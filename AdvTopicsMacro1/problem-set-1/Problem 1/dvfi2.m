%-------------------------------------------------------------------------
%------------------- DISCRETE VALUE FUNCTION ITERATION WITH MONOTONICITY -
%-------------------------------------------------------------------------

function [V0,mK_path] = dvfi2(UMAT,V0,beta,dT,dK0, mKgrid, dn)
    
    mK_path(1,1) = dK0;
    VMAT         = repmat(V0',size(UMAT,1),1);
    a            = 0;

    for i=1:dT
        Index_K        = find(mKgrid==mK_path(i,1));                                               % Find the position of the first capital value
        V              = UMAT(Index_K:dn,Index_K:dn)+beta*VMAT((Index_K-a):dn-a,(Index_K-a):dn-a); % Compute the value function for all possible K'
        V0             = max(V,[],2);                                                              % Find the maximum value in this choice of capital 
                                                                                                   % and stores to use as new starting point in the next iteration
        [Vmax,col]     = max(V(1,:),[],2);                                                         % Takes the maximum value given this K (now in first row) (max over rows)
        mK_path(i+1,1) = mKgrid(col+Index_K-1);                                                    % Stores the value of capital to build the capital path later
        VMAT           = repmat(V0',size(UMAT(Index_K:dn,1),1), 1);                                % Rebuilds the capital grid, now only for the indexes above the current level of capital
        a              = Index_K-1;                                                                % Updates the indexing
    end 
    
    
end