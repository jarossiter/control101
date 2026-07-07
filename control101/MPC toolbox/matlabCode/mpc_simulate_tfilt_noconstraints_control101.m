%%%%%%%%%%%%%%                        (WITH T-filter!!)
%%%%%%%%%%%%%%  Simulates MIMO GPC with no constraint handling
%%%
%              y, u, Du, r are dimensionally compatible 
% closed-loop outputs/inputs/input increments and supplied set-point and disturbance
%
% MFD model     Ay(k) = Bu(k-1) + Tfilt*dist
%
% ny is output horizon
% nu is the input horizon
% Wu is the diagonal control weighting 
% Wy is the diagonal output weighting
% sizey no. outputs and inputs (assumed square)
% dist, noise are the disturbance and noise signals
% ref is the reference signal
%
%%%%%
%%%%%  [y,u,Du,r] = mpc_simulate_tfilt_noconstraints_control101(B,A,Tfilt,nu,ny,Wu,Wy,ref,dist,noise)
%%  
%% Author: J.A. Rossiter  (email: J.A.Rossiter@shef.ac.uk)

function [y,u,Du,r] = mpc_simulate_tfilt_noconstraints_control101(B,A,Tfilt,nu,ny,Wu,Wy,ref,dist,noise)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Error checks
sizey = size(A,1);
if size(B,2)==sizey;B=[B,zeros(sizey,sizey)];end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%   Find prediction matrices 
%%%%    yfut = H *Dufut + P*Dupast + Q*ypast
%%%%    yfut = H *Dufut + Pt*Dutpast + Qt*ytpast   %% filtered data
[H,P,Q] = mpc_predmat_control101(A,B,ny);
[Pt,Qt] = mpc_predtfilt_control101(H,P,Q,Tfilt,sizey,ny);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%   Find control law and parameters of the cost function
%%%%   Dufut = Pr*rfut - Dk*Dutpast - Nk*ytpast 
%%%%    J = Dufut'*S*Dufut + Dufut'*2X*[Dutpast;ytpast;rfut]

[Nk,Dk,Pr,S,X] = mpc_law_control101(H,Pt,Qt,nu,Wu,Wy,sizey);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Set up simulation parameters
nNk = size(Nk,2)/sizey;
nDk = size(Dk,2)/sizey;
nT = size(Tfilt,2)/sizey;
T2 = Tfilt(:,sizey+1:nT*sizey);
nA = size(A,2)/sizey;
nB = size(B,2)/sizey;
init = max([nNk,nDk,nA,nB])+2;
y = zeros(sizey,init);    yt=y;
u = y;
Du = u;     Dut = u;
r = u;
d=u;
runtime = size(ref,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



for i=init:runtime-1;
   
    %%%%% Update filtered data
    ytpast = yt(:,i-1:-1:i-nT+1);
    yt(:,i) = y(:,i) + noise(:,i) - T2*ytpast(:);
    Dutpast = Dut(:,i-2:-1:i-nT);
    Dut(:,i-1) = Du(:,i-1) - T2*Dutpast(:);
   
%%% Define vectors of past filtered data for use by control law
d(1:sizey,i+1)=dist(:,i+1);
ypast = yt(:, i:-1:i+1-nNk);
Dupast = Dut(:, i-1:-1:i-nDk) ;
upast = u(:, i-1);
rfut = ref(:,i+1); 

%%%%%%% Unconstrained law 
Dufast = Pr*rfut - Nk*ypast(:) - Dk*Dupast(:);
Du(:,i) = Dufast(1:sizey);
u(:,i) = u(:,i-1)+Du(:,i);
%  End to update control law


%%% Simulate the process
upast2 = u(:,i:-1:i-nB+1);
ypast2 = y(:, i:-1:i+2-nA);
y(:,i+1) = -A(:,sizey+1:nA*sizey)*ypast2(:) + B*[upast2(:)]+ d(:,i+1);
r(:,i+1) = ref(:,i+1);


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%  Produce a neat plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Ensure all outputs are dimensionally compatible
u(:,i+1) = u(:,i);
Du(:,i+1) = Du(:,i)*0;
noise = noise(:,1:i+1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


