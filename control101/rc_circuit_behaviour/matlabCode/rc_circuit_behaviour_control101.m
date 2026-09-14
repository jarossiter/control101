classdef rc_circuit_behaviour_control101 < matlab.apps.AppBase
    %RC_CIRCUIT_BEHAVIOUR_CONTROL101
    %   File written by J.A.Rossiter, University of Sheffield
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   
    %   A simple interface to practice behaviour of a RC circuit with and
    %   without leakage.
    %   
    %   Some notes and engineering background are in the partner
    %   livescript  file:    rc_circuit_behaviour_control101_manual.mlx
    %   
    %   A group of similar files can be downloaded through MATLAB
    %   add-ons with the toolbox name:  control101
    %      
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        Slider                   matlab.ui.control.RangeSlider
        SliderLabel              matlab.ui.control.Label
        GridLayout               matlab.ui.container.GridLayout
        GridLayout4              matlab.ui.container.GridLayout
        LeakageR2Slider          matlab.ui.control.Slider
        LeakageR2SliderLabel     matlab.ui.control.Label
        CircuitparametersRfracdqdtqCvLabel  matlab.ui.control.Label
        ResistanceRSlider        matlab.ui.control.Slider
        ResistanceRSliderLabel   matlab.ui.control.Label
        CapacitanceCSlider       matlab.ui.control.Slider
        CapacitanceCSliderLabel  matlab.ui.control.Label
        GridLayout3              matlab.ui.container.GridLayout
        Image3                   matlab.ui.control.Image
        Image2                   matlab.ui.control.Image
        SimulateButton           matlab.ui.control.Button
        GridLayout2              matlab.ui.container.GridLayout
        Image                    matlab.ui.control.Image
        BehaviourofanRCcircuitwithleakageLabel  matlab.ui.control.Label
        UIAxes3                  matlab.ui.control.UIAxes
        UIAxes2                  matlab.ui.control.UIAxes
        UIAxes                   matlab.ui.control.UIAxes
    end

    
    % The next section defines all the core variables used in the code 
    % that it may be convenient to have available in the various
    % subfunctions
    properties (Access = private)
        originalsize     % product of width and height for font sizing

        legstring=cell(1); % To store legends
        tt     % time vector
        q_values  % charge for nominal circuit
        vt      % voltage for nominal circuit
        it      % current for nominal circuit
        T   % time constant
        v

        % leakage circuit
        i2_values
        q2_values
        i_values
        v2t
        T2  % time constant

        
        
    end
    
    methods (Access = private)
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Manage the animation and legends
%%%%%%%%%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
        function app = animationoflineplots(app)
            
            % for scaling the graphs to ensure normalisation
            factor = double(round(max(app.i_values)/(10*max(app.q2_values)))*10);
            
            % initialise figure for current and charge
            hold(app.UIAxes2,'off') % Clear  figure
            plot(app.UIAxes2,0,0)
            current1 = plot(app.UIAxes2,0,app.it(1),'b');
            hold(app.UIAxes2,'on')
            charge1 = plot(app.UIAxes2,0,app.q_values(1),'r');
            current2 = plot(app.UIAxes2,0,app.i_values(1),'b--');
            charge2 = plot(app.UIAxes2,0,app.q2_values(1),'r--');
            mm=max([app.i_values,app.q2_values]);
            plot(app.UIAxes2,[app.T,app.T],[0,mm],'g:','LineWidth',2);
            plot(app.UIAxes2,[app.T2,app.T2],[0,mm],'m:','LineWidth',2);
            grid(app.UIAxes2)
            legend(app.UIAxes2,'Current (nominal)',['Charge (nominal)*',num2str(factor)],...
                'Current (leakage)',['Charge (leakage)*',num2str(factor)],...
                'T (nominal)','T (leakage)')
            xlabel(app.UIAxes2,'Seconds')
        
         % voltage plots
            hold(app.UIAxes3,'off') % Clear  figure
            plot(app.UIAxes3,0,0)
            voltagec1 = plot(app.UIAxes3,0,app.vt(1),'b');
            hold(app.UIAxes3,'on')
            voltagec2 = plot(app.UIAxes3,0,app.v2t(1),'b--');
            voltager1 = plot(app.UIAxes3,0,app.v-app.vt(1),'r');
            voltager2 = plot(app.UIAxes3,0,app.v-app.v2t(1),'r--');
            xlabel(app.UIAxes3,'Seconds')
            legend(app.UIAxes3,'Capacitor (nominal)','Capacitor (leakage)',...
                'Resistor (nominal)','Resistor (leakage)','Location','east')
            
            % picture
            hold(app.UIAxes,'off')
            plot(app.UIAxes,[1,2,2,1,1],[0,0,0.4,0.4,0],'k','linewidth',2')
            hold(app.UIAxes,'on')
            plot(app.UIAxes,[2.5,3.5],[0.6,0.6],'k',[2.5 3.5],[-0.2,-0.2],'k','linewidth',8)
            axis(app.UIAxes,[0.5,4,-0.3,0.7])
            a=0;
            h2=fill(app.UIAxes,[2.5 3.5 3.5 2.5],[-0.19,-0.19,-0.19+a,-0.19+a],'r');
            x=[0.5 1.2 1.9];y=0.12;l=0.4;w=0.3;tip=0.2;
            arrow4 = makearrow(app,x(1),y,l,w,tip);
            arrow5 = makearrow(app,x(2),y,l,w,tip);
            arrow6 = makearrow(app,x(3),y,l,w,tip);
            %[x x x+l,x+l,x+l+0.2,x+l,x+l]
            %[y y+w,y+w,y+w+0.1,y+w/2,y-0.1,y]

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% animation 

            for k=1:length(app.tt);


                % update line plot and tank picture
                set(current1,'Ydata',app.it(1:k),'Xdata',app.tt(1:k));
                set(charge1,'Ydata',factor*app.q_values(1:k),'Xdata',app.tt(1:k));
                set(current2,'Ydata',app.i_values(1:k),'Xdata',app.tt(1:k));
                set(charge2,'Ydata',factor*app.q2_values(1:k),'Xdata',app.tt(1:k));
    
                set(voltagec1,'Ydata',app.vt(1:k),'Xdata',app.tt(1:k));
                set(voltagec2,'Ydata',app.v2t(1:k),'Xdata',app.tt(1:k));
                set(voltager1,'Ydata',app.v-app.vt(1:k),'Xdata',app.tt(1:k));
                set(voltager2,'Ydata',app.v-app.v2t(1:k),'Xdata',app.tt(1:k));
    
                % diagram
                wn=double(w*app.it(k)/max(app.it));
                tip2=double(tip*app.it(k)/max(app.it));
                xx=x(1);
                VV=[[xx xx xx+l,xx+l,xx+l+2*tip2,xx+l,xx+l];...
                [y y+wn,y+wn,y+wn+tip2,y+wn/2,y-tip2,y]]';
                arrow4.Vertices=VV;
                xx=x(2);
                VV=[[xx xx xx+l,xx+l,xx+l+2*tip2,xx+l,xx+l];...
                [y y+wn,y+wn,y+wn+tip2,y+wn/2,y-tip2,y]]';
                arrow5.Vertices=VV;
                xx=x(3);
                VV=[[xx xx xx+l,xx+l,xx+l+2*tip2,xx+l,xx+l];...
                [y y+wn,y+wn,y+wn+tip2,y+wn/2,y-tip2,y]]';
                arrow6.Vertices=VV;
                

                a=0.02*app.v2t(k)*8;
                h2.Vertices(:,2)=[-0.19,-0.19,-0.19+a,-0.19+a]';
                % manage the animation
                 pause(0.05);              
                
            end
            
        end  % end of animation



        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function determines all the closed-loop UNIT step responses
            % Based on current values of the sliders

            function app = loop_responses(app)
      
            % collect parameters and determine responses for the nominal
            % case
            R=app.ResistanceRSlider.Value; 
            C=app.CapacitanceCSlider.Value; 
            v=5;
            T=R*C; Gain =C;
            syms q(t)
            qt=dsolve(T*diff(q)+q==C*v,q(0)==0');
            app.tt=linspace(0,4*T,100);
            app.q_values=subs(qt,app.tt);
            app.vt=app.q_values/C; % voltage on capacitor
            app.it=(v-app.vt)/R;  % current flow
            app.T=T;
            app.v=v;
            
            
            % leakage circuit responses
            R2=app.LeakageR2Slider.Value; 
            T2=R*R2*C/(R+R2);  Gain2=1/(R+R2);
            syms i2(t)
            i2t=dsolve(T2*diff(i2)+i2==Gain2*v,i2(0)==0');
            app.i2_values=subs(i2t,app.tt);
            app.v2t=app.i2_values*R2; % voltage on capacitor
            app.i_values=(v-app.v2t)/R;
            app.T2=T2;
            app.q2_values=app.v2t*app.CapacitanceCSlider.Value;
            
            
            end   % end of responses subfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Control interaction during the animation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function  disablebuttons(app)
            set(app.SimulateButton, 'Enable', 'off');
             set(app.ResistanceRSlider, 'Enable', 'off');
            set(app.LeakageR2Slider, 'Enable', 'off');
            set(app.CapacitanceCSlider, 'Enable', 'off');
        end
        
        function enablebuttons(app)
            set(app.SimulateButton, 'Enable', 'on');
             set(app.ResistanceRSlider, 'Enable', 'on');
            set(app.CapacitanceCSlider, 'Enable', 'on');
            set(app.LeakageR2Slider, 'Enable', 'on');

        end

        
        % Function to draw an arrow with given x,y coordinates, length and
        % width
        function [arrowhandle] = makearrow(app,x,y,lengtharrow,widtharrow,tip)

            arrowhandle=fill(app.UIAxes,[x x x+lengtharrow,x+lengtharrow,...
                x+lengtharrow+2*tip,x+lengtharrow,x+lengtharrow],...
            [y y+widtharrow,y+widtharrow,...
            y+widtharrow+tip,y+widtharrow/2,y-tip,y],'r');
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
           % resize to be in middle of  the window
            movegui(app.UIFigure)
            
            % Open the manual
            if exist('rc_circuit_behaviour_control101_manual_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open rc_circuit_behaviour_control101_manual_mycopy.mlx
            else
                p1 = which('rc_circuit_behaviour_control101_manual.mlx');
                p2 = strcat(pwd,'/rc_circuit_behaviour_control101_manual_mycopy.mlx');
                copyfile(p1,p2)                
                open rc_circuit_behaviour_control101_manual_mycopy.mlx
                clear p1 p2
            end

            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);

            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
                theme(app.UIFigure,"light")
            end

      
        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
            
            disablebuttons(app);

            app = loop_responses(app); % create responses
            app = animationoflineplots(app); % manage the animations

            enablebuttons(app);

        end

        % Value changed function: ResistanceRSlider
        function ResistanceRSliderValueChanged(app, event)
            value = app.ResistanceRSlider.Value;
            value=round(value,1); 
            if value<0.1;value=0.1;end
            app.ResistanceRSlider.Value=value;
            
        end

        % Value changed function: CapacitanceCSlider
        function CapacitanceCSliderValueChanged(app, event)
            value = app.CapacitanceCSlider.Value;
            value=round(value,3);
            app.CapacitanceCSlider.Value=value;
            
           
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
            app.UIFigure.Position = [100 100 938 779];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1.5x'};
            app.GridLayout.RowHeight = {'0.4x', '1.2x', '1.2x'};

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Animation of current and charge')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.XTick = [];
            app.UIAxes.XTickLabel = '';
            app.UIAxes.YTick = [];
            app.UIAxes.YTickLabel = '';
            app.UIAxes.FontSize = 18;
            app.UIAxes.Layout.Row = 3;
            app.UIAxes.Layout.Column = 1;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout);
            title(app.UIAxes2, 'Charge and current responses')
            xlabel(app.UIAxes2, 'Time (s)')
            ylabel(app.UIAxes2, 'Amps/Coulombs')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 14;
            app.UIAxes2.Layout.Row = 2;
            app.UIAxes2.Layout.Column = 2;

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.GridLayout);
            title(app.UIAxes3, 'Voltage across components')
            xlabel(app.UIAxes3, 'Time (s)')
            ylabel(app.UIAxes3, 'voltage')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.FontSize = 14;
            app.UIAxes3.Layout.Row = 3;
            app.UIAxes3.Layout.Column = 2;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = 2;
            app.GridLayout2.BackgroundColor = [0.6 1 1];

            % Create BehaviourofanRCcircuitwithleakageLabel
            app.BehaviourofanRCcircuitwithleakageLabel = uilabel(app.GridLayout2);
            app.BehaviourofanRCcircuitwithleakageLabel.BackgroundColor = [0 1 1];
            app.BehaviourofanRCcircuitwithleakageLabel.HorizontalAlignment = 'center';
            app.BehaviourofanRCcircuitwithleakageLabel.FontSize = 24;
            app.BehaviourofanRCcircuitwithleakageLabel.FontWeight = 'bold';
            app.BehaviourofanRCcircuitwithleakageLabel.Layout.Row = 1;
            app.BehaviourofanRCcircuitwithleakageLabel.Layout.Column = [1 2];
            app.BehaviourofanRCcircuitwithleakageLabel.Text = 'Behaviour of an RC circuit with leakage';

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

            % Create Image2
            app.Image2 = uiimage(app.GridLayout3);
            app.Image2.Layout.Row = 1;
            app.Image2.Layout.Column = 2;
            app.Image2.ImageSource = fullfile(pathToMLAPP, 'rccircuit.png');

            % Create Image3
            app.Image3 = uiimage(app.GridLayout3);
            app.Image3.Layout.Row = 1;
            app.Image3.Layout.Column = 3;
            app.Image3.ImageSource = fullfile(pathToMLAPP, 'rccircuit2.png');

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout4.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout4.Layout.Row = 2;
            app.GridLayout4.Layout.Column = 1;
            app.GridLayout4.BackgroundColor = [0.902 1 0.502];

            % Create CapacitanceCSliderLabel
            app.CapacitanceCSliderLabel = uilabel(app.GridLayout4);
            app.CapacitanceCSliderLabel.HorizontalAlignment = 'center';
            app.CapacitanceCSliderLabel.FontSize = 16;
            app.CapacitanceCSliderLabel.Layout.Row = 2;
            app.CapacitanceCSliderLabel.Layout.Column = 1;
            app.CapacitanceCSliderLabel.Text = 'Capacitance (C)';

            % Create CapacitanceCSlider
            app.CapacitanceCSlider = uislider(app.GridLayout4);
            app.CapacitanceCSlider.Limits = [0 0.1];
            app.CapacitanceCSlider.ValueChangedFcn = createCallbackFcn(app, @CapacitanceCSliderValueChanged, true);
            app.CapacitanceCSlider.MinorTicks = [500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000];
            app.CapacitanceCSlider.FontSize = 16;
            app.CapacitanceCSlider.Layout.Row = 2;
            app.CapacitanceCSlider.Layout.Column = 2;
            app.CapacitanceCSlider.Value = 0.02;

            % Create ResistanceRSliderLabel
            app.ResistanceRSliderLabel = uilabel(app.GridLayout4);
            app.ResistanceRSliderLabel.HorizontalAlignment = 'center';
            app.ResistanceRSliderLabel.FontSize = 16;
            app.ResistanceRSliderLabel.Layout.Row = 3;
            app.ResistanceRSliderLabel.Layout.Column = 1;
            app.ResistanceRSliderLabel.Text = 'Resistance (R)';

            % Create ResistanceRSlider
            app.ResistanceRSlider = uislider(app.GridLayout4);
            app.ResistanceRSlider.Limits = [1 2];
            app.ResistanceRSlider.ValueChangedFcn = createCallbackFcn(app, @ResistanceRSliderValueChanged, true);
            app.ResistanceRSlider.MinorTicks = [0 100 200 300 400 500 600 700 800 900 1000];
            app.ResistanceRSlider.FontSize = 16;
            app.ResistanceRSlider.Layout.Row = 3;
            app.ResistanceRSlider.Layout.Column = 2;
            app.ResistanceRSlider.Value = 1;

            % Create CircuitparametersRfracdqdtqCvLabel
            app.CircuitparametersRfracdqdtqCvLabel = uilabel(app.GridLayout4);
            app.CircuitparametersRfracdqdtqCvLabel.BackgroundColor = [1 1 0];
            app.CircuitparametersRfracdqdtqCvLabel.HorizontalAlignment = 'center';
            app.CircuitparametersRfracdqdtqCvLabel.FontSize = 18;
            app.CircuitparametersRfracdqdtqCvLabel.FontWeight = 'bold';
            app.CircuitparametersRfracdqdtqCvLabel.Layout.Row = 1;
            app.CircuitparametersRfracdqdtqCvLabel.Layout.Column = [1 2];
            app.CircuitparametersRfracdqdtqCvLabel.Interpreter = 'latex';
            app.CircuitparametersRfracdqdtqCvLabel.Text = 'Circuit parameters: R\frac{dq}{dt} + q/C =  v';

            % Create LeakageR2SliderLabel
            app.LeakageR2SliderLabel = uilabel(app.GridLayout4);
            app.LeakageR2SliderLabel.HorizontalAlignment = 'center';
            app.LeakageR2SliderLabel.FontSize = 16;
            app.LeakageR2SliderLabel.Layout.Row = 4;
            app.LeakageR2SliderLabel.Layout.Column = 1;
            app.LeakageR2SliderLabel.Text = 'Leakage (R2)';

            % Create LeakageR2Slider
            app.LeakageR2Slider = uislider(app.GridLayout4);
            app.LeakageR2Slider.Limits = [10 50];
            app.LeakageR2Slider.MinorTicks = [0 100 200 300 400 500 600 700 800 900 1000];
            app.LeakageR2Slider.FontSize = 16;
            app.LeakageR2Slider.Layout.Row = 4;
            app.LeakageR2Slider.Layout.Column = 2;
            app.LeakageR2Slider.Value = 20;

            % Create SliderLabel
            app.SliderLabel = uilabel(app.UIFigure);
            app.SliderLabel.HorizontalAlignment = 'right';
            app.SliderLabel.Position = [1227 -135 36 22];
            app.SliderLabel.Text = 'Slider';

            % Create Slider
            app.Slider = uislider(app.UIFigure, 'range');
            app.Slider.Position = [1285 -126 150 3];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = rc_circuit_behaviour_control101

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

