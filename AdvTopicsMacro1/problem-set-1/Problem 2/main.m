%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       TINBERGEN INSTITUTE
%               PROBLEM SET 1 - ADVANCED TOPICS IN MACRO I - QUESTION 2
%                       Block 2 - 2020
%               Instructors: dr. E. Proehl (UvA) and dr. M. Pedroni (UvA)
%   Group members: 
%   Aishameriane V. Schmidt
%   Antonia Kurz
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%__________________________________________________________________________
% Analytical example: 
% u(c) = log(c) and f(k) = dZ0*k^alpha
% Value function: 
% V(k) = max_k' log(dZ0*k^alpha - k') + beta V(k')
% Analytical solution (benchmark): 
% V(k) = a + alpha/(1-alpha*beta) log(k) and k'(k) = dZ0*alpha*beta*k^alpha
%__________________________________________________________________________
%   
%   Inputs:
%       dAlpha             double, the share of the capital in the
%                          production function.
%       dBeta              double, the coefficient of impatience (or discount) 
%                          of the households. Must be between 0 and 1.
%       dDelta             double, the depreciation rate. Must be beteeen 0
%                          and 1 (inclusive).
%       dEps               double, the precision used to stop the
%                          algorithms in which a stopping rule is necessary.
%       dn                 double, number of points in the grid for the optimization
%       dK0                double, initial capital level
%       dT                 double, last period
%       dK0                double, initial capital level
%       dZ0                double, the initial value for zt (exogenous process)
%
%   Return Value:
%       dC         vector of doubles, the consumption policy function
%       dK         vector of doubles, the capital policy function path
%       vdTime     vector of doubles, the computational time used by each
%                  method
%       viIter     vector of integers, the number of iterations for each
%                  method until reaching convergence
%       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% MAGIC NUMBERS
dAlpha = 0.3;
dBeta  = 0.3;
dDelta = 1;
dEps   = 0.01;
dn     = 1000;
dT     = 200; % 200 time periods
dZ0    = 1;   % TFP before doubling


%% Specification
%----- UTILITY FUNCTION -----%
fUtility = @(C) log(C);

%% Change of TFP, start at old Steady state --------------------------
dZ1    = 2*dZ0;          % TFP

%% STEADY STATE VALUES (analytically)
kss_1 = (dZ0 * dAlpha * dBeta)^(1/(1-dAlpha));
kss_2 = (dZ1 * dAlpha * dBeta)^(1/(1-dAlpha));


%% 200 equations and unknowns
% Assumption: 
% Policy Function is k'(k) = 2 z \alpha \beta k^\alpha 
% after TFP change
% Goal: 
% what is the actual path of K given that we start (and know) the old SS?
aPath_K(1,1) = kss_1;
for i=1:dT
    aPath_K(i+1,1) = dZ1 * dAlpha * dBeta * aPath_K(i,1)^dAlpha;
end 
if aPath_K(dT+1,1) == kss_2
    "Reach Steady State"
else
    "No convergence"
end 
for i=1:dT
    if aPath_K(i+1,1) == kss_2
        timecount(i,1) = 0;
    else
        timecount(i,1) = 1;
    end 
end 
sum(timecount)
% Reach second steady state after 30 time periods
% timer: 0.005 s

plot((0:dT), aPath_K,'g');
xlabel('t');
ylabel('K(t)');


%% OR
% use policy function shooting:
aPath_K(1,1) = dK0;
aPath_K(2,1) = dK0;
Fk = @(k) dZ1*k^dAlpha + (1-dDelta)*k;
F_k = @(k) dZ1*dAlpha*k^(dAlpha-1) + (1-dDelta);
% for i=3:dT+1
%     aPath_K(i,1) = uc_solve(aPath_K(i-2,1), aPath_K(i-1,1), mKgrid, dZ1, dBeta, dAlpha, dDelta);
% end 
for i=3:dT+1
    k1=aPath_K(i-2,1);
    k2=aPath_K(i-1,1);
    aPath_K(i,1) = Fk(k2) - dBeta*F_k(k2)* (Fk(k1)-k2);
end 
% not successful: k in period 201 would be 2.6918 (but convergence!)



%% Guessing first period capital
% We make an assumption about k_ss_1 and let it converge to k_ss_2
dK0    = 0.5; 

% VALUE FUNCTION ITERATION
%----- EVENLY SPACED GRID -----%
mKgrid = linspace(1/dn,1,dn)';

%----- INITITAL GUESS FOR VALUE FUNCTION -----%
aV0 = zeros(dn,1);

%------------------------------ COMPUTATION -------------------------------
%----- BUILDING mU -----
mK       = repmat(mKgrid,1,dn);      % matrix n x n
mK_prime = mK';                      % matrix n x n
mC       = dZ1*mK.^dAlpha - mK_prime;    % matrix n x n.  
% Here, we use the result from slide 16 that the planer is  
% maximizing over u(dZ0*K^alpha - K'), where consumption will be given
% by C(t) = dZ1*K^alpha - K'

mU = zeros(dn,dn); % a matrix n x n in which K' varies across columns and K varies across rows

for i = 1:dn
    for j = 1:dn
        if mC(i,j)>=0
            mU(i,j) = fUtility(dZ1*mK(i,j).^dAlpha - mK_prime(i,j));
        else
            mU(i,j) = -Inf; % this avoids having impossible levels of consumption
        end
    end
end

%----- VALUE FUNCTION AND POLICY INDEXES ----
% iterate so many times until value functions (matrix) given all possible parameters converge
[aV,aPi_K_I] = dvfi(mU,aV0,dBeta,dEps);

%----- COMPUTING THE POLICY FUNCTION -----
% Vector with policy function for capital obtained from matching indexes
% K':
aPi_K = mKgrid(aPi_K_I); 

% Vector with optimal values of C(t) = dZ1*K^alpha - K'. Because we have full depreciation, 
% it follows that: pi(K)=K'
aPi_C = dZ1*mKgrid.^dAlpha-aPi_K;

% Computing time path
% Vector (T+1) x 1 with indeces of initial K (K0) and optimal levels of capital
% (maximisers) at each period
% The policy function gives us the optimal choice for the control given our
% current states. Therefore, it is a map that will give us what path the
% capital is taking towards the steady state.

aPath_K_I = zeros(dT+1,1);   % we have 100 + 1 periods (0,1,2,...,100)

% 2nd method
dK0_I = dK0/(1/dn);      % Index of initial capital level on grid
aPath_K_I(1) = dK0_I;        % we depart from the initial point

for j = 2:dT+1
    aPath_K_I(j) = aPi_K_I(aPath_K_I(j-1));
end

aPath_K = mKgrid(aPath_K_I);

if aPath_K(dT+1,1) == kss_2
    "Reach Steady State"
else
    "No convergence"
end 
for i=1:dT
    if aPath_K(i+1,1) == kss_2
        timecount(i,1) = 0;
    else
        timecount(i,1) = 1;
    end 
end 
sum(timecount)
aPath_K(dT+1,1)
kss_2
% Reach second steady state not even after 200 time periods (but almost: 0.0860 vs. 0.0863)
% timer: 3.129 s

%% Guessing last period capital
% We make an assumption about k_ss_2 and see if the initial k_ss_1
% converges to the analytical one
dK201    = 0.5; 

% VALUE FUNCTION ITERATION
%----- EVENLY SPACED GRID -----%
mKgrid = linspace(1/dn,1,dn)';

%----- INITITAL GUESS FOR VALUE FUNCTION -----%
aV0 = zeros(dn,1);

%------------------------------ COMPUTATION -------------------------------
%----- BUILDING mU -----
mK       = repmat(mKgrid,1,dn);      % matrix n x n
mK_prime = mK';                      % matrix n x n
mC       = dZ1*mK.^dAlpha - mK_prime;    % matrix n x n.  
% Here, we use the result from slide 16 that the planer is  
% maximizing over u(dZ0*K^alpha - K'), where consumption will be given
% by C(t) = dZ1*K^alpha - K'

mU = zeros(dn,dn); % a matrix n x n in which K' varies across columns and K varies across rows

for i = 1:dn
    for j = 1:dn
        if mC(i,j)>=0
            mU(i,j) = fUtility(dZ1*mK(i,j).^dAlpha - mK_prime(i,j));
        else
            mU(i,j) = -Inf; % this avoids having impossible levels of consumption
        end
    end
end

%----- VALUE FUCNTION AND POLICY INDEXES ----
% iterate so many times until value functions (matrix) given all possible parameters converge
[aV,aPi_K_I_rev] = dvfi_rev(mU,aV0,dBeta,dEps);
% return all values that maximise the value function

%----- COMPUTING THE POLICY FUNCTION -----
% Vector with reverse policy function for capital obtained from matching indexes
% K given K':
aPi_K_rev = mKgrid(aPi_K_I_rev); 

% Vector with optimal values of C(t) = dZ1*K^alpha - K'. Because we have full depreciation, 
% it follows that: pi(K)=K'
% for the optimal K given every K' in grid:
aPi_C = dZ1*aPi_K_rev.^dAlpha-mKgrid;

% Computing time path
% Vector (T+1) x 1 with indeces of initial K (K0) and optimal levels of capital
% (maximisers) at each period
% The policy function gives us the optimal choice for the control given our
% current states. Therefore, it is a map that will give us what path the
% capital is taking towards the steady state.

aPath_K_I = zeros(dT+1,1);   % we have 200 + 1 periods (0,1,2,...,200)

% 2nd method
dK201_I = (1-dK201)/(1/dn);      % Index of last capital level on grid
aPath_K_I(1) = dK201_I;          % we depart from that initial point

for j = 2:dT+1
    aPath_K_I(j) = aPi_K_I(aPath_K_I(j-1));
end

aPath_K = mKgrid(aPath_K_I);

if aPath_K(dT+1,1) == kss_1
    "Reach Steady State"
else
    "No convergence"
end 
for i=1:dT
    if aPath_K(i+1,1) == kss_1
        timecount(i,1) = 0;
    else
        timecount(i,1) = 1;
    end 
end 
sum(timecount)
aPath_K(dT+1,1)
kss_1

% without any assumption for the initial state, one cannot infer the exact
% location of the starting point - it could have just been the the steady
% state and we stay in it over 200 periods.
% timer: 2.570 s


%--------------------------------- PLOTS ----------------------------------
%Plot of the value function, policy function, and time path
figure(2);
subplot(3,1,1);
plot(mKgrid, aV, 'r');
xlabel('K');
ylabel('V(K)');

subplot(3,1,2);
plot(mKgrid, aPi_K, 'b');

hold on
fplot(@(a) a,[0,1], ':k')

xlabel('K');
ylabel('\pi(K)');

hold off

subplot(3,1,3);
plot((0:dT), aPath_K,'g');
xlabel('t');
ylabel('K(t)');
