%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute_Q.m
% Adapted from here: https://github.com/cassioraa/Doc/blob/master/RCE/compute.py
% This function uses the policy function for
% a with the transition matrix to give back
% the matrix Q (slide 7, lecture 4)
% This is not actually working: the condition i_aa == policy(i_a, i_y) is
% never met (which is obvious). I think we probably would need some
% interpolation to have a match between i_aa and the policy grid, but I am
% too sleepy to be able to fix this.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Q = compute_Q(policy, PI)

    %policy = ini_a;
    %PI = P_RH;

    [n_a, n_y] = size(policy);

    Q = zeros(n_a*n_y, n_a*n_y);

    for i_y = 1:n_y-1
        for i_a = 1:n_a-1
           current_state = i_y*n_a + i_a;
           for i_yy = 1:n_y-1
              for i_aa = 1:n_a-1
                next_state = i_yy*n_a + i_aa;
                index = round(policy(i_a, i_y),1)*10+1;
                if (i_aa == index)
                    Q(current_state, next_state) = Q(current_state, next_state) + PI(i_y, i_yy);
                end
           end      
        end
    end

end

