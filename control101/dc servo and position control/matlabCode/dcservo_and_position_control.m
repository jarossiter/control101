classdef dcservo_and_position_control < matlab.apps.AppBase
    %DCSERVO_AND_POSITION_CONTROL
    %   A simple interface to practice the role of PI compensation for
    %   cruise control
    %   
    %   File written by J.A.Rossiter, University of Sheffield
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   
    %   Some notes and engineering background are in the partner livescript
    %   file:    cruisecontrol_manual.mlx
    %   A group of similar files can be downloaded through MATLAB add-ons
    %   with the toolbox name:  control101
    %          
    %      
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   FILE ORGANISATION
    %       A section defining the core variables stored in "app"
    %       
    %       A section with subfunctions doing the core computations
    %       i) define transfer functions for closed-loop; 
    %       ii) find linear responses to inputs and disturbances; 
    %       iii) find responses for square waves; 
    %       iv) find responses with random disturbances (timing defined in
    %   subfunction) 
    %       v) initialise figures for animations; 
    %       vi) control the animations
    %       vii) switch interaction on and off during animations
    %       viii) clean figures and legends so can begin a new
    %   investigation
    %       ix) callbacks (subfunctions) for every item in the interface to
    %   control decimal places and the like.
    %       
    %   A callback which activates with the 'start simulation' button and
    %   runs the subfunctions in turn.

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        Image2                         matlab.ui.control.Image
        GridLayout6                    matlab.ui.container.GridLayout
        AnimationOnButton              matlab.ui.control.Button
        RefreshButton                  matlab.ui.control.Button
        SimulateButton                 matlab.ui.control.Button
        GridLayout5                    matlab.ui.container.GridLayout
        Image                          matlab.ui.control.Image
        PositionvelocitycontrolwithaDCservoLabel  matlab.ui.control.Label
        GridLayout4                    matlab.ui.container.GridLayout
        DisturbancesDropDown           matlab.ui.control.DropDown
        DisturbancesDropDownLabel      matlab.ui.control.Label
        OpenorclosedloopDropDown       matlab.ui.control.DropDown
        OpenorclosedloopDropDownLabel  matlab.ui.control.Label
        SimulationparametersLabel      matlab.ui.control.Label
        GridLayout3                    matlab.ui.container.GridLayout
        FrictionBSlider                matlab.ui.control.Slider
        FrictionBSliderLabel           matlab.ui.control.Label
        GearrationSlider               matlab.ui.control.Slider
        GearrationSliderLabel          matlab.ui.control.Label
        TorqueconstantkNmampSlider     matlab.ui.control.Slider
        TorqueconstantkNmampSliderLabel  matlab.ui.control.Label
        LoadinertiaJkgm2Slider         matlab.ui.control.Slider
        LoadinertiaJkgm2Label          matlab.ui.control.Label
        ServoandloadparametersLabel    matlab.ui.control.Label
        GridLayout2                    matlab.ui.container.GridLayout
        IntegralKiSlider               matlab.ui.control.Slider
        IntegralKiLabel                matlab.ui.control.Label
        ProportionalKpSlider           matlab.ui.control.Slider
        ProportionalKpLabel            matlab.ui.control.Label
        ControlparametersMsKpKisLabel  matlab.ui.control.Label
        UIAxes                         matlab.ui.control.UIAxes
        UIAxes3                        matlab.ui.control.UIAxes
        UIAxes2                        matlab.ui.control.UIAxes
    end

%     File written by J.A.Rossiter, University of Sheffield
%     See website for more files like this.
%     https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
%     A simple interface to practice the role of PI compensation for
%     cruise control
%     Some notes and engineering background are in the partner livescript
%     file:    cruisecontrol_manual.mlx
%     A group of similar files can be downloaded through MATLAB add-ons
%     with the toolbox name:  ********************
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%  FILE ORGANISATION
%     A section defining the core variables stored in "app"
%     
%     A section with subfunctions doing the core computations
%     i) define transfer functions for closed-loop; 
%     ii) find linear responses to inputs and disturbances; 
%     iii) find responses for square waves; 
%     iv) find responses with random disturbances (timing defined in
%     subfunction) 
%     v) initialise figures for animations; 
%     vi) control the animations
%     vii) switch interaction on and off during animations
%     viii) clean figures and legends so can begin a new investigation
%     ix) callbacks (subfunctions) for every item in the interface to control decimal
%     places and the like.
%     
%     A callback which activates with the 'start simulation' button
%     and runs the subfunctions in turn.
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
    
    % The next section defines all the core variables used in the code and
    % that it may be convenient to have available in the various
    % subfunctions
    properties (Access = private)
         originalsize     % product of width and height for font sizing


        legstring=cell(1); % To store legends
        Kp;  % proportional control
        Ki;  % integral control
        h;   % handle for stig drawing
        targetposition = 50; %  for animation
        targetposition2 = 5; %  in m, fix for simplicity
        targetspeed = 1; % in m/s
        loopsize = 20;  % Size of loop for figure animation
        loopsize2 = 0.5;   % real size of loop 
        voltstep = 5;  % default voltage in open-loop
        runtime = 15;
        samples = 201;
        animationtime = 8; % how long animation will take
        Tsamp=0.1;  % update rate for animation
        timescale=linspace(0,3,201);  % for simulation the runtime
        
        Gspeed    % transfer function voltage to speed
        Gposition % transfer function voltage to position
        Gspeed2    % transfer function voltage to speed - extra friction
        Gposition2 % transfer function voltage to position - extra friction


        PI;   % PI compensator
        Gcy;   % system closed-loop transfer function (target to output)
        Gcu;   % system closed-loop transfer function (target to input)
        yr;  % output position response 
        yv   % output velocity response
        yloop % x coordinates for open-loop simulation
        xloop % x coordinates for open-loop simulation
        ur;  %  input response
        
        targetlineplot;  % needed, especially if a square wave
        utarget; % expected ss of input
        xtarget % spoke coordinates
        ytarget
        disttext % Text describing disturbance
        

    end
    
    methods (Access = private)
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION FOR BASIC STEP RESPONSES

        function app = determineclosedloopresponses(app)
            % This function determines all the closed-loop UNIT step responses
            % Based on current values of the sliders
            % Scaling required is also added using default choices

            % collect compensator and car values from the sliders
            % round values to avoid unnecessary decimal places
            app.Kp=app.ProportionalKpSlider.Value;
            app.IntegralKiSlider.Value=0;
            app.Ki=app.IntegralKiSlider.Value;
            app.PI=tf([app.Kp,app.Ki],[1 0]); % PI compensator

            % define closed-loop transfer functions
            % y = G*u 
            % y = GPI/(1+GPI)* R 
            % u = PI/(1+GPI) * R  
            app.Gcy=feedback(app.Gposition*app.PI,1);
            app.Gcu=feedback(app.PI,app.Gposition);
            
            % Define the closed-loop step responses
            app.timescale = linspace(0,app.runtime,app.samples);
            app.targetlineplot = ones(1,length(app.timescale))*app.targetposition2;

            % Update the legend
            nlegstring = length(app.legstring);
            app.legstring{nlegstring+1}=['Kp = ',num2str(app.Kp),...
                ', Ki = ',num2str(app.Ki),...
                ', Jl = ',num2str(app.LoadinertiaJkgm2Slider.Value),...
                ', k = ',num2str(app.TorqueconstantkNmampSlider.Value),...
                ', n = ',num2str(app.GearrationSlider.Value),...
                ', B = ',num2str(app.FrictionBSlider.Value)];
            
            switch app.DisturbancesDropDown.Value
                case 'None'
                    app.yr = step(app.Gcy,app.timescale)*app.targetposition2;
                    app.ur = step(app.Gcu,app.timescale)*app.targetposition2;
                case 'Transient friction'
                    app.legstring{nlegstring+1} = [app.legstring{nlegstring+1},', Friction'];
                    
                    Tsamp = app.runtime/(app.samples-1);
                    % no friction
                    Gd1 = c2d(app.Gposition,Tsamp);
                    [nd1,dd1] = tfdata(Gd1,'v');
                    % with friction
                    Gd2 = c2d(app.Gposition2,Tsamp);
                    [nd2,dd2] = tfdata(Gd2,'v');
                    % control law
                    PIDd = c2d(app.PI,Tsamp,'tustin');
                    [Mnd,Mdd] = tfdata(PIDd,'v');    
                    
                    
                    y=[0 0 0]; u=[0 0 0];
                    k1 = round(app.samples/10); k2 = round(app.samples*0.5);
                    
                    for k=3:app.samples+2;
                        % control law
                        e(k) = app.targetposition2-y(k);
                        u(k) = Mnd*e(k:-1:k-1)'-Mdd(2)*u(k-1);

                        % update model output
                        if or(k<k1,k>k2) %
                          y(k+1) = nd1(2:end)*u(k:-1:k-2)'-dd1(2:end)*y(k:-1:k-2)';
                        else
                          y(k+1) = nd2(2:end)*u(k:-1:k-2)'-dd2(2:end)*y(k:-1:k-2)';
                       
                        end
                        
                    end
                    app.yr = y(3:end);app.ur = u(3:end);

 
            end % end of switch
  
        end  % end of determineclosedloopresponses

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION FOR SPEED CONTROL RESPONSES

        function app = determineclosedloopresponses_speed(app)
            % This function determines all the closed-loop UNIT step responses
            % Based on current values of the sliders
            % Scaling required is also added using default choices

            % collect compensator and car values from the sliders
            % round values to avoid unnecessary decimal places
            app.Kp=app.ProportionalKpSlider.Value;
            app.Ki=app.IntegralKiSlider.Value;
            app.PI=tf([app.Kp,app.Ki],[1 0]); % PI compensator

            % define closed-loop transfer functions
            % y = G*u 
            % y = GPI/(1+GPI)* R 
            % u = PI/(1+GPI) * R  
            app.Gcy=feedback(app.Gspeed*app.PI,1);
            app.Gcu=feedback(app.PI,app.Gspeed);
            
            % Define the closed-loop step responses
            app.targetlineplot = ones(1,length(app.timescale))*app.targetspeed;
            app.timescale = linspace(0,app.runtime,app.samples);

            % Update legend
            nlegstring = length(app.legstring);
            app.legstring{nlegstring+1}=['Kp = ',num2str(app.Kp),...
                ', Ki = ',num2str(app.Ki),...
                ', Jl = ',num2str(app.LoadinertiaJkgm2Slider.Value),...
                ', k = ',num2str(app.TorqueconstantkNmampSlider.Value),...
                ', n = ',num2str(app.GearrationSlider.Value),...
                ', B = ',num2str(app.FrictionBSlider.Value)];

            switch app.DisturbancesDropDown.Value
                case 'None'
                    
                    app.yv = step(app.Gcy,app.timescale)*app.targetspeed;
                    app.ur = step(app.Gcu,app.timescale)*app.targetspeed;
                    position = step(app.Gcy*tf(1,[1 0]),app.timescale)*app.targetspeed;
                
                case 'Transient friction'
                    app.legstring{nlegstring+1} = [app.legstring{nlegstring+1},', Friction'];
                    
                    Tsamp = app.runtime/(app.samples-1);
                    % no friction
                    Gd1 = c2d(app.Gspeed,Tsamp);
                    [nd1,dd1] = tfdata(Gd1,'v');
                    % with friction
                    Gd2 = c2d(app.Gspeed2,Tsamp);
                    [nd2,dd2] = tfdata(Gd2,'v');
                    % control law
                    PIDd = c2d(app.PI,Tsamp,'tustin');
                    [Mnd,Mdd] = tfdata(PIDd,'v');    
                                        
                    y=[0 0 0]; u=[0 0 0]; position = [0 0 0];
                    k1 = round(app.samples/5); k2 = round(app.samples*0.6);
                    
                    for k=3:app.samples+2;
                        % control law
                        e(k) = app.targetspeed-y(k);
                        u(k) = Mnd*e(k:-1:k-1)'-Mdd(2)*u(k-1);

                        % update model output
                        if or(k<k1,k>k2) %
                          y(k+1) = nd1(2:end)*u(k:-1:k-1)'-dd1(2:end)*y(k:-1:k-1)';
                        else
                          y(k+1) = nd2(2:end)*u(k:-1:k-1)'-dd2(2:end)*y(k:-1:k-1)';
                       
                        end
                        position(k+1) = position(k)+Tsamp*y(k+1);
                    end
                    app.yv = y(3:end);app.ur = u(3:end);
                    position = position(3:end);
 
            end % end of switch

            % translate to position on a circle
            theta = position/app.loopsize2; % translate movement to an angle
            app.xloop = app.loopsize*cos(theta);
            app.yloop = app.loopsize*sin(theta);

            % Movement of spokes are linked to the target
            distance = app.timescale*app.targetspeed;
            theta2 = distance/app.loopsize2;
            app.xtarget = app.loopsize*cos(theta2);
            app.ytarget = app.loopsize*sin(theta2);

        end  % end of determineclosedloopresponses_speed

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION FOR BASIC STEP RESPONSES

function app = determineopenloopresponses(app)
            % This function determines open-loop step responses
            % Based on current values of the sliders
                      
            % Update legend
            nlegstring = length(app.legstring);
            app.legstring{nlegstring+1}=['Jl = ',num2str(app.LoadinertiaJkgm2Slider.Value),...
                ', k = ',num2str(app.TorqueconstantkNmampSlider.Value),...
                ', n = ',num2str(app.GearrationSlider.Value),...
                ', B = ',num2str(app.FrictionBSlider.Value)];

            % Define the open-loop step responses
            app.timescale = linspace(0,app.runtime,app.samples);
            switch app.DisturbancesDropDown.Value
                case 'None'
                    app.yv = step(app.Gspeed,app.timescale)*app.voltstep;
                    app.yr = step(app.Gposition,app.timescale)*app.voltstep;
                case 'Transient friction'
                    app.legstring{nlegstring+1} = [app.legstring{nlegstring+1},', Friction'];
       
                    Tsamp = app.runtime/(app.samples-1); % sample time
                    % no friction
                    Gd1 = c2d(app.Gspeed,Tsamp);
                    [nd1,dd1] = tfdata(Gd1,'v');
                    Gd2 = c2d(app.Gspeed2,Tsamp);
                    [nd2,dd2] = tfdata(Gd2,'v');
                    y=[0 0]; ys =[0 0 ]; 
                    k1 = round(app.samples/2); k2 = round(app.samples*0.8);
                    
                    for k=2:app.samples;
                        if or(k<k1,k>k2) %
                          y(k+1) = nd1(2:end)*[1;1]*app.voltstep-dd1(2:end)*y(k:-1:k-1)';
                        else
                          y(k+1) = nd2(2:end)*[1;1]*app.voltstep-dd2(2:end)*y(k:-1:k-1)';
                       
                        end
                        ys(k+1) = ys(k)+y(k+1)*Tsamp;
                    end
                    app.yv = y(2:end); app.yr = ys(2:end);
            end

            % translate to position on a circle
            theta = app.yr/app.loopsize2; % translate movement to an angle
            app.xloop = app.loopsize*cos(theta);
            app.yloop = app.loopsize*sin(theta);
            app.ur = ones(1,app.samples)*app.voltstep;

        end  % end of determineopenloopresponses


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION FOR animation of line plots and stig
        
        function updatelineplots(app)

            % update target line if and only if clean figure
            if length(app.legstring)==2;
                
                plot(app.UIAxes2,app.timescale,app.targetlineplot,'g--');
                xlabel(app.UIAxes2,'time (sec)')
                hold(app.UIAxes2,'on')

                app.utarget=plot(app.UIAxes3,app.timescale,app.targetlineplot*0,'g--');
                xlabel(app.UIAxes3,'time (sec)')
                hold(app.UIAxes3,'on');
            else
                set(app.utarget,'Ydata',app.targetlineplot*0)
            end
            xlim(app.UIAxes2,[0,app.timescale(end)]);
            xlim(app.UIAxes3,[0,app.timescale(end)]);
            app.UIAxes2.Title.String='Position';
            app.UIAxes2.YLabel.String='m';

            % Initialise line plot values
            outputs = plot(app.UIAxes2,app.timescale(1),app.yr(1));
            inputs = plot(app.UIAxes3,app.timescale(1),app.ur(1));
            legend(app.UIAxes3,app.legstring);
           

            % update animation with a loop with time pauses
            animationsamples = app.animationtime/app.Tsamp; % assume sample time of Tsamp
            updaterate =ceil(81/animationsamples); % no of samples between pauses
            tstart=tic; tsave = tstart;
            scale = app.targetposition/app.targetposition2;
            k1 = round(app.samples/10); k2 = round(app.samples*0.5); % for disturbance

            for k=1:app.samples;

                % animation of figure with car picture
                set(app.h.seat1,'Xdata',app.h.xseat1+app.yr(k)*scale);
                set(app.h.seat2,'Xdata',app.h.xseat2+app.yr(k)*scale);
                set(app.h.hbody,'Xdata',app.h.xhbody+app.yr(k)*scale);

                % animation of Line plots
                set(outputs,'Xdata',app.timescale(1:k),'Ydata',app.yr(1:k));  %% update depth response
                set(inputs,'Xdata',app.timescale(1:k),'Ydata',app.ur(1:k));  %% update depth response

                % Friction illustration
                if strcmp(app.DisturbancesDropDown.Value,'Transient friction')
                    if or(k<k1,k>k2) %
                          set(app.disttext,'color',[1 1 1]);
                        else
                          set(app.disttext,'color',[1 0 0]);
                    end
                 end % end of disturbance check

                % Pause animation every updaterate samples only so rem(k,updaterate) 
                % checks for this
                if and(strcmp(app.AnimationOnButton.Text,'Animation On'),not(rem(k,updaterate)));
                    pause(app.Tsamp-toc(tstart));  %% Clumsy application of sampling time
                    tstart = tic;
                    drawnow limitrate
                end         

            end
            
            %ttotal= toc(tsave)  % total time taken by animation loop
            
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION FOR animation of line plots and pilot during
%%%%%%%%%%%% open-loop behaviour
        
function updateopenloopplots(app)

            % No target line in open-loop case
            % ss = dcgain(app.Gspeed)*app.volt;

            xlim(app.UIAxes2,[0,app.timescale(end)]);
            xlim(app.UIAxes3,[0,app.timescale(end)]);
            app.UIAxes2.Title.String='Velocity';
            app.UIAxes2.YLabel.String='m/s';

            % Initialise line plot values
            outputs = plot(app.UIAxes2,app.timescale(1),app.yv(1));
            inputs = plot(app.UIAxes3,app.timescale(1),app.ur(1));
            legend(app.UIAxes3,app.legstring{2:end});
            hold(app.UIAxes2,'on')
            hold(app.UIAxes3,'on')

            % update animation with a loop with time pauses
            animationsamples = app.animationtime/app.Tsamp; % assume sample time of Tsamp
            updaterate =ceil(81/animationsamples); % no of samples between pauses
            tstart=tic; tsave = tstart;
            k1 = round(app.samples/2); k2 = round(app.samples*0.8);

            for k=1:app.samples;

                % animation of figure with car picture
                set(app.h.seat1,'Xdata',app.h.xseat1+app.xloop(k)-app.loopsize);
                set(app.h.seat2,'Xdata',app.h.xseat2+app.xloop(k)-app.loopsize);
                set(app.h.hbody,'Xdata',app.h.xhbody+app.xloop(k)-app.loopsize);
                set(app.h.seat1,'Ydata',app.h.yseat1+app.yloop(k));
                set(app.h.seat2,'Ydata',app.h.yseat2+app.yloop(k));
                set(app.h.hbody,'Ydata',app.h.yhbody+app.yloop(k));

                % animation of Line plots
                set(outputs,'Xdata',app.timescale(1:k),'Ydata',app.yv(1:k));  %% update position response
                set(inputs,'Xdata',app.timescale(1:k),'Ydata',app.ur(1:k));  %% update input response

                % Friction illustration
                if strcmp(app.DisturbancesDropDown.Value,'Transient friction')
                    if or(k<k1,k>k2) %
                          set(app.disttext,'color',[1 1 1]);
                        else
                          set(app.disttext,'color',[1 0 0]);
                    end
                 end % end of disturbance check

                % Pause animation every updaterate samples only so rem(k,updaterate) 
                % checks for this
                if and(strcmp(app.AnimationOnButton.Text,'Animation On'),not(rem(k,updaterate)));
                    pause(app.Tsamp-toc(tstart));  %% Clumsy application of sampling time
                    tstart = tic;
                    drawnow limitrate
                end         
            end
            
            %ttotal= toc(tsave)  % total time taken by animation loop
            
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION FOR animation of line plots and pilot during
%%%%%%%%%%%% closed-loop speed control
        
function updatespeedplots(app)

            % update target line if and only if clean figure
            if length(app.legstring)==2;
                
                plot(app.UIAxes2,app.timescale,app.targetlineplot,'g--');
                xlabel(app.UIAxes2,'time (sec)')
                hold(app.UIAxes2,'on')

                app.utarget=plot(app.UIAxes3,app.timescale,app.targetlineplot/dcgain(app.Gspeed),'g--');
                xlabel(app.UIAxes3,'time (sec)')
                hold(app.UIAxes3,'on');
            else
                set(app.utarget,'Ydata',app.targetlineplot/dcgain(app.Gspeed))
            end

            xlim(app.UIAxes2,[0,app.timescale(end)]);
            xlim(app.UIAxes3,[0,app.timescale(end)]);
            app.UIAxes2.Title.String='Velocity';
            app.UIAxes2.YLabel.String='m/s';

            % Initialise line plot values
            outputs = plot(app.UIAxes2,app.timescale(1),app.yv(1));
            inputs = plot(app.UIAxes3,app.timescale(1),app.ur(1));
            legend(app.UIAxes3,app.legstring{2:end});
            hold(app.UIAxes2,'on')
            hold(app.UIAxes3,'on')

            % update animation with a loop with time pauses
            animationsamples = app.animationtime/app.Tsamp; % assume sample time of Tsamp
            updaterate =ceil(81/animationsamples); % no of samples between pauses
            tstart=tic; tsave = tstart;
            k1 = round(app.samples/5); k2 = round(app.samples*0.6);
            
            for k=1:app.samples;

                % animation of figure with car picture
                set(app.h.seat1,'Xdata',app.h.xseat1+app.xloop(k)-app.loopsize);
                set(app.h.seat2,'Xdata',app.h.xseat2+app.xloop(k)-app.loopsize);
                set(app.h.hbody,'Xdata',app.h.xhbody+app.xloop(k)-app.loopsize);
                set(app.h.seat1,'Ydata',app.h.yseat1+app.yloop(k));
                set(app.h.seat2,'Ydata',app.h.yseat2+app.yloop(k));
                set(app.h.hbody,'Ydata',app.h.yhbody+app.yloop(k));

                % animation of spokes
                set(app.h.spoke1,'Xdata',[1 -1]*app.xtarget(k));
                set(app.h.spoke1,'Ydata',[1 -1]*app.ytarget(k));
                set(app.h.spoke2,'Xdata',[-1 1]*app.ytarget(k));
                set(app.h.spoke2,'Ydata',[1 -1]*app.xtarget(k));

                % animation of Line plots
                set(outputs,'Xdata',app.timescale(1:k),'Ydata',app.yv(1:k));  %% update position response
                set(inputs,'Xdata',app.timescale(1:k),'Ydata',app.ur(1:k));  %% update input response

                % Friction illustration
                if strcmp(app.DisturbancesDropDown.Value,'Transient friction')
                    if or(k<k1,k>k2) %
                          set(app.disttext,'color',[1 1 1]);
                        else
                          set(app.disttext,'color',[1 0 0]);
                    end
                 end % end of disturbance check

                % Pause animation every updaterate samples only so rem(k,updaterate) 
                % checks for this
                if and(strcmp(app.AnimationOnButton.Text,'Animation On'),not(rem(k,updaterate)));
                    pause(app.Tsamp-toc(tstart));  %% Clumsy application of sampling time
                    tstart = tic;
                    drawnow limitrate
                end         
            end
            
            %ttotal= toc(tsave)  % total time taken by animation loop
            
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION to build initial outline of stig and seat
                
        function app = drawstig(app)
            
            % Body co-ordinates
            x= [-0.5,0,-0.2,-0.2,1,1,0.5,0.5,1.2,1,2.5,3.5,3.5,3.4,3.7 3.7,3,3.1,3,2.9,3,1.5,-0.3,-0.5];
            y= [6.5,8,8.3,9.5,9.4,8.5 8.5,8,8,6,5.8,5.5,4,1.2,1.2,0.8 0.8,1,1.4,2.9,4.9,4.7,4.7,6.5];
            h.hbody=plot(app.UIAxes,x+1,y*.1,'r','LineWidth',6);
            h.xhbody = x;
            h.yhbody = y;
            hold(app.UIAxes,'on');
            
            % Seat coordinates
            h.xseat1=[-1,-1,-0.5,-0.5];
            h.yseat1=[8,4.2,4.2,8];
            h.xseat2=[-0.5,-0.5,3,3];
            h.yseat2=[4.7,4.2,4.2,4.7];
            h.seat1=fill(app.UIAxes,h.xseat1+1,h.yseat1/10,'m');
            h.seat2=fill(app.UIAxes,h.xseat2+1,h.yseat2/10,'m');
            
            % Rail co-ordinates
            h.xrail=[0 0 80 80];
            h.yrail=[0 0.1 0.1 0];
            h.rail=fill(app.UIAxes,h.xrail,h.yrail,'b');
            
            % target line
            h.target=fill(app.UIAxes,[-1 0 0 -1]+app.targetposition,[0 0 0.4 0.4],'g');
            
            % disturbance words
            app.disttext=text(app.UIAxes,30,0.3,'Getting sticky!!',...
                'fontsize',32,'color',[1 1 1]);
            
            hold(app.UIAxes,'off');
            app.h = h; % Save handles to app
            axis(app.UIAxes,[0 app.targetposition*1.4 -0.2 1]);

            
         end

         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION to build initial outline of stig and seat
                
        function app = drawstigloop(app)
            
            loopsize=app.loopsize; 
            h=app.h;

            % Rail co-ordinates
            h.xx=linspace(0,2*pi,200);
            h.xrail = cos(h.xx)*loopsize;
            h.yrail = sin(h.xx)*loopsize;
            h.rail=plot(app.UIAxes,h.xrail,h.yrail,'b','LineWidth',10);
            hold(app.UIAxes,'on');
            
            % spokes coordinates
            spoke1x = h.xrail([1,100])*0.9;
            spoke2x = h.xrail([50,150])*0.9;
            spoke1y = h.yrail([1,100])*0.9;
            spoke2y = h.yrail([50,150])*0.9;
            h.spoke1 = plot(app.UIAxes,spoke1x,spoke1y,'g:','linewidth',5);
            h.spoke2 = plot(app.UIAxes,spoke2x,spoke2y,'g:','linewidth',5);

            % Body co-ordinates
            h.xhbody = [-0.5,0,-0.2,-0.2,1,1,0.5,0.5,1.2,1,2.5,3.5,3.5,3.4,3.7 3.7,3,3.1,3,2.9,3,1.5,-0.3,-0.5];
            h.yhbody = [6.5,8,8.3,9.5,9.4,8.5 8.5,8,8,6,5.8,5.5,4,1.2,1.2,0.8 0.8,1,1.4,2.9,4.9,4.7,4.7,6.5];
            h.xhbody = h.xhbody+loopsize-1;
            h.yhbody = h.yhbody-5;
            h.hbody=plot(app.UIAxes,h.xhbody,h.yhbody,'r','LineWidth',6);
           
            % Seat coordinates
            h.xseat1=[-1,-1,-0.5,-0.5];
            h.yseat1=[8,4.2,4.2,8];
            h.xseat2=[-0.5,-0.5,3,3];
            h.yseat2=[4.7,4.2,4.2,4.7];
            h.xseat1 = h.xseat1+loopsize-1;
            h.xseat2 = h.xseat2+loopsize-1;
            h.yseat1 = h.yseat1 - 5;
            h.yseat2 = h.yseat2 - 5;
            h.seat1=fill(app.UIAxes,h.xseat1,h.yseat1,'m');
            h.seat2=fill(app.UIAxes,h.xseat2,h.yseat2,'m');

            % disturbance words
            app.disttext=text(app.UIAxes,1,4,'Getting sticky!!',...
                'fontsize',32,'color',[1 1 1]);
                        
            hold(app.UIAxes,'off');
            app.h = h; % Save handles to app
            axis(app.UIAxes,[-1 1 -1 1]*loopsize*1.2);
            
         end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% CONTROL INTERACTION WHILE ANIMATION RUNNING
        function disablebuttons(app)
               set(app.SimulateButton, 'Enable', 'off');
               set(app.RefreshButton, 'Enable', 'off')
               set(app.DisturbancesDropDown, 'Enable', 'off')
               set(app.OpenorclosedloopDropDown, 'Enable', 'off')
               set(app.TorqueconstantkNmampSlider, 'Enable', 'off')
               set(app.LoadinertiaJkgm2Slider, 'Enable', 'off')
               set(app.GearrationSlider, 'Enable', 'off')
               set(app.ProportionalKpSlider, 'Enable', 'off')
               set(app.IntegralKiSlider, 'Enable', 'off')
               set(app.AnimationOnButton,'Enable','off')
        end
        
        function enablebuttons(app)
               set(app.SimulateButton, 'Enable', 'on');
               set(app.RefreshButton, 'Enable', 'on')
               set(app.DisturbancesDropDown, 'Enable', 'on')
               set(app.OpenorclosedloopDropDown, 'Enable', 'on')
               set(app.TorqueconstantkNmampSlider, 'Enable', 'on')
               set(app.LoadinertiaJkgm2Slider, 'Enable', 'on')
               set(app.GearrationSlider, 'Enable', 'on')
               set(app.ProportionalKpSlider, 'Enable', 'on')
               set(app.IntegralKiSlider, 'Enable', 'on')
               set(app.AnimationOnButton,'Enable','on')
        end
        
        % Collect parameters from sliders and define transfer function
        % models
        function app = definesystem(app)

           % Default values
           B=0.008; Jm = 6*10^(-7);n=10;k=0.015;
           L=7*10^(-5);R=2;Jl=0.02;r = 0.05;

           % Collect values from sliders
           Jl = app.LoadinertiaJkgm2Slider.Value;
           k = app.TorqueconstantkNmampSlider.Value;
           n = app.GearrationSlider.Value;
           B = app.FrictionBSlider.Value;

           % define model transfer function
           a1= (L/k)*(n*Jm+(Jl/n));
           a2 = (R/k)*(n*Jm+(Jl/n))+(L*B/(k*n));
           a3 = (B*R/(n*k))+ (k*n);
           app.Gspeed = tf(r,[a1 a2 a3]);
           app.Gposition = tf(r,[a1 a2 a3 0]);
           
           % Define models when extra friction applied
           B=B+0.04;
           a2 = (R/k)*(n*Jm+(Jl/n))+(L*B/(k*n));
           a3 = (B*R/(n*k))+ (k*n);
           app.Gspeed2 = tf(r,[a1 a2 a3]);
           app.Gposition2 = tf(r,[a1 a2 a3 0]);
        end


    end  %% end of methods
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % resize to be in middle of  the window
            movegui(app.UIFigure)
            
            % Open the manual
            if exist('dcservo_and_position_control_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open dcservo_and_position_control_mycopy.mlx
            else
                p1 = which('dcservo_and_position_control_manual.mlx');
                p2 = strcat(pwd,'/dcservo_and_position_control_mycopy.mlx');
                copyfile(p1,p2)                
                open dcservo_and_position_control_mycopy.mlx
                clear p1 p2
            end
            
            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);
            app = drawstigloop(app);

            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
            theme(app.UIFigure,"light")
            end
        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
            
            disablebuttons(app)
            app.runtime = 10;
            app.timescale=linspace(0,app.runtime,201);

            % collect data from sliders and dropdowns and determine overall responses
            app = definesystem(app);

            % Check drop down to decide simulation type
            value = app.OpenorclosedloopDropDown.Value;
            switch value
                case 'Open-loop';
                    app=drawstigloop(app);
                    app = determineopenloopresponses(app);
                    updateopenloopplots(app);
                    
                case 'Velocity control'
                    app.legstring{1}='Target speed/voltage';
                    app=drawstigloop(app);
                    app.runtime = 10;
                    app.timescale=linspace(0,app.runtime,201);
                    app = determineclosedloopresponses_speed(app);
                    updatespeedplots(app);
                case 'Position control'
                    app.legstring{1}='Target position/voltage';
                    app=drawstig(app);
                    [app] = determineclosedloopresponses(app);
                    % Animation and update of line plots
                    updatelineplots(app);
            end 

            enablebuttons(app)
            %% end of start simulation below
        end

        % Button pushed function: RefreshButton
        function RefreshButtonPushed(app, event)
            %% Clean all the figures and legend so user can begin afresh
             hold(app.UIAxes3,'off')
             hold(app.UIAxes2,'off')
             plot(app.UIAxes3,0,0)
             plot(app.UIAxes2,0,0)
             app.legstring=cell(1);
             app.legstring{1}= 'empty';
             app=drawstigloop(app);
             
        end

        % Button pushed function: AnimationOnButton
        function AnimationOnButtonPushed(app, event)
            val = app.AnimationOnButton.Text;
            if strcmp(val,'Animation On');
                val = 'Animation Off';
            else
                val = 'Animation On';
            end
            app.AnimationOnButton.Text=val;
        end

        % Value changed function: TorqueconstantkNmampSlider
        function TorqueconstantkNmampSliderValueChanged(app, event)
            value = app.TorqueconstantkNmampSlider.Value;
            value = round(value,2);
            if value==0;value=0.01;end
            app.TorqueconstantkNmampSlider.Value=value;

        end

        % Value changed function: LoadinertiaJkgm2Slider
        function LoadinertiaJkgm2SliderValueChanged(app, event)
            value = app.LoadinertiaJkgm2Slider.Value;
            value=round(value,2);
            if value == 0; value = 0.01;end
            app.LoadinertiaJkgm2Slider.Value=value;
        end

        % Value changed function: IntegralKiSlider
        function IntegralKiSliderValueChanged(app, event)
            value = app.IntegralKiSlider.Value;
            value = round(value,0);
            app.IntegralKiSlider.Value=value;
            
        end

        % Value changed function: ProportionalKpSlider
        function ProportionalKpSliderValueChanged(app, event)
            value = app.ProportionalKpSlider.Value;
            value=round(value,0);
            if value==0; value =2;end
            app.ProportionalKpSlider.Value=value;
            
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

        % Value changed function: OpenorclosedloopDropDown
        function OpenorclosedloopDropDownValueChanged(app, event)
            value = app.OpenorclosedloopDropDown.Value;
            RefreshButtonPushed(app);

            switch value
                case 'Open-loop';
                    app=drawstigloop(app);

                case 'Velocity control'
                    app=drawstigloop(app);

                case 'Position control'
                    app=drawstig(app);
            end 

        end

        % Value changed function: GearrationSlider
        function GearrationSliderValueChanged(app, event)
            value = app.GearrationSlider.Value;
            value  =round(value,0);
            if value == 0; value =1;end
            app.GearrationSlider.Value = value;
        end

        % Value changed function: FrictionBSlider
        function FrictionBSliderValueChanged(app, event)
            value = app.FrictionBSlider.Value;
            value  = round(value,3);
            if value == 0; value = 0.001;end
            app.FrictionBSlider.Value = value;
            
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
            app.UIFigure.Position = [100 100 1243 948];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '2x'};
            app.GridLayout.RowHeight = {'0.4x', '0.2x', '1.6x', '1x', '1.2x', '1.2x'};

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout);
            title(app.UIAxes2, 'Position or velocity')
            xlabel(app.UIAxes2, 'time (sec)')
            ylabel(app.UIAxes2, 'm or m/s')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 14;
            app.UIAxes2.Layout.Row = 5;
            app.UIAxes2.Layout.Column = 2;

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.GridLayout);
            title(app.UIAxes3, 'Voltage/Input to servo')
            xlabel(app.UIAxes3, 'time (sec)')
            ylabel(app.UIAxes3, 'Volts')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.FontSize = 14;
            app.UIAxes3.Layout.Row = 6;
            app.UIAxes3.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'The seat position and target')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.XTick = [];
            app.UIAxes.XTickLabel = '';
            app.UIAxes.YTick = [];
            app.UIAxes.YTickLabel = '';
            app.UIAxes.FontSize = 18;
            app.UIAxes.Layout.Row = [2 4];
            app.UIAxes.Layout.Column = 2;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout2.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout2.Layout.Row = 4;
            app.GridLayout2.Layout.Column = 1;
            app.GridLayout2.BackgroundColor = [1 0.8 0.6];

            % Create ControlparametersMsKpKisLabel
            app.ControlparametersMsKpKisLabel = uilabel(app.GridLayout2);
            app.ControlparametersMsKpKisLabel.BackgroundColor = [1 0.502 0.302];
            app.ControlparametersMsKpKisLabel.HorizontalAlignment = 'center';
            app.ControlparametersMsKpKisLabel.FontSize = 18;
            app.ControlparametersMsKpKisLabel.FontWeight = 'bold';
            app.ControlparametersMsKpKisLabel.Layout.Row = 1;
            app.ControlparametersMsKpKisLabel.Layout.Column = [1 2];
            app.ControlparametersMsKpKisLabel.Text = 'Control parameters: M(s) = Kp + Ki/s';

            % Create ProportionalKpLabel
            app.ProportionalKpLabel = uilabel(app.GridLayout2);
            app.ProportionalKpLabel.HorizontalAlignment = 'right';
            app.ProportionalKpLabel.FontSize = 14;
            app.ProportionalKpLabel.Layout.Row = 2;
            app.ProportionalKpLabel.Layout.Column = 1;
            app.ProportionalKpLabel.Text = 'Proportional (Kp)';

            % Create ProportionalKpSlider
            app.ProportionalKpSlider = uislider(app.GridLayout2);
            app.ProportionalKpSlider.Limits = [0 20];
            app.ProportionalKpSlider.ValueChangedFcn = createCallbackFcn(app, @ProportionalKpSliderValueChanged, true);
            app.ProportionalKpSlider.FontSize = 14;
            app.ProportionalKpSlider.Layout.Row = 2;
            app.ProportionalKpSlider.Layout.Column = 2;
            app.ProportionalKpSlider.Value = 5;

            % Create IntegralKiLabel
            app.IntegralKiLabel = uilabel(app.GridLayout2);
            app.IntegralKiLabel.HorizontalAlignment = 'right';
            app.IntegralKiLabel.FontSize = 14;
            app.IntegralKiLabel.Layout.Row = 3;
            app.IntegralKiLabel.Layout.Column = 1;
            app.IntegralKiLabel.Text = 'Integral (Ki)';

            % Create IntegralKiSlider
            app.IntegralKiSlider = uislider(app.GridLayout2);
            app.IntegralKiSlider.Limits = [0 20];
            app.IntegralKiSlider.ValueChangedFcn = createCallbackFcn(app, @IntegralKiSliderValueChanged, true);
            app.IntegralKiSlider.FontSize = 14;
            app.IntegralKiSlider.Layout.Row = 3;
            app.IntegralKiSlider.Layout.Column = 2;
            app.IntegralKiSlider.Value = 5;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout);
            app.GridLayout3.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout3.RowHeight = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout3.Layout.Row = 3;
            app.GridLayout3.Layout.Column = 1;
            app.GridLayout3.BackgroundColor = [0.902 1 0.502];

            % Create ServoandloadparametersLabel
            app.ServoandloadparametersLabel = uilabel(app.GridLayout3);
            app.ServoandloadparametersLabel.BackgroundColor = [1 1 0];
            app.ServoandloadparametersLabel.HorizontalAlignment = 'center';
            app.ServoandloadparametersLabel.FontSize = 18;
            app.ServoandloadparametersLabel.FontWeight = 'bold';
            app.ServoandloadparametersLabel.Layout.Row = 1;
            app.ServoandloadparametersLabel.Layout.Column = [1 2];
            app.ServoandloadparametersLabel.Text = 'Servo and load  parameters';

            % Create LoadinertiaJkgm2Label
            app.LoadinertiaJkgm2Label = uilabel(app.GridLayout3);
            app.LoadinertiaJkgm2Label.HorizontalAlignment = 'right';
            app.LoadinertiaJkgm2Label.FontSize = 14;
            app.LoadinertiaJkgm2Label.Layout.Row = 2;
            app.LoadinertiaJkgm2Label.Layout.Column = 1;
            app.LoadinertiaJkgm2Label.Text = {'Load inertia '; 'J (kg m^2)'};

            % Create LoadinertiaJkgm2Slider
            app.LoadinertiaJkgm2Slider = uislider(app.GridLayout3);
            app.LoadinertiaJkgm2Slider.Limits = [0 0.05];
            app.LoadinertiaJkgm2Slider.ValueChangedFcn = createCallbackFcn(app, @LoadinertiaJkgm2SliderValueChanged, true);
            app.LoadinertiaJkgm2Slider.MinorTicks = [200 300 400 500 600 700 800 900 1000];
            app.LoadinertiaJkgm2Slider.FontSize = 14;
            app.LoadinertiaJkgm2Slider.Layout.Row = 2;
            app.LoadinertiaJkgm2Slider.Layout.Column = 2;
            app.LoadinertiaJkgm2Slider.Value = 0.02;

            % Create TorqueconstantkNmampSliderLabel
            app.TorqueconstantkNmampSliderLabel = uilabel(app.GridLayout3);
            app.TorqueconstantkNmampSliderLabel.HorizontalAlignment = 'right';
            app.TorqueconstantkNmampSliderLabel.FontSize = 14;
            app.TorqueconstantkNmampSliderLabel.Layout.Row = 3;
            app.TorqueconstantkNmampSliderLabel.Layout.Column = 1;
            app.TorqueconstantkNmampSliderLabel.Text = {'Torque constant '; 'k (Nm/amp)'};

            % Create TorqueconstantkNmampSlider
            app.TorqueconstantkNmampSlider = uislider(app.GridLayout3);
            app.TorqueconstantkNmampSlider.Limits = [0 0.1];
            app.TorqueconstantkNmampSlider.ValueChangedFcn = createCallbackFcn(app, @TorqueconstantkNmampSliderValueChanged, true);
            app.TorqueconstantkNmampSlider.MinorTicks = [50 100 150 200 250 300 350 400 450 500];
            app.TorqueconstantkNmampSlider.FontSize = 14;
            app.TorqueconstantkNmampSlider.Layout.Row = 3;
            app.TorqueconstantkNmampSlider.Layout.Column = 2;
            app.TorqueconstantkNmampSlider.Value = 0.02;

            % Create GearrationSliderLabel
            app.GearrationSliderLabel = uilabel(app.GridLayout3);
            app.GearrationSliderLabel.HorizontalAlignment = 'right';
            app.GearrationSliderLabel.FontSize = 14;
            app.GearrationSliderLabel.Layout.Row = 4;
            app.GearrationSliderLabel.Layout.Column = 1;
            app.GearrationSliderLabel.Text = {'Gear ratio'; 'n'};

            % Create GearrationSlider
            app.GearrationSlider = uislider(app.GridLayout3);
            app.GearrationSlider.Limits = [0 20];
            app.GearrationSlider.ValueChangedFcn = createCallbackFcn(app, @GearrationSliderValueChanged, true);
            app.GearrationSlider.MinorTicks = [50 100 150 200 250 300 350 400 450 500];
            app.GearrationSlider.FontSize = 14;
            app.GearrationSlider.Layout.Row = 4;
            app.GearrationSlider.Layout.Column = 2;
            app.GearrationSlider.Value = 10;

            % Create FrictionBSliderLabel
            app.FrictionBSliderLabel = uilabel(app.GridLayout3);
            app.FrictionBSliderLabel.HorizontalAlignment = 'right';
            app.FrictionBSliderLabel.FontSize = 14;
            app.FrictionBSliderLabel.Layout.Row = 5;
            app.FrictionBSliderLabel.Layout.Column = 1;
            app.FrictionBSliderLabel.Text = {'Friction'; 'B'};

            % Create FrictionBSlider
            app.FrictionBSlider = uislider(app.GridLayout3);
            app.FrictionBSlider.Limits = [0 0.02];
            app.FrictionBSlider.ValueChangedFcn = createCallbackFcn(app, @FrictionBSliderValueChanged, true);
            app.FrictionBSlider.MinorTicks = [50 100 150 200 250 300 350 400 450 500];
            app.FrictionBSlider.FontSize = 14;
            app.FrictionBSlider.Layout.Row = 5;
            app.FrictionBSlider.Layout.Column = 2;
            app.FrictionBSlider.Value = 0.008;

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout4.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout4.Layout.Row = 5;
            app.GridLayout4.Layout.Column = 1;
            app.GridLayout4.BackgroundColor = [0.702 1 0.702];

            % Create SimulationparametersLabel
            app.SimulationparametersLabel = uilabel(app.GridLayout4);
            app.SimulationparametersLabel.BackgroundColor = [0 1 0];
            app.SimulationparametersLabel.HorizontalAlignment = 'center';
            app.SimulationparametersLabel.FontSize = 18;
            app.SimulationparametersLabel.FontWeight = 'bold';
            app.SimulationparametersLabel.Layout.Row = 1;
            app.SimulationparametersLabel.Layout.Column = [1 2];
            app.SimulationparametersLabel.Text = 'Simulation parameters';

            % Create OpenorclosedloopDropDownLabel
            app.OpenorclosedloopDropDownLabel = uilabel(app.GridLayout4);
            app.OpenorclosedloopDropDownLabel.HorizontalAlignment = 'center';
            app.OpenorclosedloopDropDownLabel.FontSize = 14;
            app.OpenorclosedloopDropDownLabel.Layout.Row = 2;
            app.OpenorclosedloopDropDownLabel.Layout.Column = 1;
            app.OpenorclosedloopDropDownLabel.Text = 'Open or closed-loop';

            % Create OpenorclosedloopDropDown
            app.OpenorclosedloopDropDown = uidropdown(app.GridLayout4);
            app.OpenorclosedloopDropDown.Items = {'Open-loop', 'Velocity control', 'Position control'};
            app.OpenorclosedloopDropDown.ValueChangedFcn = createCallbackFcn(app, @OpenorclosedloopDropDownValueChanged, true);
            app.OpenorclosedloopDropDown.FontSize = 14;
            app.OpenorclosedloopDropDown.Layout.Row = 2;
            app.OpenorclosedloopDropDown.Layout.Column = 2;
            app.OpenorclosedloopDropDown.Value = 'Open-loop';

            % Create DisturbancesDropDownLabel
            app.DisturbancesDropDownLabel = uilabel(app.GridLayout4);
            app.DisturbancesDropDownLabel.HorizontalAlignment = 'center';
            app.DisturbancesDropDownLabel.WordWrap = 'on';
            app.DisturbancesDropDownLabel.FontSize = 14;
            app.DisturbancesDropDownLabel.Layout.Row = 3;
            app.DisturbancesDropDownLabel.Layout.Column = 1;
            app.DisturbancesDropDownLabel.Text = 'Disturbances';

            % Create DisturbancesDropDown
            app.DisturbancesDropDown = uidropdown(app.GridLayout4);
            app.DisturbancesDropDown.Items = {'None', 'Transient friction'};
            app.DisturbancesDropDown.FontSize = 14;
            app.DisturbancesDropDown.Layout.Row = 3;
            app.DisturbancesDropDown.Layout.Column = 2;
            app.DisturbancesDropDown.Value = 'None';

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout);
            app.GridLayout5.ColumnWidth = {'1.8x', '1x'};
            app.GridLayout5.RowHeight = {'1x'};
            app.GridLayout5.Layout.Row = 1;
            app.GridLayout5.Layout.Column = 2;
            app.GridLayout5.BackgroundColor = [0.6 1 1];

            % Create PositionvelocitycontrolwithaDCservoLabel
            app.PositionvelocitycontrolwithaDCservoLabel = uilabel(app.GridLayout5);
            app.PositionvelocitycontrolwithaDCservoLabel.BackgroundColor = [0 1 1];
            app.PositionvelocitycontrolwithaDCservoLabel.FontSize = 24;
            app.PositionvelocitycontrolwithaDCservoLabel.FontWeight = 'bold';
            app.PositionvelocitycontrolwithaDCservoLabel.Layout.Row = 1;
            app.PositionvelocitycontrolwithaDCservoLabel.Layout.Column = 1;
            app.PositionvelocitycontrolwithaDCservoLabel.Text = 'Position/velocity control with a DC servo';

            % Create Image
            app.Image = uiimage(app.GridLayout5);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 2;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'UoSlogo.png');

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.ColumnWidth = {'1x', '0.9x', '1.1x'};
            app.GridLayout6.RowHeight = {'1x'};
            app.GridLayout6.Layout.Row = [1 2];
            app.GridLayout6.Layout.Column = 1;
            app.GridLayout6.BackgroundColor = [1 0.6 0.8];

            % Create SimulateButton
            app.SimulateButton = uibutton(app.GridLayout6, 'push');
            app.SimulateButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateButtonPushed, true);
            app.SimulateButton.WordWrap = 'on';
            app.SimulateButton.BackgroundColor = [1 0.2 0.702];
            app.SimulateButton.FontSize = 20;
            app.SimulateButton.FontWeight = 'bold';
            app.SimulateButton.Layout.Row = 1;
            app.SimulateButton.Layout.Column = 1;
            app.SimulateButton.Text = 'Simulate';

            % Create RefreshButton
            app.RefreshButton = uibutton(app.GridLayout6, 'push');
            app.RefreshButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshButtonPushed, true);
            app.RefreshButton.WordWrap = 'on';
            app.RefreshButton.BackgroundColor = [1 0.2 0.702];
            app.RefreshButton.FontSize = 20;
            app.RefreshButton.FontWeight = 'bold';
            app.RefreshButton.Layout.Row = 1;
            app.RefreshButton.Layout.Column = 2;
            app.RefreshButton.Text = 'Refresh';

            % Create AnimationOnButton
            app.AnimationOnButton = uibutton(app.GridLayout6, 'push');
            app.AnimationOnButton.ButtonPushedFcn = createCallbackFcn(app, @AnimationOnButtonPushed, true);
            app.AnimationOnButton.WordWrap = 'on';
            app.AnimationOnButton.BackgroundColor = [1 0.2 0.702];
            app.AnimationOnButton.FontSize = 20;
            app.AnimationOnButton.FontWeight = 'bold';
            app.AnimationOnButton.Layout.Row = 1;
            app.AnimationOnButton.Layout.Column = 3;
            app.AnimationOnButton.Text = 'Animation On';

            % Create Image2
            app.Image2 = uiimage(app.GridLayout);
            app.Image2.Layout.Row = 6;
            app.Image2.Layout.Column = 1;
            app.Image2.ImageSource = fullfile(pathToMLAPP, 'servo.jpg');

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dcservo_and_position_control

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

