classdef mpcconstraints_lab_control101 < matlab.apps.AppBase
    %MPCCONSTRAINTS_LAB_CONTROL101
    %   This is a simple interface to understand and investigate how the
    %   core parameters within an MPC law affect the decision making and
    %   performance in teh presence of constraints.

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        TabGroup                      matlab.ui.container.TabGroup
        SimulationchoicesTab          matlab.ui.container.Tab
        GridLayout10                  matlab.ui.container.GridLayout
        GridLayout10_2                matlab.ui.container.GridLayout
        GridLayout7_2                 matlab.ui.container.GridLayout
        DisturbanceDropDown           matlab.ui.control.DropDown
        DisturbanceDropDownLabel      matlab.ui.control.Label
        ModelDropDown                 matlab.ui.control.DropDown
        ModelDropDownLabel            matlab.ui.control.Label
        ChoicesLabel                  matlab.ui.control.Label
        GridLayout11                  matlab.ui.container.GridLayout
        OutputonButton                matlab.ui.control.Button
        AbsoluteonButton              matlab.ui.control.Button
        RatesonButton                 matlab.ui.control.Button
        OnoroffLabel                  matlab.ui.control.Label
        GridLayout8                   matlab.ui.container.GridLayout
        GridLayout3_2                 matlab.ui.container.GridLayout
        InputratesSlider              matlab.ui.control.Slider
        InputratesSliderLabel         matlab.ui.control.Label
        OutputlimitsSlider            matlab.ui.control.RangeSlider
        OutputlimitsSliderLabel       matlab.ui.control.Label
        AbsoluteinputSlider           matlab.ui.control.RangeSlider
        AbsoluteinputSliderLabel      matlab.ui.control.Label
        ConstraintsLabel              matlab.ui.control.Label
        GridLayout3                   matlab.ui.container.GridLayout
        NoisevarianceSlider           matlab.ui.control.Slider
        NoisevarianceSliderLabel      matlab.ui.control.Label
        TfilterorderSlider            matlab.ui.control.Slider
        TfilterorderSliderLabel       matlab.ui.control.Label
        TfilterpoleSlider             matlab.ui.control.Slider
        TfilterpoleSliderLabel        matlab.ui.control.Label
        Weightingpower10pSlider       matlab.ui.control.Slider
        Weightingpower10pSliderLabel  matlab.ui.control.Label
        ControlhorizonSlider          matlab.ui.control.Slider
        ControlhorizonSliderLabel     matlab.ui.control.Label
        PredictionhorizonSlider       matlab.ui.control.Slider
        PredictionhorizonSliderLabel  matlab.ui.control.Label
        ControllersettingsLabel       matlab.ui.control.Label
        HistoryinformationTab         matlab.ui.container.Tab
        GridLayout13                  matlab.ui.container.GridLayout
        Plot11EditField               matlab.ui.control.EditField
        Plot11EditFieldLabel          matlab.ui.control.Label
        Plot10EditField               matlab.ui.control.EditField
        Plot10EditFieldLabel          matlab.ui.control.Label
        Plot9EditField                matlab.ui.control.EditField
        Plot9EditFieldLabel           matlab.ui.control.Label
        Plot8EditField                matlab.ui.control.EditField
        Plot8EditFieldLabel           matlab.ui.control.Label
        Plot7EditField                matlab.ui.control.EditField
        Plot7EditFieldLabel           matlab.ui.control.Label
        Plot6EditField                matlab.ui.control.EditField
        Plot6EditFieldLabel           matlab.ui.control.Label
        Plot5EditField                matlab.ui.control.EditField
        Plot5EditFieldLabel           matlab.ui.control.Label
        Plot4EditField                matlab.ui.control.EditField
        Plot4EditFieldLabel           matlab.ui.control.Label
        Plot3EditField                matlab.ui.control.EditField
        Plot3EditFieldLabel           matlab.ui.control.Label
        Plot2EditField                matlab.ui.control.EditField
        Plot2EditFieldLabel           matlab.ui.control.Label
        Plot1EditField                matlab.ui.control.EditField
        Plot1EditFieldLabel           matlab.ui.control.Label
        CurrentplotsonlyTab           matlab.ui.container.Tab
        GridLayout14                  matlab.ui.container.GridLayout
        UIAxes8                       matlab.ui.control.UIAxes
        UIAxes7                       matlab.ui.control.UIAxes
        UIAxes6                       matlab.ui.control.UIAxes
        UIAxes5                       matlab.ui.control.UIAxes
        GridLayout5                   matlab.ui.container.GridLayout
        RefreshButton                 matlab.ui.control.Button
        SimulateButton                matlab.ui.control.Button
        GridLayout4                   matlab.ui.container.GridLayout
        GridLayout9                   matlab.ui.container.GridLayout
        RuntimecostEditField          matlab.ui.control.NumericEditField
        RuntimecostEditFieldLabel     matlab.ui.control.Label
        Image                         matlab.ui.control.Image
        GPCwithaTfilterandconstraintsLabel  matlab.ui.control.Label
        UIAxes2                       matlab.ui.control.UIAxes
        UIAxes4                       matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        originalsize % Description
        
        legstring=cell(1)
        nlegstring=1;
        legendstore=cell(1)
    end
    
    methods (Access = private)
        
        function  disablebuttons(app)
            set(app.SimulateButton,'Enable','off')
            set(app.ModelchoiceDropDown, 'Enable', 'off');
             set(app.DisturbancesDropDown, 'Enable', 'off');
            set(app.UncertaintyDropDown, 'Enable', 'off');
            
        end
        
        function enablebuttons(app)
            set(app.SimulateButton,'Enable','on')
            set(app.ModelchoiceDropDown, 'Enable', 'on');
             set(app.DisturbancesDropDown, 'Enable', 'on');
            set(app.UncertaintyDropDown, 'Enable', 'on');
        end


        % Forms optimal MPC control law and the associated predictions at
        % the current sample
        function [Duopt,uopt,ypredall,ypred] = getpredictions(app,a,b,ny,nu,lambda,ny2,y,Du,r,u,k)
            
            na = length(a);
            nb=length(b);
            [H,P,Q] = mpc_predmat_toeplitz_control101(a,b,ny);   % pred over horizon
            [H2,P2,Q2] = mpc_predmat_toeplitz_control101(a,b,ny2);   % full prediction
            HH=tril(ones(nu,nu));
            [Nk,Dk,Pr,S,X,Prlong] = mpc_law_control101(H,P,Q,nu,lambda,1,1);
            
            % Find input and output prediction
            ypast=y(k:-1:k-na+1)';
            Dupast = Du(k-1:-1:k-nb+1)';
            Duopt = Pr*r(k+1) -Nk*ypast-Dk*Dupast;
            uopt=HH*Duopt+u(k-1);
            ypredall = H2(:,1:nu)*Duopt+Q2*ypast+P2*Dupast;
            ypred = H(:,1:nu)*Duopt+Q*ypast+P*Dupast;
            
        end

%%%%%%%%%%%%%%   Simulates MIMO GPC with constraint handling
%%%%   OVERLAYS THE UNCONSTRAINED CONTROL CHOICE
%%%%   WARNING - INCLUSION OF OUTPUT CONSTRANTS CAN CAUSE INFEASIBILITY -
%%%%   THIS CODE IS NOT DESIGNED TO BE ROBUST TO SUCH CASES!
%%%
%%%%%  [y,u,Du,r] = mpc_simulate_tfilt_outputconstraints_control101(B,A,Tfilt,nu,ny,Wu,Wy,Dumax,umax,umin,ymax,ymin,ref,dist,noise)
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
% Dumax is a vector of limits on input increments (assumed symetric)
% umax, umin are vectors of limits on the inputs

function [y,u,Du,r] = mpc_internal(app,B,A,Tfilt,nu,ny,Wu,Wy,Dumax,umax,umin,ymax,ymin,ref,dist,noise)

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%   Define constraint matrices
%%%%%%   CC*Du(future) - dd - du*u(k-1))-ddu*Dupast-dy*ypast <= 0
[CC,dd,du,ddu,dy]  = mpc_constraints2_control101(Dumax,umax,umin,ymax,ymin,sizey,nu,H(:,1:nu*sizey),Pt,Qt);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
u = y;ufast=u;
Du = u;     Dut = u;
r = u;
d=u;
opt = optimset('quadprog');
opt.Diagnostics='off';    %%%%% Switches of unwanted MATLAB displays
opt.LargeScale='off';     %%%%% However no warning of infeasibility
opt.Display='off';
opt.Algorithm='interior-point-convex';
runtime = size(ref,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=init:runtime-ny-1;
   
    %%% Update unconstrained control law

    
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

%%%%%%% Unconstrained law - if needed
Dufast = Pr*rfut - Nk*ypast(:) - Dk*Dupast(:);

% Form constraint matrices and solve constrained optimisation
%%%%%%   CC*Du(future) - dd - du*u(k-1))-ddu*Dupast-dy*ypast <= 0]
%%% note past is filtered data
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
   if u(j,i)>u(j,i-1)+Dumax(j),u(j,i)=u(j,i-1)+Dumax(j);end
   if u(j,i)<u(j,i-1)-Dumax(j),u(j,i)=u(j,i-1)-Dumax(j);end
   if u(j,i)>umax(j); u(i)=umax(j);end
   if u(j,i)<umin(j); u(i)=umin(j);end
end
Du(:,i) = u(:,i)-u(:,i-1);
%  End to update control law


%%% Simulate the process
upast2 = u(:,i:-1:i-nB+1);
ypast2 = y(:, i:-1:i+2-nA);
y(:,i+1) = -A(:,sizey+1:nA*sizey)*ypast2(:) + B*[upast2(:)]+ d(:,i+1);
r(:,i+1) = ref(:,i+1);


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Ensure all outputs are dimensionally compatible
u(:,i+1) = u(:,i);
Du(:,i+1) = Du(:,i)*0;
noise = noise(:,1:i+1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%  Produce a neat plot
time=0:size(u,2)-1;
for i=1:sizey;
    
    plotall(app,y(i,:),r(i,:),u(i,:),Du(i,:),d(i,:),noise(i,:),umax(i),umin(i),Dumax(i),ymin(i),ymax(i),time,i);
end

end   % end of internal MPC function

%%%%% Function to do plotting in the MIMO case and 
%%%%% allow a small boundary around each plot

function plotall(app,y,r,u,Du,d,noise,umax,umin,Dumax,ymin,ymax,time,loop)

uupper = [umax,umax]';
ulower = [umin,umin]';
yupper = [ymax,ymax]';
ylower = [ymin,ymin]';
Dulim = [Dumax,Dumax]';
time2 = [0,time(end)];
rangeDu = (max(umax)-min(umin))/10;
rangeu = (max(umax)-min(umin))/10;
rangey = (max(ymax)-min(ymin))/10;
ranged = (max(max([d,noise]))-min(min([d,noise])))/20;

aa=plot(app.UIAxes5,time,y','-',time,r','--',time2,yupper,'--',time2,ylower,'--');
set(aa,'linewidth',2)
axis(app.UIAxes5,[time2,ymin-rangey,ymax+rangey]);
title(app.UIAxes5,['Outputs and set-point in loop ',num2str(loop)]);

aa=plot(app.UIAxes6,time,Du','-',time2,Dulim,'--',time2,-Dulim,'--');
set(aa,'linewidth',2)
axis(app.UIAxes6,[time2,-Dumax*1.1,Dumax*1.1]);
title(app.UIAxes6,['Input increments in loop ',num2str(loop)]);

aa=plot(app.UIAxes7,time,u','-',time2,uupper,'--',time2,ulower,'--');
set(aa,'linewidth',2)
axis(app.UIAxes7,[time2,min(umin)-rangeu,max(umax)+rangeu]);
title(app.UIAxes7,['Inputs in loop ',num2str(loop)]);

aa=plot(app.UIAxes8,time,d','b',time,noise,'g');
set(aa,'linewidth',2)
if max(abs([d,noise]))>0;
    axis(app.UIAxes8,[time2,min(min([d,noise]))-ranged,max(max([d,noise]))+ranged]);
end
title(app.UIAxes8,['Disturbance/noise in loop ',num2str(loop)]);

        
end   % end of plotall function


    end  % end of all functions
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.UIFigure.AutoResizeChildren='off';   
            movegui(app.UIFigure)
            
            % Open the manual
            if exist('mpc_constraints_control101_manual_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open mpc_constraints_control101_manual_mycopy.mlx
            else
                p1 = which('mpc_constraints_control101_manual.mlx');
                p2 = strcat(pwd,'/mpc_constraints_control101_manual_mycopy.mlx');
                copyfile(p1,p2)
                open mpc_constraints_control101_manual_mycopy.mlx
                clear p1 p2
            end
            

            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);
          
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
                theme(app.UIFigure,"light")
                
            end
        end

        % Size changed function: UIFigure
        function UIFigureSizeChanged(app, event)
           position = app.UIFigure.Position;
                                 
           % Determine the current size
           newSize = position(3) * position(4);
           numberofchanges = length(app.originalsize);
           
           % Do not use these lines at start up
           if numberofchanges>0;
           app.originalsize(numberofchanges+1)=newSize;
           currentsize = app.originalsize(numberofchanges);
           % get the resize factor using root
           resizeFactor = sqrt(newSize/currentsize);
          
           % get the handles of object, which haven the property about font size
           h = findobj(app.UIFigure, '-property', 'FontSize');
           hFontSize = cell2mat(get(h, 'FontSize'));
           % get the current font size and change the font size using resize factor
           newFontSize =  hFontSize * resizeFactor;
           % set the new font size back
           set(h,{'FontSize'}, num2cell(newFontSize));
           end
            
        end

        % Button pushed function: RefreshButton
        function RefreshButtonPushed(app, event)
            app.legstring=cell(1);
            app.legstring{1}='Reference';
            app.nlegstring=1;
            hold(app.UIAxes2,'off');
            plot(app.UIAxes2,1,1,'w')
            hold(app.UIAxes4,'off')
            plot(app.UIAxes4,1,1,'w')    
            app.Plot1EditField.Value='';
            app.Plot2EditField.Value='';
            app.Plot3EditField.Value='';
            app.Plot4EditField.Value='';
            app.Plot5EditField.Value='';
            app.Plot6EditField.Value='';
            app.Plot7EditField.Value='';
            app.Plot8EditField.Value='';
            app.Plot9EditField.Value='';
            app.Plot10EditField.Value='';
            app.Plot11EditField.Value='';
        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
           

            % Controller settings and external signals
            ny=app.PredictionhorizonSlider.Value;
            nu=app.ControlhorizonSlider.Value;
            lambda = 10^(app.Weightingpower10pSlider.Value);
            runtime=50;
            init=5;
            ref = [zeros(1,init),ones(1,runtime-init)];
            dist=[zeros(1,init+2),ones(1,runtime-init-2)*0.2];
            noise = randn(1,runtime)*app.NoisevarianceSlider.Value;

            % Collect values of constraints
            if strcmp(app.RatesonButton.Text,'Rates on')
                Dumax = app.InputratesSlider.Value;
            else
                Dumax=100;
            end
            if strcmp(app.AbsoluteonButton.Text,'Absolute on')
                umin=app.AbsoluteinputSlider.Value(1);
                umax=app.AbsoluteinputSlider.Value(2);
            else
                umin=-100; umax=100;
            end
            if strcmp(app.OutputonButton.Text,'Output on')
                ymax=app.OutputlimitsSlider.Value(2);
                ymin=app.OutputlimitsSlider.Value(1);
            else
                ymax=100;ymin=-100;
            end
                      
            % Define the T filter
            Tfilter=[1,-app.TfilterpoleSlider.Value];
            Tfilterstring=['1,',num2str(Tfilter(2))];

            if app.TfilterorderSlider.Value==2;
                Tfilter = conv(Tfilter,Tfilter);
                Tfilterstring=['1,',num2str(Tfilter(2)),',',num2str(Tfilter(3))];
            end
            if app.TfilterorderSlider.Value==3;
                Tfilter = conv(conv(Tfilter,Tfilter),Tfilter);
                Tfilterstring=['1,',num2str(Tfilter(2)),',',num2str(Tfilter(3)),...
                    ',',num2str(Tfilter(4))];
            end

            tt=1:30;
            % Check for no disturbances
            disttext=', dist=N, ';
            if strcmp(app.DisturbanceDropDown.Value,'no'); 
                dist=dist*0;
                else
                disttext=', dist=Y, ';
                ref=ref*0;
            end

            % initialise plot
            if app.nlegstring==1;
                aa=plot(app.UIAxes4,tt,ref(tt),'r--','LineWidth',2);
                hold(app.UIAxes4,'on')
                app.legstring{1}='Reference';
            end

            % upload model
            switch app.ModelDropDown.Value
                case "1st order"
                    a=[1 -0.8]; b=[0.4 0]; na=2;nb=2;
                    %ap=[1 -0.85]; bp=[0.42, 0];
                    modelname='Model 1';
                case "2nd order"
                    a=[1,-1.4, 0.48]; b=[0.1 0.1]; na=3; nb=2;
                    %ap=[1 -1.5 0.56]; bp=[0.12, 0.11];
                    dist=dist/2;
                    modelname='Model 2';
                case "3rd order"
                    a=poly([0.8,0.6,0.5]); b=[0.05 0.03]; na=4;nb=2;
                    %ap=poly([0.8,0.6,0.5]); bp=[0.04, 0.025];
                    dist=dist/4;
                    modelname='Model 3';
            end
            
            na=length(a);  % number of parameter values
            nb=length(b);

            %%% Compute and plot MPC closed-loop behaviour for 30 samples
            %%% with and without the T-filter
            %%% Set point, disturbance and noise
            
            % Simulations with no constraints. NOT USED
            % [ycl,ucl,Ducl,r] = mpc_simulate_noconstraints_control101(b,a,bp,ap,nu,ny,lambda,1,ref,dist,noise);
            % [yT,uT,DuT,r] = mpc_simulate_tfilt_noconstraints_control101(b,a,Tfilter,nu,ny,lambda,1,ref,dist,noise);
            
            % All constraints and a T-filter
            [yT,uT,DuT,r] = mpc_internal(app,b,a,Tfilter,nu,ny,lambda,1,Dumax,umax,umin,ymax,ymin,ref,dist,noise);

            % History plots
            aaa=plot(app.UIAxes4,tt,yT(tt),'LineWidth',2);
            stairs(app.UIAxes2,tt,uT(tt),'LineWidth',2,'Color',aaa.Color);
            hold(app.UIAxes2,'on')

        
            % Update prediction costs
                    sumerrors = norm(r-yT)^2;
                    suminputs = norm(DuT)^2;
                    J(app.nlegstring)=round(sumerrors+lambda*suminputs,3,'significant');
                    app.RuntimecostEditField.Value=J(app.nlegstring);
                   % app.SuminputchangesEditField.Value=suminputs;

            % update legend
            lam=round(lambda,3,'significant');
            app.nlegstring=app.nlegstring+1;
            app.legstring{app.nlegstring}=['Plot ',num2str(app.nlegstring-1)];
                  
            tempstring=(['ny=',num2str(ny),...
                 ', nu=',num2str(nu),', W=',num2str(lam),...
                 ', T=[',Tfilterstring,']',disttext,' J=',num2str(J(app.nlegstring-1)),...
                 ', ulim=[',num2str(Dumax),',',num2str([umin]),',',num2str([umax]),']',...
                 ', ylim=[',num2str([ymin]),',',num2str([ymax]),'], ',modelname]);
            legend(app.UIAxes4,app.legstring,'Location','southeast','FontSize',8)
            app.legendstore{app.nlegstring-1}='tempstring';
            switch app.nlegstring;
                case 2
                  app.Plot1EditField.Value=tempstring;
                case 3
                  app.Plot2EditField.Value=tempstring;
                case 4
                  app.Plot3EditField.Value=tempstring;
                case 5
                  app.Plot4EditField.Value=tempstring;
                case 6
                  app.Plot5EditField.Value=tempstring;
                case 7
                  app.Plot6EditField.Value=tempstring;
                case 8
                  app.Plot7EditField.Value=tempstring;
                case 9
                  app.Plot8EditField.Value=tempstring;
                case 10
                  app.Plot9EditField.Value=tempstring;
                case 11
                  app.Plot10EditField.Value=tempstring;
                case 12
                  app.Plot11EditField.Value=tempstring;
            end

            
            
            

        end

        % Value changed function: PredictionhorizonSlider
        function PredictionhorizonSliderValueChanged(app, event)
            value = app.PredictionhorizonSlider.Value;
            value =round(value);
            if value<app.ControlhorizonSlider.Value;
                value =app.ControlhorizonSlider.Value+1;
            end
            app.PredictionhorizonSlider.Value=value;
            if value==0;
                app.PredictionhorizonSlider.Value=5;
            end

        end

        % Value changed function: ControlhorizonSlider
        function ControlhorizonSliderValueChanged(app, event)
            value = app.ControlhorizonSlider.Value;
            value =round(value);
            if value>app.PredictionhorizonSlider.Value;
                app.PredictionhorizonSlider.Value=value+1;
            end
            app.ControlhorizonSlider.Value=value;

        end

        % Value changed function: Weightingpower10pSlider
        function Weightingpower10pSliderValueChanged(app, event)
            value = app.Weightingpower10pSlider.Value;
            value = round(value *2)/2;
            app.Weightingpower10pSlider.Value=value;

        end

        % Value changed function: TfilterpoleSlider
        function TfilterpoleSliderValueChanged(app, event)
            value = app.TfilterpoleSlider.Value;
            value = round(value*20)/20;
            if value ==1; value =0.95;end
            app.TfilterpoleSlider.Value=value;
        end

        % Value changed function: TfilterorderSlider
        function TfilterorderSliderValueChanged(app, event)
            value = app.TfilterorderSlider.Value;
            value = round(value);
            app.TfilterorderSlider.Value=value;
        end

        % Value changed function: NoisevarianceSlider
        function NoisevarianceSliderValueChanged(app, event)
            value = app.NoisevarianceSlider.Value;
            value = round(value*100)/100;
            app.NoisevarianceSlider.Value=value;
        end

        % Button pushed function: RatesonButton
        function RatesonButtonPushed(app, event)
            value=app.RatesonButton.Text;
            switch value 
                case 'Rates on';
                    app.RatesonButton.Text = 'Rates off';
                    app.RatesonButton.BackgroundColor='r';
                case 'Rates off'
                    app.RatesonButton.Text='Rates on';
                    app.RatesonButton.BackgroundColor=[.20,0.70,0.20];
            end
        end

        % Button pushed function: AbsoluteonButton
        function AbsoluteonButtonPushed(app, event)
            value=app.AbsoluteonButton.Text;
            switch value 
                case 'Absolute on';
                    app.AbsoluteonButton.Text = 'Absolute off';
                    app.AbsoluteonButton.BackgroundColor='r';
                case 'Absolute off'
                    app.AbsoluteonButton.Text='Absolute on';
                    app.AbsoluteonButton.BackgroundColor=[.20,0.70,0.20];
            end
        end

        % Button pushed function: OutputonButton
        function OutputonButtonPushed(app, event)
            value=app.OutputonButton.Text;
            switch value 
                case 'Output on';
                    app.OutputonButton.Text = 'Output off';
                    app.OutputonButton.BackgroundColor='r';
                case 'Output off'
                    app.OutputonButton.Text='Output on';
                    app.OutputonButton.BackgroundColor=[.20,0.70,0.20];
            end
        end

        % Value changed function: InputratesSlider
        function InputratesSliderValueChanged(app, event)
            value = app.InputratesSlider.Value;
            value = round(value*10)/10;
            app.InputratesSlider.Value=value;
        end

        % Value changed function: AbsoluteinputSlider
        function AbsoluteinputSliderValueChanged(app, event)
            value = app.AbsoluteinputSlider.Value;
            if value(1)>0;value(1)=0;end
            if value(2)<0.1;value(2)=0.1;end
            value = round(value*10)/10;
            app.AbsoluteinputSlider.Value=value;
            
        end

        % Value changed function: OutputlimitsSlider
        function OutputlimitsSliderValueChanged(app, event)
            value = app.OutputlimitsSlider.Value;
            if value(1)>-0.1;value(1)=-0.1;end
            if value(2)<0.1;value(2)=0.1;end
            value = round(value*10)/10;
            app.OutputlimitsSlider.Value=value;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 1437 955];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '0.5x', '2x'};
            app.GridLayout.RowHeight = {'0.45x', '1x', '1x'};

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.GridLayout);
            title(app.UIAxes4, 'Closed-loop output')
            xlabel(app.UIAxes4, 'Samples')
            ylabel(app.UIAxes4, 'Output')
            zlabel(app.UIAxes4, 'Z')
            app.UIAxes4.FontSize = 18;
            app.UIAxes4.Layout.Row = 2;
            app.UIAxes4.Layout.Column = 3;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout);
            title(app.UIAxes2, 'Closed-loop input')
            xlabel(app.UIAxes2, 'Samples')
            ylabel(app.UIAxes2, 'Input')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 18;
            app.UIAxes2.Layout.Row = 3;
            app.UIAxes2.Layout.Column = 3;

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'2x', '1x'};
            app.GridLayout4.RowHeight = {'1x', '1.4x'};
            app.GridLayout4.Layout.Row = 1;
            app.GridLayout4.Layout.Column = [2 3];
            app.GridLayout4.BackgroundColor = [0.6 1 1];

            % Create GPCwithaTfilterandconstraintsLabel
            app.GPCwithaTfilterandconstraintsLabel = uilabel(app.GridLayout4);
            app.GPCwithaTfilterandconstraintsLabel.BackgroundColor = [0 1 1];
            app.GPCwithaTfilterandconstraintsLabel.HorizontalAlignment = 'center';
            app.GPCwithaTfilterandconstraintsLabel.WordWrap = 'on';
            app.GPCwithaTfilterandconstraintsLabel.FontSize = 24;
            app.GPCwithaTfilterandconstraintsLabel.FontWeight = 'bold';
            app.GPCwithaTfilterandconstraintsLabel.Layout.Row = 1;
            app.GPCwithaTfilterandconstraintsLabel.Layout.Column = 1;
            app.GPCwithaTfilterandconstraintsLabel.Text = 'GPC with a T-filter and constraints';

            % Create Image
            app.Image = uiimage(app.GridLayout4);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 2;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'UoSlogo.png');

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.GridLayout4);
            app.GridLayout9.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.GridLayout9.RowHeight = {'1x'};
            app.GridLayout9.Layout.Row = 2;
            app.GridLayout9.Layout.Column = [1 2];

            % Create RuntimecostEditFieldLabel
            app.RuntimecostEditFieldLabel = uilabel(app.GridLayout9);
            app.RuntimecostEditFieldLabel.HorizontalAlignment = 'center';
            app.RuntimecostEditFieldLabel.FontSize = 18;
            app.RuntimecostEditFieldLabel.FontWeight = 'bold';
            app.RuntimecostEditFieldLabel.Layout.Row = 1;
            app.RuntimecostEditFieldLabel.Layout.Column = 1;
            app.RuntimecostEditFieldLabel.Text = 'Runtime cost';

            % Create RuntimecostEditField
            app.RuntimecostEditField = uieditfield(app.GridLayout9, 'numeric');
            app.RuntimecostEditField.FontSize = 24;
            app.RuntimecostEditField.FontWeight = 'bold';
            app.RuntimecostEditField.Layout.Row = 1;
            app.RuntimecostEditField.Layout.Column = 2;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout);
            app.GridLayout5.Layout.Row = 1;
            app.GridLayout5.Layout.Column = 1;
            app.GridLayout5.BackgroundColor = [1 0.6 0.8];

            % Create SimulateButton
            app.SimulateButton = uibutton(app.GridLayout5, 'push');
            app.SimulateButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateButtonPushed, true);
            app.SimulateButton.WordWrap = 'on';
            app.SimulateButton.BackgroundColor = [1 0.2 0.702];
            app.SimulateButton.FontSize = 24;
            app.SimulateButton.FontWeight = 'bold';
            app.SimulateButton.Layout.Row = [1 2];
            app.SimulateButton.Layout.Column = 1;
            app.SimulateButton.Text = 'Simulate';

            % Create RefreshButton
            app.RefreshButton = uibutton(app.GridLayout5, 'push');
            app.RefreshButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshButtonPushed, true);
            app.RefreshButton.WordWrap = 'on';
            app.RefreshButton.BackgroundColor = [1 0.2 0.702];
            app.RefreshButton.FontSize = 24;
            app.RefreshButton.FontWeight = 'bold';
            app.RefreshButton.Layout.Row = [1 2];
            app.RefreshButton.Layout.Column = 2;
            app.RefreshButton.Text = 'Refresh';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.Layout.Row = [2 3];
            app.TabGroup.Layout.Column = [1 2];

            % Create SimulationchoicesTab
            app.SimulationchoicesTab = uitab(app.TabGroup);
            app.SimulationchoicesTab.Title = 'Simulation choices';

            % Create GridLayout10
            app.GridLayout10 = uigridlayout(app.SimulationchoicesTab);
            app.GridLayout10.ColumnWidth = {'1x', '0.45x'};
            app.GridLayout10.RowHeight = {'1x'};

            % Create GridLayout8
            app.GridLayout8 = uigridlayout(app.GridLayout10);
            app.GridLayout8.ColumnWidth = {'1x'};
            app.GridLayout8.RowHeight = {'1.8x', '1x'};
            app.GridLayout8.Layout.Row = 1;
            app.GridLayout8.Layout.Column = 1;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout8);
            app.GridLayout3.ColumnWidth = {'0.4x', '1x'};
            app.GridLayout3.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout3.Layout.Row = 1;
            app.GridLayout3.Layout.Column = 1;
            app.GridLayout3.BackgroundColor = [0.902 1 0.502];

            % Create ControllersettingsLabel
            app.ControllersettingsLabel = uilabel(app.GridLayout3);
            app.ControllersettingsLabel.BackgroundColor = [1 1 0];
            app.ControllersettingsLabel.HorizontalAlignment = 'center';
            app.ControllersettingsLabel.FontSize = 24;
            app.ControllersettingsLabel.FontWeight = 'bold';
            app.ControllersettingsLabel.Layout.Row = 1;
            app.ControllersettingsLabel.Layout.Column = [1 2];
            app.ControllersettingsLabel.Text = 'Controller settings';

            % Create PredictionhorizonSliderLabel
            app.PredictionhorizonSliderLabel = uilabel(app.GridLayout3);
            app.PredictionhorizonSliderLabel.HorizontalAlignment = 'right';
            app.PredictionhorizonSliderLabel.WordWrap = 'on';
            app.PredictionhorizonSliderLabel.FontSize = 14;
            app.PredictionhorizonSliderLabel.FontWeight = 'bold';
            app.PredictionhorizonSliderLabel.Layout.Row = 2;
            app.PredictionhorizonSliderLabel.Layout.Column = 1;
            app.PredictionhorizonSliderLabel.Text = 'Prediction horizon';

            % Create PredictionhorizonSlider
            app.PredictionhorizonSlider = uislider(app.GridLayout3);
            app.PredictionhorizonSlider.Limits = [0 20];
            app.PredictionhorizonSlider.ValueChangedFcn = createCallbackFcn(app, @PredictionhorizonSliderValueChanged, true);
            app.PredictionhorizonSlider.MinorTicks = [0 2 4 6 8 10 12 14 16 18 20];
            app.PredictionhorizonSlider.FontSize = 14;
            app.PredictionhorizonSlider.FontWeight = 'bold';
            app.PredictionhorizonSlider.Layout.Row = 2;
            app.PredictionhorizonSlider.Layout.Column = 2;
            app.PredictionhorizonSlider.Value = 10;

            % Create ControlhorizonSliderLabel
            app.ControlhorizonSliderLabel = uilabel(app.GridLayout3);
            app.ControlhorizonSliderLabel.HorizontalAlignment = 'right';
            app.ControlhorizonSliderLabel.WordWrap = 'on';
            app.ControlhorizonSliderLabel.FontSize = 14;
            app.ControlhorizonSliderLabel.FontWeight = 'bold';
            app.ControlhorizonSliderLabel.Layout.Row = 3;
            app.ControlhorizonSliderLabel.Layout.Column = 1;
            app.ControlhorizonSliderLabel.Text = 'Control horizon';

            % Create ControlhorizonSlider
            app.ControlhorizonSlider = uislider(app.GridLayout3);
            app.ControlhorizonSlider.Limits = [1 6];
            app.ControlhorizonSlider.MajorTicks = [1 2 3 4 5 6];
            app.ControlhorizonSlider.MajorTickLabels = {'1', '2', '3', '4', '5', '6'};
            app.ControlhorizonSlider.ValueChangedFcn = createCallbackFcn(app, @ControlhorizonSliderValueChanged, true);
            app.ControlhorizonSlider.MinorTicks = [1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4 4.1 4.2 4.3 4.4 4.5 4.6 4.7 4.8 4.9 5 5.1 5.2 5.3 5.4 5.5 5.6 5.7 5.8 5.9 6];
            app.ControlhorizonSlider.FontSize = 14;
            app.ControlhorizonSlider.FontWeight = 'bold';
            app.ControlhorizonSlider.Layout.Row = 3;
            app.ControlhorizonSlider.Layout.Column = 2;
            app.ControlhorizonSlider.Value = 1;

            % Create Weightingpower10pSliderLabel
            app.Weightingpower10pSliderLabel = uilabel(app.GridLayout3);
            app.Weightingpower10pSliderLabel.HorizontalAlignment = 'right';
            app.Weightingpower10pSliderLabel.WordWrap = 'on';
            app.Weightingpower10pSliderLabel.FontSize = 14;
            app.Weightingpower10pSliderLabel.FontWeight = 'bold';
            app.Weightingpower10pSliderLabel.Layout.Row = 4;
            app.Weightingpower10pSliderLabel.Layout.Column = 1;
            app.Weightingpower10pSliderLabel.Text = 'Weighting power (10^p)';

            % Create Weightingpower10pSlider
            app.Weightingpower10pSlider = uislider(app.GridLayout3);
            app.Weightingpower10pSlider.Limits = [-3 3];
            app.Weightingpower10pSlider.ValueChangedFcn = createCallbackFcn(app, @Weightingpower10pSliderValueChanged, true);
            app.Weightingpower10pSlider.MinorTicks = [0 1 2 3 4 5 6 7 8 9 10];
            app.Weightingpower10pSlider.FontWeight = 'bold';
            app.Weightingpower10pSlider.Layout.Row = 4;
            app.Weightingpower10pSlider.Layout.Column = 2;

            % Create TfilterpoleSliderLabel
            app.TfilterpoleSliderLabel = uilabel(app.GridLayout3);
            app.TfilterpoleSliderLabel.HorizontalAlignment = 'right';
            app.TfilterpoleSliderLabel.FontSize = 14;
            app.TfilterpoleSliderLabel.FontWeight = 'bold';
            app.TfilterpoleSliderLabel.Layout.Row = 5;
            app.TfilterpoleSliderLabel.Layout.Column = 1;
            app.TfilterpoleSliderLabel.Text = 'T-filter pole';

            % Create TfilterpoleSlider
            app.TfilterpoleSlider = uislider(app.GridLayout3);
            app.TfilterpoleSlider.Limits = [0 1];
            app.TfilterpoleSlider.MajorTicks = [0 0.2 0.4 0.6 0.8 1];
            app.TfilterpoleSlider.ValueChangedFcn = createCallbackFcn(app, @TfilterpoleSliderValueChanged, true);
            app.TfilterpoleSlider.Step = 0.1;
            app.TfilterpoleSlider.FontSize = 14;
            app.TfilterpoleSlider.FontWeight = 'bold';
            app.TfilterpoleSlider.Layout.Row = 5;
            app.TfilterpoleSlider.Layout.Column = 2;
            app.TfilterpoleSlider.Value = 0.8;

            % Create TfilterorderSliderLabel
            app.TfilterorderSliderLabel = uilabel(app.GridLayout3);
            app.TfilterorderSliderLabel.HorizontalAlignment = 'right';
            app.TfilterorderSliderLabel.FontSize = 14;
            app.TfilterorderSliderLabel.FontWeight = 'bold';
            app.TfilterorderSliderLabel.Layout.Row = 6;
            app.TfilterorderSliderLabel.Layout.Column = 1;
            app.TfilterorderSliderLabel.Text = 'T-filter order';

            % Create TfilterorderSlider
            app.TfilterorderSlider = uislider(app.GridLayout3);
            app.TfilterorderSlider.Limits = [1 3];
            app.TfilterorderSlider.MajorTicks = [1 2 3];
            app.TfilterorderSlider.MajorTickLabels = {'1', '2', '3'};
            app.TfilterorderSlider.ValueChangedFcn = createCallbackFcn(app, @TfilterorderSliderValueChanged, true);
            app.TfilterorderSlider.MinorTicks = [1 2 3];
            app.TfilterorderSlider.Step = 1;
            app.TfilterorderSlider.FontSize = 14;
            app.TfilterorderSlider.FontWeight = 'bold';
            app.TfilterorderSlider.Layout.Row = 6;
            app.TfilterorderSlider.Layout.Column = 2;
            app.TfilterorderSlider.Value = 1;

            % Create NoisevarianceSliderLabel
            app.NoisevarianceSliderLabel = uilabel(app.GridLayout3);
            app.NoisevarianceSliderLabel.HorizontalAlignment = 'right';
            app.NoisevarianceSliderLabel.WordWrap = 'on';
            app.NoisevarianceSliderLabel.FontSize = 14;
            app.NoisevarianceSliderLabel.FontWeight = 'bold';
            app.NoisevarianceSliderLabel.Layout.Row = 7;
            app.NoisevarianceSliderLabel.Layout.Column = 1;
            app.NoisevarianceSliderLabel.Text = 'Noise variance';

            % Create NoisevarianceSlider
            app.NoisevarianceSlider = uislider(app.GridLayout3);
            app.NoisevarianceSlider.Limits = [0 0.1];
            app.NoisevarianceSlider.ValueChangedFcn = createCallbackFcn(app, @NoisevarianceSliderValueChanged, true);
            app.NoisevarianceSlider.Step = 0.01;
            app.NoisevarianceSlider.FontSize = 14;
            app.NoisevarianceSlider.FontWeight = 'bold';
            app.NoisevarianceSlider.Layout.Row = 7;
            app.NoisevarianceSlider.Layout.Column = 2;

            % Create GridLayout3_2
            app.GridLayout3_2 = uigridlayout(app.GridLayout8);
            app.GridLayout3_2.ColumnWidth = {'0.4x', '1x'};
            app.GridLayout3_2.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout3_2.Layout.Row = 2;
            app.GridLayout3_2.Layout.Column = 1;
            app.GridLayout3_2.BackgroundColor = [0.902 1 0.502];

            % Create ConstraintsLabel
            app.ConstraintsLabel = uilabel(app.GridLayout3_2);
            app.ConstraintsLabel.BackgroundColor = [1 1 0];
            app.ConstraintsLabel.HorizontalAlignment = 'center';
            app.ConstraintsLabel.FontSize = 24;
            app.ConstraintsLabel.FontWeight = 'bold';
            app.ConstraintsLabel.Layout.Row = 1;
            app.ConstraintsLabel.Layout.Column = [1 2];
            app.ConstraintsLabel.Text = 'Constraints';

            % Create AbsoluteinputSliderLabel
            app.AbsoluteinputSliderLabel = uilabel(app.GridLayout3_2);
            app.AbsoluteinputSliderLabel.HorizontalAlignment = 'right';
            app.AbsoluteinputSliderLabel.WordWrap = 'on';
            app.AbsoluteinputSliderLabel.FontSize = 14;
            app.AbsoluteinputSliderLabel.FontWeight = 'bold';
            app.AbsoluteinputSliderLabel.Layout.Row = 3;
            app.AbsoluteinputSliderLabel.Layout.Column = 1;
            app.AbsoluteinputSliderLabel.Text = 'Absolute input';

            % Create AbsoluteinputSlider
            app.AbsoluteinputSlider = uislider(app.GridLayout3_2, 'range');
            app.AbsoluteinputSlider.Limits = [-2 2];
            app.AbsoluteinputSlider.ValueChangedFcn = createCallbackFcn(app, @AbsoluteinputSliderValueChanged, true);
            app.AbsoluteinputSlider.Step = 0.1;
            app.AbsoluteinputSlider.Layout.Row = 3;
            app.AbsoluteinputSlider.Layout.Column = 2;
            app.AbsoluteinputSlider.Value = [-1 1.5];

            % Create OutputlimitsSliderLabel
            app.OutputlimitsSliderLabel = uilabel(app.GridLayout3_2);
            app.OutputlimitsSliderLabel.HorizontalAlignment = 'right';
            app.OutputlimitsSliderLabel.WordWrap = 'on';
            app.OutputlimitsSliderLabel.FontSize = 14;
            app.OutputlimitsSliderLabel.FontWeight = 'bold';
            app.OutputlimitsSliderLabel.Layout.Row = 4;
            app.OutputlimitsSliderLabel.Layout.Column = 1;
            app.OutputlimitsSliderLabel.Text = 'Output limits';

            % Create OutputlimitsSlider
            app.OutputlimitsSlider = uislider(app.GridLayout3_2, 'range');
            app.OutputlimitsSlider.Limits = [-1 1.5];
            app.OutputlimitsSlider.ValueChangedFcn = createCallbackFcn(app, @OutputlimitsSliderValueChanged, true);
            app.OutputlimitsSlider.Step = 0.1;
            app.OutputlimitsSlider.Layout.Row = 4;
            app.OutputlimitsSlider.Layout.Column = 2;
            app.OutputlimitsSlider.Value = [-0.2 1.3];

            % Create InputratesSliderLabel
            app.InputratesSliderLabel = uilabel(app.GridLayout3_2);
            app.InputratesSliderLabel.HorizontalAlignment = 'right';
            app.InputratesSliderLabel.WordWrap = 'on';
            app.InputratesSliderLabel.FontSize = 14;
            app.InputratesSliderLabel.Layout.Row = 2;
            app.InputratesSliderLabel.Layout.Column = 1;
            app.InputratesSliderLabel.Text = 'Input rates';

            % Create InputratesSlider
            app.InputratesSlider = uislider(app.GridLayout3_2);
            app.InputratesSlider.Limits = [0 1];
            app.InputratesSlider.MajorTicks = [0 0.2 0.4 0.6 0.8 1];
            app.InputratesSlider.ValueChangedFcn = createCallbackFcn(app, @InputratesSliderValueChanged, true);
            app.InputratesSlider.Step = 0.1;
            app.InputratesSlider.FontSize = 14;
            app.InputratesSlider.Layout.Row = 2;
            app.InputratesSlider.Layout.Column = 2;
            app.InputratesSlider.Value = 0.8;

            % Create GridLayout10_2
            app.GridLayout10_2 = uigridlayout(app.GridLayout10);
            app.GridLayout10_2.ColumnWidth = {'1x'};
            app.GridLayout10_2.RowHeight = {'1.8x', '1x'};
            app.GridLayout10_2.Layout.Row = 1;
            app.GridLayout10_2.Layout.Column = 2;

            % Create GridLayout11
            app.GridLayout11 = uigridlayout(app.GridLayout10_2);
            app.GridLayout11.ColumnWidth = {'1x'};
            app.GridLayout11.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout11.Layout.Row = 2;
            app.GridLayout11.Layout.Column = 1;
            app.GridLayout11.BackgroundColor = [0.702 1 0.702];

            % Create OnoroffLabel
            app.OnoroffLabel = uilabel(app.GridLayout11);
            app.OnoroffLabel.BackgroundColor = [0 1 0];
            app.OnoroffLabel.HorizontalAlignment = 'center';
            app.OnoroffLabel.FontSize = 18;
            app.OnoroffLabel.FontWeight = 'bold';
            app.OnoroffLabel.Layout.Row = 1;
            app.OnoroffLabel.Layout.Column = 1;
            app.OnoroffLabel.Text = 'On or off';

            % Create RatesonButton
            app.RatesonButton = uibutton(app.GridLayout11, 'push');
            app.RatesonButton.ButtonPushedFcn = createCallbackFcn(app, @RatesonButtonPushed, true);
            app.RatesonButton.BackgroundColor = [0.2 0.702 0.2];
            app.RatesonButton.FontSize = 14;
            app.RatesonButton.FontWeight = 'bold';
            app.RatesonButton.Layout.Row = 2;
            app.RatesonButton.Layout.Column = 1;
            app.RatesonButton.Text = 'Rates on';

            % Create AbsoluteonButton
            app.AbsoluteonButton = uibutton(app.GridLayout11, 'push');
            app.AbsoluteonButton.ButtonPushedFcn = createCallbackFcn(app, @AbsoluteonButtonPushed, true);
            app.AbsoluteonButton.BackgroundColor = [0.2 0.702 0.2];
            app.AbsoluteonButton.FontSize = 14;
            app.AbsoluteonButton.FontWeight = 'bold';
            app.AbsoluteonButton.Layout.Row = 3;
            app.AbsoluteonButton.Layout.Column = 1;
            app.AbsoluteonButton.Text = 'Absolute on';

            % Create OutputonButton
            app.OutputonButton = uibutton(app.GridLayout11, 'push');
            app.OutputonButton.ButtonPushedFcn = createCallbackFcn(app, @OutputonButtonPushed, true);
            app.OutputonButton.BackgroundColor = [0.2 0.702 0.2];
            app.OutputonButton.FontSize = 14;
            app.OutputonButton.FontWeight = 'bold';
            app.OutputonButton.Layout.Row = 4;
            app.OutputonButton.Layout.Column = 1;
            app.OutputonButton.Text = 'Output on';

            % Create GridLayout7_2
            app.GridLayout7_2 = uigridlayout(app.GridLayout10_2);
            app.GridLayout7_2.ColumnWidth = {'0.7x'};
            app.GridLayout7_2.RowHeight = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout7_2.Layout.Row = 1;
            app.GridLayout7_2.Layout.Column = 1;
            app.GridLayout7_2.BackgroundColor = [0.702 1 0.702];

            % Create ChoicesLabel
            app.ChoicesLabel = uilabel(app.GridLayout7_2);
            app.ChoicesLabel.BackgroundColor = [0 1 0];
            app.ChoicesLabel.HorizontalAlignment = 'center';
            app.ChoicesLabel.FontSize = 24;
            app.ChoicesLabel.FontWeight = 'bold';
            app.ChoicesLabel.FontColor = [0.1294 0.1294 0.1294];
            app.ChoicesLabel.Layout.Row = 1;
            app.ChoicesLabel.Layout.Column = 1;
            app.ChoicesLabel.Text = 'Choices';

            % Create ModelDropDownLabel
            app.ModelDropDownLabel = uilabel(app.GridLayout7_2);
            app.ModelDropDownLabel.HorizontalAlignment = 'center';
            app.ModelDropDownLabel.WordWrap = 'on';
            app.ModelDropDownLabel.FontSize = 18;
            app.ModelDropDownLabel.Layout.Row = 2;
            app.ModelDropDownLabel.Layout.Column = 1;
            app.ModelDropDownLabel.Text = 'Model';

            % Create ModelDropDown
            app.ModelDropDown = uidropdown(app.GridLayout7_2);
            app.ModelDropDown.Items = {'1st order', '2nd order', '3rd order'};
            app.ModelDropDown.FontSize = 18;
            app.ModelDropDown.Layout.Row = 3;
            app.ModelDropDown.Layout.Column = 1;
            app.ModelDropDown.Value = '1st order';

            % Create DisturbanceDropDownLabel
            app.DisturbanceDropDownLabel = uilabel(app.GridLayout7_2);
            app.DisturbanceDropDownLabel.HorizontalAlignment = 'center';
            app.DisturbanceDropDownLabel.WordWrap = 'on';
            app.DisturbanceDropDownLabel.FontSize = 18;
            app.DisturbanceDropDownLabel.Layout.Row = 4;
            app.DisturbanceDropDownLabel.Layout.Column = 1;
            app.DisturbanceDropDownLabel.Text = 'Disturbance';

            % Create DisturbanceDropDown
            app.DisturbanceDropDown = uidropdown(app.GridLayout7_2);
            app.DisturbanceDropDown.Items = {'yes', 'no'};
            app.DisturbanceDropDown.FontSize = 18;
            app.DisturbanceDropDown.Layout.Row = 5;
            app.DisturbanceDropDown.Layout.Column = 1;
            app.DisturbanceDropDown.Value = 'no';

            % Create HistoryinformationTab
            app.HistoryinformationTab = uitab(app.TabGroup);
            app.HistoryinformationTab.Title = 'History information';

            % Create GridLayout13
            app.GridLayout13 = uigridlayout(app.HistoryinformationTab);
            app.GridLayout13.ColumnWidth = {'0.15x', '1x'};
            app.GridLayout13.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};

            % Create Plot1EditFieldLabel
            app.Plot1EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot1EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot1EditFieldLabel.FontSize = 14;
            app.Plot1EditFieldLabel.FontWeight = 'bold';
            app.Plot1EditFieldLabel.Layout.Row = 1;
            app.Plot1EditFieldLabel.Layout.Column = 1;
            app.Plot1EditFieldLabel.Text = 'Plot 1';

            % Create Plot1EditField
            app.Plot1EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot1EditField.FontSize = 10;
            app.Plot1EditField.Layout.Row = 1;
            app.Plot1EditField.Layout.Column = 2;
            app.Plot1EditField.Value = 'TBC';

            % Create Plot2EditFieldLabel
            app.Plot2EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot2EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot2EditFieldLabel.FontSize = 14;
            app.Plot2EditFieldLabel.FontWeight = 'bold';
            app.Plot2EditFieldLabel.Layout.Row = 2;
            app.Plot2EditFieldLabel.Layout.Column = 1;
            app.Plot2EditFieldLabel.Text = 'Plot 2';

            % Create Plot2EditField
            app.Plot2EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot2EditField.FontSize = 10;
            app.Plot2EditField.Layout.Row = 2;
            app.Plot2EditField.Layout.Column = 2;
            app.Plot2EditField.Value = 'TBC';

            % Create Plot3EditFieldLabel
            app.Plot3EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot3EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot3EditFieldLabel.FontSize = 14;
            app.Plot3EditFieldLabel.FontWeight = 'bold';
            app.Plot3EditFieldLabel.Layout.Row = 3;
            app.Plot3EditFieldLabel.Layout.Column = 1;
            app.Plot3EditFieldLabel.Text = 'Plot 3';

            % Create Plot3EditField
            app.Plot3EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot3EditField.FontSize = 10;
            app.Plot3EditField.Layout.Row = 3;
            app.Plot3EditField.Layout.Column = 2;
            app.Plot3EditField.Value = 'TBC';

            % Create Plot4EditFieldLabel
            app.Plot4EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot4EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot4EditFieldLabel.FontSize = 14;
            app.Plot4EditFieldLabel.FontWeight = 'bold';
            app.Plot4EditFieldLabel.Layout.Row = 4;
            app.Plot4EditFieldLabel.Layout.Column = 1;
            app.Plot4EditFieldLabel.Text = 'Plot 4';

            % Create Plot4EditField
            app.Plot4EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot4EditField.FontSize = 10;
            app.Plot4EditField.Layout.Row = 4;
            app.Plot4EditField.Layout.Column = 2;
            app.Plot4EditField.Value = 'TBC';

            % Create Plot5EditFieldLabel
            app.Plot5EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot5EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot5EditFieldLabel.FontSize = 14;
            app.Plot5EditFieldLabel.FontWeight = 'bold';
            app.Plot5EditFieldLabel.Layout.Row = 5;
            app.Plot5EditFieldLabel.Layout.Column = 1;
            app.Plot5EditFieldLabel.Text = 'Plot 5';

            % Create Plot5EditField
            app.Plot5EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot5EditField.FontSize = 10;
            app.Plot5EditField.Layout.Row = 5;
            app.Plot5EditField.Layout.Column = 2;
            app.Plot5EditField.Value = 'TBC';

            % Create Plot6EditFieldLabel
            app.Plot6EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot6EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot6EditFieldLabel.FontSize = 14;
            app.Plot6EditFieldLabel.FontWeight = 'bold';
            app.Plot6EditFieldLabel.Layout.Row = 6;
            app.Plot6EditFieldLabel.Layout.Column = 1;
            app.Plot6EditFieldLabel.Text = 'Plot 6';

            % Create Plot6EditField
            app.Plot6EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot6EditField.FontSize = 10;
            app.Plot6EditField.Layout.Row = 6;
            app.Plot6EditField.Layout.Column = 2;
            app.Plot6EditField.Value = 'TBC';

            % Create Plot7EditFieldLabel
            app.Plot7EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot7EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot7EditFieldLabel.FontSize = 14;
            app.Plot7EditFieldLabel.FontWeight = 'bold';
            app.Plot7EditFieldLabel.Layout.Row = 7;
            app.Plot7EditFieldLabel.Layout.Column = 1;
            app.Plot7EditFieldLabel.Text = 'Plot 7';

            % Create Plot7EditField
            app.Plot7EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot7EditField.FontSize = 10;
            app.Plot7EditField.Layout.Row = 7;
            app.Plot7EditField.Layout.Column = 2;
            app.Plot7EditField.Value = 'TBC';

            % Create Plot8EditFieldLabel
            app.Plot8EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot8EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot8EditFieldLabel.FontSize = 14;
            app.Plot8EditFieldLabel.FontWeight = 'bold';
            app.Plot8EditFieldLabel.Layout.Row = 8;
            app.Plot8EditFieldLabel.Layout.Column = 1;
            app.Plot8EditFieldLabel.Text = 'Plot 8';

            % Create Plot8EditField
            app.Plot8EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot8EditField.FontSize = 10;
            app.Plot8EditField.Layout.Row = 8;
            app.Plot8EditField.Layout.Column = 2;
            app.Plot8EditField.Value = 'TBC';

            % Create Plot9EditFieldLabel
            app.Plot9EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot9EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot9EditFieldLabel.FontSize = 14;
            app.Plot9EditFieldLabel.FontWeight = 'bold';
            app.Plot9EditFieldLabel.Layout.Row = 9;
            app.Plot9EditFieldLabel.Layout.Column = 1;
            app.Plot9EditFieldLabel.Text = 'Plot 9';

            % Create Plot9EditField
            app.Plot9EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot9EditField.FontSize = 10;
            app.Plot9EditField.Layout.Row = 9;
            app.Plot9EditField.Layout.Column = 2;
            app.Plot9EditField.Value = 'TBC';

            % Create Plot10EditFieldLabel
            app.Plot10EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot10EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot10EditFieldLabel.FontSize = 14;
            app.Plot10EditFieldLabel.FontWeight = 'bold';
            app.Plot10EditFieldLabel.Layout.Row = 10;
            app.Plot10EditFieldLabel.Layout.Column = 1;
            app.Plot10EditFieldLabel.Text = 'Plot 10';

            % Create Plot10EditField
            app.Plot10EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot10EditField.FontSize = 10;
            app.Plot10EditField.Layout.Row = 10;
            app.Plot10EditField.Layout.Column = 2;
            app.Plot10EditField.Value = 'TBC';

            % Create Plot11EditFieldLabel
            app.Plot11EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot11EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot11EditFieldLabel.FontSize = 14;
            app.Plot11EditFieldLabel.FontWeight = 'bold';
            app.Plot11EditFieldLabel.Layout.Row = 11;
            app.Plot11EditFieldLabel.Layout.Column = 1;
            app.Plot11EditFieldLabel.Text = 'Plot 11';

            % Create Plot11EditField
            app.Plot11EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot11EditField.FontSize = 10;
            app.Plot11EditField.Layout.Row = 11;
            app.Plot11EditField.Layout.Column = 2;
            app.Plot11EditField.Value = 'TBC';

            % Create CurrentplotsonlyTab
            app.CurrentplotsonlyTab = uitab(app.TabGroup);
            app.CurrentplotsonlyTab.Title = 'Current plots only';

            % Create GridLayout14
            app.GridLayout14 = uigridlayout(app.CurrentplotsonlyTab);

            % Create UIAxes5
            app.UIAxes5 = uiaxes(app.GridLayout14);
            title(app.UIAxes5, 'Output and constraints')
            xlabel(app.UIAxes5, 'X')
            ylabel(app.UIAxes5, 'Y')
            zlabel(app.UIAxes5, 'Z')
            app.UIAxes5.Layout.Row = 1;
            app.UIAxes5.Layout.Column = 1;

            % Create UIAxes6
            app.UIAxes6 = uiaxes(app.GridLayout14);
            title(app.UIAxes6, 'Input rate and constraints')
            xlabel(app.UIAxes6, 'X')
            ylabel(app.UIAxes6, 'Y')
            zlabel(app.UIAxes6, 'Z')
            app.UIAxes6.Layout.Row = 1;
            app.UIAxes6.Layout.Column = 2;

            % Create UIAxes7
            app.UIAxes7 = uiaxes(app.GridLayout14);
            title(app.UIAxes7, 'Input and constraints')
            xlabel(app.UIAxes7, 'X')
            ylabel(app.UIAxes7, 'Y')
            zlabel(app.UIAxes7, 'Z')
            app.UIAxes7.Layout.Row = 2;
            app.UIAxes7.Layout.Column = 1;

            % Create UIAxes8
            app.UIAxes8 = uiaxes(app.GridLayout14);
            title(app.UIAxes8, 'Disturbance')
            xlabel(app.UIAxes8, 'X')
            ylabel(app.UIAxes8, 'Y')
            zlabel(app.UIAxes8, 'Z')
            app.UIAxes8.Layout.Row = 2;
            app.UIAxes8.Layout.Column = 2;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = mpcconstraints_lab_control101

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end

