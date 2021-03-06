function [du] = BurgersFLrhs1D(x,u,h,k,maxvel)
% function [du] = BurgersFLrhs1D(x,u,h,k,maxvel);
% Purpose: Evaluate right hand side for Burgers equation using a
% flux limited scheme
N = length(x);

% Chose flux limiter - 0:LF; 1:CO; 2:Koren; 3:Sweby; 4:OSPRE; 5:van Leer 
type = 5; beta=2; 

% Boundary conditions
[xe,ue] = extend(x,u,h,1,'P',0,'P',0); % Periodic boundary conditions
%[xe,ue] = extend(x,u,h,1,'D',2,'N',0); % Constant boundary conditions

% Compute indicator function and define flux limiter
r = (ue(2:N+1) - ue(1:N))./(ue(3:N+2)-ue(2:N+1));
[xe,re] = extend(x,r,h,1,'N',0,'N',0); rm = 1./re;
phiLp = FluxLimit(re(1:N),type,beta); 
phiRp = FluxLimit(re(2:N+1),type,beta);
phiLm = FluxLimit(rm(2:N+1),type,beta); 
phiRm = FluxLimit(rm(3:N+2),type,beta);

ufilt = (u>=0); 
phiL = ufilt.*phiLp + (1-ufilt).*phiLm; 
phiR = ufilt.*phiRp + (1-ufilt).*phiRm;

% Compute left flux - Change numerical flux here
Fluxlow = BurgersLF(ue(1:N),ue(2:N+1),0,maxvel); 
Fluxhigh = BurgersLW(ue(1:N),ue(2:N+1),k/h,maxvel); 
FluxL = Fluxlow + phiL.*(Fluxhigh - Fluxlow);

% Compute right flux - Change numerical flux here
Fluxlow = BurgersLF(ue(2:N+1),ue(3:N+2),0,maxvel); 
Fluxhigh = BurgersLW(ue(2:N+1),ue(3:N+2),k/h,maxvel); 
FluxR = Fluxlow + phiR.*(Fluxhigh - Fluxlow);

% Compute RHS 
du = -(FluxR - FluxL)/h;
return