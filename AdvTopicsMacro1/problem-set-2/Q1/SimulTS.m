%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   SimulTS.m
%
%   ts = SimulTS(Z0, P, t, t_burn)
%
%   Purpose:
%       This functions simulate a Markov process from a transition matrix P
%       and an initial value Z0, with t periods and using a burn-in of 
%       t_burn periods.
%
%   Inputs:
%       z0         double, initial state
%       P          matrix nxn of doubles, transition matrix
%       t          double, number of periods
%       t_burn     double, the burn in
% 
%   Output:
%
%       ts         a (t-t_burn) x 1 vector with the bin values.
%__________________________________________________________________________

% TO-DO: we can incorporate inside this function the method to generate P.

function ts = SimulTS(z0, P, t, t_burn)

    ts       = ones(t,1);
    ts(1)    = z0;
    
    sumprob  = cumsum(P, 2); % Cumulative sum over columns, slide 41
    
    ru       = rand(t-1,1);
    
    
    for i = 2:t
        x     = find(ru(i-1) <= sumprob(ts(i-1),:));
        ts(i) = x(1);
    end
    
    ts = ts((t_burn+1):end);
end