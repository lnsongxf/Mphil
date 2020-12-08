%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       TINBERGEN INSTITUTE
%               PROBLEM SET 1 - ADVANCED TOPICS IN MACRO I - QUESTION 1
%                       Block 2 - 2020
%               Instructors: dr. E. Proehl (UvA) and dr. M. Pedroni (UvA)
%   Group members: 
%   Aishameriane V. Schmidt
%   Antonia Kurz
%
%   Version history:
%   1. 28/10/20 First lines
%   2. 29/10/20 Worked on the value function iteration using brute search
%   grid
%   3. 31/10/20 Changed the initial value function to a better guess
%   4. 01/11/20 Implemented the analytical solution and the monotonicity
%   part. Started working in the concavity part.
%   5. 02/11/20 Trying to fix the monotonicity part that is broken. No
%   success with concavity.
%   6. 03/11/20 Wrap up.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   main.m
%
%   Purpose:
%       This program solves the deterministic neoclasical growth model from
%   lecture 1 using different kinds of methods:
%   1. Value function iteration
%   2. Using monotonicity of the policy function
%   3. Using the concavity of the value function
%   4. Using Howard's policy iteration algorithm
%__________________________________________________________________________
% Analytical example: 
% u(c) = log(c) and f(k) = k^alpha
% Value function: 
% V(k) = max_k' log(k^alpha - k') + beta V(k')
% Analytical solution (benchmark): 
% V(k) = alpha + alpha/(1-alpha*beta) log(k) and k'(k) = alpha*beta*k^alpha
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
%                  method until reching convergence
%       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;

%% MAGIC NUMBERS
dAlpha = 0.3;
dBeta  = 0.95;
dDelta = 1;
dEps   = 0.01;
dn     = 1000;
dT     = 200;
dZ0    = 1;
dK0    = 0.001;

%% INITIALIZATION
%----- UTILITY FUNCTION SPECIFICATION -----%
fUtility = @(C) log(C);

%----- EVENLY SPACED GRID -----%
mKgrid = linspace(1/dn,1,dn)';

%----- INITITAL GUESS FOR VALUE FUNCTION -----%
%aV0 = zeros(dn,1); % If we are using a starting point from the capital
aV0  = (fUtility(mKgrid.^dAlpha-dDelta*mKgrid))/(1-dBeta); % Initial guess for the value function

%------------------------------ COMPUTATION -------------------------------
%----- BUILDING mU -----

mK       = repmat(mKgrid,1,dn);      % matrix n x n
mK_prime = mK';                      % matrix n x n
mC       = dZ0*mK.^dAlpha - mK_prime;    % matrix n x n.  
% Here, we use the result from slide 16 that the planer is  
% maximizing over u(dZ0*K^alpha - K'), where C(t) = dZ0*K^alpha - K'

mU = zeros(dn,dn); % a matrix n x n in which K' varies across columns and K varies across rows

for i = 1:dn
    for j = 1:dn
        if mC(i,j)>=0
            mU(i,j) = fUtility(dZ0*mK(i,j).^dAlpha - mK_prime(i,j));
        else
            mU(i,j) = -Inf; % this avoids having impossible levels of consumption
        end
    end
end

%% VALUE FUNCTION ITERATION BY BRUTE FORCE
%----- VALUE FUCNTION AND POLICY INDEXES ----
tic;
[aV,aPi_K_I] = dvfi(mU,aV0,dBeta,dEps);
elapsed_vfi  = toc;

%----- COMPUTING THE POLICY FUNCTION -----
% Vector with policy function for capital obtained from matching indexes
aPi_K = mKgrid(aPi_K_I); 

% Vector with optimal values of C(t) = dZ0*K^alpha - K'. Because we have full depreciation, 
% it follows that: pi(K)=K'
aPi_C = dZ0*mKgrid.^dAlpha-aPi_K;

% -----  ANALYTICAL SOLUTION -----
% Compute parameters
dB     = dAlpha/(1-dAlpha*dBeta);
dA     = (1/(1-dBeta))*(log(1-dAlpha*dBeta) + dBeta*dB * log(dBeta*dAlpha));

% In here we have the results in closed formula (slide 16 from the lecture notes)
aV2       = dA + dB*log(mKgrid);
aPi_K2    = dAlpha * dBeta * mKgrid.^dAlpha;
aPi_C2    = dZ0*mKgrid.^dAlpha-aPi_K;

% --------------------------------- PLOTS FOR ITEM (a) ----------------------------------
%Plot of the value function, policy function for capital, and policy function for consumption
figure(2);
subplot(3,2,1);
plot(mKgrid, aV, 'r');
xlabel('K');
ylabel('V(K)');

subplot(3,2,3);
plot(mKgrid, aPi_K, 'b');

hold on
fplot(@(a) a,[0,1], ':k')

xlabel('K');
ylabel('\pi(K)');

hold off

subplot(3,2,5);
plot(mKgrid, aPi_C,'g');
xlabel('K');
ylabel('\pi(C)');

subplot(3,2,2);
plot(mKgrid, aV2, 'r');
xlabel('K');
ylabel('V(K)');

subplot(3,2,4);
plot(mKgrid, aPi_K2, 'b');

hold on
fplot(@(a) a,[0,1], ':k')

xlabel('K');
ylabel('\pi(K)');

hold off

subplot(3,2,6);
plot(mKgrid, aPi_C2,'g');
xlabel('K');
ylabel('\pi(C)');

%% MONOTONICITY OF POLICY FUNCTION
% For this we need to change our dvfi function to search only over the
% higher values of capital

%----- VALUE FUCNTION AND POLICY INDEXES ----
tic;
[aV3,aPi_K_I] = dvfi2(mU,aV0,dBeta,dT,dK0,mKgrid,dn);
elapsed_vfimon  = toc;

%----- COMPUTING THE POLICY FUNCTION -----

% Vector with policy function for capital obtained from matching indexes
aPi_K3 = aPi_K_I(2:end); % This time the function already spits out the values for capital 

% Vector with optimal values of C(t) = dZ0*K^alpha - K'. Because we have full depreciation, 
% it follows that: pi(K)=K'
Kvector    = lagmatrix(aPi_K3,1);
Kvector(1) = 0;
aPi_C3     = dZ0*Kvector.^dAlpha-aPi_K3;

%--------------------------------- PLOTS FOR ITEM (b) ----------------------------------
%Plot of the value function, capital and consumption paths
figure(2);
subplot(3,1,1);
plot(aV3, 'r');
ylabel('V(K)');

subplot(3,1,2);
plot(aPi_K3, 'b');

hold on
fplot(@(a) a,[0,1], ':k')

xlabel('t');
ylabel('\pi(K)');

hold off

subplot(3,1,3);
plot(aPi_C3,'g');
xlabel('t');
ylabel('\pi(C)');


%% EVALUATING PERFORMANCE
models = ["VFI"; "Monotonicity"];
Time = [elapsed_vfi; elapsed_vfimon];
T1 = table(Time, 'Rownames', models);

%% CONCAVITY OF VALUE FUNCTION
% We again change our optimization routine
% We didn't get to integrate well the code so we are cleaning up and
% reestarting
clear all;

% MAGIC NUMBERS
dAlpha = 0.3;
dBeta  = 0.3;
dDelta = 1;
dEps   = 0.01;
dn     = 1000;
dT     = 200; % 200 time periods
dZ1    = 2;
dK0    = 0.001; 

% Specification
%----- UTILITY FUNCTION -----%
fUtility = @(C) log(C);

% VALUE FUNCTION ITERATION
%----- EVENLY SPACED GRID -----%
mKgrid = linspace(1/dn,1,dn)';

%----- INITITAL GUESS FOR VALUE FUNCTION -----%
aV0 = zeros(dn,1);

%------------------------------ COMPUTATION -------------------------------
%----- BUILDING mU -----
mK       = repmat(mKgrid,1,dn);          % matrix n x n
mK_prime = mK';                          % matrix n x n
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

% CONCAVITY
%----- VALUE FUNCTION AND POLICY INDEXES ----

tic;
V0= aV0;  
mK_path(1,1)=dK0;
VMAT=repmat(V0',size(mU,1),1);
V = mU+dBeta*VMAT;
a = 0;
for i=1:dT
    % where is K located?
    Index_K = find(mKgrid==mK_path(i,1));
    % while value function (given K) at K' <= value fct for K'(+1), check
    % next K', after: set mK_path(i+1,1) = mKgrid(j);
    j=1;
    while mU(Index_K,j)+dBeta*VMAT(Index_K,j)<mU(Index_K,j+1)+dBeta*VMAT(Index_K,j+1);
        j=j+1;
    end 
    mK_path(i+1,1) = mKgrid(j);
    V0 = mU(:,j)+dBeta*VMAT(:,j);
    VMAT=repmat(V0',size(mU,1), 1);
end 
elapsed_vficon  = toc;

%----- COMPUTING THE POLICY FUNCTION -----

aV3 = V0;
% Vector with policy function for capital obtained from matching indexes
aPi_K4 = mK_path(2:end); % This time the function already spits out the values for capital 

% Vector with optimal values of C(t) = dZ0*K^alpha - K'. Because we have full depreciation, 
% it follows that: pi(K)=K'
Kvector    = lagmatrix(aPi_K4,1);
Kvector(1) = 0;
aPi_C4     = dZ1*Kvector.^dAlpha-aPi_K4;

%--------------------------------- PLOTS FOR ITEM (c) ----------------------------------
%Plot of the value function, capital and consumption paths
figure(2);
subplot(3,1,1);
plot(aV3, 'r');
ylabel('V(K)');

subplot(3,1,2);
plot(aPi_K4, 'b');

hold on
fplot(@(a) a,[0,1], ':k')

xlabel('t');
ylabel('\pi(K)');

hold off

subplot(3,1,3);
plot(aPi_C4,'g');
xlabel('t');
ylabel('\pi(C)');

%% HOWARD'S POLICY FUNCTION
% Please see the other files on github


