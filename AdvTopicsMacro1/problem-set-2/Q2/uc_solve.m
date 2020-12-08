%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   uc_solve.m
%
%   y = uc_solve(k1, k2, dZ1, dBeta, dAlpha, dDelta)
%
%   Purpose:
%       This function solves the problem of policy function iteration
%
%   Inputs:
%       k1          double, 
%       k2          double, 
%       dZ1         double, number of iterations
%       dAlpha      double, the share of the capital in the
%                    production function.
%       dBeta       double, the coefficient of impatience (or discount) 
%                    of the households. Must be between 0 and 1.
%       dDelta      double, the depreciation rate. Must be beteeen 0
%                    and 1 (inclusive).
%
%   Output:
%       
%       y         
%__________________________________________________________________________

function y = uc_solve(k1, k2, dZ1, dBeta, dAlpha, dDelta, P_RH, i_z)
    % based on u(c) = log(c) -> u_c(c)=1/c:
    u     = @(c) log(c);
    u_c   = @(c) 1/c;
    Fk    = @(k) dZ1*k^dAlpha + (1-dDelta)*k;
    F_k   = @(k) dZ1*dAlpha*k^(dAlpha-1) + (1-dDelta);
    Ez    = @(i_z, P_RH, x) P_RH(i_z)*x;
    y     = u_c(dBeta*Ez(i_z, P_RH, 1+F_k(k2))*u_c(Fk(k1)-k2));    
end
