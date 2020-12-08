%--------------------------------------------------------------------------
%------------------- APPLY BELLMAN OPERATOR -------------------------------
%--------------------------------------------------------------------------

function [Tv, Tg] = applyBellman(VMAT, mKgrid, Gridp_RHy)

    Tv = zeros(size(mKgrid, 1), size(Gridp_RHy,1));
    Tg = zeros(size(mKgrid, 1), size(Gridp_RHy,1));

    for i_z = 1:size(Gridp_RHy,1)
        for i_k = 1:size(mKgrid, 1)
            [Tv(i_k, i_z), Tg(i_k, i_z)] = max(VMAT(i_k,:,i_z)); % Verify in which column is the maximum of a given row
        end
    end

end