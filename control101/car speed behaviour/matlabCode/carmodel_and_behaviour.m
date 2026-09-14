classdef carmodel_and_behaviour < matlab.apps.AppBase
    %CARMODEL_AND_BEHAVIOUR
    %   File written by J.A.Rossiter, University of Sheffield  
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   
    %   A simple interface to practice behaviour of a simple car model
    %   subject to changes in mass, friction, enging power road slope
    %   and wind 
    %   Some notes and engineering background are in the partner
    %   livescript file:    carmodel_and_behaviour_manual.mlx
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
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        GridLayout6                   matlab.ui.container.GridLayout
        WindvelocitymsSlider          matlab.ui.control.Slider
        WindvelocitymsSliderLabel     matlab.ui.control.Label
        RoadslopedegSlider            matlab.ui.control.Slider
        RoadslopedegSliderLabel       matlab.ui.control.Label
        EnvironmentparametersLabel    matlab.ui.control.Label
        DetailedanalysisoffirstordermodelparametersPanel  matlab.ui.container.Panel
        GridLayout5                   matlab.ui.container.GridLayout
        UIAxes2                       matlab.ui.control.UIAxes
        UIAxes3                       matlab.ui.control.UIAxes
        GridLayout4                   matlab.ui.container.GridLayout
        MaxenginepowerCkWSlider       matlab.ui.control.Slider
        MaxenginepowerCkWSliderLabel  matlab.ui.control.Label
        CarparametersMdvdtBvCfLabel   matlab.ui.control.Label
        FrictionBNmsSlider            matlab.ui.control.Slider
        FrictionBNmsSliderLabel       matlab.ui.control.Label
        MassMkgSlider                 matlab.ui.control.Slider
        MassMkgLabel                  matlab.ui.control.Label
        GridLayout3                   matlab.ui.container.GridLayout
        AnimationOnButton             matlab.ui.control.Button
        RefreshButton                 matlab.ui.control.Button
        SimulateButton                matlab.ui.control.Button
        GridLayout2                   matlab.ui.container.GridLayout
        Image                         matlab.ui.control.Image
        stordermodelforcarvelocityLabel  matlab.ui.control.Label
        UIAxes                        matlab.ui.control.UIAxes
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
        M;   % car mass
        B;   % friction
        targetspeed = 40; %  in m/s, fix for simplicity
        slope;  % angle of road slope in radians
        wind;   % strength of wind in m/s
        power;  % engine power
        runtime = 20; % for simulation the runtime
        time;  % variable to store time instants for simulation plots
        samples = 201;
        animationtime = 8; % how long animation will take
        Tsamp=0.1;  % update rate for animation
        G;   % system transfer function (input to output)
        F;   % system transfer function (slope to output)
        W;   % system transfer function (wind to output)
        yr;  % output step response to throttle
        ys;  % output step response to slope
        yw;  % step response to wind
        Gss; % steady-state gain
        steadylineplot;  % needed, especially if a square wave
        ytotal; % sum of all output components
        utotal; % sum of all input components
        carxy;  % handle for the plot of car
        ycar;   % ydata only for the car
        carroadxy;  % handle for the upper road barriers
        carroad2xy; % handle for the lower road barriers
        ycarslope  % change in carxy Ydata with a slope
        yroadslope  % change in carroadxy Ydata with a slope
        xroad  %  handle for road x values
        yroad  % handle for road y values
        yroad2  % handle for 2nd road/target
        windarrow   % handle for wind
        windtext % handle for windtext
        
    end
    
    methods (Access = private)
        


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  PLOT OF TOP FIGURE - THE CAR ANIMATION
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function app = createcaroutline(app)
            %%% Define car and road outline
            app.slope=app.RoadslopedegSlider.Value;
            
            hold(app.UIAxes,'off')
            th=pi+0.2:0.3:2*pi-0.1;
            xcircle=0.15*cos(th);
            ycircle=0.15*sin(th);
            xcar=[0.5,1,1.15+xcircle,1.3,1.8,1.95+xcircle,2.1,3.1,2.7,1.9,1.7,1,0.5]+1;
            ycar1=[0.5,0.5,0.5+ycircle,0.5,0.5,0.5+ycircle,0.5,0.5,0.8,1,1.4,1.4,0.5];
            app.xroad=[0,1,1,1.1,1.1,2,2,2.1,2.1,3,3,3.1,3.1,4,4,4.1,4.1,5,5,5.1,5.1,6,6,0];
            yroad1=[0.4,0.4,0.8,0.8,0.4,0.4,0.8,0.8,0.4,0.4,0.8,0.8,0.4,0.4,0.8,0.8,0.4,0.4,0.8,0.8,0.4,0.4,0.35,0.35]-0.05;
            % Update data for a slope and
            app.ycarslope=xcar*sin(app.slope*pi/180); % change in carxy Ydata coordinates if uphill
            app.yroadslope=app.xroad*sin(app.slope*pi/180); % change carroadxy Ydata coordinates if uphill
            app.ycar=ycar1+app.ycarslope;
            app.yroad=yroad1+app.xroad*sin(app.slope*pi/180); 
            app.yroad2=app.yroad-0.6;

            % create car and road objects
            app.carxy=fill(app.UIAxes,xcar,app.ycar,'b');   %% car
            hold(app.UIAxes,'on')
            app.carroadxy=fill(app.UIAxes,app.xroad,app.yroad,'r');  %% posts for speed
            app.carroad2xy=fill(app.UIAxes,app.xroad,app.yroad-0.6,'g');  %% posts for target speed
            axis(app.UIAxes,[0.5,4.5,-1,2.5]);
            
            app.windarrow=quiver(app.UIAxes,[4 4 4.6 4.6 5.2 5.2]-0.6,...
                [0.8 1 0.8 1 0.8 1]+1.2,-[1 1 1 1 1 1],...
                [0 0 0 0 0 0],'linewidth',4,'linestyle','-','Color','g');
            app.windtext=text(app.UIAxes,3.5,2.35,'WIND','fontsize',14,'Color','g');
            
            carleg=legend(app.UIAxes,'Car','Road','Steady state speed','Location','southeast');
            set(carleg,'fontsize',10);

            % Code to update coordinates if needed
            %set(app.carxy,'Ydata',ycar);  %% car
            %set(app.carroadxy,'Ydata',yroad); %% road posts
            %set(app.carroad2xy,'Ydata',yroad-0.6); %% target speed
            
        end      %%% END OF CAROUTLINE SUBFUNCTION

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  Down load data from sliders and create models and responses
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function app = createmodels(app)

            % Collect values from sliders and ensure rounded sensibly
            app.M=app.MassMkgSlider.Value;
            app.B=app.FrictionBNmsSlider.Value;
            app.power=app.MaxenginepowerCkWSlider.Value;
            app.wind=app.WindvelocitymsSlider.Value;
            app.slope=app.RoadslopedegSlider.Value;
            

            % define transfer functions
            % y = G*u + F*slope + W*wind
            app.G=tf(app.power,[app.M,app.B])*1000; % car model
            app.W=tf(app.B,[app.M,app.B]);     % wind to velocity
            app.F=tf(app.M*10,[app.M,app.B]);  % slope to velocity

            % Define the step responses
            app.time=linspace(0,app.runtime,app.samples);
            app.yr = step(app.G,app.time);
            app.yw = step(app.W,app.time);  % scale by wind
            app.ys = step(app.F,app.time);  % scale by slope (in radians)
            app.Gss = dcgain(app.G);
            app.steadylineplot = ones(1,length(app.time))*dcgain(app.G);

            % use superposition to find overall response
            app.ytotal = app.yr-app.yw*app.wind-app.ys*sin(app.slope*pi/180);

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
            T=round(app.M/app.B,2);
            app.legstring{nlegstring+1}=['M = ',num2str(app.M),', B = ',num2str(app.B),', Power = ',num2str(app.power),', \theta = ',num2str(app.slope),', wind = ',num2str(app.wind),', T = ',num2str(T)];
            
            %% initialise figure for speed response
            yplot = plot(app.UIAxes2,app.time(1),app.ytotal(1));
            xlabel(app.UIAxes2,'time (sec)')
            hold(app.UIAxes2,'on')
            xlim(app.UIAxes2,[0,app.runtime]);
            kk=legend(app.UIAxes2,app.legstring,'Location','southeast');
            set(kk,'fontsize',8);
            grid(app.UIAxes2,'on')
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% animation of car and speed plot
            % define animation time aspects
            animationsamples = app.animationtime/app.Tsamp; % assume sample time of Tsamp
            updaterate =ceil(app.samples/animationsamples); % no of samples between pauses
            tstart=tic; tsave = tstart;

            deltax=0;deltax2=0;
            for k=1:length(app.time);
                deltax=deltax+(0.03/36)*app.ytotal(k);
                deltax2 = deltax2+0.03/36*app.Gss;
                if deltax>1; deltax=deltax-1;end
                if deltax<-1;deltax=deltax+1;end
                if deltax2>1; deltax2=deltax2-1;end
                if deltax2<-1;deltax2=deltax2+1;end
                set(app.carroadxy,'Xdata',app.xroad-deltax,'Ydata',app.yroad-deltax*sin(app.slope*pi/180));
                set(app.carroad2xy,'Xdata',app.xroad-deltax2,'Ydata',app.yroad-deltax2*sin(app.slope*pi/180)-0.6);
                set(yplot,'Ydata',app.ytotal(1:k),'Xdata',app.time(1:k));
                
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
            
            T=app.M/app.B;
            plot(app.UIAxes3,app.time,app.yr,'b');
            hold(app.UIAxes3,'on') ;
            plot(app.UIAxes3,[T,T],[0,app.Gss],'r-.','linewidth',3)
            plot(app.UIAxes3,[0,app.runtime],[app.Gss,app.Gss],'g-.','linewidth',3)
            kkk=legend(app.UIAxes3,'Speed','Time constant','Steady-state');
            set(kkk,'fontsize',10);
            text(app.UIAxes3,app.runtime/3,app.Gss/3,['T = ',num2str(T),', Steady-state = ',num2str(app.Gss)],'fontsize', 16);
            xlabel(app.UIAxes3,'time (sec)');
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
            set(app.WindvelocitymsSlider, 'Enable', 'off');
            set(app.RoadslopedegSlider, 'Enable', 'off');
            set(app.MaxenginepowerCkWSlider, 'Enable', 'off');
            set(app.FrictionBNmsSlider, 'Enable', 'off');
            set(app.MassMkgSlider, 'Enable', 'off');
        end
        
        function enablebuttons(app)
            set(app.SimulateButton, 'Enable', 'on');
            set(app.RefreshButton, 'Enable', 'on')
            set(app.AnimationOnButton, 'Enable', 'on')
            set(app.WindvelocitymsSlider, 'Enable', 'on');
            set(app.RoadslopedegSlider, 'Enable', 'on');
            set(app.MaxenginepowerCkWSlider, 'Enable', 'on');
            set(app.FrictionBNmsSlider, 'Enable', 'on');
            set(app.MassMkgSlider, 'Enable', 'on');
        end


    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
           % resize to be in middle of  the window
            movegui(app.UIFigure)
            
            % Open the manual
            if exist('carmodel_and_behaviour_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open carmodel_and_behaviour_mycopy.mlx
            else
                p1 = which('carmodel_and_behaviour_manual.mlx');
                p2 = strcat(pwd,'/carmodel_and_behaviour_mycopy.mlx');
                copyfile(p1,p2)                
                open carmodel_and_behaviour_mycopy.mlx
                clear p1 p2
            end
            
            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);

            app = createcaroutline(app); % define car outline for animation
            
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
            theme(app.UIFigure,"light")
            end
        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
            
            disablebuttons(app);

            app = createmodels(app); % define responses
            app = createcaroutline(app); % define car outline for animation
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

        % Value changed function: MaxenginepowerCkWSlider
        function MaxenginepowerCkWSliderValueChanged(app, event)
            value = app.MaxenginepowerCkWSlider.Value;
            value = round(value,-1);
            if value<5; value=5;end;
            app.MaxenginepowerCkWSlider.Value=value;
            app = createcaroutline(app);

        end

        % Value changed function: FrictionBNmsSlider
        function FrictionBNmsSliderValueChanged(app, event)
            value = app.FrictionBNmsSlider.Value;
            value=round(value,-2); 
            if value<100; value =100;end
            app.FrictionBNmsSlider.Value=value;
            app = createcaroutline(app);
        end

        % Value changed function: MassMkgSlider
        function MassMkgSliderValueChanged(app, event)
            value = app.MassMkgSlider.Value;
            value=round(value,-2);
            app.MassMkgSlider.Value=value;
            app = createcaroutline(app);
           
        end

        % Value changed function: WindvelocitymsSlider
        function WindvelocitymsSliderValueChanged(app, event)
            value = app.WindvelocitymsSlider.Value;
            value=round(value/5)*5;
            app.WindvelocitymsSlider.Value=value;
            app = createcaroutline(app);
            
        end

        % Value changed function: RoadslopedegSlider
        function RoadslopedegSliderValueChanged(app, event)
            value = app.RoadslopedegSlider.Value;
            value = round(value/5)*5;
            app.RoadslopedegSlider.Value=value;
            app = createcaroutline(app);
            
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
            app.UIFigure.Position = [100 100 1062 825];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '2x'};
            app.GridLayout.RowHeight = {'0.4x', '1.3x', '1x', '2x'};

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Animation of car movement')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.XTickLabel = '';
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

            % Create stordermodelforcarvelocityLabel
            app.stordermodelforcarvelocityLabel = uilabel(app.GridLayout2);
            app.stordermodelforcarvelocityLabel.BackgroundColor = [0 1 1];
            app.stordermodelforcarvelocityLabel.HorizontalAlignment = 'center';
            app.stordermodelforcarvelocityLabel.FontSize = 24;
            app.stordermodelforcarvelocityLabel.FontWeight = 'bold';
            app.stordermodelforcarvelocityLabel.Layout.Row = 1;
            app.stordermodelforcarvelocityLabel.Layout.Column = [1 2];
            app.stordermodelforcarvelocityLabel.Text = '1st order model for car velocity';

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
            app.GridLayout4.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout4.Layout.Row = 2;
            app.GridLayout4.Layout.Column = 1;
            app.GridLayout4.BackgroundColor = [0.902 1 0.502];

            % Create MassMkgLabel
            app.MassMkgLabel = uilabel(app.GridLayout4);
            app.MassMkgLabel.HorizontalAlignment = 'right';
            app.MassMkgLabel.FontSize = 14;
            app.MassMkgLabel.Layout.Row = 2;
            app.MassMkgLabel.Layout.Column = 1;
            app.MassMkgLabel.Text = 'Mass: M (kg)';

            % Create MassMkgSlider
            app.MassMkgSlider = uislider(app.GridLayout4);
            app.MassMkgSlider.Limits = [500 2000];
            app.MassMkgSlider.MajorTicks = [500 1000 1500 2000];
            app.MassMkgSlider.ValueChangedFcn = createCallbackFcn(app, @MassMkgSliderValueChanged, true);
            app.MassMkgSlider.MinorTicks = [500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000];
            app.MassMkgSlider.FontSize = 14;
            app.MassMkgSlider.Layout.Row = 2;
            app.MassMkgSlider.Layout.Column = 2;
            app.MassMkgSlider.Value = 800;

            % Create FrictionBNmsSliderLabel
            app.FrictionBNmsSliderLabel = uilabel(app.GridLayout4);
            app.FrictionBNmsSliderLabel.HorizontalAlignment = 'right';
            app.FrictionBNmsSliderLabel.FontSize = 14;
            app.FrictionBNmsSliderLabel.Layout.Row = 3;
            app.FrictionBNmsSliderLabel.Layout.Column = 1;
            app.FrictionBNmsSliderLabel.Text = 'Friction: B (Nms)';

            % Create FrictionBNmsSlider
            app.FrictionBNmsSlider = uislider(app.GridLayout4);
            app.FrictionBNmsSlider.Limits = [0 1000];
            app.FrictionBNmsSlider.ValueChangedFcn = createCallbackFcn(app, @FrictionBNmsSliderValueChanged, true);
            app.FrictionBNmsSlider.MinorTicks = [0 100 200 300 400 500 600 700 800 900 1000];
            app.FrictionBNmsSlider.FontSize = 14;
            app.FrictionBNmsSlider.Layout.Row = 3;
            app.FrictionBNmsSlider.Layout.Column = 2;
            app.FrictionBNmsSlider.Value = 200;

            % Create CarparametersMdvdtBvCfLabel
            app.CarparametersMdvdtBvCfLabel = uilabel(app.GridLayout4);
            app.CarparametersMdvdtBvCfLabel.BackgroundColor = [1 1 0];
            app.CarparametersMdvdtBvCfLabel.HorizontalAlignment = 'center';
            app.CarparametersMdvdtBvCfLabel.FontSize = 16;
            app.CarparametersMdvdtBvCfLabel.FontWeight = 'bold';
            app.CarparametersMdvdtBvCfLabel.Layout.Row = 1;
            app.CarparametersMdvdtBvCfLabel.Layout.Column = [1 2];
            app.CarparametersMdvdtBvCfLabel.Text = 'Car parameters: M(dv/dt) + Bv = C f';

            % Create MaxenginepowerCkWSliderLabel
            app.MaxenginepowerCkWSliderLabel = uilabel(app.GridLayout4);
            app.MaxenginepowerCkWSliderLabel.HorizontalAlignment = 'right';
            app.MaxenginepowerCkWSliderLabel.FontSize = 13;
            app.MaxenginepowerCkWSliderLabel.Layout.Row = 4;
            app.MaxenginepowerCkWSliderLabel.Layout.Column = 1;
            app.MaxenginepowerCkWSliderLabel.Text = {'Max. engine power:'; ' C (kW)'};

            % Create MaxenginepowerCkWSlider
            app.MaxenginepowerCkWSlider = uislider(app.GridLayout4);
            app.MaxenginepowerCkWSlider.Limits = [0 50];
            app.MaxenginepowerCkWSlider.ValueChangedFcn = createCallbackFcn(app, @MaxenginepowerCkWSliderValueChanged, true);
            app.MaxenginepowerCkWSlider.MinorTicks = [0 10 20 30 40 50];
            app.MaxenginepowerCkWSlider.FontSize = 13;
            app.MaxenginepowerCkWSlider.Layout.Row = 4;
            app.MaxenginepowerCkWSlider.Layout.Column = 2;
            app.MaxenginepowerCkWSlider.Value = 10;

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
            xlabel(app.UIAxes3, 'Time (s)')
            ylabel(app.UIAxes3, 'Speed (m/s)')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.FontSize = 14;
            app.UIAxes3.Layout.Row = 1;
            app.UIAxes3.Layout.Column = 1;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout5);
            title(app.UIAxes2, 'Stored step responses with f(t)=1')
            xlabel(app.UIAxes2, 'Time (s)')
            ylabel(app.UIAxes2, 'Speed (m/s)')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 14;
            app.UIAxes2.Layout.Row = 1;
            app.UIAxes2.Layout.Column = 2;

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout6.RowHeight = {'1x', '1x', '1x'};
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

            % Create RoadslopedegSliderLabel
            app.RoadslopedegSliderLabel = uilabel(app.GridLayout6);
            app.RoadslopedegSliderLabel.HorizontalAlignment = 'right';
            app.RoadslopedegSliderLabel.FontSize = 14;
            app.RoadslopedegSliderLabel.Layout.Row = 2;
            app.RoadslopedegSliderLabel.Layout.Column = 1;
            app.RoadslopedegSliderLabel.Text = 'Road slope (deg)';

            % Create RoadslopedegSlider
            app.RoadslopedegSlider = uislider(app.GridLayout6);
            app.RoadslopedegSlider.Limits = [-20 20];
            app.RoadslopedegSlider.MajorTicks = [-20 -15 -10 -5 0 5 10 15 20];
            app.RoadslopedegSlider.ValueChangedFcn = createCallbackFcn(app, @RoadslopedegSliderValueChanged, true);
            app.RoadslopedegSlider.MinorTicks = [-20 -15 -10 -5 0 5 10 15 20];
            app.RoadslopedegSlider.FontSize = 14;
            app.RoadslopedegSlider.Layout.Row = 2;
            app.RoadslopedegSlider.Layout.Column = 2;

            % Create WindvelocitymsSliderLabel
            app.WindvelocitymsSliderLabel = uilabel(app.GridLayout6);
            app.WindvelocitymsSliderLabel.HorizontalAlignment = 'right';
            app.WindvelocitymsSliderLabel.FontSize = 13;
            app.WindvelocitymsSliderLabel.Layout.Row = 3;
            app.WindvelocitymsSliderLabel.Layout.Column = 1;
            app.WindvelocitymsSliderLabel.Text = 'Wind velocity (m/s)';

            % Create WindvelocitymsSlider
            app.WindvelocitymsSlider = uislider(app.GridLayout6);
            app.WindvelocitymsSlider.Limits = [0 20];
            app.WindvelocitymsSlider.MajorTicks = [0 5 10 15 20];
            app.WindvelocitymsSlider.ValueChangedFcn = createCallbackFcn(app, @WindvelocitymsSliderValueChanged, true);
            app.WindvelocitymsSlider.MinorTicks = [0 5 15 20];
            app.WindvelocitymsSlider.FontSize = 13;
            app.WindvelocitymsSlider.Layout.Row = 3;
            app.WindvelocitymsSlider.Layout.Column = 2;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = carmodel_and_behaviour

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

