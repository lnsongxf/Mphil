%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       TINBERGEN INSTITUTE
%               PROBLEM SET 1 - ADVANCED TOPICS IN MACRO I - QUESTION 1
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

dK0    = 0.001; 

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


%% HOWARD
%----- VALUE FUNCTION AND POLICY INDEXES ----
V0= aV0;  
mK_path(1,1)=dK0;
VMAT=repmat(V0',size(mU,1),1);
V = mU+dBeta*VMAT;
eta = 5;
for i=1:(dT/eta)
    % for j=1:5: 
        % while j<5: use mKgrid of current K, transform, plug in value function;
        % j==5: use max of Value function
    for j=1:eta
        if j<eta
            % where is K located?
            Index_K = find(mKgrid==mK_path((i-1)*5+j,1));
            V0=mU(:,Index_K)+dBeta*VMAT(:,Index_K);
            VMAT=repmat(V0',size(mU,1),1);
            mK_path((i-1)*5+j+1,1) = mKgrid(Index_K);
        else 
            Index_K = find(mKgrid==mK_path(i*5,1));
            % maximum value in this choice (vector) given this K
            [Vmax,col]=max(mU(Index_K,:)+dBeta*VMAT(Index_K,:),[],2);
            V0 = max(VMAT,[],2);
            VMAT=repmat(V0',size(mU,1),1);
            mK_path((i-1)*5+j+1,1) = mKgrid(col);
        end
    end 
end 