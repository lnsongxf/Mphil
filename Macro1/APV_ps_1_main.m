%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       TINBERGEN INSTITUTE
%               PROBLEM SET 1 - MACROECONOMICS I
%                       Block 2 - 2019
%               Prof. Björn Brügemann, TA Jori Kopershock
%   Group members: 
%   Aishameriane V. Schmidt
%   Paloma M. Assunção
%   Maria Valentina Antonaccio Guedes
%   19/11/2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       APV_ps_1_main.m
%
%   Purpose:
%       Solve numerically a model of an exchange economy with stochastic
%       endownments for two consumers with utility function CRRA.
%   
%   Inputs:
%       dSigma1            double, the coefficient of relative risk aversion of
%                          household 1. Must be positive and not equal to one.
%       dSigma2            double, the coefficient of relative risk aversion 
%                          of household 2. Must be positive 
%                          and not equal to one.
%       ini:step:final     double, the range for the coefficient of relative risk aversion of household 2. 
%                          Must be positive and not equal to one. The
%                          program crashes if you use ini<=1 even though
%                          the grid doesn't include 1. Any value 
%                          from 1.15 should be fine.
%       dBeta              double, the coefficient of impatience (or discount) 
%                          of the households. Must be between 0 and 1.
%       iAlt               integer, use 1 to compute the code iterating
%                          over different values of Sigma2 and any other value for iterating
%                          over Sigma1.
%
%   Return Value:
%       dcL1       double, the consumption for household 1 when the state
%                  of nature is L
%       dcH1       double, the consumption for household 1 when the state
%                  of nature is H
%       dpH        double, the price when the state of nature is H
%       dU1        double, the intertemporal utility of household 1 after solving the infinite horizon optimization problem.
%       dpLL       double, the prices in state L given that the previous
%                  state was also L.
%       dpLH       double, the prices in state L given that the previous
%                  state was H.
%       dpHL       double, the prices in state L given that the previous
%                  state was also L.
%       dpHH       double, the prices in state L given that the previous
%                  state was also L.
%       daL1       double, the equilibrium arrow securities purchased 
%                  by household 1 that pay off when the future state is L.
%       daH1       double, the equilibrium arrow securities purchased 
%                  by household 1 that pay off when the future state is L.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Main equations after working analitically in the problem:
%
%   For the prices:
%       dnu2 = 1 - dnu1
%       2    = dpH^(-1/dSigma1)*dnu1 + dpH^(-1/dSigma2)*(1-dnu1)
%
%   Intertemporal budget constraint (interpret dpH as function of dnu1 because it is implicitly defined above)
%       dnu1*(1+dph^((1-dSigma1)/dSigma1) - dpH - 1/2 = 0
%
%   Consumption levels
%       dcL = dnu1
%       dcH = dnu1 * (1/(dpH)^(1/dSigma1))
%
%   Utility function (for household 1)
%       dU1 = (dBeta/(1-dBeta))*((1/2)*((dcL)^(1-dSigma1)/(1-dSigma1))+(1/2)*((dcH)^(1-dSigma1)/(1-dSigma1)))
%
%   Prices for different combinations of nature states:
%       
%       dpLL = dBeta * (1/2)
%       dpLH = dBeta * (1/2) * (1/dpH)
%       dpHL = dBeta * (1/2) * dpH
%       dpHH = dBeta * (1/2)
%
%   Quantities of arrow securities purchased for future states L and H
%   
%       daL1 = dcL - (1/2) 
%       daH1 = dcH - 1 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Magic numbers
dSigma1 = 2;
dSigma2 = 2;
dBeta   = 0.1;

% Change in here if you want to run the code for different values of Sigma1
% given Sigma2 instead different values of Sigma2 for a given Sigma1
iAlt = 1;
   
% Values to iterate over
ini   = 2;
step  = 0.01;
final = 10;

% Creates empty vectors to store results
dcL = zeros(size(ini:step:final,2),1);
dcH = zeros(size(ini:step:final,2),1);
dpH = zeros(size(ini:step:final,2),1);
dU1 = zeros(size(ini:step:final,2),1);
i=1;

% Computes the consumption, prices and utility for household 1
if iAlt == 1
    for dSigma2 = ini:step:final
        [dcL(i) dcH(i) dpH(i) dU1(i)] = APV_ps_1_competitive_equilibrium(dSigma1, dSigma2, dBeta);
        i=i+1;
    end
else 
    for dSigma1 = ini:step:final
        [dcL(i) dcH(i) dpH(i) dU1(i)] = APV_ps_1_competitive_equilibrium(dSigma1, dSigma2, dBeta);
        i=i+1;
    end
end

vdSigma2 = ini:step:final;

% Plot all four variables as a function of dSigma2
figure
subplot(2,2,1)
plot(vdSigma2,dpH,'k')
xtickformat('%.1f')
ytickformat('%.3f')
xticks(ini:1.5:final)
title('Relative prices given z(t)=H')
xlabel('\sigma^2') 
ylabel('p_H/p_L')

subplot(2,2,2)
plot(vdSigma2,dU1, 'b')
xtickformat('%.1f')
ytickformat('%.3f')
xticks(ini:1.5:final)
title('Intertemporal utility for household 1')
xlabel('\sigma^2') 
ylabel('U^1')

subplot(2,2,3)
plot(vdSigma2,dcL, 'r')
xtickformat('%.1f')
ytickformat('%.3f')
xticks(ini:1.5:final)
title('c_L for household 1')
xlabel('\sigma^2') 
ylabel('c_L^1')

subplot(2,2,4)
plot(vdSigma2,dcH, 'g')
xticks(ini:1.5:final)
xtickformat('%.1f')
ytickformat('%.3f')
title('c_H for household 1')
xlabel('\sigma^2') 
ylabel('c_H^1')

fig = gcf;
print(fig,'Fig1','-dpdf')

% Compute the quantities and plot the graphs for question 3

       dpLL = dBeta * (1/2) * ones(size(ini:step:final,2),1);
       dpLH = dBeta * (1/2) * (1./dpH);
       dpHL = dBeta * (1/2) * dpH;
       dpHH = dBeta * (1/2) * ones(size(ini:step:final,2),1);

       daL1 = dcL - (1/2);
       daH1 = dcH - 1; 
       
figure
subplot(3,2,1)
plot(vdSigma2,dpLL,'k')
xtickformat('%.1f')
ytickformat('%.3f')
xticks(ini:1.5:final)
title('p_{L|L}')
xlabel('\sigma^2') 
ylabel('p_{L|L}')

subplot(3,2,2)
plot(vdSigma2,dpLH, 'b')
xtickformat('%.1f')
ytickformat('%.3f')
xticks(ini:1.5:final)
title('p_{L|H}')
xlabel('\sigma^2') 
ylabel('p_{L|H}')

subplot(3,2,3)
plot(vdSigma2,dpHL,'k')
xtickformat('%.1f')
ytickformat('%.3f')
xticks(ini:1.5:final)
title('p_{H|L}')
xlabel('\sigma^2') 
ylabel('p_{H|L}')

subplot(3,2,4)
plot(vdSigma2,dpHH, 'b')
xtickformat('%.1f')
ytickformat('%.3f')
xticks(ini:1.5:final)
title('p_{H|H}')
xlabel('\sigma^2') 
ylabel('p_{H|H}')

subplot(3,2,5)
plot(vdSigma2,daL1, 'r')
xtickformat('%.1f')
ytickformat('%.3f')
xticks(ini:1.5:final)
title('a_{L}^1')
xlabel('\sigma^2') 
ylabel('a_{L}^1')

subplot(3,2,6)
plot(vdSigma2,daH1, 'g')
xticks(ini:1.5:final)
xtickformat('%.1f')
ytickformat('%.3f')
title('a_{H}^1')
xlabel('\sigma^2') 
ylabel('a_{H}^1')

fig = gcf;
print(fig,'Fig2','-dpdf')