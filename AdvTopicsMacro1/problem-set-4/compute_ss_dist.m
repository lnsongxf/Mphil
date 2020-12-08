%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute_ss_dist.m
% Adapted from here: https://github.com/cassioraa/Doc/blob/master/RCE/compute.py
% This function uses the Q matrix to find the stationary distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Pi_ss = compute_ss_dist(Q)

    n = size(Q,1);
    Pi = ones(1,n)/n;
    
    norm = 1;
    tol  = 1e-2;
    it   = 0;

    while norm > tol
        Pi_ss = dot(Pi, Q); % If we do this long enough, it will end up converging
 		norm = max(abs(Pi_ss(0,:) - Pi(0,:)));
 		Pi = Pi_ss;
    end
end


