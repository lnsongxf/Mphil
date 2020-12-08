%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   rouwenhorst.m
%
%   [Pi, P_N, s] = rouwenhorst(r_N, r_p, r_q)
%
%   Purpose:
%       This function computes the probability transition matrix for using
%       the Tauchen's method with an equidistant grid.
%
%   Inputs:
%       r_p        double, first parameter
%       r_q        double, second parameter
%       r_N        double, number of iterations
% 
%   Output:
%       
%       Pi         vector N x 1 of doubles with the stationary distribution
%       P_N        matrix N+1 x N+1 with transition probabilities
%       s          double, probability of success of the stationary distribution
%__________________________________________________________________________

function [Pi, P_N, s] = rouwenhorst(r_N, r_p, r_q)

 P_N  = [r_p, 1-r_p; 1-r_q, r_q];
 
 if r_N > 2
    for N = 3:r_N
        G1  = [P_N zeros( size(P_N,1),1); zeros(1, size(P_N,1)+1)];
        G2  = [zeros( size(P_N,1),1) P_N; zeros(1, size(P_N,1)+1)];
        G3  = [zeros(1, size(P_N,1)+1); P_N zeros(size(P_N,1), 1)];
        G4  = [zeros(1, size(P_N,1)+1); zeros(size(P_N,1), 1) P_N];
        
        P_N = r_p*G1 + (1-r_p)*G2 + (1-r_q)*G3 + r_q*G4;
        
        % Correction in the middle
        P_N = [P_N(1,:); P_N(2:(size(P_N,1)-1),:)/2; P_N(size(P_N,1),:)];
    end
    
    if abs(sum(P_N,2) - repmat([1],size(P_N,1), 1)) < 0.000001
        "Transition matrix complete."
    else
        "ERROR: Check row sums."
    end 
    
    % Building the stationary distribution
    s = (1-r_p)/(2-r_p-r_q);
    Pi = zeros(r_N,1);
    for i=1:r_N
        Pi(i,1) = nchoosek(r_N-1,i-1)*s^(i-1)*(1-s)^(r_N-1);
    end
    
 end

end
