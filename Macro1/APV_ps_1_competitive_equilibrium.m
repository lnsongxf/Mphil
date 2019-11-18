%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       APV_ps_1_competitive_equilibrium.m
%
%   Purpose:
%       This program has the equations that are necessary to solve the
%       problem of heterogeneity in risk aversion after solving
%       analitically the equilibrium conditions and finding the equations
%       that implicitly gives the trajectories of consumption, prices and
%       utility given the risk aversion and coefficient of impatience.
%       Notice that this concerns only the household 1.
%   
%   Inputs:
%       dSigma1    double, the coefficient of relative risk aversion of
%                  household 1. Must be positive and not equal to one.
%       dSigma2    double, the coefficient of relative risk aversion of
%                  household 2. Must be positive and not equal to one.
%       dBeta      double, the coefficient of impatience (or discount) 
%                  of the households. Must be between 0 and 1.      
%
%   Return Value:
%       dcL        double, the consumption of household 1 when the state of
%                  nature is L
%       dcH        double, the consumption of household 1 when the state of
%                  nature is L
%       dpH        double, the prices when the state of
%                  nature is L
%       dU1        double, the intertemporal utility function of household
%                  1 considering all possible histories
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dcL dcH dpH dU1]=APV_ps_1_competitive_equilibrium(dSigma1,dSigma2,dBeta)
%function competitive_equilibrium_out = competitive_equilibrium(dSigma1,dSigma2,dBeta, outvar);

% The equation relating the price dpH, nu1 and Sigmas into a function
% called dpH_equation
dpH_equation = @(dpH, dnu1) ((dpH^((-1)/dSigma1))*dnu1 + (dpH^((-1)/dSigma2))*(1-dnu1)-2);

% We now want to know which values of dpH solve the equation above for a
% grid of nu1
fcompute_dpH = @(dnu1) (fzero(@(dpH) dpH_equation(dpH, dnu1), [0.00012345 123450]));

% Now we use the intertemporal budget constraint to solve for dnu1
dnu1_equation = @(dnu1) (dnu1*(1+(fcompute_dpH(dnu1))^((dSigma1-1)/dSigma1)) - fcompute_dpH(dnu1) - (1/2));

% We use fzero to have a value for dnu1 and start the algorithm
dnu1 = fzero(dnu1_equation, [0 1]);

% Now we can compute a value for dpH using our values of nu1
dpH = fcompute_dpH(dnu1);

% We know the consumption levels for each state of nature
dcL = dnu1;
dcH = dnu1 * (dpH^(-(1/dSigma1)));

% Finally, we can compute the utility
dU1 = (dBeta/(1-dBeta))*((1/2)*((dcL)^(1-dSigma1)/(1-dSigma1))+(1/2)*((dcH)^(1-dSigma1)/(1-dSigma1)));
