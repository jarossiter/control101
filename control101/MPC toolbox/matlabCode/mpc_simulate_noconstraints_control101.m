%%%  Computes and simulates a GPC control law
%%%  Assumes no advance knowledge of target is used
%%%
%%%%%  [y,u,Du,r] = mpc_simulate(B,A,Bp,Ap,nu,ny,Wu,Wy,ref,dist,noise)
%              y, u, Du, r are dimensionally compatible 
% closed-loop outputs/inputs/input increments and supplied set-point and disturbance
%
% MFD model     Ay(k) = Bu(k-1) + dist  [Real system is Ap,Bp]
%
% ny is output horizon
% nu is the input horizon
% Wu is the diagonal control weighting 
% Wy is the diagonal output weighting
% sizey no. outputs and inputs (assumed square)
% dist,noise are the disturbance and noise signals
% ref is the reference signal
% Dumax is a vector of limits on input increments (assumed symetric)
% umax, umin are vectors of limits on the inputs
%
% [y,u,Du,r,d] = mpc_simulate_limited_control101(B,A,Bp,Ap,nu,ny,Wu,Wy,ref,dist,noise)
%%  
%% Author: J.A. Rossiter  (email: J.A.Rossiter@shef.ac.uk)

function [y,u,Du,r,init] = mpc_simulate_limited_control101(B,A,Bp,Ap,nu,ny,Wu,Wy,ref,dist,noise)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Error checks
sizey = size(A,1);
if size(B,2)==sizey;
    B=[B,zeros(sizey,sizey)];
    Bp=[Bp,zeros(sizey,sizey)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%   Find prediction matrices 
%%%%    yfut = H *Dufut + P*Dupast + Q*ypast
[H,P,Q] = mpc_predmat_toeplitz_control101(A,B,ny);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%   Find control law and parameters of the cost function
%%%%   Dufut = Pr*rfut - Dk*Dupast - Nk*ypast 
[Nk,Dk,Pr] = mpc_law_control101(H,P,Q,nu,Wu,Wy,sizey);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Set up simulation parameters
nNk = size(Nk,2)/sizey;
nDk = size(Dk,2)/sizey;
init = max([nNk,nDk])+2;
y = zeros(sizey,init);
u = y;
Du = u;
r = u;
d=u;
runtime = size(ref,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Closed-loop simulation
for i=init:runtime-1;

%%% Update vectors needed for the control law
d(1:sizey,i+1)=dist(:,i+1);
ypast = y(:, i:-1:i+1-nNk)+noise(:, i:-1:i+1-nNk);
Dupast = Du(:, i-1:-1:i-nDk) ;
upast = u(:, i-1);
rfut = ref(:,i+1); 

%%%%%%% Unconstrained law 
Dufast = Pr*rfut - Nk*ypast(:) - Dk*Dupast(:);
Du(:,i) = Dufast(1:sizey);
u(:,i)=u(:,i-1)+Du(:,i);

%%% Simulate the process
upast2 = u(:,i:-1:i-nDk);
ypast2 = y(:, i:-1:i+2-nNk);
y(:,i+1) = -Ap(:,sizey+1:nNk*sizey)*ypast2(:) + Bp*[upast2(:)] + d(:,i+1);
r(:,i+1) = ref(:,i+1);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%  Produce a neat plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% Ensure all outputs are dimensionally compatible
u(:,i+1) = u(:,i);
Du(:,i+1) = Du(:,i)*0;
noise = noise(:,1:i+1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

