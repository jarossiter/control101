classdef conical_tank_behaviour_control101 < matlab.apps.AppBase
    %CONICAL_TANK_BEHAVIOUR_CONTROL101
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
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        GridLayout15                    matlab.ui.container.GridLayout
        GridLayout4                     matlab.ui.container.GridLayout
        BlockageButton_2                matlab.ui.control.Button
        DisturbanceflowButton           matlab.ui.control.Button
        ExternaldisturbancesredmeansnotincludedLabel  matlab.ui.control.Label
        GridLayout6                     matlab.ui.container.GridLayout
        AnimationonButton               matlab.ui.control.Button
        RefreshfigureButton             matlab.ui.control.Button
        CreateresponsesButton           matlab.ui.control.Button
        GridLayout5                     matlab.ui.container.GridLayout
        GridLayout14                    matlab.ui.container.GridLayout
        Image4                          matlab.ui.control.Image
        Image                           matlab.ui.control.Image
        ImpactofnonlinearcomponentsonapositioncontrolsystemLabel  matlab.ui.control.Label
        GridLayout3                     matlab.ui.container.GridLayout
        TankangledegSlider              matlab.ui.control.Slider
        TankangledegSliderLabel         matlab.ui.control.Label
        OutletresistanceRSlider         matlab.ui.control.Slider
        OutletresistanceRSliderLabel    matlab.ui.control.Label
        BlockageSlider                  matlab.ui.control.Slider
        BlockageSliderLabel             matlab.ui.control.Label
        DisturbanceflowltrsSlider_3     matlab.ui.control.Slider
        DisturbanceflowltrsSlider_3Label  matlab.ui.control.Label
        InletflowchangeltrsSlider       matlab.ui.control.Slider
        InletflowchangeltrsSliderLabel  matlab.ui.control.Label
        InitialdepthmSlider             matlab.ui.control.Slider
        InitialdepthmSliderLabel        matlab.ui.control.Label
        SimulationandmodelparametersLabel  matlab.ui.control.Label
        UIAxes4                         matlab.ui.control.UIAxes
        UIAxes3                         matlab.ui.control.UIAxes
        UIAxes2                         matlab.ui.control.UIAxes
        UIAxes2_2                       matlab.ui.control.UIAxes
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
        animationtime=5;
        Tsamp = 0.1;
        samples =100;
      
        % Simulation parameters which are fixed
        blockagetime=2400; % time that blockage introduced
        endtime=4200;     % simulation run time
        disturbanceflowtime=1200;
        qss   % expected steady-state  
        hss
        qstep = 0.01;     % change in inflow compared to steady-state
        qchangetime = 200; % time that change in flow/disturbance introduced
        Blockage    % label for legends
       
        % Model parameters needed by simulink file
        rho=1000;    % water density
        g=10;        % gravity
        R;      % constant needed to determine outflow
        C
        Ctemp
        theta  % tank angle
        theta2 % square of tangent
        itantheta2
        alpha % linear model parameters
        beta
      
        blockageonoff=0;
        disturbanceonoff=0;
        water  % handle for water picture
        waterout
        waterin

    end
    
    methods (Access = private)
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION FOR BASIC STEP RESPONSES

function [yynl,yyl,tt,ttl] = determineresponses(app)
            % This function determines all the closed-loop step responses 
            simIn = Simulink.SimulationInput('conical_tank_system_behaviour_control101_2023');
            
            simIn = simIn.setVariable('C',app.C);
            simIn = simIn.setVariable('Ctemp',app.Ctemp);
            simIn = simIn.setVariable('qss',app.qss);
            simIn = simIn.setVariable('hss',app.hss);
            simIn = simIn.setVariable('blockagetime',app.blockagetime); 
            simIn = simIn.setVariable('endtime',app.endtime);
            simIn = simIn.setVariable('qchangetime',app.qchangetime);
            simIn = simIn.setVariable('qstep',app.InletflowchangeltrsSlider.Value);
            simIn = simIn.setVariable('beta',app.beta);
            simIn = simIn.setVariable('alpha',app.alpha);
            simIn = simIn.setVariable('disturbanceflow',app.DisturbanceflowltrsSlider_3.Value);
            simIn = simIn.setVariable('disturbanceflowtime',app.disturbanceflowtime);
            simIn = simIn.setVariable('tantheta2',app.theta2);
            simIn = simIn.setVariable('itantheta2',app.itantheta2);
            simIn = simIn.setVariable('alpha',app.alpha);
      
      


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
                simIn = simIn.setVariable('disturbanceflow',0);
                app.Blockage=0;
            else
                simIn = simIn.setVariable('disturbanceflow',app.DisturbanceflowltrsSlider_3.Value);
                app.Blockage = app.BlockageSlider.Value;
            end

            % Simulation - 
            simdata=sim(simIn);
            tt=simdata.nonlineardata.time;
            ttl=simdata.lineardata.time;
            yynl = simdata.nonlineardata.signals.values; % stored in order simulink file
            yyl = simdata.lineardata.signals.values; % stored in order as shown in simulink file
  
            

        end  % end of determineresponses
 

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Set up basic picture of the tank 
        % Assume a 5 m depth allowance
        
        function app = tankoutline(app)
        % Tank outline and initial depth close to zero
        hold(app.UIAxes3,'off')
        y2 = 0.2:5.2; 
        % plot(app.UIAxes3,x2,y2,'');
        app.theta=app.TankangledegSlider.Value;
        th =tan(app.TankangledegSlider.Value*pi/180);
        x1= th*y2;
        plot(app.UIAxes3,[-fliplr(x1),x1],[fliplr(y2),y2],'k','linewidth',3);
        hold(app.UIAxes3,'on')
        depth = app.InitialdepthmSlider.Value;
        waterx = [0,-depth*th,depth*th,0];
        watery = [0,depth,depth,0];
        app.water = fill(app.UIAxes3,waterx,watery,'b');
        ylim(app.UIAxes3,[-0.5,6])
        xlim(app.UIAxes3,[-7,7])

        % width of water out reflects outlet resistance
        xdd= 0.02+4*sqrt(app.rho*app.g)/(app.OutletresistanceRSlider.Value*1000); % size of outlet
        wateroutx = [-0.1-xdd,-0.1,0.1,0.1+xdd];
        waterouty = [-0.4,0.2,0.2,-0.4];
        app.waterout = fill(app.UIAxes3,wateroutx,waterouty,'b');
        
         % width of water in reflects flow
        xx = app.InletflowchangeltrsSlider.Value *30;
        waterinx = [-xx,-0.2,0.2,xx];
        wateriny = [5.3,5.8,5.8,5.3];
        app.waterin =fill(app.UIAxes3,waterinx,wateriny,'b');

                    
        end      %%% END OF TANKOUTLINE SUBFUNCTION
        
        
   %%%%%%%%%%%%%% PROVIDES AN ANIMATION OF THE BEHAVIOUR
        function app = animationoflineplots(app)
                       
           % Collect response data
           [yynl,yyl,tt,ttl] = determineresponses(app);
           th =tan(app.TankangledegSlider.Value*pi/180);

          

            %%  Set up legend
            if isempty(app.legstring{1});
                nlegstring=0;
            else
                nlegstring = length(app.legstring);
            end
            
            app.legstring{nlegstring+1}=['Flow = ',num2str(app.InletflowchangeltrsSlider.Value),...
                ', h_{ss} = ',num2str(app.InitialdepthmSlider.Value),...
                ', \theta = ',num2str(app.TankangledegSlider.Value), ', R = ',num2str(app.OutletresistanceRSlider.Value)];

            % Plot history information
            hold(app.UIAxes4,'on')
            plot(app.UIAxes4,tt/60,[yynl(:,2)]);  % depth
            kh=legend(app.UIAxes4,app.legstring,'Location','southeast');
            set(kh,'fontsize',8);
            grid(app.UIAxes4,'on')
           
            %% initialise figure for depth response
            yplot = plot(app.UIAxes2,tt(1:2)/60,[yynl(1:2,2),yyl(1:2,1)+app.hss,yynl(1:2,5)]);
            xlim(app.UIAxes2,[0,tt(end)]/60);
            kk=legend(app.UIAxes2,'NL depth','Linear depth','Blockage (on/off)','Location','southeast');
            set(kk,'fontsize',8);
            grid(app.UIAxes2,'on')

            uplot = plot(app.UIAxes2_2,tt(1:2)/60,[yynl(1:2,[1,3])]);
            %hold(app.UIAxes2_2,'on')
            %uplot(2) = plot(app.UIAxes2_2,tt(1:2)/60,[yynl(1:2,1)]);
            xlim(app.UIAxes2,[0,tt(end)]/60);
            kk2=legend(app.UIAxes2_2,'In-flow','Out-flow','Location','southeast');
            set(kk2,'fontsize',8);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% animation of tank and level plot
            % define animation time aspects
            animationsamples = app.animationtime/app.Tsamp; % assume sample time of Tsamp
            updaterate =ceil(app.samples/animationsamples); % no of samples between pauses
            tstart=tic; tsave = tstart;

            %keyboard

            for k=2:length(tt);
                     
                % update line plot and tank picture
                % [yynl(1:k,2),yyl(1:k,1)+app.hss,yynl(1:k,5)]

                set(yplot(1),'Ydata',[yynl(1:k,2)],'Xdata',tt(1:k)/60);
                set(yplot(2),'Ydata',[yyl(1:k,1)+app.hss],'Xdata',tt(1:k)/60);
                set(yplot(3),'Ydata',[yynl(1:k,5)],'Xdata',tt(1:k)/60);
                set(app.water,'Ydata',[0,yynl(k,2),yynl(k,2),0],'Xdata',[0,-yynl(k,2)*th,yynl(k,2)*th,0]);

                set(uplot(1),'Ydata',[yynl(1:k,[1])],'Xdata',tt(1:k)/60);
                set(uplot(2),'Ydata',[yynl(1:k,3)],'Xdata',tt(1:k)/60);


                % Pause animation every updaterate samples only so rem(k,updaterate) 
                % checks for this
                if and(strcmp(app.AnimationonButton.Text,'Animation on'),not(rem(k,updaterate)));
                    pause(app.Tsamp-toc(tstart));  %% Clumsy application of sampling time
                    tstart = tic;
                    drawnow limitrate
                end
                
            end
            %ttotal= toc(tsave)  % total time taken by animation loop
        end  % end of animation
            
        
    end  %% end of methods
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
           % resize to be in middle of  the window
            movegui(app.UIFigure)
            
            %Open the manual
            if exist('conical_tank_system_simulink_control101_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open conical_tank_system_simulink_control101_mycopy.mlx
            else
                p1 = which('conical_tank_system_simulink_control101_manual.mlx');
                p2 = strcat(pwd,'/conical_tank_system_simulink_control101_mycopy.mlx');
                copyfile(p1,p2)                
                open conical_tank_system_simulink_control101_mycopy.mlx
                clear p1 p2
            end

     
            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);
            
            RefreshfigureButtonPushed(app)

            app = tankoutline(app);
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
            theme(app.UIFigure,"light")
            end

        end

        % Button pushed function: CreateresponsesButton
        function CreateresponsesButtonPushed(app, event)
           
            % non-linear model values          
            app.R=app.OutletresistanceRSlider.Value*1000;
            app.C=sqrt(app.rho*app.g)/app.R;
            app.Ctemp = app.C*(1-app.BlockageSlider.Value);  % Increase R during blockage which reduces outflow
            app.hss = app.InitialdepthmSlider.Value;
            app.qss = app.C*sqrt(app.hss);
            app.qstep = app.InletflowchangeltrsSlider.Value;
            app.theta = tan(app.TankangledegSlider.Value*pi/180);
            app.theta2 = app.theta^2*pi;
            app.itantheta2 = 1/app.theta2;

            % Linear model values
            app.alpha= 1/(app.hss^2*app.theta2);
            app.beta = -(2/(app.hss^3*app.theta2))*app.qss + app.C*1.5/(app.hss^2.5*app.theta2);     

            
            app = animationoflineplots(app);
     
                       
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

          hold(app.UIAxes4,'off')
          cla(app.UIAxes4)

          app.legstring=cell(1);
          app=tankoutline(app);
          
             
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

        % Value changed function: InletflowchangeltrsSlider
        function InletflowchangeltrsSliderValueChanged(app, event)
            value = app.InletflowchangeltrsSlider.Value;
            value=round(value*2,3)/2;
            
            app.InletflowchangeltrsSlider.Value=value;
            app = tankoutline(app);
           
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
            value=round(value*2,0)/2;
            
            app.InitialdepthmSlider.Value=value;
            app = tankoutline(app);
           
           
        end

        % Value changed function: BlockageSlider
        function BlockageSliderValueChanged(app, event)
            value = app.BlockageSlider.Value;
            value=round(value,1);
            if value ==1; value=0.9;end
            app.BlockageSlider.Value=value;
            
        end

        % Value changed function: TankangledegSlider
        function TankangledegSliderValueChanged(app, event)
            value = app.TankangledegSlider.Value;
            value=round(value,-1);
            app.TankangledegSlider.Value=value;
            app = tankoutline(app);
            
        end

        % Value changed function: OutletresistanceRSlider
        function OutletresistanceRSliderValueChanged(app, event)
            value = app.OutletresistanceRSlider.Value;
            value=round(value,0);
            app.OutletresistanceRSlider.Value=value;
            app = tankoutline(app);
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
            app.UIFigure.Position = [100 100 1258 662];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1.2x', '1.5x', '1.5x'};
            app.GridLayout.RowHeight = {'0.4x', '0.2x', '1.8x', '0.5x', '1.5x'};

            % Create UIAxes2_2
            app.UIAxes2_2 = uiaxes(app.GridLayout);
            title(app.UIAxes2_2, 'Inlet and outlet flows (NL)')
            xlabel(app.UIAxes2_2, 'time (min)')
            ylabel(app.UIAxes2_2, 'Flow (ltr/s)')
            zlabel(app.UIAxes2_2, 'Z')
            app.UIAxes2_2.FontSize = 14;
            app.UIAxes2_2.Layout.Row = [4 5];
            app.UIAxes2_2.Layout.Column = 2;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout);
            title(app.UIAxes2, 'Depth responses with linear and non-linear models')
            xlabel(app.UIAxes2, 'time (min)')
            ylabel(app.UIAxes2, 'Depth (m)')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 14;
            app.UIAxes2.Layout.Row = 3;
            app.UIAxes2.Layout.Column = 2;

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.GridLayout);
            title(app.UIAxes3, 'Tank Animation')
            xlabel(app.UIAxes3, 'metre')
            ylabel(app.UIAxes3, 'metre')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.Layout.Row = [4 5];
            app.UIAxes3.Layout.Column = 3;

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.GridLayout);
            title(app.UIAxes4, 'History of depth plots for nonlinear model')
            xlabel(app.UIAxes4, 'X')
            ylabel(app.UIAxes4, 'Y')
            zlabel(app.UIAxes4, 'Z')
            app.UIAxes4.Layout.Row = 3;
            app.UIAxes4.Layout.Column = 3;

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
            app.InitialdepthmSlider.MajorTicks = [0 1 2 3 4 5];
            app.InitialdepthmSlider.ValueChangedFcn = createCallbackFcn(app, @InitialdepthmSliderValueChanged2, true);
            app.InitialdepthmSlider.Layout.Row = 4;
            app.InitialdepthmSlider.Layout.Column = 2;
            app.InitialdepthmSlider.Value = 3;

            % Create InletflowchangeltrsSliderLabel
            app.InletflowchangeltrsSliderLabel = uilabel(app.GridLayout3);
            app.InletflowchangeltrsSliderLabel.HorizontalAlignment = 'right';
            app.InletflowchangeltrsSliderLabel.Layout.Row = 5;
            app.InletflowchangeltrsSliderLabel.Layout.Column = 1;
            app.InletflowchangeltrsSliderLabel.Text = 'Inlet flow change (ltr/s)';

            % Create InletflowchangeltrsSlider
            app.InletflowchangeltrsSlider = uislider(app.GridLayout3);
            app.InletflowchangeltrsSlider.Limits = [0 0.05];
            app.InletflowchangeltrsSlider.ValueChangedFcn = createCallbackFcn(app, @InletflowchangeltrsSliderValueChanged, true);
            app.InletflowchangeltrsSlider.Layout.Row = 5;
            app.InletflowchangeltrsSlider.Layout.Column = 2;
            app.InletflowchangeltrsSlider.Value = 0.02;

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

            % Create OutletresistanceRSliderLabel
            app.OutletresistanceRSliderLabel = uilabel(app.GridLayout3);
            app.OutletresistanceRSliderLabel.HorizontalAlignment = 'right';
            app.OutletresistanceRSliderLabel.Layout.Row = 3;
            app.OutletresistanceRSliderLabel.Layout.Column = 1;
            app.OutletresistanceRSliderLabel.Text = 'Outlet resistance (R)';

            % Create OutletresistanceRSlider
            app.OutletresistanceRSlider = uislider(app.GridLayout3);
            app.OutletresistanceRSlider.Limits = [0 10];
            app.OutletresistanceRSlider.ValueChangedFcn = createCallbackFcn(app, @OutletresistanceRSliderValueChanged, true);
            app.OutletresistanceRSlider.Layout.Row = 3;
            app.OutletresistanceRSlider.Layout.Column = 2;
            app.OutletresistanceRSlider.Value = 5;

            % Create TankangledegSliderLabel
            app.TankangledegSliderLabel = uilabel(app.GridLayout3);
            app.TankangledegSliderLabel.HorizontalAlignment = 'right';
            app.TankangledegSliderLabel.Layout.Row = 2;
            app.TankangledegSliderLabel.Layout.Column = 1;
            app.TankangledegSliderLabel.Text = 'Tank angle (deg)';

            % Create TankangledegSlider
            app.TankangledegSlider = uislider(app.GridLayout3);
            app.TankangledegSlider.Limits = [0 60];
            app.TankangledegSlider.MajorTicks = [0 10 20 30 40 50 60];
            app.TankangledegSlider.ValueChangedFcn = createCallbackFcn(app, @TankangledegSliderValueChanged, true);
            app.TankangledegSlider.Layout.Row = 2;
            app.TankangledegSlider.Layout.Column = 2;
            app.TankangledegSlider.Value = 50;

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
            app.ImpactofnonlinearcomponentsonapositioncontrolsystemLabel.Text = 'Behaviour of a  conical tank';

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
            app.GridLayout6.ColumnWidth = {'1x', '1x', '1x'};
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

            % Create AnimationonButton
            app.AnimationonButton = uibutton(app.GridLayout6, 'push');
            app.AnimationonButton.ButtonPushedFcn = createCallbackFcn(app, @AnimationonButtonPushed, true);
            app.AnimationonButton.WordWrap = 'on';
            app.AnimationonButton.BackgroundColor = [1 0.2 0.702];
            app.AnimationonButton.FontSize = 18;
            app.AnimationonButton.FontWeight = 'bold';
            app.AnimationonButton.Layout.Row = 1;
            app.AnimationonButton.Layout.Column = 3;
            app.AnimationonButton.Text = 'Animation on';

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
        function app = conical_tank_behaviour_control101

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

