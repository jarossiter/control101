classdef nonlinear_tank_control_control101 < matlab.apps.AppBase
    %NONLINEAR_TANK_CONTROL_CONTROL101
    %   This resource focuses on non-linear behaviour which will arise from
    %   some common non-linear components: 
    %   Input saturation   (inputs always have rate and absolute limits)
    %   Measurement noise
    %   parameterisation errors
    %   Anti-windup in a PID compensator
    %   
    %   The easiest way to explore this is using this app interface (see
    %   section 3), although the livescript manual (opened automatically)
    %   provides source code that users will find helpful to take more
    %   explicit control of the simulation. 
    %   
    %   The intention is to expose users to the non-linear components and
    %   their impact on closed-loop behaviour.   Underlying the virtual
    %   laboratory (app file) is a simulink file 
    %   nonlinear_tank_system_fbk_control101.slx  which users could open
    %   for interest. Take a copy in your own area if you want to edit this
    %   for further study.
    %   
    %   File written by J.A.Rossiter, University of Sheffield
    %        See website for more files like this.
    %       
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   
    %   A group of similar files can be downloaded
    %   through MATLAB add-ons with the toolbox name:  control101

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        GridLayout15                    matlab.ui.container.GridLayout
        GridLayout4                     matlab.ui.container.GridLayout
        BlockageButton                  matlab.ui.control.Button
        AntiwindupButton                matlab.ui.control.Button
        MeasurementnoiseButton          matlab.ui.control.Button
        SaturationButton                matlab.ui.control.Button
        SimulationparametersredmeansnotincludedLabel  matlab.ui.control.Label
        GridLayout6                     matlab.ui.container.GridLayout
        RefreshfigureButton             matlab.ui.control.Button
        CreateresponsesButton           matlab.ui.control.Button
        GridLayout5                     matlab.ui.container.GridLayout
        GridLayout14                    matlab.ui.container.GridLayout
        Image4                          matlab.ui.control.Image
        Image                           matlab.ui.control.Image
        ImpactofnonlinearcomponentsonapositioncontrolsystemLabel  matlab.ui.control.Label
        GridLayout3                     matlab.ui.container.GridLayout
        DisturbanceflowltrsSlider       matlab.ui.control.Slider
        DisturbanceflowltrsSliderLabel  matlab.ui.control.Label
        Inputratelimitltrs2Slider       matlab.ui.control.Slider
        Inputratelimitltrs2SliderLabel  matlab.ui.control.Label
        InputlimitltrsSlider            matlab.ui.control.Slider
        InputlimitltrsSliderLabel       matlab.ui.control.Label
        BlockageSlider                  matlab.ui.control.Slider
        BlockageSliderLabel             matlab.ui.control.Label
        NoisevarianceSlider             matlab.ui.control.Slider
        NoisevarianceSliderLabel        matlab.ui.control.Label
        UncertaintyandnonlinearityLabel  matlab.ui.control.Label
        GridLayout2                     matlab.ui.container.GridLayout
        Label                           matlab.ui.control.Label
        SystemhardwiredincodeLabel      matlab.ui.control.Label
        UIAxes2_2                       matlab.ui.control.UIAxes
        UIAxes2                         matlab.ui.control.UIAxes
        UIAxes2_3                       matlab.ui.control.UIAxes
        UIAxes2_4                       matlab.ui.control.UIAxes
    end

%     File written by J.A.Rossiter, University of Sheffield
%     See website for more files like this.
%     https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
%     A simple interface to compar and contrast different PID auto-tuning algorithms 
%     A group of similar files can be downloaded through MATLAB add-ons
%     with the toolbox name:  control101
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     
    
    % The next section defines all the core variables used in the code and
    % that it may be convenient to have available in the various
    % subfunctions
    properties (Access = private)
        originalsize     % product of width and height for font sizing

        legstring=cell(1); % To store legends
      
        % Simulation parameters which are fixed
        Initial_target = 0.3;
        Targetchange = 0.7;
        Targetchangetime = 60;
        blockagetime=1200; % time that blockage introduced
        endtime=1800;     % simulation run time
        disturbanceflowtime=800;
        disturbanceflow=0.002;
        Noise
        qss   % expected steady-state
        switchpidtime=0;   % With or without anti-windup
       
       
        % use for memory and legends
        Dumax;    % rate limits on input
        Dumin;
        umax;      % absolute limits on the input
        umin;
        Blockage 
        noisevalue
        saturationonoff=0  % keep track of input limits
        noiseonoff=0       % keep track of noise
        modellingonoff=0  % to keep track of blocakages
        switchpid=1;       % no anti windup
        windupstate = 'off'
                
        % Model parameters needed by simulink file
        rho=1000;    % water density
        g=10;        % gravity
        A=2;         % tank area true
        Ai           % inverse of A
        Ae = 2.1;    % estimated tank area 
        R=10^4;      % constant needed to determine outflow
        Re = 10500;  %   estimated R
        C
        Ce
        Ctemp
        Cl
        Kp
        Ki
        

    end
    
    methods (Access = private)
        
 %%%%%%%%   Making interaction impossible until simulation complete
        
        function  disablebuttons(app)
            set(app.DisturbanceflowltrsSlider, 'Enable', 'off');
            set(app.RefreshfigureButton, 'Enable', 'off');
            set(app.InputlimitltrsSlider, 'Enable', 'off');
            set(app.BlockageSlider, 'Enable', 'off');
            set(app.Inputratelimitltrs2Slider, 'Enable', 'off');
            set(app.NoisevarianceSlider, 'Enable', 'off');
            set(app.BlockageButton, 'Enable', 'off');
            set(app.AntiwindupButton, 'Enable', 'off');
            set(app.MeasurementnoiseButton, 'Enable', 'off');
            set(app.SaturationButton, 'Enable', 'off');
            set(app.CreateresponsesButton, 'Enable', 'off');
            
        end

        function enablebuttons(app)
            set(app.DisturbanceflowltrsSlider, 'Enable', 'on');
            set(app.RefreshfigureButton, 'Enable', 'on');
            set(app.InputlimitltrsSlider, 'Enable', 'on');
            set(app.BlockageSlider, 'Enable', 'on');
            set(app.Inputratelimitltrs2Slider, 'Enable', 'on');
            set(app.NoisevarianceSlider, 'Enable', 'on');
            set(app.BlockageButton, 'Enable', 'on');
            set(app.AntiwindupButton, 'Enable', 'on');
            set(app.MeasurementnoiseButton, 'Enable', 'on');
            set(app.SaturationButton, 'Enable', 'on');
            set(app.CreateresponsesButton, 'Enable', 'on');
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION FOR BASIC STEP RESPONSES

        function [yy,uu,tt] = determineresponses(app)
            % This function determines all the closed-loop step responses 
            simIn = Simulink.SimulationInput('non_linear_tank_system_fbk_control101_2023');
            
            simIn = simIn.setVariable('R',app.R);
            simIn = simIn.setVariable('C',app.C);
            simIn = simIn.setVariable('Ctemp',app.Ctemp);
            simIn = simIn.setVariable('qss',app.qss);
            simIn = simIn.setVariable('Ai',1/app.A);
            simIn = simIn.setVariable('Kp',app.Kp);
            simIn = simIn.setVariable('Ki',app.Ki);
            simIn = simIn.setVariable('Initial_target',app.Initial_target);
            simIn = simIn.setVariable('Targetchange',app.Targetchange);
            simIn = simIn.setVariable('Targetchangetime',app.Targetchangetime);
            simIn = simIn.setVariable('blockagetime',app.blockagetime); 
            simIn = simIn.setVariable('disturbanceflowtime',app.disturbanceflowtime);
            simIn = simIn.setVariable('endtime',app.endtime);
            simIn = simIn.setVariable('switchpidtime',app.switchpidtime);
            simIn = simIn.setVariable('switchpid',app.switchpid);
            simIn = simIn.setVariable('disturbanceflow',app.DisturbanceflowltrsSlider.Value/1000);


 
            % Apply saturation or not
            if app.saturationonoff==1;
            simIn = simIn.setVariable('umax',app.InputlimitltrsSlider.Value/1000);
            simIn = simIn.setVariable('umin',0);
            simIn = simIn.setVariable('Dumax',app.Inputratelimitltrs2Slider.Value/1000);
            simIn = simIn.setVariable('Dumin',-app.Inputratelimitltrs2Slider.Value/1000);
            app.umax=app.InputlimitltrsSlider.Value;
            app.Dumax=app.Inputratelimitltrs2Slider.Value;
            else % set values large enough to be irrelevant
            simIn = simIn.setVariable('umax',1);
            simIn = simIn.setVariable('umin',0);
            simIn = simIn.setVariable('Dumax',1);
            simIn = simIn.setVariable('Dumin',-1);
            app.umax=inf;
            app.Dumax=inf;
            end

            % Apply Noise or not
            if app.noiseonoff==0;
                simIn = simIn.setVariable('Noise',app.Noise*0);
                app.noisevalue=0;
            else 
                simIn = simIn.setVariable('Noise',app.Noise);
                app.noisevalue=app.NoisevarianceSlider.Value;
            end

            % Include blockages
            
            if app.modellingonoff==0;
                simIn = simIn.setVariable('blocksize',app.BlockageSlider.Value*0);
                app.Blockage=0;
            else
                simIn = simIn.setVariable('blocksize',app.BlockageSlider.Value);
                app.Blockage = app.BlockageSlider.Value;
            end

            
            % Simulation - 
           
            simdata=sim(simIn);
            tt=simdata.nonlineardata.time;
            yy = simdata.nonlineardata.signals.values; % stored in order simulink file
            uu = simdata.pidoutputs.signals.values; % stored in order as shown in simulink file

            
        end  % end of determineresponses
 

    end  %% end of methods
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
           % resize to be in middle of  the window
            movegui(app.UIFigure)
            
            %Open the manual
            if exist('nonlinear_tank_system_simulink_control101_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open nonlinear_tank_system_simulink_control101_mycopy.mlx
            else
                p1 = which('nonlinear_tank_system_simulink_control101_manual.mlx');
                p2 = strcat(pwd,'/nonlinear_tank_system_simulink_control101_mycopy.mlx');
                copyfile(p1,p2)                
                open nonlinear_tank_system_simulink_control101_mycopy.mlx
                clear p1 p2
            end

     
            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
                theme(app.UIFigure,"light")
            end

        end

        % Button pushed function: CreateresponsesButton
        function CreateresponsesButtonPushed(app, event)
           
           disablebuttons(app);

            % Include blockages
            if app.modellingonoff==0;
               app.Blockage=0;
            else
               app.Blockage = app.BlockageSlider.Value;
            end

            
            % run simulation and collect data
            Noise=[];
            Noise(:,1) = [0:app.endtime]';
            Noise(:,2)=randn(1,app.endtime+1)'*app.NoisevarianceSlider.Value;   
            app.Noise= Noise;
            app.C=sqrt(app.rho*app.g)/app.R;
            app.Ce=sqrt(app.rho*app.g)/app.Re;
            app.Ctemp = app.C*(1-app.Blockage);
            app.qss = app.Ce*sqrt(app.Initial_target);
            app.Cl=app.Ce/(2*sqrt(app.Initial_target));
            app.Kp =app.Cl;
            app.Ki = app.Cl^2/app.A;

            % make sure input limits are viable
            if app.qss>app.InputlimitltrsSlider.Value/1000;
                rrr = round(app.qss*1200,2);
                app.InputlimitltrsSlider.Value=rrr;
                
            end

            [yy,uu,tt] = determineresponses(app);

            % manage the legend for overlays or not
            if isempty(app.legstring{1});
                nlegstring=0;
                hold(app.UIAxes2,'on')
                hold(app.UIAxes2_2,'on')
            else
                nlegstring = length(app.legstring);
            end
            
            app.legstring{nlegstring+1}=['u_{max} = ',num2str(app.umax),...
                ', \delta u_{max}=',num2str(app.Dumax),...
                ', Blockage=',num2str(app.Blockage),...
                ', Noise=',num2str(app.noisevalue),...
                ', Anti-wind up ',app.windupstate,...
                ', dist. = ',num2str(app.DisturbanceflowltrsSlider.Value)];
            
                       
           % ploting
           % History plots
           plot(app.UIAxes2,tt/60,yy(:,5))  % output
           legend(app.UIAxes2,app.legstring,'Location','southeast','FontSize',8)
           plot(app.UIAxes2_2,tt/60,yy(:,3)*1000)  % input

           % current simulation only to show different signals in the loop
           plot(app.UIAxes2_3,tt/60,[yy(:,[1,5,7]),yy(:,4)*app.BlockageSlider.Value]);
           legend(app.UIAxes2_3,'Target','True Depth','Measured depth','Blockage','Location','southwest')
        %   title(app.UIAxes2_3,'Inlet and outlet flow responses')
        %   ylabel(app.UIAxes2_3,'Depth (m)')

          plot(app.UIAxes2_4,tt/60,[yy(:,[2:3,8]),yy(:,3)+yy(:,8)]*1000);
          legend(app.UIAxes2_4,'Desired flow','Actual flow','Disturbance flow','Total flow','Location','southwest')
         %  ylabel(app.UIAxes2_4, 'Flows (m^3 /s)')
         %   xlabel(app.UIAxes2_4, 'Time (min)')
         %   title(app.UIAxes2_4,'Input responses')
          %  ylim(app.UIAxes2_4,[0,0.02])


          enablebuttons(app);
             
        end

        % Button pushed function: RefreshfigureButton
        function RefreshfigureButtonPushed(app, event)
          %  The idea here is to compare the different control laws, but for a single option
          % define the compensators, sensitivities and closed-loop
          % responses and then create the plots

          hold(app.UIAxes2,'off')
          cla(app.UIAxes2)
         
          hold(app.UIAxes2_2,'off')
          cla(app.UIAxes2_2)

          hold(app.UIAxes2_3,'off')
          cla(app.UIAxes2_3)
         
          hold(app.UIAxes2_4,'off')
          cla(app.UIAxes2_4)

          app.legstring=cell(1);
          
             
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

        % Value changed function: InputlimitltrsSlider
        function InputlimitltrsSliderValueChanged(app, event)
            value = app.InputlimitltrsSlider.Value;
            value=round(value,2);
            
            app.InputlimitltrsSlider.Value=value;
            app.umax = value/1000; % change to m^3/s
            app.umin=-value/1000;
        end

        % Button pushed function: SaturationButton
        function SaturationButtonPushed(app, event)
            Value = app.SaturationButton.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.SaturationButton.BackgroundColor = [1 0 0];
                    app.saturationonoff=0; % saturation inactive
                    app.AntiwindupButton.BackgroundColor = [1 0 0];
                    app.switchpid=1;   %no anti-windup
                    app.windupstate = 'off';
            else
                    app.SaturationButton.BackgroundColor = [0.4,0.8,0.1];
                    app.saturationonoff=1; % saturation active
            end

        end

        % Button pushed function: MeasurementnoiseButton
        function MeasurementnoiseButtonPushed(app, event)
            Value = app.MeasurementnoiseButton.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.MeasurementnoiseButton.BackgroundColor = [1 0 0];
                    app.noiseonoff =0;   % backlash inactive
            else
                    app.MeasurementnoiseButton.BackgroundColor = [0.4,0.8,0.1];
                    app.noiseonoff =1;   % backlash active
            end
        end

        % Button pushed function: AntiwindupButton
        function AntiwindupButtonPushed(app, event)
            Value = app.AntiwindupButton.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.AntiwindupButton.BackgroundColor = [1 0 0];
                    app.switchpid=1;   %no anti-windup
                    app.windupstate = 'off';
                    
            else
                    app.AntiwindupButton.BackgroundColor = [0.4,0.8,0.1];
                    app.switchpid=0;   % With anti-windup
                    app.windupstate = 'on';
                    app.SaturationButton.BackgroundColor = [0.4,0.8,0.1];
                    app.saturationonoff=1; % saturation active
            end
        end

        % Value changed function: Inputratelimitltrs2Slider
        function Inputratelimitltrs2SliderValueChanged(app, event)
            value = app.Inputratelimitltrs2Slider.Value;
            value=round(value,2);
            
            app.Inputratelimitltrs2Slider.Value=value;
            app.Dumax = value/1000; % change to m^3/s
            app.Dumin=-value/1000;
            
        end

        % Value changed function: BlockageSlider
        function BlockageSliderValueChanged2(app, event)
            value = app.BlockageSlider.Value;
            value=round(value,1);
            
            app.BlockageSlider.Value=value;
           
           
        end

        % Value changed function: NoisevarianceSlider
        function NoisevarianceSliderValueChanged2(app, event)
            value = app.NoisevarianceSlider.Value;
            if value<0.01; value=0.01;end  %to avoid warnings
            value=round(value,2);
            
            app.NoisevarianceSlider.Value=value;
            
            
        end

        % Button pushed function: BlockageButton
        function BlockageButtonPushed(app, event)
             Value = app.BlockageButton.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.BlockageButton.BackgroundColor = [1 0 0];
                    app.modellingonoff=0;  % no blockage
            else
                    app.BlockageButton.BackgroundColor = [0.4,0.8,0.1];
                    app.modellingonoff=1;
            end
        end

        % Value changed function: DisturbanceflowltrsSlider
        function DisturbanceflowltrsSliderValueChanged(app, event)
            value = app.DisturbanceflowltrsSlider.Value;
            value=round(value,1);
            app.DisturbanceflowltrsSlider.Value=value;
            
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
            app.UIFigure.Position = [100 100 1183 687];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1.5x', '1.2x'};
            app.GridLayout.RowHeight = {'0.4x', '0.2x', '1.8x', '0.5x', '1x'};

            % Create UIAxes2_4
            app.UIAxes2_4 = uiaxes(app.GridLayout);
            title(app.UIAxes2_4, 'Current input flow responses')
            xlabel(app.UIAxes2_4, 'time (min)')
            ylabel(app.UIAxes2_4, 'Flows (ltr/s)')
            zlabel(app.UIAxes2_4, 'Z')
            app.UIAxes2_4.FontSize = 14;
            app.UIAxes2_4.Layout.Row = [4 5];
            app.UIAxes2_4.Layout.Column = 3;

            % Create UIAxes2_3
            app.UIAxes2_3 = uiaxes(app.GridLayout);
            title(app.UIAxes2_3, 'Current depth responses')
            xlabel(app.UIAxes2_3, 'time (min)')
            ylabel(app.UIAxes2_3, 'Depth (m)')
            zlabel(app.UIAxes2_3, 'Z')
            app.UIAxes2_3.FontSize = 14;
            app.UIAxes2_3.Layout.Row = 3;
            app.UIAxes2_3.Layout.Column = 3;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout);
            title(app.UIAxes2, 'Output response comparisons')
            xlabel(app.UIAxes2, 'time (min)')
            ylabel(app.UIAxes2, 'Depth (m)')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 14;
            app.UIAxes2.Layout.Row = 3;
            app.UIAxes2.Layout.Column = 2;

            % Create UIAxes2_2
            app.UIAxes2_2 = uiaxes(app.GridLayout);
            title(app.UIAxes2_2, 'Controllable Input response comparisons')
            xlabel(app.UIAxes2_2, 'time (min)')
            ylabel(app.UIAxes2_2, 'Flow (ltr/s)')
            zlabel(app.UIAxes2_2, 'Z')
            app.UIAxes2_2.FontSize = 14;
            app.UIAxes2_2.Layout.Row = [4 5];
            app.UIAxes2_2.Layout.Column = 2;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout2.Layout.Row = 4;
            app.GridLayout2.Layout.Column = 1;
            app.GridLayout2.BackgroundColor = [0.902 1 0.502];

            % Create SystemhardwiredincodeLabel
            app.SystemhardwiredincodeLabel = uilabel(app.GridLayout2);
            app.SystemhardwiredincodeLabel.BackgroundColor = [1 1 0];
            app.SystemhardwiredincodeLabel.HorizontalAlignment = 'center';
            app.SystemhardwiredincodeLabel.FontSize = 14;
            app.SystemhardwiredincodeLabel.FontWeight = 'bold';
            app.SystemhardwiredincodeLabel.Layout.Row = 1;
            app.SystemhardwiredincodeLabel.Layout.Column = [1 2];
            app.SystemhardwiredincodeLabel.Text = 'System hardwired in code';

            % Create Label
            app.Label = uilabel(app.GridLayout2);
            app.Label.WordWrap = 'on';
            app.Label.Layout.Row = 2;
            app.Label.Layout.Column = [1 2];
            app.Label.Text = 'Change source code header to change the parameters of the system - see manual for more information.';

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout);
            app.GridLayout3.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout3.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout3.Layout.Row = 3;
            app.GridLayout3.Layout.Column = 1;
            app.GridLayout3.BackgroundColor = [1 0.8 0.6];

            % Create UncertaintyandnonlinearityLabel
            app.UncertaintyandnonlinearityLabel = uilabel(app.GridLayout3);
            app.UncertaintyandnonlinearityLabel.BackgroundColor = [1 0.502 0.302];
            app.UncertaintyandnonlinearityLabel.HorizontalAlignment = 'center';
            app.UncertaintyandnonlinearityLabel.FontSize = 14;
            app.UncertaintyandnonlinearityLabel.FontWeight = 'bold';
            app.UncertaintyandnonlinearityLabel.Layout.Row = 1;
            app.UncertaintyandnonlinearityLabel.Layout.Column = [1 2];
            app.UncertaintyandnonlinearityLabel.Text = 'Uncertainty and non linearity';

            % Create NoisevarianceSliderLabel
            app.NoisevarianceSliderLabel = uilabel(app.GridLayout3);
            app.NoisevarianceSliderLabel.HorizontalAlignment = 'right';
            app.NoisevarianceSliderLabel.Layout.Row = 2;
            app.NoisevarianceSliderLabel.Layout.Column = 1;
            app.NoisevarianceSliderLabel.Text = 'Noise variance';

            % Create NoisevarianceSlider
            app.NoisevarianceSlider = uislider(app.GridLayout3);
            app.NoisevarianceSlider.Limits = [0 0.1];
            app.NoisevarianceSlider.ValueChangedFcn = createCallbackFcn(app, @NoisevarianceSliderValueChanged2, true);
            app.NoisevarianceSlider.Layout.Row = 2;
            app.NoisevarianceSlider.Layout.Column = 2;
            app.NoisevarianceSlider.Value = 0.02;

            % Create BlockageSliderLabel
            app.BlockageSliderLabel = uilabel(app.GridLayout3);
            app.BlockageSliderLabel.HorizontalAlignment = 'right';
            app.BlockageSliderLabel.Layout.Row = 3;
            app.BlockageSliderLabel.Layout.Column = 1;
            app.BlockageSliderLabel.Text = 'Blockage';

            % Create BlockageSlider
            app.BlockageSlider = uislider(app.GridLayout3);
            app.BlockageSlider.Limits = [0 0.5];
            app.BlockageSlider.ValueChangedFcn = createCallbackFcn(app, @BlockageSliderValueChanged2, true);
            app.BlockageSlider.Layout.Row = 3;
            app.BlockageSlider.Layout.Column = 2;
            app.BlockageSlider.Value = 0.1;

            % Create InputlimitltrsSliderLabel
            app.InputlimitltrsSliderLabel = uilabel(app.GridLayout3);
            app.InputlimitltrsSliderLabel.HorizontalAlignment = 'right';
            app.InputlimitltrsSliderLabel.Layout.Row = 4;
            app.InputlimitltrsSliderLabel.Layout.Column = 1;
            app.InputlimitltrsSliderLabel.Text = 'Input limit (ltr/s)';

            % Create InputlimitltrsSlider
            app.InputlimitltrsSlider = uislider(app.GridLayout3);
            app.InputlimitltrsSlider.Limits = [0 20];
            app.InputlimitltrsSlider.ValueChangedFcn = createCallbackFcn(app, @InputlimitltrsSliderValueChanged, true);
            app.InputlimitltrsSlider.Layout.Row = 4;
            app.InputlimitltrsSlider.Layout.Column = 2;
            app.InputlimitltrsSlider.Value = 10;

            % Create Inputratelimitltrs2SliderLabel
            app.Inputratelimitltrs2SliderLabel = uilabel(app.GridLayout3);
            app.Inputratelimitltrs2SliderLabel.HorizontalAlignment = 'right';
            app.Inputratelimitltrs2SliderLabel.Layout.Row = 5;
            app.Inputratelimitltrs2SliderLabel.Layout.Column = 1;
            app.Inputratelimitltrs2SliderLabel.Text = 'Input rate limit (ltr/s^2)';

            % Create Inputratelimitltrs2Slider
            app.Inputratelimitltrs2Slider = uislider(app.GridLayout3);
            app.Inputratelimitltrs2Slider.Limits = [0 0.2];
            app.Inputratelimitltrs2Slider.ValueChangedFcn = createCallbackFcn(app, @Inputratelimitltrs2SliderValueChanged, true);
            app.Inputratelimitltrs2Slider.Layout.Row = 5;
            app.Inputratelimitltrs2Slider.Layout.Column = 2;
            app.Inputratelimitltrs2Slider.Value = 0.1;

            % Create DisturbanceflowltrsSliderLabel
            app.DisturbanceflowltrsSliderLabel = uilabel(app.GridLayout3);
            app.DisturbanceflowltrsSliderLabel.HorizontalAlignment = 'right';
            app.DisturbanceflowltrsSliderLabel.Layout.Row = 6;
            app.DisturbanceflowltrsSliderLabel.Layout.Column = 1;
            app.DisturbanceflowltrsSliderLabel.Text = 'Disturbance flow (ltr/s)';

            % Create DisturbanceflowltrsSlider
            app.DisturbanceflowltrsSlider = uislider(app.GridLayout3);
            app.DisturbanceflowltrsSlider.Limits = [0 4];
            app.DisturbanceflowltrsSlider.ValueChangedFcn = createCallbackFcn(app, @DisturbanceflowltrsSliderValueChanged, true);
            app.DisturbanceflowltrsSlider.Layout.Row = 6;
            app.DisturbanceflowltrsSlider.Layout.Column = 2;
            app.DisturbanceflowltrsSlider.Value = 2;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout);
            app.GridLayout5.ColumnWidth = {'1.4x', '1x'};
            app.GridLayout5.RowHeight = {'1x'};
            app.GridLayout5.Layout.Row = [1 2];
            app.GridLayout5.Layout.Column = [2 3];
            app.GridLayout5.BackgroundColor = [0.6 1 1];

            % Create ImpactofnonlinearcomponentsonapositioncontrolsystemLabel
            app.ImpactofnonlinearcomponentsonapositioncontrolsystemLabel = uilabel(app.GridLayout5);
            app.ImpactofnonlinearcomponentsonapositioncontrolsystemLabel.BackgroundColor = [0 1 1];
            app.ImpactofnonlinearcomponentsonapositioncontrolsystemLabel.HorizontalAlignment = 'center';
            app.ImpactofnonlinearcomponentsonapositioncontrolsystemLabel.WordWrap = 'on';
            app.ImpactofnonlinearcomponentsonapositioncontrolsystemLabel.FontSize = 24;
            app.ImpactofnonlinearcomponentsonapositioncontrolsystemLabel.FontWeight = 'bold';
            app.ImpactofnonlinearcomponentsonapositioncontrolsystemLabel.Layout.Row = 1;
            app.ImpactofnonlinearcomponentsonapositioncontrolsystemLabel.Layout.Column = 1;
            app.ImpactofnonlinearcomponentsonapositioncontrolsystemLabel.Text = 'Impact of non linear components on control and behaviour of a single tank';

            % Create GridLayout14
            app.GridLayout14 = uigridlayout(app.GridLayout5);
            app.GridLayout14.RowHeight = {'1x'};
            app.GridLayout14.Layout.Row = 1;
            app.GridLayout14.Layout.Column = 2;

            % Create Image
            app.Image = uiimage(app.GridLayout14);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 1;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'UoSlogo.png');

            % Create Image4
            app.Image4 = uiimage(app.GridLayout14);
            app.Image4.Layout.Row = 1;
            app.Image4.Layout.Column = 2;
            app.Image4.ImageSource = fullfile(pathToMLAPP, 'Logo-UNED.png');

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.RowHeight = {'1x'};
            app.GridLayout6.Layout.Row = [1 2];
            app.GridLayout6.Layout.Column = 1;
            app.GridLayout6.BackgroundColor = [1 0.6 0.8];

            % Create CreateresponsesButton
            app.CreateresponsesButton = uibutton(app.GridLayout6, 'push');
            app.CreateresponsesButton.ButtonPushedFcn = createCallbackFcn(app, @CreateresponsesButtonPushed, true);
            app.CreateresponsesButton.WordWrap = 'on';
            app.CreateresponsesButton.BackgroundColor = [1 0.2 0.702];
            app.CreateresponsesButton.FontSize = 18;
            app.CreateresponsesButton.FontWeight = 'bold';
            app.CreateresponsesButton.Layout.Row = 1;
            app.CreateresponsesButton.Layout.Column = 1;
            app.CreateresponsesButton.Text = 'Create responses';

            % Create RefreshfigureButton
            app.RefreshfigureButton = uibutton(app.GridLayout6, 'push');
            app.RefreshfigureButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshfigureButtonPushed, true);
            app.RefreshfigureButton.WordWrap = 'on';
            app.RefreshfigureButton.BackgroundColor = [1 0.2 0.702];
            app.RefreshfigureButton.FontSize = 18;
            app.RefreshfigureButton.FontWeight = 'bold';
            app.RefreshfigureButton.Layout.Row = 1;
            app.RefreshfigureButton.Layout.Column = 2;
            app.RefreshfigureButton.Text = 'Refresh figure';

            % Create GridLayout15
            app.GridLayout15 = uigridlayout(app.GridLayout);
            app.GridLayout15.ColumnWidth = {'2x'};
            app.GridLayout15.RowHeight = {'1x'};
            app.GridLayout15.Layout.Row = 5;
            app.GridLayout15.Layout.Column = 1;

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout15);
            app.GridLayout4.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout4.Layout.Row = 1;
            app.GridLayout4.Layout.Column = 1;
            app.GridLayout4.BackgroundColor = [0.702 1 0.702];

            % Create SimulationparametersredmeansnotincludedLabel
            app.SimulationparametersredmeansnotincludedLabel = uilabel(app.GridLayout4);
            app.SimulationparametersredmeansnotincludedLabel.BackgroundColor = [0 1 0];
            app.SimulationparametersredmeansnotincludedLabel.HorizontalAlignment = 'center';
            app.SimulationparametersredmeansnotincludedLabel.WordWrap = 'on';
            app.SimulationparametersredmeansnotincludedLabel.FontSize = 14;
            app.SimulationparametersredmeansnotincludedLabel.FontWeight = 'bold';
            app.SimulationparametersredmeansnotincludedLabel.Layout.Row = 1;
            app.SimulationparametersredmeansnotincludedLabel.Layout.Column = [1 2];
            app.SimulationparametersredmeansnotincludedLabel.Text = 'Simulation parameters (red means not included)';

            % Create SaturationButton
            app.SaturationButton = uibutton(app.GridLayout4, 'push');
            app.SaturationButton.ButtonPushedFcn = createCallbackFcn(app, @SaturationButtonPushed, true);
            app.SaturationButton.BackgroundColor = [1 0 0];
            app.SaturationButton.FontSize = 14;
            app.SaturationButton.Layout.Row = 2;
            app.SaturationButton.Layout.Column = 1;
            app.SaturationButton.Text = 'Saturation';

            % Create MeasurementnoiseButton
            app.MeasurementnoiseButton = uibutton(app.GridLayout4, 'push');
            app.MeasurementnoiseButton.ButtonPushedFcn = createCallbackFcn(app, @MeasurementnoiseButtonPushed, true);
            app.MeasurementnoiseButton.WordWrap = 'on';
            app.MeasurementnoiseButton.BackgroundColor = [1 0 0];
            app.MeasurementnoiseButton.FontSize = 14;
            app.MeasurementnoiseButton.Layout.Row = 2;
            app.MeasurementnoiseButton.Layout.Column = 2;
            app.MeasurementnoiseButton.Text = 'Measurement noise';

            % Create AntiwindupButton
            app.AntiwindupButton = uibutton(app.GridLayout4, 'push');
            app.AntiwindupButton.ButtonPushedFcn = createCallbackFcn(app, @AntiwindupButtonPushed, true);
            app.AntiwindupButton.WordWrap = 'on';
            app.AntiwindupButton.BackgroundColor = [1 0 0];
            app.AntiwindupButton.FontSize = 14;
            app.AntiwindupButton.Layout.Row = 3;
            app.AntiwindupButton.Layout.Column = 1;
            app.AntiwindupButton.Text = 'Anti-windup';

            % Create BlockageButton
            app.BlockageButton = uibutton(app.GridLayout4, 'push');
            app.BlockageButton.ButtonPushedFcn = createCallbackFcn(app, @BlockageButtonPushed, true);
            app.BlockageButton.WordWrap = 'on';
            app.BlockageButton.BackgroundColor = [1 0 0];
            app.BlockageButton.FontSize = 14;
            app.BlockageButton.Layout.Row = 3;
            app.BlockageButton.Layout.Column = 2;
            app.BlockageButton.Text = 'Blockage';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = nonlinear_tank_control_control101

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

