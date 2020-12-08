%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       TINBERGEN INSTITUTE
%   PROBLEM SET 2 - ADVANCED TOPICS IN MACRO I - QUESTION 2
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
%       This program solves the neoclassical stochastic growth model from
%       question 2, homework 2. We need to use Rouwenhorst's method to
%       discretize the AR(1) process.
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
dAlpha      = 0.3;
dBeta       = 0.3;
dDelta      = 1;
dEps        = 0.01;
dn          = 1000;
dT          = 200;

% For the Markovian process
p.rho_y     = 0.7;      
p.mu_eps    = 0;        
p.sigma_eps = 1;       
t_burn      = 500;
y0          = 1;
seed        = 6969;
r_N         = 3;

%% INITIALIZATION
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
Gridp_RHy = fz(Gridp_RH);

% Get z values:
vz = fz(Gridp_RH);
mz = repmat(vz,1,dn);

%% VFI

[Tv, ig, dc] = iteration_value_function(eps, mKgrid, Gridp_RHy, dAlpha, dBeta, vz, P_RH);
pi_K = [mKgrid(ig(:,1)), mKgrid(ig(:,2)), mKgrid(ig(:,3))];


%% Policy function (not currently working)
    
    mPath_K = ones(size(mKgrid, 1), size(Gridp_RHy, 1));
    vK      = ones(size(mKgrid, 1));
    not_converged = 1;
    max_it = 500;

for i_z = 1:size(Gridp_RHy,1)
     aPath_K = ones(size(mKgrid, 1),1);
     
     for it = 1:max_it
         vk = ones(size(mKgrid, 1),1);
         for i_k = 1:size(mKgrid, 1)
            for i_kk = size(mKgrid, 1)
                cstar = uc_solve(mKgrid(i_k,1), vk(i_kk,1), Gridp_RHy(i_z,1), dBeta, dAlpha, dDelta, P_RH, i_z);
                
                kstar = Gridp_RHy(i_z,1)*mKgrid(i_k,1)^dAlpha + (1-dDelta)*mKgrid(i_k,1) - cstar;
            end
                vk(i_k,1) = kstar;
         end
         criterion = max(abs(aPath_K - vk));
         
         if (criterion<eps)
            not_converged=0;
         end
        
         aPath_K = vk;
     end
     mPath_K(:, i_z) = aPath_K;
end

%% Euler Equation Error

% u_c_inv: u_c(y) = 1/y = x -> u_c_inv(x) = 1/x = y

for l=1:r_N
    for k=1:dn
        fk = Gridp_RHy(l) *dAlpha*pi_K(k,l)^(dAlpha-1);
        indexkp = find(mKgrid==pi_K(k,l));
        EEE(k,l) = log10(abs(1 - dc(k,k,l)/(dBeta*(1+fk-dDelta)*1/dc(indexkp,indexkp,l))));
    end
end 


%% RESULTS
%--------------------------------- PLOTS ----------------------------------
%Plot of the value function and corresponding EEK
figure(1);
plot(mKgrid, Tv(:,1), 'r');
xlabel('K');
ylabel('V(K)');
hold on

plot(mKgrid, Tv(:,2), 'g');
hold on

plot(mKgrid, Tv(:,3), 'b');
legend('z=0.1380','z=1','z=7.2449');
hold off

figure(2);
plot(mKgrid, pi_K(:,1), 'r');
ylabel('K´(K)');
xlabel('K');

hold on

plot(mKgrid, pi_K(:,2), 'g');
hold on

plot(mKgrid, pi_K(:,3), 'b');
legend('z=0.1380','z=1','z=7.2449');
hold off

figure(3);
plot(mKgrid, EEE(:,1), 'r');
ylabel('EEE(K)');
xlabel('K');

hold on

plot(mKgrid, EEE(:,2), 'g');
hold on

plot(mKgrid, EEE(:,3), 'b');
legend('z=0.1380','z=1','z=7.2449');
hold off


figure(4);
plot(mKgrid, mPath_K(:,1), 'r');
xlabel('K');
ylabel('\pi(K)');
hold on

plot(mKgrid, mPath_K(:,2), 'g');
hold on

plot(mKgrid, mPath_K(:,3), 'b');
legend('z=0.1380','z=1','z=7.2449');
hold off
