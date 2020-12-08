%--------------------------------------------------------------------------
%------------------- BUILD OBJECTIVE FUNCTION -----------------------------
%--------------------------------------------------------------------------

function [VMAT,dc] = build_objective(mV, mKgrid, Gridp_RHy, dAlpha, dBeta, vz, P_RH)

    VMAT = zeros(size(mKgrid, 1), size(mKgrid, 1), size(Gridp_RHy,1));
    dc = VMAT;
    
    for i_z = 1:size(Gridp_RHy,1)
        for i_k = 1:size(mKgrid,1)
            for i_kk = 1:size(mKgrid,1)
                dc(i_k, i_kk, i_z) = Gridp_RHy(i_z)*mKgrid(i_k,1)^dAlpha - mKgrid(i_kk,1);
                if dc(i_k, i_kk, i_z) >=0
                    Ev = dot(P_RH(i_z,:),mV(i_kk,:));
                    VMAT(i_k, i_kk, i_z) = log(dc(i_k, i_kk, i_z)) + dBeta*Ev;
                else
                    VMAT(i_k, i_kk, i_z) = -Inf; % this avoids having impossible levels of consumption
                end
            end
        end    
    end 
    
end