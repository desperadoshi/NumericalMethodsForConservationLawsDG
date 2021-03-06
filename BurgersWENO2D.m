function [u] = BurgersWENO2D(x,y,u,hx,hy,m,CFL,FinalTime);
% function [u] = BurgersWENO2D(x,y,u,hx,hy,m,CFL,FinalTime);
% Purpose  : Integrate 2D Burgers equation until FinalTime 
%             using a WENO scheme.

time = 0; tstep = 0;

% Initialize reconstruction weights
Crec = zeros(m+1,m);
for r=-1:m-1;
    Crec(r+2,:) = ReconstructWeights(m,r);
end;

% Initialize linear weights
dw = LinearWeights(m,0);

% Compute smoothness indicator matrices
beta = zeros(m,m,m);
for r=0:m-1
    xl = -1/2 + [-r:1:m-r];
    beta(:,:,r+1) = betarcalc(xl,m);
end

% integrate scheme
while (time<FinalTime)
   % Decide on timestep
   maxvel = max(max(2*sqrt(2.0)*abs(u))); k = CFL*min(hx,hy)/maxvel/2;
   if (time+k>FinalTime) k = FinalTime-time; end
  
   % Update solution
   rhsu  = BurgersWENOrhs2D(x,y,u,hx,hy,k,m,Crec,dw,beta,maxvel); 
   u1 = u + k*rhsu;
   rhsu  = BurgersWENOrhs2D(x,y,u1,hx,hy,k,m,Crec,dw,beta,maxvel); 
   u2 = (3*u + u1 + k*rhsu)/4;
   rhsu  = BurgersWENOrhs2D(x,y,u2,hx,hy,k,m,Crec,dw,beta,maxvel); 
   u = (u + 2*u2 + 2*k*rhsu)/3;
   time = time+k; tstep = tstep+1;
end
return
