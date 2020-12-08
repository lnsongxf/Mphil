function y = uc_solve(k1, k2, mKgrid, dZ1, dBeta, dAlpha, dDelta)
% based on u(c) = log(c) -> u_c(c)=1/c:
u_c = @(c) 1/c;
Fk = @(k) dZ1*k^dAlpha + (1-dDelta)*k;
F_k = @(k) dZ1*dAlpha*k^(dAlpha-1) + (1-dDelta);
myfun = @(x, k1, k2) u_c(Fk(k1)-k2) - dBeta*F_k(k2)*u_c(Fk(k2)-x); 
fun = @(x) myfun(x, k1, k2); 
y = fzero(fun,k1)
end

% Fk(k2)-x = dBeta*F_k(k2)* (Fk(k1)-k2);
% 
% x = Fk(k2) - dBeta*F_k(k2)* (Fk(k1)-k2)