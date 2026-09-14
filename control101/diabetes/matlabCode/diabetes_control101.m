classdef diabetes_control101 < matlab.apps.AppBase
    %DIABETES_CONTROL101
    %   File written by J.A.Rossiter, University of Sheffield  
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   
    %   This app is to allow users to explore the impact of diabetes on the
    %   blood sugar levels of sufferers and the potential of control to
    %   manage this better. Largely the interaction is obvious and simple.
    %   
    %   Some notes and engineering background are in the partner
    %   livescript file:    lead_design_phase_margin_manual.mlx
    %   A group of similar files can be downloaded through MATLAB
    %   add-ons with the toolbox name:  control101

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        GridLayout                matlab.ui.container.GridLayout
        TabGroup                  matlab.ui.container.TabGroup
        IndividualcomparisonsTab  matlab.ui.container.Tab
        GridLayout16              matlab.ui.container.GridLayout
        UIAxes2_2                 matlab.ui.control.UIAxes
        UIAxes2                   matlab.ui.control.UIAxes
        EverythingoverlaidTab     matlab.ui.container.Tab
        GridLayout13              matlab.ui.container.GridLayout
        UIAxes_5                  matlab.ui.control.UIAxes
        UIAxes_4                  matlab.ui.control.UIAxes
        UIAxes_2                  matlab.ui.control.UIAxes
        UIAxes                    matlab.ui.control.UIAxes
        GridLayout12              matlab.ui.container.GridLayout
        TabGroup2                 matlab.ui.container.TabGroup
        ChoosecomparisonTab       matlab.ui.container.Tab
        GridLayout15              matlab.ui.container.GridLayout
        MIMOfbkButton             matlab.ui.control.Button
        InsulinfbkButton          matlab.ui.control.Button
        ExerciseButton            matlab.ui.control.Button
        GlucosefbkButton          matlab.ui.control.Button
        InsulinButton             matlab.ui.control.Button
        HealthyButton             matlab.ui.control.Button
        FoodButton                matlab.ui.control.Button
        DisturbancetimingTab      matlab.ui.container.Tab
        GridLayout14              matlab.ui.container.GridLayout
        UIAxes_3                  matlab.ui.control.UIAxes
        GridLayout6               matlab.ui.container.GridLayout
        InjectionSlider           matlab.ui.control.Slider
        InjectionSliderLabel      matlab.ui.control.Label
        ExerciseSlider            matlab.ui.control.Slider
        ExerciseSliderLabel       matlab.ui.control.Label
        FoodSlider                matlab.ui.control.Slider
        FoodSliderLabel           matlab.ui.control.Label
        InputsLabel               matlab.ui.control.Label
        GridLayout3               matlab.ui.container.GridLayout
        GridLayout10              matlab.ui.container.GridLayout
        SimulateButton            matlab.ui.control.Button
        GridLayout2               matlab.ui.container.GridLayout
        Image                     matlab.ui.control.Image
        BloodsugarlevelswithdiabetesLabel  matlab.ui.control.Label
    end

    
    
    
    % The next section defines all the core variables used in the code and
    % that it may be convenient to have available in the various
    % subfunctions
    properties (Access = private)
        Ghealthy % model injection to glucose
        
        Tsamp = 0.1;   % real time in hrs is Tsamp/5
        Gdhealthy % Discrete model
        Adh   % State space matrices for discrete model
        Bdh
        Cdh
        Ddh            
        Kinsulinh  % Controllers for healthy model
        Kglucoseh
        Kmimoh
               
        % Unhealthy parameters
        Gunhealthy % model injection to glucose
        Gdunhealthy % Discrete model
        Adu   % State space matrices for discrete model
        Bdu
        Cdu
        Ddu            
        Kinsulinu  % Controllers for healthy model
        Kglucoseu
        Kmimou     

        controllaw = 1     % control law choice
        originalsize    % for managing window resize
        runtime=299;
        individualchoice_disturbance =[0;1;0];
        individualchoice_control = [1];
        individualchoice_healthy = [1;0];

          
    end
    
    methods (Access = private)
        
 
        
        function app = createmodel(app)
            % Healthy person
            % x1 is blood sugar and x2 is blood insulin
            % u1 is insulin dosage, u2 is food intake and u3 is exercise
            a=0.5;b=1;f=1;g=1; k=1;d=1;m=1;  
            A=[-a -b;f -g];
            B  = [0 d -m;k 0 0]; 
            C=eye(2);
            D = zeros(2,3);
            Q =diag([10,1]);
            
            app.Ghealthy =ss(A,B,C,D); % continuous model 
            app.Gdhealthy = c2d(app.Ghealthy,app.Tsamp);  % DISCRETE MODEL
            [app.Adh,app.Bdh,app.Cdh,app.Ddh]=ssdata(app.Gdhealthy); % state space parameters
            app.Kinsulinh=[dlqr(app.Adh,app.Bdh(:,1),Q,1);0 0];  %% fbk law using injection
            app.Kglucoseh=[0 0;dlqr(app.Adh,app.Bdh(:,2),Q,1)];  %% fbk law using glucose
            app.Kmimoh=dlqr(app.Adh,app.Bdh(:,1:2),Q,eye(2));  %% fbk law using both
           
            % unhealthy person
            a=0.5;b=1;f=0.1;g=1;k=1;d=1;m=1;
            A=[-a -b;f -g];
            B  = [0 d -m;k 0 0]; 
            C=eye(2);
            D = zeros(2,3);
            app.Gunhealthy =ss(A,B,C,D); % model injection to glucose
            app.Gdunhealthy = c2d(app.Gunhealthy,app.Tsamp);  % DISCRETE MODEL
            [app.Adu,app.Bdu,app.Cdu,app.Ddu]=ssdata(app.Gdunhealthy);
            app.Kinsulinu=[dlqr(app.Adu,app.Bdu(:,1),Q,1);0 0 ];  %% fbk law using injection
            app.Kglucoseu=[ 0 0;dlqr(app.Adu,app.Bdu(:,2),Q,1)];  %% fbk law using glucose
            app.Kmimou=dlqr(app.Adu,app.Bdu(:,1:2),Q,eye(2));  %% fbk law using both
           
        end


        % Simulates the closed-loop while ensuring that the inputs cannot
        % go below zero
        function [x,t,ucontrol] = simulateclosedloop(app,modelchoice,controlchoice,disturbance)

          [A,B,C,D]=ssdata(modelchoice);
          x=[0;0];ucontrol=[0;0;0];
          tend=app.runtime; t=1:tend+1;
            for k=1:tend;                

                ucontrol(1,k)=0;
                ucontrol(1:2,k)=-controlchoice*x(:,k);
                if ucontrol(1,k)<0;ucontrol(1,k)=0;end %% cannot subtract only add
                if ucontrol(2,k)<0;ucontrol(2,k)=0;end %% cannot subtract only add
                
                x(:,k+1)=A*x(:,k)+B*ucontrol(:,k)+B*disturbance(:,k);
 
            end  % end of simulation loop
            
        end


        % Assumes a fixed timing for the disturbances and produces the
        % plots in the tab group everything overlaid
        function defaultsimulations(app,disturbance)
            
           [xhealthy1,t,uhealthy1] = simulateclosedloop(app,app.Gdhealthy,app.Kinsulinh,disturbance);
           [xhealthy2,t,uhealthy2] = simulateclosedloop(app,app.Gdhealthy,app.Kglucoseh,disturbance);
           [xhealthy3,t,uhealthy3] = simulateclosedloop(app,app.Gdhealthy,app.Kmimoh,disturbance);
           [xhealthy4,t] = simulateclosedloop(app,app.Gdhealthy,zeros(2,2),disturbance );   % no feedback
           
           [xunhealthy1,t,uunhealthy1] = simulateclosedloop(app,app.Gdunhealthy,app.Kinsulinu,disturbance);
           [xunhealthy2,t,uunhealthy2] = simulateclosedloop(app,app.Gdunhealthy,app.Kglucoseu,disturbance);
           [xunhealthy3,t,uunhealthy3] = simulateclosedloop(app,app.Gdunhealthy,app.Kmimou,disturbance);
           [xunhealthy4,t] = simulateclosedloop(app,app.Gdunhealthy,zeros(2,2),disturbance );   % no feedback
                  
           tt=t(1:end-1);

           % Plot states (Glucose and insulin levels) Insulin fbk
           hold(app.UIAxes,'off')
           plot(app.UIAxes,t,xhealthy1(1,:),'r--',t,xhealthy1(2,:),'r')
           hold(app.UIAxes,'on')
           plot(app.UIAxes,t,xunhealthy1(1,:),'b--',t,xunhealthy1(2,:),'b')
           plot(app.UIAxes,tt,uhealthy1(1,:),'g--',tt,uhealthy1(2,:),'g')
           plot(app.UIAxes,tt,uunhealthy1(1,:),'k--',tt,uunhealthy1(2,:),'k')
           grid(app.UIAxes,'on');

           % Plot states (Glucose and insulin levels) Glucose fbk
           hold(app.UIAxes_2,'off')
           plot(app.UIAxes_2,t,xhealthy2(1,:),'r--',t,xhealthy2(2,:),'r')
           hold(app.UIAxes_2,'on')
           plot(app.UIAxes_2,t,xunhealthy2(1,:),'b--',t,xunhealthy2(2,:),'b')
           plot(app.UIAxes_2,tt,uhealthy2(1,:),'g--',tt,uhealthy2(2,:),'g')
           plot(app.UIAxes_2,tt,uunhealthy2(1,:),'k--',tt,uunhealthy2(2,:),'k')
          grid(app.UIAxes_2,'on');

           % Plot states (Glucose and insulin levels) MIMO fbk
           hold(app.UIAxes_4,'off')
           plot(app.UIAxes_4,t,xhealthy3(1,:),'r--',t,xhealthy3(2,:),'r')
           hold(app.UIAxes_4,'on')
           plot(app.UIAxes_4,t,xunhealthy3(1,:),'b--',t,xunhealthy3(2,:),'b')
           plot(app.UIAxes_4,tt,uhealthy3(1,:),'g--',tt,uhealthy3(2,:),'g')
           plot(app.UIAxes_4,tt,uunhealthy3(1,:),'k--',tt,uunhealthy3(2,:),'k')
           legend(app.UIAxes_4,'Blood sugar healthy','Insulin healthy',...
               'Blood sugar unhealthy','Insulin unhealthy', 'Insulin control input (h)','Glucose control input (h)', ...
               'Insulin control input (un)','Glucose control input (un)');
           grid(app.UIAxes_4,'on');
         
           % Plot states (Glucose and insulin levels) no fbk
           hold(app.UIAxes_5,'off')
           plot(app.UIAxes_5,t,xhealthy4(1,:),'r--',t,xhealthy4(2,:),'r')
           hold(app.UIAxes_5,'on')
           plot(app.UIAxes_5,t,xunhealthy4(1,:),'b--',t,xunhealthy4(2,:),'b')
           grid(app.UIAxes_5,'on');
      
           % External factors
           hold(app.UIAxes_3,'off')
           plot(app.UIAxes_3,tt,disturbance(1,:),'m')
           hold(app.UIAxes_3,'on')
           plot(app.UIAxes_3,tt,disturbance(2,:),'k')
           plot(app.UIAxes_3,tt,disturbance(3,:),'y')

           legend(app.UIAxes_3,'Insulin injection','Food input','Exercise');
        end


% Assumes a fixed timing for the disturbances and produces separate plots
% to allow easier comparison
        function individualsimulations(app,disturbance)
            
           if app.HealthyButton.BackgroundColor==[1 0 0];  % use unhealthy
           [x1,t,u1] = simulateclosedloop(app,app.Gdunhealthy,app.Kinsulinu,disturbance);
           [x2,t,u2] = simulateclosedloop(app,app.Gdunhealthy,app.Kglucoseu,disturbance);
           [x3,t,u3] = simulateclosedloop(app,app.Gdunhealthy,app.Kmimou,disturbance);
           [x4,t,u4] = simulateclosedloop(app,app.Gdunhealthy,zeros(2,2),disturbance );   % no feedback
           else % use healthy
           [x1,t,u1] = simulateclosedloop(app,app.Gdhealthy,app.Kinsulinh,disturbance);
           [x2,t,u2] = simulateclosedloop(app,app.Gdhealthy,app.Kglucoseh,disturbance);
           [x3,t,u3] = simulateclosedloop(app,app.Gdhealthy,app.Kmimoh,disturbance);
           [x4,t,u4] = simulateclosedloop(app,app.Gdhealthy,zeros(2,2),disturbance );   % no feedback
           end
              
           % Decide which control law to plot
           hold(app.UIAxes2,'off')
           hold(app.UIAxes2_2,'off')
           tt=1:100;
            switch app.individualchoice_control
                
                case 1    % insulin fbk
                    plot(app.UIAxes2,tt,x1(1,tt),'r--o',tt,x1(2,tt),'r+')
                    plot(app.UIAxes2_2,tt,u1(1,tt),'r--',tt,u1(2,tt),'r')
                case 2    % Glucose fbk
                    plot(app.UIAxes2,tt,x2(1,tt),'r--o',tt,x2(2,tt),'r+')
                    plot(app.UIAxes2_2,tt,u2(1,tt),'r--',tt,u2(2,tt),'r')
                case 3    % MIMO fbk
                    plot(app.UIAxes2,tt,x3(1,tt),'r--o',tt,x3(2,tt),'r+')
                    plot(app.UIAxes2_2,tt,u3(1,tt),'r--',tt,u3(2,tt),'r')

            end
           hold(app.UIAxes2,'on')
           plot(app.UIAxes2,tt,x4(1,tt),'b--',tt,x4(2,tt),'b')
           legend(app.UIAxes2,'Blood sugar (with fbk)','Blood insulin (with fbk)','Blood sugar (no fbk)','Blood insulin (no fbk)')

           hold(app.UIAxes2_2,'on')
           plot(app.UIAxes2_2,tt,disturbance(1,tt),'m',tt,disturbance(2,tt),'k',tt,disturbance(3,tt),'y')
           legend(app.UIAxes2_2,'Insulin fbk input','Glucose fbk input','Insulin injection','Food','Exercise')

        end



        end  % end of sub functions section
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
            % resize to be in middle of  the window
            movegui(app.UIFigure)

            % Open the manual
            if exist('diabetes_control101_manual_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open diabetes_control101_manual_mycopy.mlx
            else           
                p1 = which('diabetes_control101_manual.mlx');
                p2 = strcat(pwd,'/diabetes_control101_manual_mycopy.mlx');
                copyfile(p1,p2)           
                open diabetes_control101_manual_mycopy.mlx
            end

            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);

           % Initialise data
           app = createmodel(app);

           SimulateButtonPushed(app);
           if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
            theme(app.UIFigure,"light")
            end

        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
           
          
           % overview plots
               disturbance = ([app.InjectionSlider.Value;app.FoodSlider.Value;app.ExerciseSlider.Value].*...
                   app.individualchoice_disturbance)*[zeros(1,20),ones(1,40), zeros(1,app.runtime-60)];
               individualsimulations(app,disturbance);

          % Focussed plots: check buttons for which to use
               disturbance = [app.InjectionSlider.Value*[zeros(1,20),ones(1,40),zeros(1,app.runtime-60)];...
               app.FoodSlider.Value*[zeros(1,120),ones(1,40),zeros(1,app.runtime-160)];...
               app.ExerciseSlider.Value*[zeros(1,200),ones(1,40),zeros(1,app.runtime-240)]];
               defaultsimulations(app,disturbance);
        
         
      

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

        % Value changed function: FoodSlider
        function FoodSliderValueChanged(app, event)
            value = app.FoodSlider.Value;
            value = round(value,1);
            app.FoodSlider.Value=value;          
                       
        end

        % Value changed function: ExerciseSlider
        function ExerciseSliderValueChanged(app, event)
            value = app.ExerciseSlider.Value;
            value = round(value,1);
            app.ExerciseSlider.Value=value;
            
        end

        % Value changed function: InjectionSlider
        function InjectionSliderValueChanged(app, event)
            value = app.InjectionSlider.Value;
            value = round(value,1);
            app.InjectionSlider.Value=value;
        end

        % Selection change function: TabGroup
        function TabGroupSelectionChanged(app, event)
            selectedTab = app.TabGroup.SelectedTab;
            
            % if strcmp(selectedTab.Title,'Individual comparisons');
            %    %app.TabGroup2.SelectedTab.Title='Choose comparison';
            % else
            %    %app.TabGroup2.SelectedTab.Title='Disturbance timing';
            % end

        end

        % Selection change function: TabGroup2
        function TabGroup2SelectionChanged(app, event)
            selectedTab = app.TabGroup2.SelectedTab;
            
        end

        % Button pushed function: FoodButton
        function FoodButtonPushed(app, event)
            if app.FoodButton.BackgroundColor==[1 0 0];
                app.FoodButton.BackgroundColor=[0 1 0];
                app.ExerciseButton.BackgroundColor=[1 0 0];
                app.InsulinButton.BackgroundColor=[1 0 0];
                app.individualchoice_disturbance = [0; 1; 0];
            else
                app.FoodButton.BackgroundColor=[1 0 0];
                app.individualchoice_disturbance = [0; 0; 0]';
            end

        end

        % Button pushed function: HealthyButton
        function HealthyButtonPushed(app, event)
            if app.HealthyButton.BackgroundColor==[1 0 0];
                app.HealthyButton.BackgroundColor=[0 1 0];
                app.HealthyButton.Text = 'Unhealthy';
            else
                app.HealthyButton.BackgroundColor=[1 0 0];
                app.HealthyButton.Text = 'Healthy';
            end
        end

        % Button pushed function: InsulinButton
        function InsulinButtonPushed(app, event)
            if app.InsulinButton.BackgroundColor==[1 0 0];
                app.InsulinButton.BackgroundColor=[0 1 0];
                app.FoodButton.BackgroundColor=[1 0 0];
                app.ExerciseButton.BackgroundColor=[1 0 0];
                app.individualchoice_disturbance = [1; 0; 0];
            else
                app.InsulinButton.BackgroundColor=[1 0 0];
                app.individualchoice_disturbance = [0; 0; 0];
            end
        end

        % Button pushed function: ExerciseButton
        function ExerciseButtonPushed(app, event)
            if app.ExerciseButton.BackgroundColor==[1 0 0];
                app.ExerciseButton.BackgroundColor=[0 1 0];
                app.InsulinButton.BackgroundColor=[1 0 0];
                app.FoodButton.BackgroundColor=[1 0 0];
                app.individualchoice_disturbance = [0; 0; 1];
            else
                app.ExerciseButton.BackgroundColor=[1 0 0];
                app.individualchoice_disturbance = [0; 0; 0];
            end
        end

        % Button pushed function: GlucosefbkButton
        function GlucosefbkButtonPushed(app, event)
            if app.GlucosefbkButton.BackgroundColor==[1 0 0];
                app.GlucosefbkButton.BackgroundColor=[0 1 0];
                app.MIMOfbkButton.BackgroundColor=[1 0 0];
                app.InsulinfbkButton.BackgroundColor=[1 0 0];
                app.individualchoice_control=2;
            else
                app.GlucosefbkButton.BackgroundColor=[1 0 0];
                app.individualchoice_control=0;
            end
        end

        % Button pushed function: InsulinfbkButton
        function InsulinfbkButtonPushed(app, event)
            if app.InsulinfbkButton.BackgroundColor==[1 0 0];
                app.InsulinfbkButton.BackgroundColor=[0 1 0];
                app.GlucosefbkButton.BackgroundColor=[1 0 0];
                app.MIMOfbkButton.BackgroundColor=[1 0 0];
                app.individualchoice_control=1; 
            else
                app.InsulinfbkButton.BackgroundColor=[1 0 0];
                app.individualchoice_control = [0; 0; 0];
            end
        end

        % Button pushed function: MIMOfbkButton
        function MIMOfbkButtonPushed(app, event)
            if app.MIMOfbkButton.BackgroundColor==[1 0 0];
                app.MIMOfbkButton.BackgroundColor=[0 1 0];
                app.InsulinfbkButton.BackgroundColor=[1 0 0];
                app.GlucosefbkButton.BackgroundColor=[1 0 0];
                app.individualchoice_control = [3];
            else
                app.MIMOfbkButton.BackgroundColor=[1 0 0];
                app.individualchoice_control = [0];
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
            app.UIFigure.Position = [100 100 1203 927];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1.2x'};
            app.GridLayout.RowHeight = {'0.3x', '2x'};

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = 2;
            app.GridLayout2.BackgroundColor = [0.6 1 1];

            % Create BloodsugarlevelswithdiabetesLabel
            app.BloodsugarlevelswithdiabetesLabel = uilabel(app.GridLayout2);
            app.BloodsugarlevelswithdiabetesLabel.BackgroundColor = [0 1 1];
            app.BloodsugarlevelswithdiabetesLabel.HorizontalAlignment = 'center';
            app.BloodsugarlevelswithdiabetesLabel.FontSize = 18;
            app.BloodsugarlevelswithdiabetesLabel.FontWeight = 'bold';
            app.BloodsugarlevelswithdiabetesLabel.Layout.Row = 1;
            app.BloodsugarlevelswithdiabetesLabel.Layout.Column = [1 2];
            app.BloodsugarlevelswithdiabetesLabel.Text = 'Blood sugar levels with diabetes';

            % Create Image
            app.Image = uiimage(app.GridLayout2);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 3;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'UoSlogo.png');

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout);
            app.GridLayout3.ColumnWidth = {'0.95x'};
            app.GridLayout3.RowHeight = {'1x'};
            app.GridLayout3.Layout.Row = 1;
            app.GridLayout3.Layout.Column = 1;
            app.GridLayout3.BackgroundColor = [1 0.6 0.8];

            % Create GridLayout10
            app.GridLayout10 = uigridlayout(app.GridLayout3);
            app.GridLayout10.RowHeight = {'1x'};
            app.GridLayout10.Layout.Row = 1;
            app.GridLayout10.Layout.Column = 1;
            app.GridLayout10.BackgroundColor = [1 0.6 0.8];

            % Create SimulateButton
            app.SimulateButton = uibutton(app.GridLayout10, 'push');
            app.SimulateButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateButtonPushed, true);
            app.SimulateButton.WordWrap = 'on';
            app.SimulateButton.BackgroundColor = [1 0.2 0.702];
            app.SimulateButton.FontSize = 36;
            app.SimulateButton.FontWeight = 'bold';
            app.SimulateButton.Layout.Row = 1;
            app.SimulateButton.Layout.Column = [1 2];
            app.SimulateButton.Text = 'Simulate';

            % Create GridLayout12
            app.GridLayout12 = uigridlayout(app.GridLayout);
            app.GridLayout12.ColumnWidth = {'1x'};
            app.GridLayout12.Layout.Row = 2;
            app.GridLayout12.Layout.Column = 1;

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout12);
            app.GridLayout6.ColumnWidth = {'0.4x', '1x'};
            app.GridLayout6.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout6.Layout.Row = 1;
            app.GridLayout6.Layout.Column = 1;
            app.GridLayout6.BackgroundColor = [0.702 1 0.702];

            % Create InputsLabel
            app.InputsLabel = uilabel(app.GridLayout6);
            app.InputsLabel.BackgroundColor = [0 1 0];
            app.InputsLabel.HorizontalAlignment = 'center';
            app.InputsLabel.FontSize = 18;
            app.InputsLabel.FontWeight = 'bold';
            app.InputsLabel.Layout.Row = 1;
            app.InputsLabel.Layout.Column = [1 2];
            app.InputsLabel.Text = 'Inputs';

            % Create FoodSliderLabel
            app.FoodSliderLabel = uilabel(app.GridLayout6);
            app.FoodSliderLabel.HorizontalAlignment = 'right';
            app.FoodSliderLabel.FontSize = 18;
            app.FoodSliderLabel.FontWeight = 'bold';
            app.FoodSliderLabel.Layout.Row = 2;
            app.FoodSliderLabel.Layout.Column = 1;
            app.FoodSliderLabel.Text = 'Food';

            % Create FoodSlider
            app.FoodSlider = uislider(app.GridLayout6);
            app.FoodSlider.Limits = [0 1];
            app.FoodSlider.ValueChangedFcn = createCallbackFcn(app, @FoodSliderValueChanged, true);
            app.FoodSlider.MinorTicks = [-20 -15 -10 -5 0 5 10 15 20];
            app.FoodSlider.FontSize = 18;
            app.FoodSlider.Layout.Row = 2;
            app.FoodSlider.Layout.Column = 2;
            app.FoodSlider.Value = 0.5;

            % Create ExerciseSliderLabel
            app.ExerciseSliderLabel = uilabel(app.GridLayout6);
            app.ExerciseSliderLabel.HorizontalAlignment = 'right';
            app.ExerciseSliderLabel.FontSize = 18;
            app.ExerciseSliderLabel.FontWeight = 'bold';
            app.ExerciseSliderLabel.Layout.Row = 3;
            app.ExerciseSliderLabel.Layout.Column = 1;
            app.ExerciseSliderLabel.Text = 'Exercise';

            % Create ExerciseSlider
            app.ExerciseSlider = uislider(app.GridLayout6);
            app.ExerciseSlider.Limits = [0 1];
            app.ExerciseSlider.ValueChangedFcn = createCallbackFcn(app, @ExerciseSliderValueChanged, true);
            app.ExerciseSlider.MinorTicks = [-20 -15 -10 -5 0 5 10 15 20];
            app.ExerciseSlider.FontSize = 18;
            app.ExerciseSlider.Layout.Row = 3;
            app.ExerciseSlider.Layout.Column = 2;
            app.ExerciseSlider.Value = 0.5;

            % Create InjectionSliderLabel
            app.InjectionSliderLabel = uilabel(app.GridLayout6);
            app.InjectionSliderLabel.HorizontalAlignment = 'right';
            app.InjectionSliderLabel.FontSize = 18;
            app.InjectionSliderLabel.FontWeight = 'bold';
            app.InjectionSliderLabel.Layout.Row = 4;
            app.InjectionSliderLabel.Layout.Column = 1;
            app.InjectionSliderLabel.Text = 'Injection';

            % Create InjectionSlider
            app.InjectionSlider = uislider(app.GridLayout6);
            app.InjectionSlider.Limits = [0 1];
            app.InjectionSlider.ValueChangedFcn = createCallbackFcn(app, @InjectionSliderValueChanged, true);
            app.InjectionSlider.MinorTicks = [-20 -15 -10 -5 0 5 10 15 20];
            app.InjectionSlider.FontSize = 18;
            app.InjectionSlider.Layout.Row = 4;
            app.InjectionSlider.Layout.Column = 2;
            app.InjectionSlider.Value = 0.5;

            % Create TabGroup2
            app.TabGroup2 = uitabgroup(app.GridLayout12);
            app.TabGroup2.SelectionChangedFcn = createCallbackFcn(app, @TabGroup2SelectionChanged, true);
            app.TabGroup2.Layout.Row = 2;
            app.TabGroup2.Layout.Column = 1;

            % Create ChoosecomparisonTab
            app.ChoosecomparisonTab = uitab(app.TabGroup2);
            app.ChoosecomparisonTab.Title = 'Choose comparison';

            % Create GridLayout15
            app.GridLayout15 = uigridlayout(app.ChoosecomparisonTab);
            app.GridLayout15.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout15.BackgroundColor = [0.9294 0.6941 0.1255];

            % Create FoodButton
            app.FoodButton = uibutton(app.GridLayout15, 'push');
            app.FoodButton.ButtonPushedFcn = createCallbackFcn(app, @FoodButtonPushed, true);
            app.FoodButton.BackgroundColor = [0 1 0];
            app.FoodButton.FontSize = 18;
            app.FoodButton.Layout.Row = 2;
            app.FoodButton.Layout.Column = 1;
            app.FoodButton.Text = 'Food';

            % Create HealthyButton
            app.HealthyButton = uibutton(app.GridLayout15, 'push');
            app.HealthyButton.ButtonPushedFcn = createCallbackFcn(app, @HealthyButtonPushed, true);
            app.HealthyButton.BackgroundColor = [0 1 0];
            app.HealthyButton.FontSize = 18;
            app.HealthyButton.Layout.Row = 1;
            app.HealthyButton.Layout.Column = [1 2];
            app.HealthyButton.Text = 'Healthy';

            % Create InsulinButton
            app.InsulinButton = uibutton(app.GridLayout15, 'push');
            app.InsulinButton.ButtonPushedFcn = createCallbackFcn(app, @InsulinButtonPushed, true);
            app.InsulinButton.BackgroundColor = [1 0 0];
            app.InsulinButton.FontSize = 18;
            app.InsulinButton.Layout.Row = 3;
            app.InsulinButton.Layout.Column = 1;
            app.InsulinButton.Text = 'Insulin';

            % Create GlucosefbkButton
            app.GlucosefbkButton = uibutton(app.GridLayout15, 'push');
            app.GlucosefbkButton.ButtonPushedFcn = createCallbackFcn(app, @GlucosefbkButtonPushed, true);
            app.GlucosefbkButton.BackgroundColor = [1 0 0];
            app.GlucosefbkButton.FontSize = 18;
            app.GlucosefbkButton.Layout.Row = 2;
            app.GlucosefbkButton.Layout.Column = 2;
            app.GlucosefbkButton.Text = 'Glucose fbk';

            % Create ExerciseButton
            app.ExerciseButton = uibutton(app.GridLayout15, 'push');
            app.ExerciseButton.ButtonPushedFcn = createCallbackFcn(app, @ExerciseButtonPushed, true);
            app.ExerciseButton.BackgroundColor = [1 0 0];
            app.ExerciseButton.FontSize = 18;
            app.ExerciseButton.Layout.Row = 4;
            app.ExerciseButton.Layout.Column = 1;
            app.ExerciseButton.Text = 'Exercise';

            % Create InsulinfbkButton
            app.InsulinfbkButton = uibutton(app.GridLayout15, 'push');
            app.InsulinfbkButton.ButtonPushedFcn = createCallbackFcn(app, @InsulinfbkButtonPushed, true);
            app.InsulinfbkButton.BackgroundColor = [0 1 0];
            app.InsulinfbkButton.FontSize = 18;
            app.InsulinfbkButton.Layout.Row = 3;
            app.InsulinfbkButton.Layout.Column = 2;
            app.InsulinfbkButton.Text = 'Insulin fbk';

            % Create MIMOfbkButton
            app.MIMOfbkButton = uibutton(app.GridLayout15, 'push');
            app.MIMOfbkButton.ButtonPushedFcn = createCallbackFcn(app, @MIMOfbkButtonPushed, true);
            app.MIMOfbkButton.BackgroundColor = [1 0 0];
            app.MIMOfbkButton.FontSize = 18;
            app.MIMOfbkButton.Layout.Row = 4;
            app.MIMOfbkButton.Layout.Column = 2;
            app.MIMOfbkButton.Text = 'MIMO fbk';

            % Create DisturbancetimingTab
            app.DisturbancetimingTab = uitab(app.TabGroup2);
            app.DisturbancetimingTab.Title = 'Disturbance timing';

            % Create GridLayout14
            app.GridLayout14 = uigridlayout(app.DisturbancetimingTab);
            app.GridLayout14.ColumnWidth = {'1x'};
            app.GridLayout14.RowHeight = {'1x'};

            % Create UIAxes_3
            app.UIAxes_3 = uiaxes(app.GridLayout14);
            title(app.UIAxes_3, 'Disturbance timing')
            xlabel(app.UIAxes_3, 'time')
            zlabel(app.UIAxes_3, 'Z')
            app.UIAxes_3.FontSize = 14;
            app.UIAxes_3.Layout.Row = 1;
            app.UIAxes_3.Layout.Column = 1;

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.SelectionChangedFcn = createCallbackFcn(app, @TabGroupSelectionChanged, true);
            app.TabGroup.Layout.Row = 2;
            app.TabGroup.Layout.Column = 2;

            % Create IndividualcomparisonsTab
            app.IndividualcomparisonsTab = uitab(app.TabGroup);
            app.IndividualcomparisonsTab.Title = 'Individual comparisons';

            % Create GridLayout16
            app.GridLayout16 = uigridlayout(app.IndividualcomparisonsTab);
            app.GridLayout16.ColumnWidth = {'1x'};

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout16);
            title(app.UIAxes2, 'Blood sugar and insulin levels')
            xlabel(app.UIAxes2, 'time')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 14;
            app.UIAxes2.Layout.Row = 1;
            app.UIAxes2.Layout.Column = 1;

            % Create UIAxes2_2
            app.UIAxes2_2 = uiaxes(app.GridLayout16);
            title(app.UIAxes2_2, 'Control inputs')
            xlabel(app.UIAxes2_2, 'time')
            zlabel(app.UIAxes2_2, 'Z')
            app.UIAxes2_2.FontSize = 14;
            app.UIAxes2_2.Layout.Row = 2;
            app.UIAxes2_2.Layout.Column = 1;

            % Create EverythingoverlaidTab
            app.EverythingoverlaidTab = uitab(app.TabGroup);
            app.EverythingoverlaidTab.Title = 'Everything overlaid';

            % Create GridLayout13
            app.GridLayout13 = uigridlayout(app.EverythingoverlaidTab);
            app.GridLayout13.ColumnWidth = {'1x'};
            app.GridLayout13.RowHeight = {'1x', '1x', '1x', '1x'};

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout13);
            title(app.UIAxes, 'Blood sugar and insulin levels (Insulin fbk)')
            xlabel(app.UIAxes, 'time')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.FontSize = 14;
            app.UIAxes.Layout.Row = 1;
            app.UIAxes.Layout.Column = 1;

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.GridLayout13);
            title(app.UIAxes_2, 'Blood sugar and insulin levels (Glucose fbk)')
            xlabel(app.UIAxes_2, 'time')
            zlabel(app.UIAxes_2, 'Z')
            app.UIAxes_2.FontSize = 14;
            app.UIAxes_2.Layout.Row = 2;
            app.UIAxes_2.Layout.Column = 1;

            % Create UIAxes_4
            app.UIAxes_4 = uiaxes(app.GridLayout13);
            title(app.UIAxes_4, 'Blood sugar and insulin levels (MIMO fbk)')
            xlabel(app.UIAxes_4, 'time')
            zlabel(app.UIAxes_4, 'Z')
            app.UIAxes_4.FontSize = 14;
            app.UIAxes_4.Layout.Row = 3;
            app.UIAxes_4.Layout.Column = 1;

            % Create UIAxes_5
            app.UIAxes_5 = uiaxes(app.GridLayout13);
            title(app.UIAxes_5, 'Blood sugar and insulin levels (no fbk)')
            xlabel(app.UIAxes_5, 'time')
            zlabel(app.UIAxes_5, 'Z')
            app.UIAxes_5.FontSize = 14;
            app.UIAxes_5.Layout.Row = 4;
            app.UIAxes_5.Layout.Column = 1;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = diabetes_control101

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

