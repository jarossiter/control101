classdef Analog_to_Digital_Converter_Application_control101 < matlab.apps.AppBase
    %ANALOG_TO_DIGITAL_CONVERTER_APPLICATION_CONTROL101
    %   This virtual laboratory allows the investigation of analogue to
    %   digital convertors for a range of sampling times and methods. The
    %   intention is to focus on visualisation of the results.
    %   
    %   For more detailed explanation and analysis see the supporting
    %   livescripts: Sampled_Data_Systems_control101.mlx,                  
    %              
    %   Sampling_Operation_control101.mlx,
    %   Reconstruction_and_Signal_Holders_control101.mlx

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        GridLayout8                   matlab.ui.container.GridLayout
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
        GridLayout3                   matlab.ui.container.GridLayout
        ResolutionBitSlider           matlab.ui.control.Slider
        ResolutionBitSliderLabel      matlab.ui.control.Label
        SensorminSlider               matlab.ui.control.Slider
        SensorminSliderLabel          matlab.ui.control.Label
        SensormaxSlider               matlab.ui.control.Slider
        SensormaxSliderLabel          matlab.ui.control.Label
        SimulationtimesSlider         matlab.ui.control.Slider
        SimulationtimesSliderLabel    matlab.ui.control.Label
        SamplingtimeSlider            matlab.ui.control.Slider
        SamplingtimeSliderLabel       matlab.ui.control.Label
        AnaloguetodigitalconvertorLabel  matlab.ui.control.Label
        GridLayout5                   matlab.ui.container.GridLayout
        DeletehistoryButton           matlab.ui.control.Button
        SimulateButton                matlab.ui.control.Button
        GridLayout4                   matlab.ui.container.GridLayout
        Image2                        matlab.ui.control.Image
        Image                         matlab.ui.control.Image
        AnaloguetodigitalconverterLabel  matlab.ui.control.Label
        UIAxes4                       matlab.ui.control.UIAxes
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
            set(app.SensorminSlider, 'Enable', 'off');
            set(app.SensormaxSlider, 'Enable', 'off');
            set(app.ResolutionBitSlider, 'Enable', 'off');
            set(app.SimulationtimesSlider, 'Enable', 'off');
            set(app.SamplingtimeSlider, 'Enable', 'off');
            set(app.SimulateButton, 'Enable', 'off');
        end
        
        function enablebuttons(app)
            set(app.SignaltypeDropDown, 'Enable', 'on');
             set(app.BiasVSlider, 'Enable', 'on');
            set(app.FundamentalfrequencyHzSlider, 'Enable', 'on');
            set(app.AmplitudeVSlider, 'Enable', 'on');
            set(app.SensorminSlider, 'Enable', 'on');
            set(app.SensormaxSlider, 'Enable', 'on');
            set(app.ResolutionBitSlider, 'Enable', 'on');
            set(app.SimulationtimesSlider, 'Enable', 'on');
            set(app.SamplingtimeSlider, 'Enable', 'on');
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
            Sampled_Data_Systems_control101                                          
            Sampling_Operation_control101 

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
            cla(app.UIAxes4);
            app.experimentCounter = 0;
            
        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
            disablebuttons(app)    
            
            value = app.SignaltypeDropDown.Value;
                amplitude = app.AmplitudeVSlider.Value;
                frequency = app.FundamentalfrequencyHzSlider.Value;
                bias = app.BiasVSlider.Value;
    
                % reminder that sampling time is in sec
                steps = app.SimulationtimesSlider.Value/app.SamplingtimeSlider.Value;
                time = linspace(0,app.SimulationtimesSlider.Value,steps+1);
                time0=linspace(0,app.SimulationtimesSlider.Value,201);
                step_value = time(2)-time(1);
                
    
                control_input = 0;
                sim_output = [];
                sinewave = sin(2*pi*frequency*time);
                sinewave0 = sin(2*pi*frequency*time0);
                 switch value                       
                    
                    case "Sine"
                    control_input = amplitude/2 * sinewave +amplitude/2+ bias;
                    control_input0 = amplitude/2 * sinewave0 +amplitude/2+ bias;
                    case "Pulse"
                    control_input = (amplitude/2) * square(sinewave)+amplitude/2  + bias;
                    control_input0 = (amplitude/2) * square(sinewave0)+amplitude/2  + bias;
                    case "Sawtooth" 
                    control_input = (amplitude/2) * sawtooth( 2 * pi * frequency * time )+...
                        amplitude/2 + bias;
                    control_input0 = (amplitude/2) * sawtooth( 2 * pi * frequency * time0 ) +...
                        amplitude/2+bias;
                end
                % Keep track of experiment number for the legend
                app.experimentCounter = app.experimentCounter + 1;
                app.Experimenttext{app.experimentCounter} = ['Experiment ',num2str(app.experimentCounter)];

                % use simulink to do the ADC
                simIn = Simulink.SimulationInput('ADCModel_control101.slx');
                simIn = simIn.setVariable('StopTime',app.SimulationtimesSlider.Value);
                simIn = simIn.setVariable('SampleTime',step_value);
                simIn = simIn.setVariable('resolution',app.ResolutionBitSlider.Value);
                simIn = simIn.setVariable('sensormax',app.SensormaxSlider.Value);
                simIn = simIn.setVariable('sensormin',app.SensorminSlider.Value);
                simIn = simIn.setVariable('input_data_gl',[time', control_input']);
                sim_output = sim(simIn);

                % plot the results
                plot(app.UIAxes4, time0, control_input0, 'LineWidth',2);
                grid(app.UIAxes4, "on");
                hold(app.UIAxes4, "on");
                grid(app.UIAxes4, "minor");                
                
                stairs(app.UIAxes2, sim_output.simout.time, sim_output.simout.signals.values, '-','LineWidth',2, 'MarkerFaceColor', [0 0.4470 0.7410]);
                hold(app.UIAxes2, "on");
                grid(app.UIAxes2, "on");
                grid(app.UIAxes2, "minor");
                
                legend(app.UIAxes2,app.Experimenttext)

                
                enablebuttons(app)

        end

        % Value changed function: SamplingtimeSlider
        function SamplingtimeSliderValueChanged(app, event)
            value = app.SamplingtimeSlider.Value;
            if value==0;
                app.SamplingtimeSlider.Value=0.05;
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
            app.UIFigure.Position = [100 100 1212 754];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1.5x'};
            app.GridLayout.RowHeight = {'0.25x', '1x', '1x'};

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout);
            title(app.UIAxes2, 'System output after ADC')
            xlabel(app.UIAxes2, 'time (sec)')
            ylabel(app.UIAxes2, 'y(kTs)')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 18;
            app.UIAxes2.Layout.Row = 3;
            app.UIAxes2.Layout.Column = 2;

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.GridLayout);
            title(app.UIAxes4, 'System output before ADC')
            xlabel(app.UIAxes4, 'time (sec)')
            ylabel(app.UIAxes4, 'y(t)')
            zlabel(app.UIAxes4, 'Z')
            app.UIAxes4.FontSize = 18;
            app.UIAxes4.Layout.Row = 2;
            app.UIAxes4.Layout.Column = 2;

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'2x', '1x', '1x'};
            app.GridLayout4.RowHeight = {'1x'};
            app.GridLayout4.Layout.Row = 1;
            app.GridLayout4.Layout.Column = 2;
            app.GridLayout4.BackgroundColor = [0.6 1 1];

            % Create AnaloguetodigitalconverterLabel
            app.AnaloguetodigitalconverterLabel = uilabel(app.GridLayout4);
            app.AnaloguetodigitalconverterLabel.BackgroundColor = [0 1 1];
            app.AnaloguetodigitalconverterLabel.HorizontalAlignment = 'center';
            app.AnaloguetodigitalconverterLabel.WordWrap = 'on';
            app.AnaloguetodigitalconverterLabel.FontSize = 24;
            app.AnaloguetodigitalconverterLabel.FontWeight = 'bold';
            app.AnaloguetodigitalconverterLabel.Layout.Row = 1;
            app.AnaloguetodigitalconverterLabel.Layout.Column = 1;
            app.AnaloguetodigitalconverterLabel.Text = 'Analogue to digital converter';

            % Create Image
            app.Image = uiimage(app.GridLayout4);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 3;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'UoSlogo.png');

            % Create Image2
            app.Image2 = uiimage(app.GridLayout4);
            app.Image2.Layout.Row = 1;
            app.Image2.Layout.Column = 2;
            app.Image2.ImageSource = fullfile(pathToMLAPP, 'logo_ITU.png');

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
            app.GridLayout8.ColumnWidth = {'1x'};
            app.GridLayout8.RowHeight = {'1.4x', '1x'};
            app.GridLayout8.Layout.Row = [2 3];
            app.GridLayout8.Layout.Column = 1;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout8);
            app.GridLayout3.ColumnWidth = {'0.7x', '1x'};
            app.GridLayout3.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout3.Layout.Row = 1;
            app.GridLayout3.Layout.Column = 1;
            app.GridLayout3.BackgroundColor = [0.902 1 0.502];

            % Create AnaloguetodigitalconvertorLabel
            app.AnaloguetodigitalconvertorLabel = uilabel(app.GridLayout3);
            app.AnaloguetodigitalconvertorLabel.BackgroundColor = [1 1 0];
            app.AnaloguetodigitalconvertorLabel.HorizontalAlignment = 'center';
            app.AnaloguetodigitalconvertorLabel.FontSize = 24;
            app.AnaloguetodigitalconvertorLabel.FontWeight = 'bold';
            app.AnaloguetodigitalconvertorLabel.Layout.Row = 1;
            app.AnaloguetodigitalconvertorLabel.Layout.Column = [1 2];
            app.AnaloguetodigitalconvertorLabel.Text = 'Analogue  to digital convertor';

            % Create SamplingtimeSliderLabel
            app.SamplingtimeSliderLabel = uilabel(app.GridLayout3);
            app.SamplingtimeSliderLabel.HorizontalAlignment = 'right';
            app.SamplingtimeSliderLabel.FontSize = 14;
            app.SamplingtimeSliderLabel.Layout.Row = 2;
            app.SamplingtimeSliderLabel.Layout.Column = 1;
            app.SamplingtimeSliderLabel.Text = 'Sampling time';

            % Create SamplingtimeSlider
            app.SamplingtimeSlider = uislider(app.GridLayout3);
            app.SamplingtimeSlider.Limits = [0 1];
            app.SamplingtimeSlider.MajorTicks = [0 0.2 0.4 0.6 0.8 1];
            app.SamplingtimeSlider.ValueChangedFcn = createCallbackFcn(app, @SamplingtimeSliderValueChanged, true);
            app.SamplingtimeSlider.FontSize = 14;
            app.SamplingtimeSlider.Layout.Row = 2;
            app.SamplingtimeSlider.Layout.Column = 2;
            app.SamplingtimeSlider.Value = 0.1;

            % Create SimulationtimesSliderLabel
            app.SimulationtimesSliderLabel = uilabel(app.GridLayout3);
            app.SimulationtimesSliderLabel.HorizontalAlignment = 'right';
            app.SimulationtimesSliderLabel.FontSize = 14;
            app.SimulationtimesSliderLabel.Layout.Row = 3;
            app.SimulationtimesSliderLabel.Layout.Column = 1;
            app.SimulationtimesSliderLabel.Text = 'Simulation time (s)';

            % Create SimulationtimesSlider
            app.SimulationtimesSlider = uislider(app.GridLayout3);
            app.SimulationtimesSlider.Limits = [10 20];
            app.SimulationtimesSlider.FontSize = 14;
            app.SimulationtimesSlider.Layout.Row = 3;
            app.SimulationtimesSlider.Layout.Column = 2;
            app.SimulationtimesSlider.Value = 10;

            % Create SensormaxSliderLabel
            app.SensormaxSliderLabel = uilabel(app.GridLayout3);
            app.SensormaxSliderLabel.HorizontalAlignment = 'right';
            app.SensormaxSliderLabel.FontSize = 14;
            app.SensormaxSliderLabel.Layout.Row = 4;
            app.SensormaxSliderLabel.Layout.Column = 1;
            app.SensormaxSliderLabel.Text = 'Sensor max';

            % Create SensormaxSlider
            app.SensormaxSlider = uislider(app.GridLayout3);
            app.SensormaxSlider.Limits = [100 150];
            app.SensormaxSlider.Layout.Row = 4;
            app.SensormaxSlider.Layout.Column = 2;
            app.SensormaxSlider.Value = 120;

            % Create SensorminSliderLabel
            app.SensorminSliderLabel = uilabel(app.GridLayout3);
            app.SensorminSliderLabel.HorizontalAlignment = 'right';
            app.SensorminSliderLabel.FontSize = 14;
            app.SensorminSliderLabel.Layout.Row = 5;
            app.SensorminSliderLabel.Layout.Column = 1;
            app.SensorminSliderLabel.Text = 'Sensor min';

            % Create SensorminSlider
            app.SensorminSlider = uislider(app.GridLayout3);
            app.SensorminSlider.Limits = [0 20];
            app.SensorminSlider.FontSize = 14;
            app.SensorminSlider.Layout.Row = 5;
            app.SensorminSlider.Layout.Column = 2;

            % Create ResolutionBitSliderLabel
            app.ResolutionBitSliderLabel = uilabel(app.GridLayout3);
            app.ResolutionBitSliderLabel.HorizontalAlignment = 'right';
            app.ResolutionBitSliderLabel.FontSize = 14;
            app.ResolutionBitSliderLabel.Layout.Row = 6;
            app.ResolutionBitSliderLabel.Layout.Column = 1;
            app.ResolutionBitSliderLabel.Text = 'Resolution (Bit)';

            % Create ResolutionBitSlider
            app.ResolutionBitSlider = uislider(app.GridLayout3);
            app.ResolutionBitSlider.Limits = [0 10];
            app.ResolutionBitSlider.FontSize = 14;
            app.ResolutionBitSlider.Layout.Row = 6;
            app.ResolutionBitSlider.Layout.Column = 2;
            app.ResolutionBitSlider.Value = 8;

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.GridLayout8);
            app.GridLayout7.ColumnWidth = {'0.7x', '1x'};
            app.GridLayout7.RowHeight = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout7.Layout.Row = 2;
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
            app.AmplitudeVSlider.Limits = [0 200];
            app.AmplitudeVSlider.FontSize = 14;
            app.AmplitudeVSlider.Layout.Row = 3;
            app.AmplitudeVSlider.Layout.Column = 2;
            app.AmplitudeVSlider.Value = 100;

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
            app.FundamentalfrequencyHzSlider.MajorTicks = [0 0.2 0.4 0.6 0.8 1];
            app.FundamentalfrequencyHzSlider.MinorTicks = [0 0.02 0.04 0.06 0.08 0.1 0.12 0.14 0.16 0.18 0.2 0.22 0.24 0.26 0.28 0.3 0.32 0.34 0.36 0.38 0.4 0.42 0.44 0.46 0.48 0.5 0.52 0.54 0.56 0.58 0.6 0.62 0.64 0.66 0.68 0.7 0.72 0.74 0.76 0.78 0.8 0.82 0.84 0.86 0.88 0.9 0.92 0.94 0.96 0.98 1];
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
            app.BiasVSlider.Limits = [0 10];
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

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Analog_to_Digital_Converter_Application_control101

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

