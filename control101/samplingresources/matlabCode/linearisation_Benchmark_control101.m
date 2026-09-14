classdef linearisation_Benchmark_control101 < matlab.apps.AppBase
    %LINEARISATION_BENCHMARK_CONTROL101
    %   This virtual laboratory allows users to investigate linearisation
    %   based on two 4th order models of non-linear mechatronic systems.
    %   Linearisation is done around a user specified operating point and
    %   behaviour is compared with the full nonlinear system.
    %   
    %   More detailed information is in the supporting livescript
    %   linearisation_Benchmark_control101_manual.mlx

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        GridLayout8                   matlab.ui.container.GridLayout
        UIAxes3                       matlab.ui.control.UIAxes
        UIAxes                        matlab.ui.control.UIAxes
        GridLayout5                   matlab.ui.container.GridLayout
        DeletehistoryButton           matlab.ui.control.Button
        SimulateButton                matlab.ui.control.Button
        GridLayout4                   matlab.ui.container.GridLayout
        Image4                        matlab.ui.control.Image
        Image3                        matlab.ui.control.Image
        PlantlinearisationapplicationLabel  matlab.ui.control.Label
        GridLayout2                   matlab.ui.container.GridLayout
        GridLayout7                   matlab.ui.container.GridLayout
        SignaltypeDropDown            matlab.ui.control.DropDown
        SignaltypeDropDownLabel       matlab.ui.control.Label
        BiasVSlider                   matlab.ui.control.Slider
        BiasVSliderLabel              matlab.ui.control.Label
        FundamentalfrequencyHzSlider  matlab.ui.control.Slider
        FundamentalfrequencyHzSliderLabel  matlab.ui.control.Label
        AmplitudeVSlider              matlab.ui.control.Slider
        AmplitudeVSliderLabel         matlab.ui.control.Label
        StimuliconfigurationLabel     matlab.ui.control.Label
        GridLayout6                   matlab.ui.container.GridLayout
        ComponentspeedrpmSlider       matlab.ui.control.Slider
        ComponentspeedrpmSliderLabel  matlab.ui.control.Label
        ComponentangledegreesSlider   matlab.ui.control.Slider
        ComponentangledegreesSliderLabel  matlab.ui.control.Label
        MotorspeedrpmSlider           matlab.ui.control.Slider
        MotorspeedrpmSliderLabel      matlab.ui.control.Label
        MotorcurrentASlider           matlab.ui.control.Slider
        MotorcurrentASliderLabel      matlab.ui.control.Label
        LinearisationandtrimconfigurationsLabel  matlab.ui.control.Label
        GridLayout3                   matlab.ui.container.GridLayout
        SimulationtimesSlider         matlab.ui.control.Slider
        SimulationtimesSliderLabel    matlab.ui.control.Label
        SamplingtimemsSlider          matlab.ui.control.Slider
        SamplingtimemsSliderLabel     matlab.ui.control.Label
        SelectedplantDropDown         matlab.ui.control.DropDown
        SelectedplantDropDownLabel    matlab.ui.control.Label
        Image2                        matlab.ui.control.Image
        Image                         matlab.ui.control.Image
        SimulationpanelLabel          matlab.ui.control.Label
        UIAxes2                       matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        originalsize % Description
        Experimenttext=cell(1)
        experimentCounter = 0
    end
    
    methods (Access = private)
        
        
        function  disablebuttons(app)
            set(app.SignaltypeDropDown, 'Enable', 'off');
            set(app.BiasVSlider, 'Enable', 'off');
            set(app.FundamentalfrequencyHzSlider, 'Enable', 'off');
            set(app.AmplitudeVSlider, 'Enable', 'off');
            set(app.ComponentangledegreesSlider, 'Enable', 'off');
            set(app.ComponentspeedrpmSlider, 'Enable', 'off');
            set(app.MotorcurrentASlider, 'Enable', 'off');
            set(app.MotorspeedrpmSlider, 'Enable', 'off');
            set(app.SimulationtimesSlider, 'Enable', 'off');
            set(app.SamplingtimemsSlider, 'Enable', 'off');
            set(app.SelectedplantDropDown, 'Enable', 'off');
            set(app.SimulateButton, 'Enable', 'off');
        end
        
        function enablebuttons(app)
            set(app.SignaltypeDropDown, 'Enable', 'on');
            set(app.BiasVSlider, 'Enable', 'on');
            set(app.FundamentalfrequencyHzSlider, 'Enable', 'on');
            set(app.AmplitudeVSlider, 'Enable', 'on');
            set(app.ComponentangledegreesSlider, 'Enable', 'on');
            set(app.ComponentspeedrpmSlider, 'Enable', 'on');
            set(app.MotorcurrentASlider, 'Enable', 'on');
            set(app.MotorspeedrpmSlider, 'Enable', 'on');
            set(app.SimulationtimesSlider, 'Enable', 'on');
            set(app.SamplingtimemsSlider, 'Enable', 'on');
            set(app.SelectedplantDropDown, 'Enable', 'on');
            set(app.SimulateButton, 'Enable', 'on');

        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            %app.UIFigure.AutoResizeChildren='off';   
            movegui(app.UIFigure)
            
            % Open the manual
            if exist('linearisation_Benchmark_control101_manual_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open linearisation_Benchmark_control101_manual_mycopy.mlx
            else
                p1 = which('linearisation_Benchmark_control101_manual.mlx');
                p2 = strcat(pwd,'/linearisation_Benchmark_control101_manual_mycopy.mlx');
                copyfile(p1,p2)                
                open linearisation_Benchmark_control101_manual_mycopy.mlx
                clear p1 p2
            end

            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);
          

            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
                theme(app.UIFigure,"light")
            end
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

        % Button pushed function: DeletehistoryButton
        function DeletehistoryButtonPushed(app, event)
            app.Experimenttext = [];
            cla(app.UIAxes2);
            cla(app.UIAxes);
            cla(app.UIAxes3);
            app.experimentCounter = 0;
        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
            disablebuttons(app)
            
            
                value = app.SignaltypeDropDown.Value;
                amplitude = app.AmplitudeVSlider.Value;
                frequency = app.FundamentalfrequencyHzSlider.Value;
                bias = app.BiasVSlider.Value;
    
                % reminder that sampling time is in ms
                steps = 1000*app.SimulationtimesSlider.Value/app.SamplingtimemsSlider.Value;
                time = linspace(0,app.SimulationtimesSlider.Value,steps+1);
                step_value = time(2)-time(1);
                
    
                control_input = 0;
                sim_output = [];

                switch value    % Ensure always greater than zero
                    case "Sine"
                    control_input = (amplitude/2) * sin( 2 * pi * frequency * time ) + ...
                        amplitude/2+bias;
                    case "Pulse"
                    control_input = amplitude * square( 2 * pi * frequency * time )  + bias;
                    case "Sawtooth" 
                    control_input = (amplitude/2) * sawtooth( 2 * pi * frequency * time ) + ...
                        +amplitude/2 + bias;
                end

                % Define the operating point
                x0 = [ app.MotorcurrentASlider.Value; app.MotorspeedrpmSlider.Value*2*pi/60; ...
                    app.ComponentspeedrpmSlider.Value*2*pi/60; deg2rad(app.ComponentangledegreesSlider.Value)];  % Example operating point for x

                switch app.SelectedplantDropDown.Value
                    case "Fan & Plate"          
                   % Parameter set and linear model
                   FanAndPlate_Data_control101;  % defines parameter values
                   sys=FanAndPlate_model_control101(x0);     
                   simIn = Simulink.SimulationInput('FanAndPlate_control101.slx');
                    
                    case "QNET VTOL"

                    % Parameter set and linear model
                    OneDofAeroVTOL_Data_control101; % defines parameter values
                    sys=OneDofAeroVTOL_model_control101(x0);
                    simIn = Simulink.SimulationInput('OneDofAeroVTOL_control101.slx');
                end
                      
                % Set up values and simulate
                    simIn = simIn.setVariable('Stoptime',app.SimulationtimesSlider.Value);
                    simIn = simIn.setVariable('SampleTime',step_value);
                    simIn = simIn.setVariable('initialcurrent',app.MotorcurrentASlider.Value);
                    simIn = simIn.setVariable('fanspeed',app.MotorspeedrpmSlider.Value*2*pi/60);
                    simIn = simIn.setVariable('initialplatespeed',app.ComponentspeedrpmSlider.Value*2*pi/60);
                    simIn = simIn.setVariable('initialplateangle',app.ComponentangledegreesSlider.Value*2*pi/360);
                    simIn = simIn.setVariable('input_data_gl',[time', control_input']);
                    nl_output = sim(simIn);
                    nl_output.continuous_output.signals.values = rad2deg(nl_output.continuous_output.signals.values);
                   

                % linear model simulation
                sim_output = lsim(sys,control_input,time,x0);
                sim_output = rad2deg(sim_output);


                % Save data
                app.experimentCounter = app.experimentCounter + 1;
                app.Experimenttext{app.experimentCounter} = ['Experiment ',num2str(app.experimentCounter)];
              
                % set default to keep history
                hold(app.UIAxes2, "on");
                hold(app.UIAxes, "on");

                % input plot
                b=plot(app.UIAxes, time, control_input);
                grid(app.UIAxes, "on");
                grid(app.UIAxes, "minor");
                                
                % overlay linear and non-linear
                a=stairs(app.UIAxes3, time, sim_output,'--','Color',b.Color);
                hold(app.UIAxes3, "on");
                plot(app.UIAxes3,nl_output.continuous_output.time,...
                     nl_output.continuous_output.signals.values,...
                     'Color',b.Color)
                legend(app.UIAxes3,'Linearised model','Non-linear model')
                hold(app.UIAxes3, "off")
                
                % Plot non-linear responses with history
                plot(app.UIAxes2,nl_output.continuous_output.time,...
                     nl_output.continuous_output.signals.values,...
                     'Color',b.Color);
                grid(app.UIAxes2, "on");
                grid(app.UIAxes2, "minor");
                legend(app.UIAxes2,app.Experimenttext);

     
                enablebuttons(app);
        end

        % Value changed function: MotorcurrentASlider
        function MotorcurrentASliderValueChanged(app, event)
            value = app.MotorcurrentASlider.Value;
            if value==0;
                app.MotorcurrentASlider.Value=0;
            end
        end

        % Value changed function: MotorspeedrpmSlider
        function MotorspeedrpmSliderValueChanged(app, event)
            value = app.MotorspeedrpmSlider.Value;
            value = app.MotorspeedrpmSlider.Value;
            if value==0;
                app.MotorspeedrpmSlider.Value=100;
            end
        end

        % Value changed function: ComponentspeedrpmSlider
        function ComponentspeedrpmSliderValueChanged(app, event)
            value = app.ComponentspeedrpmSlider.Value;
            value = app.ComponentspeedrpmSlider.Value;
            if value==0;
                app.ComponentspeedrpmSlider.Value=0;
            end
        end

        % Value changed function: AmplitudeVSlider
        function AmplitudeVSliderValueChanged(app, event)
            value = app.AmplitudeVSlider.Value;
             value = app.AmplitudeVSlider.Value;
            if value==0;
                app.AmplitudeVSlider.Value=1;
            end
        end

        % Value changed function: FundamentalfrequencyHzSlider
        function FundamentalfrequencyHzSliderValueChanged(app, event)
            value = app.FundamentalfrequencyHzSlider.Value;
            value = app.FundamentalfrequencyHzSlider.Value;
            if value==0;
                app.FundamentalfrequencyHzSlider.Value=0.1;
            end
        end

        % Value changed function: SamplingtimemsSlider
        function SamplingtimemsSliderValueChanged(app, event)
            value = app.SamplingtimemsSlider.Value;
            value = app.SamplingtimemsSlider.Value;
              if value==0; app.SamplingtimemsSlider.Value=5;end
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
            app.UIFigure.Position = [100 100 1292 925];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1.5x'};
            app.GridLayout.RowHeight = {'0.25x', '1x', '1x'};

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout);
            title(app.UIAxes2, 'Output signal')
            xlabel(app.UIAxes2, 'time (sec)')
            ylabel(app.UIAxes2, 'Position')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 18;
            app.UIAxes2.Layout.Row = 3;
            app.UIAxes2.Layout.Column = 2;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x'};
            app.GridLayout2.RowHeight = {'1.15x', '1x', '1x'};
            app.GridLayout2.Layout.Row = [2 3];
            app.GridLayout2.Layout.Column = 1;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout2);
            app.GridLayout3.RowHeight = {'1x', '0.8x', '2x', '1x', '1x'};
            app.GridLayout3.Layout.Row = 1;
            app.GridLayout3.Layout.Column = 1;
            app.GridLayout3.BackgroundColor = [0.902 1 0.502];

            % Create SimulationpanelLabel
            app.SimulationpanelLabel = uilabel(app.GridLayout3);
            app.SimulationpanelLabel.BackgroundColor = [1 1 0];
            app.SimulationpanelLabel.HorizontalAlignment = 'center';
            app.SimulationpanelLabel.FontSize = 24;
            app.SimulationpanelLabel.FontWeight = 'bold';
            app.SimulationpanelLabel.Layout.Row = 1;
            app.SimulationpanelLabel.Layout.Column = [1 2];
            app.SimulationpanelLabel.Text = 'Simulation panel';

            % Create Image
            app.Image = uiimage(app.GridLayout3);
            app.Image.Layout.Row = 3;
            app.Image.Layout.Column = 1;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'images', 'FanandPlate_small_size.jpg');

            % Create Image2
            app.Image2 = uiimage(app.GridLayout3);
            app.Image2.Layout.Row = 3;
            app.Image2.Layout.Column = 2;
            app.Image2.ImageSource = fullfile(pathToMLAPP, 'images', 'QNET-VTOL-Board.jpg');

            % Create SelectedplantDropDownLabel
            app.SelectedplantDropDownLabel = uilabel(app.GridLayout3);
            app.SelectedplantDropDownLabel.HorizontalAlignment = 'right';
            app.SelectedplantDropDownLabel.FontSize = 18;
            app.SelectedplantDropDownLabel.Layout.Row = 2;
            app.SelectedplantDropDownLabel.Layout.Column = 1;
            app.SelectedplantDropDownLabel.Text = 'Selected plant';

            % Create SelectedplantDropDown
            app.SelectedplantDropDown = uidropdown(app.GridLayout3);
            app.SelectedplantDropDown.Items = {'Fan & Plate', 'QNET VTOL'};
            app.SelectedplantDropDown.FontSize = 18;
            app.SelectedplantDropDown.Layout.Row = 2;
            app.SelectedplantDropDown.Layout.Column = 2;
            app.SelectedplantDropDown.Value = 'Fan & Plate';

            % Create SamplingtimemsSliderLabel
            app.SamplingtimemsSliderLabel = uilabel(app.GridLayout3);
            app.SamplingtimemsSliderLabel.HorizontalAlignment = 'right';
            app.SamplingtimemsSliderLabel.FontSize = 14;
            app.SamplingtimemsSliderLabel.Layout.Row = 4;
            app.SamplingtimemsSliderLabel.Layout.Column = 1;
            app.SamplingtimemsSliderLabel.Text = 'Sampling time (ms)';

            % Create SamplingtimemsSlider
            app.SamplingtimemsSlider = uislider(app.GridLayout3);
            app.SamplingtimemsSlider.ValueChangedFcn = createCallbackFcn(app, @SamplingtimemsSliderValueChanged, true);
            app.SamplingtimemsSlider.FontSize = 14;
            app.SamplingtimemsSlider.Layout.Row = 4;
            app.SamplingtimemsSlider.Layout.Column = 2;
            app.SamplingtimemsSlider.Value = 10;

            % Create SimulationtimesSliderLabel
            app.SimulationtimesSliderLabel = uilabel(app.GridLayout3);
            app.SimulationtimesSliderLabel.HorizontalAlignment = 'right';
            app.SimulationtimesSliderLabel.FontSize = 14;
            app.SimulationtimesSliderLabel.Layout.Row = 5;
            app.SimulationtimesSliderLabel.Layout.Column = 1;
            app.SimulationtimesSliderLabel.Text = 'Simulation time (s)';

            % Create SimulationtimesSlider
            app.SimulationtimesSlider = uislider(app.GridLayout3);
            app.SimulationtimesSlider.Limits = [5 20];
            app.SimulationtimesSlider.FontSize = 14;
            app.SimulationtimesSlider.Layout.Row = 5;
            app.SimulationtimesSlider.Layout.Column = 2;
            app.SimulationtimesSlider.Value = 10;

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout2);
            app.GridLayout6.RowHeight = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout6.Layout.Row = 2;
            app.GridLayout6.Layout.Column = 1;
            app.GridLayout6.BackgroundColor = [1 0.8 0.6];

            % Create LinearisationandtrimconfigurationsLabel
            app.LinearisationandtrimconfigurationsLabel = uilabel(app.GridLayout6);
            app.LinearisationandtrimconfigurationsLabel.BackgroundColor = [1 0.502 0.302];
            app.LinearisationandtrimconfigurationsLabel.HorizontalAlignment = 'center';
            app.LinearisationandtrimconfigurationsLabel.FontSize = 24;
            app.LinearisationandtrimconfigurationsLabel.FontWeight = 'bold';
            app.LinearisationandtrimconfigurationsLabel.Layout.Row = 1;
            app.LinearisationandtrimconfigurationsLabel.Layout.Column = [1 2];
            app.LinearisationandtrimconfigurationsLabel.Text = 'Linearisation and trim configurations';

            % Create MotorcurrentASliderLabel
            app.MotorcurrentASliderLabel = uilabel(app.GridLayout6);
            app.MotorcurrentASliderLabel.HorizontalAlignment = 'right';
            app.MotorcurrentASliderLabel.FontSize = 14;
            app.MotorcurrentASliderLabel.Layout.Row = 2;
            app.MotorcurrentASliderLabel.Layout.Column = 1;
            app.MotorcurrentASliderLabel.Text = 'Motor current (A)';

            % Create MotorcurrentASlider
            app.MotorcurrentASlider = uislider(app.GridLayout6);
            app.MotorcurrentASlider.Limits = [0 2];
            app.MotorcurrentASlider.ValueChangedFcn = createCallbackFcn(app, @MotorcurrentASliderValueChanged, true);
            app.MotorcurrentASlider.FontSize = 14;
            app.MotorcurrentASlider.Layout.Row = 2;
            app.MotorcurrentASlider.Layout.Column = 2;

            % Create MotorspeedrpmSliderLabel
            app.MotorspeedrpmSliderLabel = uilabel(app.GridLayout6);
            app.MotorspeedrpmSliderLabel.HorizontalAlignment = 'right';
            app.MotorspeedrpmSliderLabel.FontSize = 14;
            app.MotorspeedrpmSliderLabel.Layout.Row = 3;
            app.MotorspeedrpmSliderLabel.Layout.Column = 1;
            app.MotorspeedrpmSliderLabel.Text = 'Motor speed (rpm)';

            % Create MotorspeedrpmSlider
            app.MotorspeedrpmSlider = uislider(app.GridLayout6);
            app.MotorspeedrpmSlider.Limits = [0 1000];
            app.MotorspeedrpmSlider.ValueChangedFcn = createCallbackFcn(app, @MotorspeedrpmSliderValueChanged, true);
            app.MotorspeedrpmSlider.FontSize = 14;
            app.MotorspeedrpmSlider.Layout.Row = 3;
            app.MotorspeedrpmSlider.Layout.Column = 2;
            app.MotorspeedrpmSlider.Value = 500;

            % Create ComponentangledegreesSliderLabel
            app.ComponentangledegreesSliderLabel = uilabel(app.GridLayout6);
            app.ComponentangledegreesSliderLabel.HorizontalAlignment = 'right';
            app.ComponentangledegreesSliderLabel.FontSize = 14;
            app.ComponentangledegreesSliderLabel.Layout.Row = 4;
            app.ComponentangledegreesSliderLabel.Layout.Column = 1;
            app.ComponentangledegreesSliderLabel.Text = 'Component angle (degrees)';

            % Create ComponentangledegreesSlider
            app.ComponentangledegreesSlider = uislider(app.GridLayout6);
            app.ComponentangledegreesSlider.FontSize = 14;
            app.ComponentangledegreesSlider.Layout.Row = 4;
            app.ComponentangledegreesSlider.Layout.Column = 2;

            % Create ComponentspeedrpmSliderLabel
            app.ComponentspeedrpmSliderLabel = uilabel(app.GridLayout6);
            app.ComponentspeedrpmSliderLabel.HorizontalAlignment = 'right';
            app.ComponentspeedrpmSliderLabel.FontSize = 14;
            app.ComponentspeedrpmSliderLabel.Layout.Row = 5;
            app.ComponentspeedrpmSliderLabel.Layout.Column = 1;
            app.ComponentspeedrpmSliderLabel.Text = 'Component speed (rpm)';

            % Create ComponentspeedrpmSlider
            app.ComponentspeedrpmSlider = uislider(app.GridLayout6);
            app.ComponentspeedrpmSlider.ValueChangedFcn = createCallbackFcn(app, @ComponentspeedrpmSliderValueChanged, true);
            app.ComponentspeedrpmSlider.FontSize = 14;
            app.ComponentspeedrpmSlider.Layout.Row = 5;
            app.ComponentspeedrpmSlider.Layout.Column = 2;

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.GridLayout2);
            app.GridLayout7.RowHeight = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout7.Layout.Row = 3;
            app.GridLayout7.Layout.Column = 1;
            app.GridLayout7.BackgroundColor = [0.702 1 0.702];

            % Create StimuliconfigurationLabel
            app.StimuliconfigurationLabel = uilabel(app.GridLayout7);
            app.StimuliconfigurationLabel.BackgroundColor = [0 1 0];
            app.StimuliconfigurationLabel.HorizontalAlignment = 'center';
            app.StimuliconfigurationLabel.FontSize = 24;
            app.StimuliconfigurationLabel.FontWeight = 'bold';
            app.StimuliconfigurationLabel.Layout.Row = 1;
            app.StimuliconfigurationLabel.Layout.Column = [1 2];
            app.StimuliconfigurationLabel.Text = 'Stimuli configuration';

            % Create AmplitudeVSliderLabel
            app.AmplitudeVSliderLabel = uilabel(app.GridLayout7);
            app.AmplitudeVSliderLabel.HorizontalAlignment = 'right';
            app.AmplitudeVSliderLabel.FontSize = 14;
            app.AmplitudeVSliderLabel.Layout.Row = 3;
            app.AmplitudeVSliderLabel.Layout.Column = 1;
            app.AmplitudeVSliderLabel.Text = 'Amplitude [V]';

            % Create AmplitudeVSlider
            app.AmplitudeVSlider = uislider(app.GridLayout7);
            app.AmplitudeVSlider.Limits = [0 5];
            app.AmplitudeVSlider.ValueChangedFcn = createCallbackFcn(app, @AmplitudeVSliderValueChanged, true);
            app.AmplitudeVSlider.FontSize = 14;
            app.AmplitudeVSlider.Layout.Row = 3;
            app.AmplitudeVSlider.Layout.Column = 2;
            app.AmplitudeVSlider.Value = 3;

            % Create FundamentalfrequencyHzSliderLabel
            app.FundamentalfrequencyHzSliderLabel = uilabel(app.GridLayout7);
            app.FundamentalfrequencyHzSliderLabel.HorizontalAlignment = 'right';
            app.FundamentalfrequencyHzSliderLabel.FontSize = 14;
            app.FundamentalfrequencyHzSliderLabel.Layout.Row = 4;
            app.FundamentalfrequencyHzSliderLabel.Layout.Column = 1;
            app.FundamentalfrequencyHzSliderLabel.Text = 'Fundamental frequency [Hz]';

            % Create FundamentalfrequencyHzSlider
            app.FundamentalfrequencyHzSlider = uislider(app.GridLayout7);
            app.FundamentalfrequencyHzSlider.Limits = [0 1];
            app.FundamentalfrequencyHzSlider.ValueChangedFcn = createCallbackFcn(app, @FundamentalfrequencyHzSliderValueChanged, true);
            app.FundamentalfrequencyHzSlider.FontSize = 14;
            app.FundamentalfrequencyHzSlider.Layout.Row = 4;
            app.FundamentalfrequencyHzSlider.Layout.Column = 2;
            app.FundamentalfrequencyHzSlider.Value = 0.2;

            % Create BiasVSliderLabel
            app.BiasVSliderLabel = uilabel(app.GridLayout7);
            app.BiasVSliderLabel.HorizontalAlignment = 'right';
            app.BiasVSliderLabel.FontSize = 14;
            app.BiasVSliderLabel.Layout.Row = 5;
            app.BiasVSliderLabel.Layout.Column = 1;
            app.BiasVSliderLabel.Text = 'Bias [V]';

            % Create BiasVSlider
            app.BiasVSlider = uislider(app.GridLayout7);
            app.BiasVSlider.Limits = [0 0.1];
            app.BiasVSlider.FontSize = 14;
            app.BiasVSlider.Layout.Row = 5;
            app.BiasVSlider.Layout.Column = 2;

            % Create SignaltypeDropDownLabel
            app.SignaltypeDropDownLabel = uilabel(app.GridLayout7);
            app.SignaltypeDropDownLabel.HorizontalAlignment = 'right';
            app.SignaltypeDropDownLabel.FontSize = 18;
            app.SignaltypeDropDownLabel.Layout.Row = 2;
            app.SignaltypeDropDownLabel.Layout.Column = 1;
            app.SignaltypeDropDownLabel.Text = 'Signal type';

            % Create SignaltypeDropDown
            app.SignaltypeDropDown = uidropdown(app.GridLayout7);
            app.SignaltypeDropDown.Items = {'Sine', 'Pulse', 'Sawtooth'};
            app.SignaltypeDropDown.FontSize = 18;
            app.SignaltypeDropDown.Layout.Row = 2;
            app.SignaltypeDropDown.Layout.Column = 2;
            app.SignaltypeDropDown.Value = 'Sine';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'2x', '1x', '1x'};
            app.GridLayout4.RowHeight = {'1x'};
            app.GridLayout4.Layout.Row = 1;
            app.GridLayout4.Layout.Column = 2;
            app.GridLayout4.BackgroundColor = [0.6 1 1];

            % Create PlantlinearisationapplicationLabel
            app.PlantlinearisationapplicationLabel = uilabel(app.GridLayout4);
            app.PlantlinearisationapplicationLabel.BackgroundColor = [0 1 1];
            app.PlantlinearisationapplicationLabel.HorizontalAlignment = 'center';
            app.PlantlinearisationapplicationLabel.FontSize = 24;
            app.PlantlinearisationapplicationLabel.FontWeight = 'bold';
            app.PlantlinearisationapplicationLabel.Layout.Row = 1;
            app.PlantlinearisationapplicationLabel.Layout.Column = 1;
            app.PlantlinearisationapplicationLabel.Text = 'Plant linearisation application';

            % Create Image3
            app.Image3 = uiimage(app.GridLayout4);
            app.Image3.Layout.Row = 1;
            app.Image3.Layout.Column = 3;
            app.Image3.ImageSource = fullfile(pathToMLAPP, 'UoSlogo.png');

            % Create Image4
            app.Image4 = uiimage(app.GridLayout4);
            app.Image4.Layout.Row = 1;
            app.Image4.Layout.Column = 2;
            app.Image4.ImageSource = fullfile(pathToMLAPP, 'logo_ITU.png');

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout);
            app.GridLayout5.RowHeight = {'1x'};
            app.GridLayout5.Layout.Row = 1;
            app.GridLayout5.Layout.Column = 1;
            app.GridLayout5.BackgroundColor = [1 0.6 0.8];

            % Create SimulateButton
            app.SimulateButton = uibutton(app.GridLayout5, 'push');
            app.SimulateButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateButtonPushed, true);
            app.SimulateButton.BackgroundColor = [1 0.2 0.702];
            app.SimulateButton.FontSize = 24;
            app.SimulateButton.FontWeight = 'bold';
            app.SimulateButton.Layout.Row = 1;
            app.SimulateButton.Layout.Column = 1;
            app.SimulateButton.Text = 'Simulate';

            % Create DeletehistoryButton
            app.DeletehistoryButton = uibutton(app.GridLayout5, 'push');
            app.DeletehistoryButton.ButtonPushedFcn = createCallbackFcn(app, @DeletehistoryButtonPushed, true);
            app.DeletehistoryButton.BackgroundColor = [1 0.2 0.702];
            app.DeletehistoryButton.FontSize = 24;
            app.DeletehistoryButton.FontWeight = 'bold';
            app.DeletehistoryButton.Layout.Row = 1;
            app.DeletehistoryButton.Layout.Column = 2;
            app.DeletehistoryButton.Text = 'Delete history';

            % Create GridLayout8
            app.GridLayout8 = uigridlayout(app.GridLayout);
            app.GridLayout8.RowHeight = {'1x'};
            app.GridLayout8.Layout.Row = 2;
            app.GridLayout8.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout8);
            title(app.UIAxes, 'Input signal')
            xlabel(app.UIAxes, 'time (sec)')
            ylabel(app.UIAxes, 'u(t)  volts')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.FontSize = 18;
            app.UIAxes.Layout.Row = 1;
            app.UIAxes.Layout.Column = 1;

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.GridLayout8);
            title(app.UIAxes3, 'Linear and non-linear overlay')
            xlabel(app.UIAxes3, 'time (sec)')
            ylabel(app.UIAxes3, 'Position')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.FontSize = 18;
            app.UIAxes3.Layout.Row = 1;
            app.UIAxes3.Layout.Column = 2;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = linearisation_Benchmark_control101

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

