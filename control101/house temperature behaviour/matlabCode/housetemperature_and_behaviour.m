classdef housetemperature_and_behaviour < matlab.apps.AppBase
    %HOUSETEMPERATURE_AND_BEHAVIOUR
    %   File written by J.A.Rossiter, University of Sheffield  
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   
    %   A simple interface to practice behaviour of a simple thermal model
    %   with thermal inertia, heat loss, heating and external disturbances
    %   such as temperature.
    %   
    %   Some notes and engineering background are in the partner
    %   livescript file:    housetemperature_and_behaviour_manual.mlx
    %   A group of similar files can be downloaded through MATLAB
    %   add-ons with the toolbox name: control101
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
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        GridLayout6                     matlab.ui.container.GridLayout
        InitialtemperatureT0degSlider   matlab.ui.control.Slider
        InitialtemperatureT0degSliderLabel  matlab.ui.control.Label
        ExternaltemperatureTedegSlider  matlab.ui.control.Slider
        ExternaltemperatureTedegSliderLabel  matlab.ui.control.Label
        HeatsupplyWkWSlider             matlab.ui.control.Slider
        HeatsupplyWkWSliderLabel        matlab.ui.control.Label
        EnvironmentparametersLabel      matlab.ui.control.Label
        DetailedanalysisoffirstordermodelparametersPanel  matlab.ui.container.Panel
        GridLayout5                     matlab.ui.container.GridLayout
        UIAxes2                         matlab.ui.control.UIAxes
        UIAxes3                         matlab.ui.control.UIAxes
        GridLayout4                     matlab.ui.container.GridLayout
        HouseparametersCdTdtkTTeWLabel  matlab.ui.control.Label
        ThermalcapacityCMJdegSlider     matlab.ui.control.Slider
        ThermalcapacityCMJdegSliderLabel  matlab.ui.control.Label
        HeatlosskkWdegSlider            matlab.ui.control.Slider
        HeatlosskkWdegSliderLabel       matlab.ui.control.Label
        GridLayout3                     matlab.ui.container.GridLayout
        AnimationOnButton               matlab.ui.control.Button
        RefreshButton                   matlab.ui.control.Button
        SimulateButton                  matlab.ui.control.Button
        GridLayout2                     matlab.ui.container.GridLayout
        Image                           matlab.ui.control.Image
        stordermodelforhousetemperatureLabel  matlab.ui.control.Label
        UIAxes                          matlab.ui.control.UIAxes
    end

    % File written by J.A.Rossiter, University of Sheffield
    % See website for more files like this.
    % https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    % A simple interface to practice behaviour of a simple car model 
    % subject to changes in mass, friction, enging power road slope and wind
    % 
    % Some notes and engineering background are in the partner livescript
    % file:    carmodel_and_behaviour_manual.mlx
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
    
    
    % The next section defines all the core variables used in the code and
    % that it may be convenient to have available in the various
    % subfunctions
    properties (Access = private)
         originalsize     % product of width and height for font sizing

        legstring=cell(1); % To store legends
      
        house   % handle for house picture
        runtime = 5; % for simulation the runtime
        time;  % variable to store time instants for simulation plots
        time2; % for time constant and gain analysis plot
        samples = 201;
        animationtime = 8; % how long animation will take
        Tsamp=0.1;  % update rate for animation
        T  % time constant
        Gss % steady-state gain
        steadylineplot;  % needed, especially if a square wave
        theta; % sum of all output components
        unitstep % step response
        
        
        
    end
    
    methods (Access = private)
        


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  PLOT OF TOP FIGURE - THE HOUSE ANIMATION
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function app = createhouseoutline(app)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%% Colour mappings, blue = cold, red = hot
            % -10 = [0 0 1] =low    40 = [1 0 0] = high
            % colort = low + (T+10)*(high -low)/50
            startcolor = [0 0 1] + (app.InitialtemperatureT0degSlider.Value+10)*[1 0 -1]/50;  
            
            % Set up basic picture of the house in the top plot
            % house paramters
            x2 = [-7:7]; y2 = x2;
            plot(app.UIAxes,x2,x2,'w');
            hold(app.UIAxes,'on')
            
            %%%
            scale = sqrt(app.ThermalcapacityCMJdegSlider.Value*3);                      
            x=[-1,1,1,1.2,0,-1.2,-1,-1,1]*scale;
            y=[-1 -1 1 1 1.3 1 1 -1,-1]*scale;
            width = max(50/app.HeatlosskkWdegSlider.Value,1);
            
            plot(app.UIAxes,x,y,'k-','linewidth',width);
            app.house=fill(app.UIAxes,[x],[y],[startcolor]);
            
            %% Heating symbols at the middle
            W = app.HeatsupplyWkWSlider.Value;
            fill(app.UIAxes,2*[-0.2,-0.2,0.2,0.2]*W/20,2*[-0.2,0.2,0.2,-0.2]*W/20,'r')
            plot(app.UIAxes,[1 3],[1,3],'r','linewidth',2)
            plot(app.UIAxes,[1 3],[-1,-3],'r','linewidth',2)
            plot(app.UIAxes,[-1 -3],[-1,-3],'r','linewidth',2)
            plot(app.UIAxes,[-1 -3],[1,3],'r','linewidth',2)
            hold(app.UIAxes,'off')
            

            
        end      %%% END OF HOUSEOUTLINE SUBFUNCTION

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  Down load data from sliders and create models and responses
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function app = createmodels(app)

           
           % Collect data from sliders and round
           T0=app.InitialtemperatureT0degSlider.Value;
           k = app.HeatlosskkWdegSlider.Value;
           C=app.ThermalcapacityCMJdegSlider.Value;
           W=app.HeatsupplyWkWSlider.Value;
           Te = app.ExternaltemperatureTedegSlider.Value;
           
            %% define model and base responses
            yss = Te+(1/k)*W;  %% steady-state temp  (noted that k in KJ)
            app.time = linspace(0,app.runtime,app.samples);
            tau = C*1000/k;  %% time constant   (noted that C in MJ and k in KJ)
            tau=tau/3600;  %% convert to hrs
            app.theta =(T0 -yss)*exp(-app.time/tau) + yss;  %% using theta for temp
            app.T = tau;  % save time constant
            
            app.time2 = linspace(0,4*app.T,app.samples);
            app.unitstep = (1-exp(-app.time2/tau))/k;

        end   % end of create models subfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Manage the animation and legends
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        function app = animationoflineplots(app)
            %%  Set up legend
            if isempty(app.legstring{1});
                nlegstring=0;
            else
                nlegstring = length(app.legstring);
            end
            
            app.legstring{nlegstring+1}=['C = ',num2str(app.ThermalcapacityCMJdegSlider.Value),...
                ', k = ',num2str(app.HeatlosskkWdegSlider.Value),...
                ', Power = ',num2str(app.HeatsupplyWkWSlider.Value),...
                ', Te = ',num2str(app.ExternaltemperatureTedegSlider.Value),...
                ', \tau = ',num2str(round(app.T,2))];
            
            % initialise figure of temp response in bottom left
                        
            yplot = plot(app.UIAxes2,app.time(1),app.theta(1));  %% dynamic line plot of depth
            xlabel(app.UIAxes2,'time (hr)')
            hold(app.UIAxes2,'on')
            xlim(app.UIAxes2,[0,app.runtime]);
            kk=legend(app.UIAxes2,app.legstring,'Location','southeast','fontsize',8);
            set(kk,'fontsize',10);
            grid(app.UIAxes2,'on')
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% animation of house temperature plot
            % define animation time aspects
            animationsamples = app.animationtime/app.Tsamp; % assume sample time of Tsamp
            updaterate =ceil(app.samples/animationsamples); % no of samples between pauses
            tstart=tic; tsave = tstart;

            deltax=0;deltax2=0;
            for k=1:length(app.time);
                set(yplot,'Ydata',app.theta(1:k),'Xdata',app.time(1:k));
                
                kout = app.theta(k)/0.6;
                newcolor=[0 0 1] + (app.theta(k)+10)*[1 0 -1]/50;
                if app.theta(k)>40;newcolor = [1 0 0];end
                set(app.house,'FaceColor',newcolor);   %% Update house picture



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

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  Time constant and gain analysis
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
        function app = timeconstantanalysis(app)
            
            k = app.HeatlosskkWdegSlider.Value;
            C=app.ThermalcapacityCMJdegSlider.Value;
            app.Gss = 1/k;
            plot(app.UIAxes3,app.time2,app.unitstep,'b');
            hold(app.UIAxes3,'on') ;
            plot(app.UIAxes3,[app.T,app.T],[0,app.Gss],'r-.','linewidth',3)
            plot(app.UIAxes3,[0,4*app.T],[app.Gss,app.Gss],'g-.','linewidth',3)
            kkk=legend(app.UIAxes3,'Temperature','Time constant','Steady-state');
            set(kkk,'fontsize',10);
            text(app.UIAxes3,app.T,app.Gss/3,['\tau = ',num2str(round(app.T,2)),...
                ', Steady-state (per kW) = ',num2str(round(app.Gss,2))],'fontsize', 16);
            xlabel(app.UIAxes3,'time (hr)');
            grid(app.UIAxes3,'on');
            hold(app.UIAxes3,'off');
        end  % end of timeconstant and gain analysis figure



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Control interaction during the animation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function  disablebuttons(app)
            set(app.SimulateButton, 'Enable', 'off');
            set(app.RefreshButton, 'Enable', 'off');
            set(app.AnimationOnButton, 'Enable', 'off');
            set(app.ExternaltemperatureTedegSlider, 'Enable', 'off');
            set(app.HeatsupplyWkWSlider, 'Enable', 'off');
            set(app.InitialtemperatureT0degSlider, 'Enable', 'off');
            set(app.ThermalcapacityCMJdegSlider, 'Enable', 'off');
            set(app.HeatlosskkWdegSlider, 'Enable', 'off');
        end
        
        function enablebuttons(app)
            set(app.SimulateButton, 'Enable', 'on');
            set(app.RefreshButton, 'Enable', 'on')
            set(app.AnimationOnButton, 'Enable', 'on')
            set(app.ExternaltemperatureTedegSlider, 'Enable', 'on');
            set(app.HeatsupplyWkWSlider, 'Enable', 'on');
            set(app.InitialtemperatureT0degSlider, 'Enable', 'on');
            set(app.ThermalcapacityCMJdegSlider, 'Enable', 'on');
            set(app.HeatlosskkWdegSlider, 'Enable', 'on');
        end


    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
           % resize to be in middle of  the window
            movegui(app.UIFigure)
            
            % Open the manual
            if exist('housetemperature_and_behaviour_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open housetemperature_and_behaviour_mycopy.mlx
            else
                p1 = which('housetemperature_and_behaviour_manual.mlx');
                p2 = strcat(pwd,'/housetemperature_and_behaviour_mycopy.mlx');
                copyfile(p1,p2)                
                open housetemperature_and_behaviour_mycopy.mlx
                clear p1 p2
            end
            
            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);

            app = createhouseoutline(app); % define car outline for animation
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
            theme(app.UIFigure,"light")
            end
        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
            
            disablebuttons(app);

            app = createmodels(app); % define responses
            app = createhouseoutline(app); % define car outline for animation
            app = timeconstantanalysis(app); % create figure to show T
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

        % Value changed function: InitialtemperatureT0degSlider
        function InitialtemperatureT0degSliderValueChanged(app, event)
            value = app.InitialtemperatureT0degSlider.Value;
            value = round(value,0);
            app.InitialtemperatureT0degSlider.Value=value;
            app = createhouseoutline(app);

        end

        % Value changed function: ThermalcapacityCMJdegSlider
        function ThermalcapacityCMJdegSliderValueChanged(app, event)
            value = app.ThermalcapacityCMJdegSlider.Value;
            value=round(value,0); 
            if value<1; value =1;end
            app.ThermalcapacityCMJdegSlider.Value=value;
            app = createhouseoutline(app);
        end

        % Value changed function: HeatlosskkWdegSlider
        function HeatlosskkWdegSliderValueChanged(app, event)
            value = app.HeatlosskkWdegSlider.Value;
            value=round(value,0);
            app.HeatlosskkWdegSlider.Value=value;
            app = createhouseoutline(app);
           
        end

        % Value changed function: ExternaltemperatureTedegSlider
        function ExternaltemperatureTedegSliderValueChanged(app, event)
            value = app.ExternaltemperatureTedegSlider.Value;
            value = round(value,0);
            app.ExternaltemperatureTedegSlider.Value=value;
            app = createhouseoutline(app);
            
        end

        % Value changed function: HeatsupplyWkWSlider
        function HeatsupplyWkWSliderValueChanged(app, event)
            value = app.HeatsupplyWkWSlider.Value;
            value = round(value,-1);
            app.HeatsupplyWkWSlider.Value=value;
            app = createhouseoutline(app);
            
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
            app.UIFigure.Position = [100 100 1158 828];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '2x'};
            app.GridLayout.RowHeight = {'0.4x', '1x', '1.2x', '2x'};

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Animation of house temperature')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.XTick = [];
            app.UIAxes.XTickLabel = '';
            app.UIAxes.YTick = [];
            app.UIAxes.YTickLabel = '';
            app.UIAxes.Layout.Row = [2 3];
            app.UIAxes.Layout.Column = 2;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = 2;
            app.GridLayout2.BackgroundColor = [0.6 1 1];

            % Create stordermodelforhousetemperatureLabel
            app.stordermodelforhousetemperatureLabel = uilabel(app.GridLayout2);
            app.stordermodelforhousetemperatureLabel.BackgroundColor = [0 1 1];
            app.stordermodelforhousetemperatureLabel.HorizontalAlignment = 'center';
            app.stordermodelforhousetemperatureLabel.FontSize = 24;
            app.stordermodelforhousetemperatureLabel.FontWeight = 'bold';
            app.stordermodelforhousetemperatureLabel.Layout.Row = 1;
            app.stordermodelforhousetemperatureLabel.Layout.Column = [1 2];
            app.stordermodelforhousetemperatureLabel.Text = '1st order model for house temperature';

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

            % Create HeatlosskkWdegSliderLabel
            app.HeatlosskkWdegSliderLabel = uilabel(app.GridLayout4);
            app.HeatlosskkWdegSliderLabel.HorizontalAlignment = 'right';
            app.HeatlosskkWdegSliderLabel.FontSize = 14;
            app.HeatlosskkWdegSliderLabel.Layout.Row = 2;
            app.HeatlosskkWdegSliderLabel.Layout.Column = 1;
            app.HeatlosskkWdegSliderLabel.Text = {'Heat loss'; 'k (kW/deg)'};

            % Create HeatlosskkWdegSlider
            app.HeatlosskkWdegSlider = uislider(app.GridLayout4);
            app.HeatlosskkWdegSlider.Limits = [0 10];
            app.HeatlosskkWdegSlider.ValueChangedFcn = createCallbackFcn(app, @HeatlosskkWdegSliderValueChanged, true);
            app.HeatlosskkWdegSlider.MinorTicks = [500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000];
            app.HeatlosskkWdegSlider.FontSize = 14;
            app.HeatlosskkWdegSlider.Layout.Row = 2;
            app.HeatlosskkWdegSlider.Layout.Column = 2;
            app.HeatlosskkWdegSlider.Value = 4;

            % Create ThermalcapacityCMJdegSliderLabel
            app.ThermalcapacityCMJdegSliderLabel = uilabel(app.GridLayout4);
            app.ThermalcapacityCMJdegSliderLabel.HorizontalAlignment = 'right';
            app.ThermalcapacityCMJdegSliderLabel.FontSize = 14;
            app.ThermalcapacityCMJdegSliderLabel.Layout.Row = 3;
            app.ThermalcapacityCMJdegSliderLabel.Layout.Column = 1;
            app.ThermalcapacityCMJdegSliderLabel.Text = {'Thermal capacity'; 'C (MJ/deg)'};

            % Create ThermalcapacityCMJdegSlider
            app.ThermalcapacityCMJdegSlider = uislider(app.GridLayout4);
            app.ThermalcapacityCMJdegSlider.Limits = [0 10];
            app.ThermalcapacityCMJdegSlider.ValueChangedFcn = createCallbackFcn(app, @ThermalcapacityCMJdegSliderValueChanged, true);
            app.ThermalcapacityCMJdegSlider.MinorTicks = [0 100 200 300 400 500 600 700 800 900 1000];
            app.ThermalcapacityCMJdegSlider.FontSize = 14;
            app.ThermalcapacityCMJdegSlider.Layout.Row = 3;
            app.ThermalcapacityCMJdegSlider.Layout.Column = 2;
            app.ThermalcapacityCMJdegSlider.Value = 6;

            % Create HouseparametersCdTdtkTTeWLabel
            app.HouseparametersCdTdtkTTeWLabel = uilabel(app.GridLayout4);
            app.HouseparametersCdTdtkTTeWLabel.BackgroundColor = [1 1 0];
            app.HouseparametersCdTdtkTTeWLabel.HorizontalAlignment = 'center';
            app.HouseparametersCdTdtkTTeWLabel.FontSize = 16;
            app.HouseparametersCdTdtkTTeWLabel.FontWeight = 'bold';
            app.HouseparametersCdTdtkTTeWLabel.Layout.Row = 1;
            app.HouseparametersCdTdtkTTeWLabel.Layout.Column = [1 2];
            app.HouseparametersCdTdtkTTeWLabel.Text = 'House parameters: C(dT/dt) + k(T-Te) = W';

            % Create DetailedanalysisoffirstordermodelparametersPanel
            app.DetailedanalysisoffirstordermodelparametersPanel = uipanel(app.GridLayout);
            app.DetailedanalysisoffirstordermodelparametersPanel.AutoResizeChildren = 'off';
            app.DetailedanalysisoffirstordermodelparametersPanel.TitlePosition = 'centertop';
            app.DetailedanalysisoffirstordermodelparametersPanel.Title = 'Detailed analysis of first order model parameters and behaviour dependence on parameters';
            app.DetailedanalysisoffirstordermodelparametersPanel.BackgroundColor = [0.8902 0.7333 0.9882];
            app.DetailedanalysisoffirstordermodelparametersPanel.Layout.Row = 4;
            app.DetailedanalysisoffirstordermodelparametersPanel.Layout.Column = [1 2];
            app.DetailedanalysisoffirstordermodelparametersPanel.FontWeight = 'bold';
            app.DetailedanalysisoffirstordermodelparametersPanel.FontSize = 18;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.DetailedanalysisoffirstordermodelparametersPanel);
            app.GridLayout5.ColumnWidth = {'1x', '1.4x'};
            app.GridLayout5.RowHeight = {'1x'};

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.GridLayout5);
            title(app.UIAxes3, 'Modelling of time constant and gain for current system')
            xlabel(app.UIAxes3, 'Time (hr)')
            ylabel(app.UIAxes3, 'Temperature (deg) with W = 1kW')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.FontSize = 14;
            app.UIAxes3.Layout.Row = 1;
            app.UIAxes3.Layout.Column = 1;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout5);
            title(app.UIAxes2, 'Stored step responses')
            xlabel(app.UIAxes2, 'Time (hr)')
            ylabel(app.UIAxes2, 'Temperature (deg)')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 14;
            app.UIAxes2.Layout.Row = 1;
            app.UIAxes2.Layout.Column = 2;

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout6.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout6.Layout.Row = 3;
            app.GridLayout6.Layout.Column = 1;
            app.GridLayout6.BackgroundColor = [0.702 1 0.702];

            % Create EnvironmentparametersLabel
            app.EnvironmentparametersLabel = uilabel(app.GridLayout6);
            app.EnvironmentparametersLabel.BackgroundColor = [0 1 0];
            app.EnvironmentparametersLabel.HorizontalAlignment = 'center';
            app.EnvironmentparametersLabel.FontSize = 16;
            app.EnvironmentparametersLabel.FontWeight = 'bold';
            app.EnvironmentparametersLabel.Layout.Row = 1;
            app.EnvironmentparametersLabel.Layout.Column = [1 2];
            app.EnvironmentparametersLabel.Text = 'Environment parameters';

            % Create HeatsupplyWkWSliderLabel
            app.HeatsupplyWkWSliderLabel = uilabel(app.GridLayout6);
            app.HeatsupplyWkWSliderLabel.HorizontalAlignment = 'right';
            app.HeatsupplyWkWSliderLabel.FontSize = 14;
            app.HeatsupplyWkWSliderLabel.Layout.Row = 2;
            app.HeatsupplyWkWSliderLabel.Layout.Column = 1;
            app.HeatsupplyWkWSliderLabel.Text = {'Heat supply '; 'W (kW)'};

            % Create HeatsupplyWkWSlider
            app.HeatsupplyWkWSlider = uislider(app.GridLayout6);
            app.HeatsupplyWkWSlider.ValueChangedFcn = createCallbackFcn(app, @HeatsupplyWkWSliderValueChanged, true);
            app.HeatsupplyWkWSlider.FontSize = 14;
            app.HeatsupplyWkWSlider.Layout.Row = 2;
            app.HeatsupplyWkWSlider.Layout.Column = 2;
            app.HeatsupplyWkWSlider.Value = 40;

            % Create ExternaltemperatureTedegSliderLabel
            app.ExternaltemperatureTedegSliderLabel = uilabel(app.GridLayout6);
            app.ExternaltemperatureTedegSliderLabel.HorizontalAlignment = 'right';
            app.ExternaltemperatureTedegSliderLabel.FontSize = 13;
            app.ExternaltemperatureTedegSliderLabel.Layout.Row = 3;
            app.ExternaltemperatureTedegSliderLabel.Layout.Column = 1;
            app.ExternaltemperatureTedegSliderLabel.Text = {'External temperature '; 'Te (deg)'};

            % Create ExternaltemperatureTedegSlider
            app.ExternaltemperatureTedegSlider = uislider(app.GridLayout6);
            app.ExternaltemperatureTedegSlider.Limits = [-10 30];
            app.ExternaltemperatureTedegSlider.ValueChangedFcn = createCallbackFcn(app, @ExternaltemperatureTedegSliderValueChanged, true);
            app.ExternaltemperatureTedegSlider.MinorTicks = [0 5 15 20];
            app.ExternaltemperatureTedegSlider.FontSize = 13;
            app.ExternaltemperatureTedegSlider.Layout.Row = 3;
            app.ExternaltemperatureTedegSlider.Layout.Column = 2;

            % Create InitialtemperatureT0degSliderLabel
            app.InitialtemperatureT0degSliderLabel = uilabel(app.GridLayout6);
            app.InitialtemperatureT0degSliderLabel.HorizontalAlignment = 'right';
            app.InitialtemperatureT0degSliderLabel.FontSize = 13;
            app.InitialtemperatureT0degSliderLabel.Layout.Row = 4;
            app.InitialtemperatureT0degSliderLabel.Layout.Column = 1;
            app.InitialtemperatureT0degSliderLabel.Text = {'Initial temperature'; ' T(0) (deg)'};

            % Create InitialtemperatureT0degSlider
            app.InitialtemperatureT0degSlider = uislider(app.GridLayout6);
            app.InitialtemperatureT0degSlider.Limits = [-10 30];
            app.InitialtemperatureT0degSlider.ValueChangedFcn = createCallbackFcn(app, @InitialtemperatureT0degSliderValueChanged, true);
            app.InitialtemperatureT0degSlider.MinorTicks = [0 10 20 30 40 50];
            app.InitialtemperatureT0degSlider.FontSize = 13;
            app.InitialtemperatureT0degSlider.Layout.Row = 4;
            app.InitialtemperatureT0degSlider.Layout.Column = 2;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = housetemperature_and_behaviour

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

