% Problems:
% - a goes below a-low (borrowing limit)
% - which is okay for now; but c then also gets negative values and the
%   distance measure cant't be calculated to find the policy function
% SUGGESTION: you can take the maximum between a'(a,y) and a0 to compute
% the consumption. Check the code for Q1.


function [residual,at,r] = stationary_equilibrium(r0,crit,I,T,Amat,Ymat,alpha,b,delta,Gamma,A0,C0,H, mAgrid, mYgrid)
% this function
% (1) solves for the consumption decision rule, given an
% intereste rate, r0
% (2) simulates the stationary equilibrium associated with the interest
% rate, r0
% (3) (i) returns the residual between the given interes rate r0 and the one
% implied by the stationary aggregate capital and labor supply.
% (ii) returns as an optional output the wealth distribution.
% based on Andreas M�ller code: https://sites.google.com/site/mrandreasmueller/resources

% get dimensions of the grid
[M,N] = size(Amat);

% get productivity realizations from the first row
%y1 = Ymat(1,1);
%y2 = Ymat(1,2);

% compute the wage according to marginal pricing and a Cobb-Douglas 
% production function
w0 = (1-alpha)*(alpha/(r0+delta))^(alpha/(1-alpha));

% initial guess on future consumption (consume asset income plus labor
% income from working h=1.
cp0 = r0*Amat+Ymat*w0;

%%% iterate on the consumption decision rule

% distance between two successive functions
% start with a distance above the convergence criterion
dist    = crit+1;
% maximum iterations (avoids infinite loops)
maxiter = 10^(3);
% counter
iter    = 1;

fprintf('Inner loop, running... \n');
    
while (dist>crit&&iter<maxiter)

% derive current consumption
c0 = C0(cp0,r0);

% derive current assets
a0 = A0(Amat,Ymat,c0,r0,w0);

%%% update the guess for the consumption decision

% consumption decision rule for a binding borrowing constraint
% can be solved as a quadratic equation
% c^(2)-((1+r)a+b)c-(yw)^(1+2/3) = 0
% general formula and notation: ax^(2)+bx+c = 0
% x = (-b+sqrt(b^2-4ac))/2a
%       (used here) cpbind = ((1+r0)*Amat+b)/2+sqrt(((1+r0)*Amat+b).^(2)+4*(Ymat*w0).^(1+varphi))/2;
% % slow alternative: rootfinding gives the same result
cpbind  = zeros(M,N);
options = optimset('Display','off');
for j=1:N
      cpbind(:,j) = fsolve(@(c) (1+r0)*Amat(:,j)+mYgrid(j)*w0-c+b,cp0(:,j),options);
end 
% cpbind = (1+r0)*Amat-b + Ymat*w0;

% consumption for nonbinding borrowing constraint
cpnon = zeros(M,N);
% interpolation conditional on productivity realization
% instead of extrapolation use the highest value in a0
for j=1:N
    cpnon(:,j)  = interp1(a0(:,j),c0(:,j),Amat(:,j),'spline');
end

% merge the two, separate grid points that induce a binding borrowing constraint
% for the future asset level (the first observation of the endogenous current asset grid is the 
% threshold where the borrowing constraint starts binding, for all lower values it will also bind
% as the future asset holdings are monotonically increasing in the current
% asset holdings).
for j=1:N
    cpnext(:,j) = (Amat(:,j)>a0(1,j)).*cpnon(:,j)+(Amat(:,j)<=a0(1,j)).*cpbind(:,j);
end
% cpnext(:,2) = (Amat(:,2)>a0(1,2)).*cpnon(:,2)+(Amat(:,2)<=a0(1,2)).*cpbind(:,2);

% distance measure
dist = norm((cpnext-cp0)./cp0);

% display every 100th iteration
if mod(iter,100) == 1
    fprintf('Inner loop, iteration: %3i, Norm: %2.6f \n',[iter,dist]);
end

% increase counter
iter = iter+1;

% update the guess on the consumption function
cp0 = cpnext;

end

fprintf('Inner loop, done. \n');

fprintf('Starting simulation... \n');

%%% simulate the stationary wealth distribution

% initialize variables
at      = zeros(I,T+1);
yt      = zeros(I,T);
IndexY  = zeros(I,T);
ct      = zeros(I,T);
ht      = zeros(I,T);

at(:,1) = 1;            % initial asset level

sumprob  = cumsum(Gamma, 2); % Cumulative sum over columns for transition matrix

for t=1:T
   % draw uniform random numbers across individuals
   s = unifrnd(0,1,I,1); % Ix1
   summ = zeros(I,1);
   if t>1   % persistence for t>1
       for l=1:I
            % yt(:,t) = summ + ((s<=rho)&(yt(:,t-1)==y1)).*y1+((s>rho)&(yt(:,t-1)==y2)).*y1+((s<=rho)&(yt(:,t-1)==y2)).*y2+((s>rho)&(yt(:,t-1)==y1)).*y2;
            x     = find(s(l,1) <= sumprob(IndexY(l,t-1),:)); % Ix1
            IndexY(l,t) = x(1);   
            yt(l,t) = mYgrid(IndexY(l,t));
       end
   else     % allocation in t=0: 
       yt(:,t) = repmat(mean(mYgrid),I,1);
       IndexY(:,t)= 4; % change according to grid points!
   end

   % consumption
   summ = zeros(1); 
   for j= 1:N
   % ct(:,t)   = (yt(:,t)==y1).*interp1(Amat(:,1),cp0(:,1),at(:,t),'spline')+(yt(:,t)==y2).*interp1(Amat(:,2),cp0(:,2),at(:,t),'spline');
      summ  = summ + (yt(:,t)==Ymat(1,j)).*interp1(Amat(:,j),cp0(:,j),at(:,t),'spline');
   end 
   ct(:,t) = summ;
   
   % labor supply
   ht(:,t)   = 1;

   % future assets
   at(:,t+1) = (1+r0)*at(:,t)+ht(:,t).*yt(:,t).*w0-ct(:,t); 

end

fprintf('simulation done... \n');

% compute aggregates from market clearing
K = mean(mean(at(:,T-100:T)));
L = mean(mean(yt(:,T-100:T).*ht(:,T-100:T)));
r = alpha*(K/L)^(alpha-1)-delta;

% compute the distance between the two
residual = (r-r0)/r0;

end

