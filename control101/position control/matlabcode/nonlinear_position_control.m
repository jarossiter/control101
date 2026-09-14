classdef nonlinear_position_control < matlab.apps.AppBase
    %NONLINEAR_POSITION_CONTROL
    %   This resource focuses on non-linear behaviour which will arise from
    %   some common non-linear components: 
    %   Input saturation   (inputs always have rate and absolute limits)
    %   Backlash in motors
    %   Measurement delays
    %   
    %   The easiest way to explore this is using this app interface (see
    %   section 3), although the livescript manual (opened automatically)
    %   provides source code that users will find helpful to take more
    %   explicit control of the simulation.
    %   The intention is to expose users to the non-linear components and
    %   their impact on closed-loop behaviour.  
    %   Underlying the virtual laboratory (app file) is a simulink file 
    %   non_linear_Position_system_control101.slx  which users could open
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
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        GridLayout15                  matlab.ui.container.GridLayout
        GridLayout4                   matlab.ui.container.GridLayout
        UnusedbuttonButton            matlab.ui.control.Button
        MeasurementdelayButton        matlab.ui.control.Button
        BacklashButton                matlab.ui.control.Button
        SaturationButton              matlab.ui.control.Button
        SimulationparametersredmeansnotincludedLabel  matlab.ui.control.Label
        GridLayout6                   matlab.ui.container.GridLayout
        RefreshfigureButton           matlab.ui.control.Button
        CreateresponsesButton         matlab.ui.control.Button
        GridLayout5                   matlab.ui.container.GridLayout
        GridLayout14                  matlab.ui.container.GridLayout
        Image4                        matlab.ui.control.Image
        Image                         matlab.ui.control.Image
        ImpactofnonlinearcomponentsonapositioncontrolsystemLabel  matlab.ui.control.Label
        GridLayout3                   matlab.ui.container.GridLayout
        InputratelimitSlider          matlab.ui.control.Slider
        InputratelimitSliderLabel     matlab.ui.control.Label
        InputlimitSlider              matlab.ui.control.Slider
        InputlimitSliderLabel         matlab.ui.control.Label
        BacklashdeadbandSlider        matlab.ui.control.Slider
        BacklashdeadbandSliderLabel   matlab.ui.control.Label
        MeasurementdelaySlider        matlab.ui.control.Slider
        MeasurementdelaySliderLabel   matlab.ui.control.Label
        ModelparametersLabel          matlab.ui.control.Label
        GridLayout2                   matlab.ui.container.GridLayout
        Label                         matlab.ui.control.Label
        SystemGshardwiredincodeLabel  matlab.ui.control.Label
        UIAxes2_4                     matlab.ui.control.UIAxes
        UIAxes2_3                     matlab.ui.control.UIAxes
        UIAxes2                       matlab.ui.control.UIAxes
        UIAxes2_2                     matlab.ui.control.UIAxes
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

        % System parameters
        R=10E3;
        P=60E3;
        C=0.33E-6;
        ks=52.5;
        km=5E-3;
        E=10;
        d=1;
        endtime=1.5;  % Simulation runtime
        
        % Non-linear component definitions
        deadband=0.2;  % Backlash
        backlashonoff  =0; % 0 means off
        umax=50;     % Saturation limits
        umin=-50;
        Dumax  =500;  % rate limit per second
        Dumin=-500;
        saturationonoff = 0;  % 0 means no saturation
        measurementdelay=0.02; % 0 causes warnings from simulink
        measurementonoff = 0; % 0 means no delay


    end
    
    methods (Access = private)
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION FOR BASIC STEP RESPONSES

        function [yy,tt] = determineresponses(app)
            % This function determines all the closed-loop step responses 
            simIn = Simulink.SimulationInput('non_linear_Position_System_control101');
            simIn = simIn.setVariable('R',app.R);
            simIn = simIn.setVariable('P',app.P);
            simIn = simIn.setVariable('C',app.C);
            simIn = simIn.setVariable('ks',app.ks);
            simIn = simIn.setVariable('km',app.km);
            simIn = simIn.setVariable('E',app.E);
            simIn = simIn.setVariable('d',app.d);
            simIn = simIn.setVariable('endtime',app.endtime);
            simIn = simIn.setVariable('deadband',app.deadband);
            simIn = simIn.setVariable('umax',app.umax);
            simIn = simIn.setVariable('umin',app.umin);
            simIn = simIn.setVariable('Dumax',app.Dumax);
            simIn = simIn.setVariable('Dumin',app.Dumin);
            simIn = simIn.setVariable('backlashonoff',app.backlashonoff);
            simIn = simIn.setVariable('saturationonoff',app.saturationonoff);
            simIn = simIn.setVariable('measurementdelay',max([0.01,app.measurementdelay*app.measurementonoff]));
            
                       
            % Simulation - 
            simdata=sim(simIn);
            %keyboard
            tt=simdata.simdata.time;
            yy = simdata.simdata.signals.values; % stored in order as shown in Figure 1.3
           
            
        end  % end of determineresponses
 

    end  %% end of methods
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
           % resize to be in middle of  the window
            movegui(app.UIFigure)
            
            %Open the manual
            if exist('nonlinear_position_system_control101_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open nonlinear_position_system_control101_mycopy.mlx
            else
                p1 = which('nonlinear_position_system_control101_manual.mlx');
                p2 = strcat(pwd,'/nonlinear_position_system_control101_mycopy.mlx');
                copyfile(p1,p2)                
                open nonlinear_position_system_control101_mycopy.mlx
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
           
            % run simulation and collect data
            app.measurementdelay=app.MeasurementdelaySlider.Value*app.measurementonoff;

            [yy,tt] = determineresponses(app);

            % manage the legend for overlays or not
            if isempty(app.legstring{1});
                nlegstring=0;
                hold(app.UIAxes2,'on')
                hold(app.UIAxes2_2,'on')
            else
                nlegstring = length(app.legstring);
            end
            
            app.legstring{nlegstring+1}=['u_{max} = ',num2str(app.umax*app.saturationonoff),...
                ', \delta u_{max}=',num2str(app.Dumax*app.saturationonoff),...
                ', deadband=',num2str(app.deadband*app.backlashonoff),...
                ', delay=',num2str(app.measurementdelay*app.measurementonoff)];
            
                       
           % ploting
           % History plots
           plot(app.UIAxes2,tt,yy(:,6))  % output
           legend(app.UIAxes2,app.legstring,'Location','southeast','FontSize',8)
           plot(app.UIAxes2_2,tt,yy(:,4))  % input

           % current simulation only to show different signals in the loop
           plot(app.UIAxes2_3,tt,yy(:,[1,2,5,6]));
           legend(app.UIAxes2_3,'target','error','output (no backlash)','output (backlash)','Location','southeast','FontSize',8)
           plot(app.UIAxes2_4,tt,yy(:,[3,4]));
           legend(app.UIAxes2_4,'input (desired)','input (saturated)','FontSize',8)

             
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

        % Value changed function: InputlimitSlider
        function InputlimitSliderValueChanged(app, event)
            value = app.InputlimitSlider.Value;
            value=round(value,-1);
            
            app.InputlimitSlider.Value=value;
            app.umax = value;
            app.umin=-value;
        end

        % Button pushed function: SaturationButton
        function SaturationButtonPushed(app, event)
            Value = app.SaturationButton.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.SaturationButton.BackgroundColor = [1 0 0];
                    app.saturationonoff=0; % saturation inactive
            else
                    app.SaturationButton.BackgroundColor = [0.4,0.8,0.1];
                    app.saturationonoff=1; % saturation active
            end

        end

        % Button pushed function: BacklashButton
        function BacklashButtonPushed(app, event)
            Value = app.BacklashButton.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.BacklashButton.BackgroundColor = [1 0 0];
                    app.backlashonoff =0;   % backlash inactive
            else
                    app.BacklashButton.BackgroundColor = [0.4,0.8,0.1];
                    app.backlashonoff =1;   % backlash active
            end
        end

        % Button pushed function: MeasurementdelayButton
        function MeasurementdelayButtonPushed(app, event)
            Value = app.MeasurementdelayButton.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.MeasurementdelayButton.BackgroundColor = [1 0 0];
                    app.measurementonoff=0;  % measurement delay inactive
            else
                    app.MeasurementdelayButton.BackgroundColor = [0.4,0.8,0.1];
                    app.measurementonoff=1;
            end
        end

        % Value changed function: InputratelimitSlider
        function InputratelimitSliderValueChanged(app, event)
            value = app.InputratelimitSlider.Value;
            value=round(value,-2);
            
            app.InputratelimitSlider.Value=value;
            app.Dumax = value;
            app.Dumin=-value;
            
        end

        % Value changed function: BacklashdeadbandSlider
        function BacklashdeadbandSliderValueChanged2(app, event)
            value = app.BacklashdeadbandSlider.Value;
            value=round(value,1);
            
            app.BacklashdeadbandSlider.Value=value;
            app.deadband = value;
           
        end

        % Value changed function: MeasurementdelaySlider
        function MeasurementdelaySliderValueChanged2(app, event)
            value = app.MeasurementdelaySlider.Value;
            if value<0.01; value=0.01;end  %to avoid warnings
            value=round(value,2);
            
            app.MeasurementdelaySlider.Value=value;
            app.measurementdelay = value;
            
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
            app.GridLayout.ColumnWidth = {'1x', '1.5x', '1x'};
            app.GridLayout.RowHeight = {'0.4x', '0.2x', '1.5x', '0.5x', '1x'};

            % Create UIAxes2_2
            app.UIAxes2_2 = uiaxes(app.GridLayout);
            title(app.UIAxes2_2, 'Input response comparisons')
            xlabel(app.UIAxes2_2, 'time (sec)')
            zlabel(app.UIAxes2_2, 'Z')
            app.UIAxes2_2.FontSize = 14;
            app.UIAxes2_2.Layout.Row = [4 5];
            app.UIAxes2_2.Layout.Column = 2;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout);
            title(app.UIAxes2, 'Output response comparisons')
            xlabel(app.UIAxes2, 'time (sec)')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 14;
            app.UIAxes2.Layout.Row = 3;
            app.UIAxes2.Layout.Column = 2;

            % Create UIAxes2_3
            app.UIAxes2_3 = uiaxes(app.GridLayout);
            title(app.UIAxes2_3, 'Current output responses')
            xlabel(app.UIAxes2_3, 'time (sec)')
            zlabel(app.UIAxes2_3, 'Z')
            app.UIAxes2_3.FontSize = 14;
            app.UIAxes2_3.Layout.Row = 3;
            app.UIAxes2_3.Layout.Column = 3;

            % Create UIAxes2_4
            app.UIAxes2_4 = uiaxes(app.GridLayout);
            title(app.UIAxes2_4, 'Current input responses')
            xlabel(app.UIAxes2_4, 'time (sec)')
            zlabel(app.UIAxes2_4, 'Z')
            app.UIAxes2_4.FontSize = 14;
            app.UIAxes2_4.Layout.Row = [4 5];
            app.UIAxes2_4.Layout.Column = 3;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout2.Layout.Row = 4;
            app.GridLayout2.Layout.Column = 1;
            app.GridLayout2.BackgroundColor = [0.902 1 0.502];

            % Create SystemGshardwiredincodeLabel
            app.SystemGshardwiredincodeLabel = uilabel(app.GridLayout2);
            app.SystemGshardwiredincodeLabel.BackgroundColor = [1 1 0];
            app.SystemGshardwiredincodeLabel.HorizontalAlignment = 'center';
            app.SystemGshardwiredincodeLabel.FontSize = 14;
            app.SystemGshardwiredincodeLabel.FontWeight = 'bold';
            app.SystemGshardwiredincodeLabel.Layout.Row = 1;
            app.SystemGshardwiredincodeLabel.Layout.Column = [1 2];
            app.SystemGshardwiredincodeLabel.Text = 'System G(s) hardwired in code';

            % Create Label
            app.Label = uilabel(app.GridLayout2);
            app.Label.WordWrap = 'on';
            app.Label.Layout.Row = 2;
            app.Label.Layout.Column = [1 2];
            app.Label.Text = 'Change source code header to change the parameters of the system - see manual for more information.';

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout);
            app.GridLayout3.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout3.RowHeight = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout3.Layout.Row = 3;
            app.GridLayout3.Layout.Column = 1;
            app.GridLayout3.BackgroundColor = [1 0.8 0.6];

            % Create ModelparametersLabel
            app.ModelparametersLabel = uilabel(app.GridLayout3);
            app.ModelparametersLabel.BackgroundColor = [1 0.502 0.302];
            app.ModelparametersLabel.HorizontalAlignment = 'center';
            app.ModelparametersLabel.FontSize = 14;
            app.ModelparametersLabel.FontWeight = 'bold';
            app.ModelparametersLabel.Layout.Row = 1;
            app.ModelparametersLabel.Layout.Column = [1 2];
            app.ModelparametersLabel.Text = 'Model parameters';

            % Create MeasurementdelaySliderLabel
            app.MeasurementdelaySliderLabel = uilabel(app.GridLayout3);
            app.MeasurementdelaySliderLabel.HorizontalAlignment = 'right';
            app.MeasurementdelaySliderLabel.Layout.Row = 2;
            app.MeasurementdelaySliderLabel.Layout.Column = 1;
            app.MeasurementdelaySliderLabel.Text = 'Measurement delay';

            % Create MeasurementdelaySlider
            app.MeasurementdelaySlider = uislider(app.GridLayout3);
            app.MeasurementdelaySlider.Limits = [0 0.1];
            app.MeasurementdelaySlider.ValueChangedFcn = createCallbackFcn(app, @MeasurementdelaySliderValueChanged2, true);
            app.MeasurementdelaySlider.Layout.Row = 2;
            app.MeasurementdelaySlider.Layout.Column = 2;
            app.MeasurementdelaySlider.Value = 0.02;

            % Create BacklashdeadbandSliderLabel
            app.BacklashdeadbandSliderLabel = uilabel(app.GridLayout3);
            app.BacklashdeadbandSliderLabel.HorizontalAlignment = 'right';
            app.BacklashdeadbandSliderLabel.Layout.Row = 3;
            app.BacklashdeadbandSliderLabel.Layout.Column = 1;
            app.BacklashdeadbandSliderLabel.Text = 'Backlash deadband';

            % Create BacklashdeadbandSlider
            app.BacklashdeadbandSlider = uislider(app.GridLayout3);
            app.BacklashdeadbandSlider.Limits = [0 1];
            app.BacklashdeadbandSlider.ValueChangedFcn = createCallbackFcn(app, @BacklashdeadbandSliderValueChanged2, true);
            app.BacklashdeadbandSlider.Layout.Row = 3;
            app.BacklashdeadbandSlider.Layout.Column = 2;
            app.BacklashdeadbandSlider.Value = 0.2;

            % Create InputlimitSliderLabel
            app.InputlimitSliderLabel = uilabel(app.GridLayout3);
            app.InputlimitSliderLabel.HorizontalAlignment = 'right';
            app.InputlimitSliderLabel.Layout.Row = 4;
            app.InputlimitSliderLabel.Layout.Column = 1;
            app.InputlimitSliderLabel.Text = 'Input limit';

            % Create InputlimitSlider
            app.InputlimitSlider = uislider(app.GridLayout3);
            app.InputlimitSlider.ValueChangedFcn = createCallbackFcn(app, @InputlimitSliderValueChanged, true);
            app.InputlimitSlider.Layout.Row = 4;
            app.InputlimitSlider.Layout.Column = 2;
            app.InputlimitSlider.Value = 50;

            % Create InputratelimitSliderLabel
            app.InputratelimitSliderLabel = uilabel(app.GridLayout3);
            app.InputratelimitSliderLabel.HorizontalAlignment = 'right';
            app.InputratelimitSliderLabel.Layout.Row = 5;
            app.InputratelimitSliderLabel.Layout.Column = 1;
            app.InputratelimitSliderLabel.Text = 'Input rate limit';

            % Create InputratelimitSlider
            app.InputratelimitSlider = uislider(app.GridLayout3);
            app.InputratelimitSlider.Limits = [0 1000];
            app.InputratelimitSlider.ValueChangedFcn = createCallbackFcn(app, @InputratelimitSliderValueChanged, true);
            app.InputratelimitSlider.Layout.Row = 5;
            app.InputratelimitSlider.Layout.Column = 2;
            app.InputratelimitSlider.Value = 500;

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
            app.ImpactofnonlinearcomponentsonapositioncontrolsystemLabel.Text = 'Impact of non linear components on a position control system';

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

            % Create BacklashButton
            app.BacklashButton = uibutton(app.GridLayout4, 'push');
            app.BacklashButton.ButtonPushedFcn = createCallbackFcn(app, @BacklashButtonPushed, true);
            app.BacklashButton.BackgroundColor = [1 0 0];
            app.BacklashButton.FontSize = 14;
            app.BacklashButton.Layout.Row = 2;
            app.BacklashButton.Layout.Column = 2;
            app.BacklashButton.Text = 'Backlash';

            % Create MeasurementdelayButton
            app.MeasurementdelayButton = uibutton(app.GridLayout4, 'push');
            app.MeasurementdelayButton.ButtonPushedFcn = createCallbackFcn(app, @MeasurementdelayButtonPushed, true);
            app.MeasurementdelayButton.WordWrap = 'on';
            app.MeasurementdelayButton.BackgroundColor = [1 0 0];
            app.MeasurementdelayButton.FontSize = 14;
            app.MeasurementdelayButton.Layout.Row = 3;
            app.MeasurementdelayButton.Layout.Column = 1;
            app.MeasurementdelayButton.Text = 'Measurement delay';

            % Create UnusedbuttonButton
            app.UnusedbuttonButton = uibutton(app.GridLayout4, 'push');
            app.UnusedbuttonButton.BackgroundColor = [1 0 0];
            app.UnusedbuttonButton.FontSize = 14;
            app.UnusedbuttonButton.Layout.Row = 3;
            app.UnusedbuttonButton.Layout.Column = 2;
            app.UnusedbuttonButton.Text = 'Unused button';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = nonlinear_position_control

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

