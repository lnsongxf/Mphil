%--------------------------------------------------------------------------
%------------------- ITERATION --------------------------------------------
%--------------------------------------------------------------------------

function [Tv, ig, dc] = iteration_value_function(eps, mKgrid, Gridp_RHy, dAlpha, dBeta, vz, P_RH)

    %global mV mVn ig
    mV  = zeros(size(mKgrid, 1), size(Gridp_RHy,1));
    mVn = {mV};
    it   = 0;
    not_converged=1;
    tol_it = 500;
    
    while not_converged & it < tol_it
        % Build the objective function
        [VMAT,dc] = build_objective(mV, mKgrid, Gridp_RHy, dAlpha, dBeta, vz, P_RH);

        % Maximization
        [Tv, Tgi] = applyBellman(VMAT, mKgrid, Gridp_RHy);

        % Iteration
        mVn{end+1} = Tv;

        criterion = max(abs(mV-Tv));
        
        if (criterion<eps)
            not_converged=0;
        end

        mV = Tv;
        ig = Tgi;
        it = it + 1;
        %fprintf('Iteration %d ended with convergence criterion %f \n', it, criterion) % This is not quite right
    end
end