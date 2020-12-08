%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       TINBERGEN INSTITUTE
%   PROBLEM SET 4 - ADVANCED TOPICS IN MACRO I - QUESTION 2
%                       Block 2 - 2020
%   Instructors: dr. E. Proehl (UvA) and dr. M. Pedroni (UvA)
%   Group members: 
%   Aishameriane V. Schmidt
%   Antonia Kurz
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   main_Q2.m
%
%   Purpose:
%       ? need to be defined 
%       This program solves the neoclassical stochastic growth model from
%       question 2, homework 2. We need to use Rouwenhorst's method to
%       discretize the AR(1) process.
%__________________________________________________________________________
clear all;
%% MAGIC NUMBERS

% For the model
dEps        = 0.0001;
dna         = 250;      % grid precision for assets
alow        = 0;        % borrowing limit
ahigh       = 10;       % lending limit, needs to adjusted!

% CRRA Utility
dSigma      = 2;        % risk aversion
dBeta       = 0.95;     % discount rate

% Cobb Douglas Production
dAlpha      = 0.33;     % capital share
dDelta      = 0.1;      % depreciation
r0          = 0.04;     % starting interest rate
dR          = 1+r0;     % gross interest rate
w           = 1;        % starting wage

% For the Markovian process of y
p.rho_y     = 0.9;      
p.mu_eps    = 0;        
p.sigma_eps = 0.1;       
t_burn      = 500;
seed        = 6969;
dny         = 7;


%% INITIALIZATION

% Policy Function for a':
g_a = @(a_k, y_j) dR*a_k + y_j;

% CRRA utility
u_c    = @(c) c.^(-dSigma);        % marginal utility of consumption
invu_c = @(x) x.^(-1/dSigma);      % inverse of marginal utility of consumption

% Markov
rng(seed);
p.mu_y     = p.mu_eps;
p.beta_eps = p.sigma_eps/(1-p.rho_y^2);
p.se_y     = p.beta_eps^0.5;
r_p        = (1+p.rho_y)/2;
r_q        = r_p;
r_psi      = p.se_y*sqrt(dny-1);

%----- EVENLY SPACED GRID for assets -----%
mAgrid = linspace(alow,ahigh,dna)';

% Rouwenhorst's Method to produce the transition matrix and the exogenous process
[Pi, P_RH, s] = rouwenhorst(dny, r_p, r_q);
Gamma = P_RH;

% Assemble the grid: 
% N-state Markov chain characterized by a symmetric and evenly-spaced state space
mYgrid  = linspace(-r_psi,r_psi,dny)';
mYgrid  = mYgrid + p.mu_y;  % shift according to mu

% vectorize the grid in two dimensions
Amat = repmat(mAgrid,1,dny);            % values of A change vertically
Ymat = repmat(mYgrid.',dna,1);          % values of Y change horizontally

% get eigenvector:
[V,D,W]   = eig(Gamma);
% Check in which D==1.000, eigenvalue 1
gamma     = -W(:,1);        % impose positive values


%% endogenous functions

% optimal labor supply
H  = 1;

% current consumption level, cp0(anext,ynext) is the guess
C0 = @(cp0,r) invu_c(dBeta*(1+r)*u_c(cp0)*Gamma);
                
% current asset level, c0 = C0(cp0(anext,ynext))
A0 = @(anext,y,c0,r,w) 1/(1+r) * (c0+anext-H*y.*w);


%% solve for the stationary equilibrium

% convergence criterion for consumption iteration
crit = 10^(-6);

% parameters of the Monte-Carlo simulation
% note: 
% Choose a high T >= 10^(-4) once the algorithm is running.
I = 10^(4);             % number of individuals
T = 10^(4);             % number of periods

% choose interval where to search for the stationary interest rate
% note: 
% the staionary distribution is very sensitive to the interst rate. 
% make use of the theoretical result that the stationary rate is slightly 
% below 1/beta-1
% r0  = (1/dBeta-1)-[10^(-12),10^(-4)]; (already set up)

% Antonia's tryout
% alpha = dAlpha;
% b =alow;
% delta = dDelta;
% [residual,at,r] = stationary_equilibrium(r0,crit,I,T,Amat,Ymat,dAlpha,alow,dDelta,Gamma,A0,C0,H, mAgrid, mYgrid);


% set up an anonymous function
fprintf('Start solving the Aiyagari model... \n');
tic;
myfun   = @(r) stationary_equilibrium(r,crit,I,T,Amat,Ymat,dAlpha,alow,dDelta,Gamma,A0,C0,H, mAgrid, mYgrid);
options = optimset('display','iter','TolX',1e-8,'MaxIter',20);
rstar   = fzero(myfun,r0,options);
fprintf('Done with the Aiyagari model in %f sec. \n',toc);

% get the simulated asset levels
fprintf('Fetching the wealth distribution... \n');
[r,at] = stationary_equilibrium(rstar,crit,I,T,Amat,Ymat,dAlpha,alow,dDelta,Gamma,A0,C0,H, mAgrid, mYgrid);








% 
% %% RESULTS
% %--------------------------------- PLOTS ----------------------------------
% %Plot of the value function and corresponding EEK
% figure(1);
% plot(mKgrid, Tv(:,1), 'r');
% xlabel('K');
% ylabel('V(K)');
% hold on
% 
% plot(mKgrid, Tv(:,2), 'g');
% hold on
% 
% plot(mKgrid, Tv(:,3), 'b');
% legend('z=0.1380','z=1','z=7.2449');
% hold off
% 
% figure(2);
% plot(mKgrid, pi_K(:,1), 'r');
% ylabel('K´(K)');
% xlabel('K');
% 
% hold on
% 
% plot(mKgrid, pi_K(:,2), 'g');
% hold on
% 
% plot(mKgrid, pi_K(:,3), 'b');
% legend('z=0.1380','z=1','z=7.2449');
% hold off
% 
% figure(3);
% plot(mKgrid, EEE(:,1), 'r');
% ylabel('EEE(K)');
% xlabel('K');
% 
% hold on
% 
% plot(mKgrid, EEE(:,2), 'g');
% hold on
% 
% plot(mKgrid, EEE(:,3), 'b');
% legend('z=0.1380','z=1','z=7.2449');
% hold off
% 
% 
% figure(4);
% plot(mKgrid, mPath_K(:,1), 'r');
% xlabel('K');
% ylabel('\pi(K)');
% hold on
% 
% plot(mKgrid, mPath_K(:,2), 'g');
% hold on
% 
% plot(mKgrid, mPath_K(:,3), 'b');
% legend('z=0.1380','z=1','z=7.2449');
% hold off
