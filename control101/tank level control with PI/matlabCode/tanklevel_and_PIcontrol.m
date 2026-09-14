classdef tanklevel_and_PIcontrol < matlab.apps.AppBase
    %TANKLEVEL_AND_PICONTROL
    %   File written by J.A.Rossiter, University of Sheffield
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   A simple interface to practice behaviour of a simple tank
    %   level model subject to changes in in flow, disturbance flow and
    %   outlet blockage
    %       
    %   Some notes and engineering background are in the partner
    %   livescript  file:    tanklevel_and_PIcontrol_manual.mlx
    %   A group of similar files can be downloaded through MATLAB
    %   add-ons with the toolbox name:  control101
    %      
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %       
    %      
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    FILE ORGANISATION
    %   A section defining the core variables stored in "app"
    %   
    %   A section with subfunctions doing the core computations
    %   i) load behaviour model parameters and create picture; 
    %   ii) find linear responses to inputs, disturbances and
    %   blockages; 
    %   iii) initialise and control figures for animations and
    %   analysis; 
    %   iv) switch interaction on and off during animations
    %   v) clean figures and legends so can begin a new investigation
    %   vi) callbacks (subfunctions) for every item in the interface
    %   to control decimal places and the like.
    %    
    %   A callback which activates with the 'start simulation' button and
    %   runs the subfunctions in turn.
    %      
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        GridLayout2_2                  matlab.ui.container.GridLayout
        IntegralKiSlider               matlab.ui.control.Slider
        IntegralKiSliderLabel          matlab.ui.control.Label
        ProportionalKpSlider           matlab.ui.control.Slider
        ProportionalKpSliderLabel      matlab.ui.control.Label
        ControlparametersCsKpKisLabel  matlab.ui.control.Label
        GridLayout6                    matlab.ui.container.GridLayout
        TimingofdisturbancesDropDown   matlab.ui.control.DropDown
        Label                          matlab.ui.control.Label
        OutletpipeblockageSlider       matlab.ui.control.Slider
        OutletpipeblockageSliderLabel  matlab.ui.control.Label
        Disturbanceflowm3sSlider       matlab.ui.control.Slider
        Disturbanceflowm3sSliderLabel  matlab.ui.control.Label
        EnvironmentparametersLabel     matlab.ui.control.Label
        GridLayout4                    matlab.ui.container.GridLayout
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
        ControloftanklevelwithPILabel  matlab.ui.control.Label
        UIAxes                         matlab.ui.control.UIAxes
        UIAxes2                        matlab.ui.control.UIAxes
        UIAxes3                        matlab.ui.control.UIAxes
    end

    
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
        target = 8 % nominal target depth
        targetline1; % handle for target line on tank diagram
        targetline2; % handle for target line on output plots
        targetline3; % handle for target flow line
        targettouse; % actual target used in simulations
        flowinu % handle for flow-in in tank picture
        tankfill % blue colour to show depth in tank
        
        
        disturbanceflow;  % addtional unexpected flow in    
        runtime = 50; % for simulation the runtime
        time;  % variable to store time instants for simulation plots
        samples = 201;
        animationtime = 6; % how long animation will take
        Tsamp=0.1;  % update rate for animation
        G;   % system transfer function (input to output)
        Gb;   % system transfer function with blockage
        Kp   % proportional gain
        Ki   % integral gain
        
        h;  % output  response to target
        u;  % input  response to target
        hd; % output response to dsturbance
        ud  % input response to disturbance 
        hb % output  response to target with blockage
        ub;  % input  response to target with blockage
        hdb; % output response to dsturbance with blockage
        udb  % input response to disturbance with blockage

        ytotal % output due to target and disturbances
        utotal % input
        ytotalb % output with blockage
        utotalb % input

        
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
        outfill=fill(app.UIAxes,[xout],[yout],'b');
        
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
        flowinbottom = fill(app.UIAxes,xflowin2,yflowin2,'b');
        text(app.UIAxes,0.8+app.A,9.8,'Disturbance flow','fontsize',16)

        % main input flow from pipe above tank
        vertpipeinx1 = [0.3+app.A/2,0.3+app.A/2];
        vertpipeinx2 = [0.7+app.A/2,0.7+app.A/2];
        vertpipeiny1 = [11,12];
        plot(app.UIAxes,vertpipeinx1,vertpipeiny1,'k','linewidth',5);
        plot(app.UIAxes,vertpipeinx2,vertpipeiny1,'k','linewidth',5);
        fill(app.UIAxes,[vertpipeinx1,vertpipeinx2],...
            [vertpipeiny1,fliplr(vertpipeiny1)],'b');
        flowinux=[.3+app.A/2,0.3+app.A/2-app.flow*1.2+0.2,...
            0.7+app.A/2+app.flow*1.2-0.2,0.7+app.A/2];
        
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
        
        ylim(app.UIAxes,[0,12])

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
            app.blockvalue=app.OutletpipeblockageSlider.Value;
            app.Rblock=app.R*(100-app.blockvalue)/100; % effective R
            
            % define transfer functions
            % y = G*flowin + G*dist  NO BLOCKAGE
            % y = Gb*flowin + Gb*dist  with BLOCKAGE
            app.G=tf(1,[app.A,app.R]);    % tank model
            app.Gb=tf(1,[app.A,app.Rblock]);  % with blockage

            
        end   % end of create models subfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Manage the animation and legends
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        function app = animationoflineplots(app)
            
            %  Set up legend
            if isempty(app.legstring{1});
                nlegstring=1;
                app.targetline2=plot(app.UIAxes2,[0,app.runtime],[1 1]*app.targettouse,'g--','linewidth',2);
                app.legstring{1} = 'Target depth and expected steady-state flow';
                hold(app.UIAxes2,'on');
                app.targetline3 = plot(app.UIAxes3,[0,app.runtime],[1 1]*app.targettouse*app.R,'g--','linewidth',2);
                hold(app.UIAxes3,'on');
                
            else
                nlegstring = length(app.legstring);
            end
            app.legstring{nlegstring+1}=['A = ',num2str(app.A),', R = ',num2str(app.R),...
                 ', Blockage (%) = ',num2str(app.blockvalue),', Disturbance = ',num2str(app.dist),...
                 ', Kp = ', num2str(app.Kp),', Ki = ',num2str(app.Ki)];
            
           



            % initialise figure for depth response and update target lines
            yplot = plot(app.UIAxes2,app.time(1),app.ytotal(1));
            xlabel(app.UIAxes2,'time (sec)')
            xlim(app.UIAxes2,[0,app.runtime]);
            kk=legend(app.UIAxes2,app.legstring,'Location','southeast');
            set(kk,'fontsize',8);
            grid(app.UIAxes2,'on')
            set(app.targetline2,'Xdata',[0,app.runtime],'Ydata',[1 1]*app.targettouse);
            set(app.targetline3,'Xdata',[0,app.runtime],'Ydata',[1 1]*app.targettouse*app.Rblock);
            set(app.targetline1,'Ydata',[1,1]*(1+app.targettouse));

            % initialise figure for flow response
            uplot = plot(app.UIAxes3,app.time(1),app.utotal(1));
            xlabel(app.UIAxes3,'time (sec)')
            hold(app.UIAxes3,'on')
            xlim(app.UIAxes3,[0,app.runtime]);
            grid(app.UIAxes3,'on')
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% animation of tank and level plot
            % define animation time aspects
            animationsamples = app.animationtime/app.Tsamp; % assume sample time of Tsamp
            updaterate =ceil(app.samples/animationsamples); % no of samples between pauses
            tstart=tic; tsave = tstart;

            
            for k=1:length(app.time);
                     
                % update line plot and tank picture
                set(yplot,'Ydata',app.ytotal(1:k),'Xdata',app.time(1:k));
                set(uplot,'Ydata',app.utotal(1:k),'Xdata',app.time(1:k));
                ytankfill = [1,1+app.ytotal(k),1+app.ytotal(k),1];
                set(app.tankfill,'Ydata',[ytankfill]);
                flowinux=[.3+app.A/2,0.3+app.A/2-app.utotal(k)*0.4+0.2,...
                0.7+app.A/2+app.utotal(k)*0.4-0.2,0.7+app.A/2];
                set(app.flowinu,'Xdata',flowinux);
               
                % Pause animation every updaterate samples only so rem(k,updaterate) 
                % checks for this
                if and(strcmp(app.AnimationOnButton.Text,'Animation On'),not(rem(k,updaterate)));
                    pause(app.Tsamp-toc(tstart));  %% Clumsy application of sampling time
                    tstart = tic;
                    drawnow limitrate
                end
                
            end
            %ttotal= toc(tsave)  % total time taken by animation loop
        end  % end of animation



        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function determines all the closed-loop UNIT step responses
            % Based on current values of the sliders

            function app = closed_loop_responses(app)
      
            % collect compensator and tank values from the sliders
            % round values to avoid unnecessary decimal places
            app.Kp=app.ProportionalKpSlider.Value;
            app.Ki=app.IntegralKiSlider.Value;
            PI =tf([app.Kp,app.Ki],[1 0]);
            app.runtime=round(app.A/app.Rblock,0)*4;
            app.time=linspace(0,app.runtime,app.samples);
            
            % Collect disturbance data from sliders
            app.dist=app.Disturbanceflowm3sSlider.Value;
            app.blockvalue = app.OutletpipeblockageSlider.Value;
 
            %%% FIND CLOSED LOOP MODELS
            %  y = GM/(1+GM)* R +  G/(1+GM) dist
            %  u = M/(1+GM) * R  - GM/(1+GM) dist
            Gc = feedback(app.G*PI,1); % target to depth
            Gcd = feedback(app.G,PI);  % disturbance to depth
            Gcu = feedback(PI,app.G);  % target to in-flow
            Gcud = -Gc;% disturbance to in-flow
            % with blockage
            Gcb = feedback(app.Gb*PI,1); % target to depth
            Gcdb = feedback(app.Gb,PI);  % disturbance to depth
            Gcub = feedback(PI,app.Gb);  % target to in-flow
            Gcudb = -Gcb;% disturbance to in-flow
            
            % find closed-loop responses
            [h]=step(Gc,app.time);    app.h = h*app.target;
            [u]=step(Gcu,app.time);   app.u = u*app.target;
            [hd]=step(Gcd,app.time);  app.hd = hd *app.dist;
            [ud]=step(Gcud,app.time); app.ud = ud*app.dist;
            [hb]=step(Gcb,app.time);    app.hb = hb*app.target;
            [ub]=step(Gcub,app.time);   app.ub = ub*app.target;
            [hdb]=step(Gcdb,app.time);  app.hdb = hdb *app.dist;
            [udb]=step(Gcudb,app.time); app.udb = udb*app.dist;
                     
            % Find disturbance assumption and modify data as required
            
            switch app.TimingofdisturbancesDropDown.Value
                case 'At t=0';
                    % only blockage values needed.
                    app.ytotal = app.hb+app.hdb;
                    app.utotal = app.ub+app.udb;
                    app.targettouse=app.target;
                case 'Mid-simulation disturbance'
                    tt = round(app.samples/2);
                    tt1 = tt:app.samples; 
                    tt2 = 1:(app.samples-tt+1); 
                    app.ytotal = app.h;
                    app.ytotal(tt1) = app.ytotal(tt1)+app.hd(tt2);
                    app.utotal = app.u;
                    app.utotal(tt1) = app.utotal(tt1)+app.ud(tt2);
                    app.targettouse=app.target;
                case 'Blockage from steady-state'
                    % in effect behaviour moves from one ss so one can use
                    % superposition to determine the responses 
                    % LAPLACE:  Y(s) = G(s) U(s) + P(s) y(0)
                    %           U(s) = M(s)[R-Y] + uss/s,  
                    % uss  = (1/dcgain(G))*R;  y(0) = R
                    %
                    % y = Gc*R/s + Gci *uss/s + Gch*h(0)
                    % u = Gcu*R/s + Gcui*uss/s + Gcuh * h(0)
                    app.targettouse=app.target/2;
                    h0 = app.targettouse; 
                    fss = app.targettouse*app.R;
                    
                    P = tf(app.A,[app.A,app.Rblock]);
                    Gci = feedback(app.Gb,PI);  % initial input to depth
                    Gch = feedback(1,app.Gb*PI)*P; % initial depth to final depth
                    Gcui = feedback(1,app.Gb*PI);% initial input to in-flow
                    Gcuh = -feedback(PI,app.Gb)*P; % initial depth to flow

                    h = step(Gcb,app.time); h = h*app.targettouse;
                    hi = step(Gci,app.time); hi = hi*fss;
                    hh = impulse(Gch,app.time); hh = hh*h0;
                    u = step(Gcub,app.time); u = u*app.targettouse;
                    ui = step(Gcui,app.time); ui = ui*fss;
                    uh = impulse(Gcuh,app.time); uh = uh*h0;

                    app.ytotal = h+hi+hh;
                    app.utotal = u+ui+uh;


            end
            
            end   % end of responses subfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Control interaction during the animation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function  disablebuttons(app)
            set(app.SimulateButton, 'Enable', 'off');
            set(app.RefreshButton, 'Enable', 'off');
            set(app.AnimationOnButton, 'Enable', 'off');
            set(app.OutletpipeblockageSlider, 'Enable', 'off');
            set(app.Disturbanceflowm3sSlider, 'Enable', 'off');
            set(app.ProportionalKpSlider, 'Enable', 'off')
            set(app.IntegralKiSlider, 'Enable', 'off')
            set(app.Rm2sSlider, 'Enable', 'off');
            set(app.Aream2Slider, 'Enable', 'off');
            set(app.TimingofdisturbancesDropDown,'Enable','off')
        end
        
        function enablebuttons(app)
            set(app.SimulateButton, 'Enable', 'on');
            set(app.RefreshButton, 'Enable', 'on')
            set(app.AnimationOnButton, 'Enable', 'on')
            set(app.OutletpipeblockageSlider, 'Enable', 'on');
            set(app.Disturbanceflowm3sSlider, 'Enable', 'on');
            set(app.Rm2sSlider, 'Enable', 'on');
            set(app.Aream2Slider, 'Enable', 'on');
            set(app.ProportionalKpSlider, 'Enable', 'on')
            set(app.IntegralKiSlider, 'Enable', 'on')
            set(app.TimingofdisturbancesDropDown,'Enable','on')
        end

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
           % resize to be in middle of  the window
            movegui(app.UIFigure)
            
            % Open the manual
            if exist('tanklevel_and_PIcontrol_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open tanklevel_and_PIcontrol_mycopy.mlx
            else
                p1 = which('tanklevel_and_PIcontrol_manual.mlx');
                p2 = strcat(pwd,'/tanklevel_and_PIcontrol_mycopy.mlx');
                copyfile(p1,p2)                
                open tanklevel_and_PIcontrol_mycopy.mlx
                clear p1 p2
            end

            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);

            app.flow=0;  % to initialise plots
            app = createtankoutline(app); % define car outline for animation
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
                theme(app.UIFigure,"light")
            end
        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
            
            disablebuttons(app);

            app = createmodels(app); % define responses
            app = createtankoutline(app); % define car outline for animation
            app = closed_loop_responses(app); % create responses
            app = animationoflineplots(app); % manage the animations

            enablebuttons(app);

        end

        % Button pushed function: RefreshButton
        function RefreshButtonPushed(app, event)
            %% Clean all the figures and legend so user can begin afresh
             hold(app.UIAxes3,'off')
             hold(app.UIAxes2,'off')
             plot(app.UIAxes3,0,0)
             plot(app.UIAxes2,0,0)
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

        % Callback function
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
            
        end

        % Value changed function: ProportionalKpSlider
        function ProportionalKpSliderValueChanged(app, event)
            value = app.ProportionalKpSlider.Value;
            value=round(value,2);
            app.ProportionalKpSlider.Value=value;
        end

        % Value changed function: IntegralKiSlider
        function IntegralKiSliderValueChanged(app, event)
            value = app.IntegralKiSlider.Value;
            value = round(value*500)/500;
            app.IntegralKiSlider.Value=value;
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
            app.UIFigure.Position = [100 100 1130 934];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '2x'};
            app.GridLayout.RowHeight = {'0.4x', '1.2x', '1.2x', '1.2x'};

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.GridLayout);
            title(app.UIAxes3, 'Input flow responses')
            xlabel(app.UIAxes3, 'Time (s)')
            ylabel(app.UIAxes3, 'Flow (m^3/s)')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.FontSize = 14;
            app.UIAxes3.Layout.Row = 4;
            app.UIAxes3.Layout.Column = 2;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout);
            title(app.UIAxes2, 'Tank level responses')
            xlabel(app.UIAxes2, 'Time (s)')
            ylabel(app.UIAxes2, 'Depth (m)')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 14;
            app.UIAxes2.Layout.Row = 3;
            app.UIAxes2.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Animation of tank level')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.XTick = [];
            app.UIAxes.XTickLabel = '';
            app.UIAxes.YTick = [];
            app.UIAxes.YTickLabel = '';
            app.UIAxes.FontSize = 18;
            app.UIAxes.Layout.Row = 2;
            app.UIAxes.Layout.Column = 2;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = 2;
            app.GridLayout2.BackgroundColor = [0.6 1 1];

            % Create ControloftanklevelwithPILabel
            app.ControloftanklevelwithPILabel = uilabel(app.GridLayout2);
            app.ControloftanklevelwithPILabel.BackgroundColor = [0 1 1];
            app.ControloftanklevelwithPILabel.HorizontalAlignment = 'center';
            app.ControloftanklevelwithPILabel.FontSize = 24;
            app.ControloftanklevelwithPILabel.FontWeight = 'bold';
            app.ControloftanklevelwithPILabel.Layout.Row = 1;
            app.ControloftanklevelwithPILabel.Layout.Column = [1 2];
            app.ControloftanklevelwithPILabel.Text = 'Control of tank level with PI';

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
            app.AnimationOnButton.BackgroundColor = [1 0.2 0.702];
            app.AnimationOnButton.FontSize = 16;
            app.AnimationOnButton.FontWeight = 'bold';
            app.AnimationOnButton.Layout.Row = 1;
            app.AnimationOnButton.Layout.Column = 3;
            app.AnimationOnButton.Text = 'Animation On';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout4.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout4.Layout.Row = 2;
            app.GridLayout4.Layout.Column = 1;
            app.GridLayout4.BackgroundColor = [0.902 1 0.502];

            % Create Aream2SliderLabel
            app.Aream2SliderLabel = uilabel(app.GridLayout4);
            app.Aream2SliderLabel.HorizontalAlignment = 'right';
            app.Aream2SliderLabel.FontSize = 16;
            app.Aream2SliderLabel.Layout.Row = 2;
            app.Aream2SliderLabel.Layout.Column = 1;
            app.Aream2SliderLabel.Text = 'Area (m^2)';

            % Create Aream2Slider
            app.Aream2Slider = uislider(app.GridLayout4);
            app.Aream2Slider.Limits = [0 10];
            app.Aream2Slider.ValueChangedFcn = createCallbackFcn(app, @Aream2SliderValueChanged, true);
            app.Aream2Slider.MinorTicks = [500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000];
            app.Aream2Slider.FontSize = 16;
            app.Aream2Slider.Layout.Row = 2;
            app.Aream2Slider.Layout.Column = 2;
            app.Aream2Slider.Value = 5;

            % Create Rm2sSliderLabel
            app.Rm2sSliderLabel = uilabel(app.GridLayout4);
            app.Rm2sSliderLabel.HorizontalAlignment = 'right';
            app.Rm2sSliderLabel.FontSize = 16;
            app.Rm2sSliderLabel.Layout.Row = 3;
            app.Rm2sSliderLabel.Layout.Column = 1;
            app.Rm2sSliderLabel.Text = 'R (m^2/s)';

            % Create Rm2sSlider
            app.Rm2sSlider = uislider(app.GridLayout4);
            app.Rm2sSlider.Limits = [0 0.5];
            app.Rm2sSlider.ValueChangedFcn = createCallbackFcn(app, @Rm2sSliderValueChanged, true);
            app.Rm2sSlider.MinorTicks = [0 100 200 300 400 500 600 700 800 900 1000];
            app.Rm2sSlider.FontSize = 16;
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

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout6.Layout.Row = 4;
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
            app.Disturbanceflowm3sSlider.MajorTicks = [0 0.05 0.1 0.15 0.2];
            app.Disturbanceflowm3sSlider.ValueChangedFcn = createCallbackFcn(app, @Disturbanceflowm3sSliderValueChanged, true);
            app.Disturbanceflowm3sSlider.MinorTicks = [-20 -15 -10 -5 0 5 10 15 20];
            app.Disturbanceflowm3sSlider.FontSize = 14;
            app.Disturbanceflowm3sSlider.Layout.Row = 2;
            app.Disturbanceflowm3sSlider.Layout.Column = 2;

            % Create OutletpipeblockageSliderLabel
            app.OutletpipeblockageSliderLabel = uilabel(app.GridLayout6);
            app.OutletpipeblockageSliderLabel.HorizontalAlignment = 'right';
            app.OutletpipeblockageSliderLabel.FontSize = 15;
            app.OutletpipeblockageSliderLabel.Layout.Row = 3;
            app.OutletpipeblockageSliderLabel.Layout.Column = 1;
            app.OutletpipeblockageSliderLabel.Text = 'Outlet pipe blockage (%)';

            % Create OutletpipeblockageSlider
            app.OutletpipeblockageSlider = uislider(app.GridLayout6);
            app.OutletpipeblockageSlider.ValueChangedFcn = createCallbackFcn(app, @OutletpipeblockageSliderValueChanged, true);
            app.OutletpipeblockageSlider.FontSize = 15;
            app.OutletpipeblockageSlider.Layout.Row = 3;
            app.OutletpipeblockageSlider.Layout.Column = 2;

            % Create Label
            app.Label = uilabel(app.GridLayout6);
            app.Label.HorizontalAlignment = 'center';
            app.Label.WordWrap = 'on';
            app.Label.FontSize = 15;
            app.Label.Layout.Row = 4;
            app.Label.Layout.Column = 1;
            app.Label.Text = 'Timing of disturbance';

            % Create TimingofdisturbancesDropDown
            app.TimingofdisturbancesDropDown = uidropdown(app.GridLayout6);
            app.TimingofdisturbancesDropDown.Items = {'At t=0', 'Mid-simulation disturbance', 'Blockage from steady-state'};
            app.TimingofdisturbancesDropDown.FontSize = 14;
            app.TimingofdisturbancesDropDown.Layout.Row = 4;
            app.TimingofdisturbancesDropDown.Layout.Column = 2;
            app.TimingofdisturbancesDropDown.Value = 'At t=0';

            % Create GridLayout2_2
            app.GridLayout2_2 = uigridlayout(app.GridLayout);
            app.GridLayout2_2.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout2_2.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout2_2.Layout.Row = 3;
            app.GridLayout2_2.Layout.Column = 1;
            app.GridLayout2_2.BackgroundColor = [1 0.8 0.6];

            % Create ControlparametersCsKpKisLabel
            app.ControlparametersCsKpKisLabel = uilabel(app.GridLayout2_2);
            app.ControlparametersCsKpKisLabel.BackgroundColor = [1 0.502 0.302];
            app.ControlparametersCsKpKisLabel.HorizontalAlignment = 'center';
            app.ControlparametersCsKpKisLabel.FontSize = 18;
            app.ControlparametersCsKpKisLabel.FontWeight = 'bold';
            app.ControlparametersCsKpKisLabel.Layout.Row = 1;
            app.ControlparametersCsKpKisLabel.Layout.Column = [1 2];
            app.ControlparametersCsKpKisLabel.Text = 'Control parameters: C(s) = Kp + Ki/s';

            % Create ProportionalKpSliderLabel
            app.ProportionalKpSliderLabel = uilabel(app.GridLayout2_2);
            app.ProportionalKpSliderLabel.HorizontalAlignment = 'right';
            app.ProportionalKpSliderLabel.FontSize = 16;
            app.ProportionalKpSliderLabel.Layout.Row = 2;
            app.ProportionalKpSliderLabel.Layout.Column = 1;
            app.ProportionalKpSliderLabel.Text = 'Proportional (Kp)';

            % Create ProportionalKpSlider
            app.ProportionalKpSlider = uislider(app.GridLayout2_2);
            app.ProportionalKpSlider.Limits = [0 1];
            app.ProportionalKpSlider.ValueChangedFcn = createCallbackFcn(app, @ProportionalKpSliderValueChanged, true);
            app.ProportionalKpSlider.FontSize = 16;
            app.ProportionalKpSlider.Layout.Row = 2;
            app.ProportionalKpSlider.Layout.Column = 2;
            app.ProportionalKpSlider.Value = 0.2;

            % Create IntegralKiSliderLabel
            app.IntegralKiSliderLabel = uilabel(app.GridLayout2_2);
            app.IntegralKiSliderLabel.HorizontalAlignment = 'right';
            app.IntegralKiSliderLabel.FontSize = 16;
            app.IntegralKiSliderLabel.Layout.Row = 3;
            app.IntegralKiSliderLabel.Layout.Column = 1;
            app.IntegralKiSliderLabel.Text = 'Integral (Ki)';

            % Create IntegralKiSlider
            app.IntegralKiSlider = uislider(app.GridLayout2_2);
            app.IntegralKiSlider.Limits = [0 0.2];
            app.IntegralKiSlider.ValueChangedFcn = createCallbackFcn(app, @IntegralKiSliderValueChanged, true);
            app.IntegralKiSlider.FontSize = 16;
            app.IntegralKiSlider.Layout.Row = 3;
            app.IntegralKiSlider.Layout.Column = 2;
            app.IntegralKiSlider.Value = 0.02;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = tanklevel_and_PIcontrol

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

