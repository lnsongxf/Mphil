%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  TINBERGEN INSTITUTE
%  PROBLEM SET 3 - ADVANCED TOPICS IN MACRO I - QUESTION 2
%                    Block 2 - 2020
%   Instructors: dr. E. Proehl (UvA) and dr. M. Pedroni (UvA)
%   Group members: 
%   Aishameriane V. Schmidt
%   Antonia Kurz
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 1. Draw 200 eps from  N(0,1)
% 2. Simulate z_{t+1} &= rho*z_{t} + sigma*eps_{t+1} with z0=0
% 3. Use policy functions k'(k) to get path for k, via the
%   a) analytical solution
%   b) log-lin solution
%   c) solution provided by Dynare
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;

%% MAGIC NUMBERS
alpha = 0.33; 
beta  = 0.99;
sigma = 0.01;
rho   = 0.95;
k_ss  = (beta*alpha)^(1/(1-alpha));
c_ss  = (beta*alpha)^(alpha/(1-alpha)) - k_ss;
t     = 200;
z0    = 0;
k0    = k_ss;
seed  = 356;
rng(seed);

%% 1+2: Path for z

% Draw 200 eps from  N(0,1):
z(1,1) = z0;
for i=1:t
 z(i+1,1) = rho*z(i,1)+ sigma*normrnd(0,1);
end

%% 3a: Path for k with the analytical solution
Xa(:,1) = [c_ss ; k0];

% Policy Fct:
for i=1:t
    Xa(1,i)   = (1-alpha*beta) * exp(z(i,1)) * Xa(2,i)^alpha; % consumption
    Xa(2,i+1) = alpha*beta * exp(z(i,1)) * Xa(2,i)^alpha;     % capital
end

%% 3b: Path for k with the log-lin solution of undetermined coeff
Xb(:,1) = [c_ss ; k0]; % in levels
Yb(:,1) = [0;0];       % in SS deviations

% Eigenvalues
% This small piece of code computes the Eigenvalues of our H matrix
% to verify if the system is stable
a = c_ss*(1-alpha)/k_ss + 1;
b = -(1-alpha)*alpha*k_ss^(alpha-1);
c = -c_ss/k_ss;
d = alpha*k_ss^(alpha-1);
H = [a b ;c d];
[v,d] = eig(H);
G = [-(1-alpha)*k_ss^(alpha-1) + rho ; k_ss^(alpha-1)];

% Policy Fct:
for i=1:t
    Yb(:,i+1) = H*Yb(:,i) + G*z(i,1); % SS deviations get shocked
    Xb(1,i+1) = c_ss*exp(Yb(1,i+1));
    Xb(2,i+1) = k_ss*exp(Yb(2,i+1));
end

%% 3c: Path for k with the solution of Dynare
%POLICY AND TRANSITION FUNCTIONS
%                                 c               k               z
% k(-1)                       0.330000        0.330000               0
% z(-1)                       0.950000        0.950000        0.950000
% eps                         0.010000        0.010000        0.010000

Xc(:,1) = [c_ss ; k0];
Yc(:,1) = [0;0];       % in SS deviations

% Policy Fct:
for i=1:t
    Yc(:,i+1) = [0, 0.33; 0, 0.33]*Yc(:,i) + [0.95; 0.95]*z(i,1);
    Xc(1,i+1) = c_ss*exp(Yc(1,i+1));
    Xc(2,i+1) = k_ss*exp(Yc(2,i+1));
end


%% EULER Equation Errors
u_c = @(x) 1/x; % here: is equal to u_c^{-1}
f_k = @(k,z) alpha* exp(z) * k^(alpha-1);

for i=1:t-1
        EEE(1,i) = log10(abs(1- (u_c(beta*(1+f_k(Xa(2,i+1),z(i+1,1)))*u_c(Xa(1,i+1)))/Xa(1,i))));
        EEE(2,i) = log10(abs(1- (u_c(beta*(1+f_k(Xb(2,i+1),z(i+1,1)))*u_c(Xb(1,i+1)))/Xb(1,i))));
        EEE(3,i) = log10(abs(1- (u_c(beta*(1+f_k(Xc(2,i+1),z(i+1,1)))*u_c(Xc(1,i+1)))/Xc(1,i))));
end 

%% PLOTS

figure(1);
% Z
subplot(3,1,1);
plot(z(:,1), 'r');
xlabel('t');
ylabel('z');


% K
subplot(3,1,2);
plot(Xa(2,:), 'r');
hold on

plot(Xb(2,:), 'b');
xlabel('t');
ylabel('k');
hold on

plot(Xc(2,:),'g--');
legend('Analytical','Log-Lin','Dynare');
hold off


% EEE
subplot(3,1,3);
plot(EEE(1,:), 'r');
hold on

plot(EEE(2,:), 'b');
xlabel('t');
ylabel('EEE(k)');
hold on

plot(Xc(2,:), 'g');
legend('Analytical','Log-Lin','Dynare');
hold off
