classdef racingcar_control101 < matlab.apps.AppBase
    %RACINGCAR_CONTROL101
    %   This is a simple interface to understand and investigate how PI
    %   compesators for steering and speed control impact on the behaviour
    %   of a racing car around a track.

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        TabGroup                        matlab.ui.container.TabGroup
        SimulationchoicesTab            matlab.ui.container.Tab
        GridLayout10                    matlab.ui.container.GridLayout
        GridLayout8                     matlab.ui.container.GridLayout
        GridLayout3_2                   matlab.ui.container.GridLayout
        SteeringratelimitSlider         matlab.ui.control.Slider
        SteeringratelimitSliderLabel    matlab.ui.control.Label
        SteeringlimitSlider             matlab.ui.control.Slider
        SteeringlimitSliderLabel        matlab.ui.control.Label
        TimelimitSlider                 matlab.ui.control.Slider
        TimelimitSliderLabel            matlab.ui.control.Label
        SystemandConstraintsLabel       matlab.ui.control.Label
        GridLayout3                     matlab.ui.container.GridLayout
        FeedforwardhorizonSlider        matlab.ui.control.Slider
        SliderLabel_2                   matlab.ui.control.Label
        IntegralcontrolspeedSlider      matlab.ui.control.Slider
        IntegralcontrolSlider_2Label    matlab.ui.control.Label
        ProportionalcontrolspeedSlider  matlab.ui.control.Slider
        SliderLabel                     matlab.ui.control.Label
        TargetspeedmsSlider             matlab.ui.control.Slider
        TargetspeedmsSliderLabel        matlab.ui.control.Label
        TargetfilterpoleSlider          matlab.ui.control.Slider
        TargetfilterpoleSliderLabel     matlab.ui.control.Label
        IntegralcontrolSlider           matlab.ui.control.Slider
        IntegralcontrolSliderLabel      matlab.ui.control.Label
        ProportionalcontrolSlider       matlab.ui.control.Slider
        ProportionalcontrolSliderLabel  matlab.ui.control.Label
        ControllersettingsLabel         matlab.ui.control.Label
        HistoryinformationTab           matlab.ui.container.Tab
        GridLayout13                    matlab.ui.container.GridLayout
        Label                           matlab.ui.control.Label
        NamesLabel                      matlab.ui.control.Label
        Plot11EditField                 matlab.ui.control.EditField
        Plot11EditFieldLabel            matlab.ui.control.Label
        Plot10EditField                 matlab.ui.control.EditField
        Plot10EditFieldLabel            matlab.ui.control.Label
        Plot9EditField                  matlab.ui.control.EditField
        Plot9EditFieldLabel             matlab.ui.control.Label
        Plot8EditField                  matlab.ui.control.EditField
        Plot8EditFieldLabel             matlab.ui.control.Label
        Plot7EditField                  matlab.ui.control.EditField
        Plot7EditFieldLabel             matlab.ui.control.Label
        Plot6EditField                  matlab.ui.control.EditField
        Plot6EditFieldLabel             matlab.ui.control.Label
        Plot5EditField                  matlab.ui.control.EditField
        Plot5EditFieldLabel             matlab.ui.control.Label
        Plot4EditField                  matlab.ui.control.EditField
        Plot4EditFieldLabel             matlab.ui.control.Label
        Plot3EditField                  matlab.ui.control.EditField
        Plot3EditFieldLabel             matlab.ui.control.Label
        Plot2EditField                  matlab.ui.control.EditField
        Plot2EditFieldLabel             matlab.ui.control.Label
        Plot1EditField                  matlab.ui.control.EditField
        Plot1EditFieldLabel             matlab.ui.control.Label
        CurrentplotsonlyTab             matlab.ui.container.Tab
        GridLayout14                    matlab.ui.container.GridLayout
        UIAxes1                         matlab.ui.control.UIAxes
        UIAxes3                         matlab.ui.control.UIAxes
        UIAxes2                         matlab.ui.control.UIAxes
        GridLayout5                     matlab.ui.container.GridLayout
        AnimationOnButton               matlab.ui.control.Button
        RefreshButton                   matlab.ui.control.Button
        SimulateButton                  matlab.ui.control.Button
        GridLayout4                     matlab.ui.container.GridLayout
        GridLayout9                     matlab.ui.container.GridLayout
        FuelusedEditField               matlab.ui.control.NumericEditField
        FuelusedEditFieldLabel          matlab.ui.control.Label
        LaptimeEditField                matlab.ui.control.NumericEditField
        LaptimeEditFieldLabel           matlab.ui.control.Label
        SteeringcostEditField           matlab.ui.control.NumericEditField
        SteeringcostEditFieldLabel      matlab.ui.control.Label
        Image                           matlab.ui.control.Image
        GPCwithaTfilterandconstraintsLabel  matlab.ui.control.Label
        UIAxes4                         matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        originalsize % Description
        
        % Track and car parameters
        xtrack
        ytrack
        thetatrack
        directiontrack
        numberanglestrack
        speedratio
        basiccar
        xcar
        ycar
        M
        Bm
        Km
        
        legstring=cell(1)
        nlegstring=1;
        legendstore=cell(1)
    end
    
    methods (Access = private)


        % prevent further user interaction while simulation running
        function  disablebuttons(app)
            set(app.SimulateButton,'Enable','off')
            set(app.ProportionalcontrolSlider,'Enable','off')
            set(app.IntegralcontrolSlider,'Enable','off')
            set(app.TargetfilterpoleSlider,'Enable','off')
            set(app.TargetspeedmsSlider,'Enable','off')
            set(app.ProportionalcontrolspeedSlider,'Enable','off')
            set(app.IntegralcontrolspeedSlider,'Enable','off')
            set(app.TimelimitSlider,'Enable','off')
            set(app.SteeringlimitSlider,'Enable','off')
            set(app.SteeringratelimitSlider,'Enable','off')
            set(app.RefreshButton,'Enable','off')
            set(app.AnimationOnButton,'Enable','off')
            
        end
        
        % prevent further user interaction while simulation running
        function enablebuttons(app)
            set(app.SimulateButton,'Enable','on')
            set(app.ProportionalcontrolSlider,'Enable','on')
            set(app.IntegralcontrolSlider,'Enable','on')
            set(app.TargetfilterpoleSlider,'Enable','on')
            set(app.TargetspeedmsSlider,'Enable','on')
            set(app.ProportionalcontrolspeedSlider,'Enable','on')
            set(app.IntegralcontrolspeedSlider,'Enable','on')
            set(app.TimelimitSlider,'Enable','on')
            set(app.SteeringlimitSlider,'Enable','on')
            set(app.AnimationOnButton,'Enable','on')
            set(app.SteeringratelimitSlider,'Enable','on')
            set(app.RefreshButton,'Enable','on')
        end

        
        function app = createtrack(app)
            % Define track coordinates and curvature and direction and how many points
            % used to define the track
             
                % Define track using curvature
                theta1 = -ones(1,200)*0.15;  %-35
                theta2 = ones(1,300)*0.8;     % 180
                theta3 = -theta2*3/4;          %-180
                theta4 = theta2*3/4;           %180
                theta5 = ones(1,300)*0.1;     % 20  
                theta6 = -ones(1,200)*0.2;   % -50
                theta7 = theta2*2/3;        % 120
                theta8=theta2/5;
                theta9=-ones(1,60)*0.83;
                theta=[0,theta1,theta2,theta3,theta4,theta5,theta6,theta7,theta8,theta9];
                theta = theta*pi/180;   % turn into radians
                numberangles = length(theta);

                % Define the implied direction and x,y coordinates
                % Assume a distance of 20m between coordinates
                x=0;y=0;d=2;direction=0;
                for k=2:length(theta);
                    direction(k)=direction(k-1)+theta(k-1);
                    x(k)=x(k-1)+d*cos(direction(k));
                    y(k)=y(k-1)+d*sin(direction(k));
                    % if k>numberangles; % Ensure track does not change on the 2nd lap
                    %     x(k)=x(k-numberangles);
                    %     y(k)=y(k-numberangles);
                    %     direction(k)=direction(k-numberangles);
                    % end
                end
                % close track
                x=[x,-5.5,-3.8,-2];
                y=[y,1.4,0.9,0.4];
                direction=[direction,0,0,0];
                theta = [theta,0,0,0];
                
                % Plot the track and initial car position
                hold(app.UIAxes4,'off')
                app.UIAxes4.XLim = [-inf inf];
                app.UIAxes4.YLim = [-inf inf];
                plot(app.UIAxes4,x,y,'c','LineWidth',20);
                hold(app.UIAxes4,'on')
                plot(app.UIAxes4,x,y,'r','LineWidth',2)

                % elongate track to ensure continuity
                x=[x,x(1:80)];
                y=[y,y(1:80)];
                theta=[theta,theta(1:80)];
                direction=[direction,direction(1:80)];

                % Save data to app
                app.thetatrack=theta;
                app.xtrack=x;
                app.ytrack=y;
                app.directiontrack = direction;
                app.numberanglestrack=numberangles;

                % Create a variable for ratio of curvature
                app.speedratio=(1-abs(app.thetatrack/max(abs(theta)))+1)/2;
                % plot(app.speedratio,'linewidth',2)
                % title('Variation of speed around the track')
                % xlabel('Track position')
            
        end  % end of create track


        % Create the car and add to the figure
        function app = createcar(app)
            xcar=[0,10,10,15,15,30,30,35,35,45,47,45,35,35,30,30,15,15,10,10,0]-20;
            ycar=[-10,-10,-14,-14,-10,-10,-14,-14,-10,-6,0,6,10,14,14,10,10,14,14,10,10];
            currentangle=0;
            currentposition=[app.xtrack(1),app.ytrack(1)];

            app.basiccar=fill(app.UIAxes4,xcar+app.xtrack(1),ycar+app.ytrack(1),'b');
            rotate(app.basiccar,[0,0,1],currentangle,[currentposition,0]);
            app.xcar=xcar;
            app.ycar=ycar;
           
            % useful parameters
            % Car model:  M vdot+Bv=K f  OR vdot = Bm v + Km f
            app.M=1500;
            app.Bm = -3000/app.M;   % was B=2000
            app.Km=150000/app.M;     % was K= 100000
        end

        % Car model - forms derivatives of states
        function [dvy, dr, dx, dy, dtheta] = carmodel_control101(app,vx, vy, r, theta, delta)
            %
            % vx is velocity
            % delta is steering
            % vy is an internal state  (must initialise)
            % r is an internal state  (must initialise)
            % theta is heading angle  (must initialise)

            % 1. Vehicle Parameter Definitions
            m  = 1500;     % Vehicle mass (kg)
            Iz = 2500;     % Yaw moment of inertia (kg*m^2)
            lf = 1.2;      % Distance from CG to front axle (m)
            lr = 1.6;      % Distance from CG to rear axle (m)
            mu = 0.85;     % Road friction coefficient (dry asphalt)
            g  = 9.81;     % Gravity acceleration (m/s^2)

            % Calculate static vertical tire loads
            Fzf = (m * g * lr) / (lf + lr);
            Fzr = (m * g * lf) / (lf + lr);

            % Cornering stiffness parameters
            Cf = 80000;    % Front tire cornering stiffness (N/rad)
            Cr = 80000;    % Rear tire cornering stiffness (N/rad)

            % 2. Calculate Tire Slip Angles (alpha)
            % A small tolerance prevents division by zero if vx is completely stopped
            if abs(vx) < 0.1
                vx_eff = 0.1 * sign(vx) + (vx == 0);
            else
                vx_eff = vx;
            end

            alpha_f = delta - atan2((vy + lf * r), vx_eff);
            alpha_r = -atan2((vy - lr * r), vx_eff);

            % 3. Non-Linear Tire Model (Fiala/Tanh Approximation for Harsh Steering)
            % Simulates tire saturation and skidding during sudden changes
            Fyf = mu * Fzf * tanh((Cf * alpha_f) / (mu * Fzf));
            Fyr = mu * Fzr * tanh((Cr * alpha_r) / (mu * Fzr));

            % 4. Equations of Motion (Derivatives of States)
            % Lateral Acceleration derivative (dvy/dt)
            dvy = ((Fyf * cos(delta) + Fyr) / m) - (vx * r);

            % Yaw Acceleration derivative (dr/dt)
            dr = (lf * Fyf * cos(delta) - lr * Fyr) / Iz;

            % Heading Angle derivative (dtheta/dt)
            dtheta = r;

            % 5. Global Coordinate Velocity Calculations
            dx = vx * cos(theta) - vy * sin(theta);
            dy = vx * sin(theta) + vy * cos(theta);


        end

        
        
        function [anew,bnew,aratio,bratio,spunoff] = nearesttrackpoints(app,x,y,a,b)
            % Current position is [x,y]
            % current track points are indices a,b
            % New track point is [x,y] + v dT   Maximum indice change of 1
            % are new indices [a,b] (unchanged) or [a+1,b+1]
            % Look at sum of squares of distances to 2 adjacent track
            % points
            
            nochangecost=norm([x-app.xtrack(a),y-app.ytrack(a)]) + ...
                norm([x-app.xtrack(b),y-app.ytrack(b)]);
            changecost=norm([x-app.xtrack(a+1),y-app.ytrack(a+1)]) + ...
                norm([x-app.xtrack(b+1),y-app.ytrack(b+1)]);
            
            if changecost<nochangecost;
                anew=a+1;bnew=b+1;
            else
                anew=a; bnew =b;
            end

            spunoff=0;
            if max([nochangecost,changecost])>20;spunoff=1;
               %text(app.UIAxes4,x,y,'Spun off - reducing speed','FontSize',14)
               
            end
            % Also define approximate ratio of contribution of each point
            % based on how neare you are
            aratio = norm([x-app.xtrack(anew),y-app.ytrack(anew)]);
            bratio = norm([x-app.xtrack(bnew),y-app.ytrack(bnew)]);
            ab = aratio+bratio;
            aratio=aratio/ab;
            bratio=bratio/ab;

            % Esnure go back to start if on a new lap
            if anew>app.numberanglestrack;
                anew=anew-app.numberanglestrack;
                bnew=anew+1;
            end


        end   % end of nearesttrackpoints



    end  % end of all functions
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.UIFigure.AutoResizeChildren='off';   
            movegui(app.UIFigure)
            
            % Open the manual
            if exist('racingcar_control101_manual_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open racingcar_control101_manual_mycopy.mlx
            else
                p1 = which('racingcar_control101_manual.mlx');
                p2 = strcat(pwd,'/racingcar_control101_manual_mycopy.mlx');
                copyfile(p1,p2)
                open racingcar_control101_manual_mycopy.mlx
                clear p1 p2
            end
            
            % create car and track
            app = createtrack(app);
            app = createcar(app);


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
            %hold(app.UIAxes2,'off');
            %plot(app.UIAxes2,1,1,'w')
            % hold(app.UIAxes4,'off')
            % plot(app.UIAxes4,1,1,'w')    
            app.Plot1EditField.Value='';
            app.Plot2EditField.Value='';
            app.Plot3EditField.Value='';
            app.Plot4EditField.Value='';
            app.Plot5EditField.Value='';
            app.Plot6EditField.Value='';
            app.Plot7EditField.Value='';
            app.Plot8EditField.Value='';
            app.Plot9EditField.Value='';
            app.Plot10EditField.Value='';
            app.Plot11EditField.Value='';
            app = createtrack(app);

        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
           
            disablebuttons(app)

            % create car and track afresh each time
            app = createtrack(app); pause(0.4);
            app = createcar(app);
            targetspeedsave=app.TargetspeedmsSlider.Value;

            % Controller settings and external signals
            Kp=app.ProportionalcontrolSlider.Value;
            Ki=app.IntegralcontrolSlider.Value;
            filterpole = app.TargetfilterpoleSlider.Value;
            upperlimit = app.SteeringlimitSlider.Value;
            upperratelimit = app.SteeringratelimitSlider.Value;
            ffhorizon=round(app.FeedforwardhorizonSlider.Value/2); % how far ahead to look on track in samples

            %
            Kispeed=app.IntegralcontrolspeedSlider.Value;
            Kpspeed=app.ProportionalcontrolspeedSlider.Value;
            sumerrorspeed=0;
            throttle=0;
            kspunoff=2;
            spinoffmarker=0;

            % Simulation parameters
            endtime=app.TimelimitSlider.Value;
            Tsamp=0.02;     % sample time
            nn=1 + endtime/Tsamp;
            time =linspace(0,endtime,nn);

            % initialise states to zero for now
            vx=0;delta=0;vy=0;r=0;theta=0;v=0;vdot=0;f=0;sumerror=0;error=0;
            x=app.xtrack(1);y=app.ytrack(1);
            theta=app.directiontrack(1); % current position  - assume on track
            targetanglesave=0; steering=0; finaltarget=0;
            currenttrackdirectionsave=0;
            xpred=cell(1);ypred=cell(1);
            kksave=0;

            % At initialisation nearest track point is 1st and 2nd
            trackindexa=1;trackindexb=2;
            targetx=10;targety=0;
            target=plot(app.UIAxes4,targetx,targety,'kx','MarkerSize',10,'Linewidth',2);

            % Run the simulation
            k=1;continuesim=1;
            
            while continuesim==1;
                k=k+1;
                % Velocity update
                %Collect position on the track and desire ratio

                % PI compensator for speed
                targetspeed(k)=app.speedratio(trackindexa+50)*app.TargetspeedmsSlider.Value;
                errorspeed=targetspeed(k)-v(k-1);
                sumerrorspeed=sumerrorspeed+errorspeed;
                throttle(k)=Kpspeed*(targetspeed(k)-v(k-1))+Kispeed*sumerrorspeed*Tsamp;
                if throttle(k)<0;
                    throttle(k)=0;
                    if Kispeed~=0;
                        sumerrorspeed=(Kpspeed*(targetspeed(k)-v(k-1))-throttle(k))/(Kispeed*Tsamp);
                    end
                elseif throttle(k)>1;
                    throttle(k)=1;
                    if Kispeed~=0;
                    sumerrorspeed=(Kpspeed*(targetspeed(k)-v(k-1))-throttle(k))/(Kispeed*Tsamp);
                    end
                end
                
                    
                    % Update car velocity
                vdot(k-1) = app.Bm*v(k-1) + app.Km*throttle(k); % update speed
                v(k)=v(k-1)+vdot(k-1)*Tsamp;

                % Car states update
                [dvy, dr, dx, dy, dtheta] = carmodel_control101(app,v(k-1), vy(k-1),r(k-1),theta(k-1),steering(k-1));
                x(k)=x(k-1)+dx*Tsamp;  % x-coordinate
                y(k)=y(k-1)+dy*Tsamp;  % y-coordinate
                vy(k) = vy(k-1) + dvy * Tsamp; % update lateral velocity
                r(k) = r(k-1) + dr * Tsamp; % update yaw rate
                theta(k) = theta(k-1) + dtheta * Tsamp; % update yaw angle
                currentposition=[x(k),y(k)];  % Position in track-space

                % Find position on track and set target angle and target trajectory
                [trackindexa,trackindexb,aratio,bratio,spunoff] = nearesttrackpoints(app,x(k),y(k),trackindexa,trackindexb);
                targetx=app.xtrack([trackindexa+ffhorizon,trackindexb+ffhorizon])*[aratio;bratio];
                targety=app.ytrack([trackindexa+ffhorizon,trackindexb+ffhorizon])*[aratio;bratio];
                desiredangle(k)=atan2((targety-y(k)),(targetx-x(k))); % angle of desired path
                targetanglesave(k)=desiredangle(k);
                currenttrackdirectionsave(k)=app.directiontrack([trackindexa,trackindexb])*[aratio;bratio];
                ratio(:,k)=[aratio;bratio];  % save for later study

                % Ensure continuity of angles and some smoothness
                if k>10;
                    targetanglesave(k-10:end) = unwrap(targetanglesave(k-10:end));
                end
                if and(k>800,strcmp(app.AnimationOnButton.Text,'Animation On'));
                    axis(app.UIAxes4,[x(k)-250,x(k)+250,y(k)-250,y(k)+250]);
                end

                if and(k>100,spunoff==1);
                    
                   if spinoffmarker==0; 
                       app.TargetspeedmsSlider.Value=10;
                       kspunoff=k;
                       text(app.UIAxes4,x(k)-40,y(k)-40,'Spun off - reducing speed','FontSize',20)
                   end
                   spinoffmarker =1;
                end

                if k-kspunoff>200;
                    spinoffmarker=0;
                    app.TargetspeedmsSlider.Value=targetspeedsave;
                end

                % Decide whether to terminate the loop (exited track,
                % completed lap, run out of samples)
                stillontrack = norm([x(k)-app.xtrack(trackindexa),y(k)-app.ytrack(trackindexa)]);
                if or(or(k==nn,and(trackindexb<20,k>400)),stillontrack>40);  % lap complete so terminate
                    continuesim=0;
                    lapcomplete=0;
                    if and(trackindexb<20,k>400); 
                        endtext = 'Terminate due to lap';
                        lapcomplete=1;
                        elseif stillontrack>40; endtext = 'Terminate due to crash';
                        else endtext = 'Terminate due to time limit';
                    end

                    text(app.UIAxes4,x(k)-300,y(k)-100,endtext,'Fontsize',40)
                    %axis(app.UIAxes4,[x(k)-100,x(k)+100,y(k)-100,y(k)+100])
                end

                % Low pass filter to smooth up some of the jumps in the target
                % can only be used when errors and changes are small otherwise
                % it can embed some previously poor decisions
                if k>7;bb=mean(abs(steering(k-1:-1:k-6))); else bb=0;end
                if bb<0.1;
                     finaltarget(k)=(1-filterpole)*targetanglesave(k)+filterpole*finaltarget(k-1);
                else
                    finaltarget(k) = targetanglesave(k);
                end          
                
                % Update steering using the PI control law
                error(k) = finaltarget(k) - theta(k);  % Calculate the angle error
                sumerror = sumerror+error(k)*Tsamp;
                steering(k) = Kp * error(k) + Ki * sumerror;  % Update steering angle using PI control
                % Limit steering angle and prevent integral saturation
                rate = (steering(k)-steering(k-1))/Tsamp;
                if and(rate>upperratelimit,Ki>0);
                    steering(k)=steering(k-1)+upperratelimit*Tsamp;
                    sumerror=(steering(k)-Kp*error(k))/Ki;
                    
                elseif and(rate<-upperratelimit,Ki>0);
                    steering(k)=steering(k-1)-upperratelimit*Tsamp;
                    sumerror=(steering(k)-Kp*error(k))/Ki;
                end

                if and(steering(k)>upperlimit,Ki>0);
                    sumerror=(upperlimit-Kp*error(k))/Ki;
                    steering(k)=upperlimit;
                elseif and(steering(k)<-upperlimit,Ki>0);
                    sumerror=(-upperlimit-Kp*error(k))/Ki;
                    steering(k)=-upperlimit;
                end

                % Animation (every 20 samples)
                if strcmp(app.AnimationOnButton.Text,'Animation On');
                    kk=round(k/20);
                    if kk>kksave;
                        kksave=kk;
                    app.basiccar.XData=app.xcar+x(k);
                    app.basiccar.YData=app.ycar+y(k);
                    rotate(app.basiccar,[0,0,1],theta(k)*180/pi,[x(k),y(k),0])
                    target.XData=targetx;   % update picture with new target
                    target.YData=targety;
                      pause(0.01);
                    end
                end


            end   % End of simulation loop
             
            
            
            % Tidy up plot at simulation end
            app.basiccar.XData=app.xcar+x(k);
            app.basiccar.YData=app.ycar+y(k);
            rotate(app.basiccar,[0,0,1],theta(k)*180/pi,[x(k),y(k),0])
            target.XData=targetx;   % update picture with new target
            target.YData=targety;
            plot(app.UIAxes4,x,y,':k','Linewidth',2)
            axis(app.UIAxes4,[x(k)-500,x(k)+500,y(k)-500,y(k)+500]);
            app.TargetspeedmsSlider.Value=targetspeedsave;

            % Extra plots
            xx=time(1:length(error));
            plot(app.UIAxes2,xx,targetanglesave,xx,finaltarget,xx(1:end-3),currenttrackdirectionsave(1:end-3)); 
            title(app.UIAxes2,'Angle targets')
            xlabel(app.UIAxes2,'Seconds')
            legend(app.UIAxes2,'Initial target','Moderated target','Track direction')

            plot(app.UIAxes3,xx(1:end-3),error(1:end-3),xx(1:end-3),steering(1:end-3));
            title(app.UIAxes3,'Perceived angle errors and steering')
            legend(app.UIAxes3,'Perceived angle errors','steering')
            xlabel(app.UIAxes3,'Seconds')
            ylim(app.UIAxes3,[-0.2,0.2]);

            plot(app.UIAxes1,xx,v,xx(1:end-3),targetspeed(1:end-3),xx(1:end-3),10*throttle(1:end-3));
            title(app.UIAxes1,'Car velocity and throttle')
            legend(app.UIAxes1,'Car velocity','Target speed','Throttle (x10)')
            xlabel(app.UIAxes1,'Seconds')
           
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Data to enter on main screen
            cost=norm(steering);
            fuel=sum(throttle)*Tsamp;
            app.SteeringcostEditField.Value=cost;
            app.LaptimeEditField.Value=k*Tsamp;
            app.FuelusedEditField.Value=fuel;

            runtime = k;
            % Save simulation data and display on 2nd tab
            app.nlegstring=app.nlegstring+1;
            tempstring=([num2str(Kp),', ',num2str(Ki),', ',num2str(Kpspeed),', ',...
                num2str(Kispeed),', ',num2str(ffhorizon*2),', ',num2str(filterpole),', ',...
                num2str(app.TargetspeedmsSlider.Value),', ',num2str(round(cost*100)/100),', ',...
                num2str(round(k*Tsamp*100)/100),', ',num2str(round(fuel*10)/10),...
                ', ',num2str(lapcomplete)]);
            % legend(app.UIAxes4,app.legstring,'Location','southeast','FontSize',8)
            app.legendstore{app.nlegstring-1}='tempstring';
            switch app.nlegstring;
                case 2
                    app.Plot1EditField.Value=tempstring;
                case 3
                    app.Plot2EditField.Value=tempstring;
                case 4
                    app.Plot3EditField.Value=tempstring;
                case 5
                    app.Plot4EditField.Value=tempstring;
                case 6
                    app.Plot5EditField.Value=tempstring;
                case 7
                    app.Plot6EditField.Value=tempstring;
                case 8
                    app.Plot7EditField.Value=tempstring;
                case 9
                    app.Plot8EditField.Value=tempstring;
                case 10
                    app.Plot9EditField.Value=tempstring;
                case 11
                    app.Plot10EditField.Value=tempstring;
                case 12
                    app.Plot11EditField.Value=tempstring;
            end



          enablebuttons(app)

        end

        % Value changed function: ProportionalcontrolSlider
        function ProportionalcontrolSliderValueChanged(app, event)
            value = app.ProportionalcontrolSlider.Value;
            value =round(value*100)/100;
            
            app.ProportionalcontrolSlider.Value=value;
            if value==0;
                app.ProportionalcontrolSlider.Value=0.01;
            end

        end

        % Value changed function: IntegralcontrolSlider
        function IntegralcontrolSliderValueChanged(app, event)
            value = app.IntegralcontrolSlider.Value;
            value =round(value*100)/100;
            app.IntegralcontrolSlider.Value=value;

        end

        % Value changed function: TargetfilterpoleSlider
        function TargetfilterpoleSliderValueChanged2(app, event)
            value = app.TargetfilterpoleSlider.Value;
            value = round(value*20)/20;
            if value ==1; value =0.95;end
            app.TargetfilterpoleSlider.Value=value;
        end

        % Value changed function: TargetspeedmsSlider
        function TargetspeedmsSliderValueChanged(app, event)
            value = app.TargetspeedmsSlider.Value;
            if value<10; value=10;end
            value = round(value*100)/100;
            app.TargetspeedmsSlider.Value=value;
        end

        % Value changed function: SteeringlimitSlider
        function SteeringlimitSliderValueChanged(app, event)
            value = app.SteeringlimitSlider.Value;
            value = round(value*100)/100;
            app.SteeringlimitSlider.Value=value;
            if value==0;
                app.SteeringlimitSlider.Value=0.2;
            end
        end

        % Value changed function: ProportionalcontrolspeedSlider
        function ProportionalcontrolspeedSliderValueChanged(app, event)
            value = app.ProportionalcontrolspeedSlider.Value;
            value =round(value*200)/200;
            app.ProportionalcontrolspeedSlider.Value=value;
            if value==0;
                app.ProportionalcontrolspeedSlider.Value=0.005;
            end
            
        end

        % Value changed function: IntegralcontrolspeedSlider
        function IntegralcontrolspeedSliderValueChanged(app, event)
            value = app.IntegralcontrolspeedSlider.Value;
            if value<0.01; value=0.01;end  % Must have some integral
            value =round(value*200)/200;
            app.IntegralcontrolspeedSlider.Value=value;
            
        end

        % Value changed function: SteeringratelimitSlider
        function SteeringratelimitSliderValueChanged(app, event)
            value = app.SteeringratelimitSlider.Value;
            value = round(value*100)/100;
            app.SteeringratelimitSlider.Value=value;
            if value==0;
                app.SteeringratelimitSlider.Value=0.05;
            end
            
        end

        % Value changed function: TimelimitSlider
        function TimelimitSliderValueChanged(app, event)
            value = app.TimelimitSlider.Value;
            value =round(value/50)*50;
            app.TimelimitSlider.Value=value;
            if value==0;
                app.TimelimitSlider.Value=50;
            end
        end

        % Button pushed function: AnimationOnButton
        function AnimationOnButtonPushed(app, event)
        value=app.AnimationOnButton.Text;
        switch value
            case 'Animation On'
                app.AnimationOnButton.Text='Animation Off';
            case 'Animation Off'
                app.AnimationOnButton.Text='Animation On';
        end

        end

        % Value changed function: FeedforwardhorizonSlider
        function FeedforwardhorizonSliderValueChanged(app, event)
            value = app.FeedforwardhorizonSlider.Value;
            if value==0;value=1;end
            app.FeedforwardhorizonSlider.Value=value;
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
            app.GridLayout.ColumnWidth = {'1.2x', '0.2x', '2x'};
            app.GridLayout.RowHeight = {'0.45x', '1x', '1x'};

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.GridLayout);
            title(app.UIAxes4, 'Track')
            xlabel(app.UIAxes4, 'Metre')
            ylabel(app.UIAxes4, 'Metre')
            zlabel(app.UIAxes4, 'Z')
            app.UIAxes4.FontSize = 18;
            app.UIAxes4.Layout.Row = [2 3];
            app.UIAxes4.Layout.Column = 3;

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'2x', '1x'};
            app.GridLayout4.RowHeight = {'1x', '1.4x'};
            app.GridLayout4.Layout.Row = 1;
            app.GridLayout4.Layout.Column = [2 3];
            app.GridLayout4.BackgroundColor = [0.6 1 1];

            % Create GPCwithaTfilterandconstraintsLabel
            app.GPCwithaTfilterandconstraintsLabel = uilabel(app.GridLayout4);
            app.GPCwithaTfilterandconstraintsLabel.BackgroundColor = [0 1 1];
            app.GPCwithaTfilterandconstraintsLabel.HorizontalAlignment = 'center';
            app.GPCwithaTfilterandconstraintsLabel.WordWrap = 'on';
            app.GPCwithaTfilterandconstraintsLabel.FontSize = 24;
            app.GPCwithaTfilterandconstraintsLabel.FontWeight = 'bold';
            app.GPCwithaTfilterandconstraintsLabel.Layout.Row = 1;
            app.GPCwithaTfilterandconstraintsLabel.Layout.Column = 1;
            app.GPCwithaTfilterandconstraintsLabel.Text = 'Racing car and steering control';

            % Create Image
            app.Image = uiimage(app.GridLayout4);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 2;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'UoSlogo.png');

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.GridLayout4);
            app.GridLayout9.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout9.RowHeight = {'1x'};
            app.GridLayout9.Layout.Row = 2;
            app.GridLayout9.Layout.Column = [1 2];

            % Create SteeringcostEditFieldLabel
            app.SteeringcostEditFieldLabel = uilabel(app.GridLayout9);
            app.SteeringcostEditFieldLabel.HorizontalAlignment = 'center';
            app.SteeringcostEditFieldLabel.FontSize = 18;
            app.SteeringcostEditFieldLabel.FontWeight = 'bold';
            app.SteeringcostEditFieldLabel.Layout.Row = 1;
            app.SteeringcostEditFieldLabel.Layout.Column = 1;
            app.SteeringcostEditFieldLabel.Text = 'Steering cost';

            % Create SteeringcostEditField
            app.SteeringcostEditField = uieditfield(app.GridLayout9, 'numeric');
            app.SteeringcostEditField.FontSize = 24;
            app.SteeringcostEditField.FontWeight = 'bold';
            app.SteeringcostEditField.Layout.Row = 1;
            app.SteeringcostEditField.Layout.Column = 2;

            % Create LaptimeEditFieldLabel
            app.LaptimeEditFieldLabel = uilabel(app.GridLayout9);
            app.LaptimeEditFieldLabel.HorizontalAlignment = 'center';
            app.LaptimeEditFieldLabel.FontSize = 18;
            app.LaptimeEditFieldLabel.FontWeight = 'bold';
            app.LaptimeEditFieldLabel.Layout.Row = 1;
            app.LaptimeEditFieldLabel.Layout.Column = 3;
            app.LaptimeEditFieldLabel.Text = 'Lap time';

            % Create LaptimeEditField
            app.LaptimeEditField = uieditfield(app.GridLayout9, 'numeric');
            app.LaptimeEditField.FontSize = 24;
            app.LaptimeEditField.FontWeight = 'bold';
            app.LaptimeEditField.Layout.Row = 1;
            app.LaptimeEditField.Layout.Column = 4;

            % Create FuelusedEditFieldLabel
            app.FuelusedEditFieldLabel = uilabel(app.GridLayout9);
            app.FuelusedEditFieldLabel.HorizontalAlignment = 'center';
            app.FuelusedEditFieldLabel.FontSize = 18;
            app.FuelusedEditFieldLabel.FontWeight = 'bold';
            app.FuelusedEditFieldLabel.Layout.Row = 1;
            app.FuelusedEditFieldLabel.Layout.Column = 5;
            app.FuelusedEditFieldLabel.Text = 'Fuel used';

            % Create FuelusedEditField
            app.FuelusedEditField = uieditfield(app.GridLayout9, 'numeric');
            app.FuelusedEditField.FontSize = 24;
            app.FuelusedEditField.FontWeight = 'bold';
            app.FuelusedEditField.Layout.Row = 1;
            app.FuelusedEditField.Layout.Column = 6;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout);
            app.GridLayout5.ColumnWidth = {'1x', '1x', '1x'};
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

            % Create AnimationOnButton
            app.AnimationOnButton = uibutton(app.GridLayout5, 'push');
            app.AnimationOnButton.ButtonPushedFcn = createCallbackFcn(app, @AnimationOnButtonPushed, true);
            app.AnimationOnButton.WordWrap = 'on';
            app.AnimationOnButton.BackgroundColor = [1 0.2 0.702];
            app.AnimationOnButton.FontSize = 24;
            app.AnimationOnButton.FontWeight = 'bold';
            app.AnimationOnButton.Layout.Row = [1 2];
            app.AnimationOnButton.Layout.Column = 3;
            app.AnimationOnButton.Text = 'Animation On';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.Layout.Row = [2 3];
            app.TabGroup.Layout.Column = [1 2];

            % Create SimulationchoicesTab
            app.SimulationchoicesTab = uitab(app.TabGroup);
            app.SimulationchoicesTab.Title = 'Simulation choices';

            % Create GridLayout10
            app.GridLayout10 = uigridlayout(app.SimulationchoicesTab);
            app.GridLayout10.ColumnWidth = {'1x'};
            app.GridLayout10.RowHeight = {'1x'};

            % Create GridLayout8
            app.GridLayout8 = uigridlayout(app.GridLayout10);
            app.GridLayout8.ColumnWidth = {'1x'};
            app.GridLayout8.RowHeight = {'1.8x', '1x'};
            app.GridLayout8.Layout.Row = 1;
            app.GridLayout8.Layout.Column = 1;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout8);
            app.GridLayout3.ColumnWidth = {'0.4x', '1x'};
            app.GridLayout3.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
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

            % Create ProportionalcontrolSliderLabel
            app.ProportionalcontrolSliderLabel = uilabel(app.GridLayout3);
            app.ProportionalcontrolSliderLabel.HorizontalAlignment = 'right';
            app.ProportionalcontrolSliderLabel.WordWrap = 'on';
            app.ProportionalcontrolSliderLabel.FontSize = 14;
            app.ProportionalcontrolSliderLabel.FontWeight = 'bold';
            app.ProportionalcontrolSliderLabel.Layout.Row = 2;
            app.ProportionalcontrolSliderLabel.Layout.Column = 1;
            app.ProportionalcontrolSliderLabel.Text = 'Proportional control';

            % Create ProportionalcontrolSlider
            app.ProportionalcontrolSlider = uislider(app.GridLayout3);
            app.ProportionalcontrolSlider.Limits = [0 1];
            app.ProportionalcontrolSlider.ValueChangedFcn = createCallbackFcn(app, @ProportionalcontrolSliderValueChanged, true);
            app.ProportionalcontrolSlider.MinorTicks = [0 2 4 6 8 10 12 14 16 18 20];
            app.ProportionalcontrolSlider.Step = 0.05;
            app.ProportionalcontrolSlider.FontSize = 14;
            app.ProportionalcontrolSlider.FontWeight = 'bold';
            app.ProportionalcontrolSlider.Layout.Row = 2;
            app.ProportionalcontrolSlider.Layout.Column = 2;
            app.ProportionalcontrolSlider.Value = 0.05;

            % Create IntegralcontrolSliderLabel
            app.IntegralcontrolSliderLabel = uilabel(app.GridLayout3);
            app.IntegralcontrolSliderLabel.HorizontalAlignment = 'right';
            app.IntegralcontrolSliderLabel.WordWrap = 'on';
            app.IntegralcontrolSliderLabel.FontSize = 14;
            app.IntegralcontrolSliderLabel.FontWeight = 'bold';
            app.IntegralcontrolSliderLabel.Layout.Row = 3;
            app.IntegralcontrolSliderLabel.Layout.Column = 1;
            app.IntegralcontrolSliderLabel.Text = 'Integral control';

            % Create IntegralcontrolSlider
            app.IntegralcontrolSlider = uislider(app.GridLayout3);
            app.IntegralcontrolSlider.Limits = [0 0.5];
            app.IntegralcontrolSlider.ValueChangedFcn = createCallbackFcn(app, @IntegralcontrolSliderValueChanged, true);
            app.IntegralcontrolSlider.MinorTicks = [1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4 4.1 4.2 4.3 4.4 4.5 4.6 4.7 4.8 4.9 5 5.1 5.2 5.3 5.4 5.5 5.6 5.7 5.8 5.9 6];
            app.IntegralcontrolSlider.Step = 0.05;
            app.IntegralcontrolSlider.FontSize = 14;
            app.IntegralcontrolSlider.FontWeight = 'bold';
            app.IntegralcontrolSlider.Layout.Row = 3;
            app.IntegralcontrolSlider.Layout.Column = 2;

            % Create TargetfilterpoleSliderLabel
            app.TargetfilterpoleSliderLabel = uilabel(app.GridLayout3);
            app.TargetfilterpoleSliderLabel.HorizontalAlignment = 'right';
            app.TargetfilterpoleSliderLabel.WordWrap = 'on';
            app.TargetfilterpoleSliderLabel.FontSize = 14;
            app.TargetfilterpoleSliderLabel.FontWeight = 'bold';
            app.TargetfilterpoleSliderLabel.Layout.Row = 4;
            app.TargetfilterpoleSliderLabel.Layout.Column = 1;
            app.TargetfilterpoleSliderLabel.Text = 'Target filter pole';

            % Create TargetfilterpoleSlider
            app.TargetfilterpoleSlider = uislider(app.GridLayout3);
            app.TargetfilterpoleSlider.Limits = [0 1];
            app.TargetfilterpoleSlider.ValueChangedFcn = createCallbackFcn(app, @TargetfilterpoleSliderValueChanged2, true);
            app.TargetfilterpoleSlider.Step = 0.05;
            app.TargetfilterpoleSlider.MinorTicksMode = 'manual';
            app.TargetfilterpoleSlider.FontSize = 14;
            app.TargetfilterpoleSlider.FontWeight = 'bold';
            app.TargetfilterpoleSlider.Layout.Row = 4;
            app.TargetfilterpoleSlider.Layout.Column = 2;

            % Create TargetspeedmsSliderLabel
            app.TargetspeedmsSliderLabel = uilabel(app.GridLayout3);
            app.TargetspeedmsSliderLabel.HorizontalAlignment = 'right';
            app.TargetspeedmsSliderLabel.WordWrap = 'on';
            app.TargetspeedmsSliderLabel.FontSize = 14;
            app.TargetspeedmsSliderLabel.FontWeight = 'bold';
            app.TargetspeedmsSliderLabel.Layout.Row = 5;
            app.TargetspeedmsSliderLabel.Layout.Column = 1;
            app.TargetspeedmsSliderLabel.Text = 'Target speed (m/s)';

            % Create TargetspeedmsSlider
            app.TargetspeedmsSlider = uislider(app.GridLayout3);
            app.TargetspeedmsSlider.Limits = [0 60];
            app.TargetspeedmsSlider.ValueChangedFcn = createCallbackFcn(app, @TargetspeedmsSliderValueChanged, true);
            app.TargetspeedmsSlider.Step = 5;
            app.TargetspeedmsSlider.MinorTicksMode = 'manual';
            app.TargetspeedmsSlider.FontSize = 14;
            app.TargetspeedmsSlider.FontWeight = 'bold';
            app.TargetspeedmsSlider.Layout.Row = 5;
            app.TargetspeedmsSlider.Layout.Column = 2;
            app.TargetspeedmsSlider.Value = 30;

            % Create SliderLabel
            app.SliderLabel = uilabel(app.GridLayout3);
            app.SliderLabel.HorizontalAlignment = 'right';
            app.SliderLabel.WordWrap = 'on';
            app.SliderLabel.FontSize = 14;
            app.SliderLabel.FontWeight = 'bold';
            app.SliderLabel.Layout.Row = 6;
            app.SliderLabel.Layout.Column = 1;
            app.SliderLabel.Text = 'Proportional control (speed)';

            % Create ProportionalcontrolspeedSlider
            app.ProportionalcontrolspeedSlider = uislider(app.GridLayout3);
            app.ProportionalcontrolspeedSlider.Limits = [0 0.1];
            app.ProportionalcontrolspeedSlider.ValueChangedFcn = createCallbackFcn(app, @ProportionalcontrolspeedSliderValueChanged, true);
            app.ProportionalcontrolspeedSlider.MinorTicks = [0 2 4 6 8 10 12 14 16 18 20];
            app.ProportionalcontrolspeedSlider.Step = 0.05;
            app.ProportionalcontrolspeedSlider.FontSize = 14;
            app.ProportionalcontrolspeedSlider.FontWeight = 'bold';
            app.ProportionalcontrolspeedSlider.Layout.Row = 6;
            app.ProportionalcontrolspeedSlider.Layout.Column = 2;
            app.ProportionalcontrolspeedSlider.Value = 0.02;

            % Create IntegralcontrolSlider_2Label
            app.IntegralcontrolSlider_2Label = uilabel(app.GridLayout3);
            app.IntegralcontrolSlider_2Label.HorizontalAlignment = 'right';
            app.IntegralcontrolSlider_2Label.WordWrap = 'on';
            app.IntegralcontrolSlider_2Label.FontSize = 14;
            app.IntegralcontrolSlider_2Label.FontWeight = 'bold';
            app.IntegralcontrolSlider_2Label.Layout.Row = 7;
            app.IntegralcontrolSlider_2Label.Layout.Column = 1;
            app.IntegralcontrolSlider_2Label.Text = 'Integral control (speed)';

            % Create IntegralcontrolspeedSlider
            app.IntegralcontrolspeedSlider = uislider(app.GridLayout3);
            app.IntegralcontrolspeedSlider.Limits = [0 0.2];
            app.IntegralcontrolspeedSlider.MajorTicks = [0 0.04 0.08 0.12 0.16 0.2];
            app.IntegralcontrolspeedSlider.ValueChangedFcn = createCallbackFcn(app, @IntegralcontrolspeedSliderValueChanged, true);
            app.IntegralcontrolspeedSlider.MinorTicks = [1 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4 4.1 4.2 4.3 4.4 4.5 4.6 4.7 4.8 4.9 5 5.1 5.2 5.3 5.4 5.5 5.6 5.7 5.8 5.9 6];
            app.IntegralcontrolspeedSlider.Step = 0.01;
            app.IntegralcontrolspeedSlider.FontSize = 14;
            app.IntegralcontrolspeedSlider.FontWeight = 'bold';
            app.IntegralcontrolspeedSlider.Layout.Row = 7;
            app.IntegralcontrolspeedSlider.Layout.Column = 2;
            app.IntegralcontrolspeedSlider.Value = 0.04;

            % Create SliderLabel_2
            app.SliderLabel_2 = uilabel(app.GridLayout3);
            app.SliderLabel_2.HorizontalAlignment = 'right';
            app.SliderLabel_2.WordWrap = 'on';
            app.SliderLabel_2.FontSize = 14;
            app.SliderLabel_2.FontWeight = 'bold';
            app.SliderLabel_2.Layout.Row = 8;
            app.SliderLabel_2.Layout.Column = 1;
            app.SliderLabel_2.Text = 'Feedforward horizon';

            % Create FeedforwardhorizonSlider
            app.FeedforwardhorizonSlider = uislider(app.GridLayout3);
            app.FeedforwardhorizonSlider.Limits = [0 50];
            app.FeedforwardhorizonSlider.ValueChangedFcn = createCallbackFcn(app, @FeedforwardhorizonSliderValueChanged, true);
            app.FeedforwardhorizonSlider.Step = 1;
            app.FeedforwardhorizonSlider.FontSize = 14;
            app.FeedforwardhorizonSlider.FontWeight = 'bold';
            app.FeedforwardhorizonSlider.Layout.Row = 8;
            app.FeedforwardhorizonSlider.Layout.Column = 2;
            app.FeedforwardhorizonSlider.Value = 3;

            % Create GridLayout3_2
            app.GridLayout3_2 = uigridlayout(app.GridLayout8);
            app.GridLayout3_2.ColumnWidth = {'0.4x', '1x'};
            app.GridLayout3_2.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout3_2.Layout.Row = 2;
            app.GridLayout3_2.Layout.Column = 1;
            app.GridLayout3_2.BackgroundColor = [0.5608 1 0.5608];

            % Create SystemandConstraintsLabel
            app.SystemandConstraintsLabel = uilabel(app.GridLayout3_2);
            app.SystemandConstraintsLabel.BackgroundColor = [0 1 0];
            app.SystemandConstraintsLabel.HorizontalAlignment = 'center';
            app.SystemandConstraintsLabel.FontSize = 24;
            app.SystemandConstraintsLabel.FontWeight = 'bold';
            app.SystemandConstraintsLabel.Layout.Row = 1;
            app.SystemandConstraintsLabel.Layout.Column = [1 2];
            app.SystemandConstraintsLabel.Text = 'System and Constraints';

            % Create TimelimitSliderLabel
            app.TimelimitSliderLabel = uilabel(app.GridLayout3_2);
            app.TimelimitSliderLabel.HorizontalAlignment = 'right';
            app.TimelimitSliderLabel.WordWrap = 'on';
            app.TimelimitSliderLabel.FontSize = 14;
            app.TimelimitSliderLabel.FontWeight = 'bold';
            app.TimelimitSliderLabel.Layout.Row = 2;
            app.TimelimitSliderLabel.Layout.Column = 1;
            app.TimelimitSliderLabel.Text = 'Time limit';

            % Create TimelimitSlider
            app.TimelimitSlider = uislider(app.GridLayout3_2);
            app.TimelimitSlider.Limits = [0 500];
            app.TimelimitSlider.ValueChangedFcn = createCallbackFcn(app, @TimelimitSliderValueChanged, true);
            app.TimelimitSlider.FontSize = 14;
            app.TimelimitSlider.FontWeight = 'bold';
            app.TimelimitSlider.Layout.Row = 2;
            app.TimelimitSlider.Layout.Column = 2;
            app.TimelimitSlider.Value = 200;

            % Create SteeringlimitSliderLabel
            app.SteeringlimitSliderLabel = uilabel(app.GridLayout3_2);
            app.SteeringlimitSliderLabel.HorizontalAlignment = 'right';
            app.SteeringlimitSliderLabel.WordWrap = 'on';
            app.SteeringlimitSliderLabel.FontSize = 14;
            app.SteeringlimitSliderLabel.FontWeight = 'bold';
            app.SteeringlimitSliderLabel.Layout.Row = 3;
            app.SteeringlimitSliderLabel.Layout.Column = 1;
            app.SteeringlimitSliderLabel.Text = 'Steering limit';

            % Create SteeringlimitSlider
            app.SteeringlimitSlider = uislider(app.GridLayout3_2);
            app.SteeringlimitSlider.Limits = [0 0.25];
            app.SteeringlimitSlider.ValueChangedFcn = createCallbackFcn(app, @SteeringlimitSliderValueChanged, true);
            app.SteeringlimitSlider.Step = 0.02;
            app.SteeringlimitSlider.FontSize = 14;
            app.SteeringlimitSlider.FontWeight = 'bold';
            app.SteeringlimitSlider.Layout.Row = 3;
            app.SteeringlimitSlider.Layout.Column = 2;
            app.SteeringlimitSlider.Value = 0.1;

            % Create SteeringratelimitSliderLabel
            app.SteeringratelimitSliderLabel = uilabel(app.GridLayout3_2);
            app.SteeringratelimitSliderLabel.HorizontalAlignment = 'right';
            app.SteeringratelimitSliderLabel.WordWrap = 'on';
            app.SteeringratelimitSliderLabel.FontSize = 14;
            app.SteeringratelimitSliderLabel.FontWeight = 'bold';
            app.SteeringratelimitSliderLabel.Layout.Row = 4;
            app.SteeringratelimitSliderLabel.Layout.Column = 1;
            app.SteeringratelimitSliderLabel.Text = 'Steering rate limit';

            % Create SteeringratelimitSlider
            app.SteeringratelimitSlider = uislider(app.GridLayout3_2);
            app.SteeringratelimitSlider.Limits = [0 0.2];
            app.SteeringratelimitSlider.MajorTicks = [0 0.04 0.08 0.12 0.16 0.2];
            app.SteeringratelimitSlider.ValueChangedFcn = createCallbackFcn(app, @SteeringratelimitSliderValueChanged, true);
            app.SteeringratelimitSlider.Step = 0.01;
            app.SteeringratelimitSlider.MinorTicksMode = 'manual';
            app.SteeringratelimitSlider.FontSize = 14;
            app.SteeringratelimitSlider.FontWeight = 'bold';
            app.SteeringratelimitSlider.Layout.Row = 4;
            app.SteeringratelimitSlider.Layout.Column = 2;
            app.SteeringratelimitSlider.Value = 0.1;

            % Create HistoryinformationTab
            app.HistoryinformationTab = uitab(app.TabGroup);
            app.HistoryinformationTab.Title = 'History information';

            % Create GridLayout13
            app.GridLayout13 = uigridlayout(app.HistoryinformationTab);
            app.GridLayout13.ColumnWidth = {'0.15x', '1x'};
            app.GridLayout13.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};

            % Create Plot1EditFieldLabel
            app.Plot1EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot1EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot1EditFieldLabel.FontWeight = 'bold';
            app.Plot1EditFieldLabel.Layout.Row = 2;
            app.Plot1EditFieldLabel.Layout.Column = 1;
            app.Plot1EditFieldLabel.Text = 'Plot 1';

            % Create Plot1EditField
            app.Plot1EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot1EditField.Layout.Row = 2;
            app.Plot1EditField.Layout.Column = 2;
            app.Plot1EditField.Value = 'TBC';

            % Create Plot2EditFieldLabel
            app.Plot2EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot2EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot2EditFieldLabel.FontWeight = 'bold';
            app.Plot2EditFieldLabel.Layout.Row = 3;
            app.Plot2EditFieldLabel.Layout.Column = 1;
            app.Plot2EditFieldLabel.Text = 'Plot 2';

            % Create Plot2EditField
            app.Plot2EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot2EditField.Layout.Row = 3;
            app.Plot2EditField.Layout.Column = 2;
            app.Plot2EditField.Value = 'TBC';

            % Create Plot3EditFieldLabel
            app.Plot3EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot3EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot3EditFieldLabel.FontWeight = 'bold';
            app.Plot3EditFieldLabel.Layout.Row = 4;
            app.Plot3EditFieldLabel.Layout.Column = 1;
            app.Plot3EditFieldLabel.Text = 'Plot 3';

            % Create Plot3EditField
            app.Plot3EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot3EditField.Layout.Row = 4;
            app.Plot3EditField.Layout.Column = 2;
            app.Plot3EditField.Value = 'TBC';

            % Create Plot4EditFieldLabel
            app.Plot4EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot4EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot4EditFieldLabel.FontWeight = 'bold';
            app.Plot4EditFieldLabel.Layout.Row = 5;
            app.Plot4EditFieldLabel.Layout.Column = 1;
            app.Plot4EditFieldLabel.Text = 'Plot 4';

            % Create Plot4EditField
            app.Plot4EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot4EditField.Layout.Row = 5;
            app.Plot4EditField.Layout.Column = 2;
            app.Plot4EditField.Value = 'TBC';

            % Create Plot5EditFieldLabel
            app.Plot5EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot5EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot5EditFieldLabel.FontWeight = 'bold';
            app.Plot5EditFieldLabel.Layout.Row = 6;
            app.Plot5EditFieldLabel.Layout.Column = 1;
            app.Plot5EditFieldLabel.Text = 'Plot 5';

            % Create Plot5EditField
            app.Plot5EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot5EditField.Layout.Row = 6;
            app.Plot5EditField.Layout.Column = 2;
            app.Plot5EditField.Value = 'TBC';

            % Create Plot6EditFieldLabel
            app.Plot6EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot6EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot6EditFieldLabel.FontWeight = 'bold';
            app.Plot6EditFieldLabel.Layout.Row = 7;
            app.Plot6EditFieldLabel.Layout.Column = 1;
            app.Plot6EditFieldLabel.Text = 'Plot 6';

            % Create Plot6EditField
            app.Plot6EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot6EditField.Layout.Row = 7;
            app.Plot6EditField.Layout.Column = 2;
            app.Plot6EditField.Value = 'TBC';

            % Create Plot7EditFieldLabel
            app.Plot7EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot7EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot7EditFieldLabel.FontWeight = 'bold';
            app.Plot7EditFieldLabel.Layout.Row = 8;
            app.Plot7EditFieldLabel.Layout.Column = 1;
            app.Plot7EditFieldLabel.Text = 'Plot 7';

            % Create Plot7EditField
            app.Plot7EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot7EditField.Layout.Row = 8;
            app.Plot7EditField.Layout.Column = 2;
            app.Plot7EditField.Value = 'TBC';

            % Create Plot8EditFieldLabel
            app.Plot8EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot8EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot8EditFieldLabel.FontWeight = 'bold';
            app.Plot8EditFieldLabel.Layout.Row = 9;
            app.Plot8EditFieldLabel.Layout.Column = 1;
            app.Plot8EditFieldLabel.Text = 'Plot 8';

            % Create Plot8EditField
            app.Plot8EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot8EditField.Layout.Row = 9;
            app.Plot8EditField.Layout.Column = 2;
            app.Plot8EditField.Value = 'TBC';

            % Create Plot9EditFieldLabel
            app.Plot9EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot9EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot9EditFieldLabel.FontWeight = 'bold';
            app.Plot9EditFieldLabel.Layout.Row = 10;
            app.Plot9EditFieldLabel.Layout.Column = 1;
            app.Plot9EditFieldLabel.Text = 'Plot 9';

            % Create Plot9EditField
            app.Plot9EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot9EditField.Layout.Row = 10;
            app.Plot9EditField.Layout.Column = 2;
            app.Plot9EditField.Value = 'TBC';

            % Create Plot10EditFieldLabel
            app.Plot10EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot10EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot10EditFieldLabel.FontWeight = 'bold';
            app.Plot10EditFieldLabel.Layout.Row = 11;
            app.Plot10EditFieldLabel.Layout.Column = 1;
            app.Plot10EditFieldLabel.Text = 'Plot 10';

            % Create Plot10EditField
            app.Plot10EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot10EditField.Layout.Row = 11;
            app.Plot10EditField.Layout.Column = 2;
            app.Plot10EditField.Value = 'TBC';

            % Create Plot11EditFieldLabel
            app.Plot11EditFieldLabel = uilabel(app.GridLayout13);
            app.Plot11EditFieldLabel.HorizontalAlignment = 'center';
            app.Plot11EditFieldLabel.FontWeight = 'bold';
            app.Plot11EditFieldLabel.Layout.Row = 12;
            app.Plot11EditFieldLabel.Layout.Column = 1;
            app.Plot11EditFieldLabel.Text = 'Plot 11';

            % Create Plot11EditField
            app.Plot11EditField = uieditfield(app.GridLayout13, 'text');
            app.Plot11EditField.Layout.Row = 12;
            app.Plot11EditField.Layout.Column = 2;
            app.Plot11EditField.Value = 'TBC';

            % Create NamesLabel
            app.NamesLabel = uilabel(app.GridLayout13);
            app.NamesLabel.HorizontalAlignment = 'center';
            app.NamesLabel.FontSize = 14;
            app.NamesLabel.FontWeight = 'bold';
            app.NamesLabel.Layout.Row = 1;
            app.NamesLabel.Layout.Column = 1;
            app.NamesLabel.Text = 'Names';

            % Create Label
            app.Label = uilabel(app.GridLayout13);
            app.Label.WordWrap = 'on';
            app.Label.FontSize = 14;
            app.Label.Layout.Row = 1;
            app.Label.Layout.Column = 2;
            app.Label.Text = 'Kp, Ki, Kpv, Kiv, FF horizon, Filter pole, Speed, Steering Cost, Lap time, Fuel, Lap complete';

            % Create CurrentplotsonlyTab
            app.CurrentplotsonlyTab = uitab(app.TabGroup);
            app.CurrentplotsonlyTab.Title = 'Current plots only';

            % Create GridLayout14
            app.GridLayout14 = uigridlayout(app.CurrentplotsonlyTab);

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout14);
            title(app.UIAxes2, 'Track and car direction')
            xlabel(app.UIAxes2, 'Seconds')
            ylabel(app.UIAxes2, 'Steering angle')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.Layout.Row = 1;
            app.UIAxes2.Layout.Column = 1;

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.GridLayout14);
            title(app.UIAxes3, 'Steering and target angle')
            xlabel(app.UIAxes3, 'Seconds')
            ylabel(app.UIAxes3, 'Radians')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.Layout.Row = 2;
            app.UIAxes3.Layout.Column = [1 2];

            % Create UIAxes1
            app.UIAxes1 = uiaxes(app.GridLayout14);
            title(app.UIAxes1, 'Speed and target speed')
            xlabel(app.UIAxes1, 'Seconds')
            ylabel(app.UIAxes1, 'm/s')
            zlabel(app.UIAxes1, 'Z')
            app.UIAxes1.Layout.Row = 1;
            app.UIAxes1.Layout.Column = 2;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = racingcar_control101

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

