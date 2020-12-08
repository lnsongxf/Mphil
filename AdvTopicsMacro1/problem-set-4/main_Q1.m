%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       TINBERGEN INSTITUTE
%   PROBLEM SET 4 - ADVANCED TOPICS IN MACRO I - QUESTION 1
%                       Block 2 - 2020
%   Instructors: dr. E. Proehl (UvA) and dr. M. Pedroni (UvA)
%   Group members: 
%   Aishameriane V. Schmidt
%   Antonia Kurz
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   main.m
%
%   Purpose:
%       To solve the stationary partial equilibrium in Ayagari's model
%  1) Solve the household's problem and get c(a,y) and a'(a,y) -- VFI
%   1.1) Take care with the occasionally binding constraint
%  2) Construct the transition function
%  3) Obtain the stationary distribution
%
%__________________________________________________________________________
% Analytical example: 
% u(c) = log(c) and f(k) = z*k^alpha
% z(t) = exp(yt), y(t) = rho*y(t-1) + epsilon(t)
% epsilon \sim N(mu_eps,sigma_eps)
%
% Value function: 
% V(k) = max_k' log(z*k^alpha - k') + beta V(k')
% Analytical solution (benchmark): 
% V(k) = a + alpha/(1-alpha*beta) log(k) and k'(k) = z*alpha*beta*k^alpha
%__________________________________________________________________________
%   
%   Inputs:
%       dAlpha     double, the share of the capital in the
%                   production function.
%       dBeta      double, the coefficient of impatience (or discount) 
%                   of the households. Must be between 0 and 1.
%       dDelta     double, the depreciation rate. Must be beteeen 0
%                   and 1 (inclusive).
%       dEps       double, the precision used to stop the
%                   algorithms in which a stopping rule is necessary.
%       dn         double, number of points in the grid for the optimization
%       dK0        double, initial capital level
%       dT         double, last period
%       dK0        double, initial capital level
%       z0         double, the initial value for zt (exogenous process)
%       p.mu_z     double, the mean of the errors, default is 0
%       dSigma     double, the variance of the errors, should be positive, default is 1
%       p.rho_z    double, the parameter in the process, default is 0.7
%       t          double, numer of periods for the simulation, default is 2000
%       t_burn     double, burn-in (initial periods to discard), default is 500
%       z0         double, initial value for the process, default is 0.5
%       r_p        double, parameter for the Rouwenhorts's Method
%       r_q        double, parameter for the Rouwenhorts's Method       
%       r_psi      double, parameter for the Rouwenhorts's Method
%       r_N        double, the N of the Rouwenhorst's Methos
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
%% MAGIC NUMBERS

% For the model
dAlpha      = 0.33;
dBeta       = 0.95;
dDelta      = 0.1;
dEps        = 0.01;
dn          = 1000;
dT          = 200;
dR          = 1.04;
dw          = 1;
drisk       = 2;                        % coefficient of risk aversion
da0         = 0;                        % borrowing constraint
dgridpoints  = 1001;                     % number of asset grid points
daM          = 100;                     % maximum asset level

% For the Markovian process
p.rho_y     = 0.9;      
p.mu_eps    = 0;        
p.sigma_eps = 0.1;       
t_burn      = 500;
y0          = 1;
seed        = 6969;
r_N         = 7;

%% INITIALIZATION

% Generating y
% y = log of labor income and follows an AR model
% labor income = exp(y) ----> z is our labor income
rng(seed);
t          = dn + t_burn;
p.mu_y     = p.mu_eps;
p.beta_eps = p.sigma_eps/(1-p.rho_y^2);
p.se_y     = p.beta_eps^0.5;
r_p        = (1+p.rho_y)/2;
r_q        = r_p;
r_psi      = p.se_y*sqrt(r_N-1);
fz         = @(y) exp(y);

%----- EVENLY SPACED GRID for capital -----%
mKgrid = linspace(1/dn,1,dn)';

%% Rouwenhorst's Method to produce the transition matrix and the exogenous process
[Pi, P_RH, s] = rouwenhorst(r_N, r_p, r_q);

% Assemble the grid: 
% N-state Markov chain characterized by a symmetric and evenly-spaced state space
Gridp_RH  = linspace(-r_psi,r_psi,r_N)';
Gridp_RH  = Gridp_RH + p.mu_y;  % shift according to mu
Gridp_RHy = fz(Gridp_RH)';

% Get z values:
vz = fz(Gridp_RH);
mz = repmat(vz,1,dn);

%% ENDOGENOUS GRID METHOD TO FIND POLICY FUNCTION

% Based heavily on http://www.personal.ceu.hu/departs/personal/Katrin_Rabitsch/ConsSav_PolicyIterationEndogGrid.m

% set up asset grid
gridA  = linspace(-da0,daM,dgridpoints)' ;

n   = ones(1,length(Gridp_RHy));
nn  = ones(dgridpoints,1);

ini_a      = gridA*n;                     % starting values for policy fct. guess for a''(a',y')
current_a  = gridA*n;                     % initialize vector for a grid

it            = 0;
not_converged = 1;
tol_it        = 500;

% start main loop that iterates over the policy function, until fixed point is reached
while not_converged & it < tol_it
        
        old_a = current_a;
        
        % Calculate the conditional expectation of Euler equations as a functions of a'
        CE_EE=zeros(dgridpoints,r_N);
        for iy = 1:r_N                   % iterate over current productivity
            for ia_prime = 1:dgridpoints % iterate over asset positions 
                for iy_prime = 1:r_N    % iterate over future productivity
                    % consumption is computed automatically in a way that takes care of the borrowing constraint (by taking the maximum)
                    cp  = Gridp_RHy(1,iy_prime) + dR*gridA(ia_prime,1) - max(-da0,ini_a(ia_prime,iy_prime)); % see https://alisdairmckay.com/Notes/HetAgents/EGM.html to know where this came from
                    CE_EE(ia_prime,iy)  = CE_EE(ia_prime,iy)  + dBeta*P_RH(iy,iy_prime)*cp.^(-drisk);
                end
            end
        end
        % We leave this triple loop with the conditional expectation of the
        % Euler equation at each gridpoint for a'
        
        % Now we can "reverse-engineer" to find a
        for iy = 1:r_N
            for ia=1:dgridpoints
                c = (dR * CE_EE(ia,iy) )^(-1/drisk);                                  % consumption at gridpoint (a',y')
                current_a(ia,iy) =  ( c - Gridp_RHy(1,iy) + current_a(ia,1) ) / dR;   % implied value of a at gridpoint (a',y') and under current policy fct guess app(a',y')
            end
        end       
        
        % update policy function
        for iy = 1:r_N
            ini_a(:,iy)=interp1(current_a(:,iy),gridA,gridA,'linear','extrap');
        end        
        % This stuff is old and needs to be changed
       criterion = max(max(abs(current_a-old_a)./(1+abs(old_a)))); % Not 100% on why they need to do this way
        
        if (criterion<dEps)
            not_converged=0;
        end
        it = it + 1;
end

%--------------------------------------------------------------------------
% Get consumption policy rule, computed from the found ini_a
%--------------------------------------------------------------------------

cp=zeros(dgridpoints,r_N);
for iy_prime=1:r_N
   cp(:,iy_prime)  = nn*Gridp_RHy(1,iy_prime) + dR *gridA(:,1) - max(-da0,ini_a(:,iy_prime));
end

%% STEADY STATE
% The policy function for a' and the matrix Pi induce the Markov's transition function Q

Q = compute_Q(ini_a, P_RH);

% We find the stationary distribution associated to Q
Phi_ss = compute_ss_dist(Q);

%% RESULTS
%--------------------------------- PLOTS ----------------------------------
%Plot of the policy functions for c and a
figure(1);
plot(gridA, cp(:,1), 'y');
ylabel('\pi(c)');
xlabel('a');
hold on

plot(gridA, cp(:,2), 'm');
hold on

plot(gridA, cp(:,3), 'c');
hold on

plot(gridA, cp(:,4), 'r');
hold on

plot(gridA, cp(:,5), 'g');
hold on

plot(gridA, cp(:,6), 'b');
hold on

plot(gridA, cp(:,7), 'k');
legend('y=.1691','y=.3058','y=.5530', 'y=1.0000', 'y=1.8082', 'y=3.2697', 'y=5.9124');
hold off

figure(2);
plot(gridA, ini_a(:,1), 'y');
ylabel('\pi(a)');
xlabel('a');
hold on

plot(gridA, ini_a(:,2), 'm');
hold on

plot(gridA, ini_a(:,3), 'c');
hold on

plot(gridA, ini_a(:,4), 'r');
hold on

plot(gridA, ini_a(:,5), 'g');
hold on

plot(gridA, ini_a(:,6), 'b');
hold on

plot(gridA, ini_a(:,7), 'k');
legend('y=.1691','y=.3058','y=.5530', 'y=1.0000', 'y=1.8082', 'y=3.2697', 'y=5.9124');
hold off