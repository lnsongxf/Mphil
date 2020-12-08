% for Antonia: addpath /Applications/Dynare/4.5.3/matlab/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dynare rbc.mod
% Dynare program - Question 2 Homework 3
% Advanced Topics in Macro - Tinbergen Institute
% Aishameriane & Antonia
% November, 2020. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Variables determined by the model
var c, k, z;

%% Exogenous variables
varexo eps;

%% Predetermined variables
predetermined_variables k;

%% Parameters
parameters beta, alpha, rho, sigma;

% Values given in the exercise
beta = 0.99;
alpha = 0.33;
rho = 0.95;
sigma = 0.01;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FOR THE LOG LINEARIZED MODEL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Values in the steady state

%parameters k_ss,c_ss, z_ss; 
%k_ss = (beta*alpha)^(1/(1-alpha));
%c_ss = (beta*alpha)^(alpha/(1-alpha))-(beta*alpha)^(1/(1-alpha));
%z_ss = 0;

%% Log linearized equations
%model(linear);
%c*c_ss  = (z + alpha*k)*k_ss^alpha - k_ss*k(+1);
%c = c(+1) +(1-alpha)*k(+1)-z(+1);
%z = rho * z(-1) + eps;
%end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FOR THE NON LINEARIZED MODEL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initial values 

initval;
k = (beta*alpha)^(1/(1-alpha));
c = (beta*alpha)^(alpha/(1-alpha))-(beta*alpha)^(1/(1-alpha));
z = 0;
end;

%% Model 
model;
1/c = beta*(1/(c(+1))*exp(z(+1))*alpha*k(+1)^(alpha-1));
c = exp(z)*k^alpha-k(+1);
z = rho * z(-1) + eps;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FOR THE NON LINEARIZED MODEL IN EXP (to compare)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initial values 

%initval;
%k = (beta*alpha)^(1/(1-alpha));
%c = (beta*alpha)^(alpha/(1-alpha))-(beta*alpha)^(1/(1-alpha));
%z = 0;
%end;

%% Model 
%model;
%1/exp(c) = beta*(1/(exp(c(+1)))*exp(z(+1))*alpha*exp(k(+1))^(alpha-1));
%exp(c) = exp(z)*exp(k)^alpha-exp(k(+1));
%z = rho * z(-1) + eps;
%end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FOR ALL MODELS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Shocks
shocks;
var eps; stderr sigma;
end;

%% Results
stoch_simul(periods = 200, order =2);