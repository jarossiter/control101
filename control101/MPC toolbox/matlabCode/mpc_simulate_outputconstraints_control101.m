%%%%%%%%%%%%%%                         (NO T-filter!!)
%%%%%%%%%%%%%%  Simulates MIMO GPC with constraint handling - no
%%%%%%%%%%%%%%  advance knowledge of target assumed
%%%%   OVERLAYS THE UNCONSTRAINED CONTROL CHOICE
%%%%   WARNING - INCLUSION OF OUTPUT CONSTRANTS CAN CAUSE INFEASIBILITY -
%%%%   THIS CODE IS NOT DESIGNED TO BE ROBUST TO SUCH CASES!
%%%
%%%%%  [y,u,Du,r] = mpc_simulate_outputconstraints_control101(B,A,nu,ny,Wu,Wy,Dumax,umax,umin,ymax,ymin,ref,dist,noise)
%              y, u, Du, r are dimensionally compatible 
% closed-loop outputs/inputs/input increments and supplied set-point and disturbance
%
% MFD model     Ay(k) = Bu(k-1) + dist
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
% ymax, ymin are vectors of limits on outputs
%
% [y,u,Du,r,d] = mpc_simulate_outputconstraints_control101(B,A,nu,ny,Wu,Wy,Dumax,umax,umin,ymax,ymin,ref,dist,noise)
%%  
%% Author: J.A. Rossiter  (email: J.A.Rossiter@shef.ac.uk)

function [y,u,Du,r] = mpc_simulate_outputconstraints_control101(B,A,nu,ny,Wu,Wy,Dumax,umax,umin,ymax,ymin,ref,dist,noise)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Error checks
sizey = size(A,1);
if size(B,2)==sizey;B=[B,zeros(sizey,sizey)];end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%   Find prediction matrices 
%%%%    yfut = H *Dufut + P*Dupast + Q*ypast
[H,P,Q] = mpc_predmat_control101(A,B,ny);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%   Find control law and parameters of the cost function
%%%%   Dufut = Pr*rfut - Dk*Dupast - Nk*ypast 
%%%%    J = Dufut'*S*Dufut + Dufut'*2X*[Dupast;ypast;rfut]
[Nk,Dk,Pr,S,X] = mpc_law_control101(H,P,Q,nu,Wu,Wy,sizey);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%   Define constraint matrices
%%%%%%   CC*Du(future) - dd - du*u(k-1))-ddu*Dupast-dy*ypast <= 0
[CC,dd,du,ddu,dy]  = mpc_constraints2_control101(Dumax,umax,umin,ymax,ymin,sizey,nu,H(:,1:nu*sizey),P,Q);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Set up simulation parameters
nNk = size(Nk,2)/sizey;
nDk = size(Dk,2)/sizey;
init = max([nNk,nDk])+2;
y = zeros(sizey,init);
u = y; ufast=u;
Du = u;
r = u;
d=u;
opt = optimset('quadprog');
opt.Diagnostics='off';    %%%%% Switches of unwanted MATLAB displays
opt.LargeScale='off';     %%%%% However no warning of infeasibility
opt.Display='off';
opt.Algorithm='interior-point-convex';

runtime = size(ref,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1); clf reset

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% Closed-loop simulation

for i=init:runtime-ny-1;

%%% Update unconstrained control law
d(1:sizey,i+1)=dist(:,i+1);
ypast = y(:, i:-1:i+1-nNk)+noise(:, i:-1:i+1-nNk);
Dupast = Du(:, i-1:-1:i-nDk) ;
upast = u(:, i-1);
rfut = ref(:,i+1); 


%%%%%%% Unconstrained law - for overlay plots
Dufast(:,i) = Pr*rfut - Nk*ypast(:) - Dk*Dupast(:);
ufast(:,i)=u(:,i-1)+Dufast(1:sizey,i);

% Form constraint matrices and solve constrained optimisation
%%%%%%   CC*Du(future) - dd - du*u(k-1))-ddu*Dupast-dy*ypast <= 0
%  J = Dufut'S*Dufut+2*X*[Dupast(:);ypast(:);rfut(:)]*Dufut
dt = dd+du*upast(:)+ddu*Dupast(:)+dy*ypast(:);
f=X*[Dupast(:);ypast(:);rfut(:)];
[Duqp,fval,exitflag] = quadprog(S,f,CC,dt,[],[],[],[],[],opt);
if exitflag==-2; %%% output constraints causing a problem so ignore
    disp(['Ignoring output constraints at sample ',num2str(i)]);
  vec=1:4*nu*sizey;
  [Duqp,fval,exitflag] = quadprog(S,f,CC(vec,:),dt(vec),[],[],[],[],[],opt);
end

Du(:,i) = Duqp(1:sizey);
u(:,i) = u(:,i-1)+Du(:,i);


%  Ensure the constraints satisfied by proposed control law   
for j=1:sizey;
   if u(j,i)>u(j,i-1)+Dumax(j);u(j,i)=u(j,i-1)+Dumax(j);end
   if u(j,i)<u(j,i-1)-Dumax(j);u(j,i)=u(j,i-1)-Dumax(j);end
   if u(j,i)>umax(j); u(i)=umax(j);end
   if u(j,i)<umin(j); u(i)=umin(j);end
end
Du(:,i) = u(:,i)-u(:,i-1);
%%% End of update to the control law


%%% Simulate the process
upast2 = u(:,i:-1:i-nDk);
ypast2 = y(:, i:-1:i+2-nNk);
y(:,i+1) = -A(:,sizey+1:nNk*sizey)*ypast2(:) + B*[upast2(:)] + d(:,i+1);
r(:,i+1) = ref(:,i+1);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Ensure all outputs are dimensionally compatible
u(:,i+1) = u(:,i);
ufast(:,i+1)=ufast(:,i);
Du(:,i+1) = Du(:,i)*0;
Dufast(:,i+1)=Dufast(:,i)*0;
noise = noise(:,1:i+1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%  Produce a neat plot
time=0:size(u,2)-1;
for i=1:sizey;
    figure(i);clf reset
    plotall(y(i,:),r(i,:),u(i,:),ufast(i,:),Du(i,:),Dufast(i,:),d(i,:),noise(i,:),umax(i),umin(i),Dumax(i),ymax(i),ymin(i),time,i);
end


%%%%% Function to do plotting in the MIMO case and 
%%%%% allow a small boundary around each plot

function plotall(y,r,u,ufast,Du,Dufast,d,noise,umax,umin,Dumax,ymax,ymin,time,loop)

uupper = [umax,umax]';
ulower = [umin,umin]';
yupper = [ymax,ymax]';
ylower = [ymin,ymin]';
Dulim = [Dumax,Dumax]';
time2 = [0,time(end)];
rangeu = (max(umax)-min(umin))/10;
rangey = (max(ymax)-min(ymin))/10;
ranged = (max(max([d,noise]))-min(min([d,noise])))/20;if ranged==0;ranged=1;end

subplot(221);
aa=plot(time,y','-',time,r','--',time2,yupper,'--',time2,ylower,'--');
set(aa,'linewidth',2);
axis([time2,ymin-rangey,ymax+rangey]);
xlabel(['GPC - Outputs and set-point in loop ',num2str(loop)]);
subplot(222);
aa=plot(time,Du','-',time, Dufast,':',time2,Dulim,'--',time2,-Dulim,'--');
set(aa,'linewidth',2);
axis([time2,min(-Dumax)-rangeu,max(Dumax)+rangeu]);
legend('Constrained','Unconstrained');
xlabel(['GPC - Input increments in loop ',num2str(loop)]);
subplot(223);
aa=plot(time,u','-',time,ufast,':',time2,uupper,'--',time2,ulower,'--');
set(aa,'linewidth',2);
axis([time2,min(umin)-rangeu,max(umax)+rangeu]);
xlabel(['GPC - Inputs in loop ',num2str(loop)]);
subplot(224);
aa=plot(time,d','b',time,noise,'g');
set(aa,'linewidth',2);
axis([time2,min(min([d,noise]))-ranged,max(max([d,noise]))+ranged]);
xlabel(['GPC - Disturbance/noise in loop ',num2str(loop)]);
