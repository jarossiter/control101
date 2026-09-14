classdef invertedpendulum < matlab.apps.AppBase
    %INVERTEDPENDULUM
    %   File written by J.A.Rossiter, University of Sheffield
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %      
    %   A simple interface to practice the behaviour of an inverted
    %   pendulum driven by either a control law and DC servo, or a human
    %   hand.
    %       
    %   Some notes and engineering background are in the partner livescript
    %   file:    invertedpendulum_manual.mlx
    %   A group of similar files can be downloaded through MATLAB add-ons
    %   with the toolbox name: control101
    %   
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   FILE ORGANISATION
    %       A section defining the core variables stored in "app"
    %       
    %       A section with subfunctions doing the core computations
    %       i) define models for open and closed-loop behaviour; 
    %       ii) find linear responses for non-zero initial condition; 
    %       iii) initialise figures for animations; 
    %       vi) control the animations
    %       v) Switch interaction on and off during animations
    %       vi) Clean figures and legends so can begin a new investigation
    %       vii) callbacks (subfunctions) for every item in the interface
    %   to control decimal places and the like.
    %       
    %   A core subfunction (callback) activates with the 'start simulation'
    %   button and runs the subfunctions in turn.
    %       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        GridLayout6_2                 matlab.ui.container.GridLayout
        NOHUMANButton                 matlab.ui.control.Button
        HumanornotLabel               matlab.ui.control.Label
        DelaysSlider                  matlab.ui.control.Slider
        DelaysSliderLabel             matlab.ui.control.Label
        FrequencyvradsSlider          matlab.ui.control.Slider
        FrequencyvradsSliderLabel     matlab.ui.control.Label
        HumaninloopparametersHuman025esTs2vsv2Label  matlab.ui.control.Label
        GridLayout6                   matlab.ui.container.GridLayout
        FrequencywradsSlider          matlab.ui.control.Slider
        FrequencywradsSliderLabel     matlab.ui.control.Label
        MotorlagparametersLag025s2wsw2Label  matlab.ui.control.Label
        DetailedanalysisoffirstordermodelparametersPanel  matlab.ui.container.Panel
        GridLayout5                   matlab.ui.container.GridLayout
        UIAxes2                       matlab.ui.control.UIAxes
        UIAxes3                       matlab.ui.control.UIAxes
        GridLayout4                   matlab.ui.container.GridLayout
        LeadcompensatorMsKs3s10Label  matlab.ui.control.Label
        ChoiceofKSlider               matlab.ui.control.Slider
        ChoiceofKSliderLabel          matlab.ui.control.Label
        GridLayout3                   matlab.ui.container.GridLayout
        AnimationOnButton             matlab.ui.control.Button
        RefreshButton                 matlab.ui.control.Button
        SimulateButton                matlab.ui.control.Button
        GridLayout2                   matlab.ui.container.GridLayout
        Image                         matlab.ui.control.Image
        InvertedpendulumhumanintheloopLabel  matlab.ui.control.Label
        UIAxes                        matlab.ui.control.UIAxes
    end


   
% The next section defines all the core variables used in the code and
% that it may be convenient to have available in the various
% subfunctions

    properties (Access = private)
        % for text scaling
        originalsize     % product of width and height for font sizing


        legstring=cell(1); % To store legends
        legtemp; % store temporary legend information
        
        % Animation handles
        motor % outline of motor
        spoke % spokes to represent actual movement
        spoke2 % spokes to represent desired movement
        pendulum % handle for the pendulum
        pendulumlength = 2.6;
        cart % handles for the cart picture
        cartx
        carty
        tape1 % handle for the tape
        manualormotor=1;  % hand operation with dc servo
        hand;  % to store hand coordinates
        handx

        K ; % compensator gain
        delay; % human caused delay
        w; % freq for lag of motor
        v; % freq for lag of human
        human;  % 1 means no human and 0 means include

        runtime=2; % for simulation the runtime
        runtimefast = 3; % if no human in the loop
        runtimeslow = 5; % if human in the loop
        samples=201;  % number of samples
        time;  % variable to store time instants for simulation plots
        animationtime = 10; % how long animation will take
        Tsamp=0.1;  % update rate for animation
        theta; % angle for spokes and motor
        theta2;  
        r; % spoke radius
        r2 ; % inner radius
        motoru1;  % desired u
        motoru2;  % actual u
        initial=0.1;  % initial deflection
        pivot % for the axle
        pivotx
        
    end
    
    methods (Access = private)
        


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  PLOT OF TOP FIGURE - THE PENDULUM ANIMATION
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  Down load data from sliders and create models and responses
 %%%%%%%%%  for given non-zero initial condition
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function app = createmodels(app)

            % Define the model with output theta as 4th state and
            % displacement of cart as 3rd state
            % desired motor 'input' is the input
            b=0.3; k=1; g=9.8;
            A = [0 0 0 0; 0 -b 0 g;1 0 0 0;0 1 0 0];
            B = [k;1;0;0];
            C = [0 0 0 1;0 0 1 0];
            D = [0;0];
            G = ss(A,B,C,D); % ouput is [theta;x]
            G1 = ss(A,B,C(1,:),D(1,:)); % output is cart angle only
            
            % Collect values from sliders and buttons
            app.K = app.ChoiceofKSlider.Value;
            app.w = app.FrequencywradsSlider.Value;
            app.v = app.FrequencyvradsSlider.Value;
            app.delay = app.DelaysSlider.Value;

            % Define lead compensator
            Klead = app.K*tf([1 3],[1 10]);
                      
            % Check with using motor or human and modify parameters
            app.human = app.NOHUMANButton.Text;
            switch app.human
                case 'NO HUMAN'
                    humanlag = 1;
                    humandelay = 1;
                    app.legtemp =[', w = ',num2str(app.w), ', No Human'];
                    app.runtime = app.runtimefast;
                     % define lag model ofr motor. 
                    motorlag = tf(0.25*[1,2*app.w],[1,0.5*app.w]);
                    
                case 'USE HUMAN'
                    humanlag = tf(0.25*[1,2*app.v],[1,0.5*app.v]);
                    humandelay = tf(1,1,'iodelay',app.delay);
                    humandelay = pade(humandelay,5);  %Approximate delay with Pade
                    app.legtemp = [', v = ',num2str(app.v),', Delay = ',num2str(app.delay)];
                    app.runtime=app.runtimeslow;
                    % define lag model for motor as 1 as not using motor. 
                    motorlag = 1;
                    
            end
                       

            
            
            % define closed-loop transferences noting G has 2 outputs but
            % only the first is used for the feedback
            % theta and x and u
            Gcy = feedback(G*Klead*motorlag*humanlag*humandelay,[1,0],1,[1;2],-1);
            nstates = order(Gcy);

            % desired signal u and actual implemented signal
            Gcu1 = feedback(Klead,G1*motorlag*humanlag*humandelay);
            Gcu2 = feedback(Klead*motorlag*humanlag*humandelay,G1);
          
            % Define the responses for a non-zero initial condition
            X0 = [0;0;0;app.initial;zeros(nstates-4,1)];       % initial condition
            X0u1 = [0;0;0;0;app.initial;zeros(nstates-5,1)];       % initial condition
            X0u2 = [zeros(nstates-1,1);app.initial];       % initial condition
            app.time=linspace(0,app.runtime,app.samples);
            target = zeros(1,app.samples);
            app.theta = lsim(Gcy,target,app.time,X0);
            app.motoru1 = lsim(Gcu1,target,app.time,X0u1);
            app.motoru2 = lsim(Gcu2,target,app.time,X0u2);
            
        end   % end of create models subfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Manage the animation and legends
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        function app = animationoflineplots(app)
            
            %  Set up legend
            if isempty(app.legstring{1});
                nlegstring=0;
            else
                nlegstring = length(app.legstring);
            end
            app.legstring{nlegstring+1}=['K = ',num2str(app.K),app.legtemp];
            
            % initialise figure for angle response
            yplot = plot(app.UIAxes3,app.time(1),app.theta(1,1));
            xlabel(app.UIAxes3,'time (sec)');
            hold(app.UIAxes3,'on');
            grid(app.UIAxes3,'on');
            kk=legend(app.UIAxes3,app.legstring,'Location','southeast');
            set(kk,'fontsize',8);
            
            % initialise figure for input response
            u1plot = plot(app.UIAxes2,app.time(1),app.motoru1(1,1));
            xlabel(app.UIAxes2,'time (sec)');
            hold(app.UIAxes2,'on');
            grid(app.UIAxes2,'on');
            u2plot = plot(app.UIAxes2,app.time(1),app.motoru2(1,1));
            kk=legend(app.UIAxes2,'Desired u','Actual u','Location','southeast');
            set(kk,'fontsize',8);
            hold(app.UIAxes2,'off');

            % Add a pause so initial condition clear before simulation
            % begins
            if app.manualormotor==1;pause(1);end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% animation of tank and concentration plot
            

            % Control animation timing aspects
            animationsamples = app.animationtime/app.Tsamp; % assume sample time of Tsamp
            updaterate =ceil(app.samples/animationsamples); % no of samples between pauses
            tstart=tic; tsave = tstart;

                        
            for k=1:length(app.time);  % loop to control animation
                
                % Update line plots
                set(yplot,'Ydata',app.theta(1:k,1),'Xdata',app.time(1:k));
                set(u1plot,'Ydata',app.motoru1(1:k,1),'Xdata',app.time(1:k));
                set(u2plot,'Ydata',app.motoru2(1:k,1),'Xdata',app.time(1:k));
                
                % update cart, pendulum 
                x1 = app.theta(k,2);
                x2 = -app.pendulumlength*app.theta(k,1)+x1;
                set(app.pendulum,'Xdata',[x1,x2]);
                set(app.cart,'Xdata',app.cartx+x1);
                set(app.pivot,'Xdata',app.pivotx+x1);

                % Conditional to change animation for use of motor or human
                if app.manualormotor==1;
                % update motor spokes: Assume change angle = x1;
                    theta2 = app.theta2+app.motoru1(k)/3;
                    theta3 = app.theta2+app.motoru2(k)/3;
                    tapeend=-1.5;
                    r=app.r;r2=app.r2;
                    for ns=1:3;
                        newx = [r*cos(theta2(ns))+tapeend-r,r*cos(theta2(ns)+pi)+tapeend-r];
                        newy = [1.25+r*sin(theta2(ns))-r,1.25+r*sin(theta2(ns)+pi)-r];
                        set(app.spoke{ns}.handle,'Xdata',newx,'Ydata',newy);
                        newx2 = [r2*cos(theta3(ns))+tapeend-r,r2*cos(theta3(ns)+pi)+tapeend-r];
                        newy2 = [1.25+r2*sin(theta3(ns))-r,1.25+r2*sin(theta3(ns)+pi)-r];
                        set(app.spoke2{ns}.handle,'Xdata',newx2,'Ydata',newy2);
                    end

                else  % update animation of hand
                  set(app.hand,'Xdata',app.handx+x1);
                end
  
                % Pause animation every updaterate samples only so rem(k,updaterate) 
                % checks for this
                if and(strcmp(app.AnimationOnButton.Text,'Animation On'),not(rem(k,updaterate)));
                    pause(app.Tsamp-toc(tstart));  %% Clumsy application of sampling time
                    tstart = tic;
                    drawnow limitrate
                end
            end
            grid(app.UIAxes2,"on");
                   

        end  % end of animation

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Control interaction during the animation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function  disablebuttons(app)
            set(app.SimulateButton, 'Enable', 'off');
            set(app.RefreshButton, 'Enable', 'off')
            set(app.AnimationOnButton, 'Enable', 'off')
            set(app.FrequencywradsSlider, 'Enable', 'off')
            set(app.FrequencyvradsSlider, 'Enable', 'off')
            set(app.ChoiceofKSlider, 'Enable', 'off')
            set(app.DelaysSlider, 'Enable', 'off')
     
        end
        
        function enablebuttons(app)
            set(app.SimulateButton, 'Enable', 'on');
            set(app.RefreshButton, 'Enable', 'on');
            set(app.AnimationOnButton, 'Enable', 'on');
            set(app.FrequencyvradsSlider, 'Enable', 'on')
            set(app.FrequencywradsSlider, 'Enable', 'on')
            set(app.ChoiceofKSlider, 'Enable', 'on')
            set(app.DelaysSlider, 'Enable', 'on')
        end

% Sets up picture of the cart, motor, tape and pendulum 
% along with handles for the all components which will move 
% during the animation      
        function app = cartpicture(app);
            
        hold(app.UIAxes,'off');
        cla(app.UIAxes)
        
        set(app.UIAxes,'XTickLabel',{' ',' '},'XTick',[-4 2]);
        set(app.UIAxes,'YTickLabel',{' ',' '},'YTick',[-1,4]);   
        hold(app.UIAxes,'on')
        
       
        theta = linspace(0,2*pi,60);
        r=0.6; r2 = r*0.7;
        app.r=r; app.r2=r2;
        tapeend=-1.5;
        xmotor = r*cos(theta)+tapeend-r;
        ymotor = 1.25+r*sin(theta)-r;

        if app.manualormotor==1;  % include motor
        %%%%%%%%%%%%%%%%%%%%% PLOT MOTOR
        % motor and spokes to represent rotation 
        app.motor = plot(app.UIAxes,xmotor,ymotor,'g','linewidth',4);
        theta2=[0,pi/3,2*pi/3];
        app.theta2=theta2;
        spoke = cell(1); spoke2 = cell(1);
        for k=1:length(theta2);
            spoke{k}.x = [r*cos(theta2(k))+tapeend-r,r*cos(theta2(k)+pi)+tapeend-r];
            spoke{k}.y = [1.25+r*sin(theta2(k))-r,1.25+r*sin(theta2(k)+pi)-r];
            spoke{k}.handle = plot(app.UIAxes,spoke{k}.x,spoke{k}.y,'b-','linewidth',3);
        
            spoke2{k}.x = [r2*cos(theta2(k))+tapeend-r,r2*cos(theta2(k)+pi)+tapeend-r];
            spoke2{k}.y = [1.25+r2*sin(theta2(k))-r,1.25+r2*sin(theta2(k)+pi)-r];
            spoke2{k}.handle = plot(app.UIAxes,spoke2{k}.x,spoke2{k}.y,'r-','linewidth',3);
        end  
        app.spoke = spoke;   % actual motor movement
        app.spoke2 = spoke2; % demand movement sent to motor
        text(app.UIAxes,-2.7,2,'Red spokes: actual u','fontsize',20)
        text(app.UIAxes,-2.7,1.7,'Blue spokes: desired u','fontsize',20)
        text(app.UIAxes,-2.8,2.4,'USING A MOTOR','fontsize',20,'color',[0 0 1])
        %%%%%%%%%%%%%%%%%%%%%

        else  % include hand
            app.handx=[0 -0.05 -0.1 -0.3 -0.5 -0.47 -0.35 -0.2 0.1 0.05 -0.1 -0.05 0.1 0.3 0.4,0.45,...
            0.45 0.55,0.65,0.65 0.65 0.85 0.95,1.05 1.1 1.1 1.0 0.9 0.9 1 1.2 1.5 1.55 1.4,...
             1.2,1]*0.7-1.5;
            y=[0 0.4 0.8 1.1 1.5 1.6 1.6 1.3 1.1 1.4 1.9 2 1.95 1.5 1.2,1.55,...
               2 2.2 2.1 1.6 1.2 1.5 1.9 2 1.8 1.4 1.2 0.9 0.7 0.65 0.8 0.85 0.75,0.6,...
              0.4 0]*0.6 + 0.6;
            app.hand=fill(app.UIAxes,app.handx,y,'r'); %,'FaceColor',[0.5,0.5,0.5])
            set(app.hand,'FaceColor',[1 0.4 0.3]);
            text(app.UIAxes,-2.4,2.4,'USING A HUMAN HAND','fontsize',20,'color',[0 0 1])
        end
        
        % tape for pulling cart   
        tapex1=[tapeend-r,1]; tapey1 = [1.25,1.25];
        app.tape1 = plot(app.UIAxes,tapex1,[tapey1],'k--','linewidth',4);
        tape3 = plot(app.UIAxes,[tapex1],[tapey1]-2*r,'k--','linewidth',4);
        
        % cart (Needs to go over the tape)
        app.cartx=[-0.5,-0.5,0.5,0.5];
        app.carty=[1 1.5,1.5 1];
        app.cart = fill(app.UIAxes,app.cartx,app.carty,'r');
        
        % Pendulum (Needs to go over the cart)
        pendulumx = [0 -app.pendulumlength*app.initial];
        pendulumy = [1.2,1.2+app.pendulumlength];
        app.pendulum = plot(app.UIAxes,pendulumx,pendulumy,'b','linewidth',6);
        app.pivotx = pendulumx(1);
        app.pivot=plot(app.UIAxes,pendulumx(1),pendulumy(1),'y.','markersize',40);

        
        
        xlim(app.UIAxes,[-3,1]);
        end
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % resize to be in middle of  the window
            movegui(app.UIFigure)
            
            % Open the manual
            if exist('invertedpendulum_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open invertedpendulum_mycopy.mlx
            else
                p1 = which('invertedpendulum_manual.mlx');
                p2 = strcat(pwd,'/invertedpendulum_mycopy.mlx');
                copyfile(p1,p2)                
                open invertedpendulum_mycopy.mlx
                clear p1 p2
            end
            
            % draw cart and update handles
            app = cartpicture(app);
           
           % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
            theme(app.UIFigure,"light")
            end
    
        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
            
            disablebuttons(app);
 
            app = cartpicture(app); % define tank outline for animation
            app = createmodels(app); % define models and responses
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
             app=cartpicture(app);
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

        % Value changed function: ChoiceofKSlider
        function ChoiceofKSliderValueChanged(app, event)
            value = app.ChoiceofKSlider.Value;
            value = round(value,-1); % precise to 10
            if value<10; value =10;end % no silly choices
            app.ChoiceofKSlider.Value=value;
             

        end

        % Value changed function: FrequencywradsSlider
        function FrequencywradsSliderValueChanged(app, event)
            value = app.FrequencywradsSlider.Value;
            value = round(value,-1); % precise to 10
            if value<10;value =10;end; % small values are nonsense
            app.FrequencywradsSlider.Value=value;           
        end

        % Value changed function: FrequencyvradsSlider
        function FrequencyvradsSliderValueChanged(app, event)
            value = app.FrequencyvradsSlider.Value;
            value = round(value,0); % precise to 1
            if value<10;value = 10;end; % small values are nonsense
            app.FrequencyvradsSlider.Value=value;           
        end

        % Value changed function: DelaysSlider
        function DelaysSliderValueChanged(app, event)
            value = app.DelaysSlider.Value;
            value = round(value,2); % precise to 0.01
            %if value<0.1;value =0.1;end; % small values are nonsense
            app.DelaysSlider.Value = value;             
        end

        % Button pushed function: NOHUMANButton
        function NOHUMANButtonPushed(app, event)
            val = app.NOHUMANButton.Text;
            if strcmp(val,'NO HUMAN');
                val = 'USE HUMAN';
                app.manualormotor=0;
            else
                val = 'NO HUMAN';
                app.manualormotor=1;
            end
            app.NOHUMANButton.Text=val;
            app = cartpicture(app);

            
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
            app.UIFigure.Position = [100 100 1099 852];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1.1x', '2x'};
            app.GridLayout.RowHeight = {'0.4x', '0.7x', '0.8x', '1.4x', '2x'};

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Animation of pendulum')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.XTickLabel = '';
            app.UIAxes.YTickLabel = '';
            app.UIAxes.FontSize = 24;
            app.UIAxes.Layout.Row = [2 4];
            app.UIAxes.Layout.Column = 2;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = 2;
            app.GridLayout2.BackgroundColor = [0.6 1 1];

            % Create InvertedpendulumhumanintheloopLabel
            app.InvertedpendulumhumanintheloopLabel = uilabel(app.GridLayout2);
            app.InvertedpendulumhumanintheloopLabel.BackgroundColor = [0 1 1];
            app.InvertedpendulumhumanintheloopLabel.HorizontalAlignment = 'center';
            app.InvertedpendulumhumanintheloopLabel.FontSize = 24;
            app.InvertedpendulumhumanintheloopLabel.FontWeight = 'bold';
            app.InvertedpendulumhumanintheloopLabel.Layout.Row = 1;
            app.InvertedpendulumhumanintheloopLabel.Layout.Column = [1 2];
            app.InvertedpendulumhumanintheloopLabel.Text = 'Inverted pendulum: human in the loop';

            % Create Image
            app.Image = uiimage(app.GridLayout2);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 3;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'UoSlogo.png');

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout);
            app.GridLayout3.ColumnWidth = {'1x', '0.9x', '1.1x'};
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
            app.RefreshButton.WordWrap = 'on';
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
            app.GridLayout4.Layout.Row = 2;
            app.GridLayout4.Layout.Column = 1;
            app.GridLayout4.BackgroundColor = [1 0.8 0.6];

            % Create ChoiceofKSliderLabel
            app.ChoiceofKSliderLabel = uilabel(app.GridLayout4);
            app.ChoiceofKSliderLabel.HorizontalAlignment = 'right';
            app.ChoiceofKSliderLabel.FontSize = 16;
            app.ChoiceofKSliderLabel.Layout.Row = 2;
            app.ChoiceofKSliderLabel.Layout.Column = 1;
            app.ChoiceofKSliderLabel.Text = 'Choice of K';

            % Create ChoiceofKSlider
            app.ChoiceofKSlider = uislider(app.GridLayout4);
            app.ChoiceofKSlider.Limits = [0 200];
            app.ChoiceofKSlider.ValueChangedFcn = createCallbackFcn(app, @ChoiceofKSliderValueChanged, true);
            app.ChoiceofKSlider.MinorTicks = [500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000];
            app.ChoiceofKSlider.FontSize = 16;
            app.ChoiceofKSlider.Layout.Row = 2;
            app.ChoiceofKSlider.Layout.Column = 2;
            app.ChoiceofKSlider.Value = 70;

            % Create LeadcompensatorMsKs3s10Label
            app.LeadcompensatorMsKs3s10Label = uilabel(app.GridLayout4);
            app.LeadcompensatorMsKs3s10Label.BackgroundColor = [1 0.502 0.302];
            app.LeadcompensatorMsKs3s10Label.HorizontalAlignment = 'center';
            app.LeadcompensatorMsKs3s10Label.FontSize = 18;
            app.LeadcompensatorMsKs3s10Label.FontWeight = 'bold';
            app.LeadcompensatorMsKs3s10Label.Layout.Row = 1;
            app.LeadcompensatorMsKs3s10Label.Layout.Column = [1 2];
            app.LeadcompensatorMsKs3s10Label.Text = 'Lead compensator: M(s) = K (s+3)/(s+10)';

            % Create DetailedanalysisoffirstordermodelparametersPanel
            app.DetailedanalysisoffirstordermodelparametersPanel = uipanel(app.GridLayout);
            app.DetailedanalysisoffirstordermodelparametersPanel.AutoResizeChildren = 'off';
            app.DetailedanalysisoffirstordermodelparametersPanel.TitlePosition = 'centertop';
            app.DetailedanalysisoffirstordermodelparametersPanel.Title = 'Detailed time response analysis of closed-loop behaviour';
            app.DetailedanalysisoffirstordermodelparametersPanel.BackgroundColor = [0.902 0.702 1];
            app.DetailedanalysisoffirstordermodelparametersPanel.Layout.Row = 5;
            app.DetailedanalysisoffirstordermodelparametersPanel.Layout.Column = [1 2];
            app.DetailedanalysisoffirstordermodelparametersPanel.FontWeight = 'bold';
            app.DetailedanalysisoffirstordermodelparametersPanel.FontSize = 18;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.DetailedanalysisoffirstordermodelparametersPanel);
            app.GridLayout5.RowHeight = {'1x'};

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.GridLayout5);
            title(app.UIAxes3, 'Time response of angle \theta')
            xlabel(app.UIAxes3, 'Time (s)')
            ylabel(app.UIAxes3, 'Angle')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.FontSize = 14;
            app.UIAxes3.Layout.Row = 1;
            app.UIAxes3.Layout.Column = 1;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout5);
            title(app.UIAxes2, 'Time response of force (desired and actual force)')
            xlabel(app.UIAxes2, 'Time (s)')
            ylabel(app.UIAxes2, 'Motor movement')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 14;
            app.UIAxes2.Layout.Row = 1;
            app.UIAxes2.Layout.Column = 2;

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout6.Layout.Row = 3;
            app.GridLayout6.Layout.Column = 1;
            app.GridLayout6.BackgroundColor = [0.702 1 0.702];

            % Create MotorlagparametersLag025s2wsw2Label
            app.MotorlagparametersLag025s2wsw2Label = uilabel(app.GridLayout6);
            app.MotorlagparametersLag025s2wsw2Label.BackgroundColor = [0 1 0];
            app.MotorlagparametersLag025s2wsw2Label.HorizontalAlignment = 'center';
            app.MotorlagparametersLag025s2wsw2Label.WordWrap = 'on';
            app.MotorlagparametersLag025s2wsw2Label.FontSize = 18;
            app.MotorlagparametersLag025s2wsw2Label.FontWeight = 'bold';
            app.MotorlagparametersLag025s2wsw2Label.Layout.Row = 1;
            app.MotorlagparametersLag025s2wsw2Label.Layout.Column = [1 2];
            app.MotorlagparametersLag025s2wsw2Label.Text = {'Motor lag parameters: '; 'Lag = 0.25 (s+2w)/(s+w/2)'};

            % Create FrequencywradsSliderLabel
            app.FrequencywradsSliderLabel = uilabel(app.GridLayout6);
            app.FrequencywradsSliderLabel.HorizontalAlignment = 'right';
            app.FrequencywradsSliderLabel.FontSize = 14;
            app.FrequencywradsSliderLabel.Layout.Row = 2;
            app.FrequencywradsSliderLabel.Layout.Column = 1;
            app.FrequencywradsSliderLabel.Text = 'Frequency w (rad/s)';

            % Create FrequencywradsSlider
            app.FrequencywradsSlider = uislider(app.GridLayout6);
            app.FrequencywradsSlider.Limits = [0 200];
            app.FrequencywradsSlider.ValueChangedFcn = createCallbackFcn(app, @FrequencywradsSliderValueChanged, true);
            app.FrequencywradsSlider.FontSize = 14;
            app.FrequencywradsSlider.Layout.Row = 2;
            app.FrequencywradsSlider.Layout.Column = 2;
            app.FrequencywradsSlider.Value = 200;

            % Create GridLayout6_2
            app.GridLayout6_2 = uigridlayout(app.GridLayout);
            app.GridLayout6_2.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout6_2.RowHeight = {'1x', '1x', '1x', '0.8x'};
            app.GridLayout6_2.Layout.Row = 4;
            app.GridLayout6_2.Layout.Column = 1;
            app.GridLayout6_2.BackgroundColor = [0.702 1 0.702];

            % Create HumaninloopparametersHuman025esTs2vsv2Label
            app.HumaninloopparametersHuman025esTs2vsv2Label = uilabel(app.GridLayout6_2);
            app.HumaninloopparametersHuman025esTs2vsv2Label.BackgroundColor = [0 1 0];
            app.HumaninloopparametersHuman025esTs2vsv2Label.HorizontalAlignment = 'center';
            app.HumaninloopparametersHuman025esTs2vsv2Label.WordWrap = 'on';
            app.HumaninloopparametersHuman025esTs2vsv2Label.FontSize = 18;
            app.HumaninloopparametersHuman025esTs2vsv2Label.FontWeight = 'bold';
            app.HumaninloopparametersHuman025esTs2vsv2Label.Layout.Row = 1;
            app.HumaninloopparametersHuman025esTs2vsv2Label.Layout.Column = [1 2];
            app.HumaninloopparametersHuman025esTs2vsv2Label.Text = {'Human in loop parameters: '; 'Human= 0.25 e^{-sT} (s+2v)/(s+v/2)'};

            % Create FrequencyvradsSliderLabel
            app.FrequencyvradsSliderLabel = uilabel(app.GridLayout6_2);
            app.FrequencyvradsSliderLabel.HorizontalAlignment = 'right';
            app.FrequencyvradsSliderLabel.FontSize = 14;
            app.FrequencyvradsSliderLabel.Layout.Row = 2;
            app.FrequencyvradsSliderLabel.Layout.Column = 1;
            app.FrequencyvradsSliderLabel.Text = 'Frequency v (rad/s)';

            % Create FrequencyvradsSlider
            app.FrequencyvradsSlider = uislider(app.GridLayout6_2);
            app.FrequencyvradsSlider.Limits = [10 20];
            app.FrequencyvradsSlider.ValueChangedFcn = createCallbackFcn(app, @FrequencyvradsSliderValueChanged, true);
            app.FrequencyvradsSlider.FontSize = 14;
            app.FrequencyvradsSlider.Layout.Row = 2;
            app.FrequencyvradsSlider.Layout.Column = 2;
            app.FrequencyvradsSlider.Value = 20;

            % Create DelaysSliderLabel
            app.DelaysSliderLabel = uilabel(app.GridLayout6_2);
            app.DelaysSliderLabel.HorizontalAlignment = 'right';
            app.DelaysSliderLabel.FontSize = 16;
            app.DelaysSliderLabel.Layout.Row = 3;
            app.DelaysSliderLabel.Layout.Column = 1;
            app.DelaysSliderLabel.Text = 'Delay (s)';

            % Create DelaysSlider
            app.DelaysSlider = uislider(app.GridLayout6_2);
            app.DelaysSlider.Limits = [0 0.1];
            app.DelaysSlider.ValueChangedFcn = createCallbackFcn(app, @DelaysSliderValueChanged, true);
            app.DelaysSlider.FontSize = 16;
            app.DelaysSlider.Layout.Row = 3;
            app.DelaysSlider.Layout.Column = 2;

            % Create HumanornotLabel
            app.HumanornotLabel = uilabel(app.GridLayout6_2);
            app.HumanornotLabel.BackgroundColor = [0.702 1 0.702];
            app.HumanornotLabel.HorizontalAlignment = 'right';
            app.HumanornotLabel.FontSize = 16;
            app.HumanornotLabel.Layout.Row = 4;
            app.HumanornotLabel.Layout.Column = 1;
            app.HumanornotLabel.Text = 'Human or not';

            % Create NOHUMANButton
            app.NOHUMANButton = uibutton(app.GridLayout6_2, 'push');
            app.NOHUMANButton.ButtonPushedFcn = createCallbackFcn(app, @NOHUMANButtonPushed, true);
            app.NOHUMANButton.FontSize = 18;
            app.NOHUMANButton.Layout.Row = 4;
            app.NOHUMANButton.Layout.Column = 2;
            app.NOHUMANButton.Text = 'NO HUMAN';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = invertedpendulum

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

