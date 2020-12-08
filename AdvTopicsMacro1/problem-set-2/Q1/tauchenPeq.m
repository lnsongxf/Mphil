%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   tauchenPeq.m
%
%   Y = tauchenPeq(Gridp, p, n, d)
%
%   Purpose:
%       This function computes the probability transition matrix for using
%       the Tauchen's method with an equidistant grid.
%
%   Inputs:
%       Gridp      vector nx1 of doubles, an equally spaced grid in whith
%                  points will be interpolated
%       p          structure with parameters
%       n          double, number of grid points
%       d          double, the size of each bin
% 
%   Output:
%
%       P          matrix nxn of doubles with transition probabilities.
%                  each row needs to sum up to 1
%__________________________________________________________________________



function Y=tauchenPeq(Gridp, p, n, d)

    P = zeros(n,n);
    for i=1:n
        j=1; 
            P(i,j) = normcdf((Gridp(j,1)+d/2-p.rho_z*Gridp(i,1))/p.beta_eps);
        j=n; 
            P(i,j) = 1- normcdf((Gridp(j,1)-d/2-p.rho_z*Gridp(i,1))/p.beta_eps);
        for j=2:n-1
            P(i,j) = normcdf((Gridp(j,1)+d/2-p.rho_z*Gridp(i,1))/p.beta_eps) - normcdf((Gridp(j,1)-d/2-p.rho_z*Gridp(i,1))/p.beta_eps);
        end
    end
    
    % check if row-sum = 1
    if abs(sum(P,2) - repmat([1],size(P,1), 1)) < 0.000001
        "Transition matrix complete."
    else
        "ERROR: Check row sums."
    end 
    Y = P;
end 
