classdef nonlinear_tank_behaviour_control101 < matlab.apps.AppBase
    %NONLINEAR_TANK_BEHAVIOUR_CONTROL101
    %   This resource focuses on non-linear behaviour which will arise from
    %   a common non-linear components, that is the non-linear dependence
    %   of flow though a restriction on the presssure difference.
    %   
    %   The easiest way to explore this is using this app interface (see
    %   section 3), although the livescript manual (opened automatically)
    %   provides source code that users will find helpful to take more
    %   explicit control of the simulation. 
    %   
    %   The intention is to expose users to the non-linear components and
    %   their impact on open-loop behaviour.   Underlying the virtual
    %   laboratory (app file) is a simulink file 
    %   nonlinear_tank_system_control101.slx  which users could open
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
        BlockageButton_2              matlab.ui.control.Button
        DisturbanceflowButton         matlab.ui.control.Button
        ExternaldisturbancesredmeansnotincludedLabel  matlab.ui.control.Label
        GridLayout6                   matlab.ui.container.GridLayout
        RefreshfigureButton           matlab.ui.control.Button
        CreateresponsesButton         matlab.ui.control.Button
        GridLayout5                   matlab.ui.container.GridLayout
        GridLayout14                  matlab.ui.container.GridLayout
        Image4                        matlab.ui.control.Image
        Image                         matlab.ui.control.Image
        ImpactofnonlinearcomponentsonapositioncontrolsystemLabel  matlab.ui.control.Label
        GridLayout3                   matlab.ui.container.GridLayout
        Tankaream2Slider              matlab.ui.control.Slider
        Tankaream2SliderLabel         matlab.ui.control.Label
        OutletresistanceKSlider       matlab.ui.control.Slider
        OutletresistanceKSliderLabel  matlab.ui.control.Label
        BlockageSlider                matlab.ui.control.Slider
        BlockageSliderLabel           matlab.ui.control.Label
        DisturbanceflowltrsSlider_3   matlab.ui.control.Slider
        DisturbanceflowltrsSlider_3Label  matlab.ui.control.Label
        InletflowltrsSlider           matlab.ui.control.Slider
        InletflowltrsSliderLabel      matlab.ui.control.Label
        InitialdepthmSlider           matlab.ui.control.Slider
        InitialdepthmSliderLabel      matlab.ui.control.Label
        SimulationandmodelparametersLabel  matlab.ui.control.Label
        UIAxes2                       matlab.ui.control.UIAxes
        UIAxes2_2                     matlab.ui.control.UIAxes
    end

%     File written by J.A.Rossiter, University of Sheffield
%     See website for more files like this.
%     https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
%    
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
        blockagetime=400; % time that blockage introduced
        endtime=2400;     % simulation run time
        %disturbanceflowtime=800;
     
        qss   % expected steady-state  
        qsse
        hss
        hsse
        qstep = 0.01;     % change in inflow compared to steady-state
        qchangetime = 1200; % time that change in flow/disturbance introduced
        Blockage    % label for legends
       
        % Model parameters needed by simulink file
        rho=1000;    % water density
        g=10;        % gravity
        A;         % tank area true
        Ai           % inverse of A
        Aie;    % estimated tank area 
        R;      % constant needed to determine outflow
        Re;  %   estimated R
        C
        Ce
        Ctemp
        Cl
        factor =1;  % uncertainty in parameters
       
        blockageonoff=0;
        disturbanceonoff=0;

    end
    
    methods (Access = private)
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION FOR BASIC STEP RESPONSES

function [yynl,yyl,tt] = determineresponses(app)
            % This function determines all the closed-loop step responses 
            simIn = Simulink.SimulationInput('non_linear_tank_system_control101_2023');
            
            % simIn = simIn.setVariable('R',app.R);
            simIn = simIn.setVariable('C',app.C);
            simIn = simIn.setVariable('Ctemp',app.Ctemp);
            simIn = simIn.setVariable('Cl',app.Cl);
            simIn = simIn.setVariable('qss',app.qss);
            simIn = simIn.setVariable('qsse',app.qsse);
            simIn = simIn.setVariable('Ai',1/app.Ai);
            simIn = simIn.setVariable('Aie',app.Aie);
            simIn = simIn.setVariable('hss',app.hss);
            simIn = simIn.setVariable('hsse',app.hsse);
            simIn = simIn.setVariable('blockagetime',app.blockagetime); 
            simIn = simIn.setVariable('endtime',app.endtime);
            simIn = simIn.setVariable('qchangetime',app.qchangetime);
            simIn = simIn.setVariable('qstep',app.DisturbanceflowltrsSlider_3.Value);


            % Include blockages
            if app.blockageonoff==0;
                simIn = simIn.setVariable('blockagetime',10000);
                app.Blockage=0;
            else 
                simIn = simIn.setVariable('blockagetime',app.blockagetime);                 
                app.Blockage = app.BlockageSlider.Value;
            end

             % Include blockages
            if app.disturbanceonoff==0;
                simIn = simIn.setVariable('qstep',0);
                
            else
                simIn = simIn.setVariable('qstep',app.DisturbanceflowltrsSlider_3.Value);
                
            end

            % Simulation - 
            simdata=sim(simIn);
            tt=simdata.nonlineardata.time;
            yynl = simdata.nonlineardata.signals.values; % stored in order simulink file
            yyl = simdata.lineardata.signals.values; % stored in order as shown in simulink file
  
            

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
            
            RefreshfigureButtonPushed(app)
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
                theme(app.UIFigure,"light")
            end


        end

        % Button pushed function: CreateresponsesButton
        function CreateresponsesButtonPushed(app, event)
           
            % non-linear model values          
            app.R=app.OutletresistanceKSlider.Value*1000;
            app.C=sqrt(app.rho*app.g)/app.R;
            app.Ctemp = app.C*(1-app.BlockageSlider.Value);  % Increase R during blockage which reduces outflow
            app.hss = app.InitialdepthmSlider.Value;
            app.qss = app.InletflowltrsSlider.Value;
            app.A=app.Tankaream2Slider.Value;
            app.Ai=1/app.A;

            % Linear model values
            app.Re=app.R*app.factor;
            app.Ce=sqrt(app.rho*app.g)/app.Re;
            app.hsse = app.hss;
            app.qsse = app.Ce*sqrt(app.hsse);
            app.Cl=app.Ce/(2*sqrt(app.hsse));
            app.Aie=app.Ai/app.factor;
            

            [yynl,yyl,tt] = determineresponses(app);

           % plotting          
           plot(app.UIAxes2,tt/60,[yynl(:,2),yyl(:,2),yynl(:,4)]);  % input
           legend(app.UIAxes2,'NL depth','Linear depth','Blockage (on/off)','Location','southeast')
          
           plot(app.UIAxes2_2,tt/60,[yynl(:,[3]),yyl(:,3),yynl(:,1)])  % output
           legend(app.UIAxes2_2,'NL out flow','Linear outflow','Input + disturbance flow','Location','southeast')
     
                       
        end

        % Button pushed function: RefreshfigureButton
        function RefreshfigureButtonPushed(app, event)
          %  The idea here is to compare the different open-loop behaviour
          % in a systematic way
          % refresh clearns the figure to begin again
          hold(app.UIAxes2,'off')
          cla(app.UIAxes2)
         
          hold(app.UIAxes2_2,'off')
          cla(app.UIAxes2_2)

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

        % Value changed function: InletflowltrsSlider
        function InletflowltrsSliderValueChanged(app, event)
            value = app.InletflowltrsSlider.Value;
            value=round(value,2);
            
            app.InletflowltrsSlider.Value=value;
           
        end

        % Button pushed function: DisturbanceflowButton
        function DisturbanceflowButtonPushed(app, event)
            Value = app.DisturbanceflowButton.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.DisturbanceflowButton.BackgroundColor = [1 0 0];
                    app.disturbanceonoff=0;
            else
                    app.DisturbanceflowButton.BackgroundColor = [0.4,0.8,0.1];
                    app.disturbanceonoff=1;
            end

        end

        % Button pushed function: BlockageButton_2
        function BlockageButton_2Pushed(app, event)
            Value = app.BlockageButton_2.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.BlockageButton_2.BackgroundColor = [1 0 0];
                    app.blockageonoff=0;
                    
            else
                    app.BlockageButton_2.BackgroundColor = [0.4,0.8,0.1];
                    app.blockageonoff=1;
            end
        end

        % Value changed function: DisturbanceflowltrsSlider_3
        function DisturbanceflowltrsSlider_3ValueChanged(app, event)
            value = app.DisturbanceflowltrsSlider_3.Value;
            value=round(value,2);
            app.DisturbanceflowltrsSlider_3.Value=value;
            
        end

        % Value changed function: InitialdepthmSlider
        function InitialdepthmSliderValueChanged2(app, event)
            value = app.InitialdepthmSlider.Value;
            value=round(value,1);
            
            app.InitialdepthmSlider.Value=value;
           
           
        end

        % Value changed function: BlockageSlider
        function BlockageSliderValueChanged(app, event)
            value = app.BlockageSlider.Value;
            value=round(value,1);
            app.BlockageSlider.Value=value;
            
        end

        % Value changed function: Tankaream2Slider
        function Tankaream2SliderValueChanged(app, event)
            value = app.Tankaream2Slider.Value;
            value=round(value,0);
            app.Tankaream2Slider.Value=value;
            
        end

        % Value changed function: OutletresistanceKSlider
        function OutletresistanceKSliderValueChanged(app, event)
            value = app.OutletresistanceKSlider.Value;
            value=round(value,0);
            app.OutletresistanceKSlider.Value=value;
            
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
            app.UIFigure.Position = [100 100 904 670];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1.6x', '1.5x', '1.2x'};
            app.GridLayout.RowHeight = {'0.4x', '0.2x', '1.8x', '0.5x', '1.5x'};

            % Create UIAxes2_2
            app.UIAxes2_2 = uiaxes(app.GridLayout);
            title(app.UIAxes2_2, 'Inlet and outlet flows')
            xlabel(app.UIAxes2_2, 'time (min)')
            ylabel(app.UIAxes2_2, 'Flow (ltr/s)')
            zlabel(app.UIAxes2_2, 'Z')
            app.UIAxes2_2.FontSize = 14;
            app.UIAxes2_2.Layout.Row = [4 5];
            app.UIAxes2_2.Layout.Column = [2 3];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout);
            title(app.UIAxes2, 'Depth responses with linear and non-linear models')
            xlabel(app.UIAxes2, 'time (min)')
            ylabel(app.UIAxes2, 'Depth (m)')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 14;
            app.UIAxes2.Layout.Row = 3;
            app.UIAxes2.Layout.Column = [2 3];

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout);
            app.GridLayout3.ColumnWidth = {'0.65x', '1x'};
            app.GridLayout3.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout3.Layout.Row = [3 4];
            app.GridLayout3.Layout.Column = 1;
            app.GridLayout3.BackgroundColor = [0.902 1 0.502];

            % Create SimulationandmodelparametersLabel
            app.SimulationandmodelparametersLabel = uilabel(app.GridLayout3);
            app.SimulationandmodelparametersLabel.BackgroundColor = [1 1 0];
            app.SimulationandmodelparametersLabel.HorizontalAlignment = 'center';
            app.SimulationandmodelparametersLabel.FontSize = 14;
            app.SimulationandmodelparametersLabel.FontWeight = 'bold';
            app.SimulationandmodelparametersLabel.Layout.Row = 1;
            app.SimulationandmodelparametersLabel.Layout.Column = [1 2];
            app.SimulationandmodelparametersLabel.Text = 'Simulation and model parameters';

            % Create InitialdepthmSliderLabel
            app.InitialdepthmSliderLabel = uilabel(app.GridLayout3);
            app.InitialdepthmSliderLabel.HorizontalAlignment = 'right';
            app.InitialdepthmSliderLabel.Layout.Row = 4;
            app.InitialdepthmSliderLabel.Layout.Column = 1;
            app.InitialdepthmSliderLabel.Text = 'Initial depth (m)';

            % Create InitialdepthmSlider
            app.InitialdepthmSlider = uislider(app.GridLayout3);
            app.InitialdepthmSlider.Limits = [0 5];
            app.InitialdepthmSlider.ValueChangedFcn = createCallbackFcn(app, @InitialdepthmSliderValueChanged2, true);
            app.InitialdepthmSlider.Layout.Row = 4;
            app.InitialdepthmSlider.Layout.Column = 2;
            app.InitialdepthmSlider.Value = 1;

            % Create InletflowltrsSliderLabel
            app.InletflowltrsSliderLabel = uilabel(app.GridLayout3);
            app.InletflowltrsSliderLabel.HorizontalAlignment = 'right';
            app.InletflowltrsSliderLabel.Layout.Row = 5;
            app.InletflowltrsSliderLabel.Layout.Column = 1;
            app.InletflowltrsSliderLabel.Text = 'Inlet flow (ltr/s)';

            % Create InletflowltrsSlider
            app.InletflowltrsSlider = uislider(app.GridLayout3);
            app.InletflowltrsSlider.Limits = [0 0.05];
            app.InletflowltrsSlider.ValueChangedFcn = createCallbackFcn(app, @InletflowltrsSliderValueChanged, true);
            app.InletflowltrsSlider.Layout.Row = 5;
            app.InletflowltrsSlider.Layout.Column = 2;
            app.InletflowltrsSlider.Value = 0.01;

            % Create DisturbanceflowltrsSlider_3Label
            app.DisturbanceflowltrsSlider_3Label = uilabel(app.GridLayout3);
            app.DisturbanceflowltrsSlider_3Label.HorizontalAlignment = 'right';
            app.DisturbanceflowltrsSlider_3Label.Layout.Row = 6;
            app.DisturbanceflowltrsSlider_3Label.Layout.Column = 1;
            app.DisturbanceflowltrsSlider_3Label.Text = 'Disturbance flow (ltr/s)';

            % Create DisturbanceflowltrsSlider_3
            app.DisturbanceflowltrsSlider_3 = uislider(app.GridLayout3);
            app.DisturbanceflowltrsSlider_3.Limits = [0 0.02];
            app.DisturbanceflowltrsSlider_3.MajorTicks = [0 0.01 0.02];
            app.DisturbanceflowltrsSlider_3.ValueChangedFcn = createCallbackFcn(app, @DisturbanceflowltrsSlider_3ValueChanged, true);
            app.DisturbanceflowltrsSlider_3.MinorTicks = [0 0.01 0.02];
            app.DisturbanceflowltrsSlider_3.Layout.Row = 6;
            app.DisturbanceflowltrsSlider_3.Layout.Column = 2;
            app.DisturbanceflowltrsSlider_3.Value = 0.01;

            % Create BlockageSliderLabel
            app.BlockageSliderLabel = uilabel(app.GridLayout3);
            app.BlockageSliderLabel.HorizontalAlignment = 'right';
            app.BlockageSliderLabel.Layout.Row = 7;
            app.BlockageSliderLabel.Layout.Column = 1;
            app.BlockageSliderLabel.Text = 'Blockage';

            % Create BlockageSlider
            app.BlockageSlider = uislider(app.GridLayout3);
            app.BlockageSlider.Limits = [0 1];
            app.BlockageSlider.ValueChangedFcn = createCallbackFcn(app, @BlockageSliderValueChanged, true);
            app.BlockageSlider.Layout.Row = 7;
            app.BlockageSlider.Layout.Column = 2;
            app.BlockageSlider.Value = 0.1;

            % Create OutletresistanceKSliderLabel
            app.OutletresistanceKSliderLabel = uilabel(app.GridLayout3);
            app.OutletresistanceKSliderLabel.HorizontalAlignment = 'right';
            app.OutletresistanceKSliderLabel.Layout.Row = 3;
            app.OutletresistanceKSliderLabel.Layout.Column = 1;
            app.OutletresistanceKSliderLabel.Text = 'Outlet resistance (K)';

            % Create OutletresistanceKSlider
            app.OutletresistanceKSlider = uislider(app.GridLayout3);
            app.OutletresistanceKSlider.ValueChangedFcn = createCallbackFcn(app, @OutletresistanceKSliderValueChanged, true);
            app.OutletresistanceKSlider.Layout.Row = 3;
            app.OutletresistanceKSlider.Layout.Column = 2;
            app.OutletresistanceKSlider.Value = 10;

            % Create Tankaream2SliderLabel
            app.Tankaream2SliderLabel = uilabel(app.GridLayout3);
            app.Tankaream2SliderLabel.HorizontalAlignment = 'right';
            app.Tankaream2SliderLabel.Layout.Row = 2;
            app.Tankaream2SliderLabel.Layout.Column = 1;
            app.Tankaream2SliderLabel.Text = 'Tank area (m^2)';

            % Create Tankaream2Slider
            app.Tankaream2Slider = uislider(app.GridLayout3);
            app.Tankaream2Slider.Limits = [0 5];
            app.Tankaream2Slider.ValueChangedFcn = createCallbackFcn(app, @Tankaream2SliderValueChanged, true);
            app.Tankaream2Slider.Layout.Row = 2;
            app.Tankaream2Slider.Layout.Column = 2;
            app.Tankaream2Slider.Value = 2;

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
            app.ImpactofnonlinearcomponentsonapositioncontrolsystemLabel.Text = 'Behaviour of a  non-linear tank model';

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
            app.GridLayout4.ColumnWidth = {'1x'};
            app.GridLayout4.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout4.Layout.Row = 1;
            app.GridLayout4.Layout.Column = 1;
            app.GridLayout4.BackgroundColor = [0.702 1 0.702];

            % Create ExternaldisturbancesredmeansnotincludedLabel
            app.ExternaldisturbancesredmeansnotincludedLabel = uilabel(app.GridLayout4);
            app.ExternaldisturbancesredmeansnotincludedLabel.BackgroundColor = [0 1 0];
            app.ExternaldisturbancesredmeansnotincludedLabel.HorizontalAlignment = 'center';
            app.ExternaldisturbancesredmeansnotincludedLabel.WordWrap = 'on';
            app.ExternaldisturbancesredmeansnotincludedLabel.FontSize = 14;
            app.ExternaldisturbancesredmeansnotincludedLabel.FontWeight = 'bold';
            app.ExternaldisturbancesredmeansnotincludedLabel.Layout.Row = 1;
            app.ExternaldisturbancesredmeansnotincludedLabel.Layout.Column = 1;
            app.ExternaldisturbancesredmeansnotincludedLabel.Text = 'External disturbances (red means not included)';

            % Create DisturbanceflowButton
            app.DisturbanceflowButton = uibutton(app.GridLayout4, 'push');
            app.DisturbanceflowButton.ButtonPushedFcn = createCallbackFcn(app, @DisturbanceflowButtonPushed, true);
            app.DisturbanceflowButton.BackgroundColor = [1 0 0];
            app.DisturbanceflowButton.FontSize = 14;
            app.DisturbanceflowButton.Layout.Row = 2;
            app.DisturbanceflowButton.Layout.Column = 1;
            app.DisturbanceflowButton.Text = 'Disturbance flow';

            % Create BlockageButton_2
            app.BlockageButton_2 = uibutton(app.GridLayout4, 'push');
            app.BlockageButton_2.ButtonPushedFcn = createCallbackFcn(app, @BlockageButton_2Pushed, true);
            app.BlockageButton_2.WordWrap = 'on';
            app.BlockageButton_2.BackgroundColor = [1 0 0];
            app.BlockageButton_2.FontSize = 14;
            app.BlockageButton_2.Layout.Row = 3;
            app.BlockageButton_2.Layout.Column = 1;
            app.BlockageButton_2.Text = 'Blockage';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = nonlinear_tank_behaviour_control101

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

