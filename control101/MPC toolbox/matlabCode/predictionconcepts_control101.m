classdef predictionconcepts_control101 < matlab.apps.AppBase
    %PREDICTIONCONCEPTS_CONTROL101
    %   This is a simple interface to understand both how prediction
    %   underpins control decision making modelling and also how, with poor
    %   choices of horizons, these decisions may be poorly thought through.
    %   Users can select their desired values for the future inputs and
    %   view the impact on the predictions. There is also an option to view
    %   the associated GPC/DMC predictions. The implement button will then
    %   use the first of these and move to the next sample.
    %   Boxes at the top summarise the sum of errors squared and input
    %   changes squared to help with any quantitative assessment. The
    %   manual is in predictionconcepts_control101_manual.mlx.

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        GridLayout8                   matlab.ui.container.GridLayout
        GridLayout7                   matlab.ui.container.GridLayout
        WeightingSlider               matlab.ui.control.Slider
        WeightingSliderLabel          matlab.ui.control.Label
        UncertaintyDropDown           matlab.ui.control.DropDown
        UncertaintyDropDownLabel      matlab.ui.control.Label
        DisturbancesDropDown          matlab.ui.control.DropDown
        DisturbancesDropDownLabel     matlab.ui.control.Label
        ModelchoiceDropDown           matlab.ui.control.DropDown
        ModelchoiceDropDownLabel      matlab.ui.control.Label
        ConfigurationLabel            matlab.ui.control.Label
        GridLayout3                   matlab.ui.container.GridLayout
        Inputuk2Slider                matlab.ui.control.Slider
        Inputuk2SliderLabel           matlab.ui.control.Label
        Inputuk1Slider                matlab.ui.control.Slider
        Inputuk1SliderLabel           matlab.ui.control.Label
        InputukSlider                 matlab.ui.control.Slider
        InputukSliderLabel            matlab.ui.control.Label
        ControlhorizonSlider          matlab.ui.control.Slider
        ControlhorizonSliderLabel     matlab.ui.control.Label
        PredictionhorizonSlider       matlab.ui.control.Slider
        PredictionhorizonSliderLabel  matlab.ui.control.Label
        ControllersettingsLabel       matlab.ui.control.Label
        GridLayout5                   matlab.ui.container.GridLayout
        MPCormanualDropDown           matlab.ui.control.DropDown
        MPCormanualDropDownLabel      matlab.ui.control.Label
        StopsimulationButton          matlab.ui.control.Button
        ImplementinputButton          matlab.ui.control.Button
        ClearandsimulateButton        matlab.ui.control.Button
        GridLayout4                   matlab.ui.container.GridLayout
        GridLayout9                   matlab.ui.container.GridLayout
        SumDu2EditField               matlab.ui.control.NumericEditField
        SumDu2EditFieldLabel          matlab.ui.control.Label
        Sumry2EditField               matlab.ui.control.NumericEditField
        Sumry2EditFieldLabel          matlab.ui.control.Label
        Image                         matlab.ui.control.Image
        TheconceptofpredictionLabel   matlab.ui.control.Label
        UIAxes2                       matlab.ui.control.UIAxes
        UIAxes4                       matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        originalsize % Description
        
        continuebutton=1
        finishbutton=0  % change to 1 to stop simulation
        manual='manual'
    end
    
    methods (Access = private)
        
        function  disablebuttons(app)
            set(app.ClearandsimulateButton,'Enable','off')
            set(app.ModelchoiceDropDown, 'Enable', 'off');
             set(app.DisturbancesDropDown, 'Enable', 'off');
            set(app.UncertaintyDropDown, 'Enable', 'off');
            set(app.ControlhorizonSlider, 'Enable', 'off');
            set(app.PredictionhorizonSlider, 'Enable', 'off');
            set(app.WeightingSlider, 'Enable', 'off');
            % set(app.Inputuk1Slider, 'Enable', 'off');
            % set(app.Inputuk2Slider, 'Enable', 'off');
         end
        
        function enablebuttons(app)
            set(app.ClearandsimulateButton,'Enable','on')
          set(app.ModelchoiceDropDown, 'Enable', 'on');
             set(app.DisturbancesDropDown, 'Enable', 'on');
            set(app.UncertaintyDropDown, 'Enable', 'on');
            set(app.ControlhorizonSlider, 'Enable', 'on');
            set(app.PredictionhorizonSlider, 'Enable', 'on');
            set(app.WeightingSlider, 'Enable', 'on');
            % set(app.Inputuk1Slider, 'Enable', 'on');
            % set(app.Inputuk2Slider, 'Enable', 'on');

        end


    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.UIFigure.AutoResizeChildren='off';   
            movegui(app.UIFigure)
            
            % Open the manual
            if exist('predictionconcepts_control101_manual_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open predictionconcepts_control101_manual_mycopy.mlx
            else
                p1 = which('predictionconcepts_control101_manual.mlx');
                p2 = strcat(pwd,'/predictionconcepts_control101_manual_mycopy.mlx');
                copyfile(p1,p2)
                open predictionconcepts_control101_manual_mycopy.mlx
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

        % Button pushed function: ImplementinputButton
        function ImplementinputButtonPushed(app, event)
            app.continuebutton=1;
            
            
        end

        % Button pushed function: ClearandsimulateButton
        function ClearandsimulateButtonPushed(app, event)
            disablebuttons(app) 
            hold(app.UIAxes2,'off');
            plot(app.UIAxes2,1,1,'w')
            hold(app.UIAxes4,'off')
            plot(app.UIAxes4,1,1,'w')
            app.finishbutton=0; % reset to allow iteration
            app.continuebutton=0;

            % Controller settings and external signals
            ny=app.PredictionhorizonSlider.Value;
            ny2=30;
            nu=app.ControlhorizonSlider.Value;
            lambda = app.WeightingSlider.Value;
            runtime=30;
            init=6;
            ref = [zeros(1,init),ones(1,runtime-init)];
            dist=[zeros(1,init+2),ones(1,runtime-init-2)*0.2];
            noise = [zeros(1,runtime)];
            tt=1:runtime;
            app.InputukSlider.Value=0;
            app.Inputuk1Slider.Value=0;
            app.Inputuk2Slider.Value=0;
            % Check for no disturbances
            if strcmp(app.DisturbancesDropDown.Value,'no'); 
                dist=dist*0;
            end

            % initialise plot
            aa=plot(app.UIAxes4,tt,ref,'r--','LineWidth',2);
            hold(app.UIAxes4,'on')

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
            if strcmp(app.UncertaintyDropDown.Value,'no'); 
                ap=a;bp=b;
            end
            na=length(a);  % number of parameter values
            nb=length(b);
            app.continuebutton=0;  % will cause loop to pause and wait           

            %%% Compute and plot MPC closed-loop behaviour for 30 samples
            %%% Set point, disturbance and noise           
            [ycl,ucl,Ducl,r] = mpc_simulate_noconstraints_control101(b,a,bp,ap,nu,ny,lambda,1,ref,dist,noise);
            
            %keyboard

            %%%%%%%%%%%%%%%%%%%%%  behavior broken down by each sample
            %%%% Predictions at each sample
            % Generates a square H matrix for now
            [H,P,Q] = mpc_predmat_toeplitz_control101(a,b,ny);   % pred over horizon
            [H2,P2,Q2] = mpc_predmat_toeplitz_control101(a,b,ny2);   % full prediction
            HH=tril(ones(nu,nu));
            
            %%%% mpc_law computes entire proposed trajectory
            [Nk,Dk,Pr,S,X,Prlong] = mpc_law_control101(H,P,Q,nu,lambda,1,1);
            %keyboard
            % check predictions each sample
            y=zeros(1,init);u=y;Du=y;

            % initialise all the plots using MPC for simplicity
            k=init;
            v2=k+1:k+ny;v=k:runtime;vv=ones(runtime-k-nu,1);
            ypast=y(k:-1:k-na+1)';
            Dupast = Du(k-1:-1:k-nb+1)';
            Duopt = Pr*r(k+1) -Nk*ypast-Dk*Dupast;                
            uopt=HH*Duopt+u(k-1);
            ypredall = H2(:,1:nu)*Duopt+Q2*ypast+P2*Dupast;
            ypred = H(:,1:nu)*Duopt+Q*ypast+P*Dupast;
            aaa=plot(app.UIAxes4,[k+ny,k+ny,k+1,k+1,k+ny],[0.2,1.4,1.4,0.2,0.2],'g:', ...
                        'linewidth',4);
            hold(app.UIAxes4,'on')
            % handles for prediction plots
            ypredhandle=plot(app.UIAxes4,v(1:runtime-k),[y(k);ypredall(1:runtime-k-1)],'--');
            set(ypredhandle,'linewidth',2,'Color',[0 0 1]*0.5);
            upredhandle=stairs(app.UIAxes4, v,[u(k-1);uopt;uopt(end)*vv],':',...
                    'Color',[1,0,1]*0.4,'LineWidth',2);
            % handles for actual simulation
            finalplot=plot(app.UIAxes4,1:k,y(1:k),'b','LineWidth',2); % bold history
            finaluplot=stairs(app.UIAxes4,1:k,u(1:k),'m','linewidth',2);
            legend(app.UIAxes4,'Target','Horizon','Output prediction',...
                    'Input prediction','Output')
            nosteps=8;
            
            for k=init:init+nosteps;
                
                % Plot prediction line 
                if k>init;              
                    set(aaa,'XData',[k+ny,k+ny,k+1,k+1,k+ny]);
                end
                
                v2=k+1:k+ny;v=k:runtime;vv=ones(runtime-k-nu,1);

                % Find MPC predictions 
                ypast=y(k:-1:k-na+1)';
                Dupast = Du(k-1:-1:k-nb+1)';
                Duopt = Pr*r(k+1) -Nk*ypast-Dk*Dupast;                
                uopt=HH*Duopt+u(k-1);
                ypredall = H2(:,1:nu)*Duopt+Q2*ypast+P2*Dupast;
                ypred = H(:,1:nu)*Duopt+Q*ypast+P*Dupast;
                                                    
                % Update and change manual predictions
                while and(app.continuebutton==0,k-init<nosteps+1);
                    % Find input prediction
                    switch app.MPCormanualDropDown.Value
                        case 'MPC'
                           % no update needed
                             Duopt = Pr*r(k+1) -Nk*ypast-Dk*Dupast;
                            uopt=HH*Duopt+u(k-1);
                            ypredall = H2(:,1:nu)*Duopt+Q2*ypast+P2*Dupast;
                            ypred = H(:,1:nu)*Duopt+Q*ypast+P*Dupast;
                        case 'Manual'               
                        % Manual input predictions
                        uopt=[app.InputukSlider.Value;app.Inputuk1Slider.Value;app.Inputuk2Slider.Value];
                        uopt=uopt(1:nu);
                        Duopt = diff([u(k-1);uopt]);
                        % find output predictions
                        ypredall = H2(:,1:nu)*Duopt+Q2*ypast+P2*Dupast;
                        ypred = H(:,1:nu)*Duopt+Q*ypast+P*Dupast;
                        
                    end  % end of switch
                    set(ypredhandle,'Xdata',[v],'Ydata',[y(k);ypredall(1:runtime-k)]);
                    set(upredhandle,'Xdata',v-1,'Ydata',[u(k-1);uopt;uopt(end)*vv]);

                    if app.finishbutton==0;pause(1);  % Stop manual iteration
                    else;app.continuebutton=1;end

                    % wait for the implement buttons to be pressed
                    legend(app.UIAxes4,'Target','Horizon','Output prediction',...
                    'Input prediction')
                    u(k:k+nu-1)=uopt';Du(k)=Duopt(1);

                    % Update prediction costs
                    sumerrors = norm(r(k+1)-ypred)^2;
                    suminputs = norm(Duopt)^2;
                    app.Sumry2EditField.Value=sumerrors;
                    app.SumDu2EditField.Value=suminputs;
                
                end   % end of while loop


                app.continuebutton=0;  % reset for next time                  
                
                % Simulate model                
                u(k:k+nu-1)=uopt';Du(k)=Duopt(1);
                y(k+1)=bp*u(k:-1:k-nb+1)'-ap(2:end)*y(k:-1:k-na+2)'+dist(k);

                set(finalplot,'Xdata',1:k+1,'Ydata',y(1:k+1)); % bold history
                set(finaluplot,'Xdata',1:k,'Ydata',u(1:k)); % bold history
               
                % bb=stairs(app.UIAxes4, [k-1,k:k+nu-1],[u(k-1);uopt],...
                %     'Color',[1,0,1]*0.5,'LineWidth',0.5) ;             
                % cc=stairs(app.UIAxes4, v,[uopt;uopt(end)*vv],'--',...
                %     'Color',[1,0,1]*0.5,'LineWidth',0.5);
                % stairs(app.UIAxes4, 1:k+nu-1,u(1:k+nu-1),'m','LineWidth',2); % bold history
               
                

              end
              
              
              % Default MPC plot
              aa=plot(app.UIAxes2,tt,r,'r--',...
              tt,ycl,'b--',tt,dist,'c');
              set(aa,'linewidth',2);
              hold(app.UIAxes2,'on');
              stairs(app.UIAxes2,tt,ucl,'m--','linewidth',2)
              c=legend(app.UIAxes2,'set point','output','Disturbance','input');
              set(c,'fontsize',18)

             %if nu==1;
         %        stairs(app.UIAxes4, 1:k+nu,[u,u(k+nu-1)],'m','LineWidth',2); % bold history
             %end

                enablebuttons(app)

        end

        % Value changed function: PredictionhorizonSlider
        function PredictionhorizonSliderValueChanged(app, event)
            value = app.PredictionhorizonSlider.Value;
            value =round(value);
            app.PredictionhorizonSlider.Value=value;
            if value==0;
                app.PredictionhorizonSlider.Value=5;
            end

        end

        % Button pushed function: StopsimulationButton
        function StopsimulationButtonPushed(app, event)
            app.finishbutton=1;
            
        end

        % Value changed function: ControlhorizonSlider
        function ControlhorizonSliderValueChanged(app, event)
            value = app.ControlhorizonSlider.Value;
            value =round(value);
            app.ControlhorizonSlider.Value=value;

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
            app.GridLayout.ColumnWidth = {'1x', '1.5x'};
            app.GridLayout.RowHeight = {'0.35x', '1x', '1x'};

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.GridLayout);
            title(app.UIAxes4, 'Current predictions')
            xlabel(app.UIAxes4, 'Samples')
            ylabel(app.UIAxes4, 'Signals')
            zlabel(app.UIAxes4, 'Z')
            app.UIAxes4.FontSize = 18;
            app.UIAxes4.Layout.Row = 2;
            app.UIAxes4.Layout.Column = 2;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout);
            title(app.UIAxes2, 'Closed-loop MPC behaviour')
            xlabel(app.UIAxes2, 'Samples')
            ylabel(app.UIAxes2, 'Signals')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 18;
            app.UIAxes2.Layout.Row = 3;
            app.UIAxes2.Layout.Column = 2;

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'2x', '1x'};
            app.GridLayout4.Layout.Row = 1;
            app.GridLayout4.Layout.Column = 2;
            app.GridLayout4.BackgroundColor = [0.6 1 1];

            % Create TheconceptofpredictionLabel
            app.TheconceptofpredictionLabel = uilabel(app.GridLayout4);
            app.TheconceptofpredictionLabel.BackgroundColor = [0 1 1];
            app.TheconceptofpredictionLabel.HorizontalAlignment = 'center';
            app.TheconceptofpredictionLabel.WordWrap = 'on';
            app.TheconceptofpredictionLabel.FontSize = 24;
            app.TheconceptofpredictionLabel.FontWeight = 'bold';
            app.TheconceptofpredictionLabel.Layout.Row = 1;
            app.TheconceptofpredictionLabel.Layout.Column = 1;
            app.TheconceptofpredictionLabel.Text = 'The concept of prediction';

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

            % Create Sumry2EditFieldLabel
            app.Sumry2EditFieldLabel = uilabel(app.GridLayout9);
            app.Sumry2EditFieldLabel.HorizontalAlignment = 'center';
            app.Sumry2EditFieldLabel.FontSize = 18;
            app.Sumry2EditFieldLabel.Layout.Row = 1;
            app.Sumry2EditFieldLabel.Layout.Column = 1;
            app.Sumry2EditFieldLabel.Text = 'Sum (r-y)^2';

            % Create Sumry2EditField
            app.Sumry2EditField = uieditfield(app.GridLayout9, 'numeric');
            app.Sumry2EditField.FontSize = 18;
            app.Sumry2EditField.Layout.Row = 1;
            app.Sumry2EditField.Layout.Column = 2;

            % Create SumDu2EditFieldLabel
            app.SumDu2EditFieldLabel = uilabel(app.GridLayout9);
            app.SumDu2EditFieldLabel.HorizontalAlignment = 'right';
            app.SumDu2EditFieldLabel.FontSize = 18;
            app.SumDu2EditFieldLabel.Layout.Row = 1;
            app.SumDu2EditFieldLabel.Layout.Column = 3;
            app.SumDu2EditFieldLabel.Text = 'Sum Du^2';

            % Create SumDu2EditField
            app.SumDu2EditField = uieditfield(app.GridLayout9, 'numeric');
            app.SumDu2EditField.FontSize = 18;
            app.SumDu2EditField.Layout.Row = 1;
            app.SumDu2EditField.Layout.Column = 4;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout);
            app.GridLayout5.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout5.Layout.Row = 1;
            app.GridLayout5.Layout.Column = 1;
            app.GridLayout5.BackgroundColor = [1 0.6 0.8];

            % Create ClearandsimulateButton
            app.ClearandsimulateButton = uibutton(app.GridLayout5, 'push');
            app.ClearandsimulateButton.ButtonPushedFcn = createCallbackFcn(app, @ClearandsimulateButtonPushed, true);
            app.ClearandsimulateButton.WordWrap = 'on';
            app.ClearandsimulateButton.BackgroundColor = [1 0.2 0.702];
            app.ClearandsimulateButton.FontSize = 18;
            app.ClearandsimulateButton.FontWeight = 'bold';
            app.ClearandsimulateButton.Layout.Row = 1;
            app.ClearandsimulateButton.Layout.Column = 1;
            app.ClearandsimulateButton.Text = 'Clear and simulate';

            % Create ImplementinputButton
            app.ImplementinputButton = uibutton(app.GridLayout5, 'push');
            app.ImplementinputButton.ButtonPushedFcn = createCallbackFcn(app, @ImplementinputButtonPushed, true);
            app.ImplementinputButton.WordWrap = 'on';
            app.ImplementinputButton.BackgroundColor = [1 0.2 0.702];
            app.ImplementinputButton.FontSize = 18;
            app.ImplementinputButton.FontWeight = 'bold';
            app.ImplementinputButton.Layout.Row = 1;
            app.ImplementinputButton.Layout.Column = 2;
            app.ImplementinputButton.Text = 'Implement input';

            % Create StopsimulationButton
            app.StopsimulationButton = uibutton(app.GridLayout5, 'push');
            app.StopsimulationButton.ButtonPushedFcn = createCallbackFcn(app, @StopsimulationButtonPushed, true);
            app.StopsimulationButton.WordWrap = 'on';
            app.StopsimulationButton.BackgroundColor = [1 0.2 0.702];
            app.StopsimulationButton.FontSize = 18;
            app.StopsimulationButton.FontWeight = 'bold';
            app.StopsimulationButton.Layout.Row = [1 2];
            app.StopsimulationButton.Layout.Column = 3;
            app.StopsimulationButton.Text = 'Stop simulation';

            % Create MPCormanualDropDownLabel
            app.MPCormanualDropDownLabel = uilabel(app.GridLayout5);
            app.MPCormanualDropDownLabel.BackgroundColor = [0.9882 0.6824 0.8941];
            app.MPCormanualDropDownLabel.HorizontalAlignment = 'center';
            app.MPCormanualDropDownLabel.FontSize = 18;
            app.MPCormanualDropDownLabel.FontWeight = 'bold';
            app.MPCormanualDropDownLabel.Layout.Row = 2;
            app.MPCormanualDropDownLabel.Layout.Column = 1;
            app.MPCormanualDropDownLabel.Text = 'MPC or manual';

            % Create MPCormanualDropDown
            app.MPCormanualDropDown = uidropdown(app.GridLayout5);
            app.MPCormanualDropDown.Items = {'MPC', 'Manual'};
            app.MPCormanualDropDown.FontSize = 14;
            app.MPCormanualDropDown.BackgroundColor = [0.9882 0.6824 0.8941];
            app.MPCormanualDropDown.Layout.Row = 2;
            app.MPCormanualDropDown.Layout.Column = 2;
            app.MPCormanualDropDown.Value = 'Manual';

            % Create GridLayout8
            app.GridLayout8 = uigridlayout(app.GridLayout);
            app.GridLayout8.ColumnWidth = {'1x'};
            app.GridLayout8.RowHeight = {'1.4x', '1x'};
            app.GridLayout8.Layout.Row = [2 3];
            app.GridLayout8.Layout.Column = 1;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout8);
            app.GridLayout3.ColumnWidth = {'0.4x', '1x'};
            app.GridLayout3.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x'};
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
            app.PredictionhorizonSliderLabel.Layout.Row = 2;
            app.PredictionhorizonSliderLabel.Layout.Column = 1;
            app.PredictionhorizonSliderLabel.Text = 'Prediction horizon';

            % Create PredictionhorizonSlider
            app.PredictionhorizonSlider = uislider(app.GridLayout3);
            app.PredictionhorizonSlider.Limits = [0 20];
            app.PredictionhorizonSlider.ValueChangedFcn = createCallbackFcn(app, @PredictionhorizonSliderValueChanged, true);
            app.PredictionhorizonSlider.MinorTicks = [0 2 4 6 8 10 12 14 16 18 20];
            app.PredictionhorizonSlider.FontSize = 14;
            app.PredictionhorizonSlider.Layout.Row = 2;
            app.PredictionhorizonSlider.Layout.Column = 2;
            app.PredictionhorizonSlider.Value = 10;

            % Create ControlhorizonSliderLabel
            app.ControlhorizonSliderLabel = uilabel(app.GridLayout3);
            app.ControlhorizonSliderLabel.HorizontalAlignment = 'right';
            app.ControlhorizonSliderLabel.FontSize = 14;
            app.ControlhorizonSliderLabel.Layout.Row = 3;
            app.ControlhorizonSliderLabel.Layout.Column = 1;
            app.ControlhorizonSliderLabel.Text = 'Control horizon';

            % Create ControlhorizonSlider
            app.ControlhorizonSlider = uislider(app.GridLayout3);
            app.ControlhorizonSlider.Limits = [1 3];
            app.ControlhorizonSlider.MajorTicks = [1 2 3];
            app.ControlhorizonSlider.MajorTickLabels = {'1', '2', '3'};
            app.ControlhorizonSlider.ValueChangedFcn = createCallbackFcn(app, @ControlhorizonSliderValueChanged, true);
            app.ControlhorizonSlider.MinorTicks = [1 2 3];
            app.ControlhorizonSlider.FontSize = 14;
            app.ControlhorizonSlider.Layout.Row = 3;
            app.ControlhorizonSlider.Layout.Column = 2;
            app.ControlhorizonSlider.Value = 1;

            % Create InputukSliderLabel
            app.InputukSliderLabel = uilabel(app.GridLayout3);
            app.InputukSliderLabel.HorizontalAlignment = 'right';
            app.InputukSliderLabel.FontSize = 14;
            app.InputukSliderLabel.Layout.Row = 4;
            app.InputukSliderLabel.Layout.Column = 1;
            app.InputukSliderLabel.Text = 'Input u(k)';

            % Create InputukSlider
            app.InputukSlider = uislider(app.GridLayout3);
            app.InputukSlider.Limits = [-0.5 2];
            app.InputukSlider.MajorTicks = [-0.5 0 0.5 1 1.5 2];
            app.InputukSlider.Layout.Row = 4;
            app.InputukSlider.Layout.Column = 2;

            % Create Inputuk1SliderLabel
            app.Inputuk1SliderLabel = uilabel(app.GridLayout3);
            app.Inputuk1SliderLabel.HorizontalAlignment = 'right';
            app.Inputuk1SliderLabel.FontSize = 14;
            app.Inputuk1SliderLabel.Layout.Row = 5;
            app.Inputuk1SliderLabel.Layout.Column = 1;
            app.Inputuk1SliderLabel.Text = 'Input u(k+1)';

            % Create Inputuk1Slider
            app.Inputuk1Slider = uislider(app.GridLayout3);
            app.Inputuk1Slider.Limits = [-0.5 2];
            app.Inputuk1Slider.MajorTicks = [-0.5 0 0.5 1 1.5 2];
            app.Inputuk1Slider.Layout.Row = 5;
            app.Inputuk1Slider.Layout.Column = 2;

            % Create Inputuk2SliderLabel
            app.Inputuk2SliderLabel = uilabel(app.GridLayout3);
            app.Inputuk2SliderLabel.HorizontalAlignment = 'right';
            app.Inputuk2SliderLabel.FontSize = 14;
            app.Inputuk2SliderLabel.Layout.Row = 6;
            app.Inputuk2SliderLabel.Layout.Column = 1;
            app.Inputuk2SliderLabel.Text = 'Input u(k+2)';

            % Create Inputuk2Slider
            app.Inputuk2Slider = uislider(app.GridLayout3);
            app.Inputuk2Slider.Limits = [-0.5 2];
            app.Inputuk2Slider.MajorTicks = [-0.5 0 0.5 1 1.5 2];
            app.Inputuk2Slider.Layout.Row = 6;
            app.Inputuk2Slider.Layout.Column = 2;

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.GridLayout8);
            app.GridLayout7.ColumnWidth = {'0.7x', '1x'};
            app.GridLayout7.RowHeight = {'1x', '1x', '1x', '1x', '1x'};
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

            % Create WeightingSliderLabel
            app.WeightingSliderLabel = uilabel(app.GridLayout7);
            app.WeightingSliderLabel.HorizontalAlignment = 'right';
            app.WeightingSliderLabel.FontSize = 14;
            app.WeightingSliderLabel.Layout.Row = 5;
            app.WeightingSliderLabel.Layout.Column = 1;
            app.WeightingSliderLabel.Text = 'Weighting';

            % Create WeightingSlider
            app.WeightingSlider = uislider(app.GridLayout7);
            app.WeightingSlider.Limits = [0 10];
            app.WeightingSlider.MinorTicks = [0 1 2 3 4 5 6 7 8 9 10];
            app.WeightingSlider.Layout.Row = 5;
            app.WeightingSlider.Layout.Column = 2;
            app.WeightingSlider.Value = 1;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = predictionconcepts_control101

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

