
% this code brings together main_Q1 (endogeneous grid) and the invariant
% distribution estimation in main_Q1b to estimate with the actual policy
% function

% unfortunately, due to time constaints, we couldn't finish the inverse of
% the policy function on time such that we couldn't run the piecewise
% approximation with the actual policy function.



clear all;
%% MAGIC NUMBERS

% For the model
dEps        = 0.0001;
dna         = 1001;      % grid precision for assets
alow        = 0;        % borrowing limit
ahigh       = 100;       % lending limit, needs to adjusted!

% CRRA Utility
dSigma      = 2;        % risk aversion
dBeta       = 0.95;     % discount rate

% Cobb Douglas Production
dAlpha      = 0.33;     % capital share
dDelta      = 0.1;      % depreciation
r0          = 0.04;     % starting interest rate
dR          = 1+r0;     % gross interest rate
w0           = 1;        % starting wage

% For the Markovian process of y
p.rho_y     = 0.9;      
p.mu_eps    = 0;        
p.sigma_eps = 0.1;       
t_burn      = 500;
seed        = 6969;
dny         = 7;

%% INITIALIZATION

% Policy Function for a':
% g_a = @(a_k, y_j) dR*a_k + y_j;

% Markov
rng(seed);
%t          = dn + t_burn;
p.mu_y     = p.mu_eps;
p.beta_eps = p.sigma_eps/(1-p.rho_y^2);
p.se_y     = p.beta_eps^0.5;
r_p        = (1+p.rho_y)/2;
r_q        = r_p;
r_psi      = p.se_y*sqrt(dny-1);
fz         = @(y) exp(y);

%----- EVENLY SPACED GRID for assets -----%
mAgrid = linspace(alow,ahigh,dna)';

%% Rouwenhorst's Method to produce the transition matrix and the exogenous process
[Pi, P_RH, s] = rouwenhorst(dny, r_p, r_q);
Gamma = P_RH;
% Cumulative (not here)
% for i=1:dny
%     for j = 2:dny
%         Gamma(i,j) = Gamma(i,j-1) + P_RH(i,j);
%     end
% end
    
% Assemble the grid: 
% N-state Markov chain characterized by a symmetric and evenly-spaced state space
Gridp_RH  = linspace(-r_psi,r_psi,dny)';
Gridp_RH  = Gridp_RH + p.mu_y;  % shift according to mu
mYgrid = fz(Gridp_RH)';

% get eigenvector:
[V,D,W]   = eig(Gamma);
% Check in which D==1.000, eigenvalue 1
gamma     = -W(:,1);        % impose positive values


% Get z values:
vz = fz(Gridp_RH);
mz = repmat(vz,1,dna);

%% ENDOGENOUS GRID METHOD TO FIND POLICY FUNCTION

% Based heavily on http://www.personal.ceu.hu/departs/personal/Katrin_Rabitsch/ConsSav_PolicyIterationEndogGrid.m

% set up asset grid
gridA  = linspace(-alow,ahigh,dna)' ;

n   = ones(1,length(mYgrid));
nn  = ones(dna,1);

ini_a      = gridA*n;                     % starting values for policy fct. guess for a''(a',y')
current_a  = gridA*n;                     % initialize vector for a grid

it            = 0;
not_converged = 1;
tol_it        = 500;

% start main loop that iterates over the policy function, until fixed point is reached
while not_converged & it < tol_it
        
        old_a = current_a;
        
        % Calculate the conditional expectation of Euler equations as a functions of a'
        CE_EE=zeros(dna,dny);
        for iy = 1:dny                   % iterate over current productivity
            for ia_prime = 1:dna % iterate over asset positions 
                for iy_prime = 1:dny    % iterate over future productivity
                    % consumption is computed automatically in a way that takes care of the borrowing constraint (by taking the maximum)
                    cp  = mYgrid(1,iy_prime) + dR*gridA(ia_prime,1) - max(-alow,ini_a(ia_prime,iy_prime)); % see https://alisdairmckay.com/Notes/HetAgents/EGM.html to know where this came from
                    CE_EE(ia_prime,iy)  = CE_EE(ia_prime,iy)  + dBeta*P_RH(iy,iy_prime)*cp.^(-dSigma);
                end
            end
        end
        % We leave this triple loop with the conditional expectation of the
        % Euler equation at each gridpoint for a'
        
        % Now we can "reverse-engineer" to find a
        for iy = 1:dny
            for ia=1:dna
                c = (dR * CE_EE(ia,iy) )^(-1/dSigma);                                  % consumption at gridpoint (a',y')
                current_a(ia,iy) =  ( c - mYgrid(1,iy) + current_a(ia,1) ) / dR;   % implied value of a at gridpoint (a',y') and under current policy fct guess app(a',y')
            end
        end       
        
        % update policy function
        for iy = 1:dny
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

cp=zeros(dna,dny);
for iy_prime=1:dny
   cp(:,iy_prime)  = nn*mYgrid(1,iy_prime) + dR *gridA(:,1) - max(-alow,ini_a(:,iy_prime));
end


% Policy Function for a': ini_a
% use index = round(policy(i_a, i_y),1)*10+1;
% index = round(ini_a(i_a, i_y),1)*10+1
g_a = @(a_k, y_j) ini_a(round(a_k,1)*10+1,find(mYgrid==y_j));

%% 
% 1. choose Lambalow over grid AxY: 
%    Lambalow, stored in first third dimension of Lambda:
%    matrix with a in rows, y in columns, version v in third dimension: na x ny matrix, v times
% Lambda(:,:,1) = ((mAgrid-alow)/(ahigh-alow))*Pi.';
% why gamma and not pi (stationary distribution of y)?
 Lambda(:,:,1) = ((mAgrid-alow)/(ahigh-alow))*gamma.';

% 2/3. get inverse of policy function: g^(-1) as function (inverse of a'):
%       nonlinear solver for a such that a(k) = a'(a,y(i)) 
%       (for every i, that means it needs to be put inside this loop below!)
%       Linearly interpolate for a until a(k) = a'(a,y(i)) with Lambda(k,j,v):
%       http://paulklein.se/newsite/teaching/Notes_InvariantDist.pdf

% for now, use 
% Inverse of Policy function example:
% ginv_a = @(a_k, y_j) (a_k-y_j)/dR;

apol = @(a_p, a_k, y_j) ini_a(round(a_k,1)*10+1,find(mYgrid==y_j))-a_p;
myfun = @(a_k) apol(a_p, a_k, y_j);
ginv_a = fzero(myfun,a_p) % solve for a_k given a_p and y_j

% 2/3. update distribution on grid points, Lambda1: 
% 4.   set v=2; put the 2/3 loop in:
%         
v=1;     
not_converged=1;
while not_converged
v = v+1
    % Lambda(:,:,v) - Lambda(:,:,v-1) > (here we need a difference condition):
for k = 1:dna
    for j = 1:dny
    summ=zeros(1);  
        for i=1:dny
            gin = ginv_a(mAgrid(k), mYgrid(i));
            In_A = sum(mAgrid<gin)+1;       % index where a is below
            if In_A < dna+1
                if In_A == 1
                    Interpol = Lambda(In_A,i,v-1);
                else
                Interpol = Lambda(In_A-1,i,v-1) + (Lambda(In_A,i,v-1) - Lambda(In_A-1,i,v-1))/(mAgrid(In_A)-mAgrid(In_A-1))*(gin-mAgrid(In_A-1));
                end 
            end
            if In_A == dna+1
                Interpol = Lambda(In_A-1,i,v-1);
            end
            summ(1) = summ(1) + Gamma(i,j)* Interpol;
        end
    Lambda(k,j,v) = summ(1);
    end 
end 
criterion=max(abs(Lambda(:,:,v) - Lambda(:,:,v-1)));
if (criterion<dEps)
        not_converged=0;
end
end 

% 5. get aggregate supply of assets:
%    (given that alow is the first row of a, so alow=a(1)
A = 0;
for i = 1:dny
	for k =1:dna-1
        A = A + (Lambda(k+1,i,v) - Lambda(k,i,v))*((mAgrid(k+1)+mAgrid(k))/2) + Lambda(1,i,v)*alow;
    end
end 
A %=

% aggregate labour supply
L = 0;
for i = 1:dny-1
	for k =1:dna
        L = L + (Lambda(k,i+1,v) - Lambda(k,i,v))*((mYgrid(i+1)+mYgrid(i))/2) + Lambda(k,1,v)*mYgrid(1);
    end
end 
L 


%% Equilibrium wage:
w =(1-dAlpha)*(((dAlpha)/r0)^(1/(1-dAlpha)))^(dAlpha);
% larger than w=1
% myfun = @(r) (1-dAlpha)*(((dAlpha)/r)^(1/(1-dAlpha)))^(dAlpha)-w0;
% r = fzero(myfun,r0)


% 
% %% RESULTS
% %--------------------------------- PLOTS ----------------------------------
% %Plot of the value function and corresponding EEK
% figure(1);
% plot(mKgrid, Tv(:,1), 'r');
% xlabel('K');
% ylabel('V(K)');
% hold on
% 
% plot(mKgrid, Tv(:,2), 'g');
% hold on
% 
% plot(mKgrid, Tv(:,3), 'b');
% legend('z=0.1380','z=1','z=7.2449');
% hold off
% 
% figure(2);
% plot(mKgrid, pi_K(:,1), 'r');
% ylabel('K´(K)');
% xlabel('K');
% 
% hold on
% 
% plot(mKgrid, pi_K(:,2), 'g');
% hold on
% 
% plot(mKgrid, pi_K(:,3), 'b');
% legend('z=0.1380','z=1','z=7.2449');
% hold off
% 
% figure(3);
% plot(mKgrid, EEE(:,1), 'r');
% ylabel('EEE(K)');
% xlabel('K');
% 
% hold on
% 
% plot(mKgrid, EEE(:,2), 'g');
% hold on
% 
% plot(mKgrid, EEE(:,3), 'b');
% legend('z=0.1380','z=1','z=7.2449');
% hold off
% 
% 
% figure(4);
% plot(mKgrid, mPath_K(:,1), 'r');
% xlabel('K');
% ylabel('\pi(K)');
% hold on
% 
% plot(mKgrid, mPath_K(:,2), 'g');
% hold on
% 
% plot(mKgrid, mPath_K(:,3), 'b');
% legend('z=0.1380','z=1','z=7.2449');
% hold off
