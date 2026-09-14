classdef pi_tuning < matlab.apps.AppBase
    %PI_TUNING
    %   File written by Ioannis Myrsinias (Mathworks) and J.A.Rossiter,
    %   University of Sheffield
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %       A simple interface to practice the tuning of PI compensation
    %   for a variety of models.
    %   
    %       Students can use a default model, or enter their own
    %   transferfunction.
    %       Some notes and engineering background are in the partner
    %   livescript file:    pi_tuning_manual.mlx
    %       A group of similar files can be downloaded through MATLAB
    %   add-ons with the toolbox name:  control101
    %       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %       
    %       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    FILE ORGANISATION
    %       A section defining the core variables stored in "app"
    %       
    %       A section with subfunctions doing the core computations
    %       SEE CALLBACKS IN LEFT HAND TAB
    %       1. Largely these do self-evident checks and updates when the
    %   user interacts with a slider/button/choice
    %       2. A few do computations of the closed-loop step responses and
    %   manage the animation.
    %       3. Some do interface management, such as preventing interaction
    %   while an animation is running and refreshing axes as required.
    %       4. The 'start simulation' button runs the subfunctions in turn
    %   as required to manage the animation and data updates.
    %       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        BlockdiagramPanel              matlab.ui.container.Panel
        Image3                         matlab.ui.control.Image
        GridLayout10                   matlab.ui.container.GridLayout
        ClosedlooppolesandzerosPanel   matlab.ui.container.Panel
        GridLayout15                   matlab.ui.container.GridLayout
        ClosedLoopZerosDisp            matlab.ui.control.EditField
        ClosedLoopZerosLabel           matlab.ui.control.Label
        ClosedLoopPolesDisp            matlab.ui.control.EditField
        ClosedLoopPolesLabel           matlab.ui.control.Label
        PolesZerosAxis                 matlab.ui.control.UIAxes
        GridLayout9                    matlab.ui.container.GridLayout
        GridLayout5_2                  matlab.ui.container.GridLayout
        Image                          matlab.ui.control.Image
        PIcompensatortuningpracticeLabel  matlab.ui.control.Label
        UIAxesU                        matlab.ui.control.UIAxes
        UIAxesY                        matlab.ui.control.UIAxes
        GridLayout2                    matlab.ui.container.GridLayout
        GridLayout16                   matlab.ui.container.GridLayout
        K_iSlider                      matlab.ui.control.Slider
        K_iSliderLabel                 matlab.ui.control.Label
        K_pSlider                      matlab.ui.control.Slider
        K_pLabel                       matlab.ui.control.Label
        PIcontrollerCsKpKisLabel       matlab.ui.control.Label
        GridLayout19                   matlab.ui.container.GridLayout
        SysteminputdisturbanceDsLabel  matlab.ui.control.Label
        DSlider                        matlab.ui.control.Slider
        DLabel                         matlab.ui.control.Label
        GridLayout17                   matlab.ui.container.GridLayout
        AnimationonButton              matlab.ui.control.Button
        RefreshButton                  matlab.ui.control.Button
        SimulateButton                 matlab.ui.control.Button
        GridLayout5                    matlab.ui.container.GridLayout
        TabGroup                       matlab.ui.container.TabGroup
        ExampleTab                     matlab.ui.container.Tab
        NumExample                     matlab.ui.control.EditField
        NumeratorLabel                 matlab.ui.control.Label
        DenExample                     matlab.ui.control.EditField
        DenominatorLabel               matlab.ui.control.Label
        ChoosePlantDropDown            matlab.ui.control.DropDown
        ChooseplantLabel               matlab.ui.control.Label
        CustomTab                      matlab.ui.container.Tab
        NumCustom                      matlab.ui.control.EditField
        NumEditField_3Label            matlab.ui.control.Label
        DenCustom                      matlab.ui.control.EditField
        DenEditFieldLabel              matlab.ui.control.Label
        LoadButton                     matlab.ui.control.Button
        ShowTransferFunction           matlab.ui.control.Label
        PlanttransferfunctionGsLabel   matlab.ui.control.Label
        Label                          matlab.ui.control.Label
    end

% File written by Ioannis Myrsinias (Mathworks) and J.A.Rossiter, University of Sheffield
%     See website for more files like this.
%     https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
%     A simple interface to practice the tuning of PI compensation for
%     a variety of models
%     Students can use a default model, or enter their own transfer
%     function
%     Some notes and engineering background are in the partner livescript
%     file:    pi_tuning_manual.mlx
%     A group of similar files can be downloaded through MATLAB add-ons
%     with the toolbox name:  ********************
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%  FILE ORGANISATION
%     A section defining the core variables stored in "app"
%     
%     A section with subfunctions doing the core computations
%     SEE CALLBACKS IN LEFT HAND TAB
%     1. Largely these do self-evident checks and updates when the user
%     interacts with a slider/button/choice
%     2. A few do computations of the closed-loop step responses and manage
%     the animation.
%     3. Some do interface management, such as preventing interaction while
%     an animation is running and refreshing axes as required.
%     4. The 'simulation' button runs the subfunctions in turn 
%     as required to manage the animation and data updates.
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
    
    % The next section defines all the core variables used in the code and
    % that it may be convenient to have available in the various
    % subfunctions

    properties (Access = private)
        originalsize     % product of width and height for font sizing


        Kp              % proportional coefficient of PI
        Ki              % integral coefficient of PI
        D               % disturbance
        plantTrFcn      % transfer function
        t               % time
        PI              % PI controller transfer function
        u               % controller's output
        y               % system's output
        Gc1             % closed loop transfer function
        Gc1u            % closed loop transfer function
        Gc1s            % closed loop transfer function
        Gc1us           % closed loop transfer function
        legstring       % closed loop transfer function
        numerator       % mumerator of open loop transfer function
        denumerator     % denominator of open loop transfer function
        mode            % 0 for example, 1 for custom
        endtime=5;      % default simulation runtime
        samples = 201;  % number of points in simulation
    end

    methods (Access = private)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION to define default  transfer function models
        function out = exampleTransferFcn(app,orderchoice)
            switch orderchoice
                case 'First order'
                    n=[1.6]; d = [1 2];
                case 'Second order'
                    n=[4]; d = [1 5 6];
                case 'Under-damped'
                    n=[4];
                    d = [1 2 6];
                case 'High-order'
                    n=[4 1.2]; d = [1 3 3 1];
            end
            app.updateTransferFunctionRender(n, d);
            out = tf(n,d);
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% TWO SUBFUNCTIONS to display the transfer function     

        function updateTransferFunctionRender(app,n,d)
            app.updateTextFieldFromArray(app.NumExample,n, " ",3); % 3 is the number of digits
            app.updateTextFieldFromArray(app.DenExample,d, " ",3); % 3 is the number of digits

            numerator_str = app.array2StringPolynomial(n);
            denumerator_str = app.array2StringPolynomial(d);

            app.ShowTransferFunction.Text = "$\frac{"+numerator_str+"}"+"{"+denumerator_str+"}$";

        end


        function updateTextFieldFromArray(app, field, arr, delimiter, digts)

            arr = string(round(arr,digts));
            allOneString = sprintf('%s'+delimiter, arr);
            field.Value = allOneString;


        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION TO CREATE A TEXT DISPLAY OF A POLYNOMIAL
        function auxmsgNum = array2StringPolynomial(app, n)
            lenNum = length(n);
            auxmsgNum= "";
            ind = 1;
            for i=lenNum:-1:1
                ncoef = n(ind);
                if n(ind)<0
                    prefix = '';
                else
                    prefix = '+';
                end

                if abs(n(ind))==1 && ind~=lenNum
                    ncoef=[];
                end

                if lenNum==1
                    auxmsgNum = auxmsgNum + num2str(ncoef);
                else
                    if i==lenNum && lenNum~=2
                        auxmsgNum = auxmsgNum + num2str(ncoef) +"s^"+num2str(i-1);

                    elseif i==lenNum && lenNum==2
                        auxmsgNum = auxmsgNum + num2str(ncoef) +"s";

                    elseif i == 1

                        auxmsgNum = auxmsgNum + prefix+ num2str(ncoef);

                    elseif i==2
                        auxmsgNum = auxmsgNum + prefix+ num2str(ncoef) +"s";

                    else
                        auxmsgNum = auxmsgNum + prefix +num2str(ncoef) +"s^"+num2str(i-1);
                    end
                end
                ind = ind + 1;
            end
        end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION TO CREATE CLOSED-LOOP TRANSFER FUNCTIONS 
%%%%%%       (for target and disturbance resposnes) AND
%%%%%%%%%%%% COMPUTE POLES AND ZEROS
        function updateControlProperties(app)

            app.Gc1 = feedback(app.plantTrFcn*app.PI,1);
            app.Gc1u = feedback(app.PI,app.plantTrFcn);
            app.Gc1s = feedback(app.plantTrFcn,app.PI);
            app.Gc1us = feedback(1,app.plantTrFcn*app.PI);
            [p,z] = pzmap(app.Gc1);

            zReal = round(real(z),3,'significant');
            zImag = round(imag(z),3,'significant');
            pReal = round(real(p),3,'significant');
            pImag = round(imag(p),3,'significant');

            p=pReal+j*pImag;
            z=zReal+j*zImag;

            app.updateTextFieldFromArray(app.ClosedLoopPolesDisp, p',"\t", 3)
            app.updateTextFieldFromArray(app.ClosedLoopZerosDisp, z', "\t", 3)
            app.updatePoleZeroPlot(p, z)

        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION TO UPDATE POLE/ZERO PLOT AND NUMERICAL DISPLAY
        function updatePoleZeroPlot(app, p, z)

            zReal = round(real(z),3,'significant');
            zImag = round(imag(z),3,'significant');
            pReal = round(real(p),3,'significant');
            pImag = round(imag(p),3,'significant');

            plot(app.PolesZerosAxis, pReal, pImag,"x", zReal, zImag,"o", "MarkerSize",15);

        end
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Control interaction during the animation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function disablebuttons(app)
            set(app.SimulateButton, 'Enable', 'off');
            set(app.RefreshButton, 'Enable', 'off')
            set(app.K_pSlider, 'Enable', 'off')
            set(app.K_iSlider, 'Enable', 'off')
            set(app.ChoosePlantDropDown, 'Enable', 'off')
            set(app.LoadButton, 'Enable', 'off')
            set(app.DSlider, 'Enable', 'off')
            set(app.NumCustom, 'Enable', 'off')
            set(app.DenCustom, 'Enable', 'off')
            set(app.AnimationonButton, 'Enable', 'off')
        end
        
        function enablebuttons(app)
            set(app.SimulateButton, 'Enable', 'on');
            set(app.RefreshButton, 'Enable', 'on')
            set(app.K_pSlider, 'Enable', 'on')
            set(app.K_iSlider, 'Enable', 'on')
            set(app.ChoosePlantDropDown, 'Enable', 'on')
            set(app.LoadButton, 'Enable', 'on')
            set(app.DSlider, 'Enable', 'on')
            set(app.NumCustom, 'Enable', 'on')
            set(app.DenCustom, 'Enable', 'on')
            set(app.AnimationonButton, 'Enable', 'on')
        end
    end
    %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTIONS BELOW ACT WHEN A COMPONENT IS SELECTED IN THE
%%%%%%%%%%%% INTERFACE. LARGELY THE CODE IS MINIMAL AND SELF-EXPLANATORY

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % resize to be in middle of  the window
            movegui(app.UIFigure)
            
            % Open the manual
            if exist('pi_tuning_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open pi_tuning_mycopy.mlx
            else
                p1 = which('pi_tuning_manual.mlx');
                p2 = strcat(pwd,'/pi_tuning_mycopy.mlx');
                copyfile(p1,p2)                
                open pi_tuning_mycopy.mlx
                clear p1 p2
            end
                       
            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);

            app.Kp = app.K_pSlider.Value;
            app.Ki = app.K_iSlider.Value;
            app.t = linspace(0,app.endtime,app.samples);
            app.D = app.DSlider.Value;
            app.mode = 0;
            model = app.ChoosePlantDropDown.Value;
            app.plantTrFcn = app.exampleTransferFcn(model);
            app.PI = tf([app.Kp,app.Ki],[1 0]);
            app.legstring = cell(1);
            app.updateControlProperties()
            set(app.SimulateButton, 'Enable', 'on')
            set(app.LoadButton, 'Enable', 'off')
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
                theme(app.UIFigure,"light")
            end


        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% MOST IMPORTANT SUBFUNCTION 
% DOWNLOADS RELEVANT DATA FROM ALL THE USER CHOICES, CREATES TRANSFER
% FUNCTION MODELS AND THEN
% CALCULATES THE BASIC STEP RESPONSES AND MANAGES THE FIGURES AND
% ANIMATIONS
            
            % Prevent unhelpful interaction during simulation
            disablebuttons(app); % switch interaction off
            
            % collect model data
            if app.mode==0
                model = app.ChoosePlantDropDown.Value;
            end
            app.updateControlProperties();

            % calculation of responses in time (to disturbances and
            % targets)
            h=step(app.Gc1,app.t);
            u=step(app.Gc1u,app.t);
            ys=step(app.Gc1s,app.t);
            ys = ys *app.D;
            us=step(app.Gc1us,app.t);
            us = us*app.D;
            ys = [zeros(100,1);ys(1:(app.samples-100))];  %% delay disturbance by 100 samples
            us = [zeros(100,1);us(1:(app.samples-100))];
            dist2 = [zeros(100,1);ones((app.samples-100),1)*app.D];

            % Initialise the legend for the plots
            if isempty(app.legstring{1})
                nlegstring=0;
                app.legstring{1}='target/disturbance';
                plot(app.UIAxesY,[0,app.endtime],[1,1],'g--',"LineWidth",2);
                plot(app.UIAxesU,app.t,dist2,'g--',"LineWidth",2);
            else

            end
            nlegstring = length(app.legstring);
            app.legstring{nlegstring+1}=['Kp = ',num2str(app.Kp),', Ki = ',num2str(app.Ki),', d = ',num2str(app.D)];


            %%%% initialise output plots
            hold(app.UIAxesY,'on')
            yplot = plot(app.UIAxesY,app.t(1),h(1)+ys(1));  % dynamic line plot of depth
            % NO LEGEND ON OUTPUT PLOT - USE INPUT PLOT ONLY
            
            %%%% initialise input plots + disturbance
            hold(app.UIAxesU,'on')
            uplot = plot(app.UIAxesU,app.t(1),u(1)+us(1));  % dynamic line plot of depth
            kb=legend(app.UIAxesU,app.legstring,'Location','southeast','fontsize',8);
            set(kb,'fontsize',10);

            %%%%% Animation part %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            for k=1:length(app.t)

                set(yplot,'Ydata',h(1:k)+ys(1:k),'Xdata',app.t(1:k));  % update depth response
                set(uplot,'Ydata',u(1:k)+us(1:k),'Xdata',app.t(1:k));  % update depth response
                
                
                if strcmp(app.AnimationonButton.Text,'Animation on');
                    pause(0.005);  %% Clumsy application of sampling time
                    drawnow limitrate    
                end     
                
                
            end

            enablebuttons(app);  %switch interaction back on

        end

        % Value changed function: K_pSlider
        function K_pSliderValueChanged(app, event)
            app.Kp = app.K_pSlider.Value;
            app.Kp=round(app.Kp,2,'significant'); % round to 1 decimal place
            app.K_pSlider.Value=app.Kp;
            app.PI = tf([app.Kp,app.Ki],[1 0]);
            app.updateControlProperties()
            set(app.SimulateButton, 'Enable', 'on')

            updateControlProperties(app);

        end

        % Value changed function: K_iSlider
        function K_iSliderValueChanged(app, event)
            app.Ki = app.K_iSlider.Value;
            app.Ki=round(app.Ki,2,'significant'); % round to 1 decimal place
            app.K_iSlider.Value=app.Ki;
            app.PI = tf([app.Kp,app.Ki],[1 0]);
            app.updateControlProperties()
            set(app.SimulateButton, 'Enable', 'on')

            updateControlProperties(app);

        end

        % Value changed function: DSlider
        function DSliderValueChanged(app, event)
            app.D = app.DSlider.Value;
            app.D=round(app.D,2); % round to 2 decimal place
            app.DSlider.Value=app.D;
            set(app.SimulateButton, 'Enable', 'on')

        end

        % Value changed function: ChoosePlantDropDown
        function ChoosePlantDropDownValueChanged(app, event)
            set(app.SimulateButton, 'Enable', 'on')

            value = app.ChoosePlantDropDown.Value;
            app.plantTrFcn = app.exampleTransferFcn(value);
            app.updateControlProperties();
            app.mode = 0;
        end

        % Button pushed function: RefreshButton
        function RefreshButtonPushed(app, event)
%%%%%%%%%%%% Cleans figures and legend so can begin again
            hold(app.UIAxesY,'off')
            hold(app.UIAxesU,'off')

            plot(app.UIAxesU,0,0)
            plot(app.UIAxesY,0,0)

            legend(app.UIAxesU, 'off')
            legend(app.UIAxesY, 'off')

            app.startupFcn()
        end

        % Value changed function: NumCustom
        function NumCustomValueChanged(app, event)
            value = app.NumCustom.Value;
            app.numerator=str2num(value);
            app.updateTransferFunctionRender(app.numerator,app.denumerator);
            app.mode=1;
            set(app.SimulateButton, 'Enable', 'on');
            set(app.LoadButton, 'Enable', 'on');


        end

        % Value changed function: DenCustom
        function DenCustomValueChanged(app, event)
            value = app.DenCustom.Value;
            app.denumerator=str2num(value);
            app.updateTransferFunctionRender(app.numerator,app.denumerator);
            app.mode=1;
            set(app.SimulateButton, 'Enable', 'on')
            set(app.LoadButton, 'Enable', 'on')

        end

        % Button pushed function: LoadButton
        function LoadButtonPushed(app, event)
            set(app.LoadButton, 'Enable', 'off')
            n = app.numerator;
            d = app.denumerator;
            app.plantTrFcn = tf(n,d);
            app.mode=1;
            app.updateControlProperties();

        end

        % Button pushed function: AnimationonButton
        function AnimationonButtonPushed(app, event)
            val = app.AnimationonButton.Text;
            if strcmp(val,'Animation on');
                val = 'Animation off';
            else
                val = 'Animation on';
            end
            app.AnimationonButton.Text=val;
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
            app.UIFigure.Position = [100 100 1290 839];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1.5x'};
            app.GridLayout.RowHeight = {'3x', '1x'};
            app.GridLayout.Scrollable = 'on';

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x'};
            app.GridLayout2.RowHeight = {'2x', '5x', '4x', '3x'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = 1;

            % Create Label
            app.Label = uilabel(app.GridLayout2);
            app.Label.HorizontalAlignment = 'center';
            app.Label.Layout.Row = 3;
            app.Label.Layout.Column = 1;
            app.Label.Text = '';

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout2);
            app.GridLayout5.ColumnWidth = {'1x', '0.6x'};
            app.GridLayout5.RowHeight = {'1x', '4x', '1x'};
            app.GridLayout5.ColumnSpacing = 0;
            app.GridLayout5.RowSpacing = 0;
            app.GridLayout5.Layout.Row = 2;
            app.GridLayout5.Layout.Column = 1;
            app.GridLayout5.Scrollable = 'on';
            app.GridLayout5.BackgroundColor = [0.902 1 0.502];

            % Create PlanttransferfunctionGsLabel
            app.PlanttransferfunctionGsLabel = uilabel(app.GridLayout5);
            app.PlanttransferfunctionGsLabel.BackgroundColor = [1 1 0];
            app.PlanttransferfunctionGsLabel.HorizontalAlignment = 'center';
            app.PlanttransferfunctionGsLabel.FontSize = 16;
            app.PlanttransferfunctionGsLabel.FontWeight = 'bold';
            app.PlanttransferfunctionGsLabel.Layout.Row = 1;
            app.PlanttransferfunctionGsLabel.Layout.Column = [1 2];
            app.PlanttransferfunctionGsLabel.Text = 'Plant transfer function G(s)';

            % Create ShowTransferFunction
            app.ShowTransferFunction = uilabel(app.GridLayout5);
            app.ShowTransferFunction.BackgroundColor = [0.902 1 0.502];
            app.ShowTransferFunction.HorizontalAlignment = 'center';
            app.ShowTransferFunction.FontSize = 16;
            app.ShowTransferFunction.Layout.Row = 2;
            app.ShowTransferFunction.Layout.Column = 2;
            app.ShowTransferFunction.Interpreter = 'latex';
            app.ShowTransferFunction.Text = '$\frac{s}{s+1}$';

            % Create LoadButton
            app.LoadButton = uibutton(app.GridLayout5, 'push');
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @LoadButtonPushed, true);
            app.LoadButton.FontSize = 14;
            app.LoadButton.Layout.Row = 3;
            app.LoadButton.Layout.Column = 2;
            app.LoadButton.Text = 'Load';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout5);
            app.TabGroup.AutoResizeChildren = 'off';
            app.TabGroup.Layout.Row = [2 3];
            app.TabGroup.Layout.Column = 1;

            % Create ExampleTab
            app.ExampleTab = uitab(app.TabGroup);
            app.ExampleTab.AutoResizeChildren = 'off';
            app.ExampleTab.Title = 'Example';
            app.ExampleTab.BackgroundColor = [0.902 1 0.502];
            app.ExampleTab.Scrollable = 'on';

            % Create ChooseplantLabel
            app.ChooseplantLabel = uilabel(app.ExampleTab);
            app.ChooseplantLabel.FontSize = 14;
            app.ChooseplantLabel.Position = [2 79 88 22];
            app.ChooseplantLabel.Text = 'Choose plant';

            % Create ChoosePlantDropDown
            app.ChoosePlantDropDown = uidropdown(app.ExampleTab);
            app.ChoosePlantDropDown.Items = {'First order', 'Second order', 'Under-damped', 'High-order'};
            app.ChoosePlantDropDown.ValueChangedFcn = createCallbackFcn(app, @ChoosePlantDropDownValueChanged, true);
            app.ChoosePlantDropDown.Position = [99 79 100 22];
            app.ChoosePlantDropDown.Value = 'First order';

            % Create DenominatorLabel
            app.DenominatorLabel = uilabel(app.ExampleTab);
            app.DenominatorLabel.HorizontalAlignment = 'right';
            app.DenominatorLabel.Enable = 'off';
            app.DenominatorLabel.Position = [10 25 74 22];
            app.DenominatorLabel.Text = 'Denominator';

            % Create DenExample
            app.DenExample = uieditfield(app.ExampleTab, 'text');
            app.DenExample.Editable = 'off';
            app.DenExample.Enable = 'off';
            app.DenExample.Position = [99 25 126 22];
            app.DenExample.Value = '1 1';

            % Create NumeratorLabel
            app.NumeratorLabel = uilabel(app.ExampleTab);
            app.NumeratorLabel.HorizontalAlignment = 'right';
            app.NumeratorLabel.Enable = 'off';
            app.NumeratorLabel.Position = [21 53 62 22];
            app.NumeratorLabel.Text = 'Numerator';

            % Create NumExample
            app.NumExample = uieditfield(app.ExampleTab, 'text');
            app.NumExample.Editable = 'off';
            app.NumExample.Enable = 'off';
            app.NumExample.Position = [98 53 127 22];
            app.NumExample.Value = '1 0';

            % Create CustomTab
            app.CustomTab = uitab(app.TabGroup);
            app.CustomTab.AutoResizeChildren = 'off';
            app.CustomTab.Title = 'Custom';

            % Create DenEditFieldLabel
            app.DenEditFieldLabel = uilabel(app.CustomTab);
            app.DenEditFieldLabel.HorizontalAlignment = 'right';
            app.DenEditFieldLabel.Position = [21 30 27 22];
            app.DenEditFieldLabel.Text = 'Den';

            % Create DenCustom
            app.DenCustom = uieditfield(app.CustomTab, 'text');
            app.DenCustom.ValueChangedFcn = createCallbackFcn(app, @DenCustomValueChanged, true);
            app.DenCustom.Position = [63 30 100 22];

            % Create NumEditField_3Label
            app.NumEditField_3Label = uilabel(app.CustomTab);
            app.NumEditField_3Label.HorizontalAlignment = 'right';
            app.NumEditField_3Label.Position = [19 68 30 22];
            app.NumEditField_3Label.Text = 'Num';

            % Create NumCustom
            app.NumCustom = uieditfield(app.CustomTab, 'text');
            app.NumCustom.ValueChangedFcn = createCallbackFcn(app, @NumCustomValueChanged, true);
            app.NumCustom.Position = [64 68 100 22];

            % Create GridLayout17
            app.GridLayout17 = uigridlayout(app.GridLayout2);
            app.GridLayout17.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout17.RowHeight = {'1x'};
            app.GridLayout17.Layout.Row = 1;
            app.GridLayout17.Layout.Column = 1;
            app.GridLayout17.BackgroundColor = [1 0.6 0.8];

            % Create SimulateButton
            app.SimulateButton = uibutton(app.GridLayout17, 'push');
            app.SimulateButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateButtonPushed, true);
            app.SimulateButton.BackgroundColor = [1 0.2 0.702];
            app.SimulateButton.FontSize = 20;
            app.SimulateButton.FontWeight = 'bold';
            app.SimulateButton.Layout.Row = 1;
            app.SimulateButton.Layout.Column = 1;
            app.SimulateButton.Text = 'Simulate';

            % Create RefreshButton
            app.RefreshButton = uibutton(app.GridLayout17, 'push');
            app.RefreshButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshButtonPushed, true);
            app.RefreshButton.BackgroundColor = [1 0.2 0.702];
            app.RefreshButton.FontSize = 20;
            app.RefreshButton.FontWeight = 'bold';
            app.RefreshButton.Layout.Row = 1;
            app.RefreshButton.Layout.Column = 2;
            app.RefreshButton.Text = 'Refresh';

            % Create AnimationonButton
            app.AnimationonButton = uibutton(app.GridLayout17, 'push');
            app.AnimationonButton.ButtonPushedFcn = createCallbackFcn(app, @AnimationonButtonPushed, true);
            app.AnimationonButton.WordWrap = 'on';
            app.AnimationonButton.BackgroundColor = [1 0.2 0.702];
            app.AnimationonButton.FontSize = 20;
            app.AnimationonButton.FontWeight = 'bold';
            app.AnimationonButton.Layout.Row = 1;
            app.AnimationonButton.Layout.Column = 3;
            app.AnimationonButton.Text = 'Animation on';

            % Create GridLayout19
            app.GridLayout19 = uigridlayout(app.GridLayout2);
            app.GridLayout19.ColumnWidth = {'0.5x', '1.5x'};
            app.GridLayout19.Layout.Row = 4;
            app.GridLayout19.Layout.Column = 1;
            app.GridLayout19.BackgroundColor = [0.702 1 0.702];

            % Create DLabel
            app.DLabel = uilabel(app.GridLayout19);
            app.DLabel.HorizontalAlignment = 'center';
            app.DLabel.FontSize = 14;
            app.DLabel.Layout.Row = 2;
            app.DLabel.Layout.Column = 1;
            app.DLabel.Interpreter = 'latex';
            app.DLabel.Text = '$D$';

            % Create DSlider
            app.DSlider = uislider(app.GridLayout19);
            app.DSlider.Limits = [0 0.2];
            app.DSlider.MajorTicks = [0 0.05 0.1 0.15 0.2];
            app.DSlider.ValueChangedFcn = createCallbackFcn(app, @DSliderValueChanged, true);
            app.DSlider.FontSize = 14;
            app.DSlider.Layout.Row = 2;
            app.DSlider.Layout.Column = 2;
            app.DSlider.Value = 0.1;

            % Create SysteminputdisturbanceDsLabel
            app.SysteminputdisturbanceDsLabel = uilabel(app.GridLayout19);
            app.SysteminputdisturbanceDsLabel.BackgroundColor = [0 1 0];
            app.SysteminputdisturbanceDsLabel.HorizontalAlignment = 'center';
            app.SysteminputdisturbanceDsLabel.FontSize = 16;
            app.SysteminputdisturbanceDsLabel.FontWeight = 'bold';
            app.SysteminputdisturbanceDsLabel.Layout.Row = 1;
            app.SysteminputdisturbanceDsLabel.Layout.Column = [1 2];
            app.SysteminputdisturbanceDsLabel.Text = 'System input disturbance D(s)';

            % Create GridLayout16
            app.GridLayout16 = uigridlayout(app.GridLayout2);
            app.GridLayout16.ColumnWidth = {'1x', '3x'};
            app.GridLayout16.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout16.Layout.Row = 3;
            app.GridLayout16.Layout.Column = 1;
            app.GridLayout16.BackgroundColor = [1 0.8 0.6];

            % Create PIcontrollerCsKpKisLabel
            app.PIcontrollerCsKpKisLabel = uilabel(app.GridLayout16);
            app.PIcontrollerCsKpKisLabel.BackgroundColor = [1 0.502 0.302];
            app.PIcontrollerCsKpKisLabel.HorizontalAlignment = 'center';
            app.PIcontrollerCsKpKisLabel.FontSize = 16;
            app.PIcontrollerCsKpKisLabel.FontWeight = 'bold';
            app.PIcontrollerCsKpKisLabel.Layout.Row = 1;
            app.PIcontrollerCsKpKisLabel.Layout.Column = [1 2];
            app.PIcontrollerCsKpKisLabel.Text = 'PI controller C(s) = Kp+Ki/s';

            % Create K_pLabel
            app.K_pLabel = uilabel(app.GridLayout16);
            app.K_pLabel.HorizontalAlignment = 'center';
            app.K_pLabel.FontSize = 14;
            app.K_pLabel.Layout.Row = 2;
            app.K_pLabel.Layout.Column = 1;
            app.K_pLabel.Interpreter = 'latex';
            app.K_pLabel.Text = '$K_p$';

            % Create K_pSlider
            app.K_pSlider = uislider(app.GridLayout16);
            app.K_pSlider.Limits = [0 4];
            app.K_pSlider.MajorTicks = [0 1 2 3 4];
            app.K_pSlider.ValueChangedFcn = createCallbackFcn(app, @K_pSliderValueChanged, true);
            app.K_pSlider.FontSize = 14;
            app.K_pSlider.Layout.Row = 2;
            app.K_pSlider.Layout.Column = 2;
            app.K_pSlider.Value = 1.4;

            % Create K_iSliderLabel
            app.K_iSliderLabel = uilabel(app.GridLayout16);
            app.K_iSliderLabel.HorizontalAlignment = 'center';
            app.K_iSliderLabel.FontSize = 14;
            app.K_iSliderLabel.Layout.Row = 3;
            app.K_iSliderLabel.Layout.Column = 1;
            app.K_iSliderLabel.Interpreter = 'latex';
            app.K_iSliderLabel.Text = '$K_i$';

            % Create K_iSlider
            app.K_iSlider = uislider(app.GridLayout16);
            app.K_iSlider.Limits = [0 4];
            app.K_iSlider.MajorTicks = [0 1 2 3 4];
            app.K_iSlider.MajorTickLabels = {'0', '1', '2', '3', '4'};
            app.K_iSlider.ValueChangedFcn = createCallbackFcn(app, @K_iSliderValueChanged, true);
            app.K_iSlider.FontSize = 14;
            app.K_iSlider.Layout.Row = 3;
            app.K_iSlider.Layout.Column = 2;
            app.K_iSlider.Value = 1.3;

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.GridLayout);
            app.GridLayout9.ColumnWidth = {'1x', '0.4x'};
            app.GridLayout9.RowHeight = {'0.3x', '1x', '1x'};
            app.GridLayout9.ColumnSpacing = 0;
            app.GridLayout9.RowSpacing = 0;
            app.GridLayout9.Padding = [0 0 0 0];
            app.GridLayout9.Layout.Row = 1;
            app.GridLayout9.Layout.Column = 2;

            % Create UIAxesY
            app.UIAxesY = uiaxes(app.GridLayout9);
            title(app.UIAxesY, 'Output response')
            xlabel(app.UIAxesY, 'Time(s)')
            ylabel(app.UIAxesY, 'y(t)')
            zlabel(app.UIAxesY, 'Z')
            app.UIAxesY.XGrid = 'on';
            app.UIAxesY.YGrid = 'on';
            app.UIAxesY.FontSize = 16;
            app.UIAxesY.Layout.Row = 2;
            app.UIAxesY.Layout.Column = [1 2];

            % Create UIAxesU
            app.UIAxesU = uiaxes(app.GridLayout9);
            title(app.UIAxesU, 'Input response')
            xlabel(app.UIAxesU, 'Time (s)')
            ylabel(app.UIAxesU, 'u(t)')
            zlabel(app.UIAxesU, 'Z')
            app.UIAxesU.XGrid = 'on';
            app.UIAxesU.YGrid = 'on';
            app.UIAxesU.FontSize = 16;
            app.UIAxesU.Layout.Row = 3;
            app.UIAxesU.Layout.Column = [1 2];

            % Create GridLayout5_2
            app.GridLayout5_2 = uigridlayout(app.GridLayout9);
            app.GridLayout5_2.ColumnWidth = {'1.8x', '1x'};
            app.GridLayout5_2.RowHeight = {'1x'};
            app.GridLayout5_2.Layout.Row = 1;
            app.GridLayout5_2.Layout.Column = [1 2];
            app.GridLayout5_2.BackgroundColor = [0.6 1 1];

            % Create PIcompensatortuningpracticeLabel
            app.PIcompensatortuningpracticeLabel = uilabel(app.GridLayout5_2);
            app.PIcompensatortuningpracticeLabel.BackgroundColor = [0 1 1];
            app.PIcompensatortuningpracticeLabel.HorizontalAlignment = 'center';
            app.PIcompensatortuningpracticeLabel.FontSize = 24;
            app.PIcompensatortuningpracticeLabel.FontWeight = 'bold';
            app.PIcompensatortuningpracticeLabel.Layout.Row = 1;
            app.PIcompensatortuningpracticeLabel.Layout.Column = 1;
            app.PIcompensatortuningpracticeLabel.Text = 'PI compensator tuning practice';

            % Create Image
            app.Image = uiimage(app.GridLayout5_2);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 2;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'UoSlogo.png');

            % Create GridLayout10
            app.GridLayout10 = uigridlayout(app.GridLayout);
            app.GridLayout10.ColumnWidth = {'1x', '1.2x'};
            app.GridLayout10.RowHeight = {'1x'};
            app.GridLayout10.Padding = [0 0 0 0];
            app.GridLayout10.Layout.Row = 2;
            app.GridLayout10.Layout.Column = 2;
            app.GridLayout10.BackgroundColor = [0.902 0.702 1];

            % Create PolesZerosAxis
            app.PolesZerosAxis = uiaxes(app.GridLayout10);
            title(app.PolesZerosAxis, 'Closed-loop poles and zeros')
            xlabel(app.PolesZerosAxis, 'Real')
            ylabel(app.PolesZerosAxis, 'Imaginary')
            zlabel(app.PolesZerosAxis, 'Z')
            app.PolesZerosAxis.XGrid = 'on';
            app.PolesZerosAxis.YGrid = 'on';
            app.PolesZerosAxis.FontSize = 16;
            app.PolesZerosAxis.Layout.Row = 1;
            app.PolesZerosAxis.Layout.Column = 2;

            % Create ClosedlooppolesandzerosPanel
            app.ClosedlooppolesandzerosPanel = uipanel(app.GridLayout10);
            app.ClosedlooppolesandzerosPanel.AutoResizeChildren = 'off';
            app.ClosedlooppolesandzerosPanel.TitlePosition = 'centertop';
            app.ClosedlooppolesandzerosPanel.Title = 'Closed-loop poles and zeros';
            app.ClosedlooppolesandzerosPanel.BackgroundColor = [0.902 0.2 1];
            app.ClosedlooppolesandzerosPanel.Layout.Row = 1;
            app.ClosedlooppolesandzerosPanel.Layout.Column = 1;
            app.ClosedlooppolesandzerosPanel.FontWeight = 'bold';
            app.ClosedlooppolesandzerosPanel.FontSize = 16;

            % Create GridLayout15
            app.GridLayout15 = uigridlayout(app.ClosedlooppolesandzerosPanel);
            app.GridLayout15.ColumnWidth = {'0.4x', '1x', '1x'};
            app.GridLayout15.Scrollable = 'on';
            app.GridLayout15.BackgroundColor = [0.902 0.702 1];

            % Create ClosedLoopPolesLabel
            app.ClosedLoopPolesLabel = uilabel(app.GridLayout15);
            app.ClosedLoopPolesLabel.FontSize = 14;
            app.ClosedLoopPolesLabel.Layout.Row = 1;
            app.ClosedLoopPolesLabel.Layout.Column = 1;
            app.ClosedLoopPolesLabel.Text = 'Poles';

            % Create ClosedLoopPolesDisp
            app.ClosedLoopPolesDisp = uieditfield(app.GridLayout15, 'text');
            app.ClosedLoopPolesDisp.Editable = 'off';
            app.ClosedLoopPolesDisp.FontSize = 14;
            app.ClosedLoopPolesDisp.Layout.Row = 1;
            app.ClosedLoopPolesDisp.Layout.Column = [2 3];

            % Create ClosedLoopZerosLabel
            app.ClosedLoopZerosLabel = uilabel(app.GridLayout15);
            app.ClosedLoopZerosLabel.FontSize = 14;
            app.ClosedLoopZerosLabel.Layout.Row = 2;
            app.ClosedLoopZerosLabel.Layout.Column = 1;
            app.ClosedLoopZerosLabel.Text = 'Zeros';

            % Create ClosedLoopZerosDisp
            app.ClosedLoopZerosDisp = uieditfield(app.GridLayout15, 'text');
            app.ClosedLoopZerosDisp.Editable = 'off';
            app.ClosedLoopZerosDisp.Layout.Row = 2;
            app.ClosedLoopZerosDisp.Layout.Column = [2 3];

            % Create BlockdiagramPanel
            app.BlockdiagramPanel = uipanel(app.GridLayout);
            app.BlockdiagramPanel.AutoResizeChildren = 'off';
            app.BlockdiagramPanel.TitlePosition = 'centertop';
            app.BlockdiagramPanel.Title = 'Block diagram';
            app.BlockdiagramPanel.BackgroundColor = [0.902 1 0.6];
            app.BlockdiagramPanel.Layout.Row = 2;
            app.BlockdiagramPanel.Layout.Column = 1;
            app.BlockdiagramPanel.FontWeight = 'bold';
            app.BlockdiagramPanel.FontSize = 16;

            % Create Image3
            app.Image3 = uiimage(app.BlockdiagramPanel);
            app.Image3.Position = [4 16 440 161];
            app.Image3.ImageSource = fullfile(pathToMLAPP, 'blockdiagram.jpg');

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = pi_tuning

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

