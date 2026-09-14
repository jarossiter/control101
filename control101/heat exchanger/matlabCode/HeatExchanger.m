classdef HeatExchanger < matlab.apps.AppBase
    %HEATEXCHANGER
    %   File written by J.A.Rossiter, University of Sheffield  
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   
    %   A simple interface to practice behaviour of a heat exchanger
    %   model subject to disturbance in flow and inlet temperature.
    %   
    %   Some notes and engineering background are in the partner
    %   livescript file:    HeatExchanger_manual.mlx
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
        GridLayout6                    matlab.ui.container.GridLayout
        TinDisturbanceCSlider          matlab.ui.control.Slider
        TinDisturbanceCSliderLabel     matlab.ui.control.Label
        FlowDisturbancem3sSlider       matlab.ui.control.Slider
        FlowDisturbancem3sSliderLabel  matlab.ui.control.Label
        EnvironmentparametersLabel     matlab.ui.control.Label
        DetailedanalysisoffirstordermodelparametersPanel  matlab.ui.container.Panel
        GridLayout5                    matlab.ui.container.GridLayout
        UIAxes2                        matlab.ui.control.UIAxes
        UIAxes3                        matlab.ui.control.UIAxes
        GridLayout4                    matlab.ui.container.GridLayout
        QkgsecSlider                   matlab.ui.control.Slider
        SteamFlowRateQLabel            matlab.ui.control.Label
        Flowinm3sSlider                matlab.ui.control.Slider
        Flowinm3sLabel                 matlab.ui.control.Label
        VFdtdtTTinCpFQLabel            matlab.ui.control.Label
        Vm3Slider                      matlab.ui.control.Slider
        VLabel                         matlab.ui.control.Label
        TinCSlider                     matlab.ui.control.Slider
        InletTTinLabel                 matlab.ui.control.Label
        GridLayout3                    matlab.ui.container.GridLayout
        AnimationOnButton              matlab.ui.control.Button
        RefreshButton                  matlab.ui.control.Button
        SimulateButton                 matlab.ui.control.Button
        GridLayout2                    matlab.ui.container.GridLayout
        Image                          matlab.ui.control.Image
        stordermodelforHeatExchangerLabel  matlab.ui.control.Label
        UIAxes                         matlab.ui.control.UIAxes
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
        Tin;     % Inlet Temperature      
        Tindist % Inlet  temperature disturbance
        Flowin;  % inlet flow
        Flowindist;   % disturbance in inlet flow 
        Q; %Steam Flow Rate
        V; %Volume     
        T0=10;%  initial tank temperature
               
        runtime = 10; % for simulation the runtime
        time;  % variable to store time instants for simulation plots
        samples = 201;
        animationtime = 6; % how long animation will take
        Tsamp=0.1;  % update rate for animation
        G;   % system transfer function (input to output)
        G1; % System TF when Q is constant
        G2; % System TF when Tin is constant including disturbances
       
        yr;  % output step response Q constant
        yrr;  % output stepTin constant
        ydd;  % overall system output response
        yplot % handle for animation of line plots
        Gss; % steady-state gain total
        Gsss; % steady-state gain total
        Gssd; % steady-state with a blockage
        steadylineplot;  % needed, especially if a square wave
        Timeconstant; % System time constant including disturbances
        thermo=0;
        watertank;
    end 
    methods (Access = private)
       
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  PLOT OF TOP FIGURE - THE CAR ANIMATION
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 function app = createtankoutline(app);

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Set up basic picture of the heat exchanger in the top plot

      hold(app.UIAxes,'off')
      plot(app.UIAxes,0,0)
           
        % heat exchanger parameters and initial plot
        app.Tin=app.TinCSlider.Value;
        app.V=app.Vm3Slider.Value;
        app.Flowin=app.Flowinm3sSlider.Value;
        app.Tindist=app.TinDisturbanceCSlider.Value; 
        app.Flowindist=app.FlowDisturbancem3sSlider.Value; 
        app.Q=app.QkgsecSlider.Value;
        app.runtime=round(app.V/app.Tin,0)*4;
        Tin=app.Tin+app.Tindist;
        Flowin=app.Flowin;
        Q=app.Q;
        V=app.V;

        % Tank outline
        hold(app.UIAxes,'on')
        x1=[0,1,1,app.V+1,app.V+1,app.V+2];
        y1=[4.46-app.Flowin,4.46-app.Flowin,0.5,0.5,1,1];
        x2=x1;
        y2=[4.5,4.5,5,5,1.04+app.Flowin,1.04+app.Flowin];
        a=plot(app.UIAxes, x1,y1,'k',x2,y2,'k');
        set(a,'linewidth',3);
        xlim(app.UIAxes,[0,7])
        
        % water parameters
        waterinx=[0 1 1 0];
        wateriny=[4.48-app.Flowin 4.48-app.Flowin 4.48 4.48];
        watertankx=[x1(2:end)+0.02,fliplr(x2(2:end))-0.02];
        watertanky=[y1(2:end)+0.02,fliplr(y2(2:end))-0.02];
        waterin=fill(app.UIAxes,waterinx,wateriny,[0 0 0.3]);
        app.watertank=fill(app.UIAxes,watertankx,watertanky,[0 0 0.3]);
        
        % heater plot
        heaterx=[1.2 1.2 1+app.V/2 0.8+app.V 0.8+app.V];
        heatery=[5.2 2 3 2 5.2];  heaterb=line(app.UIAxes,heaterx,heatery,'color',[1 0 0]);
        heaterwidth=app.QkgsecSlider.Value;
        if heaterwidth<0.1;heaterwidth=0.1;end
        set(heaterb,'linewidth',heaterwidth);
        
        text(app.UIAxes,0,5,'T_{in}','fontsize',30)
        text(app.UIAxes,V+2.1,1.2,'T','fontsize',30)

   % Colour for waterin
       red=Tin(end)/30; blue = 0.3+Tin(end)/70;
       if red>1;red=1;end;
       if blue>1;blue=1;end;
       set(waterin,'Facecolor',[red 0 blue]);

   % initial colour for water tank
       red=app.T0/30; blue = 0.3+app.T0/90;
       if red>1;red=1;end;
       if blue>1;blue=1;end;
       set(app.watertank,'Facecolor',[red 0 blue]);

               
    end      %%% END OF TANKOUTLINE SUBFUNCTION

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  Down load data from sliders and create models and responses
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function app = createmodels(app)

            % Assume an initial tank temperature of T0 defined in
            % properties
            % Ensure Tin variables are defined as deviations from this

            % Collect values from sliders and ensure rounded sensibly
            app.Tin=app.TinCSlider.Value;
            app.V=app.Vm3Slider.Value;
            app.Flowin=app.Flowinm3sSlider.Value;
            app.Tindist=app.TinDisturbanceCSlider.Value; 
            app.Flowindist=app.FlowDisturbancem3sSlider.Value; 
            app.Q=app.QkgsecSlider.Value;
            app.runtime=round(app.V/app.Tin,0)*4;
            rho=1000; lambda=2300000; Cp=4200;
            Tin=app.Tin - app.T0 +app.Tindist; % in deviation form
            F=app.Flowin;                      
            Ftotal = app.Flowin+app.Flowindist;

            % model is T dw/dt+w = k1 Tin + k2 Q
            Timeconstant=app.V/(Ftotal);
            k1=1;
            k2=lambda/(rho*Cp*(Ftotal));
            app.G1= tf(k1, [Timeconstant 1]);   
            app.G2= tf(k2, [Timeconstant 1]);
            

            % Define the step responses in deviation form
            app.time=linspace(0,5*Timeconstant,app.samples);
            app.yr = step(app.G1,app.time)*Tin;
            app.yrr= step(app.G2,app.time)*app.Q;
            app.ydd=app.yr+app.yrr + app.T0;
            app.Gsss= dcgain(app.G1)*Tin+dcgain(app.G2)*app.Q;
            app.Gss = k2*app.Q; % used in bottom left plot only
            
        end   % end of create models subfunction


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%  Manage the animation and legends
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
        function app = animationoflineplots(app)

            %%  Set up legend
            if isempty(app.legstring{1});
                nlegstring=0;
            else
                nlegstring = length(app.legstring);
            end
            T=round(app.V/(app.Flowin+app.Flowindist),2);
            app.legstring{nlegstring+1}=['V = ',num2str(app.V),', Tin = ',num2str(app.Tin),...
                ', Flow = ',num2str(app.Flowin), ', Q = ',num2str(app.QkgsecSlider.Value), ...
                ', Tin dist = ',num2str(app.Tindist), ', Flow dist = ',num2str(app.Flowindist)];

            % initialise figure for depth response
            yplot = plot(app.UIAxes2,app.time(1),(app.ydd(1)));
            grid(app.UIAxes2,'on')
            xlabel(app.UIAxes2,'time (sec)')
            hold(app.UIAxes2,'on')
            % xlim(app.UIAxes2,[0,app.runtime*4]);
            kk=legend(app.UIAxes2,app.legstring,'Location','southeast');
            set(kk,'fontsize',8);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% animation of house temperature plot
            % define animation time aspects
            animationsamples = app.animationtime/app.Tsamp; % assume sample time of Tsamp
            updaterate =ceil(app.samples/animationsamples); % no of samples between pauses
            tstart=tic; tsave = tstart;

            for k=1:length(app.time);
                set(yplot,'Xdata',app.time(1:k),'Ydata',app.ydd(1:k));
                
                
               % if app.theta(k)>40;newcolor = [1 0 0];end
               red=app.ydd(k)/30; blue = 0.3+app.ydd(k)/90;
               if red>1;red=1;end;
               if blue>1;blue=1;end;
               set(app.watertank,'FaceColor',[red 0 blue]);   %% Update tank picture


                % Pause animation every updaterate samples only so rem(k,updaterate) 
                % checks for this
                if and(strcmp(app.AnimationOnButton.Text,'Animation On'),not(rem(k,updaterate)));
                    pause(app.Tsamp-toc(tstart));  %% Clumsy application of sampling time
                    tstart = tic;
                    drawnow limitrate
                end
                
            end

        end  % end of animation
% 
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  %%%%%%%%%  Time constant and gain analysis
%  %%%%%%%%%  Done assuming the blockage
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
        function app = timeconstantanalysis(app)

            T=round(app.V/(app.Flowin+app.Flowindist),2);
            grid(app.UIAxes3,'on');
            plot(app.UIAxes3,app.time,app.yrr,'b');
            % xlim(app.UIAxes3,[0,4*T])
            hold(app.UIAxes3,'on') ;
            plot(app.UIAxes3,[T,T],[0,app.Gss],'r-.','linewidth',3)
            plot(app.UIAxes3,[0,4*T],[app.Gss,app.Gss],'g-.','linewidth',3)
            kkk=legend(app.UIAxes3,'Temperature','Time constant','Steady-state');
            set(kkk,'fontsize',10);
            text(app.UIAxes3,4*T/3,app.Gss/3,['\tau = ',num2str(T)],'fontsize', 16);
            text(app.UIAxes3,4*T/3,app.Gss/5,['Steady-state = ',num2str(app.Gss),...
                ' = k Q'],'fontsize', 16);
            xlabel(app.UIAxes3,'time (sec)');

            hold(app.UIAxes3,'off');
        end  % end of timeconstant and gain analysis figure

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Control interaction during the animation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function  disablebuttons(app)
            set(app.SimulateButton, 'Enable', 'off');
            set(app.RefreshButton, 'Enable', 'off');
            set(app.AnimationOnButton, 'Enable', 'off');
            set(app.TinDisturbanceCSlider, 'Enable', 'off');
            set(app.FlowDisturbancem3sSlider, 'Enable', 'off');
            set(app.Vm3Slider, 'Enable', 'off');
            set(app.TinCSlider, 'Enable', 'off');
            set(app.QkgsecSlider, 'Enable', 'off');
            set(app.Flowinm3sSlider, 'Enable', 'off');
            
        end

        function enablebuttons(app)
            set(app.SimulateButton, 'Enable', 'on');
            set(app.RefreshButton, 'Enable', 'on')
            set(app.AnimationOnButton, 'Enable', 'on')
            set(app.TinDisturbanceCSlider, 'Enable', 'on');
            set(app.Flowinm3sSlider, 'Enable', 'on');
            set(app.Vm3Slider, 'Enable', 'on');
            set(app.TinCSlider, 'Enable', 'on');
            set(app.QkgsecSlider, 'Enable', 'on');
            set(app.FlowDisturbancem3sSlider, 'Enable', 'on');
        end


    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
            
            % resize to be in middle of  the window
            movegui(app.UIFigure)
            
            %Open the manual
            if exist('HeatExchanger_manual_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open HeatExchanger_manual.mlx
            else
                p1 = which('HeatExchanger_manual.mlx');
                p2 = strcat(pwd,'/HeatExchanger_manual_mycopy.mlx');
                copyfile(p1,p2)                
                open HeatExchanger_manual_mycopy.mlx
                clear p1 p2
            end

            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);
            app = createmodels(app); % define responses
            app = createtankoutline(app); % define car outline for animation

            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
            theme(app.UIFigure,"light")
            end

        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
            
            disablebuttons(app);

            app = createmodels(app); % define responses
            app = createtankoutline(app); % define HE for animation
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

        % Value changed function: Flowinm3sSlider
        function Flowinm3sSliderValueChanged(app, event)
            value = app.Flowinm3sSlider.Value;
            value = round(value,1);
            if value<0.1;value=0.1;end
            app.Flowinm3sSlider.Value=value;
            app = createtankoutline(app);

            if app.Flowinm3sSlider.Value+app.FlowDisturbancem3sSlider.Value<0.01;  % ensure still some flow
                app.FlowDisturbancem3sSlider.Value = 0.01-app.Flowinm3sSlider.Value;
            end
            

        end

        % Value changed function: Vm3Slider
        function Vm3SliderValueChanged(app, event)
            value = app.Vm3Slider.Value;
            value=round(value,1); 
            if value<1;value=1;end
            app.Vm3Slider.Value=value;
            app = createtankoutline(app);
        end

        % Value changed function: TinCSlider
        function TinCSliderValueChanged(app, event)
            value = app.TinCSlider.Value;
            value=round(value,0);
            app.TinCSlider.Value=value;
            if app.TinDisturbanceCSlider.Value+value<0;
                app.TinDisturbanceCSlider.Value = -app.TinCSlider.Value;
            end
            app = createtankoutline(app);
           
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

        % Value changed function: QkgsecSlider
        function QkgsecSliderValueChanged(app, event)
            value = app.QkgsecSlider.Value;
            value=round(value*2,-1)/2;
            app.QkgsecSlider.Value=value;
            app = createtankoutline(app);
        end

        % Value changed function: TinDisturbanceCSlider
        function TinDisturbanceCSliderValueChanged(app, event)
            value = app.TinDisturbanceCSlider.Value;
            value=round(value,0);
            if app.TinCSlider.Value+value<0;
                value = -app.TinCSlider.Value;
            end
            
            app.TinDisturbanceCSlider.Value=value;
            app = createtankoutline(app);
        end

        % Value changed function: FlowDisturbancem3sSlider
        function FlowDisturbancem3sSliderValueChanged(app, event)
            value = app.FlowDisturbancem3sSlider.Value;
            value=round(value,2);
            if app.Flowinm3sSlider.Value+value<0.01;  % ensure still some flow
                value = 0.01-app.Flowinm3sSlider.Value;
            end
            app.FlowDisturbancem3sSlider.Value=value;
            
            
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
            app.UIFigure.Position = [100 100 1125 869];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '2x'};
            app.GridLayout.RowHeight = {'0.4x', '1.5x', '1x', '2x'};

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Animation of Heat Exchanger')
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
            app.GridLayout2.Layout.Column = 2;
            app.GridLayout2.BackgroundColor = [0.6 1 1];

            % Create stordermodelforHeatExchangerLabel
            app.stordermodelforHeatExchangerLabel = uilabel(app.GridLayout2);
            app.stordermodelforHeatExchangerLabel.BackgroundColor = [0 1 1];
            app.stordermodelforHeatExchangerLabel.HorizontalAlignment = 'center';
            app.stordermodelforHeatExchangerLabel.FontSize = 24;
            app.stordermodelforHeatExchangerLabel.FontWeight = 'bold';
            app.stordermodelforHeatExchangerLabel.Layout.Row = 1;
            app.stordermodelforHeatExchangerLabel.Layout.Column = [1 2];
            app.stordermodelforHeatExchangerLabel.Text = '1st order model for Heat Exchanger';

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
            app.GridLayout4.RowHeight = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout4.Layout.Row = 2;
            app.GridLayout4.Layout.Column = 1;
            app.GridLayout4.BackgroundColor = [0.902 1 0.502];

            % Create InletTTinLabel
            app.InletTTinLabel = uilabel(app.GridLayout4);
            app.InletTTinLabel.HorizontalAlignment = 'right';
            app.InletTTinLabel.FontSize = 14;
            app.InletTTinLabel.Layout.Row = 2;
            app.InletTTinLabel.Layout.Column = 1;
            app.InletTTinLabel.Text = 'Tin (°C)';

            % Create TinCSlider
            app.TinCSlider = uislider(app.GridLayout4);
            app.TinCSlider.Limits = [0 25];
            app.TinCSlider.ValueChangedFcn = createCallbackFcn(app, @TinCSliderValueChanged, true);
            app.TinCSlider.MinorTicks = [500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000];
            app.TinCSlider.FontSize = 14;
            app.TinCSlider.Layout.Row = 2;
            app.TinCSlider.Layout.Column = 2;
            app.TinCSlider.Value = 5;

            % Create VLabel
            app.VLabel = uilabel(app.GridLayout4);
            app.VLabel.HorizontalAlignment = 'right';
            app.VLabel.FontSize = 14;
            app.VLabel.Layout.Row = 3;
            app.VLabel.Layout.Column = 1;
            app.VLabel.Text = 'V (m^3)';

            % Create Vm3Slider
            app.Vm3Slider = uislider(app.GridLayout4);
            app.Vm3Slider.Limits = [0 5];
            app.Vm3Slider.ValueChangedFcn = createCallbackFcn(app, @Vm3SliderValueChanged, true);
            app.Vm3Slider.MinorTicks = [0 100 200 300 400 500 600 700 800 900 1000];
            app.Vm3Slider.FontSize = 14;
            app.Vm3Slider.Layout.Row = 3;
            app.Vm3Slider.Layout.Column = 2;
            app.Vm3Slider.Value = 2;

            % Create VFdtdtTTinCpFQLabel
            app.VFdtdtTTinCpFQLabel = uilabel(app.GridLayout4);
            app.VFdtdtTTinCpFQLabel.BackgroundColor = [1 1 0];
            app.VFdtdtTTinCpFQLabel.HorizontalAlignment = 'center';
            app.VFdtdtTTinCpFQLabel.FontSize = 18;
            app.VFdtdtTTinCpFQLabel.FontWeight = 'bold';
            app.VFdtdtTTinCpFQLabel.Layout.Row = 1;
            app.VFdtdtTTinCpFQLabel.Layout.Column = [1 2];
            app.VFdtdtTTinCpFQLabel.Text = 'V/F (dt/dt) +T = Tin+ (λ/ρCpF) Q';

            % Create Flowinm3sLabel
            app.Flowinm3sLabel = uilabel(app.GridLayout4);
            app.Flowinm3sLabel.HorizontalAlignment = 'right';
            app.Flowinm3sLabel.FontSize = 14;
            app.Flowinm3sLabel.Layout.Row = 4;
            app.Flowinm3sLabel.Layout.Column = 1;
            app.Flowinm3sLabel.Text = 'Flow in (m^3/s)';

            % Create Flowinm3sSlider
            app.Flowinm3sSlider = uislider(app.GridLayout4);
            app.Flowinm3sSlider.Limits = [0 0.4];
            app.Flowinm3sSlider.MajorTicks = [0 0.1 0.2 0.3 0.4];
            app.Flowinm3sSlider.ValueChangedFcn = createCallbackFcn(app, @Flowinm3sSliderValueChanged, true);
            app.Flowinm3sSlider.MinorTicks = [0 10 20 30 40 50];
            app.Flowinm3sSlider.FontSize = 14;
            app.Flowinm3sSlider.Layout.Row = 4;
            app.Flowinm3sSlider.Layout.Column = 2;
            app.Flowinm3sSlider.Value = 0.3;

            % Create SteamFlowRateQLabel
            app.SteamFlowRateQLabel = uilabel(app.GridLayout4);
            app.SteamFlowRateQLabel.HorizontalAlignment = 'right';
            app.SteamFlowRateQLabel.FontSize = 14;
            app.SteamFlowRateQLabel.Layout.Row = 5;
            app.SteamFlowRateQLabel.Layout.Column = 1;
            app.SteamFlowRateQLabel.Text = 'Q (kg/sec)';

            % Create QkgsecSlider
            app.QkgsecSlider = uislider(app.GridLayout4);
            app.QkgsecSlider.Limits = [0 25];
            app.QkgsecSlider.ValueChangedFcn = createCallbackFcn(app, @QkgsecSliderValueChanged, true);
            app.QkgsecSlider.FontSize = 14;
            app.QkgsecSlider.Layout.Row = 5;
            app.QkgsecSlider.Layout.Column = 2;
            app.QkgsecSlider.Value = 5;

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
            ylabel(app.UIAxes3, 'Deviation Temperature (°C)')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.FontSize = 14;
            app.UIAxes3.Layout.Row = 1;
            app.UIAxes3.Layout.Column = 1;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout5);
            title(app.UIAxes2, 'Stored step responses')
            xlabel(app.UIAxes2, 'Time (s)')
            ylabel(app.UIAxes2, 'Temperature (°C)')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 14;
            app.UIAxes2.Layout.Row = 1;
            app.UIAxes2.Layout.Column = 2;

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

            % Create FlowDisturbancem3sSliderLabel
            app.FlowDisturbancem3sSliderLabel = uilabel(app.GridLayout6);
            app.FlowDisturbancem3sSliderLabel.HorizontalAlignment = 'right';
            app.FlowDisturbancem3sSliderLabel.FontSize = 14;
            app.FlowDisturbancem3sSliderLabel.Layout.Row = 3;
            app.FlowDisturbancem3sSliderLabel.Layout.Column = 1;
            app.FlowDisturbancem3sSliderLabel.Text = 'Flow Disturbance (m^3/s)';

            % Create FlowDisturbancem3sSlider
            app.FlowDisturbancem3sSlider = uislider(app.GridLayout6);
            app.FlowDisturbancem3sSlider.Limits = [-0.1 0.1];
            app.FlowDisturbancem3sSlider.ValueChangedFcn = createCallbackFcn(app, @FlowDisturbancem3sSliderValueChanged, true);
            app.FlowDisturbancem3sSlider.Layout.Row = 3;
            app.FlowDisturbancem3sSlider.Layout.Column = 2;

            % Create TinDisturbanceCSliderLabel
            app.TinDisturbanceCSliderLabel = uilabel(app.GridLayout6);
            app.TinDisturbanceCSliderLabel.HorizontalAlignment = 'right';
            app.TinDisturbanceCSliderLabel.FontSize = 14;
            app.TinDisturbanceCSliderLabel.Layout.Row = 2;
            app.TinDisturbanceCSliderLabel.Layout.Column = 1;
            app.TinDisturbanceCSliderLabel.Text = 'Tin Disturbance (°C)';

            % Create TinDisturbanceCSlider
            app.TinDisturbanceCSlider = uislider(app.GridLayout6);
            app.TinDisturbanceCSlider.Limits = [-5 5];
            app.TinDisturbanceCSlider.MajorTicks = [-5 -4 -3 -2 -1 0 1 2 3 4 5];
            app.TinDisturbanceCSlider.ValueChangedFcn = createCallbackFcn(app, @TinDisturbanceCSliderValueChanged, true);
            app.TinDisturbanceCSlider.Layout.Row = 2;
            app.TinDisturbanceCSlider.Layout.Column = 2;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = HeatExchanger

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

