classdef Signal_Types_in_Comp_Control_application_control101 < matlab.apps.AppBase
    %SIGNAL_TYPES_IN_COMP_CONTROL_APPLICATION_CONTROL101
    %   This app focuses on the impact of sampling on behaviour and pole
    %   positions. The intention is to allow easy visualisation os the user
    %   can focus on core concepts and the impact. The simulations are
    %   based on two non-linear models to add an authentic touch.
    %   
    %   For more detailed explanations and theory see the supporting
    %   livescripts: Sampled_Data_Systems_control101.mlx,      
    %   Sampling_Operation_control101.mlx,                            
    %   Signal_Types_in_Computer_Controlled_Systems_control101.mlx

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        GridLayout11                  matlab.ui.container.GridLayout
        Image5                        matlab.ui.control.Image
        UIAxes3                       matlab.ui.control.UIAxes
        UIAxes                        matlab.ui.control.UIAxes
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
        GridLayout10                  matlab.ui.container.GridLayout
        Image4                        matlab.ui.control.Image
        UIAxes2                       matlab.ui.control.UIAxes
        UIAxes4                       matlab.ui.control.UIAxes
        GridLayout5                   matlab.ui.container.GridLayout
        DeletehistoryButton           matlab.ui.control.Button
        SimulateButton                matlab.ui.control.Button
        GridLayout4                   matlab.ui.container.GridLayout
        Image6                        matlab.ui.control.Image
        Image3                        matlab.ui.control.Image
        SignalTypesinComputerControlledSystemsApplicationLabel  matlab.ui.control.Label
    end

    
    properties (Access = private)
        originalsize % Description
        Experimenttext=cell(1)
        experimentCounter = 0
    end
    
    methods (Access = private)
        
        function results = func(app)
            
        end
        function  disablebuttons(app)
            set(app.SignaltypeDropDown, 'Enable', 'off');
             set(app.BiasVSlider, 'Enable', 'off');
            set(app.FundamentalfrequencyHzSlider, 'Enable', 'off');
            set(app.AmplitudeVSlider, 'Enable', 'off');
            set(app.SimulationtimesSlider, 'Enable', 'off');
            set(app.SamplingtimemsSlider, 'Enable', 'off');
            set(app.SelectedplantDropDown, 'Enable', 'off');
        end
        
        function enablebuttons(app)
            set(app.SignaltypeDropDown, 'Enable', 'on');
             set(app.BiasVSlider, 'Enable', 'on');
            set(app.FundamentalfrequencyHzSlider, 'Enable', 'on');
            set(app.AmplitudeVSlider, 'Enable', 'on');
            set(app.SimulationtimesSlider, 'Enable', 'on');
            set(app.SamplingtimemsSlider, 'Enable', 'on');
            set(app.SelectedplantDropDown, 'Enable', 'on');

        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            %app.UIFigure.AutoResizeChildren='off';   
            movegui(app.UIFigure)
            
            % Open the manual
            Signal_Types_in_Computer_Controlled_Systems_control101

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

            % reminder that sampling time is in ms
            steps = 1000*app.SimulationtimesSlider.Value/app.SamplingtimemsSlider.Value;
            time = linspace(0,app.SimulationtimesSlider.Value,steps+1);
            time0 = linspace(0,app.SimulationtimesSlider.Value,1001);
            step_value = time(2)-time(1);
                
            control_input = 0;
            sim_output = [];
            sinewave = sin(2*pi*frequency*time);
                switch value                       
                    case "Sine"
                    control_input = amplitude * sinewave + bias;
                    case "Pulse"
                    control_input = amplitude * square(sinewave)  + bias;
                    case "Sawtooth" 
                    control_input = amplitude * sawtooth( 2 * pi * frequency * time ) + bias;
                end
                %control_input_rad = deg2rad(control_input);
                % make sure no negative inputs
                for item_cnt = 1 : length(control_input);
                        if control_input(item_cnt) < 0;
                            control_input(item_cnt) = 0;
                        end
                end

                % Define the operating point for a default speed and zeros
                % elsewhere
                speed= 2*pi*500/60;
                x0 = [ 0; speed; 0; 0];

                switch app.SelectedplantDropDown.Value
                    case "Fan & Plate" 
                        % Define the operating point for a default speed and zeros
                        % elsewhere
                        speed= 2*pi*500/60;
                        x0 = [ 0; speed; 0; 0];
                    %linearised model
                    FanAndPlate_Data_control101;  % defines parameter values
                    sys=FanAndPlate_model_control101(x0);     
                   
                    simIn = Simulink.SimulationInput('FanAndPlate_control101.slx');
                    simIn = simIn.setVariable('Stoptime',app.SimulationtimesSlider.Value);
                    simIn = simIn.setVariable('SampleTime',step_value);
                    simIn = simIn.setVariable('initialcurrent',0);
                    simIn = simIn.setVariable('fanspeed',speed);
                    simIn = simIn.setVariable('initialplatespeed',0);
                    simIn = simIn.setVariable('initialplateangle',0);
                    simIn = simIn.setVariable('input_data_gl',[time', control_input']);
                    sim_output = sim(simIn);
                    sim_output2 = sim_output.continuous_output.signals.values;
                    sim_output3 = sim_output.discrete_output.signals.values;
                    time2 = sim_output.continuous_output.time;
                    time3 = sim_output.discrete_output.time;
                    

                    case "QNET VTOL" 
                        % Define the operating point for a default speed and zeros
                        % elsewhere
                        speed= 2*pi*50/60;
                        x0 = [ 0; speed; 0; 0];

                    % linearised model
                    OneDofAeroVTOL_Data_control101; % defines parameter values
                    sys=OneDofAeroVTOL_model_control101(x0);
                    
                    simIn = Simulink.SimulationInput('OneDofAeroVTOL_control101.slx');
                    simIn = simIn.setVariable('Stoptime',app.SimulationtimesSlider.Value);
                    simIn = simIn.setVariable('SampleTime',step_value);
                    simIn = simIn.setVariable('initialcurrent',0);
                    simIn = simIn.setVariable('fanspeed',speed);
                    simIn = simIn.setVariable('initialplatespeed',0);
                    simIn = simIn.setVariable('initialplateangle',0);
                    simIn = simIn.setVariable('input_data_gl',[time', control_input']);
                    sim_output = sim(simIn);
                    sim_output2 = sim_output.continuous_output.signals.values;
                    sim_output3 = sim_output.discrete_output.signals.values;
                    time2 = sim_output.continuous_output.time;
                    time3 = sim_output.discrete_output.time;
                    
                   
                end
                
                %%% Plotting
                sim_output2 = rad2deg(sim_output2);
                sim_output3 = rad2deg(sim_output3);
%
                stem(app.UIAxes2, time, control_input);
                grid(app.UIAxes2, "on");
                grid(app.UIAxes2, "minor");

                acolor=stairs(app.UIAxes4, time, control_input);
                grid(app.UIAxes4, "on");
                grid(app.UIAxes4, "minor");

                plot(app.UIAxes,  time2, sim_output2);
                grid(app.UIAxes, "on");
                grid(app.UIAxes, "minor");
                
                stem(app.UIAxes3, time3, sim_output3);
                grid(app.UIAxes3, "on");
                grid(app.UIAxes3, "minor");
       

                % Save data for legend
                app.experimentCounter = app.experimentCounter + 1;
                app.Experimenttext{app.experimentCounter} = ['Experiment ',num2str(app.experimentCounter)];
                %legend(app.UIAxes,app.Experimenttext)
                
                enablebuttons(app)
    
    

        end

        % Value changed function: SamplingtimemsSlider
        function SamplingtimemsSliderValueChanged(app, event)
            value = app.SamplingtimemsSlider.Value;
              if value==0; app.SamplingtimemsSlider.Value=20;end
        end

        % Value changed function: FundamentalfrequencyHzSlider
        function FundamentalfrequencyHzSliderValueChanged(app, event)
            value = app.FundamentalfrequencyHzSlider.Value;
            if value==0;
                app.FundamentalfrequencyHzSlider.Value=0.1;
            end
        end

        % Value changed function: AmplitudeVSlider
        function AmplitudeVSliderValueChanged(app, event)
            value = app.AmplitudeVSlider.Value;
            if value==0;
                app.AmplitudeVSlider.Value=1;
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
            app.UIFigure.Position = [100 100 1486 925];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '0.6x', '1x'};
            app.GridLayout.RowHeight = {'0.25x', '1x', '1x'};

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'2x', '1x', '1x'};
            app.GridLayout4.RowHeight = {'1x'};
            app.GridLayout4.Layout.Row = 1;
            app.GridLayout4.Layout.Column = [2 3];
            app.GridLayout4.BackgroundColor = [0.6 1 1];

            % Create SignalTypesinComputerControlledSystemsApplicationLabel
            app.SignalTypesinComputerControlledSystemsApplicationLabel = uilabel(app.GridLayout4);
            app.SignalTypesinComputerControlledSystemsApplicationLabel.BackgroundColor = [0 1 1];
            app.SignalTypesinComputerControlledSystemsApplicationLabel.HorizontalAlignment = 'center';
            app.SignalTypesinComputerControlledSystemsApplicationLabel.WordWrap = 'on';
            app.SignalTypesinComputerControlledSystemsApplicationLabel.FontSize = 24;
            app.SignalTypesinComputerControlledSystemsApplicationLabel.FontWeight = 'bold';
            app.SignalTypesinComputerControlledSystemsApplicationLabel.Layout.Row = 1;
            app.SignalTypesinComputerControlledSystemsApplicationLabel.Layout.Column = 1;
            app.SignalTypesinComputerControlledSystemsApplicationLabel.Text = 'Signal Types in Computer Controlled Systems Application';

            % Create Image3
            app.Image3 = uiimage(app.GridLayout4);
            app.Image3.Layout.Row = 1;
            app.Image3.Layout.Column = 3;
            app.Image3.ImageSource = fullfile(pathToMLAPP, 'UoSlogo.png');

            % Create Image6
            app.Image6 = uiimage(app.GridLayout4);
            app.Image6.Layout.Row = 1;
            app.Image6.Layout.Column = 2;
            app.Image6.ImageSource = fullfile(pathToMLAPP, 'logo_ITU.png');

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

            % Create GridLayout10
            app.GridLayout10 = uigridlayout(app.GridLayout);
            app.GridLayout10.ColumnWidth = {'1x'};
            app.GridLayout10.RowHeight = {'1x', '0.5x', '1x'};
            app.GridLayout10.Layout.Row = [2 3];
            app.GridLayout10.Layout.Column = 1;

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.GridLayout10);
            title(app.UIAxes4, 'Input signal after DAC')
            xlabel(app.UIAxes4, 'time (sec)')
            ylabel(app.UIAxes4, 'u(t)')
            zlabel(app.UIAxes4, 'Z')
            app.UIAxes4.FontSize = 18;
            app.UIAxes4.Layout.Row = 1;
            app.UIAxes4.Layout.Column = 1;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout10);
            title(app.UIAxes2, 'Input signal before DAC')
            xlabel(app.UIAxes2, 'time (sec)')
            ylabel(app.UIAxes2, 'u(kTs)')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 18;
            app.UIAxes2.Layout.Row = 3;
            app.UIAxes2.Layout.Column = 1;

            % Create Image4
            app.Image4 = uiimage(app.GridLayout10);
            app.Image4.Layout.Row = 2;
            app.Image4.Layout.Column = 1;
            app.Image4.ImageSource = fullfile(pathToMLAPP, 'images', 'in.png');

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.GridLayout);
            app.GridLayout7.RowHeight = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout7.Layout.Row = 3;
            app.GridLayout7.Layout.Column = 2;
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
            app.FundamentalfrequencyHzSlider.MajorTicks = [0 0.2 0.4 0.6 0.8 1];
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
            app.SignaltypeDropDown.Value = 'Pulse';

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout);
            app.GridLayout3.RowHeight = {'1x', '0.8x', '2x', '1x', '1x'};
            app.GridLayout3.Layout.Row = 2;
            app.GridLayout3.Layout.Column = 2;
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
            app.SamplingtimemsSlider.Limits = [0 1000];
            app.SamplingtimemsSlider.ValueChangedFcn = createCallbackFcn(app, @SamplingtimemsSliderValueChanged, true);
            app.SamplingtimemsSlider.FontSize = 14;
            app.SamplingtimemsSlider.Layout.Row = 4;
            app.SamplingtimemsSlider.Layout.Column = 2;
            app.SamplingtimemsSlider.Value = 20;

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

            % Create GridLayout11
            app.GridLayout11 = uigridlayout(app.GridLayout);
            app.GridLayout11.ColumnWidth = {'1x'};
            app.GridLayout11.RowHeight = {'1x', '0.5x', '1x'};
            app.GridLayout11.Layout.Row = [2 3];
            app.GridLayout11.Layout.Column = 3;

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout11);
            title(app.UIAxes, 'System output before ADC')
            xlabel(app.UIAxes, 'time (sec)')
            ylabel(app.UIAxes, 'y(t)')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.FontSize = 18;
            app.UIAxes.Layout.Row = 1;
            app.UIAxes.Layout.Column = 1;

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.GridLayout11);
            title(app.UIAxes3, 'System output after ADC')
            xlabel(app.UIAxes3, 'Time (sec)')
            ylabel(app.UIAxes3, 'y(kTs)')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.FontSize = 18;
            app.UIAxes3.Layout.Row = 3;
            app.UIAxes3.Layout.Column = 1;

            % Create Image5
            app.Image5 = uiimage(app.GridLayout11);
            app.Image5.Layout.Row = 2;
            app.Image5.Layout.Column = 1;
            app.Image5.ImageSource = fullfile(pathToMLAPP, 'images', 'out.png');

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Signal_Types_in_Comp_Control_application_control101

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

