%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  TINBERGEN INSTITUTE
%  PROBLEM SET 5 - ADVANCED TOPICS IN MACRO I - 
%                    Block 2 - 2020
%   Instructors: dr. E. Proehl (UvA) and dr. M. Pedroni (UvA)
%   Group members: 
%   Aishameriane V. Schmidt
%   Antonia Kurz
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   main.m
%
%   Purpose:
%       
%       This program solves the Ayagari model with aggregate uncertainty. 
%       This program is heavily based on the original code from Lilia Maliar, 
%       Serguei Maliar and Fernando Valli (2008).
%__________________________________________________________________________

clear all;
warning('off');

%% MAGIC NUMBERS

% For the model
dEps        = 0.0001;   % precision for convergence
dprod       = 0.01;     % Represents what is the increase or decrease in productivity in good and bad state
dTime       = 1500;     % Number of periods to simulate --- T
dnBurn      = 500;      % burn-in
dnstate_id  = 2;        % number of idyosincratic shock possible values
dnstate_ag  = 2;        % number of aggregate shock possible values

depsilon_u  = 0;        % idiosyncratic shock if unemployed
depsilon_e  = 1;        % idiosyncratic shock if employed

dur_bad     = 0.1;       % unemployment rate in a bad state
der_bad     = 1-dur_bad; % employment rate in a bad state
dur_good    = 0.04;      % unemployment rate in a good state
der_good    = 1-dur_good;% employment rate in a good state

% CRRA Utility
dSigma      = 1;        % risk aversion
dBeta       = 0.99;     % discount rate

% Cobb Douglas Production
dAlpha      = 0.36;     % capital share
dDelta      = 0.025;    % depreciation
dmu         = 0.65;     % unemployment benefits as a share of wage % default 0.15
dl0         = 1/0.9;    % time endowment - normalizes labor supply to 1 in the bad state --- WHAT IF WE HAVE MORE STATES?
% comment Antonia: The paper assumes that there is only two states; so I
% think it is okay to programme in a non-generic way (so only for 2 states)

% For the states
dk_min      = 0;        % minimum grid-value of capital ---- k_min (=a_min)
dk_max      = 1000;     % maximum grid-value of capital ---- k_max (=a_max)
dngridk     = 100;      % number of grid points -- ngridk
dtheta      = 7;        % degree of the polinomial for the grid   

% Select the method (1 for stochastic, 2 for non-stochastic)
dmethod     = 2;

% Parameters for Method 1 only
dnagents    = 10000; % number of agents for the stochastic simulation

% Parameters for Method 2 only
dN          = 5000; % number of grid points for the non-stochastic simulation % default 1000
kvalues_min = 0;    % minimum grid value for the non-stochastic simulation
kvalues_max = 100;  % maximum grid value for the non-stochastic simulation

kss         = ((1/dBeta-(1-dDelta))/dAlpha)^(1/(dAlpha-1)); 
        % steady-state capital in a (=k)
        % deterministic model with employment rate of 0.9 
        % (i.e., l_bar*L=1 where L is aggregate labor in the paper) 
        
dkm_min  = 30;   % minimum grid-value of the mean of 
                 % capital distribution, km 
dkm_max  = 50;   % maximum grid value of km
dngridkm = 4;    % number of grid points for km ---- ngridkm

% Matrix of transition probabilities in Den Haan, Judd, Juillard (2008)

mprob = [0.525 0.35 0.03125 0.09375  
   0.038889 0.836111 0.002083 0.122917
   0.09375 0.03125 0.291667 0.583333
   0.009115 0.115885 0.024306 0.850694];



%% Generating shocks (idiosyncratic and aggregate)

[v_idshock,v_agshock]  = SHOCKS(mprob,dTime,dnagents,dur_bad);



%% Grids for capital

% We need a grid for capital in the "individual" level and another for the
% aggregate level of capital.

% Grid for capital in the individual problem

% Because this model has the problem of performing poorly in the left side
% of the capital distribution, the capital grid needs an interpolation. It
% is described in the paper in page 7

x      = linspace(0,0.5,dngridk)';          % generate a grid of ngridk points on [0,0.5] 
                                            % interval  
y      = x.^dtheta/max(x.^dtheta);          % polynomial distribution of grid points, formula 
                                            % (7) in the paper
k_grid = dk_min+(dk_max-dk_min)*y;          % transformation of grid points from [0,0.5] 
                                            % interval to [k_min,k_max]
                                            % interval ---- k

% Grid for mean of capital
km = linspace(dkm_min,dkm_max,dngridkm)';   % generate a grid of ngridkm points on 
                                            % [km_min,km_max] interval 

%% Vectors for the shocks

epsilon     = zeros(dnstate_id,1);  % vector of possible idiosyncratic states 
epsilon(1)  = depsilon_u;           % the unemployed and employed 
epsilon(2)  = depsilon_e;           % states are 0 and 1, respectively 
                              
epsilon2    = zeros(dnstate_id,1);  % vector of possible idiosyncratic states 
epsilon2(1) = 1;                    % the unemployed and employed states are
epsilon2(2) = 2;                    % 1 and 2, respectively 
                                

a           = zeros(dnstate_ag,1);  % vector of possible aggregate states
a(1)        = 1-dprod;              % bad and good aggregate states are 1-delta_a 
a(2)        = 1+dprod;              % and 1+delta_a, respectively
                              
a2          = zeros(dnstate_ag,1);  % vector of possible aggregate states
a2(1)       = 1;                    % bad and good aggregate states are 1 and 2, 
a2(2)       = 2;                    % respectively



%% Getting initial condition (initializing)

kprime=zeros(dngridk,dngridkm,dnstate_ag,dnstate_id); 
   % next-period individual 
   % capital (k') depends on four state variables: individual k, aggregate k, 
   % aggregate shock, idiosyncratic shock 

% Initial capital function

for i=1:dngridkm
   for j=1:dnstate_ag
      for h=1:dnstate_id
         kprime(:,i,j,h)=0.9*k_grid;
      end
   end
end

% Initial distribution of capital is chosen so that aggregate capital is
% near the steady state value, kss

if dmethod==1;    

    % inititial distribution of capital for the stochastic simulation 

    kcross=zeros(1,dnagents)+kss;  % initial capital of all agents is equal to kss

else % i.e. Method 2
    
    % inititial density on the grid for the non-stochastic simulation

    kcross=zeros(2,dN);      % density function for the employed and 
                             % unemployed agents, defined in J grid points 
    igrid=(kvalues_max-kvalues_min)/dN; % interval between grid points
    jss=round(kss/igrid);    % # of the grid point nearest to kss
    kcross(1:2,jss)=1;       % all density is concentrated in the point jjs;
                             % density is zero in all other grid points
end

% Initial vector of coefficients B of the ALM (in the paper, it is b) 

% (the ALM in a bad state is ln(km')=B(1)+B(2)*ln(km) and the ALM in a good
% state is ln(km')=B(3)+B(4)*ln(km))

B=[0 1 0 1];

%__________________________________________________________________________
%
% Convergence parameters
%__________________________________________________________________________

dif_B    = 2^5;  % difference between coefficients B of the the aggregate law of motion (ALM) on 
                 % successive iterations; initially, set to a large number default = 10^10
criter_k = 1e-8; % convergence criterion for the individual capital function
criter_B = 1e-8; % convergence criterion for the coefficients B in the ALM
update_k = 0.7;  % updating parameter for the individual capital function
update_B = 0.3;  % updating parameter for the coefficients B in the ALM

%% Model solution

iteration  = 0;      % initial iteration  
init_time  = clock; % initialize the time clock

i=1; 

while dif_B>criter_B % perform iterations until the difference between coefficients is less or equal than criter_B
    
    % compututing a solution to the individual problem
    [kprime,c]  = INDIVIDUAL(mprob, dur_bad, dur_good, dngridk, dngridkm, dnstate_ag, dnstate_id, k_grid, km, der_bad, der_good, a, epsilon, dl0, dAlpha, dDelta, dSigma, dBeta, dmu, dkm_max, dkm_min, kprime, B, criter_k, dk_min, dk_max, update_k);
    
    if dmethod==1; 
        [kmts,kcross1]  = AGGREGATE_ST(dTime, v_idshock, v_agshock, dkm_max, dkm_min, kprime, km, k_grid, epsilon2, dk_min, dk_max, kcross,a2);
    else % i.e., Method 2 
        [kmts,kcross1]  = AGGREGATE_NS(dl0, dAlpha, mprob, dur_bad, dur_good, dTime, dN, kvalues_min, kvalues_max, dngridk, dngridkm, dnstate_ag, dnstate_id, v_idshock, v_agshock, dkm_max, dkm_min, kprime, km, k_grid, epsilon2, dnBurn, dk_min, dk_max, kcross, a, a2);
    end
    
    % Time series for the ALM regression 

    ibad  = 0; % count how many times the aggregate shock was bad
    igood = 0; % count how many times the aggregate shock was good
    xbad  = 0; % regression-variables for a bad state
    ybad  = 0; % regression-variables for a bad state
    xgood = 0; % regression-variables for a good state
    ygood = 0; % regression-variables for a good state
    
    for i=dnBurn+1:dTime-1
        if v_agshock(i)==1
          ibad=ibad+1;
          xbad(ibad,1)=log(kmts(i));
          ybad(ibad,1)=log(kmts(i+1));
       else
          igood=igood+1;
          xgood(igood,1)=log(kmts(i));
          ygood(igood,1)=log(kmts(i+1));
       end
    end

    % Krusell-Smith
    % run the OLS regression ln(km')=B(1)+B(2)*ln(km) for a bad agg. state and compute R^2 (which is the first statistic in s5)
    [B1(1:2),s2,s3,s4,s5]=regress(ybad,[ones(ibad,1) xbad]);
    R2bad=s5(1); 

    % make the OLS regression ln(km')=B(3)+B(4)*ln(km) for a good agg. state and compute R^2 (which is the first statistic in s5)
    [B1(3:4),s2,s3,s4,s5]=regress(ygood,[ones(igood,1) xgood]);
    R2good=s5(1);

    dif_B=norm(B-B1); % compute the difference between the initial and obtained vector of coefficients
    
    % To ensure that initial capital distribution comes from the ergodic set,
    % we use the terminal distribution of the current iteration as initial 
    % distribution for a subsequent iteration. When the solution is sufficiently 
    % accurate, dif_B<(criter_B*100), we stop such an updating and hold the 
    % distribution "kcross" fixed for the rest of iterations. ·
    
    if dif_B>(criter_B*100)
        kcross=kcross1; % the new capital distribution  replaces the old one
    end

    B=B1*update_B+B*(1-update_B); % update the vector of the ALM coefficients according to the rule (9) in the paper
    iteration=iteration+1;
    
end

end_time  = clock;                     % end the time clock
et        = etime(end_time,init_time); % compute time in seconds that has elapsed 
                                       % between init_time and end_time
disp('Elapsed Time (in seconds):'); et
disp('Iterations');          iteration
format long g; 
disp('R^2 bad aggregate shock:'); R2bad(1)
disp('R^2 good aggregare shock:'); R2good(1)
format; 


%% EULER EQUATION ERRORS
u_c     = @(x) x^(-dSigma); 
u_cinv  = @(x) x^(-1/dSigma);
f_k     = @(k,l,z) dAlpha*(z*(k/l/dl0)^(dAlpha-1));     % MPK = interest rate
w       = @(k,l,z) (1-dAlpha)*(z*(k/l/dl0)^(dAlpha));   % MPL = wage
un      = [dur_bad, dur_good];

for i=1:dTime-1
        z(i)   = a(v_agshock(i,:));                         % aggregate shock
        L(i)   = sum(epsilon(v_idshock(i,:)))/dnagents;     % labour supply per period
        ir(i)  = f_k(kmts(i),L(i),z(i));                    % interest rate
        tau(i) = (dmu*un(v_agshock(i,:)))/(dl0*L(i));       % tax
        cons(i)= (1+ir(i)-dDelta)*kmts(i)  - kmts(i+1) ...
            + w(kmts(i),L(i),z(i))* ((1-tau(i))*dl0*L(i) +dmu*(1-L(i))); % consumption in i by BC
        mu(i)  = dBeta*(1+ir(i)) - dDelta;                  % marginal utility of consumption
end 
for i=1:dTime-2
        EEE(i) = log10(abs(1- (u_cinv(mu(i+1))*u_c(cons(i+1)))/cons(i)));
end

if dmethod ==1
% stochastic
matlab.io.saveVariablesToScript('stoch.m',{'EEE','kmts','kcross'})
else
% non-stochastic
matlab.io.saveVariablesToScript('nonstoch.m',{'EEE','kmts','kcross'}) 
end 

EEE_s = load('stoch').EEE;
EEE_n = load('nonstoch').EEE;
kmts_s = load('stoch').kmts;
kmts_n = load('nonstoch').kmts;
kcross_s = load('stoch').kcross;
kcross_n = load('nonstoch').kcross;


%% __________________________________________________________________________
%
% PLOTS
%__________________________________________________________________________


% Euler Equation Errors
figure(1);
plot(EEE_s(:,dnBurn:dTime-2), 'r');
hold on

plot(EEE_n(:,dnBurn:dTime-2), 'b');
xlabel('t');
ylabel('EEE(k)');

legend('Stochastic','Non-Stochastic');
hold off


% Mean Capital
figure(2);
plot(kmts_s(dnBurn:dTime-2,:), 'r');
hold on

plot(kmts_n(dnBurn:dTime-2,:), 'b');
xlabel('t');
ylabel('mean capital');

legend('Stochastic','Non-Stochastic');
hold off


% Savings Distribution for Stochastic
figure(3);
histogram(kcross_s, dN, 'Normalization','probability');
xlabel('k');
ylabel('probability');

% Savings Distribution for Non-Stochastic
figure(4);
plot(kcross_n(1,:), 'r');
hold on

plot(kcross_n(2,:), 'b');
xlabel('k');
ylabel('probability');

legend('Unemployed','Employed');
hold off

%__________________________________________________________________________
%
% FIGURE OF THE AGGREGATE TIME SERIES SOLUTION
%__________________________________________________________________________

kmalm   = zeros(dTime,1);  % represents aggregate capital computed from the ALM
kmalm(1)= kmts(1);         % in the first period km computed from the ALM (kmalm) 
                           % is equal km computed from the cross-sectional capital 
                           % distribution (kmts)                      

for t=1:dTime-1       % compute kmalm for t=2:T
   if v_agshock(t)==1
      kmalm(t+1)=exp(B(1)+B(2)*log(kmalm(t)));
   else
      kmalm(t+1)=exp(B(3)+B(4)*log(kmalm(t)));
   end
   
end

Tts=1:1:dTime;
axis([min(Tts) max(Tts) min(kmts)*0.99 max(kmts)*1.01]); axis manual; hold on; 
plot (Tts,kmts(1:dTime,1),'-',Tts,kmalm(1:dTime,1),'--'),xlabel('Time'), ylabel('Aggregate capital series'), title('Figure 1. Accuracy of the aggregate law of motion.')
legend('implied by individual policy rule', 'aggregate law of motion');
hold off