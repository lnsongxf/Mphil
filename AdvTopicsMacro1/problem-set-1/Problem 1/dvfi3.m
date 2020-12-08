%-------------------------------------------------------------------------
%------------------- DISCRETE VALUE FUNCTION ITERATION WITH CONCAVITY    -
%-------------------------------------------------------------------------

function [V0,mK_path] = dvfi3(UMAT,V0,beta,dT,dK0, mKgrid)
 
    mK_path(1,1)=dK0;
    VMAT=repmat(V0',size(UMAT,1),1);
    a = 0;

    for i=1:dT
        Index_K = find(mKgrid==mK_path(i,1)); % Find the position of the first capital value
        j       =1;
        
        % While value function (given K) at K' <= value fct for K'(+1), check
        % next K', after: set mK_path(i+1,1) = mKgrid(j);
        while UMAT(Index_K,j)+beta*VMAT(Index_K,j)<UMAT(Index_K,j+1)+beta*VMAT(Index_K,j+1);
            j=j+1;
        end
        
        mK_path(i+1,1) = mKgrid(j);                  % Stores the value of capital to build the capital path later
        V0             = UMAT(:,j)+beta*VMAT(:,j);   % Update value function for next iteration
        VMAT           = repmat(V0',size(UMAT,1), 1);% Rebuilds the capital grid, now only for the indexes above the current level of capital
    end 


end
