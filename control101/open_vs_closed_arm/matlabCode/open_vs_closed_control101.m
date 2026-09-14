classdef open_vs_closed_control101 < matlab.apps.AppBase
    %OPEN_VS_CLOSED_CONTROL101
    %   This resource focuses on open loop control of a mechatronic system,
    %   that is a simple single limb robot arm. It is shown that, in
    %   principle one can determine an input signal to move the arim to a
    %   desirable position. However, computing errors and other uncertainty
    %   will cause the accuracy to be poor, some times leading to failure
    %   of delivery.  
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
        ContinuousButton              matlab.ui.control.Button
        Move60Button                  matlab.ui.control.Button
        Move90Button                  matlab.ui.control.Button
        Move30Button                  matlab.ui.control.Button
        SimulationparametersgreenisselectionLabel  matlab.ui.control.Label
        GridLayout6                   matlab.ui.container.GridLayout
        CreateresponsesButton         matlab.ui.control.Button
        GridLayout5                   matlab.ui.container.GridLayout
        GridLayout14                  matlab.ui.container.GridLayout
        Image                         matlab.ui.control.Image
        AcomparisonofopenandclosedloopstrategiesonaroboticarmLabel  matlab.ui.control.Label
        GridLayout3                   matlab.ui.container.GridLayout
        ResponseswithuncertaintyarethesolidlinesLabel  matlab.ui.control.Label
        GainSlider                    matlab.ui.control.Slider
        GainSliderLabel               matlab.ui.control.Label
        LoadSlider                    matlab.ui.control.Slider
        LoadSliderLabel               matlab.ui.control.Label
        UncertaintyinmodelparametersLabel  matlab.ui.control.Label
        GridLayout2                   matlab.ui.container.GridLayout
        AnimationchoiceDropDown       matlab.ui.control.DropDown
        AnimationchoiceDropDownLabel  matlab.ui.control.Label
        LoadchoiceDropDown            matlab.ui.control.DropDown
        LoadchoiceDropDownLabel       matlab.ui.control.Label
        SystemModelLabel              matlab.ui.control.Label
        UIAxes2_3                     matlab.ui.control.UIAxes
        UIAxes2                       matlab.ui.control.UIAxes
        UIAxes2_2                     matlab.ui.control.UIAxes
    end

%     File written by J.A.Rossiter, University of Sheffield
%     See website for more files like this.
%     https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
%     A simple interface to compar and contrast different PID auto-tuning algorithms 
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
        arm  % handle for the arm
        angle=1; % handle for the choice of target (1 to 4)
        choiceanim =1
        loadonarm  % handle for load

        % System parameters
        num = 1
        den = [1 1 0]
        Knum = [2 2]
        Kden = [1 2]
        load=1    
        Loadnumber=1
        loadvalues = [1 2 2.5];
        wmax=0.4
        endtime = [5 8 12];  % simulation time varies with load
        noterms = 2001;  % number of terms in open loop search for input

        min_time_signal
        max_speed_signal
        target_signal
        Ums = cell(1,3) % bang bang signal and time for max speed
        ttms = cell(1,3)
        Umt = cell(1,3) % bang bang signal and time for min time
        ttmt = cell(1,3)
        

    end
    
    methods (Access = private)
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION FOR BASIC STEP RESPONSES for a single move
function [simdata,target_signal] = determineresponses(app)

          % collect save data and rearrange
          
            min_time_signal.signals.values=app.Umt{app.Loadnumber}(app.angle,:)';
            min_time_signal.time = app.ttmt{app.Loadnumber}(app.angle,:)';
            max_speed_signal.signals.values=app.Ums{app.Loadnumber}(app.angle,:)';
            max_speed_signal.time = app.ttms{app.Loadnumber}(app.angle,:)';
            target_signal.time = app.ttms{app.Loadnumber}(app.angle,:)';
            target_signal.signals.values=[ones(size(target_signal.time))]*app.angle*pi/6 ;  

            % This function determines all the closed-loop step responses 
            simIn = Simulink.SimulationInput('open_vs_closed_simulink_control101');
            simIn = simIn.setVariable('num',app.num);
            simIn = simIn.setVariable('den',app.den);
            simIn = simIn.setVariable('Knum',app.Knum);
            simIn = simIn.setVariable('Kden',app.Kden);
            simIn = simIn.setVariable('min_time_signal',min_time_signal);
            simIn = simIn.setVariable('max_speed_signal',max_speed_signal);
            simIn = simIn.setVariable('target_signal',target_signal);
            simIn = simIn.setVariable('endtime',app.endtime(app.Loadnumber));
                                   
            % Simulation - 
            simdata=sim(simIn);
                       
            
        end  % end of determineresponses
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION FOR RESPONSES with multiple sequential target
%%%%%%%%%%%% changes

        % for a more continuous single with multiple angle changes
        % +60, -30,+60, -90, +30
        function [simdata,target_signal] = determineresponses2(app)

          % collect save data and rearrange
          
            min_time_signal.signals.values=[app.Umt{app.Loadnumber}(2,:)';...
                -app.Umt{app.Loadnumber}(1,2:end)';app.Umt{app.Loadnumber}(2,2:end)';...
                -app.Umt{app.Loadnumber}(3,2:end)';app.Umt{app.Loadnumber}(1,2:end)'];

            min_time_signal.time = [app.ttmt{app.Loadnumber}(2,:)'];
            min_time_signal.time = [min_time_signal.time;min_time_signal.time(end)+app.ttmt{app.Loadnumber}(1,2:end)'];
            min_time_signal.time = [min_time_signal.time;min_time_signal.time(end)+app.ttmt{app.Loadnumber}(2,2:end)'];
            min_time_signal.time = [min_time_signal.time;min_time_signal.time(end)+app.ttmt{app.Loadnumber}(3,2:end)'];
            min_time_signal.time = [min_time_signal.time;min_time_signal.time(end)+app.ttmt{app.Loadnumber}(1,2:end)'];

            max_speed_signal.signals.values=[app.Ums{app.Loadnumber}(2,:)';...
                -app.Ums{app.Loadnumber}(1,2:end)';app.Ums{app.Loadnumber}(2,2:end)';...
                -app.Ums{app.Loadnumber}(3,2:end)';app.Ums{app.Loadnumber}(1,2:end)'];
            max_speed_signal.time = [app.ttms{app.Loadnumber}(2,:)'];
            max_speed_signal.time = [max_speed_signal.time;max_speed_signal.time(end)+app.ttms{app.Loadnumber}(1,2:end)'];
            max_speed_signal.time = [max_speed_signal.time;max_speed_signal.time(end)+app.ttms{app.Loadnumber}(2,2:end)'];
            max_speed_signal.time = [max_speed_signal.time;max_speed_signal.time(end)+app.ttms{app.Loadnumber}(3,2:end)'];
            max_speed_signal.time = [max_speed_signal.time;max_speed_signal.time(end)+app.ttms{app.Loadnumber}(1,2:end)'];

            target_signal.time = [app.ttms{app.Loadnumber}(2,:)'];
            target_signal.time = [target_signal.time;target_signal.time(end)+app.ttms{app.Loadnumber}(1,2:end)'];
            target_signal.time = [target_signal.time;target_signal.time(end)+app.ttms{app.Loadnumber}(2,2:end)'];
            target_signal.time = [target_signal.time;target_signal.time(end)+app.ttms{app.Loadnumber}(3,2:end)'];
            target_signal.time = [target_signal.time;target_signal.time(end)+app.ttms{app.Loadnumber}(1,2:end)'];
            tt=[ones(size(app.ttms{app.Loadnumber}(2,:)'))];tt1=tt(2:end);
            target_signal.signals.values=[tt*pi/3;tt1*pi/6;tt1*pi/2;-tt1*0;tt1*pi/6];  

%keyboard

            % This function determines all the closed-loop step responses 
            simIn = Simulink.SimulationInput('open_vs_closed_simulink_control101');
            simIn = simIn.setVariable('num',app.num);
            simIn = simIn.setVariable('den',app.den);
            simIn = simIn.setVariable('Knum',app.Knum);
            simIn = simIn.setVariable('Kden',app.Kden);
            simIn = simIn.setVariable('min_time_signal',min_time_signal);
            simIn = simIn.setVariable('max_speed_signal',max_speed_signal);
            simIn = simIn.setVariable('target_signal',target_signal);
            simIn = simIn.setVariable('endtime',app.endtime(app.Loadnumber)*5);
                                   
            % Simulation - 
            simdata=sim(simIn);
                       
            
        end  % end of determineresponses

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Create a picture of arm and handles to support the animation
        function app = plotarm(app)
            hold(app.UIAxes2_3,'off')
            tray1=plot(app.UIAxes2_3,0,2.2,'ko','MarkerSize',50,'LineWidth',20);
            hold(app.UIAxes2_3,'on')
            text(app.UIAxes2_3,0.25,2.3,'Tray 1','FontSize',16);
            text(app.UIAxes2_3,1.35,2.05,'Tray 2','FontSize',16);
            text(app.UIAxes2_3,2.2,0.33,'Tray 4','FontSize',16);
            text(app.UIAxes2_3,2.1,1.3,'Tray 3','FontSize',16)
            tray2=plot(app.UIAxes2_3,1.1,1.9,'ko','MarkerSize',50,'LineWidth',20);
            tray3=plot(app.UIAxes2_3,1.9,1.1,'ko','MarkerSize',50,'LineWidth',20);
            tray4=plot(app.UIAxes2_3,2.2,0,'ko','MarkerSize',50,'LineWidth',20);
            app.loadonarm = plot(app.UIAxes2_3,0,2.2,'go','MarkerSize',25,'LineWidth',24);
            xarm=[-0.2,0.2,0.2,0.17,0.17,-0.17,-0.17,-0.2];
            yarm=[-0.1,-0.1,2.4,2.4,2,2,2.4,2.4];
            app.arm = fill(app.UIAxes2_3,xarm,yarm,'r');
            axis(app.UIAxes2_3,[-0.5,2.5,-0.5,2.5])
            set(app.UIAxes2_3,'XTick',[])
            set(app.UIAxes2_3,'YTick',[])
            plot(app.UIAxes2_3,0,0,'bo','MarkerSize',20,'LineWidth',3);
            hold(app.UIAxes2_3,'off');
            
                        
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Find the input signal that moves the arm as fast as possible
        % with the assumption of input constraints. Essentially only uses
        % max and min values for as short a time as possible.

        function [U,Tout] = createmintimesignals(app,Load,endtime)
           tt= linspace(0,endtime,app.noterms);
           u=[ones(1,app.noterms)];
           k=0;
           for angle=[30,60,90];
                k=k+1;
                [t1(1,k),t2(1,k)] = findtimes_internal(app,Load,angle,endtime);
                ufalse =le(tt,t1(1,k));
                ufalse2 =le(tt,t2(1,k));
                u1=-u.*ufalse2;
                u2 =u.*ufalse;
                uu=2*u2+u1;
                U(k,:)=uu;
                Tout(k,:)=tt;
           end
          
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Find the bang bang control signals giving the desired movement
        % while a sizeable time is spent at constant (MAX) velocity
        % Solution depends on load and angle
        function [U,Tout] = createmaxspeedsignals(app,T,endtime,wmax)
            
            % T is the load;
            tt= linspace(0,endtime,app.noterms);
            u=[ones(1,app.noterms)];
            k=0;

            for angle = [30,60,90]*pi/180;
                k=k+1;
                tau1 = -T*log(1-wmax);
                tau3 = T*log(1+wmax);
                tau2 = (angle +tau3 - tau1)/wmax;
                ufalse =le(tt,tau1);
                ufalse2 =ge(tt,tau1+tau2);
                ufalse3 =ge(tt,tau3+tau1+tau2);
                uc1 = ge(tt,tau1).*u;
                uc2 = ge(tt,tau1+tau2).*u;
                u2=-u.*ufalse2;
                u1 =u.*ufalse;
                u3=u.*ufalse3;
                uu=u2+u1+u3 +(uc1-uc2)*wmax;
                U(k,:)=uu;
                Tout(k,:)=tt;
            end
        end    % end of max speed function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Plot responses with the nominal and uncertain cases
        % Also produces the animation of the arm
        function results = plotresponses(app,outnominal,outuncertain,targetsignal)
            
            
            % Collate inputs and outputs for nominal system
            nomycl=outnominal.closedloopout.Data(:,2)*180/pi;
            nomymax=outnominal.max_speed_out.Data(:,2)*180/pi;
            nomymin=outnominal.min_time_out.Data(:,2)*180/pi;
            nomucl=outnominal.closedloopout.Data(:,1);
            nomumax=outnominal.max_speed_out.Data(:,1);
            nomumin=outnominal.min_time_out.Data(:,1);
            nomt=outnominal.closedloopout.time;
       
            % Collate inputs and outputs for nominal system
            unycl=outuncertain.closedloopout.Data(:,2)*180/pi;
            unymax=outuncertain.max_speed_out.Data(:,2)*180/pi;
            unymin=outuncertain.min_time_out.Data(:,2)*180/pi;
            unucl=outuncertain.closedloopout.Data(:,1);
            unumax=outuncertain.max_speed_out.Data(:,1);
            unumin=outuncertain.min_time_out.Data(:,1);
            unt=outuncertain.closedloopout.time;

            % Plot outputs
            hold(app.UIAxes2,'off')
            nomlines =plot(app.UIAxes2,nomt,nomycl,'r',nomt,nomymax,'b',nomt,nomymin,'g',...
                targetsignal.time,targetsignal.signals.values*180/pi,'k');
            hold(app.UIAxes2,'on')
            nomlines2 =plot(app.UIAxes2,unt,unycl,'r',unt,unymax,'b',unt,unymin,'g');

            set(nomlines, 'linestyle','--','linewidth',2)
            legend(app.UIAxes2,'Feedback','Max speed','Min time','target','Location','southeast')

            % Plot inputs
            hold(app.UIAxes2_2,'off')
            nomulines =plot(app.UIAxes2_2,nomt,nomucl,'r',nomt,nomumax,'b',nomt,nomumin,'g');
            hold(app.UIAxes2_2,'on')
            nomulines2 =plot(app.UIAxes2_2,unt,unucl,'r');
            set(nomulines, 'linestyle','--','linewidth',2)
            legend(app.UIAxes2_2,'Feedback','Max speed','Min time')

            % animate the arm movement
            %choice 1=fbk, 2= min time or 3=max speed
            switch app.choiceanim
                case 1
                    y = unycl*pi/180;
                case 2
                    y=unymin*pi/180;
                case 3
                    y=unymax*pi/180;
            end

            % do a move
            xarm = get(app.arm,'Xdata');
            yarm = get(app.arm,'Ydata');
            xload = get(app.loadonarm,'Xdata');
            yload = get(app.loadonarm,'Ydata');

            anglechange = y;
            for k=1:length(y);
                th = y(k);
                Rot = [cos(th) sin(th);-sin(th) cos(th)];
                Xnew = Rot*[xarm,yarm]';
                loadnew=Rot*[xload;yload];
                set(app.arm,'XData',Xnew(1,:),'YData',Xnew(2,:))
                set(app.loadonarm,'XData',loadnew(1),'YData',loadnew(2))
                pause(0.02)
            end
 
        end
 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Subfunction to find the switch times for bang bang control
        function [t1s,t2s] = findtimes_internal(app,Load,angle,endtime)

            T=Load;
            t1=linspace(0,endtime,app.noterms);
            for k=1:length(t1);   
                    alpha =exp(-t1(k)/T);
                    w = 1-alpha;
                    t2 = T*log(1+w);  % in fact t2-t1
                    beta = exp(-t2/T);
                    gamma = t2;
                    delta(k)=t1(k)-T*(1-alpha)-(gamma - T*(1-beta)) +T*(1-beta)*(1-alpha);   
            end
            
            [val,k]=min(abs(delta*180/pi-angle)); % index closest to required angle
            t1s = t1(k);  %% angle degrees
            alpha =exp(-t1s/T); 
            t2s = T*log(2-alpha);
            t2s=t2s+t1s;
        end
    
    
    
    end  %% end of methods
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
           % resize to be in middle of  the window
            movegui(app.UIFigure)
            
            %Open the manual
            if exist('open_vs_closed_control101_manual_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open open_vs_closed_control101_manual_mycopy.mlx
            else
                p1 = which('open_vs_closed_control101_manual.mlx');
                p2 = strcat(pwd,'/open_vs_closed_control101_manual_mycopy.mlx');
                copyfile(p1,p2)                
                open open_vs_closed_control101_manual_mycopy.mlx
                clear p1 p2
            end

            % Generate starting picture of the robot arm and load
            app = plotarm(app);

            % Create the min time and max speed input signals; these do not change as OL
            for k=1:3;   % index for load, rows for angles       
                [U,T] = createmaxspeedsignals(app,app.loadvalues(k),app.endtime(k),app.wmax);
                app.Ums{k}=U;app.ttms{k}=T;
                [app.Umt{k},app.ttmt{k}] = createmintimesignals(app,app.loadvalues(k),app.endtime(k));                
            end

            % variables to manage re-sizing of the window. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
                theme(app.UIFigure,"light")
            end


        end

        % Button pushed function: CreateresponsesButton
        function CreateresponsesButtonPushed(app, event)
            % Accesses the simulink file to generate the system responses
            % Ensure a viable target
            if app.angle==0;
                app.angle=1;
                app.Move30Button.BackgroundColor = [0.4,0.8,0.1];
            end

            %reset figure
            app = plotarm(app);
           
            % Plot the results
            switch app.angle
                case 4  % Using a continuous simulation
                    % Certain case
                    app.num = 1;
                    app.den = [app.load 1 0];
                    [outnominal,targetsignal] = determineresponses2(app);
        
                    % uncertain case
                    app.num = (1+app.GainSlider.Value);
                    app.den = [app.load*(1+app.LoadSlider.Value) 1 0];
                    [outuncertain] = determineresponses2(app);

                    plotresponses(app,outnominal,outuncertain,targetsignal)
               
                otherwise % does a single move from zero
                    % Certain case
                    app.num = 1;
                    app.den = [app.load 1 0];
                    [outnominal,targetsignal] = determineresponses(app);
        
                    % uncertain case
                    app.num = (1+app.GainSlider.Value);
                    app.den = [app.load*(1+app.LoadSlider.Value) 1 0];
                    [outuncertain] = determineresponses(app);

                    plotresponses(app,outnominal,outuncertain,targetsignal)
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

        % Button pushed function: Move30Button
        function Move30ButtonPushed(app, event)
            % update colours and stored variables to reflect target choice
            Value = app.Move30Button.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.Move30Button.BackgroundColor = [1 0 0];
                    app.angle=0;
                    
            else
                    app.Move30Button.BackgroundColor = [0.4,0.8,0.1];
                    app.angle=1;
                    app.Move60Button.BackgroundColor = [1 0 0];
                    app.Move90Button.BackgroundColor = [1 0 0];
                    app.ContinuousButton.BackgroundColor = [1 0 0];
            end

        end

        % Button pushed function: Move90Button
        function Move90ButtonPushed(app, event)
            % update colours and stored variables to reflect target choice
            Value = app.Move90Button.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.Move90Button.BackgroundColor = [1 0 0];
                    app.angle=0;
                    
            else
                    app.Move90Button.BackgroundColor = [0.4,0.8,0.1];
                    app.angle=3;
                    app.Move60Button.BackgroundColor = [1 0 0];
                    app.Move30Button.BackgroundColor = [1 0 0];
                    app.ContinuousButton.BackgroundColor = [1 0 0];
                   
            end
        end

        % Button pushed function: Move60Button
        function Move60ButtonPushed(app, event)
            % update colours and stored variables to reflect target choice
            Value = app.Move60Button.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.Move60Button.BackgroundColor = [1 0 0];
                    app.angle=0;
                    
            else
                    app.Move60Button.BackgroundColor = [0.4,0.8,0.1];
                    app.angle=2;
                    app.Move30Button.BackgroundColor = [1 0 0];
                    app.Move90Button.BackgroundColor = [1 0 0];
                    app.ContinuousButton.BackgroundColor = [1 0 0];
            end
        end

        % Value changed function: GainSlider
        function GainSliderValueChanged2(app, event)
            value = app.GainSlider.Value;
            value=round(value,2);
            app.GainSlider.Value=value;       
        end

        % Value changed function: LoadSlider
        function LoadSliderValueChanged2(app, event)
            value = app.LoadSlider.Value;
            value=round(value,2);
            app.LoadSlider.Value=value;
        end

        % Button pushed function: ContinuousButton
        function ContinuousButtonPushed(app, event)
            % update colours and stored variables to reflect target choice
            Value = app.ContinuousButton.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.ContinuousButton.BackgroundColor = [1 0 0];
                    app.angle=1;
                    app.Move30Button.BackgroundColor = [0.4,0.8,0.1];
                    
            else
                    app.ContinuousButton.BackgroundColor = [0.4,0.8,0.1];
                    app.angle=4;
                    app.Move30Button.BackgroundColor = [1 0 0];
                    app.Move90Button.BackgroundColor = [1 0 0];
                    app.Move60Button.BackgroundColor = [1 0 0];
            end
        end

        % Clicked callback: LoadchoiceDropDown
        function LoadchoiceDropDownClicked(app, event)
            % Create a simple variable to store the desired load
            item = event.InteractionInformation.Item;
            
            app.load = item;
            app.Loadnumber = item;
            if app.Loadnumber==2.5; app.Loadnumber=3;end
        end

        % Value changed function: AnimationchoiceDropDown
        function AnimationchoiceDropDownValueChanged(app, event)
            % Create a simple variable to store the desired animation
            value = app.AnimationchoiceDropDown.Value;
        switch value
            case 'Feedback'
                app.choiceanim=1;
            case 'Min time'
                app.choiceanim=2;
            case 'Max speed'
                app.choiceanim=3;
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
            app.UIFigure.Position = [100 100 1183 687];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1.5x', '2x'};
            app.GridLayout.RowHeight = {'0.4x', '0.2x', '1.5x', '0.8x', '1x'};

            % Create UIAxes2_2
            app.UIAxes2_2 = uiaxes(app.GridLayout);
            title(app.UIAxes2_2, 'Input response comparisons')
            xlabel(app.UIAxes2_2, 'time (sec)')
            zlabel(app.UIAxes2_2, 'Z')
            app.UIAxes2_2.FontSize = 14;
            app.UIAxes2_2.Layout.Row = [4 5];
            app.UIAxes2_2.Layout.Column = 2;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout);
            title(app.UIAxes2, 'Output response comparisons')
            xlabel(app.UIAxes2, 'time (sec)')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 14;
            app.UIAxes2.Layout.Row = 3;
            app.UIAxes2.Layout.Column = 2;

            % Create UIAxes2_3
            app.UIAxes2_3 = uiaxes(app.GridLayout);
            title(app.UIAxes2_3, 'Animation')
            zlabel(app.UIAxes2_3, 'Z')
            app.UIAxes2_3.XTick = [];
            app.UIAxes2_3.YTick = [];
            app.UIAxes2_3.FontSize = 14;
            app.UIAxes2_3.Layout.Row = [3 5];
            app.UIAxes2_3.Layout.Column = 3;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout2.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout2.Layout.Row = 4;
            app.GridLayout2.Layout.Column = 1;
            app.GridLayout2.BackgroundColor = [0.902 1 0.502];

            % Create SystemModelLabel
            app.SystemModelLabel = uilabel(app.GridLayout2);
            app.SystemModelLabel.BackgroundColor = [1 1 0];
            app.SystemModelLabel.HorizontalAlignment = 'center';
            app.SystemModelLabel.FontSize = 14;
            app.SystemModelLabel.FontWeight = 'bold';
            app.SystemModelLabel.Layout.Row = 1;
            app.SystemModelLabel.Layout.Column = [1 2];
            app.SystemModelLabel.Text = 'System Model';

            % Create LoadchoiceDropDownLabel
            app.LoadchoiceDropDownLabel = uilabel(app.GridLayout2);
            app.LoadchoiceDropDownLabel.HorizontalAlignment = 'right';
            app.LoadchoiceDropDownLabel.FontSize = 18;
            app.LoadchoiceDropDownLabel.Layout.Row = 2;
            app.LoadchoiceDropDownLabel.Layout.Column = 1;
            app.LoadchoiceDropDownLabel.Text = 'Load choice';

            % Create LoadchoiceDropDown
            app.LoadchoiceDropDown = uidropdown(app.GridLayout2);
            app.LoadchoiceDropDown.Items = {'1', '2', '2.5'};
            app.LoadchoiceDropDown.FontSize = 18;
            app.LoadchoiceDropDown.Layout.Row = 2;
            app.LoadchoiceDropDown.Layout.Column = 2;
            app.LoadchoiceDropDown.ClickedFcn = createCallbackFcn(app, @LoadchoiceDropDownClicked, true);
            app.LoadchoiceDropDown.Value = '1';

            % Create AnimationchoiceDropDownLabel
            app.AnimationchoiceDropDownLabel = uilabel(app.GridLayout2);
            app.AnimationchoiceDropDownLabel.HorizontalAlignment = 'right';
            app.AnimationchoiceDropDownLabel.FontSize = 18;
            app.AnimationchoiceDropDownLabel.Layout.Row = 3;
            app.AnimationchoiceDropDownLabel.Layout.Column = 1;
            app.AnimationchoiceDropDownLabel.Text = 'Animation choice';

            % Create AnimationchoiceDropDown
            app.AnimationchoiceDropDown = uidropdown(app.GridLayout2);
            app.AnimationchoiceDropDown.Items = {'Feedback', 'Min time', 'Max speed'};
            app.AnimationchoiceDropDown.ValueChangedFcn = createCallbackFcn(app, @AnimationchoiceDropDownValueChanged, true);
            app.AnimationchoiceDropDown.FontSize = 18;
            app.AnimationchoiceDropDown.Layout.Row = 3;
            app.AnimationchoiceDropDown.Layout.Column = 2;
            app.AnimationchoiceDropDown.Value = 'Feedback';

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout);
            app.GridLayout3.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout3.RowHeight = {'1x', '1x', '1x', '0.8x'};
            app.GridLayout3.Layout.Row = 3;
            app.GridLayout3.Layout.Column = 1;
            app.GridLayout3.BackgroundColor = [1 0.8 0.6];

            % Create UncertaintyinmodelparametersLabel
            app.UncertaintyinmodelparametersLabel = uilabel(app.GridLayout3);
            app.UncertaintyinmodelparametersLabel.BackgroundColor = [1 0.502 0.302];
            app.UncertaintyinmodelparametersLabel.HorizontalAlignment = 'center';
            app.UncertaintyinmodelparametersLabel.WordWrap = 'on';
            app.UncertaintyinmodelparametersLabel.FontSize = 18;
            app.UncertaintyinmodelparametersLabel.FontWeight = 'bold';
            app.UncertaintyinmodelparametersLabel.Layout.Row = 1;
            app.UncertaintyinmodelparametersLabel.Layout.Column = [1 2];
            app.UncertaintyinmodelparametersLabel.Text = 'Uncertainty in model parameters';

            % Create LoadSliderLabel
            app.LoadSliderLabel = uilabel(app.GridLayout3);
            app.LoadSliderLabel.HorizontalAlignment = 'right';
            app.LoadSliderLabel.FontSize = 18;
            app.LoadSliderLabel.Layout.Row = 2;
            app.LoadSliderLabel.Layout.Column = 1;
            app.LoadSliderLabel.Text = 'Load';

            % Create LoadSlider
            app.LoadSlider = uislider(app.GridLayout3);
            app.LoadSlider.Limits = [-0.2 0.2];
            app.LoadSlider.ValueChangedFcn = createCallbackFcn(app, @LoadSliderValueChanged2, true);
            app.LoadSlider.FontSize = 18;
            app.LoadSlider.Layout.Row = 2;
            app.LoadSlider.Layout.Column = 2;
            app.LoadSlider.Value = 0.02;

            % Create GainSliderLabel
            app.GainSliderLabel = uilabel(app.GridLayout3);
            app.GainSliderLabel.HorizontalAlignment = 'right';
            app.GainSliderLabel.FontSize = 18;
            app.GainSliderLabel.Layout.Row = 3;
            app.GainSliderLabel.Layout.Column = 1;
            app.GainSliderLabel.Text = 'Gain';

            % Create GainSlider
            app.GainSlider = uislider(app.GridLayout3);
            app.GainSlider.Limits = [-0.2 0.2];
            app.GainSlider.ValueChangedFcn = createCallbackFcn(app, @GainSliderValueChanged2, true);
            app.GainSlider.FontSize = 18;
            app.GainSlider.Layout.Row = 3;
            app.GainSlider.Layout.Column = 2;
            app.GainSlider.Value = -0.01;

            % Create ResponseswithuncertaintyarethesolidlinesLabel
            app.ResponseswithuncertaintyarethesolidlinesLabel = uilabel(app.GridLayout3);
            app.ResponseswithuncertaintyarethesolidlinesLabel.BackgroundColor = [0.9294 0.6941 0.1255];
            app.ResponseswithuncertaintyarethesolidlinesLabel.WordWrap = 'on';
            app.ResponseswithuncertaintyarethesolidlinesLabel.FontSize = 16;
            app.ResponseswithuncertaintyarethesolidlinesLabel.Layout.Row = 4;
            app.ResponseswithuncertaintyarethesolidlinesLabel.Layout.Column = [1 2];
            app.ResponseswithuncertaintyarethesolidlinesLabel.Text = 'Responses with uncertainty are the solid lines.';

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout);
            app.GridLayout5.ColumnWidth = {'1.4x', '1x'};
            app.GridLayout5.RowHeight = {'1x'};
            app.GridLayout5.Layout.Row = [1 2];
            app.GridLayout5.Layout.Column = [2 3];
            app.GridLayout5.BackgroundColor = [0.6 1 1];

            % Create AcomparisonofopenandclosedloopstrategiesonaroboticarmLabel
            app.AcomparisonofopenandclosedloopstrategiesonaroboticarmLabel = uilabel(app.GridLayout5);
            app.AcomparisonofopenandclosedloopstrategiesonaroboticarmLabel.BackgroundColor = [0 1 1];
            app.AcomparisonofopenandclosedloopstrategiesonaroboticarmLabel.HorizontalAlignment = 'center';
            app.AcomparisonofopenandclosedloopstrategiesonaroboticarmLabel.WordWrap = 'on';
            app.AcomparisonofopenandclosedloopstrategiesonaroboticarmLabel.FontSize = 24;
            app.AcomparisonofopenandclosedloopstrategiesonaroboticarmLabel.FontWeight = 'bold';
            app.AcomparisonofopenandclosedloopstrategiesonaroboticarmLabel.Layout.Row = 1;
            app.AcomparisonofopenandclosedloopstrategiesonaroboticarmLabel.Layout.Column = 1;
            app.AcomparisonofopenandclosedloopstrategiesonaroboticarmLabel.Text = 'A comparison of open and closed-loop strategies on a robotic arm';

            % Create GridLayout14
            app.GridLayout14 = uigridlayout(app.GridLayout5);
            app.GridLayout14.RowHeight = {'1x'};
            app.GridLayout14.Layout.Row = 1;
            app.GridLayout14.Layout.Column = 2;

            % Create Image
            app.Image = uiimage(app.GridLayout14);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = [1 2];
            app.Image.ImageSource = fullfile(pathToMLAPP, 'UoSlogo.png');

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.ColumnWidth = {'1x'};
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

            % Create GridLayout15
            app.GridLayout15 = uigridlayout(app.GridLayout);
            app.GridLayout15.ColumnWidth = {'2x'};
            app.GridLayout15.RowHeight = {'1x'};
            app.GridLayout15.Layout.Row = 5;
            app.GridLayout15.Layout.Column = 1;

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout15);
            app.GridLayout4.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout4.Layout.Row = 1;
            app.GridLayout4.Layout.Column = 1;
            app.GridLayout4.BackgroundColor = [0.702 1 0.702];

            % Create SimulationparametersgreenisselectionLabel
            app.SimulationparametersgreenisselectionLabel = uilabel(app.GridLayout4);
            app.SimulationparametersgreenisselectionLabel.BackgroundColor = [0 1 0];
            app.SimulationparametersgreenisselectionLabel.HorizontalAlignment = 'center';
            app.SimulationparametersgreenisselectionLabel.WordWrap = 'on';
            app.SimulationparametersgreenisselectionLabel.FontSize = 14;
            app.SimulationparametersgreenisselectionLabel.FontWeight = 'bold';
            app.SimulationparametersgreenisselectionLabel.Layout.Row = 1;
            app.SimulationparametersgreenisselectionLabel.Layout.Column = [1 2];
            app.SimulationparametersgreenisselectionLabel.Text = 'Simulation parameters (green is selection)';

            % Create Move30Button
            app.Move30Button = uibutton(app.GridLayout4, 'push');
            app.Move30Button.ButtonPushedFcn = createCallbackFcn(app, @Move30ButtonPushed, true);
            app.Move30Button.BackgroundColor = [0.4 0.8 0.102];
            app.Move30Button.FontSize = 14;
            app.Move30Button.Layout.Row = 2;
            app.Move30Button.Layout.Column = 1;
            app.Move30Button.Text = 'Move 30';

            % Create Move90Button
            app.Move90Button = uibutton(app.GridLayout4, 'push');
            app.Move90Button.ButtonPushedFcn = createCallbackFcn(app, @Move90ButtonPushed, true);
            app.Move90Button.BackgroundColor = [1 0 0];
            app.Move90Button.FontSize = 14;
            app.Move90Button.Layout.Row = 2;
            app.Move90Button.Layout.Column = 2;
            app.Move90Button.Text = 'Move 90';

            % Create Move60Button
            app.Move60Button = uibutton(app.GridLayout4, 'push');
            app.Move60Button.ButtonPushedFcn = createCallbackFcn(app, @Move60ButtonPushed, true);
            app.Move60Button.WordWrap = 'on';
            app.Move60Button.BackgroundColor = [1 0 0];
            app.Move60Button.FontSize = 14;
            app.Move60Button.Layout.Row = 3;
            app.Move60Button.Layout.Column = 1;
            app.Move60Button.Text = 'Move 60';

            % Create ContinuousButton
            app.ContinuousButton = uibutton(app.GridLayout4, 'push');
            app.ContinuousButton.ButtonPushedFcn = createCallbackFcn(app, @ContinuousButtonPushed, true);
            app.ContinuousButton.BackgroundColor = [1 0 0];
            app.ContinuousButton.FontSize = 14;
            app.ContinuousButton.Layout.Row = 3;
            app.ContinuousButton.Layout.Column = 2;
            app.ContinuousButton.Text = 'Continuous';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = open_vs_closed_control101

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

