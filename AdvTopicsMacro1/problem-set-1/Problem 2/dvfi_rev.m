%--------------------------------------------------------------------------
%------------------- Reverse DISCRETE VALUE FUNCTION ITERATION ------------
%--------------------------------------------------------------------------
% This is based on dvfi.m 
% Obs.: The following function is given in problem set solution from 2014, 
% which was provided by the professor.
% The outputs are: value function V and policy function indeces pi_I. These
% indices are to the optimal policy pi.

function [V_argmax,pi] = dvfi(UMAT,V0,beta,eps)

not_converged=1;
while not_converged
    VMAT=repmat(V0',size(UMAT,1),1);
    [V,pi]=max(UMAT+beta*VMAT,[],2);
    % use index pi where maximum is to find the maximising VMAT (argmax)
    V_argmax = VMAT*pi;
    criterion=max(abs(V-V0));
    V0=V;
    if (criterion<eps)
        not_converged=0;
    end
end

end