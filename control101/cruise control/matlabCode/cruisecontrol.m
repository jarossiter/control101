classdef cruisecontrol < matlab.apps.AppBase
    %CRUISECONTROL
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
        GridLayout6                    matlab.ui.container.GridLayout
        AnimationOnButton              matlab.ui.control.Button
        RefreshButton                  matlab.ui.control.Button
        SimulateButton                 matlab.ui.control.Button
        GridLayout5                    matlab.ui.container.GridLayout
        Image                          matlab.ui.control.Image
        CruisecontrolusingPIcompensationLabel  matlab.ui.control.Label
        GridLayout4                    matlab.ui.container.GridLayout
        TargettypeDropDown             matlab.ui.control.DropDown
        TargettypeDropDownLabel        matlab.ui.control.Label
        DisturbancesDropDown           matlab.ui.control.DropDown
        DisturbancesDropDownLabel      matlab.ui.control.Label
        SimulationparametersLabel      matlab.ui.control.Label
        GridLayout3                    matlab.ui.container.GridLayout
        FrictionBNsmSlider             matlab.ui.control.Slider
        FrictionBNsmSliderLabel        matlab.ui.control.Label
        MassMkgSlider                  matlab.ui.control.Slider
        MassMkgSliderLabel             matlab.ui.control.Label
        CarparametersGs1000MsBLabel    matlab.ui.control.Label
        GridLayout2                    matlab.ui.container.GridLayout
        IntegralKiSlider               matlab.ui.control.Slider
        IntegralKiLabel                matlab.ui.control.Label
        ProportionalKpSlider           matlab.ui.control.Slider
        ProportionalKpLabel            matlab.ui.control.Label
        ControlparametersCsKpKisLabel  matlab.ui.control.Label
        UIAxes2                        matlab.ui.control.UIAxes
        UIAxes3                        matlab.ui.control.UIAxes
        UIAxes                         matlab.ui.control.UIAxes
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
        M;   % car mass
        B;   % friction
        targetspeed = 40; %  in m/s, fix for simplicity
        dashedr  % handle for plot
        slope = 0.15;  % angle of road slope in radians
        slope2;  % variable to take slope changes due to user interaction
        wind = 10;   % strength of wind in m/s
        runtime = 201;
        samples = 201;
        animationtime = 8; % how long animation will take
        Tsamp=0.1;  % update rate for animation
        longtimescale=linspace(0,50,201);  % for simulation the runtime
        squarewaveinterval=10; % time between changes in the square wave
        plottime;  %% used to control time of plot displayed
        PI;   % PI compensator
        G;   % system transfer function (input to output)
        F;   % system transfer function (slope to output)
        W;   % system transfer function (wind to output)
        Gcy;   % system closed-loop transfer function (target to output)
        Gcdy   % system closed-loop transfer function (slope to output)
        Gcwy;  % system closed-loop transfer function (wind to output)
        Gcu;   % system closed-loop transfer function (target to input)
        Gcdu   % system closed-loop transfer function (slope to input)
        Gcwu;  % system closed-loop transfer function (wind to input)
        yr;  % closed-loop output step response to target
        yd;  % closed-loop output step response to slope
        yw;  % closed-loop output step response to wind
        ur;  % closed-loop input step response to target
        ud;  % closed-loop input step response to slope
        uw;  % closed-loop input step response to wind
        targetlineplot;  % needed, especially if a square wave
        ytotal; % sum of all output components
        utotal; % sum of all input components
        utarget; % expected ss of input
        carxy;  % handle for the plot of car
        ycar;   % ydata only for the car
        carroadxy;  % handle for the upper road barriers
        carroad2xy; % handle for the lower road barriers
        ycarslope  % change in carxy Ydata with a slope
        yroadslope  % change in carroadxy Ydata with a slope
        xroad  %  handle for road x values
        yroad  % handle for road y values
        yroad2  % handle for 2nd road/target
        windarrow   % handle for wind
        windtext % handle for windtext
        windon=zeros(1,201); % option includes wind if value is 1
        hillon=zeros(1,201); % option includes hill if value is 1

    end
    
    methods (Access = private)
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION FOR BASIC STEP RESPONSES

        function app = determineresponses(app)
            % This function determines all the closed-loop UNIT step responses
            % Based on current values of the sliders
            % Scaling required is also added using default choices

            % collect compensator and car values from the sliders
            % round values to avoid unnecessary decimal places
            app.Kp=app.ProportionalKpSlider.Value;
            app.Ki=app.IntegralKiSlider.Value;
            app.M=app.MassMkgSlider.Value;
            app.B=app.FrictionBNsmSlider.Value;
            

            % define closed-loop transfer functions
            % y = G*u + F*slope + W*wind
            % y = GM/(1+GPI)* R -  F/(1+GPI) s -  W/(1+GPI) w
            % u = M/(1+GPI) * R  + PIF/(1+GPI) s +  W/(1+GPI) w
            app.G=tf(1000,[app.M,app.B]); % car model
            app.PI=tf([app.Kp,app.Ki],[1 0]); % PI compensator
            app.W=tf(app.B,[app.M,app.B]);     % wind to velocity
            app.F=tf(app.M*10,[app.M,app.B]);  % slope to velocity
            app.Gcy=feedback(app.G*app.PI,1);
            app.Gcu=feedback(app.PI,app.G);
            app.Gcdy=-feedback(1,app.G*app.PI)*app.F;
            app.Gcdu = app.Gcu*app.F;
            app.Gcwy=-feedback(1,app.G*app.PI)*app.W;
            app.Gcwu=app.Gcu*app.W;

            % Define the closed-loop step responses
            app.yr = step(app.Gcy,app.longtimescale)*app.targetspeed;
            app.ur = step(app.Gcu,app.longtimescale)*app.targetspeed;
            app.yd = step(app.Gcdy,app.longtimescale)*app.slope;
            app.ud = step(app.Gcdu,app.longtimescale)*app.slope;
            app.yw = step(app.Gcwy,app.longtimescale)*app.wind;
            app.uw = step(app.Gcwu,app.longtimescale)*app.wind;
            app.targetlineplot = ones(1,length(app.longtimescale))*app.targetspeed;
            
            
        end  % end of determineresponses


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION FOR SQUAREWAVES
%%%%%%%%%%%% use step responses to build square wave responses
        
        function [ysquare,usquare,targetsquare] = squarewaveresponses(app)
            % This function determines UNIT square wave responses (target
            % only)
            % Based on current values of the step responses
            % let square wave change every squarewaveinterval sec
            % use superposition to determine overall response
            totalsamples=length(app.longtimescale);
            ysquare = app.yr/2;
            usquare = app.ur/2;
            targetsquare = app.targetlineplot;

            % find the number of samples within a square wave
            numbersamples=find(app.longtimescale==app.squarewaveinterval);

            % Add step responses every numbersamples
            factor = -1;
            for k=numbersamples+1:numbersamples:totalsamples;
                ysquare(k:end)=ysquare(k:end)+ factor*app.yr(1:end-k+1);
                usquare(k:end)=usquare(k:end)+ factor*app.ur(1:end-k+1);
                targetsquare(k:end)=targetsquare(k:end)+ factor*app.targetlineplot(1:end-k+1);
                factor = -factor;
            end

            % Add a shift so moving between 2 non-zero velocities
            ysquare = ysquare/4+app.targetspeed;
            usquare = usquare/4+app.targetspeed/dcgain(app.G);
            targetsquare = targetsquare/4+app.targetspeed;



        end % end of squarewave responses

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION FOR TOTAL RESPONSES
%%%%%%%%%%%% Also defines the legend appropriate to the current response
        
        function [app] = totalresponses(app)
            % interrogate dropdowns for disturbances and wave type and hence
            % find the total response for current scenario
            % collect unit step responses
            % defines appropriate legend entry
            app = determineresponses(app);

            % define target responses depending on step or square wave selection
            switch app.TargettypeDropDown.Value;
                case 'Step in target';
                    % truncate time
                    app.plottime=1:81;
                    
                case 'Square wave';
                    app.plottime=1:201;
                    [app.yr,app.ur,app.targetlineplot] = squarewaveresponses(app);
                
            end  %  end of switch

            % Use switch loop to define total responses 
            % depending on disturbance selection and update legend
            app.ytotal=app.yr;
            app.utotal=app.ur;
            nlegstring = length(app.legstring);
            app.legstring{1}='Target speed/throttle';

            switch app.DisturbancesDropDown.Value;
                case 'Horizontal slope';
                    % no action for now
                    app.slope2=0;
                    app.windon=zeros(1,app.runtime);   
                    app.hillon=zeros(1,app.runtime);
                    app.legstring{nlegstring+1}=['M = ',num2str(app.M),', B = ',num2str(app.B),...
                ', Kp = ',num2str(app.Kp),', Ki = ',num2str(app.Ki)];

                case 'Uphill'
                    app.slope2=app.slope;
                    app.ytotal=app.ytotal+app.yd;
                    app.utotal=app.utotal+app.ud;
                    app.windon=zeros(1,app.runtime);
                    app.hillon=ones(1,app.runtime);;
                    app.legstring{nlegstring+1}=['M = ',num2str(app.M),', B = ',num2str(app.B),...
                ', Kp = ',num2str(app.Kp),', Ki = ',num2str(app.Ki),', Uphill'];

                case 'Downhill'
                    app.slope2=-app.slope;
                    app.ytotal=app.ytotal-app.yd;
                    app.utotal=app.utotal-app.ud;
                    app.windon=zeros(1,app.runtime); 
                    app.hillon=-ones(1,app.runtime);
                    app.legstring{nlegstring+1}=['M = ',num2str(app.M),', B = ',num2str(app.B),...
                ', Kp = ',num2str(app.Kp),', Ki = ',num2str(app.Ki),', Downhill'];

                case 'Head wind and no slope'
                    app.slope2=0;
                    app.ytotal=app.ytotal+app.yw;
                    app.utotal=app.utotal+app.uw;
                    app.windon=ones(1,app.runtime);
                    app.hillon=zeros(1,app.runtime);
                    app.legstring{nlegstring+1}=['M = ',num2str(app.M),', B = ',num2str(app.B),...
                ', Kp = ',num2str(app.Kp),', Ki = ',num2str(app.Ki),', Wind'];

                case 'Head wind with uphill'
                    app.slope2=app.slope;
                    app.ytotal=app.ytotal+app.yd+app.yw;
                    app.utotal=app.utotal+app.ud+app.uw;
                    app.windon=ones(1,app.runtime); 
                    app.hillon=ones(1,app.runtime);
                    app.legstring{nlegstring+1}=['M = ',num2str(app.M),', B = ',num2str(app.B),...
                ', Kp = ',num2str(app.Kp),', Ki = ',num2str(app.Ki),', Uphill',', Wind'];
               
                case 'Random wind and hills';
                    app.slope2=0;
                    app.plottime=1:201;
                    app.windon=zeros(1,app.runtime); 
                    app.hillon=zeros(1,app.runtime);
                    [app] = randomresponses(app);
                    app.legstring{nlegstring+1}=['M = ',num2str(app.M),', B = ',num2str(app.B),...
                ', Kp = ',num2str(app.Kp),', Ki = ',num2str(app.Ki),', random'];
                   
            end  % end of switch
        
        end  % end of total responses subfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION FOR animation of line plots and car
        
        function updatelineplots(app)

            % update target line if and only if clean figure
            if length(app.legstring)==2;
                
                app.dashedr = plot(app.UIAxes2,app.longtimescale,app.targetlineplot,'g--');
                xlabel(app.UIAxes2,'time (sec)')
                hold(app.UIAxes2,'on')

                app.utarget=plot(app.UIAxes3,app.longtimescale,app.targetlineplot*app.B/1000,'g--');
                xlabel(app.UIAxes3,'time (sec)')
                hold(app.UIAxes3,'on');
            else
                set(app.utarget,'Ydata',app.targetlineplot*app.B/1000)
                set(app.dashedr,'Ydata',app.targetlineplot)
            end
            xlim(app.UIAxes2,[0,app.longtimescale(app.plottime(end))]);
            xlim(app.UIAxes3,[0,app.longtimescale(app.plottime(end))])


            % Initialise line plot values
            outputs = plot(app.UIAxes2,app.longtimescale(1),app.ytotal(1));
            inputs = plot(app.UIAxes3,app.longtimescale(1),app.utotal(1));
            legend(app.UIAxes3,app.legstring);

            % update animation with a loop with time pauses
            deltax=0;deltax2=0;
            animationsamples = app.animationtime/app.Tsamp; % assume sample time of Tsamp
            updaterate =ceil(81/animationsamples); % no of samples between pauses
            tstart=tic; tsave = tstart;
            
            for k=1:length(app.plottime);

                % animation of figure with car picture
                deltax=deltax+(0.03/36)*app.ytotal(k);
                deltax2 = deltax2+0.03/36*app.targetlineplot(k);
                if deltax>1; deltax=deltax-1;end
                if deltax<-1;deltax=deltax+1;end
                if deltax2>1; deltax2=deltax2-1;end
                if deltax2<-1;deltax2=deltax2+1;end
                

                % animation of Line plots
                set(outputs,'Xdata',app.longtimescale(1:k),'Ydata',app.ytotal(1:k));  %% update depth response
                set(inputs,'Xdata',app.longtimescale(1:k),'Ydata',app.utotal(1:k));  %% update depth response

                % wind effects
                if app.windon(k)==1;
                    set(app.windarrow,'Color','g');
                    set(app.windtext,'Color','g');
                elseif app.windon(k)==0;
                    set(app.windarrow,'Color','w');
                    set(app.windtext,'Color','w');
                end
               
                % Hill effects - update car handles
                if app.hillon(k)==1;  % uphill
                    set(app.carxy,'Ydata',app.ycar+app.ycarslope);  %% car
                    set(app.carroadxy,'Xdata',app.xroad-deltax,'Ydata',app.yroad+app.yroadslope-deltax*sin(app.slope));
                    set(app.carroad2xy,'Xdata',app.xroad-deltax2,'Ydata',app.yroad+app.yroadslope-deltax2*sin(app.slope)-0.6);
                
                elseif app.hillon(k)==0; % flat
                    set(app.carxy,'Ydata',app.ycar);  %% car
                    set(app.carroadxy,'Xdata',app.xroad-deltax,'Ydata',app.yroad);
                    set(app.carroad2xy,'Xdata',app.xroad-deltax2,'Ydata',app.yroad-0.6);
                
                else % downhill
                    set(app.carxy,'Ydata',app.ycar-app.ycarslope);  %% car
                    set(app.carroadxy,'Xdata',app.xroad-deltax,'Ydata',app.yroad-app.yroadslope+deltax*sin(app.slope));
                    set(app.carroad2xy,'Xdata',app.xroad-deltax2,'Ydata',app.yroad-app.yroadslope+deltax2*sin(app.slope)-0.6);
                
                end


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
%%%%%%%%%%%% SUBFUNCTION to build initial outline of car and road
%%%%%%%%%%%%  and wind
                
        function app = caroutline(app)
            
            %%% Define car and road outline
            hold(app.UIAxes,'off')
            th=pi+0.2:0.3:2*pi-0.1;
            xcircle=0.15*cos(th);
            ycircle=0.15*sin(th);
            xcar=[0.5,1,1.15+xcircle,1.3,1.8,1.95+xcircle,2.1,3.1,2.7,1.9,1.7,1,0.5]+1;
            ycar1=[0.5,0.5,0.5+ycircle,0.5,0.5,0.5+ycircle,0.5,0.5,0.8,1,1.4,1.4,0.5];
            %ycar=ycar+xcar*sin(slope); if on a slope
            xroad=[0,1,1,1.1,1.1,2,2,2.1,2.1,3,3,3.1,3.1,4,4,4.1,4.1,5,5,5.1,5.1,6,6,0];
            yroad1=[0.4,0.4,0.8,0.8,0.4,0.4,0.8,0.8,0.4,0.4,0.8,0.8,0.4,0.4,0.8,0.8,0.4,0.4,0.8,0.8,0.4,0.4,0.35,0.35]-0.05;
            %yroad=yroad+xroad*sin(slope); if on a slope
            ycar=ycar1;yroad=yroad1;                  

            % create car and road objects
            acar=fill(app.UIAxes,xcar,ycar1,'b');   %% car
            hold(app.UIAxes,'on')
            bcar=fill(app.UIAxes,xroad,yroad1,'r');  %% posts for speed
            bcar2=fill(app.UIAxes,xroad,yroad1-0.6,'g');  %% posts for target speed
            axis(app.UIAxes,[0.5,4.5,-1,2.2]);
            
            app.windarrow=quiver(app.UIAxes,[4 4 4.6 4.6 5.2 5.2]-0.6,...
                [0.8 1 0.8 1 0.8 1]+0.7,-[1 1 1 1 1 1],...
                [0 0 0 0 0 0],'linewidth',4,'linestyle','-','Color','w');
            app.windtext=text(app.UIAxes,3.5,1.85,'WIND','fontsize',14,'Color','w');
            
            %set(app.UIAxes.axes,'Xtick',[])
            %set(app.UIAxes.axes,'Ytick',[])
            carleg=legend(app.UIAxes,'Car','Road','Target speed','Location','southeast');
            set(carleg,'fontsize',10);

            % Update data for a slope and
            app.ycarslope=xcar*sin(app.slope); % change in carxy Ydata coordinates if uphill
            app.yroadslope=xroad*sin(app.slope); % change carroadxy Ydata coordinates if uphill

            % create and store handles for data needed in animation
            app.carxy = acar;
            app.ycar = ycar;
            app.carroadxy = bcar;
            app.carroad2xy = bcar2;
            app.xroad=xroad;
            app.yroad=yroad;
            app.yroad2=yroad1-0.6;

            % Code to update coordinates if needed
            %set(app.carxy,'Ydata',ycar);  %% car
            %set(app.carroadxy,'Ydata',yroad); %% road posts
            %set(app.carroad2xy,'Ydata',yroad-0.6); %% target speed
            
         end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION to build responses with random changes in slope
%%%%%%%%%%%% and wind. Random is in effect predetermined in first few lines
%%%%%%%%%%%% as the idea is to
%%%%%%%%%%%% give indicative illustrations
%%%%%%%%%%%% Could make wind/slope bigger to emphasise effects

        function app = randomresponses(app)
            % let hill and wind on and off be dictated as follows
            switchwindon=[110,170];
            switchwindoff=[140];
            app.windon(switchwindon(1):switchwindoff(1))=ones(1,switchwindoff(1)-switchwindon(1)+1);
            app.windon(switchwindon(2):app.runtime) = ones(1,app.runtime+1-switchwindon(2));
            
            switchhillon=[30,80,180];
            switchhilloff=[60,100];
            app.hillon(switchhillon(1):switchhilloff(1))=ones(1,switchhilloff(1)-switchhillon(1)+1);
            app.hillon(switchhillon(2):switchhilloff(2))=ones(1,switchhilloff(2)-switchhillon(2)+1);
            app.hillon(switchhillon(3):app.runtime) = ones(1,app.runtime+1-switchhillon(3));
            
            totalsamples=length(app.longtimescale);

            % initialise based on nominal step responses
            yrandom = app.yr; 
            urandom = app.ur;
            

            % Add step responses every time wind on
            for k=1:length(switchwindon)
                yrandom(switchwindon(k):end)=yrandom(switchwindon(k):end)+app.yw(1:end-switchwindon(k)+1);
                urandom(switchwindon(k):end)=urandom(switchwindon(k):end)+app.uw(1:end-switchwindon(k)+1);
            end
             % Add step responses every time wind off
            for k=1:length(switchwindoff);
                yrandom(switchwindoff(k):end)=yrandom(switchwindoff(k):end)-app.yw(1:end-switchwindoff(k)+1);
                urandom(switchwindoff(k):end)=urandom(switchwindoff(k):end)-app.uw(1:end-switchwindoff(k)+1);
            end
            % Add step responses every time hill on
            for k=1:length(switchwindon)
                yrandom(switchhillon(k):end)=yrandom(switchhillon(k):end)+app.yd(1:end-switchhillon(k)+1);
                urandom(switchhillon(k):end)=urandom(switchhillon(k):end)+app.ud(1:end-switchhillon(k)+1);
            end
             % Add step responses every time hill off
            for k=1:length(switchhilloff);
                yrandom(switchhilloff(k):end)=yrandom(switchhilloff(k):end)-app.yd(1:end-switchhilloff(k)+1);
                urandom(switchhilloff(k):end)=urandom(switchhilloff(k):end)-app.ud(1:end-switchhilloff(k)+1);
             end
            
                       
            app.ytotal = yrandom;
            app.utotal = urandom;


        end  %% end of randomresponses

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% CONTROL INTERACTION WHILE ANIMATION RUNNING
        function disablebuttons(app)
               set(app.SimulateButton, 'Enable', 'off');
               set(app.RefreshButton, 'Enable', 'off')
               set(app.TargettypeDropDown, 'Enable', 'off')
               set(app.DisturbancesDropDown, 'Enable', 'off')
               set(app.FrictionBNsmSlider, 'Enable', 'off')
               set(app.MassMkgSlider, 'Enable', 'off')
               set(app.ProportionalKpSlider, 'Enable', 'off')
               set(app.IntegralKiSlider, 'Enable', 'off')
               set(app.AnimationOnButton,'Enable','off')
        end
        
        function enablebuttons(app)
            set(app.SimulateButton, 'Enable', 'on');
            set(app.RefreshButton, 'Enable', 'on')
            set(app.TargettypeDropDown, 'Enable', 'on')
               set(app.DisturbancesDropDown, 'Enable', 'on')
               set(app.FrictionBNsmSlider, 'Enable', 'on')
               set(app.MassMkgSlider, 'Enable', 'on')
               set(app.ProportionalKpSlider, 'Enable', 'on')
               set(app.IntegralKiSlider, 'Enable', 'on')
               set(app.AnimationOnButton,'Enable','on')
        end
    end  %% end of methods
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
           % resize to be in middle of  the window
            movegui(app.UIFigure)
            
            % Open the manual
            if exist('cruisecontrol_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open cruisecontrol_mycopy.mlx
            else
                p1 = which('cruisecontrol_manual.mlx');
                p2 = strcat(pwd,'/cruisecontrol_mycopy.mlx');
                copyfile(p1,p2)                
                open cruisecontrol_mycopy.mlx
                clear p1 p2
            end
            
            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);

            app = caroutline(app);

            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
            theme(app.UIFigure,"light")
            end
        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
            
            disablebuttons(app)
            
            % collect data from sliders and dropdowns and determine overall responses
            [app] = totalresponses(app);

            % Draw car (after total responses as needs slope updating)
            app = caroutline(app);
            
            % Animation and update of line plots
            updatelineplots(app);
            
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

        % Value changed function: FrictionBNsmSlider
        function FrictionBNsmSliderValueChanged(app, event)
            value = app.FrictionBNsmSlider.Value;
            value = round(value/50)*50;
            if value==0;value=10;end
            app.FrictionBNsmSlider.Value=value;

        end

        % Value changed function: MassMkgSlider
        function MassMkgSliderValueChanged(app, event)
            value = app.MassMkgSlider.Value;
            value=round(value,-2);
            app.MassMkgSlider.Value=value;
        end

        % Value changed function: IntegralKiSlider
        function IntegralKiSliderValueChanged(app, event)
            value = app.IntegralKiSlider.Value;
            value = round(value*500)/500;
            app.IntegralKiSlider.Value=value;
            
        end

        % Value changed function: ProportionalKpSlider
        function ProportionalKpSliderValueChanged(app, event)
            value = app.ProportionalKpSlider.Value;
            value=round(value,2);
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
            app.UIFigure.Position = [100 100 1088 719];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '2x'};
            app.GridLayout.RowHeight = {'0.4x', '0.2x', '1x', '1x', '1x'};

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Car and relative movement')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.XTickLabel = '';
            app.UIAxes.YTickLabel = '';
            app.UIAxes.Layout.Row = [2 3];
            app.UIAxes.Layout.Column = 2;

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.GridLayout);
            title(app.UIAxes3, 'Throttle')
            xlabel(app.UIAxes3, 'time (sec)')
            ylabel(app.UIAxes3, 'units')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.Layout.Row = 5;
            app.UIAxes3.Layout.Column = 2;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout);
            title(app.UIAxes2, 'Velocity')
            xlabel(app.UIAxes2, 'time (sec)')
            ylabel(app.UIAxes2, 'm/s')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.Layout.Row = 4;
            app.UIAxes2.Layout.Column = 2;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout2.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout2.Layout.Row = 4;
            app.GridLayout2.Layout.Column = 1;
            app.GridLayout2.BackgroundColor = [1 0.8 0.6];

            % Create ControlparametersCsKpKisLabel
            app.ControlparametersCsKpKisLabel = uilabel(app.GridLayout2);
            app.ControlparametersCsKpKisLabel.BackgroundColor = [1 0.502 0.302];
            app.ControlparametersCsKpKisLabel.HorizontalAlignment = 'center';
            app.ControlparametersCsKpKisLabel.FontSize = 18;
            app.ControlparametersCsKpKisLabel.FontWeight = 'bold';
            app.ControlparametersCsKpKisLabel.Layout.Row = 1;
            app.ControlparametersCsKpKisLabel.Layout.Column = [1 2];
            app.ControlparametersCsKpKisLabel.Text = 'Control parameters: C(s) = Kp + Ki/s';

            % Create ProportionalKpLabel
            app.ProportionalKpLabel = uilabel(app.GridLayout2);
            app.ProportionalKpLabel.HorizontalAlignment = 'right';
            app.ProportionalKpLabel.FontSize = 14;
            app.ProportionalKpLabel.Layout.Row = 2;
            app.ProportionalKpLabel.Layout.Column = 1;
            app.ProportionalKpLabel.Text = 'Proportional (Kp)';

            % Create ProportionalKpSlider
            app.ProportionalKpSlider = uislider(app.GridLayout2);
            app.ProportionalKpSlider.Limits = [0 1];
            app.ProportionalKpSlider.ValueChangedFcn = createCallbackFcn(app, @ProportionalKpSliderValueChanged, true);
            app.ProportionalKpSlider.FontSize = 14;
            app.ProportionalKpSlider.Layout.Row = 2;
            app.ProportionalKpSlider.Layout.Column = 2;
            app.ProportionalKpSlider.Value = 0.2;

            % Create IntegralKiLabel
            app.IntegralKiLabel = uilabel(app.GridLayout2);
            app.IntegralKiLabel.HorizontalAlignment = 'right';
            app.IntegralKiLabel.FontSize = 14;
            app.IntegralKiLabel.Layout.Row = 3;
            app.IntegralKiLabel.Layout.Column = 1;
            app.IntegralKiLabel.Text = 'Integral (Ki)';

            % Create IntegralKiSlider
            app.IntegralKiSlider = uislider(app.GridLayout2);
            app.IntegralKiSlider.Limits = [0 0.2];
            app.IntegralKiSlider.ValueChangedFcn = createCallbackFcn(app, @IntegralKiSliderValueChanged, true);
            app.IntegralKiSlider.FontSize = 14;
            app.IntegralKiSlider.Layout.Row = 3;
            app.IntegralKiSlider.Layout.Column = 2;
            app.IntegralKiSlider.Value = 0.02;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout);
            app.GridLayout3.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout3.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout3.Layout.Row = 3;
            app.GridLayout3.Layout.Column = 1;
            app.GridLayout3.BackgroundColor = [0.902 1 0.502];

            % Create CarparametersGs1000MsBLabel
            app.CarparametersGs1000MsBLabel = uilabel(app.GridLayout3);
            app.CarparametersGs1000MsBLabel.BackgroundColor = [1 1 0];
            app.CarparametersGs1000MsBLabel.HorizontalAlignment = 'center';
            app.CarparametersGs1000MsBLabel.FontSize = 18;
            app.CarparametersGs1000MsBLabel.FontWeight = 'bold';
            app.CarparametersGs1000MsBLabel.Layout.Row = 1;
            app.CarparametersGs1000MsBLabel.Layout.Column = [1 2];
            app.CarparametersGs1000MsBLabel.Text = 'Car parameters:  G(s) = 1000/(Ms+B)';

            % Create MassMkgSliderLabel
            app.MassMkgSliderLabel = uilabel(app.GridLayout3);
            app.MassMkgSliderLabel.HorizontalAlignment = 'right';
            app.MassMkgSliderLabel.FontSize = 14;
            app.MassMkgSliderLabel.Layout.Row = 2;
            app.MassMkgSliderLabel.Layout.Column = 1;
            app.MassMkgSliderLabel.Text = 'Mass (M kg)';

            % Create MassMkgSlider
            app.MassMkgSlider = uislider(app.GridLayout3);
            app.MassMkgSlider.Limits = [200 1000];
            app.MassMkgSlider.MajorTicks = [200 400 600 800 1000];
            app.MassMkgSlider.MajorTickLabels = {'200', '400', '600', '800', '1000'};
            app.MassMkgSlider.ValueChangedFcn = createCallbackFcn(app, @MassMkgSliderValueChanged, true);
            app.MassMkgSlider.MinorTicks = [200 300 400 500 600 700 800 900 1000];
            app.MassMkgSlider.FontSize = 14;
            app.MassMkgSlider.Layout.Row = 2;
            app.MassMkgSlider.Layout.Column = 2;
            app.MassMkgSlider.Value = 500;

            % Create FrictionBNsmSliderLabel
            app.FrictionBNsmSliderLabel = uilabel(app.GridLayout3);
            app.FrictionBNsmSliderLabel.HorizontalAlignment = 'right';
            app.FrictionBNsmSliderLabel.FontSize = 14;
            app.FrictionBNsmSliderLabel.Layout.Row = 3;
            app.FrictionBNsmSliderLabel.Layout.Column = 1;
            app.FrictionBNsmSliderLabel.Text = 'Friction (B Ns/m)';

            % Create FrictionBNsmSlider
            app.FrictionBNsmSlider = uislider(app.GridLayout3);
            app.FrictionBNsmSlider.Limits = [0 500];
            app.FrictionBNsmSlider.MajorTicks = [0 100 200 300 400 500];
            app.FrictionBNsmSlider.MajorTickLabels = {'0', '100', '200', '300', '400', '500'};
            app.FrictionBNsmSlider.ValueChangedFcn = createCallbackFcn(app, @FrictionBNsmSliderValueChanged, true);
            app.FrictionBNsmSlider.MinorTicks = [50 100 150 200 250 300 350 400 450 500];
            app.FrictionBNsmSlider.FontSize = 14;
            app.FrictionBNsmSlider.Layout.Row = 3;
            app.FrictionBNsmSlider.Layout.Column = 2;
            app.FrictionBNsmSlider.Value = 200;

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

            % Create DisturbancesDropDownLabel
            app.DisturbancesDropDownLabel = uilabel(app.GridLayout4);
            app.DisturbancesDropDownLabel.HorizontalAlignment = 'center';
            app.DisturbancesDropDownLabel.FontSize = 14;
            app.DisturbancesDropDownLabel.Layout.Row = 2;
            app.DisturbancesDropDownLabel.Layout.Column = 1;
            app.DisturbancesDropDownLabel.Text = 'Disturbances';

            % Create DisturbancesDropDown
            app.DisturbancesDropDown = uidropdown(app.GridLayout4);
            app.DisturbancesDropDown.Items = {'Horizontal slope', 'Uphill', 'Downhill', 'Head wind and no slope', 'Head wind with uphill', 'Random wind and hills'};
            app.DisturbancesDropDown.FontSize = 14;
            app.DisturbancesDropDown.Layout.Row = 2;
            app.DisturbancesDropDown.Layout.Column = 2;
            app.DisturbancesDropDown.Value = 'Horizontal slope';

            % Create TargettypeDropDownLabel
            app.TargettypeDropDownLabel = uilabel(app.GridLayout4);
            app.TargettypeDropDownLabel.HorizontalAlignment = 'center';
            app.TargettypeDropDownLabel.WordWrap = 'on';
            app.TargettypeDropDownLabel.FontSize = 14;
            app.TargettypeDropDownLabel.Layout.Row = 3;
            app.TargettypeDropDownLabel.Layout.Column = 1;
            app.TargettypeDropDownLabel.Text = 'Target type';

            % Create TargettypeDropDown
            app.TargettypeDropDown = uidropdown(app.GridLayout4);
            app.TargettypeDropDown.Items = {'Step in target', 'Square wave'};
            app.TargettypeDropDown.FontSize = 14;
            app.TargettypeDropDown.Layout.Row = 3;
            app.TargettypeDropDown.Layout.Column = 2;
            app.TargettypeDropDown.Value = 'Step in target';

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout);
            app.GridLayout5.ColumnWidth = {'1.8x', '1x'};
            app.GridLayout5.RowHeight = {'1x'};
            app.GridLayout5.Layout.Row = 1;
            app.GridLayout5.Layout.Column = 2;
            app.GridLayout5.BackgroundColor = [0.6 1 1];

            % Create CruisecontrolusingPIcompensationLabel
            app.CruisecontrolusingPIcompensationLabel = uilabel(app.GridLayout5);
            app.CruisecontrolusingPIcompensationLabel.BackgroundColor = [0 1 1];
            app.CruisecontrolusingPIcompensationLabel.FontSize = 24;
            app.CruisecontrolusingPIcompensationLabel.FontWeight = 'bold';
            app.CruisecontrolusingPIcompensationLabel.Layout.Row = 1;
            app.CruisecontrolusingPIcompensationLabel.Layout.Column = 1;
            app.CruisecontrolusingPIcompensationLabel.Text = 'Cruise control using PI compensation';

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

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = cruisecontrol

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

