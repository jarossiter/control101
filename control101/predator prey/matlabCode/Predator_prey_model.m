classdef Predator_prey_model < matlab.apps.AppBase
    %PREDATOR_PREY_MODEL
    %   File written by Z.Song with some support from J.A.Rossiter,
    %   University of Sheffield
    %   See website for more files like this.
    %     
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   
    %   A simple interface to practice behaviour of a simple predator-prey
    %   model subject to changes in prey intrinsic growth rate, attack rate
    %   by predator, hunter condition and predator reproduction rate.
    %        
    %   Some notes and engineering background are in the partner livescript
    %   file:    Predator_prey_model_manual.mlx 
    %   A group of similar files can be downloaded through MATLAB add-ons
    %   with the toolbox name:  control101
    %      
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    FILE ORGANISATION
    %   A section defining the core variables stored in "app"
    %   
    %   A section with subfunctions doing the core computations
    %   i) define behaviour models; 
    %   ii) find linear responses to inputs and disturbances; 
    %   iii) initialise figures for animations and analysis; 
    %   iv) control the animations
    %   v) switch interaction on and off during animations
    %   vi) clean figures and legends so can begin a new investigation
    %   vii) callbacks (subfunctions) for every item in the interface to
    %   control decimal places and the like.
    %   
    %   A callback which activates with the 'start simulation' button and
    %   runs the subfunctions in turn.

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        GridLayout                  matlab.ui.container.GridLayout
        GridLayout6_2               matlab.ui.container.GridLayout
        PredatorGrowthSlider        matlab.ui.control.Slider
        PredatorGrowthSliderLabel   matlab.ui.control.Label
        HuntersSlider               matlab.ui.control.Slider
        HuntersSliderLabel          matlab.ui.control.Label
        OtherFactorsLabel           matlab.ui.control.Label
        GridLayout6                 matlab.ui.container.GridLayout
        GetAttackedSlider           matlab.ui.control.Slider
        GetAttackedSliderLabel      matlab.ui.control.Label
        PreyGrowthSlider            matlab.ui.control.Slider
        PreyGrowthSliderLabel       matlab.ui.control.Label
        PreyRelatedFactorsLabel     matlab.ui.control.Label
        GridLayout4                 matlab.ui.container.GridLayout
        PreySlider                  matlab.ui.control.Slider
        PreySliderLabel             matlab.ui.control.Label
        InitialPopulationSizeLabel  matlab.ui.control.Label
        PredatorSlider              matlab.ui.control.Slider
        MassMkgLabel                matlab.ui.control.Label
        GridLayout3                 matlab.ui.container.GridLayout
        RefreshButton               matlab.ui.control.Button
        SimulateButton              matlab.ui.control.Button
        GridLayout2                 matlab.ui.container.GridLayout
        Image                       matlab.ui.control.Image
        PredatorPreyModelLabel      matlab.ui.control.Label
        UIAxes4                     matlab.ui.control.UIAxes
        UIAxes3                     matlab.ui.control.UIAxes
        UIAxes2                     matlab.ui.control.UIAxes
    end

    
    
    
    % The next section defines all the core variables used in the code and
    % that it may be convenient to have available in the various
    % subfunctions
    properties (Access = private)
        originalsize     % product of width and height for font sizing

        legstring=cell(1); % To store legends
        
        % System parameters
        alpha; % Predator attack rate (0.01-0.1)
        beta; % Predator reproduction rate (0.01-0.1)
        r;  % Prey intrinsic growth rate (0.1-1)
        m;  % Predator mortality rate (0.1-1)
        h; % Predator loss rate in the absence of prey (0.1-1)

        % readings from sliders
        prey_init; % initial population of prey
        predator_init; % initial population of predator
        prey_growth; % prey growth rate
        attack_rate; % by predator
        hunter_condition; % Targets: N/A, prey, or predator
        predator_reproduction_rate;

        % for plotting legend
        prey_growth_label;
        attack_rate_label;
        hunter_label;
        predator_reproduction_label;
        lineplothandle;  % to save color in a plot

        plot_prey; % plot handle for prey change
        plot_predator; % plot handle for predator change

        theta; % to plot circle
        prey_circle; % prey population circle in animation
        prey_r; % radius of prey circle
        predator_circle; % predator population circle in animation
        predator_r; % radius of predator circle

        
        % Rectangle/bar plot to indicate:
        % prey growth rate and attack rate by predator
        prey_growth_bar;
        prey_growth_outline;
        prey_growth_actual;

        attack_rate_outline;
        attack_rate_bar;
        attack_rate_actual;


        % Text indications in animation
        prey_growth_text1;
        prey_growth_text2;

        attack_rate_text1;
        attack_rate_text2;

        prey_hunter_text; 
        predator_hunter_text;

        pred_growth_text;


        % define the ODE solver options (optional but can be helpful)
        options; 

        % Simulation parameters
        runtime = 40; % for simulation the runtime
        t; % variable to store time instants for simulation plots 
        
        t_result; % time array as simulation result
        y_result; % population array as simulation result (prey + predator)
        
        
    end
    
    methods (Access = private)
        


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  Down load data from sliders
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 function app = parameterSetUp(app)
            %%% Define car and road outline
            app.predator_init=app.PredatorSlider.Value;
            app.prey_init=app.PreySlider.Value;
            app.prey_growth = app.PreyGrowthSlider.Value;
            app.attack_rate = app.GetAttackedSlider.Value;
            app.hunter_condition = app.HuntersSlider.Value;
            app.predator_reproduction_rate = app.PredatorGrowthSlider.Value;

        % Prey Growth Rate
            if app.prey_growth == 1
                app.r = 0.6;
                app.prey_growth_label = 'L'; % low
                app.prey_growth_bar = 0.4;
            elseif app.prey_growth == 2
                app.r = 0.8;
                app.prey_growth_label = 'M'; % medium
                app.prey_growth_bar = 1;
            else
                app.r = 1;
                app.prey_growth_label = 'H'; % high
                app.prey_growth_bar = 1.6;
            end

        % Attack rate by predator
            if app.attack_rate == 1
                app.alpha = 0.01;
                app.attack_rate_label = 'L';
                app.attack_rate_bar = 0.4;
            elseif app.attack_rate == 2
                app.alpha = 0.02;
                app.attack_rate_label = 'M';
                app.attack_rate_bar = 1;
            else
                app.alpha = 0.03;
                app.attack_rate_label = 'H';
                app.attack_rate_bar = 1.6;
            end        
            
        % hunter condition
            if app.hunter_condition == 1
                app.h = 0.3;
                app.m = 0.3;
                app.hunter_label = 'N'; % No or N/A
            elseif app.hunter_condition == 2
                app.h = 0.3;
                app.m = 0.3;
                app.r = app.r * 0.7;
                app.hunter_label = 'Prey';
            else
                app.h = 0.5;
                app.m = 0.5;
                app.hunter_label = 'Pred';
            end        

        % Predator Reproduction Rate
            if app.predator_reproduction_rate == 1
                app.beta = 0.001;
                app.predator_reproduction_label = 'S';
            elseif app.predator_reproduction_rate == 2
                app.beta = 0.005;
                app.predator_reproduction_label = 'M';
            else
                app.beta = 0.07;
                app.predator_reproduction_label = 'F';
            end          
            
        end      %%% END OF PARAMETERSETUP SUBFUNCTION

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  Create Lotka-Volterra Model and Start Simulation
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function app = predatorPreyModel(app)
            
            % Simulation by solving ODE
            app.options = odeset('RelTol', 1e-6, 'AbsTol', 1e-6);

            % Set up the function handle for the Lotka-Volterra equations
            lotka_volterra_fun = @(t, y) lotka_volterra(t, y, app.r, app.alpha, app.beta, app.m, app.h);
            [app.t_result, app.y_result]=ode45(lotka_volterra_fun,[0 app.runtime],[app.prey_init; app.predator_init],app.options);

            % Define function for dynamics of lotka-volterra model
            function dxdt = lotka_volterra(t, x, r, a, b, m, h)
                % Lotka-Volterra equations
                dxdt(1,1) = r * x(1) - a * x(1) * x(2);
                dxdt(2,1) = -m * x(2) + b * x(1) * x(2) - h * x(2);
            end


            %%%%%% Settings & first frame of animation  %%%%%%%%%%%

            % Plot for population circle
            app.prey_r = rescale(app.y_result(:,1), 0.5, 2); % rescale radius to (0.5,2) according to prey population at each time step
            app.predator_r = rescale(app.y_result(:,2), 0.5, 2);

            axis(app.UIAxes4, [0 9 0 4]); % important to fix the axis during animation!
            hold(app.UIAxes4,'on')
            xlabel(app.UIAxes4,'');
            ylabel(app.UIAxes4,'');
            xticks(app.UIAxes4,[]);
            yticks(app.UIAxes4,[]);
            line_width = 1; % line width for all lines

            app.theta = linspace(-pi,pi,20);
            app.prey_circle = plot(app.UIAxes4, 3+app.prey_r(1)*sin(app.theta),2+app.prey_r(1)*cos(app.theta), 'LineWidth', line_width,'Color','b','LineStyle','--');
            text(app.UIAxes4, 2.7,2,{'   Prey','Population'},'Color','black','FontSize',14); 
            app.predator_circle = plot(app.UIAxes4, 6+app.predator_r(1)*sin(app.theta),2+app.predator_r(1)*cos(app.theta), 'LineWidth', line_width,'Color','cyan');
            text(app.UIAxes4, 5.7,2,{'Predator','Population'},'Color','black','FontSize',14);

            % Plot for prey growth rate and attack rate by predator
            app.prey_growth_outline = rectangle(app.UIAxes4,'Position',[0.5 1.2 0.5 1.7],'Curvature',0.2, 'LineWidth', line_width); 
            app.prey_growth_actual = rectangle(app.UIAxes4,'Position',[0.5 1.2 0.5 app.prey_growth_bar],'Curvature',0.2, 'LineWidth', line_width, 'FaceColor','b'); 
            app.attack_rate_outline = rectangle(app.UIAxes4,'Position',[8 1.2 0.5 1.7],'Curvature',0.2, 'LineWidth', line_width);
            app.attack_rate_actual = rectangle(app.UIAxes4,'Position',[8 1.2 0.5 app.attack_rate_bar],'Curvature',0.2, 'LineWidth', line_width, 'FaceColor','cyan');

            % Indications of prey growth rate and attack rate by predator
            app.prey_growth_text1 = text(app.UIAxes4,0.5, 1.2+1.7+0.3, {'Prey','Growth Rate'},'Color','black','FontSize',14);
            app.attack_rate_text1 = text(app.UIAxes4,8, 1.2+1.7+0.3, {'Attack Rate','by Predator'},'Color','black','FontSize',14);

            if app.prey_growth == 1
                temp1 = 'Low';
            elseif app.prey_growth == 2
                temp1 = 'Medium';
            else
                temp1 = 'High';
            end
            app.prey_growth_text2 = text(app.UIAxes4,0.5, 1.2-0.3, temp1,'Color','black','FontSize',14);

            if app.attack_rate == 1
                temp2 = 'Low';
            elseif app.attack_rate == 2
                temp2 = 'Medium';
            else
                temp2 = 'High';
            end
            app.attack_rate_text2 = text(app.UIAxes4,8, 1.2-0.3, temp2,'Color','black','FontSize',14);

            % Hunter indication
            if app.hunter_label == 'Prey'
                app.prey_hunter_text = text(app.UIAxes4, 2.7,(2+1+0.4),'Hunter!','Color','black','FontSize',14);
            elseif app.hunter_label == 'Pred'
                app.predator_hunter_text = text(app.UIAxes4, 5.7,(2+1+0.4),'Hunter!','Color','black','FontSize',14);
            end

            % Predator growth speed indication
            if app.predator_reproduction_label == 'S'
                temp = 'Slow';
            elseif app.predator_reproduction_label == 'M'
                temp = 'Medium';
            else
                temp = 'Fast';
            end
            app.pred_growth_text = text(app.UIAxes4, 5.2, 2-1-0.2, append('Predator Growth Rate: ',temp),'Color','black','FontSize',14);


        end   % end of predatorPreyModel & first frame set-up


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Animation of Population Progression
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function app = animationoflineplots(app)
            
            % initialise figure for population progression
            app.plot_prey = plot(app.UIAxes2,app.t_result,app.y_result(:,1), '--');
            set(app.plot_prey,'Color',app.lineplothandle.Color);
            set(app.plot_prey,'Linewidth',1);
            hold(app.UIAxes2,'on')

            app.plot_predator =plot(app.UIAxes2,app.t_result, app.y_result(:,2), '-'); 
            set(app.plot_predator,'Color',app.lineplothandle.Color);
            set(app.plot_predator,'Linewidth',1);

            xlabel(app.UIAxes2,'Time (weeks)')
            ylabel(app.UIAxes2,'Population')
            hold(app.UIAxes2,'on')
            xlim(app.UIAxes2,[0,app.runtime]);

            grid(app.UIAxes2,'on');
            xticks(app.UIAxes2,'auto');
            yticks(app.UIAxes2,'auto');
            xticklabels(app.UIAxes2,'auto');
            yticklabels(app.UIAxes2,'auto');


            kkk=legend(app.UIAxes2,'Prey','Predator'); 
            set(kkk,'fontsize',10);


            % Animation
            for k=1:length(app.t_result)
                set(app.plot_prey,'Ydata',app.y_result(1:k,1),'Xdata',app.t_result(1:k)); 
                set(app.plot_predator,'Ydata',app.y_result(1:k,2),'Xdata',app.t_result(1:k));
                
                set(app.prey_circle,'Xdata',3+app.prey_r(k)*sin(app.theta),'Ydata',2+app.prey_r(k)*cos(app.theta));
                set(app.predator_circle,'Xdata', 6+app.predator_r(k)*sin(app.theta),'Ydata',2+app.predator_r(k)*cos(app.theta));

                pause(0.01);
            end

            hold(app.UIAxes4,"off"); % hold off the animation for next plot


        end  % end of animation

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  Phase Plot (no animation) and Managing Legends
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
 function app = phaseplot(app)
            %%  Set up legend
            if isempty(app.legstring{1})
                nlegstring=0;
            else
                nlegstring = length(app.legstring);
            end
            
            app.legstring{nlegstring+1}=['Pred0 = ',num2str(app.predator_init),', Prey0 = ',num2str(app.prey_init),...
                ', PreyG = ',app.prey_growth_label,', PredA = ',app.attack_rate_label,', ',...
                'Hunt = ',app.hunter_label,', PredG = ',app.predator_reproduction_label];
            
            % Plot the results
            app.lineplothandle=plot(app.UIAxes3, app.y_result(:,1), app.y_result(:,2), '-','Linewidth',1);

            xlabel(app.UIAxes3,'Prey Population');
            ylabel(app.UIAxes3,'Predator Population');
            xticks(app.UIAxes3,'auto');
            yticks(app.UIAxes3,'auto');
            xticklabels(app.UIAxes3,'auto');
            yticklabels(app.UIAxes3,'auto');

            kk=legend(app.UIAxes3,app.legstring,'Location','northeast'); 
            set(kk,'fontsize',8);
            hold(app.UIAxes3,'on');
            %hold(app.UIAxes3,'off');
        end  % end of phase plot



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Control interaction during the animation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function  disablebuttons(app)
            set(app.SimulateButton, 'Enable', 'off');
            set(app.RefreshButton, 'Enable', 'off');
            set(app.GetAttackedSlider, 'Enable', 'off');
            set(app.PreyGrowthSlider, 'Enable', 'off');
            set(app.PreySlider, 'Enable', 'off');
            set(app.PredatorSlider, 'Enable', 'off');
            set(app.PredatorGrowthSlider, 'Enable', 'off');
            set(app.HuntersSlider, 'Enable', 'off');
        end
        
        function enablebuttons(app)
            set(app.SimulateButton, 'Enable', 'on');
            set(app.RefreshButton, 'Enable', 'on');
            set(app.GetAttackedSlider, 'Enable', 'on');
            set(app.PreyGrowthSlider, 'Enable', 'on');
            set(app.PreySlider, 'Enable', 'on');
            set(app.PredatorSlider, 'Enable', 'on');
            set(app.PredatorGrowthSlider, 'Enable', 'on');
            set(app.HuntersSlider, 'Enable', 'on');
        end


    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Open the manual
            if exist('Predator_prey_model_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open Predator_prey_model_mycopy.mlx
            else
                p1 = which('Predator_prey_model_manual.mlx');
                copyfile(p1,pwd);
                system("rename " + "Predator_prey_model_manual.mlx" + " " + "Predator_prey_model_mycopy.mlx");
                open Predator_prey_model_mycopy.mlx
                clear p1
            end
            
            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
                theme(app.UIFigure,"light")
            end

            % app = parameterSetUp(app); % define population circles for animation
        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
            
            disablebuttons(app);
            

            plot(app.UIAxes4,0,0); % clear animation from last simulation
            app = parameterSetUp(app); % setup parameters
            app = predatorPreyModel(app); % simulation based on lotka-volterra model
            app = phaseplot(app); % draw phase plot
            app = animationoflineplots(app); % draw population vs. time 
      

            enablebuttons(app);

        end

        % Button pushed function: RefreshButton
        function RefreshButtonPushed(app, event)
            %% Clean all the figures and legend so user can begin afresh
             hold(app.UIAxes3,'off')
             hold(app.UIAxes2,'off')
             hold(app.UIAxes4,'off')
             plot(app.UIAxes3,0,0)
             plot(app.UIAxes2,0,0)
             plot(app.UIAxes4,0,0)
             app.legstring=cell(1);
        end

        % Value changed function: PredatorSlider
        function PredatorSliderValueChanged(app, event)
            value = app.PredatorSlider.Value;
            value=round(value,-1);
            app.PredatorSlider.Value=value;
            app = parameterSetUp(app);
           
        end

        % Size changed function: UIFigure
        function UIFigureSizeChanged(app, event)
            position = app.UIFigure.Position;
                                 
           % Determine the current size
           newSize = position(3) * position(4);
           numberofchanges = length(app.originalsize);
           
           % Do not use these lines at start up
           if numberofchanges>0
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

        % Value changed function: PreySlider
        function PreySliderValueChanged(app, event)
            value = app.PreySlider.Value;
            value=round(value,-2);
            app.PreySlider.Value=value;
            app = parameterSetUp(app);
           
        end

        % Value changed function: PreyGrowthSlider
        function PreyGrowthSliderValueChanged(app, event)
            value = app.PreyGrowthSlider.Value;
            value = round(value,0); 
            app.PreyGrowthSlider.Value=value;
            app = parameterSetUp(app);
        end

        % Value changed function: GetAttackedSlider
        function GetAttackedSliderValueChanged(app, event)
            value = app.GetAttackedSlider.Value;
            value = round(value,0); % 
            app.GetAttackedSlider.Value=value;
            app = parameterSetUp(app);
        end

        % Value changed function: HuntersSlider
        function HuntersSliderValueChanged(app, event)
            value = app.HuntersSlider.Value;
            value = round(value,0); % 
            app.HuntersSlider.Value=value;
            app = parameterSetUp(app);            
        end

        % Value changed function: PredatorGrowthSlider
        function PredatorGrowthSliderValueChanged(app, event)
            value = app.PredatorGrowthSlider.Value;
            value = round(value,0); % 
            app.PredatorGrowthSlider.Value=value;
            app = parameterSetUp(app);            
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
            app.UIFigure.Position = [100 100 1428 860];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1.3x', '1.3x'};
            app.GridLayout.RowHeight = {'0.4x', '1x', '1x', '1x'};

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout);
            title(app.UIAxes2, 'Predator/Prey Populations Over Time')
            xlabel(app.UIAxes2, 'Time (weeks)')
            ylabel(app.UIAxes2, 'Population')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.XTick = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
            app.UIAxes2.XTickLabel = '';
            app.UIAxes2.YTickLabel = '';
            app.UIAxes2.FontSize = 18;
            app.UIAxes2.Layout.Row = [3 4];
            app.UIAxes2.Layout.Column = 2;

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.GridLayout);
            title(app.UIAxes3, 'Phase Plane Plot')
            xlabel(app.UIAxes3, 'Prey Population')
            ylabel(app.UIAxes3, 'Predator Population')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.XTick = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
            app.UIAxes3.XTickLabel = '';
            app.UIAxes3.YTickLabel = '';
            app.UIAxes3.FontSize = 18;
            app.UIAxes3.Layout.Row = [3 4];
            app.UIAxes3.Layout.Column = 3;

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.GridLayout);
            title(app.UIAxes4, 'Animation of Predator-Prey Model')
            app.UIAxes4.XTick = [];
            app.UIAxes4.YTick = [];
            app.UIAxes4.FontSize = 18;
            app.UIAxes4.Layout.Row = 2;
            app.UIAxes4.Layout.Column = [2 3];

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = [2 3];
            app.GridLayout2.BackgroundColor = [0.6 1 1];

            % Create PredatorPreyModelLabel
            app.PredatorPreyModelLabel = uilabel(app.GridLayout2);
            app.PredatorPreyModelLabel.BackgroundColor = [0 1 1];
            app.PredatorPreyModelLabel.HorizontalAlignment = 'center';
            app.PredatorPreyModelLabel.FontSize = 36;
            app.PredatorPreyModelLabel.FontWeight = 'bold';
            app.PredatorPreyModelLabel.Layout.Row = 1;
            app.PredatorPreyModelLabel.Layout.Column = [1 2];
            app.PredatorPreyModelLabel.Text = 'Predator Prey Model';

            % Create Image
            app.Image = uiimage(app.GridLayout2);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 3;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'UoSlogo.png');

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout);
            app.GridLayout3.RowHeight = {'1x'};
            app.GridLayout3.Layout.Row = 1;
            app.GridLayout3.Layout.Column = 1;
            app.GridLayout3.BackgroundColor = [1 0.6 0.8];

            % Create SimulateButton
            app.SimulateButton = uibutton(app.GridLayout3, 'push');
            app.SimulateButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateButtonPushed, true);
            app.SimulateButton.BackgroundColor = [1 0.2 0.702];
            app.SimulateButton.FontSize = 24;
            app.SimulateButton.FontWeight = 'bold';
            app.SimulateButton.Layout.Row = 1;
            app.SimulateButton.Layout.Column = 1;
            app.SimulateButton.Text = 'Simulate';

            % Create RefreshButton
            app.RefreshButton = uibutton(app.GridLayout3, 'push');
            app.RefreshButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshButtonPushed, true);
            app.RefreshButton.BackgroundColor = [1 0.2 0.702];
            app.RefreshButton.FontSize = 24;
            app.RefreshButton.FontWeight = 'bold';
            app.RefreshButton.Layout.Row = 1;
            app.RefreshButton.Layout.Column = 2;
            app.RefreshButton.Text = 'Refresh';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout4.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout4.Layout.Row = 2;
            app.GridLayout4.Layout.Column = 1;
            app.GridLayout4.BackgroundColor = [0.902 1 0.502];

            % Create MassMkgLabel
            app.MassMkgLabel = uilabel(app.GridLayout4);
            app.MassMkgLabel.HorizontalAlignment = 'center';
            app.MassMkgLabel.FontSize = 18;
            app.MassMkgLabel.Layout.Row = 2;
            app.MassMkgLabel.Layout.Column = 1;
            app.MassMkgLabel.Text = 'Predator';

            % Create PredatorSlider
            app.PredatorSlider = uislider(app.GridLayout4);
            app.PredatorSlider.ValueChangedFcn = createCallbackFcn(app, @PredatorSliderValueChanged, true);
            app.PredatorSlider.FontSize = 18;
            app.PredatorSlider.Layout.Row = 2;
            app.PredatorSlider.Layout.Column = 2;
            app.PredatorSlider.Value = 20;

            % Create InitialPopulationSizeLabel
            app.InitialPopulationSizeLabel = uilabel(app.GridLayout4);
            app.InitialPopulationSizeLabel.BackgroundColor = [1 1 0];
            app.InitialPopulationSizeLabel.HorizontalAlignment = 'center';
            app.InitialPopulationSizeLabel.FontSize = 18;
            app.InitialPopulationSizeLabel.FontWeight = 'bold';
            app.InitialPopulationSizeLabel.Layout.Row = 1;
            app.InitialPopulationSizeLabel.Layout.Column = [1 2];
            app.InitialPopulationSizeLabel.Text = 'Initial Population Size';

            % Create PreySliderLabel
            app.PreySliderLabel = uilabel(app.GridLayout4);
            app.PreySliderLabel.HorizontalAlignment = 'center';
            app.PreySliderLabel.FontSize = 18;
            app.PreySliderLabel.Layout.Row = 3;
            app.PreySliderLabel.Layout.Column = 1;
            app.PreySliderLabel.Text = 'Prey';

            % Create PreySlider
            app.PreySlider = uislider(app.GridLayout4);
            app.PreySlider.Limits = [0 400];
            app.PreySlider.MajorTicks = [0 100 200 300 400];
            app.PreySlider.MajorTickLabels = {'0', '100', '200', '300', '400'};
            app.PreySlider.ValueChangedFcn = createCallbackFcn(app, @PreySliderValueChanged, true);
            app.PreySlider.FontSize = 18;
            app.PreySlider.Layout.Row = 3;
            app.PreySlider.Layout.Column = 2;
            app.PreySlider.Value = 100;

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout6.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout6.Layout.Row = 3;
            app.GridLayout6.Layout.Column = 1;
            app.GridLayout6.BackgroundColor = [0.702 1 0.702];

            % Create PreyRelatedFactorsLabel
            app.PreyRelatedFactorsLabel = uilabel(app.GridLayout6);
            app.PreyRelatedFactorsLabel.BackgroundColor = [0 1 0];
            app.PreyRelatedFactorsLabel.HorizontalAlignment = 'center';
            app.PreyRelatedFactorsLabel.FontSize = 18;
            app.PreyRelatedFactorsLabel.FontWeight = 'bold';
            app.PreyRelatedFactorsLabel.Layout.Row = 1;
            app.PreyRelatedFactorsLabel.Layout.Column = [1 2];
            app.PreyRelatedFactorsLabel.Text = 'Prey-Related Factors';

            % Create PreyGrowthSliderLabel
            app.PreyGrowthSliderLabel = uilabel(app.GridLayout6);
            app.PreyGrowthSliderLabel.HorizontalAlignment = 'center';
            app.PreyGrowthSliderLabel.FontSize = 18;
            app.PreyGrowthSliderLabel.Layout.Row = 2;
            app.PreyGrowthSliderLabel.Layout.Column = 1;
            app.PreyGrowthSliderLabel.Text = 'Prey Growth';

            % Create PreyGrowthSlider
            app.PreyGrowthSlider = uislider(app.GridLayout6);
            app.PreyGrowthSlider.Limits = [1 3];
            app.PreyGrowthSlider.MajorTicks = [1 2 3];
            app.PreyGrowthSlider.MajorTickLabels = {'Slow', 'Medium', 'Fast'};
            app.PreyGrowthSlider.ValueChangedFcn = createCallbackFcn(app, @PreyGrowthSliderValueChanged, true);
            app.PreyGrowthSlider.FontSize = 18;
            app.PreyGrowthSlider.Layout.Row = 2;
            app.PreyGrowthSlider.Layout.Column = 2;
            app.PreyGrowthSlider.Value = 2;

            % Create GetAttackedSliderLabel
            app.GetAttackedSliderLabel = uilabel(app.GridLayout6);
            app.GetAttackedSliderLabel.HorizontalAlignment = 'center';
            app.GetAttackedSliderLabel.FontSize = 18;
            app.GetAttackedSliderLabel.Layout.Row = 3;
            app.GetAttackedSliderLabel.Layout.Column = 1;
            app.GetAttackedSliderLabel.Text = 'Get Attacked';

            % Create GetAttackedSlider
            app.GetAttackedSlider = uislider(app.GridLayout6);
            app.GetAttackedSlider.Limits = [1 3];
            app.GetAttackedSlider.MajorTicks = [1 2 3];
            app.GetAttackedSlider.MajorTickLabels = {'Low', 'Medium', 'High'};
            app.GetAttackedSlider.ValueChangedFcn = createCallbackFcn(app, @GetAttackedSliderValueChanged, true);
            app.GetAttackedSlider.FontSize = 18;
            app.GetAttackedSlider.Layout.Row = 3;
            app.GetAttackedSlider.Layout.Column = 2;
            app.GetAttackedSlider.Value = 2;

            % Create GridLayout6_2
            app.GridLayout6_2 = uigridlayout(app.GridLayout);
            app.GridLayout6_2.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout6_2.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout6_2.Layout.Row = 4;
            app.GridLayout6_2.Layout.Column = 1;
            app.GridLayout6_2.BackgroundColor = [0.702 1 0.702];

            % Create OtherFactorsLabel
            app.OtherFactorsLabel = uilabel(app.GridLayout6_2);
            app.OtherFactorsLabel.BackgroundColor = [0 1 0];
            app.OtherFactorsLabel.HorizontalAlignment = 'center';
            app.OtherFactorsLabel.FontSize = 18;
            app.OtherFactorsLabel.FontWeight = 'bold';
            app.OtherFactorsLabel.Layout.Row = 1;
            app.OtherFactorsLabel.Layout.Column = [1 2];
            app.OtherFactorsLabel.Text = 'Other Factors';

            % Create HuntersSliderLabel
            app.HuntersSliderLabel = uilabel(app.GridLayout6_2);
            app.HuntersSliderLabel.HorizontalAlignment = 'center';
            app.HuntersSliderLabel.FontSize = 18;
            app.HuntersSliderLabel.Layout.Row = 2;
            app.HuntersSliderLabel.Layout.Column = 1;
            app.HuntersSliderLabel.Text = 'Hunters?';

            % Create HuntersSlider
            app.HuntersSlider = uislider(app.GridLayout6_2);
            app.HuntersSlider.Limits = [1 3];
            app.HuntersSlider.MajorTicks = [1 2 3];
            app.HuntersSlider.MajorTickLabels = {'None', 'Prey', 'Predator'};
            app.HuntersSlider.ValueChangedFcn = createCallbackFcn(app, @HuntersSliderValueChanged, true);
            app.HuntersSlider.FontSize = 18;
            app.HuntersSlider.Layout.Row = 2;
            app.HuntersSlider.Layout.Column = 2;
            app.HuntersSlider.Value = 1;

            % Create PredatorGrowthSliderLabel
            app.PredatorGrowthSliderLabel = uilabel(app.GridLayout6_2);
            app.PredatorGrowthSliderLabel.HorizontalAlignment = 'center';
            app.PredatorGrowthSliderLabel.FontSize = 18;
            app.PredatorGrowthSliderLabel.Layout.Row = 3;
            app.PredatorGrowthSliderLabel.Layout.Column = 1;
            app.PredatorGrowthSliderLabel.Text = 'Predator Growth';

            % Create PredatorGrowthSlider
            app.PredatorGrowthSlider = uislider(app.GridLayout6_2);
            app.PredatorGrowthSlider.Limits = [1 3];
            app.PredatorGrowthSlider.MajorTicks = [1 2 3];
            app.PredatorGrowthSlider.MajorTickLabels = {'Slow', 'Medium', 'Fast'};
            app.PredatorGrowthSlider.ValueChangedFcn = createCallbackFcn(app, @PredatorGrowthSliderValueChanged, true);
            app.PredatorGrowthSlider.FontSize = 18;
            app.PredatorGrowthSlider.Layout.Row = 3;
            app.PredatorGrowthSlider.Layout.Column = 2;
            app.PredatorGrowthSlider.Value = 2;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Predator_prey_model

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

