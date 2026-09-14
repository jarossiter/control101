classdef mixingtank_and_behaviour < matlab.apps.AppBase
    %MIXINGTANK_AND_BEHAVIOUR
    %   File written by J.A.Rossiter, University of Sheffield
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %      
    %   A simple interface to practice the behaviour of a mixing tank, with
    %   and without a reaction
    %       
    %   Some notes and engineering background are in the partner livescript
    %   file:    mxingtank_and_behaviour_manual.mlx
    %   A group of similar files can be downloaded through MATLAB add-ons
    %   with the toolbox name:  control101
    %      
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   FILE ORGANISATION
    %       A section defining the core variables stored in "app"
    %       
    %       A section with subfunctions doing the core computations
    %       i) define transfer functions for open-loop; 
    %       ii) find linear responses to inputs and disturbances; 
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
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        GridLayout6                     matlab.ui.container.GridLayout
        InletdisturbanceSlider          matlab.ui.control.Slider
        InletdisturbanceSliderLabel     matlab.ui.control.Label
        ReactionrateSlider              matlab.ui.control.Slider
        ReactionrateSliderLabel         matlab.ui.control.Label
        Inletconcentrationmolem3Slider  matlab.ui.control.Slider
        Inletconcentrationmolem3SliderLabel  matlab.ui.control.Label
        EnvironmentparametersLabel      matlab.ui.control.Label
        DetailedanalysisoffirstordermodelparametersPanel  matlab.ui.container.Panel
        GridLayout5                     matlab.ui.container.GridLayout
        UIAxes2                         matlab.ui.control.UIAxes
        UIAxes3                         matlab.ui.control.UIAxes
        GridLayout4                     matlab.ui.container.GridLayout
        Initialconcentrationmolem3Slider  matlab.ui.control.Slider
        Initialconcentrationmolem3SliderLabel  matlab.ui.control.Label
        TankparametersVdCdtFCFCinLabel  matlab.ui.control.Label
        Flowratem3sSlider               matlab.ui.control.Slider
        Flowratem3sSliderLabel          matlab.ui.control.Label
        Tankvolumem3Slider              matlab.ui.control.Slider
        Tankvolumem3SliderLabel         matlab.ui.control.Label
        GridLayout3                     matlab.ui.container.GridLayout
        AnimationOnButton               matlab.ui.control.Button
        RefreshButton                   matlab.ui.control.Button
        SimulateButton                  matlab.ui.control.Button
        GridLayout2                     matlab.ui.container.GridLayout
        Image                           matlab.ui.control.Image
        stordermodelformixingtankLabel  matlab.ui.control.Label
        UIAxes                          matlab.ui.control.UIAxes
    end

%     File written by J.A.Rossiter, University of Sheffield
%     See website for more files like this.
%     https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
%     A simple interface to practice the behaviour of a mixing tank, 
%     with and without a reaction
%     
%     Some notes and engineering background are in the partner livescript
%     file:    mxingtank_and_behaviour_manual.mlx
%     A group of similar files can be downloaded through MATLAB add-ons
%     with the toolbox name:  ********************
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%  FILE ORGANISATION
%     A section defining the core variables stored in "app"
%     
%     A section with subfunctions doing the core computations
%     i) define transfer functions for open-loop; 
%     ii) find linear responses to inputs and disturbances; 
%     iii) initialise figures for animations; 
%     vi) control the animations
%     v) Switch interaction on and off during animations
%     vi) Clean figures and legends so can begin a new investigation
%     vii) callbacks (subfunctions) for every item in the interface to control decimal
%     places and the like.
%     
%     A core subfunction (callback) activates with the 'start simulation' button
%     and runs the subfunctions in turn.
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     
    % The next section defines all the core variables used in the code and
    % that it may be convenient to have available in the various
    % subfunctions

    properties (Access = private)
         originalsize     % product of width and height for font sizing


        legstring=cell(1); % To store legends
        V;   % tank volume
        F;   % flow rate
        targetconcentration; %  
        inlet;  % inlet concentration
        reaction;   % reaction rate
        initial;  % initial concentration
        disturbance;  % inlet disturbance for T sec (T to 2T)
        
        runtime; % for simulation the runtime
        samples=201;  % number of samples
        time;  % variable to store time instants for simulation plots
        T;   % time constant
        K;   % system gain (1st order model)
        animationtime = 8; % how long animation will take
        Tsamp=0.1;  % update rate for animation

        
        ct;  % output step response to throttle
        cdist % perturbation caused by disturbance
        steadyvalue;  % steady state
        steadylineplot;  % might be needed
        ytotal; % sum of all output components
        utotal; % sum of all input components

        inhandle;  % inlet pipe colour
        outhandle; % outlet pipe colour
        pipewidth; % link to flow
        tankwidth;  % link to volume
        
        
        
    end
    
    methods (Access = private)
        


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  PLOT OF TOP FIGURE - THE TANK ANIMATION
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     function app = createtankoutline(app)
                
         hold(app.UIAxes,'off')
         % Round parameter values to sensible decimal places
         
         
         app.initial = app.Initialconcentrationmolem3Slider.Value;
         app.inlet = app.Inletconcentrationmolem3Slider.Value;
         app.disturbance=app.InletdisturbanceSlider.Value;
         
         
         %%% Define TANK outline
         % extra 0.02 used for line width
         xx = app.Flowratem3sSlider.Value;
         yy = 0.5+app.Tankvolumem3Slider.Value;
         hold(app.UIAxes,'off')
         xlower=[0,0.5,0.5,yy,yy,5];
         xupper1=[0,0.5,0.5];
         xupper2=[yy,yy,5];
         ylower=[2-0.02,2-0.02,0.1,0.1,0.2-0.02,0.2-0.02];
         yupper1=[2+xx+0.02,2+xx+0.02,2.5]; 
         yupper2=[2.5,0.22+xx,0.22+xx];
         plot(app.UIAxes,xlower,ylower,'k','linewidth',3)
         hold(app.UIAxes,'on');
         plot(app.UIAxes,[xupper1,xupper2],[yupper1,yupper2],'k','linewidth',3)
         plot(app.UIAxes,xupper2,yupper2,'k','linewidth',3)
         text(app.UIAxes,0.1,1.8,'Flow in','fontsize',14)
         text(app.UIAxes,4.6,0.5,'Flow out','fontsize',14)
         %axis([-0.2,4.2,-0.2,2.7]);
         set(app.UIAxes,'XTickLabel',{' ',' '},'XTick',[-0.2 4.2]);
         set(app.UIAxes,'YTickLabel',{' ',' '},'YTick',[-0.2 2.7]);
        
        %%%% define colour infill for tank linked to concentration
        xinlet=[0 .52 .52 0]; 
        yinlet=[2.0 2.0 2+xx 2+xx];
        xtank=[.52,.52,yy-0.02,yy-0.02,5,5,yy-0.02,yy-0.02,1.02];
        ytank=[2.48,0.12,0.12,0.2,0.2,0.2+xx,0.2+xx,2.48,2.48];
          
        %%% Handles to create and manage colour in tank
        kinitial=app.initial/0.5;
        kinlet = app.inlet/0.5;
        app.inhandle = fill(app.UIAxes,xinlet,yinlet,[1-kinlet,0,kinlet]);
        app.outhandle = fill(app.UIAxes,xtank,ytank,[1-kinitial,0,kinitial]);
        
        ylim(app.UIAxes,[0,2.6])
        
                    
        end      %%% END OF TANKOUTLINE SUBFUNCTION

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  Down load data from sliders and create models and responses
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function app = createmodels(app)

            % Collect values from sliders and ensure rounded sensibly
            app.V=app.Tankvolumem3Slider.Value;
            app.F=app.Flowratem3sSlider.Value;
            app.initial=app.Initialconcentrationmolem3Slider.Value;
            app.inlet=app.Inletconcentrationmolem3Slider.Value;
            app.reaction=app.ReactionrateSlider.Value;
            
           
            % define models of behaviour
            %  V dC/dt + FC = F Cin -rVC
            %  T dC/dt + C = K Cin ==> T =V/(f+rV),  K =F/(F+rV)
            %  C(t) = KCin(1-exp(-t/T)) + C(0) exp(-t/T)
            app.T = app.V/(app.F + app.V*app.reaction);
            app.K = app.F/(app.F + app.V*app.reaction);
            app.runtime = round(5*app.T/10)*10;

            % Define the step responses
            
            app.time=linspace(0,app.runtime,app.samples);
            expterm = exp(-app.time/app.T);
            app.ct = app.K*app.inlet*(1-expterm) + app.initial*expterm;
            app.steadyvalue = app.K*app.inlet;
            app.steadylineplot = ones(1,length(app.time))*app.steadyvalue;

            % define the disturbance response (acts for 50:75 samples);
            steponly = app.K*(1-expterm)*app.disturbance;
            app.cdist = zeros(1,app.samples);
            app.cdist(40:app.samples)=steponly(1:app.samples-39);
            app.cdist(60:app.samples) = app.cdist(60:app.samples)-steponly(1:app.samples-59);

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
            Ttext = round(app.T,3,'significant');
            app.legstring{nlegstring+1}=['V = ',num2str(app.V),', F = ',num2str(app.F),...
                ', reaction = ',num2str(app.reaction),', T = ',num2str(Ttext),', inlet = ',num2str(app.inlet),', disturbance = ',num2str(app.disturbance)];
            
            %% initialise figure for concentration response
            yplot = plot(app.UIAxes2,app.time(1),app.ct(1));
            xlabel(app.UIAxes2,'time (sec)')
            hold(app.UIAxes2,'on')
            %xlim(app.UIAxes2,[0,app.runtime]);
            kk=legend(app.UIAxes2,app.legstring,'Location','southeast');
            set(kk,'fontsize',8);
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% animation of tank and concentration plot
            app.ct = app.ct+app.cdist;  % add disturbance impact
            colour = app.ct/0.6;

            % define animation time aspects
            animationsamples = app.animationtime/app.Tsamp; % assume sample time of Tsamp
            updaterate =ceil(app.samples/animationsamples); % no of samples between pauses
            tstart=tic; tsave = tstart;
            
            
            for k=1:length(app.time);
                

                if colour(k)>1; colour(k)=1;end % disturbances can over concentrate

                set(app.outhandle,'FaceColor',[1-colour(k),0,colour(k)]);

                set(yplot,'Ydata',app.ct(1:k),'Xdata',app.time(1:k));
                
                % Pause animation every updaterate samples only so rem(k,updaterate) 
                % checks for this
                if and(strcmp(app.AnimationOnButton.Text,'Animation On'),not(rem(k,updaterate)));
                    pause(app.Tsamp-toc(tstart));  %% Clumsy application of sampling time
                    tstart = tic;
                    drawnow limitrate
                end
            end
            %ttotal= toc(tsave);  % total time taken by animation loop
            grid(app.UIAxes2,"on");
            
        end  % end of animation

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  Time constant and gain analysis
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
        function app = timeconstantanalysis(app)
            
            
            plot(app.UIAxes3,app.time,app.ct,'b');
            hold(app.UIAxes3,'on') ;
            plot(app.UIAxes3,[app.T,app.T],[app.initial,app.steadyvalue],'r-.','linewidth',3)
            plot(app.UIAxes3,[0,app.runtime],[1,1]*app.steadyvalue,'g-.','linewidth',3)
            kkk=legend(app.UIAxes3,'Concentration','Time constant','Steady-state');
            set(kkk,'fontsize',10);
            pos = (app.initial+app.steadyvalue)/2;
            text(app.UIAxes3,app.runtime/3,pos,['T = ',num2str(app.T),', Steady-state = ',num2str(app.steadyvalue)],'fontsize', 16);
            xlabel(app.UIAxes3,'time (sec)');
            grid(app.UIAxes3,'on');
            hold(app.UIAxes3,'off');

        end  % end of timeconstant and gain analysis figure



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Control interaction during the animation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function  disablebuttons(app)
            set(app.SimulateButton, 'Enable', 'off');
            set(app.RefreshButton, 'Enable', 'off')
            set(app.AnimationOnButton, 'Enable', 'off')
            set(app.Initialconcentrationmolem3Slider, 'Enable', 'off')
            set(app.Inletconcentrationmolem3Slider, 'Enable', 'off')
            set(app.ReactionrateSlider, 'Enable', 'off')
            set(app.InletdisturbanceSlider, 'Enable', 'off')
            set(app.Tankvolumem3Slider, 'Enable', 'off')
            set(app.Flowratem3sSlider, 'Enable', 'off')

        end
        
        function enablebuttons(app)
            set(app.SimulateButton, 'Enable', 'on');
            set(app.RefreshButton, 'Enable', 'on');
            set(app.AnimationOnButton, 'Enable', 'on');
            set(app.Initialconcentrationmolem3Slider, 'Enable', 'on')
            set(app.Inletconcentrationmolem3Slider, 'Enable', 'on')
            set(app.ReactionrateSlider, 'Enable', 'on')
            set(app.InletdisturbanceSlider, 'Enable', 'on')
            set(app.Tankvolumem3Slider, 'Enable', 'on')
            set(app.Flowratem3sSlider, 'Enable', 'on')
        end


    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % resize to be in middle of  the window
            movegui(app.UIFigure)
            
            % Open the manual
            if exist('mixingtank_and_behaviour_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open mixingtank_and_behaviour_mycopy.mlx
            else
                p1 = which('mixingtank_and_behaviour_manual.mlx');
                p2 = strcat(pwd,'/mixingtank_and_behaviour_mycopy.mlx');
                copyfile(p1,p2)                
                open mixingtank_and_behaviour_mycopy.mlx
                clear p1 p2
            end
            
            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);

            % draw tank and update handles
            app = createtankoutline(app);
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
                theme(app.UIFigure,"light")
            end
        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
            
            disablebuttons(app);
            app = createtankoutline(app); % define tank outline for animation
            app = createmodels(app); % define responses
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

        % Value changed function: Tankvolumem3Slider
        function Tankvolumem3SliderValueChanged(app, event)
            value = app.Tankvolumem3Slider.Value;
            value = round(value*2,0)/2; % precise to 0.5
            app.Tankvolumem3Slider.Value=value;
            app = createtankoutline(app); % define tank outline for animation
           

        end

        % Value changed function: Flowratem3sSlider
        function Flowratem3sSliderValueChanged(app, event)
            value = app.Flowratem3sSlider.Value;
            value = round(value,2); % precise to 0.01
            if value<0.02;value=0.02;end
            app.Flowratem3sSlider.Value=value;
            app = createtankoutline(app); % define tank outline for animation
        end

        % Value changed function: Initialconcentrationmolem3Slider
        function Initialconcentrationmolem3SliderValueChanged(app, event)
            value = app.Initialconcentrationmolem3Slider.Value;
            value = round(value,1); % precise to 0.1
            app.Initialconcentrationmolem3Slider.Value=value;
            app = createtankoutline(app); % define tank outline for animation
        end

        % Value changed function: Inletconcentrationmolem3Slider
        function Inletconcentrationmolem3SliderValueChanged(app, event)
            value = app.Inletconcentrationmolem3Slider.Value;
            value = round(value,1); % precise to 0.1
            app.Inletconcentrationmolem3Slider.Value=value;
            app = createtankoutline(app); % define tank outline for animation
            
        end

        % Value changed function: ReactionrateSlider
        function ReactionrateSliderValueChanged(app, event)
            value = app.ReactionrateSlider.Value;
            value = round(value,2); % precise to 0.01
            app.ReactionrateSlider.Value=value;
        end

        % Value changed function: InletdisturbanceSlider
        function InletdisturbanceSliderValueChanged(app, event)
            value = app.InletdisturbanceSlider.Value;
            value = round(value,1); % precise to 0.01
            app.InletdisturbanceSlider.Value=value;
            
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
            app.UIFigure.Position = [100 100 1109 872];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '2x'};
            app.GridLayout.RowHeight = {'0.4x', '1.2x', '1.2x', '2x'};

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Animation of concentration in tank')
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

            % Create stordermodelformixingtankLabel
            app.stordermodelformixingtankLabel = uilabel(app.GridLayout2);
            app.stordermodelformixingtankLabel.BackgroundColor = [0 1 1];
            app.stordermodelformixingtankLabel.HorizontalAlignment = 'center';
            app.stordermodelformixingtankLabel.FontSize = 24;
            app.stordermodelformixingtankLabel.FontWeight = 'bold';
            app.stordermodelformixingtankLabel.Layout.Row = 1;
            app.stordermodelformixingtankLabel.Layout.Column = [1 2];
            app.stordermodelformixingtankLabel.Text = '1st order model for mixing tank';

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
            app.GridLayout4.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout4.Layout.Row = 2;
            app.GridLayout4.Layout.Column = 1;
            app.GridLayout4.BackgroundColor = [0.902 1 0.502];

            % Create Tankvolumem3SliderLabel
            app.Tankvolumem3SliderLabel = uilabel(app.GridLayout4);
            app.Tankvolumem3SliderLabel.HorizontalAlignment = 'right';
            app.Tankvolumem3SliderLabel.FontSize = 14;
            app.Tankvolumem3SliderLabel.Layout.Row = 2;
            app.Tankvolumem3SliderLabel.Layout.Column = 1;
            app.Tankvolumem3SliderLabel.Text = 'Tank volume (m^3)';

            % Create Tankvolumem3Slider
            app.Tankvolumem3Slider = uislider(app.GridLayout4);
            app.Tankvolumem3Slider.Limits = [0.5 4];
            app.Tankvolumem3Slider.ValueChangedFcn = createCallbackFcn(app, @Tankvolumem3SliderValueChanged, true);
            app.Tankvolumem3Slider.MinorTicks = [500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000];
            app.Tankvolumem3Slider.FontSize = 14;
            app.Tankvolumem3Slider.Layout.Row = 2;
            app.Tankvolumem3Slider.Layout.Column = 2;
            app.Tankvolumem3Slider.Value = 1;

            % Create Flowratem3sSliderLabel
            app.Flowratem3sSliderLabel = uilabel(app.GridLayout4);
            app.Flowratem3sSliderLabel.HorizontalAlignment = 'right';
            app.Flowratem3sSliderLabel.FontSize = 14;
            app.Flowratem3sSliderLabel.Layout.Row = 3;
            app.Flowratem3sSliderLabel.Layout.Column = 1;
            app.Flowratem3sSliderLabel.Text = 'Flow rate (m^3/s)';

            % Create Flowratem3sSlider
            app.Flowratem3sSlider = uislider(app.GridLayout4);
            app.Flowratem3sSlider.Limits = [0 0.2];
            app.Flowratem3sSlider.ValueChangedFcn = createCallbackFcn(app, @Flowratem3sSliderValueChanged, true);
            app.Flowratem3sSlider.MinorTicks = [0 100 200 300 400 500 600 700 800 900 1000];
            app.Flowratem3sSlider.FontSize = 14;
            app.Flowratem3sSlider.Layout.Row = 3;
            app.Flowratem3sSlider.Layout.Column = 2;
            app.Flowratem3sSlider.Value = 0.1;

            % Create TankparametersVdCdtFCFCinLabel
            app.TankparametersVdCdtFCFCinLabel = uilabel(app.GridLayout4);
            app.TankparametersVdCdtFCFCinLabel.BackgroundColor = [1 1 0];
            app.TankparametersVdCdtFCFCinLabel.HorizontalAlignment = 'center';
            app.TankparametersVdCdtFCFCinLabel.FontSize = 16;
            app.TankparametersVdCdtFCFCinLabel.FontWeight = 'bold';
            app.TankparametersVdCdtFCFCinLabel.Layout.Row = 1;
            app.TankparametersVdCdtFCFCinLabel.Layout.Column = [1 2];
            app.TankparametersVdCdtFCFCinLabel.Text = 'Tank parameters: V(dC/dt) + FC = F Cin';

            % Create Initialconcentrationmolem3SliderLabel
            app.Initialconcentrationmolem3SliderLabel = uilabel(app.GridLayout4);
            app.Initialconcentrationmolem3SliderLabel.HorizontalAlignment = 'right';
            app.Initialconcentrationmolem3SliderLabel.FontSize = 13;
            app.Initialconcentrationmolem3SliderLabel.Layout.Row = 4;
            app.Initialconcentrationmolem3SliderLabel.Layout.Column = 1;
            app.Initialconcentrationmolem3SliderLabel.Text = 'Initial concentration  (mole/m^3)';

            % Create Initialconcentrationmolem3Slider
            app.Initialconcentrationmolem3Slider = uislider(app.GridLayout4);
            app.Initialconcentrationmolem3Slider.Limits = [0 0.5];
            app.Initialconcentrationmolem3Slider.ValueChangedFcn = createCallbackFcn(app, @Initialconcentrationmolem3SliderValueChanged, true);
            app.Initialconcentrationmolem3Slider.MinorTicks = [0 10 20 30 40 50];
            app.Initialconcentrationmolem3Slider.FontSize = 13;
            app.Initialconcentrationmolem3Slider.Layout.Row = 4;
            app.Initialconcentrationmolem3Slider.Layout.Column = 2;
            app.Initialconcentrationmolem3Slider.Value = 0.1;

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
            ylabel(app.UIAxes3, 'Concentration')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.FontSize = 14;
            app.UIAxes3.Layout.Row = 1;
            app.UIAxes3.Layout.Column = 1;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout5);
            title(app.UIAxes2, 'Stored step responses')
            xlabel(app.UIAxes2, 'Time (s)')
            ylabel(app.UIAxes2, 'Outlet Concentration')
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

            % Create Inletconcentrationmolem3SliderLabel
            app.Inletconcentrationmolem3SliderLabel = uilabel(app.GridLayout6);
            app.Inletconcentrationmolem3SliderLabel.HorizontalAlignment = 'right';
            app.Inletconcentrationmolem3SliderLabel.FontSize = 14;
            app.Inletconcentrationmolem3SliderLabel.Layout.Row = 2;
            app.Inletconcentrationmolem3SliderLabel.Layout.Column = 1;
            app.Inletconcentrationmolem3SliderLabel.Text = 'Inlet concentration (mole/m^3)';

            % Create Inletconcentrationmolem3Slider
            app.Inletconcentrationmolem3Slider = uislider(app.GridLayout6);
            app.Inletconcentrationmolem3Slider.Limits = [0 0.5];
            app.Inletconcentrationmolem3Slider.ValueChangedFcn = createCallbackFcn(app, @Inletconcentrationmolem3SliderValueChanged, true);
            app.Inletconcentrationmolem3Slider.FontSize = 14;
            app.Inletconcentrationmolem3Slider.Layout.Row = 2;
            app.Inletconcentrationmolem3Slider.Layout.Column = 2;
            app.Inletconcentrationmolem3Slider.Value = 0.4;

            % Create ReactionrateSliderLabel
            app.ReactionrateSliderLabel = uilabel(app.GridLayout6);
            app.ReactionrateSliderLabel.HorizontalAlignment = 'right';
            app.ReactionrateSliderLabel.FontSize = 13;
            app.ReactionrateSliderLabel.Layout.Row = 3;
            app.ReactionrateSliderLabel.Layout.Column = 1;
            app.ReactionrateSliderLabel.Text = 'Reaction rate';

            % Create ReactionrateSlider
            app.ReactionrateSlider = uislider(app.GridLayout6);
            app.ReactionrateSlider.Limits = [0 0.1];
            app.ReactionrateSlider.ValueChangedFcn = createCallbackFcn(app, @ReactionrateSliderValueChanged, true);
            app.ReactionrateSlider.FontSize = 13;
            app.ReactionrateSlider.Layout.Row = 3;
            app.ReactionrateSlider.Layout.Column = 2;

            % Create InletdisturbanceSliderLabel
            app.InletdisturbanceSliderLabel = uilabel(app.GridLayout6);
            app.InletdisturbanceSliderLabel.HorizontalAlignment = 'right';
            app.InletdisturbanceSliderLabel.FontSize = 14;
            app.InletdisturbanceSliderLabel.Layout.Row = 4;
            app.InletdisturbanceSliderLabel.Layout.Column = 1;
            app.InletdisturbanceSliderLabel.Text = 'Inlet disturbance';

            % Create InletdisturbanceSlider
            app.InletdisturbanceSlider = uislider(app.GridLayout6);
            app.InletdisturbanceSlider.Limits = [0 0.5];
            app.InletdisturbanceSlider.ValueChangedFcn = createCallbackFcn(app, @InletdisturbanceSliderValueChanged, true);
            app.InletdisturbanceSlider.Layout.Row = 4;
            app.InletdisturbanceSlider.Layout.Column = 2;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = mixingtank_and_behaviour

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

