classdef tanklevel_story < matlab.apps.AppBase
    %TANKLEVEL_STORY
    %   File written by J.A.Rossiter, University of Sheffield  
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   
    %   A simple interface to practice behaviour of a simple tank level
    %   model subject to inflow, disturbance in flow and outlet blockages.
    %   
    %   Some notes and engineering background are in the partner
    %   livescript file:    tanlelvelbehaviour_manual.mlx
    %   A group of similar files can be downloaded through MATLAB
    %   add-ons with the toolbox name:  control101
    %     
    %      
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   %%%%%%%%%%%%  FILE ORGANISATION
    %   A section defining the core variables stored in "app"
    %   
    %       A section with subfunctions doing the core computations
    %       i) define behaviour models; 
    %       ii) find linear responses to inputs and disturbances; 
    %       iii) initialise figures for animations and analysis; 
    %       iv) control the animations
    %       v) switch interaction on and off during animations
    %       vi) clean figures and legends so can begin a new investigation
    %       vii) callbacks (subfunctions) for every item in the interface
    %   to control decimal places and the like.
    %       
    %       A callback which activates with the 'start simulation' button
    %   and runs the subfunctions in turn.

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        TabGroup                       matlab.ui.container.TabGroup
        OpenloopbehaviourTab           matlab.ui.container.Tab
        GridLayout7                    matlab.ui.container.GridLayout
        Label_5                        matlab.ui.control.Label
        Label_4                        matlab.ui.control.Label
        Label_3                        matlab.ui.control.Label
        OutletblockageDropDown         matlab.ui.control.DropDown
        OutletblockageDropDownLabel    matlab.ui.control.Label
        Label                          matlab.ui.control.Label
        DisturbanceflowDropDown        matlab.ui.control.DropDown
        DisturbanceflowDropDownLabel   matlab.ui.control.Label
        ModellingTab                   matlab.ui.container.Tab
        GridLayout8                    matlab.ui.container.GridLayout
        EditField_2                    matlab.ui.control.NumericEditField
        EditField                      matlab.ui.control.NumericEditField
        SystemGainLabel                matlab.ui.control.Label
        TimeconstantLabel              matlab.ui.control.Label
        Label_2                        matlab.ui.control.Label
        UIAxes3                        matlab.ui.control.UIAxes
        ManualcontrolTab               matlab.ui.container.Tab
        GridLayout10                   matlab.ui.container.GridLayout
        SetinputflowSlider             matlab.ui.control.Slider
        SetinputflowSliderLabel        matlab.ui.control.Label
        PausesimulationButton          matlab.ui.control.Button
        IncludingblockagesButton       matlab.ui.control.Button
        IncludingdisturbancesButton    matlab.ui.control.Button
        StartsimulationButton          matlab.ui.control.Button
        Label_6                        matlab.ui.control.Label
        Label2                         matlab.ui.control.Label
        MovethesliderbelowtochangetheinletflowrateLabel  matlab.ui.control.Label
        PIdesignTab                    matlab.ui.container.Tab
        GridLayout9                    matlab.ui.container.GridLayout
        Label_9                        matlab.ui.control.Label
        Label_8                        matlab.ui.control.Label
        Label_7                        matlab.ui.control.Label
        IntegralgainKiSlider           matlab.ui.control.Slider
        IntegralgainKiSliderLabel      matlab.ui.control.Label
        ProportionalgainKpSlider       matlab.ui.control.Slider
        ProportionalgainKpSliderLabel  matlab.ui.control.Label
        ControlParametersLabel         matlab.ui.control.Label
        ControlwithuncertaintyTab      matlab.ui.container.Tab
        GridLayout11                   matlab.ui.container.GridLayout
        Label_15                       matlab.ui.control.Label
        IncludingmeasurementdelayButton  matlab.ui.control.Button
        IncludingmeasurementnoiseButton  matlab.ui.control.Button
        IncludingblockagesButton_2     matlab.ui.control.Button
        IncludingdisturbancesButton_2  matlab.ui.control.Button
        Label_14                       matlab.ui.control.Label
        StartButton                    matlab.ui.control.Button
        Label_13                       matlab.ui.control.Label
        Label_12                       matlab.ui.control.Label
        Label_10                       matlab.ui.control.Label
        GridLayout6                    matlab.ui.container.GridLayout
        OutletpipeblockageSlider       matlab.ui.control.Slider
        OutletpipeblockageSliderLabel  matlab.ui.control.Label
        Disturbanceflowm3sSlider       matlab.ui.control.Slider
        Disturbanceflowm3sSliderLabel  matlab.ui.control.Label
        EnvironmentparametersLabel     matlab.ui.control.Label
        GridLayout4                    matlab.ui.container.GridLayout
        Flowinm3sSlider                matlab.ui.control.Slider
        Flowinm3sSliderLabel           matlab.ui.control.Label
        TankparametersAdhdtRhfinLabel  matlab.ui.control.Label
        Rm2sSlider                     matlab.ui.control.Slider
        Rm2sSliderLabel                matlab.ui.control.Label
        Aream2Slider                   matlab.ui.control.Slider
        Aream2SliderLabel              matlab.ui.control.Label
        GridLayout3                    matlab.ui.container.GridLayout
        AnimationOnButton              matlab.ui.control.Button
        RefreshButton                  matlab.ui.control.Button
        SimulateButton                 matlab.ui.control.Button
        GridLayout2                    matlab.ui.container.GridLayout
        Image                          matlab.ui.control.Image
        ModellingandcontroloftanklevelLabel  matlab.ui.control.Label
        UIAxes                         matlab.ui.control.UIAxes
        UIAxes2                        matlab.ui.control.UIAxes
        UIAxes4                        matlab.ui.control.UIAxes
    end

    % File written by J.A.Rossiter, University of Sheffield
    % See website for more files like this.
    % https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    % A simple interface to practice behaviour of a simple tank level model 
    % subject to changes in in flow, disturbance flow and outlet blockage
    % 
    % Some notes and engineering background are in the partner livescript
    % file:    tanklevelbehaviour_manual.mlx
    % A group of similar files can be downloaded through MATLAB add-ons
    % with the toolbox name:  ********************
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%  FILE ORGANISATION
    % A section defining the core variables stored in "app"
    %
    % A section with subfunctions doing the core computations
    % i) define behaviour models; 
    % ii) find linear responses to inputs and disturbances; 
    % iii) initialise figures for animations and analysis; 
    % iv) control the animations
    % v) switch interaction on and off during animations
    % vi) clean figures and legends so can begin a new investigation
    % vii) callbacks (subfunctions) for every item in the interface to control decimal
    % places and the like.
    % 
    % A callback which activates with the 'start simulation' button
    % and runs the subfunctions in turn.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % The next section defines all the core variables used in the code 
    % that it may be convenient to have available in the various
    % subfunctions
    properties (Access = private)

        originalsize     % product of width and height for font sizing


        legstring=cell(1); % To store legends
        A;     % tank area
        R;     % conductance of outflow pipe
        Rblock % effective R with blockage
        flow;  % inlet flow
        block  % to represent blockage component
        blockvalue % precentage blockage
        dist   % magnitude of disturbance in flow

        flowin
        flowinu % handle for input flow
        tankfill % blue colour to show depth in tank
        outfill  % outlet pipe colour
        disturbanceflow;  % additional unexpected flow in
        flowinbottom; % handle for disturbance flow

        include_dist=1 % for use during manual control
        include_blockage=1 % for use during manual control
        pause = true;  % for use during manual and uncertainty control
        changingu =0;

        include_dist2=1 % for use during uncertainty control
        include_blockage2=1 % for use during uncertainty control
        include_noise =1;
        include_delay =1;
              
        
        runtime = 50; % for simulation the runtime
        time;  % variable to store time instants for simulation plots
        samples = 201;
        animationtime = 6; % how long animation will take
        Tsamp_anim=0.1;  % update rate for animation

        G;   % system transfer function (input to output)
        Gb;   % system transfer function with blockage
        Tsample =0.2 % discrete sample time
        Gdis % Discretised model
        Gbdis % discretised model with blockage
        
        yr;  % output step response to in flow
        yplot % handle for animation of line plots
        Gss; % steady-state value for given inflow
        Gssb % steady-state value with a blockage

        steadylineplot;  % needed, especially if a square wave
        ytotal; % sum of all output components
        utotal; % sum of all input components
        u  % basic inflow
        blocksave % memory of the blockage
        distsave  % memory of the disturbance
        target = 5; % for control parts
        targetline1 % handle for figure
        targetline2 % for output plots
        targetline3 % for input plots
        

        
    end
    
    methods (Access = private)
        


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  PLOT OF TOP FIGURE - THE CAR ANIMATION
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 function app = createtankoutline(app)

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Set up basic picture of the tank in the top plot
     
        % tank parameters and initial plot
        app.A=app.Aream2Slider.Value;
        app.R=app.Rm2sSlider.Value;
        app.flow = app.Flowinm3sSlider.Value;
        dist = app.Disturbanceflowm3sSlider.Value;
        A=app.A;
        R=app.R;
        depth = 0.3;
        
        % Tank outline and initial depth close to zero
        hold(app.UIAxes,'off')
        x2 = [0:11]; y2 = x2; 
        plot(app.UIAxes,x2,x2,'w');
        hold(app.UIAxes,'on')
        x=[0.5,0.5,0.5+A,0.5+A,1.5+A];
        x3 = [1.5+A,0.5+A,0.5+A];
        y=[10,1,1,1.02,1.02];
        y3 = [1.02+3*R,1.02+3*R,10];
        plot(app.UIAxes,x,y,'k-','linewidth',4);
        plot(app.UIAxes,x3,y3,'k-','linewidth',4);
        
        % outlet pipe fill
        xout = [0.5+A,0.5+A,1.5+A,1.7+A,1.8+A,1.5+A];
        yout = [1,1+3*R,1+3*R,1+2.5*R,0.9,1];
        app.outfill=fill(app.UIAxes,[xout],[yout],'b');
        
        % main tank fill
        xtankfill=[0.5,0.5,0.5+A,0.5+A];
        ytankfill=[1,1+depth,1+depth,1];
        app.tankfill=fill(app.UIAxes,[xtankfill],[ytankfill],'b');
        
                                
        % Disturbance in flow component
        xpipein = [1.5+app.A,0.4+app.A];
        ypipein = [10.4,10.4];
        xflowin1 = [1.5+app.A,0.4+app.A,0.4+app.A,1.5+app.A];
        yflowin1 = [10.4,10.4,10.8,10.8];
        xflowin2 = [0.1+app.A,0.1+app.A,0.4+app.A,0.4+app.A]; %% Use A as x distance
        yflowin2 = [10.5-dist*2,10.5+dist*2,10.8,10.4];
        pipein=plot(app.UIAxes,xpipein,ypipein,'k','linewidth',4);
        pipein2=plot(app.UIAxes,xpipein,ypipein+0.4,'k','linewidth',4);
        flowintop = fill(app.UIAxes,xflowin1,yflowin1,'b');
        app.flowinbottom = fill(app.UIAxes,xflowin2,yflowin2,'b');
        text(app.UIAxes,0.8+app.A,9.8,'Disturbance flow','fontsize',16)

        % main input flow from pipe above tank
        vertpipeinx1 = [0.3+app.A/2,0.3+app.A/2];
        vertpipeinx2 = [0.7+app.A/2,0.7+app.A/2];
        vertpipeiny1 = [11,12];
        plot(app.UIAxes,vertpipeinx1,vertpipeiny1,'k','linewidth',5);
        plot(app.UIAxes,vertpipeinx2,vertpipeiny1,'k','linewidth',5);
        fill(app.UIAxes,[vertpipeinx1,vertpipeinx2],...
            [vertpipeiny1,fliplr(vertpipeiny1)],'b');
        flowinux=[.3+app.A/2,0.3+app.A/2-app.flow*1.2,0.7+app.A/2+app.flow*1.2,0.7+app.A/2];
        flowinuy=[11,10,10,11];
        app.flowinu=fill(app.UIAxes,[flowinux],flowinuy,'b');
        text(app.UIAxes,0.8+app.A/2,11.5,'Main in-flow','fontsize',16)

        % Define the blockage shape       
        % define height to cover relevant % of the outlet
        gap = 3*R*(100-app.OutletpipeblockageSlider.Value)/100;
        x3=1.5+app.A; % right position of tank
        blockx=[x3+0.8,x3-0.05,x3-0.05,x3+0.8];
        blocky=[1+gap,1+gap,3+gap,3+gap];
        app.block=fill(app.UIAxes,blockx,blocky,'r');
        text(app.UIAxes,x3,0.4,'Blockage','fontsize',16)
        
        % target line in output plot
        app.targetline1 = plot(app.UIAxes,[0,2+A],[1,1]*(1+app.target),'g--','linewidth',2);
                    
    end      %%% END OF TANKOUTLINE SUBFUNCTION

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  Down load data from sliders and create models and responses
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function app = createmodels(app)

            % Collect values from sliders and ensure rounded sensibly
            app.A=app.Aream2Slider.Value;
            app.R=app.Rm2sSlider.Value;
            app.flow=app.Flowinm3sSlider.Value;
            app.blockvalue=app.OutletpipeblockageSlider.Value;
            app.Rblock=app.R*(100-app.blockvalue)/100; % effective R
            app.dist=app.Disturbanceflowm3sSlider.Value;
            app.runtime=round(app.A/app.Rblock,0)*4;

            % define transfer functions
            % y = G*flowin + G*dist  NO BLOCKAGE
            % y = Gd*flowin + Gd*dist  with BLOCKAGE
            app.G=tf(1,[app.A,app.R]);    % tank model
            app.Gb=tf(1,[app.A,app.Rblock]);  % with blockage
            % Discretise
            app.Gdis = c2d(app.G,app.Tsample);
            app.Gbdis=c2d(app.Gb,app.Tsample);  % with blockage
                      
            % properties
            app.Gss = dcgain(app.G)*app.flow;
            app.Gssb = dcgain(app.Gb)*app.flow;
            app.steadylineplot = ones(1,length(app.time))*app.Gss;
            app.time=linspace(0,app.runtime,app.samples);
 

        end   % end of create models subfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Manage the animation and legends
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        function app = animationoflineplots(app)
            
            
            %  Set up legend
            if isempty(app.legstring{1});
                nlegstring=1;
                app.targetline2=plot(app.UIAxes2,[0,app.runtime],[1 1]*app.target,'g--','linewidth',2);
                app.legstring{1} = 'Target depth';
                hold(app.UIAxes2,'on');
                
            else
                nlegstring = length(app.legstring);
            end
            switch app.TabGroup.SelectedTab.Title
                case 'PI design'
                app.legstring{nlegstring+1}=['A = ',num2str(app.A),...
                ', R = ',num2str(app.R),...
                ', Blockage (%) = ',num2str(app.blockvalue),...
                ', Disturbance = ',num2str(app.dist),...
                ', Kp = ',num2str(app.ProportionalgainKpSlider.Value),...
                ', Ki = ',num2str(app.IntegralgainKiSlider.Value)];

                otherwise
                app.legstring{nlegstring+1}=['A = ',num2str(app.A),...
                ', R = ',num2str(app.R),...
                ', Flow = ',num2str(app.flow), ...
                ', Blockage (%) = ',num2str(app.blockvalue),...
                ', Disturbance = ',num2str(app.dist)];
          

            end
            %T=round(app.A/app.R,2);
              
            % initialise figure for depth response
            yplot = plot(app.UIAxes2,app.time(1),app.ytotal(1));        
            xlabel(app.UIAxes2,'time (sec)')
            hold(app.UIAxes2,'on')
            xlim(app.UIAxes2,[0,app.runtime]);
            kk=legend(app.UIAxes2,app.legstring,'Location','southeast');
            set(kk,'fontsize',8);
            grid(app.UIAxes2,'on')
            
            hold(app.UIAxes4,'off')
            app.targetline3 = plot(app.UIAxes4,[0,app.runtime],[1 1]*app.target/dcgain(app.G),'g--','linewidth',2);
            hold(app.UIAxes4,'on');
            uplot = plot(app.UIAxes4,app.time(1),app.u(1));
            bb= app.blocksave*app.OutletpipeblockageSlider.Value/100; % blocksave has zeros and ones
            dd= app.distsave*app.Disturbanceflowm3sSlider.Value;  % distsave has zeros and ones
            dplot = plot(app.UIAxes4,app.time(1),dd(1));
            bplot = plot(app.UIAxes4,app.time(1),bb(1));
            xlim(app.UIAxes4,[0,app.runtime]);
            if max(app.u)>1;
                ylim(app.UIAxes4,'auto');
            else
                ylim(app.UIAxes4,[0,1]);
            end
            
            legend(app.UIAxes4,'Expected steady input','Input','Disturbance','Blockage')

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% animation of tank and level plot
            % define animation time aspects
            animationsamples = app.animationtime/app.Tsamp_anim; % assume sample time of Tsamp
            updaterate =ceil(app.samples/animationsamples); % no of samples between pauses
            tstart=tic; tsave = tstart;

            
            for k=1:length(app.time);
                     
                % update line plot and tank picture
                set(yplot,'Ydata',app.ytotal(1:k),'Xdata',app.time(1:k));
                set(uplot,'Ydata',app.u(1:k),'Xdata',app.time(1:k));
                
                set(dplot,'Ydata',dd(1:k),'Xdata',app.time(1:k));
                set(bplot,'Ydata',bb(1:k),'Xdata',app.time(1:k));
                ytankfill = [1,1+app.ytotal(k),1+app.ytotal(k),1];
                set(app.tankfill,'Ydata',[ytankfill]);
                flowinux=[.3+app.A/2,0.3+app.A/2-app.u(k)*0.4+0.2,...
                0.7+app.A/2+app.u(k)*0.4-0.2,0.7+app.A/2];
                set(app.flowinu,'XData',flowinux);

                
                % Pause animation every updaterate samples only so rem(k,updaterate) 
                % checks for this
                if and(strcmp(app.AnimationOnButton.Text,'Animation On'),not(rem(k,updaterate)));
                    pause(app.Tsamp_anim-toc(tstart));  %% Clumsy application of sampling time
                    tstart = tic;
                    drawnow limitrate
                end
                
            end
            %ttotal= toc(tsave)  % total time taken by animation loop
        end  % end of animation

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  Time constant and gain analysis
 %%%%%%%%%  Done assuming the blockage and disturbance are zero
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
        function app = timeconstantanalysis(app)
            
            % Compute nominal response        
            app.yr = step(app.G,app.time)*app.flow;
            app.u=ones(1,length(app.time))*app.flow;
            app.ytotal=app.yr;

            % create illustrative plots
            T=app.A/app.R;
            plot(app.UIAxes3,app.time,app.yr,'b');
            xlim(app.UIAxes3,[0,4*T])
            hold(app.UIAxes3,'on') ;
            plot(app.UIAxes3,[T,T],[0,app.Gss],'r-.','linewidth',3)
            plot(app.UIAxes3,[0,4*T],[app.Gss,app.Gss],'g-.','linewidth',3)
            kkk=legend(app.UIAxes3,'Depth','Time constant','Steady-state');
            set(kkk,'fontsize',10);
            text(app.UIAxes3,4*T/3,app.Gss/3,['T = ',num2str(T),', Steady-state = ',num2str(app.Gss)],'fontsize', 16);
            xlabel(app.UIAxes3,'time (sec)');
            grid(app.UIAxes3,'on');
            hold(app.UIAxes3,'off');
            
            % update parameter values in the tab
            app.EditField.Value = T;
            app.EditField_2.Value = dcgain(app.G);

            % No disturbances for simple modelling tab - set to zero
            k=length(app.time);
            app.distsave = zeros(1,k);
            app.blocksave = zeros(1,k);
            app.OutletpipeblockageSlider.Value=0;
            app.Disturbanceflowm3sSlider.Value=0;

            ylabel(app.UIAxes2,'Open-loop behaviour')
        end  % end of timeconstant and gain analysis figure



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Control interaction during the animation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function  disablebuttons(app)
            set(app.SimulateButton, 'Enable', 'off');
            set(app.RefreshButton, 'Enable', 'off');
            set(app.AnimationOnButton, 'Enable', 'off');
            set(app.OutletpipeblockageSlider, 'Enable', 'off');
            set(app.Disturbanceflowm3sSlider, 'Enable', 'off');
            set(app.Flowinm3sSlider, 'Enable', 'off');
            set(app.Rm2sSlider, 'Enable', 'off');
            set(app.Aream2Slider, 'Enable', 'off');
            set(app.DisturbanceflowDropDown,'Enable', 'off');
            set(app.OutletblockageDropDown,'Enable', 'off');
            set(app.ProportionalgainKpSlider,'Enable', 'off');
            set(app.IntegralgainKiSlider,'Enable', 'off');
        end
        
        function enablebuttons(app)
            set(app.SimulateButton, 'Enable', 'on');
            set(app.RefreshButton, 'Enable', 'on')
            set(app.AnimationOnButton, 'Enable', 'on')
            set(app.OutletpipeblockageSlider, 'Enable', 'on');
            set(app.Disturbanceflowm3sSlider, 'Enable', 'on');
            set(app.Flowinm3sSlider, 'Enable', 'on');
            set(app.Rm2sSlider, 'Enable', 'on');
            set(app.Aream2Slider, 'Enable', 'on');
            set(app.DisturbanceflowDropDown,'Enable', 'on');
            set(app.OutletblockageDropDown,'Enable', 'on');
            set(app.ProportionalgainKpSlider,'Enable', 'on');
            set(app.IntegralgainKiSlider,'Enable', 'on');
        end


        
        function app = openloopresponses(app)
            % Define the nominal step responses
            % Use discrete approximations as easiest way to handle
            % uncertainty

            % Models: Use N1,D1,dist1 for 1st half and N2,D2,dist2 thereafter
            [n,d] = tfdata(app.Gdis,'v');
            [nb,db] = tfdata(app.Gbdis,'v'); % with blockage
            
            % Change time due to sample rate
            app.time=0:app.Tsample:app.runtime; 
            k2 = round(length(app.time)/2);
            kend =length(app.time);
            u = ones(1,kend)*app.flow;
            y=0;

           %Blockage
           sw2 = app.OutletblockageDropDown.Value;
            switch sw2
                case 'Throughout'
                    N1=nb;D1=db; N2=nb;D2=db;
                    app.blocksave = ones(1,kend);
                case 'Mid-simulation'
                    N1=n;D1=d; N2 = nb; D2=db;
                    app.blocksave = [zeros(1,k2),ones(1,kend-k2)];
            end

            % Disturbance flow
            sw1= app.DisturbanceflowDropDown.Value;
            switch sw1
                case 'Throughout'
                    dist1 = app.Disturbanceflowm3sSlider.Value;
                    dist2 = dist1;
                    app.distsave = ones(1,kend);   % zeros and ones
                case 'Mid-simulation'
                    dist2 = app.Disturbanceflowm3sSlider.Value;
                    dist1 = 0;
                    app.distsave = [zeros(1,k2),ones(1,kend-k2)];
            end

            
            
            % The model changes with the disturbances, so we use a conditional to assess
            % the appropriate model. This switch only occurs mid-simulation
            for k=2:k2;
                y(k)=N1(end)*(u(k-1)+dist1)-D1(end)*y(k-1);
                              
            end
            for k=k2+1:kend;
                y(k)=N2(end)*(u(k-1)+dist2)-D2(end)*y(k-1);
                 
            end

            app.ytotal = y;
            app.u = u;
            
            ylabel(app.UIAxes2,'Open-loop behaviour')

            
        end
        
        % For the tab on manual control
        % Self-contained as this is continuous, responding dynamically to
        % user inputs and thus stands apart from other tabs
        function app = manualcontrol(app)
            
            RefreshButtonPushed(app) % clean figures
            disablebuttons(app);
            app.pause=true;
            app = createmodels(app); % define models
            app = createtankoutline(app); % define tank outline for animation
            
            
            % Models: Use N1,D1,dist1 for 1st half and N2,D2,dist2 thereafter
            [n,d] = tfdata(app.Gdis,'v'); n = n(end); d= d(2);
            [nb,db] = tfdata(app.Gbdis,'v'); nb=nb(end); db = db(2);% with blockage
            
            % Create a discrete simulation with randomly varying
            % disturbances and blockages (activated or not as desired)
            % Maximum of 2400 samples
            v = ones(40,1);
            dist = v*(randi(2,1,60)-1); dist = dist(:);
            block = v*(randi(2,1,60)-1); block = block(:); 

            % Initialise plots
            yplot = plot(app.UIAxes2,0,0);        
            xlabel(app.UIAxes2,'time (sec)')
            grid(app.UIAxes2,'on')
            hold(app.UIAxes2,'on')
            rplot = plot(app.UIAxes2,0,app.target,'g--','linewidth',2);
            legend(app.UIAxes2,'Depth','Target')
            ylim(app.UIAxes2,[0,8])
            ylabel(app.UIAxes2,'Manual control behaviour')


            uplot = plot(app.UIAxes4,0,0);
            hold(app.UIAxes4,'on')
            dplot = plot(app.UIAxes4,0,0);
            bplot = plot(app.UIAxes4,0,0);
            ylim(app.UIAxes4,'auto');
            legend(app.UIAxes4,'Input','Disturbance','Blockage')

            % Do simulation
            cont=1; y=[0 0]; k=1; time =0; r=app.target;
            app.changingu=app.SetinputflowSlider.Value;
            while and(cont==1,k<2400);
                k=k+1;
                time(k)=(k-1)*app.Tsample;
                u(k) = app.changingu;
                r(k)=app.target;
                if app.include_dist==1; 
                    disturbance(k)=app.Disturbanceflowm3sSlider.Value*dist(k);
                else
                    disturbance(k)=0;
                end

                if app.include_blockage==1;
                    block(k)=app.OutletpipeblockageSlider.Value*block(k)/100;
                    y(k+1) = nb*(u(k)+disturbance(k))-db*y(k);
                else
                    block(k)=0;
                    y(k+1) = n*(u(k)+disturbance(k))-d*y(k);
                end

                % Plotting - no overlays used here
                set(yplot,'Ydata',y(1:k),'Xdata',time(1:k));
                set(rplot,'Ydata',r(1:k),'Xdata',time(1:k));
                set(uplot,'Ydata',u(1:k),'Xdata',time(1:k));
                set(dplot,'Ydata',disturbance(1:k),'Xdata',time(1:k));
                set(bplot,'Ydata',block(1:k),'Xdata',time(1:k));
                ytankfill = [1,1+y(k),1+y(k),1];
                set(app.tankfill,'Ydata',[ytankfill]);
                % input flow
                flowinux=[.3+app.A/2,0.3+app.A/2-u(k)*0.4+0.2,...
                0.7+app.A/2+u(k)*0.4-0.2,0.7+app.A/2];
                set(app.flowinu,'XData',flowinux);
                % Blockage
                gap = 3*app.R*(1-block(k));                     
                blocky=[1+gap,1+gap,3+gap,3+gap];
                set(app.block,'YData',blocky);
                % disturbance
                yflowin2 = [10.5-disturbance(k)*2,10.5+disturbance(k)*2,10.8,10.4];
                set(app.flowinbottom,'YData',yflowin2);

                val = app.StartsimulationButton.Text;
                if strcmp(val,'Start simulation'); % because already set to end so this means end selected
                    cont=0;
                end

                drawnow % to ensure we collect relevant user input
                % Pause button action
                while not(app.pause);
                    pause(1);
                end
                
            end




            enablebuttons(app);

        end




        
        function app = closed_loop_responses(app)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function determines all the closed-loop UNIT step responses
            % Based on current values of the sliders and assuming the
            % uncertainty is fixed

           
            % collect compensator and tank values from the sliders
            % round values to avoid unnecessary decimal places
            Kp=app.ProportionalgainKpSlider.Value;
            Ki=app.IntegralgainKiSlider.Value;
            PI =tf([Kp,Ki],[1 0]);
            app.runtime=round(app.A/app.Rblock,0)*4;
            app.time=linspace(0,app.runtime,app.samples);
            kend = length(app.time);
            
            % Collect disturbance data from sliders
            dist=app.Disturbanceflowm3sSlider.Value;
            % blockvalue = app.OutletpipeblockageSlider.Value;
            % app.blocksave = ones(1,kend);
            % app.distsave = ones(1,kend);
 
            %%% FIND CLOSED LOOP MODELS
            %  y = GM/(1+GM)* R +  G/(1+GM) dist
            %  u = M/(1+GM) * R  - GM/(1+GM) dist
            Gc = feedback(app.Gb*PI,1); % target to depth
            Gcd = feedback(app.Gb,PI);  % disturbance to depth
            Gcu = feedback(PI,app.Gb);  % target to in-flow
            Gcud = -Gc;% disturbance to in-flow
                        
            % find closed-loop responses
            [h]=step(Gc,app.time);    h = h*app.target;
            [u]=step(Gcu,app.time);   u = u*app.target;
            [hd]=step(Gcd,app.time);  hd = hd *dist;
            [ud]=step(Gcud,app.time); ud = ud*dist;
                                 
            app.ytotal = h+hd;
            app.u = u+ud;

            ylabel(app.UIAxes2,'Closed-loop behaviour')
            app.blocksave = ones(1,kend);
            app.distsave = ones(1,kend);
           
        end
        
        % Linked to the last tab, what happens when we have multiple forms of
        % uncertainty occuring simultaneously?
        % This tab assumes the target is a square wave so that one can also
        % assess tracking effectively

        function app = responseswithuncertainty(app)
            RefreshButtonPushed(app) % clean figures
            disablebuttons(app);
            app.pause=true;
            app = createmodels(app); % define models
            app = createtankoutline(app); % define tank outline for animation
            
            
            % Models: Nominal model is fixed, but blockage model needs to
            % be updated every time blockage changes
            [n,d] = tfdata(app.Gdis,'v'); n = n(end); d= d(2);
            Kp=app.ProportionalgainKpSlider.Value;
            Ki=app.IntegralgainKiSlider.Value;
            PI =tf([Kp,Ki],[1 0]);
            PId = c2d(PI,app.Tsample,'tustin');
            [nK,dK]=tfdata(PId,'v');
          
            
            % Create a discrete simulation with randomly varying
            % disturbances and blockages (activated or not as desired)
            % Create vaiables to be interrogated to pick up updated
            % uncertainty every 50 samples.
            vblockage = (randi(8,1,200)+2)/10; % a percentage
            vdisturbance = 0.2*(randi(8,1,200)+2)/10; % actual value of disurbance flow
            vnoise = 0.4*(randi(8,1,200)+2)/10; % maximum value of noise
            vdelay = (randi(6,1,200)+2)*2; vdelay(1)=0;  % actual value of delay in samples
            counter=1;          

            % Initialise plots
            yplot = plot(app.UIAxes2,0,0);   
            xlabel(app.UIAxes2,'time (sec)')
            grid(app.UIAxes2,'on')
            hold(app.UIAxes2,'on')
            ymplot = plot(app.UIAxes2,0,0); 
            rplot = plot(app.UIAxes2,0,app.target,'g--','linewidth',2);
            legend(app.UIAxes2,'Depth','Noisy measurement','Target')
            ylim(app.UIAxes2,[0,8])
            xlim(app.UIAxes2,'auto');
            ylabel(app.UIAxes2,'Closed-loop behaviour with uncertainty')
            uplot = plot(app.UIAxes4,0,0);
            hold(app.UIAxes4,'on')
            dplot = plot(app.UIAxes4,0,0);
            bplot = plot(app.UIAxes4,0,0);
            nplot = plot(app.UIAxes4,0,0);
            delayplot = plot(app.UIAxes4,0,0);
            ylim(app.UIAxes4,'auto');
            xlim(app.UIAxes4,'auto');
            legend(app.UIAxes4,'Input','Disturbance','Blockage','Noise magnitude','Delay/10','Location','southwest')

            % Do simulation
            cont=1; y=[0 0]; ym=y; e= y;
            k=1; time =0; u=[0 0];
            r=app.target;
            noise = [1 1]*vnoise(1); 
            disturbance = [1 1]*vdisturbance(1); 
            blockage =[1 1]*vblockage(1); 
            delay = [1 1]*vdelay(1);
            r = [1 1]*app.target;
            p=1;
            tstart=tic; 

            while and(cont==1,k<8000);
                k=k+1;
                
                % Update uncertainty and target
                p=p+1;  % counter for changes in uncertainty
                if p==150; %Change all uncertainty values
                    counter = counter+1;
                    p=1;
                    if r(k)==app.target;
                        r(k)=app.target-1;
                    else
                        r(k)=app.target;
                    end % target is a square wave
                    
                end                          
                r(k+1)=r(k);               
                time(k)=(k-1)*app.Tsample;

                % Update control law
                e(k) = r(k)-ym(k);
                u(k) = (-dK(2)*u(k-1) + nK*e(k:-1:k-1)')/dK(1);
                if u(k)<0;u(k)=0;end % add some saturation checks
                if u(k)>3; u(k)=3;end

                % Update system uncertainty                
                if app.include_dist2==1; 
                    disturbance(k)=vdisturbance(counter);
                else
                    disturbance(k)=0;
                end
                if app.include_noise==1; 
                    noise(k+1)=vnoise(counter)*(rand(1)-0.5);
                else
                    noise(k+1)=0;
                end
                if app.include_blockage2==1;
                    block(k)=vblockage(counter);
                else
                    block(k)=0;                  
                end
                if app.include_delay==1; 
                    delay(k)=vdelay(counter);
                else
                    delay(k)=0;
                end


                % define model for current sample
                % y = Gd*flowin + Gd*dist  with BLOCKAGE
                Gb=tf(1,[app.A,app.R*(1-block(k))]);  % with blockage 
                Gbdis=c2d(Gb,app.Tsample);  % discretise
                nb = Gbdis.numerator; nb = nb{:}; nb=nb(end);
                db = Gbdis.denominator; db = db{:};db = db(2);
                %[nb,db] = tfdata(Gbdis,'v'); 
                 
                % update model output
                y(k+1) = nb*(u(k)+disturbance(k))-db*y(k);

                % add measurement noise and measurement delay
                ym(k+1) = y(k+1-delay(k))+noise(k+1-delay(k));

                % Plotting animation every 3 samples
                if rem(k,3);
                set(yplot,'Ydata',y(1:k),'Xdata',time(1:k));
                set(ymplot,'Ydata',ym(1:k),'Xdata',time(1:k));
                set(rplot,'Ydata',r(1:k),'Xdata',time(1:k));
                set(uplot,'Ydata',u(1:k),'Xdata',time(1:k));
                set(nplot,'Ydata',noise(1:k),'Xdata',time(1:k));
                set(delayplot,'Ydata',delay(1:k)/10,'Xdata',time(1:k));
                set(dplot,'Ydata',disturbance(1:k),'Xdata',time(1:k));
                set(bplot,'Ydata',block(1:k),'Xdata',time(1:k));
                % TANK picture
                ytankfill = [1,1+y(k),1+y(k),1];
                set(app.tankfill,'Ydata',[ytankfill]);
                % target line in tank plot
                set(app.targetline1,'Ydata',[1,1]*(1+r(k)));
                % input flow
                flowinux=[.3+app.A/2,0.3+app.A/2-u(k)*0.4+0.2,...
                0.7+app.A/2+u(k)*0.4-0.2,0.7+app.A/2];
                set(app.flowinu,'XData',flowinux);
                % Blockage
                gap = 3*app.R*(1-block(k));                     
                blocky=[1+gap,1+gap,3+gap,3+gap];
                set(app.block,'YData',blocky);
                % disturbance
                yflowin2 = [10.5-disturbance(k)*2,10.5+disturbance(k)*2,10.8,10.4];
                set(app.flowinbottom,'YData',yflowin2);

                pause(app.Tsamp_anim-toc(tstart));  %% Clumsy application of sampling time
                tstart = tic;
                drawnow % to ensure we collect relevant user input

                end

                val = app.StartButton.Text;
                if strcmp(val,'Start'); % because already set to end so this means end selected
                    cont=0;
                end            
                                
            end  % end of the simulation loop


            enablebuttons(app);
        end   % end of responses with uncertainty


    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % resize to be in middle of  the window
            movegui(app.UIFigure)
            
            % Open the manual
            if exist('tanklevel_story_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open tanklevel_story_mycopy.mlx
            else
                p1 = which('tanklevel_story_manual.mlx');
                p2 = strcat(pwd,'/tanklevel_story_mycopy.mlx');
                copyfile(p1,p2)                
                open tanklevel_story_mycopy.mlx
                clear p1 p2
            end

            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);
 
            app = createtankoutline(app); % define car outline for animation
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
                theme(app.UIFigure,"light")
            end
        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
            
            disablebuttons(app);
            app = createmodels(app); % define models
            app = createtankoutline(app); % define tank outline for animation

            switch app.TabGroup.SelectedTab.Title
                case 'Open-loop behaviour'
                    app = openloopresponses(app);
                    app = animationoflineplots(app); % manage the animations

                case 'Modelling' % No disturbances so simple data
                    
                    app = timeconstantanalysis(app); % create figure to show 
                    app = createtankoutline(app); % define tank outline for animation
                    app = animationoflineplots(app); % manage the animations
                     
                case 'Manual control' % No disturbances so simple data
                    StartsimulationButtonPushed(app); % activate the bottom left button

                case 'PI design'
                    app = closed_loop_responses(app);
                    app = animationoflineplots(app); % manage the animations

                case 'Control with uncertainty' % No disturbances so simple data
                    StartButtonPushed(app); % activate the bottom left button
                    

            end

            

            enablebuttons(app);

        end

        % Button pushed function: RefreshButton
        function RefreshButtonPushed(app, event)
            %% Clean all the figures and legend so user can begin afresh
             hold(app.UIAxes3,'off')
             hold(app.UIAxes2,'off')
             hold(app.UIAxes4,'off')
             plot(app.UIAxes3,0,0)
             plot(app.UIAxes2,0,0)
             plot(app.UIAxes4,0,0)
             app.legstring=cell(1);
        end

        % Button pushed function: AnimationOnButton
        function AnimationOnButtonPushed(app, event)
            val = app.AnimationOnButton.Text;
            if strcmp(val,'Animation On');
                val = 'Animation Off';
            else
                val = 'Animation On';
            end
            app.AnimationOnButton.Text=val;
        end

        % Value changed function: Flowinm3sSlider
        function Flowinm3sSliderValueChanged(app, event)
            value = app.Flowinm3sSlider.Value;
            value = round(value,1);
            if value<0.1;value=0.1;end
            app.Flowinm3sSlider.Value=value;
            app = createtankoutline(app);

        end

        % Value changed function: Rm2sSlider
        function Rm2sSliderValueChanged(app, event)
            value = app.Rm2sSlider.Value;
            value=round(value,1); 
            if value<0.1;value=0.1;end
            app.Rm2sSlider.Value=value;
            app = createtankoutline(app);
        end

        % Value changed function: Aream2Slider
        function Aream2SliderValueChanged(app, event)
            value = app.Aream2Slider.Value;
            value=round(value,0);
            if value<1;value=1;end
            app.Aream2Slider.Value=value;
            app = createtankoutline(app);
           
        end

        % Value changed function: OutletpipeblockageSlider
        function OutletpipeblockageSliderValueChanged(app, event)
            value = app.OutletpipeblockageSlider.Value;
            value=round(value,-1);
            if value>90;value=90;end
            app.OutletpipeblockageSlider.Value=value;
            app = createtankoutline(app);
            
        end

        % Value changed function: Disturbanceflowm3sSlider
        function Disturbanceflowm3sSliderValueChanged(app, event)
            value = app.Disturbanceflowm3sSlider.Value;
            value = round(value*2,1)/2;
            app.Disturbanceflowm3sSlider.Value=value;
            app = createtankoutline(app);
            %keyboard
            
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

        % Button pushed function: StartsimulationButton
        function StartsimulationButtonPushed(app, event)
            val = app.StartsimulationButton.Text;
            if strcmp(val,'Start simulation');
                val = 'End simulation';
                % Sub function to run the functions required in the manual
                % control tab
                app.StartsimulationButton.Text=val;
                app = manualcontrol(app);
            else
                % Stop simulation
                val = 'Start simulation';
                app.StartsimulationButton.Text=val;
            end
                    
            

        end

        % Button pushed function: IncludingdisturbancesButton
        function IncludingdisturbancesButtonPushed(app, event)
            val = app.IncludingdisturbancesButton.Text;
            if strcmp(val,'Including disturbances');
                val = 'Using disturbances = 0';
                app.include_dist = 0;
            else
                % Stop simulation
                val = 'Including disturbances';
                app.include_dist=1;
            end
            app.IncludingdisturbancesButton.Text=val;
        end

        % Button pushed function: IncludingblockagesButton
        function IncludingblockagesButtonPushed(app, event)
            val = app.IncludingblockagesButton.Text;
            if strcmp(val,'Including blockages');
                val = 'Using no blockage';
                app.include_blockage = 0;
            else
                % Stop simulation
                val = 'Including blockages';
                app.include_blockage=1;
            end
            app.IncludingblockagesButton.Text=val;
        end

        % Button pushed function: PausesimulationButton
        function PausesimulationButtonPushed(app, event)
            val = app.PausesimulationButton.Text;
            if strcmp(val,'Pause simulation');
                val = 'Continue simulation';
                app.pause = false;
            else
                % Stop simulation
                val = 'Pause simulation';
                app.pause=true;
            end
            app.PausesimulationButton.Text=val;
        end

        % Value changing function: SetinputflowSlider
        function SetinputflowSliderValueChanging(app, event)
            changingValue = event.Value;
            app.changingu=changingValue;
        end

        % Value changed function: ProportionalgainKpSlider
        function ProportionalgainKpSliderValueChanged(app, event)
            value = app.ProportionalgainKpSlider.Value;
            value=round(value,2);
            app.ProportionalgainKpSlider.Value=value;
        end

        % Value changed function: IntegralgainKiSlider
        function IntegralgainKiSliderValueChanged(app, event)
            value = app.IntegralgainKiSlider.Value;
            value=round(value,2);
            app.IntegralgainKiSlider.Value=value;
        end

        % Button pushed function: IncludingdisturbancesButton_2
        function IncludingdisturbancesButton_2Pushed(app, event)
            val = app.IncludingdisturbancesButton_2.Text;
            if strcmp(val,'Including disturbances');
                val = 'Using disturbances = 0';
                app.include_dist2 = 0;
            else
                
                val = 'Including disturbances';
                app.include_dist2=1;
            end
            app.IncludingdisturbancesButton_2.Text=val;
        end

        % Button pushed function: IncludingblockagesButton_2
        function IncludingblockagesButton_2Pushed(app, event)
            val = app.IncludingblockagesButton_2.Text;
            if strcmp(val,'Including blockages');
                val = 'Using no blockage';
                app.include_blockage2 = 0;
            else
                
                val = 'Including blockages';
                app.include_blockage2=1;
            end
            app.IncludingblockagesButton_2.Text=val;
        end

        % Button pushed function: IncludingmeasurementnoiseButton
        function IncludingmeasurementnoiseButtonPushed(app, event)
            val = app.IncludingmeasurementnoiseButton.Text;
            if strcmp(val,'Including measurement noise');
                val = 'Using no measurement noise';
                app.include_noise = 0;
            else
                
                val = 'Including measurement noise';
                app.include_noise=1;
            end
            app.IncludingmeasurementnoiseButton.Text=val;
        end

        % Button pushed function: IncludingmeasurementdelayButton
        function IncludingmeasurementdelayButtonPushed(app, event)
            val = app.IncludingmeasurementdelayButton.Text;
            if strcmp(val,'Including measurement delay');
                val = 'Using no measurement delay';
                app.include_delay = 0;
            else
                
                val = 'Including measurement delay';
                app.include_delay=1;
            end
            app.IncludingmeasurementdelayButton.Text=val;
        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            val = app.StartButton.Text;
            if strcmp(val,'Start');
                val = 'End';
                % Sub function to run the functions required in the manual
                % control tab
                app.StartButton.Text=val;
                app = responseswithuncertainty(app);
            else
                % Stop simulation
                val = 'Start';
                app.StartButton.Text=val;
            end
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
            app.UIFigure.Position = [100 100 1297 806];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1.4x', '2x', '2x'};
            app.GridLayout.RowHeight = {'0.4x', '1.2x', '1x', '2x'};

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.GridLayout);
            title(app.UIAxes4, 'Input and disturbances (current simulation)')
            xlabel(app.UIAxes4, 'Time (s)')
            ylabel(app.UIAxes4, 'Input flow')
            zlabel(app.UIAxes4, 'Z')
            app.UIAxes4.FontSize = 14;
            app.UIAxes4.Layout.Row = 4;
            app.UIAxes4.Layout.Column = 3;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout);
            title(app.UIAxes2, 'Stored step responses')
            xlabel(app.UIAxes2, 'Time (s)')
            ylabel(app.UIAxes2, 'Depth (m)')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 14;
            app.UIAxes2.Layout.Row = [2 3];
            app.UIAxes2.Layout.Column = 3;

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Animation of tank level')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.XTick = [];
            app.UIAxes.XTickLabel = '';
            app.UIAxes.YTick = [];
            app.UIAxes.YTickLabel = '';
            app.UIAxes.FontSize = 18;
            app.UIAxes.Layout.Row = [2 3];
            app.UIAxes.Layout.Column = 2;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = [2 3];
            app.GridLayout2.BackgroundColor = [0.6 1 1];

            % Create ModellingandcontroloftanklevelLabel
            app.ModellingandcontroloftanklevelLabel = uilabel(app.GridLayout2);
            app.ModellingandcontroloftanklevelLabel.BackgroundColor = [0 1 1];
            app.ModellingandcontroloftanklevelLabel.HorizontalAlignment = 'center';
            app.ModellingandcontroloftanklevelLabel.FontSize = 24;
            app.ModellingandcontroloftanklevelLabel.FontWeight = 'bold';
            app.ModellingandcontroloftanklevelLabel.Layout.Row = 1;
            app.ModellingandcontroloftanklevelLabel.Layout.Column = [1 2];
            app.ModellingandcontroloftanklevelLabel.Text = 'Modelling and control of tank level';

            % Create Image
            app.Image = uiimage(app.GridLayout2);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 3;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'UoSlogo.png');

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout);
            app.GridLayout3.ColumnWidth = {'0.95x', '0.85x', '1.1x'};
            app.GridLayout3.RowHeight = {'1x'};
            app.GridLayout3.Layout.Row = 1;
            app.GridLayout3.Layout.Column = 1;
            app.GridLayout3.BackgroundColor = [1 0.6 0.8];

            % Create SimulateButton
            app.SimulateButton = uibutton(app.GridLayout3, 'push');
            app.SimulateButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateButtonPushed, true);
            app.SimulateButton.BackgroundColor = [1 0.2 0.702];
            app.SimulateButton.FontSize = 20;
            app.SimulateButton.FontWeight = 'bold';
            app.SimulateButton.Layout.Row = 1;
            app.SimulateButton.Layout.Column = 1;
            app.SimulateButton.Text = 'Simulate';

            % Create RefreshButton
            app.RefreshButton = uibutton(app.GridLayout3, 'push');
            app.RefreshButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshButtonPushed, true);
            app.RefreshButton.BackgroundColor = [1 0.2 0.702];
            app.RefreshButton.FontSize = 20;
            app.RefreshButton.FontWeight = 'bold';
            app.RefreshButton.Layout.Row = 1;
            app.RefreshButton.Layout.Column = 2;
            app.RefreshButton.Text = 'Refresh';

            % Create AnimationOnButton
            app.AnimationOnButton = uibutton(app.GridLayout3, 'push');
            app.AnimationOnButton.ButtonPushedFcn = createCallbackFcn(app, @AnimationOnButtonPushed, true);
            app.AnimationOnButton.WordWrap = 'on';
            app.AnimationOnButton.BackgroundColor = [1 0.2 0.702];
            app.AnimationOnButton.FontSize = 16;
            app.AnimationOnButton.FontWeight = 'bold';
            app.AnimationOnButton.Layout.Row = 1;
            app.AnimationOnButton.Layout.Column = 3;
            app.AnimationOnButton.Text = 'Animation On';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout4.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout4.Layout.Row = 2;
            app.GridLayout4.Layout.Column = 1;
            app.GridLayout4.BackgroundColor = [0.902 1 0.502];

            % Create Aream2SliderLabel
            app.Aream2SliderLabel = uilabel(app.GridLayout4);
            app.Aream2SliderLabel.HorizontalAlignment = 'right';
            app.Aream2SliderLabel.FontSize = 14;
            app.Aream2SliderLabel.Layout.Row = 2;
            app.Aream2SliderLabel.Layout.Column = 1;
            app.Aream2SliderLabel.Text = 'Area (m^2)';

            % Create Aream2Slider
            app.Aream2Slider = uislider(app.GridLayout4);
            app.Aream2Slider.Limits = [0 10];
            app.Aream2Slider.ValueChangedFcn = createCallbackFcn(app, @Aream2SliderValueChanged, true);
            app.Aream2Slider.MinorTicks = [500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000];
            app.Aream2Slider.FontSize = 14;
            app.Aream2Slider.Layout.Row = 2;
            app.Aream2Slider.Layout.Column = 2;
            app.Aream2Slider.Value = 5;

            % Create Rm2sSliderLabel
            app.Rm2sSliderLabel = uilabel(app.GridLayout4);
            app.Rm2sSliderLabel.HorizontalAlignment = 'right';
            app.Rm2sSliderLabel.FontSize = 14;
            app.Rm2sSliderLabel.Layout.Row = 3;
            app.Rm2sSliderLabel.Layout.Column = 1;
            app.Rm2sSliderLabel.Text = 'R (m^2/s)';

            % Create Rm2sSlider
            app.Rm2sSlider = uislider(app.GridLayout4);
            app.Rm2sSlider.Limits = [0 0.5];
            app.Rm2sSlider.ValueChangedFcn = createCallbackFcn(app, @Rm2sSliderValueChanged, true);
            app.Rm2sSlider.MinorTicks = [0 100 200 300 400 500 600 700 800 900 1000];
            app.Rm2sSlider.FontSize = 14;
            app.Rm2sSlider.Layout.Row = 3;
            app.Rm2sSlider.Layout.Column = 2;
            app.Rm2sSlider.Value = 0.2;

            % Create TankparametersAdhdtRhfinLabel
            app.TankparametersAdhdtRhfinLabel = uilabel(app.GridLayout4);
            app.TankparametersAdhdtRhfinLabel.BackgroundColor = [1 1 0];
            app.TankparametersAdhdtRhfinLabel.HorizontalAlignment = 'center';
            app.TankparametersAdhdtRhfinLabel.FontSize = 18;
            app.TankparametersAdhdtRhfinLabel.FontWeight = 'bold';
            app.TankparametersAdhdtRhfinLabel.Layout.Row = 1;
            app.TankparametersAdhdtRhfinLabel.Layout.Column = [1 2];
            app.TankparametersAdhdtRhfinLabel.Text = 'Tank parameters: A(dh/dt) + R h =  fin';

            % Create Flowinm3sSliderLabel
            app.Flowinm3sSliderLabel = uilabel(app.GridLayout4);
            app.Flowinm3sSliderLabel.HorizontalAlignment = 'right';
            app.Flowinm3sSliderLabel.FontSize = 13;
            app.Flowinm3sSliderLabel.Layout.Row = 4;
            app.Flowinm3sSliderLabel.Layout.Column = 1;
            app.Flowinm3sSliderLabel.Text = 'Flow in (m^3/s)';

            % Create Flowinm3sSlider
            app.Flowinm3sSlider = uislider(app.GridLayout4);
            app.Flowinm3sSlider.Limits = [0 1];
            app.Flowinm3sSlider.ValueChangedFcn = createCallbackFcn(app, @Flowinm3sSliderValueChanged, true);
            app.Flowinm3sSlider.MinorTicks = [0 10 20 30 40 50];
            app.Flowinm3sSlider.FontSize = 13;
            app.Flowinm3sSlider.Layout.Row = 4;
            app.Flowinm3sSlider.Layout.Column = 2;
            app.Flowinm3sSlider.Value = 0.5;

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout6.Layout.Row = 3;
            app.GridLayout6.Layout.Column = 1;
            app.GridLayout6.BackgroundColor = [0.702 1 0.702];

            % Create EnvironmentparametersLabel
            app.EnvironmentparametersLabel = uilabel(app.GridLayout6);
            app.EnvironmentparametersLabel.BackgroundColor = [0 1 0];
            app.EnvironmentparametersLabel.HorizontalAlignment = 'center';
            app.EnvironmentparametersLabel.FontSize = 18;
            app.EnvironmentparametersLabel.FontWeight = 'bold';
            app.EnvironmentparametersLabel.Layout.Row = 1;
            app.EnvironmentparametersLabel.Layout.Column = [1 2];
            app.EnvironmentparametersLabel.Text = 'Environment parameters';

            % Create Disturbanceflowm3sSliderLabel
            app.Disturbanceflowm3sSliderLabel = uilabel(app.GridLayout6);
            app.Disturbanceflowm3sSliderLabel.HorizontalAlignment = 'right';
            app.Disturbanceflowm3sSliderLabel.FontSize = 14;
            app.Disturbanceflowm3sSliderLabel.Layout.Row = 2;
            app.Disturbanceflowm3sSliderLabel.Layout.Column = 1;
            app.Disturbanceflowm3sSliderLabel.Text = 'Disturbance flow (m^3/s)';

            % Create Disturbanceflowm3sSlider
            app.Disturbanceflowm3sSlider = uislider(app.GridLayout6);
            app.Disturbanceflowm3sSlider.Limits = [0 0.2];
            app.Disturbanceflowm3sSlider.ValueChangedFcn = createCallbackFcn(app, @Disturbanceflowm3sSliderValueChanged, true);
            app.Disturbanceflowm3sSlider.MinorTicks = [-20 -15 -10 -5 0 5 10 15 20];
            app.Disturbanceflowm3sSlider.FontSize = 14;
            app.Disturbanceflowm3sSlider.Layout.Row = 2;
            app.Disturbanceflowm3sSlider.Layout.Column = 2;

            % Create OutletpipeblockageSliderLabel
            app.OutletpipeblockageSliderLabel = uilabel(app.GridLayout6);
            app.OutletpipeblockageSliderLabel.HorizontalAlignment = 'right';
            app.OutletpipeblockageSliderLabel.FontSize = 13;
            app.OutletpipeblockageSliderLabel.Layout.Row = 3;
            app.OutletpipeblockageSliderLabel.Layout.Column = 1;
            app.OutletpipeblockageSliderLabel.Text = 'Outlet pipe blockage (%)';

            % Create OutletpipeblockageSlider
            app.OutletpipeblockageSlider = uislider(app.GridLayout6);
            app.OutletpipeblockageSlider.ValueChangedFcn = createCallbackFcn(app, @OutletpipeblockageSliderValueChanged, true);
            app.OutletpipeblockageSlider.FontSize = 13;
            app.OutletpipeblockageSlider.Layout.Row = 3;
            app.OutletpipeblockageSlider.Layout.Column = 2;

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.Layout.Row = 4;
            app.TabGroup.Layout.Column = [1 2];

            % Create OpenloopbehaviourTab
            app.OpenloopbehaviourTab = uitab(app.TabGroup);
            app.OpenloopbehaviourTab.Title = 'Open-loop behaviour';

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.OpenloopbehaviourTab);
            app.GridLayout7.ColumnWidth = {'1.4x', '2x', '2x'};
            app.GridLayout7.RowHeight = {'1x', '1x', '1x'};

            % Create DisturbanceflowDropDownLabel
            app.DisturbanceflowDropDownLabel = uilabel(app.GridLayout7);
            app.DisturbanceflowDropDownLabel.BackgroundColor = [0.702 1 0.702];
            app.DisturbanceflowDropDownLabel.HorizontalAlignment = 'right';
            app.DisturbanceflowDropDownLabel.FontSize = 18;
            app.DisturbanceflowDropDownLabel.Layout.Row = 2;
            app.DisturbanceflowDropDownLabel.Layout.Column = 1;
            app.DisturbanceflowDropDownLabel.Text = 'Disturbance flow';

            % Create DisturbanceflowDropDown
            app.DisturbanceflowDropDown = uidropdown(app.GridLayout7);
            app.DisturbanceflowDropDown.Items = {'Throughout', 'Mid-simulation'};
            app.DisturbanceflowDropDown.FontSize = 18;
            app.DisturbanceflowDropDown.BackgroundColor = [0.702 1 0.702];
            app.DisturbanceflowDropDown.Layout.Row = 2;
            app.DisturbanceflowDropDown.Layout.Column = 2;
            app.DisturbanceflowDropDown.Value = 'Throughout';

            % Create Label
            app.Label = uilabel(app.GridLayout7);
            app.Label.BackgroundColor = [0 1 1];
            app.Label.HorizontalAlignment = 'center';
            app.Label.WordWrap = 'on';
            app.Label.FontSize = 18;
            app.Label.FontWeight = 'bold';
            app.Label.Layout.Row = 1;
            app.Label.Layout.Column = [1 2];
            app.Label.Text = 'Explore how the tank behaviour depends on input flow, flow disturbances and blockages. ';

            % Create OutletblockageDropDownLabel
            app.OutletblockageDropDownLabel = uilabel(app.GridLayout7);
            app.OutletblockageDropDownLabel.BackgroundColor = [0.702 1 0.702];
            app.OutletblockageDropDownLabel.HorizontalAlignment = 'right';
            app.OutletblockageDropDownLabel.FontSize = 18;
            app.OutletblockageDropDownLabel.Layout.Row = 3;
            app.OutletblockageDropDownLabel.Layout.Column = 1;
            app.OutletblockageDropDownLabel.Text = 'Outlet blockage';

            % Create OutletblockageDropDown
            app.OutletblockageDropDown = uidropdown(app.GridLayout7);
            app.OutletblockageDropDown.Items = {'Throughout', 'Mid-simulation'};
            app.OutletblockageDropDown.FontSize = 18;
            app.OutletblockageDropDown.BackgroundColor = [0.702 1 0.702];
            app.OutletblockageDropDown.Layout.Row = 3;
            app.OutletblockageDropDown.Layout.Column = 2;
            app.OutletblockageDropDown.Value = 'Throughout';

            % Create Label_3
            app.Label_3 = uilabel(app.GridLayout7);
            app.Label_3.BackgroundColor = [0.902 0.702 1];
            app.Label_3.WordWrap = 'on';
            app.Label_3.FontSize = 18;
            app.Label_3.Layout.Row = 2;
            app.Label_3.Layout.Column = 3;
            app.Label_3.Text = 'The time scale changes to be about 4 time constants for the most recent scenario.';

            % Create Label_4
            app.Label_4 = uilabel(app.GridLayout7);
            app.Label_4.BackgroundColor = [0.902 0.702 1];
            app.Label_4.WordWrap = 'on';
            app.Label_4.FontSize = 18;
            app.Label_4.Layout.Row = 3;
            app.Label_4.Layout.Column = 3;
            app.Label_4.Text = 'With high % blockage, the tank may overflow.';

            % Create Label_5
            app.Label_5 = uilabel(app.GridLayout7);
            app.Label_5.BackgroundColor = [0.902 0.702 1];
            app.Label_5.HorizontalAlignment = 'center';
            app.Label_5.WordWrap = 'on';
            app.Label_5.FontSize = 18;
            app.Label_5.FontWeight = 'bold';
            app.Label_5.Layout.Row = 1;
            app.Label_5.Layout.Column = 3;
            app.Label_5.Text = 'REMARKS';

            % Create ModellingTab
            app.ModellingTab = uitab(app.TabGroup);
            app.ModellingTab.Title = 'Modelling';

            % Create GridLayout8
            app.GridLayout8 = uigridlayout(app.ModellingTab);
            app.GridLayout8.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout8.RowHeight = {'1x', '1x', '1x', '1x', '1x'};

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.GridLayout8);
            title(app.UIAxes3, 'Modelling of time constant and gain for current system')
            xlabel(app.UIAxes3, 'Time (s)')
            ylabel(app.UIAxes3, 'Depth (m)')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.FontSize = 14;
            app.UIAxes3.Layout.Row = [2 5];
            app.UIAxes3.Layout.Column = [2 3];

            % Create Label_2
            app.Label_2 = uilabel(app.GridLayout8);
            app.Label_2.BackgroundColor = [0 1 1];
            app.Label_2.HorizontalAlignment = 'center';
            app.Label_2.VerticalAlignment = 'top';
            app.Label_2.WordWrap = 'on';
            app.Label_2.FontSize = 18;
            app.Label_2.FontWeight = 'bold';
            app.Label_2.Layout.Row = 1;
            app.Label_2.Layout.Column = [1 3];
            app.Label_2.Text = 'This tab does open loop unit step tests with NO disturbances & blockage. Use to determine time constant ''T'' and gain ''C'' of the model:    T (dh/dt) + h = C Fin';

            % Create TimeconstantLabel
            app.TimeconstantLabel = uilabel(app.GridLayout8);
            app.TimeconstantLabel.BackgroundColor = [1 0.6 0.8];
            app.TimeconstantLabel.HorizontalAlignment = 'center';
            app.TimeconstantLabel.FontSize = 18;
            app.TimeconstantLabel.Layout.Row = 2;
            app.TimeconstantLabel.Layout.Column = 1;
            app.TimeconstantLabel.Text = 'Time constant';

            % Create SystemGainLabel
            app.SystemGainLabel = uilabel(app.GridLayout8);
            app.SystemGainLabel.BackgroundColor = [1 0.6 0.8];
            app.SystemGainLabel.HorizontalAlignment = 'center';
            app.SystemGainLabel.FontSize = 18;
            app.SystemGainLabel.Layout.Row = 4;
            app.SystemGainLabel.Layout.Column = 1;
            app.SystemGainLabel.Text = 'System Gain';

            % Create EditField
            app.EditField = uieditfield(app.GridLayout8, 'numeric');
            app.EditField.HorizontalAlignment = 'center';
            app.EditField.FontSize = 18;
            app.EditField.Layout.Row = 3;
            app.EditField.Layout.Column = 1;

            % Create EditField_2
            app.EditField_2 = uieditfield(app.GridLayout8, 'numeric');
            app.EditField_2.HorizontalAlignment = 'center';
            app.EditField_2.FontSize = 18;
            app.EditField_2.Layout.Row = 5;
            app.EditField_2.Layout.Column = 1;

            % Create ManualcontrolTab
            app.ManualcontrolTab = uitab(app.TabGroup);
            app.ManualcontrolTab.Title = 'Manual control';

            % Create GridLayout10
            app.GridLayout10 = uigridlayout(app.ManualcontrolTab);
            app.GridLayout10.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.GridLayout10.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout10.BackgroundColor = [1 0.8 0.6];

            % Create MovethesliderbelowtochangetheinletflowrateLabel
            app.MovethesliderbelowtochangetheinletflowrateLabel = uilabel(app.GridLayout10);
            app.MovethesliderbelowtochangetheinletflowrateLabel.BackgroundColor = [0 1 1];
            app.MovethesliderbelowtochangetheinletflowrateLabel.HorizontalAlignment = 'center';
            app.MovethesliderbelowtochangetheinletflowrateLabel.WordWrap = 'on';
            app.MovethesliderbelowtochangetheinletflowrateLabel.FontSize = 18;
            app.MovethesliderbelowtochangetheinletflowrateLabel.FontWeight = 'bold';
            app.MovethesliderbelowtochangetheinletflowrateLabel.Layout.Row = 1;
            app.MovethesliderbelowtochangetheinletflowrateLabel.Layout.Column = [1 4];
            app.MovethesliderbelowtochangetheinletflowrateLabel.Text = 'Move the slider below to change the inlet flow rate and try to maintain the desired level.';

            % Create Label2
            app.Label2 = uilabel(app.GridLayout10);
            app.Label2.BackgroundColor = [0.6 1 1];
            app.Label2.WordWrap = 'on';
            app.Label2.FontSize = 14;
            app.Label2.Layout.Row = 2;
            app.Label2.Layout.Column = [1 2];
            app.Label2.Text = 'The system will be subject to random disturbances and blockages. Set sliders above before you begin simulation.';

            % Create Label_6
            app.Label_6 = uilabel(app.GridLayout10);
            app.Label_6.BackgroundColor = [0.6 1 1];
            app.Label_6.WordWrap = 'on';
            app.Label_6.FontSize = 14;
            app.Label_6.Layout.Row = 2;
            app.Label_6.Layout.Column = [3 4];
            app.Label_6.Text = 'This simulation is continuous (up to a time limit). Use the buttons below to stop, pause and change the settings.';

            % Create StartsimulationButton
            app.StartsimulationButton = uibutton(app.GridLayout10, 'push');
            app.StartsimulationButton.ButtonPushedFcn = createCallbackFcn(app, @StartsimulationButtonPushed, true);
            app.StartsimulationButton.BackgroundColor = [1 0.2 0.702];
            app.StartsimulationButton.FontSize = 18;
            app.StartsimulationButton.Layout.Row = 4;
            app.StartsimulationButton.Layout.Column = 1;
            app.StartsimulationButton.Text = 'Start simulation';

            % Create IncludingdisturbancesButton
            app.IncludingdisturbancesButton = uibutton(app.GridLayout10, 'push');
            app.IncludingdisturbancesButton.ButtonPushedFcn = createCallbackFcn(app, @IncludingdisturbancesButtonPushed, true);
            app.IncludingdisturbancesButton.WordWrap = 'on';
            app.IncludingdisturbancesButton.BackgroundColor = [1 0.2 0.702];
            app.IncludingdisturbancesButton.FontSize = 18;
            app.IncludingdisturbancesButton.Layout.Row = 4;
            app.IncludingdisturbancesButton.Layout.Column = 2;
            app.IncludingdisturbancesButton.Text = 'Including disturbances';

            % Create IncludingblockagesButton
            app.IncludingblockagesButton = uibutton(app.GridLayout10, 'push');
            app.IncludingblockagesButton.ButtonPushedFcn = createCallbackFcn(app, @IncludingblockagesButtonPushed, true);
            app.IncludingblockagesButton.WordWrap = 'on';
            app.IncludingblockagesButton.BackgroundColor = [1 0.2 0.702];
            app.IncludingblockagesButton.FontSize = 18;
            app.IncludingblockagesButton.Layout.Row = 4;
            app.IncludingblockagesButton.Layout.Column = 3;
            app.IncludingblockagesButton.Text = 'Including blockages';

            % Create PausesimulationButton
            app.PausesimulationButton = uibutton(app.GridLayout10, 'push');
            app.PausesimulationButton.ButtonPushedFcn = createCallbackFcn(app, @PausesimulationButtonPushed, true);
            app.PausesimulationButton.BackgroundColor = [1 0.2 0.702];
            app.PausesimulationButton.FontSize = 18;
            app.PausesimulationButton.Layout.Row = 4;
            app.PausesimulationButton.Layout.Column = 4;
            app.PausesimulationButton.Text = 'Pause simulation';

            % Create SetinputflowSliderLabel
            app.SetinputflowSliderLabel = uilabel(app.GridLayout10);
            app.SetinputflowSliderLabel.HorizontalAlignment = 'right';
            app.SetinputflowSliderLabel.FontSize = 18;
            app.SetinputflowSliderLabel.Layout.Row = 3;
            app.SetinputflowSliderLabel.Layout.Column = 1;
            app.SetinputflowSliderLabel.Text = 'Set input flow';

            % Create SetinputflowSlider
            app.SetinputflowSlider = uislider(app.GridLayout10);
            app.SetinputflowSlider.Limits = [0 2];
            app.SetinputflowSlider.ValueChangingFcn = createCallbackFcn(app, @SetinputflowSliderValueChanging, true);
            app.SetinputflowSlider.Layout.Row = 3;
            app.SetinputflowSlider.Layout.Column = [2 4];
            app.SetinputflowSlider.Value = 0.2;

            % Create PIdesignTab
            app.PIdesignTab = uitab(app.TabGroup);
            app.PIdesignTab.Title = 'PI design';

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.PIdesignTab);
            app.GridLayout9.ColumnWidth = {'1x', '2x', '1x'};
            app.GridLayout9.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout9.BackgroundColor = [1 0.8 0.6];

            % Create ControlParametersLabel
            app.ControlParametersLabel = uilabel(app.GridLayout9);
            app.ControlParametersLabel.BackgroundColor = [1 0.5098 0.302];
            app.ControlParametersLabel.HorizontalAlignment = 'center';
            app.ControlParametersLabel.FontSize = 18;
            app.ControlParametersLabel.FontWeight = 'bold';
            app.ControlParametersLabel.Layout.Row = 1;
            app.ControlParametersLabel.Layout.Column = [1 2];
            app.ControlParametersLabel.Text = 'Control Parameters';

            % Create ProportionalgainKpSliderLabel
            app.ProportionalgainKpSliderLabel = uilabel(app.GridLayout9);
            app.ProportionalgainKpSliderLabel.HorizontalAlignment = 'right';
            app.ProportionalgainKpSliderLabel.FontSize = 14;
            app.ProportionalgainKpSliderLabel.Layout.Row = 2;
            app.ProportionalgainKpSliderLabel.Layout.Column = 1;
            app.ProportionalgainKpSliderLabel.Text = 'Proportional gain (Kp)';

            % Create ProportionalgainKpSlider
            app.ProportionalgainKpSlider = uislider(app.GridLayout9);
            app.ProportionalgainKpSlider.Limits = [0 1];
            app.ProportionalgainKpSlider.ValueChangedFcn = createCallbackFcn(app, @ProportionalgainKpSliderValueChanged, true);
            app.ProportionalgainKpSlider.FontSize = 14;
            app.ProportionalgainKpSlider.Layout.Row = 2;
            app.ProportionalgainKpSlider.Layout.Column = 2;
            app.ProportionalgainKpSlider.Value = 0.2;

            % Create IntegralgainKiSliderLabel
            app.IntegralgainKiSliderLabel = uilabel(app.GridLayout9);
            app.IntegralgainKiSliderLabel.HorizontalAlignment = 'right';
            app.IntegralgainKiSliderLabel.FontSize = 14;
            app.IntegralgainKiSliderLabel.Layout.Row = 3;
            app.IntegralgainKiSliderLabel.Layout.Column = 1;
            app.IntegralgainKiSliderLabel.Text = 'Integral gain (Ki)';

            % Create IntegralgainKiSlider
            app.IntegralgainKiSlider = uislider(app.GridLayout9);
            app.IntegralgainKiSlider.Limits = [0 0.2];
            app.IntegralgainKiSlider.ValueChangedFcn = createCallbackFcn(app, @IntegralgainKiSliderValueChanged, true);
            app.IntegralgainKiSlider.FontSize = 14;
            app.IntegralgainKiSlider.Layout.Row = 3;
            app.IntegralgainKiSlider.Layout.Column = 2;
            app.IntegralgainKiSlider.Value = 0.02;

            % Create Label_7
            app.Label_7 = uilabel(app.GridLayout9);
            app.Label_7.BackgroundColor = [0.902 0.702 1];
            app.Label_7.HorizontalAlignment = 'center';
            app.Label_7.WordWrap = 'on';
            app.Label_7.FontSize = 18;
            app.Label_7.FontWeight = 'bold';
            app.Label_7.Layout.Row = 1;
            app.Label_7.Layout.Column = 3;
            app.Label_7.Text = 'REMARKS';

            % Create Label_8
            app.Label_8 = uilabel(app.GridLayout9);
            app.Label_8.BackgroundColor = [0.902 0.702 1];
            app.Label_8.HorizontalAlignment = 'center';
            app.Label_8.WordWrap = 'on';
            app.Label_8.FontSize = 18;
            app.Label_8.Layout.Row = 2;
            app.Label_8.Layout.Column = 3;
            app.Label_8.Text = 'Use the 2nd tab on modelling to estimate the model, and hence choose the Kp, Ki values systematically.';

            % Create Label_9
            app.Label_9 = uilabel(app.GridLayout9);
            app.Label_9.BackgroundColor = [0.902 0.702 1];
            app.Label_9.HorizontalAlignment = 'center';
            app.Label_9.WordWrap = 'on';
            app.Label_9.FontSize = 18;
            app.Label_9.Layout.Row = 3;
            app.Label_9.Layout.Column = 3;
            app.Label_9.Text = 'On this tab, blockages and disturbances are constant for simplicity.';

            % Create ControlwithuncertaintyTab
            app.ControlwithuncertaintyTab = uitab(app.TabGroup);
            app.ControlwithuncertaintyTab.Title = 'Control with uncertainty';

            % Create GridLayout11
            app.GridLayout11 = uigridlayout(app.ControlwithuncertaintyTab);
            app.GridLayout11.ColumnWidth = {'1x', '1x', '1x', '0.2x'};
            app.GridLayout11.RowHeight = {'1.4x', '1x', '1x', '1.2x'};
            app.GridLayout11.BackgroundColor = [1 0.8 0.6];

            % Create Label_10
            app.Label_10 = uilabel(app.GridLayout11);
            app.Label_10.BackgroundColor = [0 1 1];
            app.Label_10.HorizontalAlignment = 'center';
            app.Label_10.WordWrap = 'on';
            app.Label_10.FontSize = 18;
            app.Label_10.FontWeight = 'bold';
            app.Label_10.Layout.Row = 1;
            app.Label_10.Layout.Column = [1 2];
            app.Label_10.Text = 'Real world scenarios have multiple forms of uncertainty. This tab allows you to explore their impact on effective control of depth.';

            % Create Label_12
            app.Label_12 = uilabel(app.GridLayout11);
            app.Label_12.BackgroundColor = [0.902 0.702 1];
            app.Label_12.WordWrap = 'on';
            app.Label_12.FontSize = 14;
            app.Label_12.Layout.Row = 4;
            app.Label_12.Layout.Column = [3 4];
            app.Label_12.Text = 'The simulation is continuous until you select stop. Ignores the magnitude of the disturbances and blockages in sliders above as randomised throughout.';

            % Create Label_13
            app.Label_13 = uilabel(app.GridLayout11);
            app.Label_13.BackgroundColor = [0.902 0.702 1];
            app.Label_13.HorizontalAlignment = 'center';
            app.Label_13.WordWrap = 'on';
            app.Label_13.FontSize = 14;
            app.Label_13.Layout.Row = 3;
            app.Label_13.Layout.Column = [3 4];
            app.Label_13.Text = 'The PI parameters are taken from the previous tab and fixed throughout the simulation.';

            % Create StartButton
            app.StartButton = uibutton(app.GridLayout11, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.BackgroundColor = [1 0.2 0.702];
            app.StartButton.FontSize = 24;
            app.StartButton.Layout.Row = [2 3];
            app.StartButton.Layout.Column = 1;
            app.StartButton.Text = 'Start';

            % Create Label_14
            app.Label_14 = uilabel(app.GridLayout11);
            app.Label_14.BackgroundColor = [0.902 0.702 1];
            app.Label_14.WordWrap = 'on';
            app.Label_14.FontSize = 14;
            app.Label_14.Layout.Row = 2;
            app.Label_14.Layout.Column = [3 4];
            app.Label_14.Text = 'The buttons allow you to dynamically include or exclude different sources of uncertainty.';

            % Create IncludingdisturbancesButton_2
            app.IncludingdisturbancesButton_2 = uibutton(app.GridLayout11, 'push');
            app.IncludingdisturbancesButton_2.ButtonPushedFcn = createCallbackFcn(app, @IncludingdisturbancesButton_2Pushed, true);
            app.IncludingdisturbancesButton_2.WordWrap = 'on';
            app.IncludingdisturbancesButton_2.BackgroundColor = [1 0.2 0.702];
            app.IncludingdisturbancesButton_2.FontSize = 18;
            app.IncludingdisturbancesButton_2.Layout.Row = 4;
            app.IncludingdisturbancesButton_2.Layout.Column = 2;
            app.IncludingdisturbancesButton_2.Text = 'Including disturbances';

            % Create IncludingblockagesButton_2
            app.IncludingblockagesButton_2 = uibutton(app.GridLayout11, 'push');
            app.IncludingblockagesButton_2.ButtonPushedFcn = createCallbackFcn(app, @IncludingblockagesButton_2Pushed, true);
            app.IncludingblockagesButton_2.WordWrap = 'on';
            app.IncludingblockagesButton_2.BackgroundColor = [1 0.2 0.702];
            app.IncludingblockagesButton_2.FontSize = 18;
            app.IncludingblockagesButton_2.Layout.Row = 4;
            app.IncludingblockagesButton_2.Layout.Column = 1;
            app.IncludingblockagesButton_2.Text = 'Including blockages';

            % Create IncludingmeasurementnoiseButton
            app.IncludingmeasurementnoiseButton = uibutton(app.GridLayout11, 'push');
            app.IncludingmeasurementnoiseButton.ButtonPushedFcn = createCallbackFcn(app, @IncludingmeasurementnoiseButtonPushed, true);
            app.IncludingmeasurementnoiseButton.WordWrap = 'on';
            app.IncludingmeasurementnoiseButton.BackgroundColor = [1 0.2 0.702];
            app.IncludingmeasurementnoiseButton.FontSize = 18;
            app.IncludingmeasurementnoiseButton.Layout.Row = 2;
            app.IncludingmeasurementnoiseButton.Layout.Column = 2;
            app.IncludingmeasurementnoiseButton.Text = 'Including measurement noise';

            % Create IncludingmeasurementdelayButton
            app.IncludingmeasurementdelayButton = uibutton(app.GridLayout11, 'push');
            app.IncludingmeasurementdelayButton.ButtonPushedFcn = createCallbackFcn(app, @IncludingmeasurementdelayButtonPushed, true);
            app.IncludingmeasurementdelayButton.WordWrap = 'on';
            app.IncludingmeasurementdelayButton.BackgroundColor = [1 0.2 0.702];
            app.IncludingmeasurementdelayButton.FontSize = 18;
            app.IncludingmeasurementdelayButton.Layout.Row = 3;
            app.IncludingmeasurementdelayButton.Layout.Column = 2;
            app.IncludingmeasurementdelayButton.Text = 'Including measurement delay';

            % Create Label_15
            app.Label_15 = uilabel(app.GridLayout11);
            app.Label_15.BackgroundColor = [0.902 0.702 1];
            app.Label_15.HorizontalAlignment = 'center';
            app.Label_15.WordWrap = 'on';
            app.Label_15.FontSize = 18;
            app.Label_15.FontWeight = 'bold';
            app.Label_15.Layout.Row = 1;
            app.Label_15.Layout.Column = [3 4];
            app.Label_15.Text = 'REMARKS';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = tanklevel_story

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

