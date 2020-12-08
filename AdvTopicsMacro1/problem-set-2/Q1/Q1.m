%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       TINBERGEN INSTITUTE
% PROBLEM SET 2 - ADVANCED TOPICS IN MACRO I - QUESTION 1
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
%       This program simulates an AR(1) process usint Tauchen and
%       Rowenhorst's methods and compare the results
%   1. Tauchen's with equidistant grid
%   2. Tauchen's with importance sampling
%   3. Rouwenhorst's
%__________________________________________________________________________
% Model: 
% z(t+1} = rho z(t) +  p.beta_eps*e(t+1), p.beta_eps=(1-rho^2)
% 
% e \sim N(mu_eps,sigma_eps)
%__________________________________________________________________________
%   
%   Inputs:
%       p.mu_z    double, the mean of the errors, default is 0
%       dSigma    double, the variance of the errors, should be positive, default is 1
%       p.rho_z   double, the parameter in the process, default is 0.7
%       n         double, number of grid points, default is 5
%       m         double, multiplicity factor to find the grid boundaries, default is 3
%       t         double, numer of periods for the simulation, default is 2000
%       t_burn    double, burn-in (initial periods to discard), default is 500
%       z0        double, initial value for the process, default is 0.5
%       r_p       double, parameter for the Rouwenhorts's Method
%       r_q       double, parameter for the Rouwenhorts's Method       
%       r_psi     double, parameter for the Rouwenhorts's Method
%       r_N       double, the number 
%  
%       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;

%% MAGIC NUMBERS
p.rho_z     = 0.7;
p.mu_eps    = 0;
p.sigma_eps = 1;
m           = 3;
n           = 5;
t           = 2000;
t_burn      = 500;
z0          = 1;
seed        = 6969;
r_N         = 5;

%% INITIALIZATION

rng(seed);

p.mu_z     = p.mu_eps;
t_eff      = t-t_burn;
p.beta_eps = (1-p.rho_z^2)*p.sigma_eps;
p.se_z     = p.beta_eps^0.5;
r_p        = (1+p.rho_z)/2;
r_q        = r_p;
r_psi      = p.se_z*sqrt(r_N-1);

%% Tauchen's Equispaced Grid

% create matrix with grid points (bin midpoints)
Gridp_EG = zeros(n,1);
dZN      = m*p.se_z;
dZ1      = -dZN;        % Normal distribution is symmetric

d = (dZN-dZ1)/(n-1);

Gridp_EG = (-m*p.se_z + ((1:n)-1)*d)'; % This gives you the same thing without needing the loop

% Create transition matrix
P_EG = tauchenPeq(Gridp_EG, p, n, d);

%% Tauchen's equi-likely bins (importance sampling)

% bin bounds (N-1), lowest is -infty, highest +infty
Bbound        = zeros(n-1,1);
Gridp_IS      = zeros(n,1);
Gridp_IS(n,1) = norminv((n-0.5)/n);

for i=1:n-1
    Bbound(i,1)   = norminv(i/n)*p.se_z;
    Gridp_IS(i,1) = norminv((i-0.5)/n)*p.se_z;
end 

% Create transition matrix
P_IS = tauchenPis(Gridp_IS, Bbound, p, n);

%% Generic Rouwenhorst's Method (for any N)
[Pi, P_RH, s] = rouwenhorst(r_N, r_p, r_q);

% Assemble the grid: 
% N-state Markov chain characterized by a symmetric and evenly-spaced state space
Gridp_RH  = linspace(-r_psi,r_psi,r_N)';
Gridp_RH  = Gridp_RH + p.mu_z;  % shift according to mu

%% Simulation using  true DGP

pos_ts    = SimulTS(z0, P_EG, t, t_burn);
ts_EG     = Gridp_EG(pos_ts);
pos_ts    = SimulTS(z0, P_IS, t, t_burn);
ts_IS     = Gridp_IS(pos_ts);
pos_ts    = SimulTS(z0, P_RH, t, t_burn);
ts_RH     = Gridp_RH(pos_ts);

vec_eps   = normrnd(p.mu_eps,p.sigma_eps, t-t_burn-1);
ts_SIM    = ones(t-t_burn,1); 
ts_SIM(1) = z0;

for i = 2:(t-t_burn)
   ts_SIM(i,1) =  p.rho_z*ts_SIM(i-1,1) + (1-p.rho_z^2)*vec_eps(i-1);
end

%% Results
rowNames = {'Tauchen EG', 'Tauchen IS', 'Rouwenhorst', 'True process'};
colNames = {'Mean','Std'};
results  = [mean(ts_EG) std(ts_EG); mean(ts_IS) std(ts_IS); mean(ts_RH) std(ts_RH); p.mu_z p.se_z];
tab1     = array2table(results,'RowNames',rowNames,'VariableNames',colNames);
tab1

figure(1);
subplot(4,1,1);
plot(ts_SIM, 'm');
title('Simulated AR(1) using the true GDP');

subplot(4,1,2);
plot(ts_EG, 'r');
title('Simulated series using Tauchen method with Equidistant Grid');

subplot(4,1,3);
plot(ts_IS);
title('Simulated series using Tauchen method with Importance Sampling');

subplot(4,1,4);
plot(ts_RH, 'k');
title('Simulated series using Ruwenhorst method');
sgtitle('Simulated AR(1) processess using different methods for \rho = 0.99');

figure(2);
subplot(2,2,1);
autocorr(ts_SIM);
title('Autocorrelation of the simulated AR(1) using the true GDP');

subplot(2,2,2);
autocorr(ts_EG);
title('Autocorrelation using Tauchen method with Equid. Grid');

subplot(2,2,3);
autocorr(ts_IS);
title('Autocorrelation using Tauchen method with Imp. Sampling');

subplot(2,2,4);
autocorr(ts_RH);
title('Autocorrelation using Rouwenhorst');

sgtitle('Autocorrelation of the series for different methods using \rho = 0.99');