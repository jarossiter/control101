classdef mpctfilter_control101 < matlab.apps.AppBase
    %MPCTFILTER_CONTROL101
    %   This is a simple interface to understand and investigate how the
    %   core parameters within an MPC law affect the decision making and
    %   performance. Specifically the focus here is the role of the
    %   T-filter for improving the sensitivity to uncertainty.

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        GridLayout8                   matlab.ui.container.GridLayout
        GridLayout7                   matlab.ui.container.GridLayout
        UncertaintyDropDown           matlab.ui.control.DropDown
        UncertaintyDropDownLabel      matlab.ui.control.Label
        DisturbancesDropDown          matlab.ui.control.DropDown
        DisturbancesDropDownLabel     matlab.ui.control.Label
        ModelchoiceDropDown           matlab.ui.control.DropDown
        ModelchoiceDropDownLabel      matlab.ui.control.Label
        ConfigurationLabel            matlab.ui.control.Label
        GridLayout3                   matlab.ui.container.GridLayout
        NoisevarianceSlider           matlab.ui.control.Slider
        NoisevarianceSliderLabel      matlab.ui.control.Label
        TfilterorderSlider            matlab.ui.control.Slider
        TfilterorderSliderLabel       matlab.ui.control.Label
        TfilterpoleSlider             matlab.ui.control.Slider
        TfilterpoleSliderLabel        matlab.ui.control.Label
        Weightingpower10pSlider       matlab.ui.control.Slider
        Weightingpower10pSliderLabel  matlab.ui.control.Label
        ControlhorizonSlider          matlab.ui.control.Slider
        ControlhorizonSliderLabel     matlab.ui.control.Label
        PredictionhorizonSlider       matlab.ui.control.Slider
        PredictionhorizonSliderLabel  matlab.ui.control.Label
        ControllersettingsLabel       matlab.ui.control.Label
        GridLayout5                   matlab.ui.container.GridLayout
        RefreshButton                 matlab.ui.control.Button
        SimulateButton                matlab.ui.control.Button
        GridLayout4                   matlab.ui.container.GridLayout
        GridLayout9                   matlab.ui.container.GridLayout
        RuntimecostEditField          matlab.ui.control.NumericEditField
        RuntimecostEditFieldLabel     matlab.ui.control.Label
        Image                         matlab.ui.control.Image
        GPCwithaTfilterLabel          matlab.ui.control.Label
        UIAxes4                       matlab.ui.control.UIAxes
        UIAxes2                       matlab.ui.control.UIAxes
        UIAxes4_2                     matlab.ui.control.UIAxes
        UIAxes2_2                     matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        originalsize % Description
        
        legstring=cell(1)
        nlegstring=1;
    end
    
    methods (Access = private)
        
        function  disablebuttons(app)
            set(app.SimulateButton,'Enable','off')
            set(app.ModelchoiceDropDown, 'Enable', 'off');
             set(app.DisturbancesDropDown, 'Enable', 'off');
            set(app.UncertaintyDropDown, 'Enable', 'off');
            
        end
        
        function enablebuttons(app)
            set(app.SimulateButton,'Enable','on')
            set(app.ModelchoiceDropDown, 'Enable', 'on');
             set(app.DisturbancesDropDown, 'Enable', 'on');
            set(app.UncertaintyDropDown, 'Enable', 'on');
        end


        % Forms optimal MPC control law and the associated predictions at
        % the current sample
        function [Duopt,uopt,ypredall,ypred] = getpredictions(app,a,b,ny,nu,lambda,ny2,y,Du,r,u,k)
            
            na = length(a);
            nb=length(b);
            [H,P,Q] = mpc_predmat_toeplitz_control101(a,b,ny);   % pred over horizon
            [H2,P2,Q2] = mpc_predmat_toeplitz_control101(a,b,ny2);   % full prediction
            HH=tril(ones(nu,nu));
            [Nk,Dk,Pr,S,X,Prlong] = mpc_law_control101(H,P,Q,nu,lambda,1,1);
            
            % Find input and output prediction
            ypast=y(k:-1:k-na+1)';
            Dupast = Du(k-1:-1:k-nb+1)';
            Duopt = Pr*r(k+1) -Nk*ypast-Dk*Dupast;
            uopt=HH*Duopt+u(k-1);
            ypredall = H2(:,1:nu)*Duopt+Q2*ypast+P2*Dupast;
            ypred = H(:,1:nu)*Duopt+Q*ypast+P*Dupast;
            
        end

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.UIFigure.AutoResizeChildren='off';   
            movegui(app.UIFigure)
            
            % Open the manual
            if exist('mpctfilter_control101_manual_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open mpctfilter_control101_manual_mycopy.mlx
            else
                p1 = which('mpctfilter_control101_manual.mlx');
                p2 = strcat(pwd,'/mpctfilter_control101_manual_mycopy.mlx');
                copyfile(p1,p2)
                open mpctfilter_control101_manual_mycopy.mlx
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

        % Button pushed function: RefreshButton
        function RefreshButtonPushed(app, event)
            app.legstring=cell(1);
            app.legstring{1}='Reference';
            app.nlegstring=1;
            hold(app.UIAxes2,'off');
            plot(app.UIAxes2,1,1,'w')
            hold(app.UIAxes4,'off')
            plot(app.UIAxes4,1,1,'w')            
        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
           

            % Controller settings and external signals
            ny=app.PredictionhorizonSlider.Value;
            nu=app.ControlhorizonSlider.Value;
            lambda = 10^(app.Weightingpower10pSlider.Value);
            runtime=100;
            init=5;
            ref = [zeros(1,init),ones(1,runtime-init)];
            dist=[zeros(1,init+2),ones(1,runtime-init-2)*0.2];
            noise = randn(1,runtime)*app.NoisevarianceSlider.Value;
                      
            Tfilter=[1,-app.TfilterpoleSlider.Value];
            Tfilterstring=['1,',num2str(Tfilter(2))];

            if app.TfilterorderSlider.Value==2;
                Tfilter = conv(Tfilter,Tfilter);
                Tfilterstring=['1,',num2str(Tfilter(2)),',',num2str(Tfilter(3))];
            end
            if app.TfilterorderSlider.Value==3;
                Tfilter = conv(conv(Tfilter,Tfilter),Tfilter);
                Tfilterstring=['1,',num2str(Tfilter(2)),',',num2str(Tfilter(3)),...
                    ',',num2str(Tfilter(4))];
            end

            tt=1:30;
            % Check for no disturbances
            disttext=', dist=N, ';
            if strcmp(app.DisturbancesDropDown.Value,'no'); 
                dist=dist*0;
                else
                disttext=', dist=Y, ';
                ref=ref*0;
            end

            % initialise plot
            if app.nlegstring==1;
                aa=plot(app.UIAxes4,tt,ref(tt),'r--','LineWidth',2);
                hold(app.UIAxes4,'on')
                app.legstring{1}='Reference';
            end

            % upload model
            switch app.ModelchoiceDropDown.Value
                case "1st order"
                    a=[1 -0.8]; b=[0.4 0]; na=2;nb=2;
                    ap=[1 -0.85]; bp=[0.42, 0];
                case "2nd order"
                    a=[1,-1.4, 0.48]; b=[0.1 0.1]; na=3; nb=2;
                    ap=[1 -1.5 0.56]; bp=[0.12, 0.11];
                    dist=dist/2;
                case "3rd order"
                    a=poly([0.8,0.6,0.5]); b=[0.05 0.03]; na=4;nb=2;
                    ap=poly([0.8,0.6,0.5]); bp=[0.04, 0.025];
                    dist=dist/4;
            end
            % Check for no uncertainty
            uncertext='uncert=N';
            if strcmp(app.UncertaintyDropDown.Value,'no'); 
                ap=a;bp=b;
            else
                uncertext='uncert=Y';
            end
            na=length(a);  % number of parameter values
            nb=length(b);

            %%% Compute and plot MPC closed-loop behaviour for 30 samples
            %%% with and without the T-filter
            %%% Set point, disturbance and noise
            
            [ycl,ucl,Ducl,r] = mpc_simulate_noconstraints_control101(b,a,bp,ap,nu,ny,lambda,1,ref,dist,noise);
            [yT,uT,DuT,r] = mpc_simulate_tfilt_noconstraints_control101(b,a,Tfilter,nu,ny,lambda,1,ref,dist,noise);
            
            % History plots
            aaa=plot(app.UIAxes4,tt,yT(tt),'LineWidth',2);
            stairs(app.UIAxes2,tt,uT(tt),'LineWidth',2,'Color',aaa.Color);
            hold(app.UIAxes2,'on')

            % Compare current time only
            plot(app.UIAxes4_2,tt,yT(tt),tt,ycl(tt),'LineWidth',2)
            legend(app.UIAxes4_2,'With T-filter','No T-filter','Location','Southeast')
            stairs(app.UIAxes2_2,tt,uT(tt),'LineWidth',2);hold(app.UIAxes2_2,'on')
            stairs(app.UIAxes2_2,tt,ucl(tt),'LineWidth',2);hold(app.UIAxes2_2,'of')

            % Update prediction costs
                    sumerrors = norm(r-yT)^2;
                    suminputs = norm(DuT)^2;
                    J(app.nlegstring)=round(sumerrors+lambda*suminputs,3,'significant');
                    app.RuntimecostEditField.Value=J(app.nlegstring);
                   % app.SuminputchangesEditField.Value=suminputs;

            % update legend
            lam=round(lambda,3,'significant');
            app.nlegstring=app.nlegstring+1;
            app.legstring{app.nlegstring}=['ny=',num2str(ny),...
                ', nu=',num2str(nu),', \lambda=',num2str(lam),...
                ', T=[',Tfilterstring,']',...
                ', \zeta=',num2str(app.NoisevarianceSlider.Value),disttext,uncertext];
            legend(app.UIAxes4,app.legstring,'Location','southeast','FontSize',8)
           
            

        end

        % Value changed function: PredictionhorizonSlider
        function PredictionhorizonSliderValueChanged(app, event)
            value = app.PredictionhorizonSlider.Value;
            value =round(value);
            if value<app.ControlhorizonSlider.Value;
                value =app.ControlhorizonSlider.Value+1;
            end
            app.PredictionhorizonSlider.Value=value;
            if value==0;
                app.PredictionhorizonSlider.Value=5;
            end

        end

        % Value changed function: ControlhorizonSlider
        function ControlhorizonSliderValueChanged(app, event)
            value = app.ControlhorizonSlider.Value;
            value =round(value);
            if value>app.PredictionhorizonSlider.Value;
                app.PredictionhorizonSlider.Value=value+1;
            end
            app.ControlhorizonSlider.Value=value;

        end

        % Value changed function: Weightingpower10pSlider
        function Weightingpower10pSliderValueChanged(app, event)
            value = app.Weightingpower10pSlider.Value;
            value = round(value *2)/2;
            app.Weightingpower10pSlider.Value=value;

        end

        % Value changed function: TfilterpoleSlider
        function TfilterpoleSliderValueChanged(app, event)
            value = app.TfilterpoleSlider.Value;
            value = round(value*20)/20;
            if value ==1; value =0.95;end
            app.TfilterpoleSlider.Value=value;
        end

        % Value changed function: TfilterorderSlider
        function TfilterorderSliderValueChanged(app, event)
            value = app.TfilterorderSlider.Value;
            value = round(value);
            app.TfilterorderSlider.Value=value;
        end

        % Value changed function: NoisevarianceSlider
        function NoisevarianceSliderValueChanged(app, event)
            value = app.NoisevarianceSlider.Value;
            value = round(value*100)/100;
            app.NoisevarianceSlider.Value=value;
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
            app.UIFigure.Position = [100 100 1245 851];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1.2x', '1x'};
            app.GridLayout.RowHeight = {'0.45x', '1x', '1x'};

            % Create UIAxes2_2
            app.UIAxes2_2 = uiaxes(app.GridLayout);
            title(app.UIAxes2_2, 'Input with/without T-filter')
            xlabel(app.UIAxes2_2, 'Samples')
            ylabel(app.UIAxes2_2, 'Input')
            zlabel(app.UIAxes2_2, 'Z')
            app.UIAxes2_2.FontSize = 18;
            app.UIAxes2_2.Layout.Row = 3;
            app.UIAxes2_2.Layout.Column = 3;

            % Create UIAxes4_2
            app.UIAxes4_2 = uiaxes(app.GridLayout);
            title(app.UIAxes4_2, 'Output with/without T-filter')
            xlabel(app.UIAxes4_2, 'Samples')
            ylabel(app.UIAxes4_2, 'Output')
            zlabel(app.UIAxes4_2, 'Z')
            app.UIAxes4_2.FontSize = 18;
            app.UIAxes4_2.Layout.Row = 2;
            app.UIAxes4_2.Layout.Column = 3;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout);
            title(app.UIAxes2, 'Closed-loop input')
            xlabel(app.UIAxes2, 'Samples')
            ylabel(app.UIAxes2, 'Input')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 18;
            app.UIAxes2.Layout.Row = 3;
            app.UIAxes2.Layout.Column = 2;

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.GridLayout);
            title(app.UIAxes4, 'Closed-loop output')
            xlabel(app.UIAxes4, 'Samples')
            ylabel(app.UIAxes4, 'Output')
            zlabel(app.UIAxes4, 'Z')
            app.UIAxes4.FontSize = 18;
            app.UIAxes4.Layout.Row = 2;
            app.UIAxes4.Layout.Column = 2;

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'2x', '1x'};
            app.GridLayout4.RowHeight = {'1x', '1.4x'};
            app.GridLayout4.Layout.Row = 1;
            app.GridLayout4.Layout.Column = [2 3];
            app.GridLayout4.BackgroundColor = [0.6 1 1];

            % Create GPCwithaTfilterLabel
            app.GPCwithaTfilterLabel = uilabel(app.GridLayout4);
            app.GPCwithaTfilterLabel.BackgroundColor = [0 1 1];
            app.GPCwithaTfilterLabel.HorizontalAlignment = 'center';
            app.GPCwithaTfilterLabel.WordWrap = 'on';
            app.GPCwithaTfilterLabel.FontSize = 24;
            app.GPCwithaTfilterLabel.FontWeight = 'bold';
            app.GPCwithaTfilterLabel.Layout.Row = 1;
            app.GPCwithaTfilterLabel.Layout.Column = 1;
            app.GPCwithaTfilterLabel.Text = 'GPC with a T-filter';

            % Create Image
            app.Image = uiimage(app.GridLayout4);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 2;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'UoSlogo.png');

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.GridLayout4);
            app.GridLayout9.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.GridLayout9.RowHeight = {'1x'};
            app.GridLayout9.Layout.Row = 2;
            app.GridLayout9.Layout.Column = [1 2];

            % Create RuntimecostEditFieldLabel
            app.RuntimecostEditFieldLabel = uilabel(app.GridLayout9);
            app.RuntimecostEditFieldLabel.HorizontalAlignment = 'center';
            app.RuntimecostEditFieldLabel.FontSize = 18;
            app.RuntimecostEditFieldLabel.FontWeight = 'bold';
            app.RuntimecostEditFieldLabel.Layout.Row = 1;
            app.RuntimecostEditFieldLabel.Layout.Column = 1;
            app.RuntimecostEditFieldLabel.Text = 'Runtime cost';

            % Create RuntimecostEditField
            app.RuntimecostEditField = uieditfield(app.GridLayout9, 'numeric');
            app.RuntimecostEditField.FontSize = 24;
            app.RuntimecostEditField.FontWeight = 'bold';
            app.RuntimecostEditField.Layout.Row = 1;
            app.RuntimecostEditField.Layout.Column = 2;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout);
            app.GridLayout5.Layout.Row = 1;
            app.GridLayout5.Layout.Column = 1;
            app.GridLayout5.BackgroundColor = [1 0.6 0.8];

            % Create SimulateButton
            app.SimulateButton = uibutton(app.GridLayout5, 'push');
            app.SimulateButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateButtonPushed, true);
            app.SimulateButton.WordWrap = 'on';
            app.SimulateButton.BackgroundColor = [1 0.2 0.702];
            app.SimulateButton.FontSize = 24;
            app.SimulateButton.FontWeight = 'bold';
            app.SimulateButton.Layout.Row = [1 2];
            app.SimulateButton.Layout.Column = 1;
            app.SimulateButton.Text = 'Simulate';

            % Create RefreshButton
            app.RefreshButton = uibutton(app.GridLayout5, 'push');
            app.RefreshButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshButtonPushed, true);
            app.RefreshButton.WordWrap = 'on';
            app.RefreshButton.BackgroundColor = [1 0.2 0.702];
            app.RefreshButton.FontSize = 24;
            app.RefreshButton.FontWeight = 'bold';
            app.RefreshButton.Layout.Row = [1 2];
            app.RefreshButton.Layout.Column = 2;
            app.RefreshButton.Text = 'Refresh';

            % Create GridLayout8
            app.GridLayout8 = uigridlayout(app.GridLayout);
            app.GridLayout8.ColumnWidth = {'1x'};
            app.GridLayout8.RowHeight = {'1.8x', '1x'};
            app.GridLayout8.Layout.Row = [2 3];
            app.GridLayout8.Layout.Column = 1;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout8);
            app.GridLayout3.ColumnWidth = {'0.4x', '1x'};
            app.GridLayout3.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout3.Layout.Row = 1;
            app.GridLayout3.Layout.Column = 1;
            app.GridLayout3.BackgroundColor = [0.902 1 0.502];

            % Create ControllersettingsLabel
            app.ControllersettingsLabel = uilabel(app.GridLayout3);
            app.ControllersettingsLabel.BackgroundColor = [1 1 0];
            app.ControllersettingsLabel.HorizontalAlignment = 'center';
            app.ControllersettingsLabel.FontSize = 24;
            app.ControllersettingsLabel.FontWeight = 'bold';
            app.ControllersettingsLabel.Layout.Row = 1;
            app.ControllersettingsLabel.Layout.Column = [1 2];
            app.ControllersettingsLabel.Text = 'Controller settings';

            % Create PredictionhorizonSliderLabel
            app.PredictionhorizonSliderLabel = uilabel(app.GridLayout3);
            app.PredictionhorizonSliderLabel.HorizontalAlignment = 'right';
            app.PredictionhorizonSliderLabel.FontSize = 14;
            app.PredictionhorizonSliderLabel.FontWeight = 'bold';
            app.PredictionhorizonSliderLabel.Layout.Row = 2;
            app.PredictionhorizonSliderLabel.Layout.Column = 1;
            app.PredictionhorizonSliderLabel.Text = 'Prediction horizon';

            % Create PredictionhorizonSlider
            app.PredictionhorizonSlider = uislider(app.GridLayout3);
            app.PredictionhorizonSlider.Limits = [0 20];
            app.PredictionhorizonSlider.ValueChangedFcn = createCallbackFcn(app, @PredictionhorizonSliderValueChanged, true);
            app.PredictionhorizonSlider.MinorTicks = [0 2 4 6 8 10 12 14 16 18 20];
            app.PredictionhorizonSlider.FontSize = 14;
            app.PredictionhorizonSlider.FontWeight = 'bold';
            app.PredictionhorizonSlider.Layout.Row = 2;
            app.PredictionhorizonSlider.Layout.Column = 2;
            app.PredictionhorizonSlider.Value = 10;

            % Create ControlhorizonSliderLabel
            app.ControlhorizonSliderLabel = uilabel(app.GridLayout3);
            app.ControlhorizonSliderLabel.HorizontalAlignment = 'right';
            app.ControlhorizonSliderLabel.FontSize = 14;
            app.ControlhorizonSliderLabel.FontWeight = 'bold';
            app.ControlhorizonSliderLabel.Layout.Row = 3;
            app.ControlhorizonSliderLabel.Layout.Column = 1;
            app.ControlhorizonSliderLabel.Text = 'Control horizon';

            % Create ControlhorizonSlider
            app.ControlhorizonSlider = uislider(app.GridLayout3);
            app.ControlhorizonSlider.Limits = [1 6];
            app.ControlhorizonSlider.MajorTicks = [1 2 3 4 5 6];
            app.ControlhorizonSlider.MajorTickLabels = {'1', '2', '3', '4', '5', '6'};
            app.ControlhorizonSlider.ValueChangedFcn = createCallbackFcn(app, @ControlhorizonSliderValueChanged, true);
            app.ControlhorizonSlider.MinorTicks = [1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4 4.1 4.2 4.3 4.4 4.5 4.6 4.7 4.8 4.9 5 5.1 5.2 5.3 5.4 5.5 5.6 5.7 5.8 5.9 6];
            app.ControlhorizonSlider.FontSize = 14;
            app.ControlhorizonSlider.FontWeight = 'bold';
            app.ControlhorizonSlider.Layout.Row = 3;
            app.ControlhorizonSlider.Layout.Column = 2;
            app.ControlhorizonSlider.Value = 1;

            % Create Weightingpower10pSliderLabel
            app.Weightingpower10pSliderLabel = uilabel(app.GridLayout3);
            app.Weightingpower10pSliderLabel.HorizontalAlignment = 'right';
            app.Weightingpower10pSliderLabel.WordWrap = 'on';
            app.Weightingpower10pSliderLabel.FontSize = 14;
            app.Weightingpower10pSliderLabel.FontWeight = 'bold';
            app.Weightingpower10pSliderLabel.Layout.Row = 4;
            app.Weightingpower10pSliderLabel.Layout.Column = 1;
            app.Weightingpower10pSliderLabel.Text = 'Weighting power (10^p)';

            % Create Weightingpower10pSlider
            app.Weightingpower10pSlider = uislider(app.GridLayout3);
            app.Weightingpower10pSlider.Limits = [-3 3];
            app.Weightingpower10pSlider.ValueChangedFcn = createCallbackFcn(app, @Weightingpower10pSliderValueChanged, true);
            app.Weightingpower10pSlider.MinorTicks = [0 1 2 3 4 5 6 7 8 9 10];
            app.Weightingpower10pSlider.FontWeight = 'bold';
            app.Weightingpower10pSlider.Layout.Row = 4;
            app.Weightingpower10pSlider.Layout.Column = 2;

            % Create TfilterpoleSliderLabel
            app.TfilterpoleSliderLabel = uilabel(app.GridLayout3);
            app.TfilterpoleSliderLabel.HorizontalAlignment = 'right';
            app.TfilterpoleSliderLabel.FontSize = 14;
            app.TfilterpoleSliderLabel.FontWeight = 'bold';
            app.TfilterpoleSliderLabel.Layout.Row = 5;
            app.TfilterpoleSliderLabel.Layout.Column = 1;
            app.TfilterpoleSliderLabel.Text = 'T-filter pole';

            % Create TfilterpoleSlider
            app.TfilterpoleSlider = uislider(app.GridLayout3);
            app.TfilterpoleSlider.Limits = [0 1];
            app.TfilterpoleSlider.ValueChangedFcn = createCallbackFcn(app, @TfilterpoleSliderValueChanged, true);
            app.TfilterpoleSlider.Step = 0.1;
            app.TfilterpoleSlider.FontSize = 14;
            app.TfilterpoleSlider.FontWeight = 'bold';
            app.TfilterpoleSlider.Layout.Row = 5;
            app.TfilterpoleSlider.Layout.Column = 2;
            app.TfilterpoleSlider.Value = 0.8;

            % Create TfilterorderSliderLabel
            app.TfilterorderSliderLabel = uilabel(app.GridLayout3);
            app.TfilterorderSliderLabel.HorizontalAlignment = 'right';
            app.TfilterorderSliderLabel.FontSize = 14;
            app.TfilterorderSliderLabel.FontWeight = 'bold';
            app.TfilterorderSliderLabel.Layout.Row = 6;
            app.TfilterorderSliderLabel.Layout.Column = 1;
            app.TfilterorderSliderLabel.Text = 'T-filter order';

            % Create TfilterorderSlider
            app.TfilterorderSlider = uislider(app.GridLayout3);
            app.TfilterorderSlider.Limits = [1 3];
            app.TfilterorderSlider.MajorTicks = [1 2 3];
            app.TfilterorderSlider.MajorTickLabels = {'1', '2', '3'};
            app.TfilterorderSlider.ValueChangedFcn = createCallbackFcn(app, @TfilterorderSliderValueChanged, true);
            app.TfilterorderSlider.MinorTicks = [1 2 3];
            app.TfilterorderSlider.Step = 1;
            app.TfilterorderSlider.FontSize = 14;
            app.TfilterorderSlider.FontWeight = 'bold';
            app.TfilterorderSlider.Layout.Row = 6;
            app.TfilterorderSlider.Layout.Column = 2;
            app.TfilterorderSlider.Value = 1;

            % Create NoisevarianceSliderLabel
            app.NoisevarianceSliderLabel = uilabel(app.GridLayout3);
            app.NoisevarianceSliderLabel.HorizontalAlignment = 'right';
            app.NoisevarianceSliderLabel.FontSize = 14;
            app.NoisevarianceSliderLabel.FontWeight = 'bold';
            app.NoisevarianceSliderLabel.Layout.Row = 7;
            app.NoisevarianceSliderLabel.Layout.Column = 1;
            app.NoisevarianceSliderLabel.Text = 'Noise variance';

            % Create NoisevarianceSlider
            app.NoisevarianceSlider = uislider(app.GridLayout3);
            app.NoisevarianceSlider.Limits = [0 0.2];
            app.NoisevarianceSlider.MajorTicks = [0 0.05 0.1 0.15 0.2];
            app.NoisevarianceSlider.ValueChangedFcn = createCallbackFcn(app, @NoisevarianceSliderValueChanged, true);
            app.NoisevarianceSlider.Step = 0.01;
            app.NoisevarianceSlider.FontSize = 14;
            app.NoisevarianceSlider.FontWeight = 'bold';
            app.NoisevarianceSlider.Layout.Row = 7;
            app.NoisevarianceSlider.Layout.Column = 2;
            app.NoisevarianceSlider.Value = 0.05;

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.GridLayout8);
            app.GridLayout7.ColumnWidth = {'0.7x', '1x'};
            app.GridLayout7.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout7.Layout.Row = 2;
            app.GridLayout7.Layout.Column = 1;
            app.GridLayout7.BackgroundColor = [0.702 1 0.702];

            % Create ConfigurationLabel
            app.ConfigurationLabel = uilabel(app.GridLayout7);
            app.ConfigurationLabel.BackgroundColor = [0 1 0];
            app.ConfigurationLabel.HorizontalAlignment = 'center';
            app.ConfigurationLabel.FontSize = 24;
            app.ConfigurationLabel.FontWeight = 'bold';
            app.ConfigurationLabel.FontColor = [0.1294 0.1294 0.1294];
            app.ConfigurationLabel.Layout.Row = 1;
            app.ConfigurationLabel.Layout.Column = [1 2];
            app.ConfigurationLabel.Text = 'Configuration';

            % Create ModelchoiceDropDownLabel
            app.ModelchoiceDropDownLabel = uilabel(app.GridLayout7);
            app.ModelchoiceDropDownLabel.HorizontalAlignment = 'right';
            app.ModelchoiceDropDownLabel.FontSize = 18;
            app.ModelchoiceDropDownLabel.Layout.Row = 2;
            app.ModelchoiceDropDownLabel.Layout.Column = 1;
            app.ModelchoiceDropDownLabel.Text = 'Model choice';

            % Create ModelchoiceDropDown
            app.ModelchoiceDropDown = uidropdown(app.GridLayout7);
            app.ModelchoiceDropDown.Items = {'1st order', '2nd order', '3rd order'};
            app.ModelchoiceDropDown.FontSize = 18;
            app.ModelchoiceDropDown.Layout.Row = 2;
            app.ModelchoiceDropDown.Layout.Column = 2;
            app.ModelchoiceDropDown.Value = '1st order';

            % Create DisturbancesDropDownLabel
            app.DisturbancesDropDownLabel = uilabel(app.GridLayout7);
            app.DisturbancesDropDownLabel.HorizontalAlignment = 'right';
            app.DisturbancesDropDownLabel.FontSize = 18;
            app.DisturbancesDropDownLabel.Layout.Row = 3;
            app.DisturbancesDropDownLabel.Layout.Column = 1;
            app.DisturbancesDropDownLabel.Text = 'Disturbances';

            % Create DisturbancesDropDown
            app.DisturbancesDropDown = uidropdown(app.GridLayout7);
            app.DisturbancesDropDown.Items = {'yes', 'no'};
            app.DisturbancesDropDown.FontSize = 18;
            app.DisturbancesDropDown.Layout.Row = 3;
            app.DisturbancesDropDown.Layout.Column = 2;
            app.DisturbancesDropDown.Value = 'no';

            % Create UncertaintyDropDownLabel
            app.UncertaintyDropDownLabel = uilabel(app.GridLayout7);
            app.UncertaintyDropDownLabel.HorizontalAlignment = 'right';
            app.UncertaintyDropDownLabel.FontSize = 18;
            app.UncertaintyDropDownLabel.Layout.Row = 4;
            app.UncertaintyDropDownLabel.Layout.Column = 1;
            app.UncertaintyDropDownLabel.Text = 'Uncertainty';

            % Create UncertaintyDropDown
            app.UncertaintyDropDown = uidropdown(app.GridLayout7);
            app.UncertaintyDropDown.Items = {'yes', 'no'};
            app.UncertaintyDropDown.FontSize = 18;
            app.UncertaintyDropDown.Layout.Row = 4;
            app.UncertaintyDropDown.Layout.Column = 2;
            app.UncertaintyDropDown.Value = 'no';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = mpctfilter_control101

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

