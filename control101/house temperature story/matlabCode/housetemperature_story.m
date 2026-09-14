classdef housetemperature_story < matlab.apps.AppBase
    %HOUSETEMPERATURE_STORY
    %   File written by J.A.Rossiter, University of Sheffield  
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   
    %   A simple interface to practice behaviour of a simple car model
    %   subject to changes in mass, friction, enging power road slope
    %   and wind.
    %   
    %   Some notes and engineering background are in the partner
    %   livescript file:    carmodel_and_behaviour_manual.mlx
    %   A group of similar files can be downloaded through MATLAB
    %   add-ons with the toolbox name: control101
    %     
    %      
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   %%%%%%%%%%%%  FILE ORGANISATION
    %   A section defining the core variables stored in "app"
    %   
    %       A section with subfunctions doing the core computations
    %       i) define behaviour models; 
    %       ii) find linear responses to inputs and disturbances; 
    %       iii) initialise figures for animations and analysis; 
    %       iv) control the animations
    %       v) switch interaction on and off during animations
    %       vi) clean figures and legends so can begin a new investigation
    %       vii) callbacks (subfunctions) for every item in the interface
    %   to control decimal places and the like.
    %       
    %       A callback which activates with the 'start simulation' button
    %   and runs the subfunctions in turn.

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        TabGroup                        matlab.ui.container.TabGroup
        OpenloopbehaviourTab            matlab.ui.container.Tab
        GridLayout7                     matlab.ui.container.GridLayout
        WindspeedDropDown               matlab.ui.control.DropDown
        WindspeedDropDownLabel          matlab.ui.control.Label
        ExternaltemperatureDropDown     matlab.ui.control.DropDown
        ExternaltemperatureDropDownLabel  matlab.ui.control.Label
        StrongwindincreasestheheatlossLabel  matlab.ui.control.Label
        Label3                          matlab.ui.control.Label
        REMARKSLabel                    matlab.ui.control.Label
        Label                           matlab.ui.control.Label
        OpenloopmodellingTab            matlab.ui.container.Tab
        GridLayout8                     matlab.ui.container.GridLayout
        EditField_2                     matlab.ui.control.NumericEditField
        EditField                       matlab.ui.control.NumericEditField
        GainperkWK1kLabel               matlab.ui.control.Label
        TimeconstanthrPCkLabel          matlab.ui.control.Label
        Label_2                         matlab.ui.control.Label
        UIAxes4                         matlab.ui.control.UIAxes
        ManualcontrolTab                matlab.ui.container.Tab
        GridLayout9                     matlab.ui.container.GridLayout
        PausesimulationButton           matlab.ui.control.Button
        IncludechangesinwindButton      matlab.ui.control.Button
        IncludechangesinTeButton        matlab.ui.control.Button
        StartsimulationButton           matlab.ui.control.Button
        SetheatingkWSlider              matlab.ui.control.Slider
        SetheatingkWSliderLabel         matlab.ui.control.Label
        Label3_2                        matlab.ui.control.Label
        Label2                          matlab.ui.control.Label
        Label_3                         matlab.ui.control.Label
        PIcontrolTab                    matlab.ui.container.Tab
        GridLayout10                    matlab.ui.container.GridLayout
        IntegralgainKiSlider            matlab.ui.control.Slider
        IntegralgainKiSliderLabel       matlab.ui.control.Label
        ProportionalgainKpSlider        matlab.ui.control.Slider
        ProportionalgainKpSliderLabel   matlab.ui.control.Label
        OnthistabblockagesanddisturbancesareconstantforsimplicityLabel  matlab.ui.control.Label
        Label2_2                        matlab.ui.control.Label
        REMARKSLabel_2                  matlab.ui.control.Label
        ControlparametersLabel          matlab.ui.control.Label
        ControlwithuncertaintyTab       matlab.ui.container.Tab
        GridLayout11                    matlab.ui.container.GridLayout
        UsingPIcontrolButton            matlab.ui.control.Button
        IncludingchangesinexternaltemperatureButton  matlab.ui.control.Button
        IncludingwindeffectsButton      matlab.ui.control.Button
        IncludingmeasurementdelayButton  matlab.ui.control.Button
        IncludingmeasurementnoiseButton  matlab.ui.control.Button
        StartButton                     matlab.ui.control.Button
        Label_8                         matlab.ui.control.Label
        Label_7                         matlab.ui.control.Label
        Label_6                         matlab.ui.control.Label
        Label_5                         matlab.ui.control.Label
        Label_4                         matlab.ui.control.Label
        GridLayout6                     matlab.ui.container.GridLayout
        WindspeedmsSlider               matlab.ui.control.Slider
        WindspeedmsSliderLabel          matlab.ui.control.Label
        ExternaltemperatureTedegSlider  matlab.ui.control.Slider
        ExternaltemperatureTedegSliderLabel  matlab.ui.control.Label
        HeatsupplyWkWSlider             matlab.ui.control.Slider
        HeatsupplyWkWSliderLabel        matlab.ui.control.Label
        EnvironmentparametersLabel      matlab.ui.control.Label
        GridLayout4                     matlab.ui.container.GridLayout
        HouseparametersCdTdtkTTeWLabel  matlab.ui.control.Label
        ThermalcapacityCMJdegSlider     matlab.ui.control.Slider
        ThermalcapacityCMJdegSliderLabel  matlab.ui.control.Label
        HeatlosskkWdegSlider            matlab.ui.control.Slider
        HeatlosskkWdegSliderLabel       matlab.ui.control.Label
        GridLayout3                     matlab.ui.container.GridLayout
        AnimationOnButton               matlab.ui.control.Button
        RefreshButton                   matlab.ui.control.Button
        SimulateButton                  matlab.ui.control.Button
        GridLayout2                     matlab.ui.container.GridLayout
        Image                           matlab.ui.control.Image
        stordermodelforhousetemperatureLabel  matlab.ui.control.Label
        UIAxes3                         matlab.ui.control.UIAxes
        UIAxes2                         matlab.ui.control.UIAxes
        UIAxes                          matlab.ui.control.UIAxes
    end

    % File written by J.A.Rossiter, University of Sheffield
    % See website for more files like this.
    % https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    % A simple interface to practice behaviour of a simple car model 
    % subject to changes in mass, friction, enging power road slope and wind
    % 
    % Some notes and engineering background are in the partner livescript
    % file:    carmodel_and_behaviour_manual.mlx
    % A group of similar files can be downloaded through MATLAB add-ons
    % with the toolbox name:  ********************
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%  FILE ORGANISATION
    % A section defining the core variables stored in "app"
    %
    % A section with subfunctions doing the core computations
    % i) define behaviour models; 
    % ii) find linear responses to inputs and disturbances; 
    % iii) initialise figures for animations and analysis; 
    % iv) control the animations
    % v) switch interaction on and off during animations
    % vi) clean figures and legends so can begin a new investigation
    % vii) callbacks (subfunctions) for every item in the interface to control decimal
    % places and the like.
    % 
    % A callback which activates with the 'start simulation' button
    % and runs the subfunctions in turn.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % The next section defines all the core variables used in the code and
    % that it may be convenient to have available in the various
    % subfunctions
    properties (Access = private)
         originalsize     % product of width and height for font sizing

        legstring=cell(1); % To store legends
      
        house   % handle for house picture
        arrowhandle =[0 0 0]  %  handle for wind arrows
        heatsquare  % handle for heating block
        runtime = 18000; % for simulation the runtime (5 hr)
        time;  % variable to store time instants for simulation plots
        time2; % for time constant and gain analysis plot
        samples = 201;
        animationtime = 8; % how long animation will take
        Tsamp=0.1;  % update rate for animation
        Tsamp_anim=0.1;  % update rate for animation
        Tsample = 20;  % sample rate for discretisation (should be fast enough)
        T  % time constant
        G % nominal model
        Gw % model with wind
        H % dependence on external temperature
        Hw
        Gdis % discretised model
        Gwdis % discretised model with wind
        Hdis
        Hwdis

        Gss % expected steady-state
        Gssw % expected ss with wind
        blocksave % for saving the wind action
        distsave % saving the external temperature action
       
        % Model parameters
        k
        C
        W
       
        steadylineplot;  % needed, especially if a square wave
        ytotal; % sum of all output components
        u % input signal
        unitstep % step response
        target = 20; % notional desired temperature
        targetline2 ; % handle for target line in output plot
        targetline3 ; % handle for target line in input plot
        
        % manual control buttons
        include_Te=1 % for use during manual control
        include_wind=1 % for use during manual control
        pause = true;  % for use during manual and uncertainty control
        changingu =0;

        % Continuous control app buttons
        include_dist2=1 % for use during uncertainty control
        include_blockage2=1 % for use during uncertainty control
        include_noise =1;
        include_delay =1;
        include_onoff = 1;  % use PI or on off control
        
        
    end
    
    methods (Access = private)
        


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  PLOT OF TOP FIGURE - THE HOUSE ANIMATION
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function app = createhouseoutline(app)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%% Colour mappings, blue = cold, red = hot
            % -10 = [0 0 1] =low    40 = [1 0 0] = high
            % colort = low + (T+10)*(high -low)/50
            startcolor = [0 0 1] + (app.ExternaltemperatureTedegSlider.Value+10)*[1 0 -1]/50;  
            
            % Set up basic picture of the house in the top plot
            % house paramters
            x2 = [-7:7]; y2 = x2;
            plot(app.UIAxes,x2,x2,'w');
            hold(app.UIAxes,'on')
            
            %
            scale = sqrt(app.ThermalcapacityCMJdegSlider.Value*3);                      
            x=[-1,1,1,1.2,0,-1.2,-1,-1,1]*scale;
            y=[-1 -1 1 1 1.3 1 1 -1,-1]*scale;
            width = max(50/app.HeatlosskkWdegSlider.Value,1);
            
            plot(app.UIAxes,x,y,'k-','linewidth',width);
            app.house=fill(app.UIAxes,[x],[y],[startcolor]);
            
            % Heating symbols at the middle
            W = app.HeatsupplyWkWSlider.Value;
            app.heatsquare = fill(app.UIAxes,2*[-0.2,-0.2,0.2,0.2]*W/20,2*[-0.2,0.2,0.2,-0.2]*W/20,'r');
            plot(app.UIAxes,[1 3],[1,3],'r','linewidth',2)
            plot(app.UIAxes,[1 3],[-1,-3],'r','linewidth',2)
            plot(app.UIAxes,[-1 -3],[-1,-3],'r','linewidth',2)
            plot(app.UIAxes,[-1 -3],[1,3],'r','linewidth',2)
            
            
            % Add arrows showing the wind
            w= app.WindspeedmsSlider.Value/10; 
            x=[7.5 6 6 5.5 6 6 7.5];
            y = [6 6 6-(0.1*w) 6+w/2 6+1.1*w 6+w 6+w]-3;
            app.arrowhandle(1)=fill(app.UIAxes,x,y,'g');
            app.arrowhandle(2)=fill(app.UIAxes,x,y-4.2,'g');
            app.arrowhandle(3)=fill(app.UIAxes,x,y-8.4,'g');

            hold(app.UIAxes,'off')

            
        end      %%% END OF HOUSEOUTLINE SUBFUNCTION

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  Down load data from sliders and create models and responses
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function app = createmodels(app)

           
           % Collect data from sliders and round
           wind=app.WindspeedmsSlider.Value;
           app.k = app.HeatlosskkWdegSlider.Value*1000;
           app.C=app.ThermalcapacityCMJdegSlider.Value*10^6;
           app.W=app.HeatsupplyWkWSlider.Value*1000;
           Te = app.ExternaltemperatureTedegSlider.Value;
           T0=Te;  % Assume initial temperature is external temperature

           % heat loss depends upon the wind
           kwind = app.k*(1+wind/100);
           
            % define model wiht and without wind
            %  y = G W + H*Te
            app.G= tf(1,[app.C,app.k]);
            app.Gw = tf(1,[app.C,kwind]);
            app.H = tf(app.k,[app.C,app.k]);
            app.Hw = tf(kwind,[app.C,kwind]);

            % Discretise
            app.Gdis = c2d(app.G,app.Tsample);
            app.Gwdis=c2d(app.Gw,app.Tsample);  % with blockage
            app.Hdis = c2d(app.H,app.Tsample);
            app.Hwdis=c2d(app.Hw,app.Tsample);  % with blockage
                      
            % properties
            app.Gss = dcgain(app.G)*app.W;
            app.Gssw = dcgain(app.Gw)*app.W;
            app.time=linspace(0,app.runtime,app.samples);
            app.steadylineplot = ones(1,length(app.time))*(app.Gss*app.W+Te); % nominal only
          
            %yss = Te+(1/k)*W;           % steady-state temp  (noted that k in KJ)
            %ysswind = Te+(1/kwind)*W;   % ss with wind
            
            %
            tau = app.C/app.k;  %% time constant   (noted that C in MJ and k in KJ)
            tau=tau/3600;  %% convert to hrs
            app.T = tau;  % save time constant
            
            

        end   % end of create models subfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Manage the animation and legends
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        function app = animationoflineplots(app)
            %%  Set up legend
            if isempty(app.legstring{1});
                nlegstring=1;
                app.targetline2=plot(app.UIAxes2,[0,app.time(end)],[1 1]*app.target,'g--','linewidth',2);
                app.legstring{1} = 'Target temperature';
                hold(app.UIAxes2,'on');
                
            else
                nlegstring = length(app.legstring);
            end
            switch app.TabGroup.SelectedTab.Title
                case 'PI control'
                app.legstring{nlegstring+1}=['C = ',num2str(app.ThermalcapacityCMJdegSlider.Value),...
                ', k = ',num2str(app.HeatlosskkWdegSlider.Value),...
                ', Kp = ',num2str(app.ProportionalgainKpSlider.Value),...
                ', Ki = ',num2str(app.IntegralgainKiSlider.Value),...
                ', Te = ',num2str(app.ExternaltemperatureTedegSlider.Value),...                
                ', wind ',num2str(app.WindspeedmsSlider.Value)];

                otherwise
                app.legstring{nlegstring+1}=['C = ',num2str(app.ThermalcapacityCMJdegSlider.Value),...
                ', k = ',num2str(app.HeatlosskkWdegSlider.Value),...
                ', Power = ',num2str(app.HeatsupplyWkWSlider.Value),...
                ', Te = ',num2str(app.ExternaltemperatureTedegSlider.Value),...
                ', P = ',num2str(round(app.T,2)),...
                ', wind ',num2str(app.WindspeedmsSlider.Value)];

            end

                      
            
            
            % initialise figures of temp response and disturbances
                        
            yplot = plot(app.UIAxes2,app.time(1),app.ytotal(1));  %% dynamic line plot of depth
            xlabel(app.UIAxes2,'time (hr)')
            hold(app.UIAxes2,'on')
            kk=legend(app.UIAxes2,app.legstring,'Location','southeast','fontsize',8);
            set(kk,'fontsize',10);
            grid(app.UIAxes2,'on')
            
            hold(app.UIAxes3,'off')
            app.targetline3 = plot(app.UIAxes3,[0,app.time(end)],[1 1]*app.target/(dcgain(app.G)*1000),'g--','linewidth',2);
            hold(app.UIAxes3,'on');
            uplot = plot(app.UIAxes3,app.time(1),app.u(1)/1000);
            bb= app.blocksave*app.WindspeedmsSlider.Value; % blocksave has zeros and ones
            dd= app.distsave*app.ExternaltemperatureTedegSlider.Value;  % distsave has zeros and ones
            dplot = plot(app.UIAxes3,app.time(1),dd(1));
            bplot = plot(app.UIAxes3,app.time(1),bb(1));          
            legend(app.UIAxes3,'Expected steady input (kW)','Input (kW)','Te','Wind')
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% animation of house temperature plot
            % define animation time aspects
            animationsamples = app.animationtime/app.Tsamp; % assume sample time of Tsamp
            updaterate =ceil(app.samples/animationsamples); % no of samples between pauses
            tstart=tic; tsave = tstart;

            for k=1:length(app.time);
                

                % output plot
                set(yplot,'Ydata',app.ytotal(1:k),'Xdata',app.time(1:k));                
                
                % house plot
                kout = app.ytotal(k)/0.6;
                newcolor=[0 0 1] + (app.ytotal(k)+10)*[1 0 -1]/50;
                if app.ytotal(k)>40;newcolor = [1 0 0];end
                set(app.house,'FaceColor',newcolor);   %% Update house picture
                W = app.u(k)/1000;
                set(app.heatsquare,'XData',2*[-0.2,-0.2,0.2,0.2]*W/20,'YData',2*[-0.2,0.2,0.2,-0.2]*W/20);
         
            
                % input plot
                set(uplot,'Ydata',app.u(1:k)/1000,'Xdata',app.time(1:k));
                set(dplot,'Ydata',dd(1:k),'Xdata',app.time(1:k));
                set(bplot,'Ydata',bb(1:k),'Xdata',app.time(1:k));
                
                % Pause animation every updaterate samples only so rem(k,updaterate) 
                % checks for this
                if and(strcmp(app.AnimationOnButton.Text,'Animation On'),not(rem(k,updaterate)));
                    pause(app.Tsamp-toc(tstart));  %% Clumsy application of sampling time
                    tstart = tic;
                    drawnow limitrate
                end
                
            end
            %ttotal= toc(tsave)  % total time taken by animation loop
        end  % end of animation

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  Time constant and gain analysis
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
        function app = timeconstantanalysis(app)
            
            % nominal response from zero
            k = app.HeatlosskkWdegSlider.Value*1000;
            u=2*10^4; % let input be 20KW
            app.HeatsupplyWkWSlider.Value = u/1000;
            app.time = linspace(0,4*app.T,app.samples);
            app.ytotal = u*(1-exp(-app.time/app.T))/k;
            app.Gss = dcgain(app.G)*u;
            
                        
            plot(app.UIAxes4,app.time,app.ytotal,'b');
            hold(app.UIAxes4,'on') ;
            plot(app.UIAxes4,[app.T,app.T],[0,app.Gss],'r-.','linewidth',3)
            plot(app.UIAxes4,[0,4*app.T],[app.Gss,app.Gss],'g-.','linewidth',3)
            kkk=legend(app.UIAxes4,'Temperature','Time constant','Steady-state');
            set(kkk,'fontsize',10);
            text(app.UIAxes4,app.T*1.1,app.Gss/3,['P = ',num2str(round(app.T,2)),' (hr)'...
                ', Steady-state (20 kW) = ',num2str(round(app.Gss,2))],'fontsize', 16);
            xlabel(app.UIAxes4,'time (hr)');
            title(app.UIAxes4,'Unit step response and analysis')
            grid(app.UIAxes4,'on');
            hold(app.UIAxes4,'off');

            % update parameter values in the tab
            app.EditField.Value = app.T;
            app.EditField_2.Value = dcgain(app.G)*1000;

            % No disturbances for simple modelling tab - set to zero
            k=length(app.time);
            app.u = ones(1,k)*u;
            app.distsave = zeros(1,k);
            app.blocksave = zeros(1,k);
            app.WindspeedmsSlider.Value=0;
            app.ExternaltemperatureTedegSlider.Value=0;


        end  % end of timeconstant and gain analysis figure



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Control interaction during the animation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function  disablebuttons(app)
            set(app.SimulateButton, 'Enable', 'off');
            set(app.RefreshButton, 'Enable', 'off');
            set(app.AnimationOnButton, 'Enable', 'off');
            set(app.ExternaltemperatureTedegSlider, 'Enable', 'off');
            set(app.HeatsupplyWkWSlider, 'Enable', 'off');
            set(app.WindspeedmsSlider, 'Enable', 'off');
            set(app.ThermalcapacityCMJdegSlider, 'Enable', 'off');
            set(app.HeatlosskkWdegSlider, 'Enable', 'off');

            set(app.WindspeedDropDown, 'Enable', 'off');
            set(app.ExternaltemperatureDropDown, 'Enable', 'off');
            set(app.IntegralgainKiSlider, 'Enable', 'off');
            set(app.ProportionalgainKpSlider, 'Enable', 'off');
        end
        
        function enablebuttons(app)
            set(app.SimulateButton, 'Enable', 'on');
            set(app.RefreshButton, 'Enable', 'on')
            set(app.AnimationOnButton, 'Enable', 'on')
            set(app.ExternaltemperatureTedegSlider, 'Enable', 'on');
            set(app.HeatsupplyWkWSlider, 'Enable', 'on');
            set(app.WindspeedmsSlider, 'Enable', 'on');
            set(app.ThermalcapacityCMJdegSlider, 'Enable', 'on');
            set(app.HeatlosskkWdegSlider, 'Enable', 'on');
            set(app.WindspeedDropDown, 'Enable', 'on');
            set(app.ExternaltemperatureDropDown, 'Enable', 'on');
            set(app.IntegralgainKiSlider, 'Enable', 'on');
            set(app.ProportionalgainKpSlider, 'Enable', 'on');
 
        end


        
        function app = openloopresponses(app)
            % Define the nominal step responses
            % Use discrete approximations as easiest way to handle
            % uncertainty
            % Model is given as (T-Te) = G(s) * W

            % Models: Use N1,D1,dist1 for 1st half and N2,D2,dist2 thereafter
            [n,d] = tfdata(app.Gdis,'v');
            [nb,db] = tfdata(app.Gwdis,'v'); % with wind
            %   d(z) * (T-Te) = n(z)*W
            
            % Change time due to sample rate
            T0 = app.ExternaltemperatureTedegSlider.Value;
            app.time=(0:app.Tsample/3600:4*app.T); % express time in hr
            k2 = round(length(app.time)/2);
            kend =length(app.time);
            u = ones(1,kend)*app.W;
            

           % Wind speed changes
           sw2 = app.WindspeedDropDown.Value;
            switch sw2
                case 'Change at t=0'
                    N1=nb;D1=db; N2=nb;D2=db;
                    app.blocksave = ones(1,kend);
                case 'Change mid-simulation'
                    N1=n;D1=d; N2 = nb; D2=db;
                    app.blocksave = [zeros(1,k2),ones(1,kend-k2)];
            end

            % External temperature changes
            % intialise output at zero or external as appropriate
            sw1= app.ExternaltemperatureDropDown.Value;
            switch sw1
                case 'Change at t=0'
                    dist1 = app.ExternaltemperatureTedegSlider.Value;
                    dist2 = dist1;
                    app.distsave = ones(1,kend);   % zeros and ones
                    y = dist1;
                case 'Change mid-simulation'
                    dist2 = app.ExternaltemperatureTedegSlider.Value;
                    dist1 = 0;
                    app.distsave = [zeros(1,k2),ones(1,kend-k2)];
                    y=0;
            end

            
            
            % The model changes with the disturbances, so we use a conditional to assess
            % the appropriate model. This switch only occurs mid-simulation
            % Model is given as (T-Te) = G(s) * W  where Te = dist1
            for k=2:k2;
                y(k)=N1(end)*u(k-1)-D1(end)*(y(k-1)-dist1) + dist1;
                              
            end
            for k=k2+1:kend;
                y(k)=N2(end)*u(k-1)-D2(end)*(y(k-1)-dist2)+ dist2;
                 
            end

            app.ytotal = y;
            app.u = u;
            ylabel(app.UIAxes3,'Open-loop behaviour')
            
        end


        
        function app= manualcontrol(app)
            RefreshButtonPushed(app) % clean figures
            disablebuttons(app);
            app.pause=true;
            app = createmodels(app); % define models
            app = createhouseoutline(app); % define house outline for animation
            
            
            % Models: Use N1,D1,dist1 for 1st half and N2,D2,dist2 thereafter
            %  y = Gu -H Te
            %  d(z) y = n(z)u + nt(z) Te
            [n,d] = tfdata(app.Gdis,'v'); n = n(end); d= d(2);
            [nb,db] = tfdata(app.Gwdis,'v'); nb=nb(end); db = db(2);% with wind
            [nt,dt] = tfdata(app.Hdis,'v'); nt = nt(end);
            [nbt,dbt] = tfdata(app.Hwdis,'v'); nbt=nbt(end);% with wind
            
            % Create a discrete simulation with randomly varying
            % disturbances and blockages (activated or not as desired)
            % Maximum of 2400 samples
            v = ones(40,1);
            dist = v*(randi(2,1,60)-1); dist = dist(:);
            wind = v*(randi(2,1,60)-1); wind = wind(:); 

            % Initialise plots
            yplot = plot(app.UIAxes2,0,0);        
            xlabel(app.UIAxes2,'time (hr)')
            grid(app.UIAxes2,'on')
            hold(app.UIAxes2,'on')
            rplot = plot(app.UIAxes2,0,app.target,'g--','linewidth',2);
            legend(app.UIAxes2,'Temperature','Target')
            ylim(app.UIAxes2,'auto')
            ylabel(app.UIAxes2,'Manual control behaviour')
            title(app.UIAxes2,'Temperature behaviour')


            uplot = plot(app.UIAxes3,0,0);
            hold(app.UIAxes3,'on')
            dplot = plot(app.UIAxes3,0,0);
            bplot = plot(app.UIAxes3,0,0);
            ylim(app.UIAxes3,'auto');
            legend(app.UIAxes3,'Input','Te','Wind')

            % Do simulation
            cont=1; y=[0 0]; k=1; time =0; r=app.target;
            app.changingu=app.SetheatingkWSlider.Value;
            TT=app.Tsample/3600;
            while and(cont==1,k<2400);
                k=k+1;
                time(k)=(k-1)*TT;
                u(k) = app.changingu*1000;
                r(k)=app.target;
                if app.include_Te==1; 
                    disturbance(k)=app.ExternaltemperatureTedegSlider.Value*dist(k);
                else
                    disturbance(k)=0;
                end

                if app.include_wind==1;
                    wind(k)=app.WindspeedmsSlider.Value*wind(k);
                    y(k+1) = nb*u(k)-db*(y(k))+nbt*disturbance(k);
                else
                    wind(k)=0;
                    y(k+1) = n*u(k)-d*(y(k))+nt*disturbance(k);
                end
  
                % Plotting - no overlays used here
                set(yplot,'Ydata',y(1:k),'Xdata',time(1:k));
                set(rplot,'Ydata',r(1:k),'Xdata',time(1:k));
                set(uplot,'Ydata',u(1:k)/1000,'Xdata',time(1:k));
                set(dplot,'Ydata',disturbance(1:k),'Xdata',time(1:k));
                set(bplot,'Ydata',wind(1:k),'Xdata',time(1:k));
                
                % House picture
                kout = y(k)/0.6;
                newcolor=[0 0 1] + (y(k)+10)*[1 0 -1]/50;
                if y(k)>40;newcolor = [1 0 0];end
                set(app.house,'FaceColor',newcolor);   %% Update house picture
                w=wind(k)/10;
                yarrow = [6 6 6-(0.1*w) 6+w/2 6+1.1*w 6+w 6+w]-3;
                set(app.arrowhandle(1),'Ydata',yarrow);
                set(app.arrowhandle(2),'Ydata',yarrow-4.2);
                set(app.arrowhandle(3),'Ydata',yarrow-8.4);
                W = u(k)/1000;
                set(app.heatsquare,'XData',2*[-0.2,-0.2,0.2,0.2]*W/20,'YData',2*[-0.2,0.2,0.2,-0.2]*W/20);
                
                val = app.StartsimulationButton.Text;
                if strcmp(val,'Start simulation'); % because already set to end so this means end selected
                    cont=0;
                end

                drawnow % to ensure we collect relevant user input
                % Pause button action
                while not(app.pause);
                    pause(1);
                end
                
            end

            enablebuttons(app);
            
        end  % end of manualcontrol


        
        function app = closedloop_responses(app)
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % This function determines all the closed-loop UNIT step responses
            % Based on current values of the sliders and assuming the
            % uncertainty is fixed

           
            % collect compensator and house values from the sliders
            % round values to avoid unnecessary decimal places
            Kp=app.ProportionalgainKpSlider.Value;
            Ki=app.IntegralgainKiSlider.Value;
            PI =tf([Kp,Ki],[1 0]);
            app.runtime=round(5*app.T*3600);
            app.time=linspace(0,app.runtime,app.samples);
            kend = length(app.time);
            
            % Collect disturbance data from sliders
            % wind effect is embedded in the model
            dist=app.ExternaltemperatureTedegSlider.Value;
             
            %%% FIND CLOSED LOOP MODELS
            %  y = G W  + H Te     u = M(R- y)
            %  y = GM/(1+GM)* R + H/(1+GM) Te
            %  u = M/(1+GM) * R  - MH/(1+GM) Te
            Gc = feedback(app.Gw*PI,1); % target to depth
            Gcd = feedback(1,app.Gw*PI)*app.Hw;  % disturbance to depth
            Gcu = feedback(PI,app.Gw);  % target to in-flow
            Gcud = Gcu*app.Hw;
            
                        
            % find closed-loop responses
            Te = app.ExternaltemperatureTedegSlider.Value;
            [h]=step(Gc,app.time);    h = h*(app.target-Te) +Te;
            [u]=step(Gcu,app.time);   u = u*(app.target-Te) +Te;
            [hd]=step(Gcd,app.time);  hd = hd *dist;
            [ud]=step(Gcu,app.time);  ud = -ud*dist;
                                 
            app.ytotal = h+hd;
            app.u = u+ud;

            ylabel(app.UIAxes2,'Closed-loop behaviour')
            app.blocksave = ones(1,kend);
            app.distsave = ones(1,kend);
            app.time = app.time/3600; % put back into hrs
            
           
        end  % end of closed-loop responses
        
        function app = responseswithuncertainty(app)
            RefreshButtonPushed(app) % clean figures
            disablebuttons(app);
            app.pause=true;
            app = createmodels(app); % define models
            app = createhouseoutline(app); % define tank outline for animation
            
            
            % Models: Nominal model is fixed, but wind model needs to
            % be updated every time blockage changes
            [n,d] = tfdata(app.Gdis,'v'); n = n(end); d= d(2);
            Kp=app.ProportionalgainKpSlider.Value;
            Ki=app.IntegralgainKiSlider.Value;
            PI =tf([Kp,Ki],[1 0]);
            PId = c2d(PI,app.Tsample,'tustin');
            [nK,dK]=tfdata(PId,'v');
          
            
            % Create a discrete simulation with randomly varying
            % disturbances and wind (activated or not as desired)
            % Create variables to be interrogated to pick up updated
            % uncertainty every 50 samples.
            vwind = (randi(40,1,200)+5); % wind
            vdisturbance = (randi(20,1,200)-10); % actual value of external temperature
            vnoise = 0.4*(randi(8,1,200)+2)/5; % maximum value of noise
            vdelay = (randi(6,1,200)+2)*2; vdelay(1)=0;  % actual value of delay in samples
            counter=1;          

            % Initialise plots
            yplot = plot(app.UIAxes2,0,0);   
            xlabel(app.UIAxes2,'time (sec)')
            grid(app.UIAxes2,'on')
            hold(app.UIAxes2,'on')
            ymplot = plot(app.UIAxes2,0,0); 
            rplot = plot(app.UIAxes2,0,app.target,'g--','linewidth',2);
            legend(app.UIAxes2,'Temperature','Noisy measurement','Target','Location','southeast')
            ylim(app.UIAxes2,'auto')
            xlim(app.UIAxes2,'auto');
            ylabel(app.UIAxes2,'Closed-loop behaviour with uncertainty')
            
            uplot = plot(app.UIAxes3,0,0);
            hold(app.UIAxes3,'on')
            dplot = plot(app.UIAxes3,0,0);
            bplot = plot(app.UIAxes3,0,0);
            nplot = plot(app.UIAxes3,0,0);
            delayplot = plot(app.UIAxes3,0,0);
            ylim(app.UIAxes3,'auto');
            xlim(app.UIAxes3,'auto');
            legend(app.UIAxes3,'Input','Te','Wind','Noise magnitude (x10)','Delay (samples)','Location','southwest')

            % Do simulation
            cont=1; y=[0 0]; ym=y; e= y;
            k=1; time =0; u=[0 0];
            r=app.target;
            noise = [1 1]*vnoise(1); 
            disturbance = [1 1]*vdisturbance(1); 
            wind =[1 1]*vwind(1); 
            delay = [1 1]*vdelay(1);
            r = [1 1]*app.target;
            p=1;
            tstart=tic; 

            while and(cont==1,k<8000);
                k=k+1;
                
                % Update uncertainty and target
                p=p+1;  % counter for changes in uncertainty
                if p==300; %Change all uncertainty values
                    counter = counter+1;
                    p=1;
                    if r(k)==app.target;
                        r(k)=app.target+2;
                    else
                        r(k)=app.target;
                    end % target is a square wave
                    
                end                          
                r(k+1)=r(k);               
                time(k)=(k-1)*app.Tsample/3600;

                % Update control law
                % Check whether using PI or on-off control
                e(k) = r(k)-ym(k);
                if app.include_onoff==1;  % use PI
                    u(k) = (-dK(2)*u(k-1) + nK*e(k:-1:k-1)')/dK(1);
                    if u(k)<0;u(k)=0;end % add some saturation checks
                    if u(k)>200000; u(k)=200000;end
                
                else  % use on-off
                    u(k)=u(k-1); % default is no change
                    if e(k)>2;  % switch to maximum
                        u(k)=100000;
                    end
                    if e(k)<-2; % switch off
                        u(k) = 0;
                    end


                end

                % Update system uncertainty                
                if app.include_dist2==1; 
                    disturbance(k)=vdisturbance(counter);
                else
                    disturbance(k)=0;
                end
                if app.include_noise==1; 
                    noise(k+1)=vnoise(counter)*(rand(1)-0.5);
                else
                    noise(k+1)=0;
                end
                if app.include_blockage2==1;
                    block(k)=vwind(counter);
                else
                    block(k)=0;                  
                end
                if app.include_delay==1; 
                    delay(k)=vdelay(counter);
                else
                    delay(k)=0;
                end


                % define model and control for current sample
                % y  = G* W + H*Te;  Dk *u = Nk *(r-y)
                kk = app.HeatlosskkWdegSlider.Value*1000;
                C=app.ThermalcapacityCMJdegSlider.Value*10^6;
                % heat loss depends upon the wind
                kwind = kk*(1+block(k)/100);
                Gw = tf(1,[C,kwind]);
                Gwdis=c2d(Gw,app.Tsample);  % discretise
                Hw = tf(kwind,[C,kwind]);
                Hwdis=c2d(Hw,app.Tsample);  % with wind
                nb = Gwdis.numerator; nb = nb{:}; nb=nb(end);
                db = Gwdis.denominator; db = db{:};db = db(2);
                [nbt,dbt] = tfdata(Hwdis,'v'); nbt=nbt(end);% with wind
                                 
                % update model output
                y(k+1) = nb*u(k)-db*y(k)+nbt*disturbance(k);

                % add measurement noise and measurement delay
                ym(k+1) = y(k+1-delay(k))+noise(k+1-delay(k));

                % Plotting animation every 3 samples
                if rem(k,3);
                set(yplot,'Ydata',y(1:k),'Xdata',time(1:k));
                set(ymplot,'Ydata',ym(1:k),'Xdata',time(1:k));
                set(rplot,'Ydata',r(1:k),'Xdata',time(1:k));
                set(uplot,'Ydata',u(1:k)/1000,'Xdata',time(1:k));
                set(nplot,'Ydata',noise(1:k)*10,'Xdata',time(1:k));
                set(delayplot,'Ydata',delay(1:k),'Xdata',time(1:k));
                set(dplot,'Ydata',disturbance(1:k),'Xdata',time(1:k));
                set(bplot,'Ydata',block(1:k),'Xdata',time(1:k));
                
                % House colour picture
                kout = y(k)/0.6;
                newcolor=[0 0 1] + (y(k)+10)*[1 0 -1]/50;
                if y(k)>40;newcolor = [1 0 0];end
                set(app.house,'FaceColor',newcolor);   %% Update house picture
                w=block(k)/10;
                yarrow = [6 6 6-(0.1*w) 6+w/2 6+1.1*w 6+w 6+w]-3;
                set(app.arrowhandle(1),'Ydata',yarrow);
                set(app.arrowhandle(2),'Ydata',yarrow-4.2);
                set(app.arrowhandle(3),'Ydata',yarrow-8.4);
                W = u(k)/1000;
                set(app.heatsquare,'XData',2*[-0.2,-0.2,0.2,0.2]*W/20,'YData',2*[-0.2,0.2,0.2,-0.2]*W/20);

                % target line in tank plot
                %set(app.targetline1,'Ydata',[1,1]*(1+r(k)));
                            
                pause(app.Tsamp_anim-toc(tstart));  %% Clumsy application of sampling time
                tstart = tic;
                drawnow % to ensure we collect relevant user input

                end  % end of every 3 samples

                val = app.StartButton.Text;
                if strcmp(val,'Start'); % because already set to end so this means end selected
                    cont=0;
                end            
                                
            end  % end of the simulation loop


            enablebuttons(app);
        end % end of responses with uncertainty
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
           % resize to be in middle of  the window
            movegui(app.UIFigure)
            
            % Open the manual
            if exist('housetemperature_story_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open housetemperature_story_mycopy.mlx
            else
                p1 = which('housetemperature_story_manual.mlx');
                p2 = strcat(pwd,'/housetemperature_story_mycopy.mlx');
                copyfile(p1,p2)                
                open housetemperature_story_mycopy.mlx
                clear p1 p2
            end
            
            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);

            app = createhouseoutline(app); % define car outline for animation
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
            theme(app.UIFigure,"light")
            end
        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
            
            disablebuttons(app);
            app = createhouseoutline(app); % define house outline for animation
            
            switch app.TabGroup.SelectedTab.Title
                case 'Open-loop behaviour'
                    
                    app = createmodels(app); % define responses
                    app = openloopresponses(app); % collect responses with disturbances                    
                    app = animationoflineplots(app); % manage the animations


                case 'Open-loop modelling' % No disturbances so simple data
                    
                    app = createmodels(app); % define responses
                    app = timeconstantanalysis(app); % create figure to show T
                    app = animationoflineplots(app); % manage the animations
                     
                case 'Manual control' % User manually moves slide to select input
                   StartsimulationButtonPushed(app); % activate the bottom left button
                    
                case 'On-off control' % No disturbances so simple data
                  %  StartsimulationButtonPushed(app); % activate the bottom left button


                case 'PI control'
                   app = createmodels(app); % define models
                   app = closedloop_responses(app);
                   app = animationoflineplots(app); % manage the animations

                case 'Control with uncertainty' % No disturbances so simple data
                   StartButtonPushed(app); % activate the bottom left button
                    

            end

            enablebuttons(app);

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

        % Value changed function: WindspeedmsSlider
        function WindspeedmsSliderValueChanged(app, event)
            value = app.WindspeedmsSlider.Value;
            value = round(value,0);
            app.WindspeedmsSlider.Value=value;
            app = createhouseoutline(app);

        end

        % Value changed function: ThermalcapacityCMJdegSlider
        function ThermalcapacityCMJdegSliderValueChanged(app, event)
            value = app.ThermalcapacityCMJdegSlider.Value;
            value=round(value,0); 
            if value<1; value =1;end
            app.ThermalcapacityCMJdegSlider.Value=value;
            app = createhouseoutline(app);
        end

        % Value changed function: HeatlosskkWdegSlider
        function HeatlosskkWdegSliderValueChanged(app, event)
            value = app.HeatlosskkWdegSlider.Value;
            value=round(value,0);
            if value<1; value =1;end
            app.HeatlosskkWdegSlider.Value=value;
            app = createhouseoutline(app);
           
        end

        % Value changed function: ExternaltemperatureTedegSlider
        function ExternaltemperatureTedegSliderValueChanged(app, event)
            value = app.ExternaltemperatureTedegSlider.Value;
            value = round(value,0);
            app.ExternaltemperatureTedegSlider.Value=value;
            app = createhouseoutline(app);
            
        end

        % Value changed function: HeatsupplyWkWSlider
        function HeatsupplyWkWSliderValueChanged(app, event)
            value = app.HeatsupplyWkWSlider.Value;
            value = round(value,-1);
            app.HeatsupplyWkWSlider.Value=value;
            app = createhouseoutline(app);
            
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

        % Button pushed function: PausesimulationButton
        function PausesimulationButtonPushed(app, event)
            val = app.PausesimulationButton.Text;
            if strcmp(val,'Pause simulation');
                val = 'Continue simulation';
                app.pause = false;
            else
                % Stop simulation
                val = 'Pause simulation';
                app.pause=true;
            end
            app.PausesimulationButton.Text=val;
        end

        % Button pushed function: IncludechangesinwindButton
        function IncludechangesinwindButtonPushed(app, event)
            val = app.IncludechangesinwindButton.Text;
            if strcmp(val,'Include changes in wind');
                val = 'Using no wind';
                app.include_wind = 0;
            else
                % Stop simulation
                val = 'Include changes in wind';
                app.include_wind=1;
            end
            app.IncludechangesinwindButton.Text=val;
        end

        % Button pushed function: IncludechangesinTeButton
        function IncludechangesinTeButtonPushed(app, event)
            val = app.IncludechangesinTeButton.Text;
            if strcmp(val,'Include changes in Te');
                val = 'Using Te = 0';
                app.include_Te = 0;
            else
                % Stop simulation
                val = 'Include changes in Te';
                app.include_Te=1;
            end
            app.IncludechangesinTeButton.Text=val;
        end

        % Button pushed function: StartsimulationButton
        function StartsimulationButtonPushed(app, event)
            val = app.StartsimulationButton.Text;
            if strcmp(val,'Start simulation');
                val = 'End simulation';
                % Sub function to run the functions required in the manual
                % control tab
                app.StartsimulationButton.Text=val;
                app = manualcontrol(app);
            else
                % Stop simulation
                val = 'Start simulation';
                app.StartsimulationButton.Text=val;
            end
        end

        % Value changing function: SetheatingkWSlider
        function SetheatingkWSliderValueChanging(app, event)
            changingValue = event.Value;
            app.changingu=changingValue;
        end

        % Value changed function: ProportionalgainKpSlider
        function ProportionalgainKpSliderValueChanged(app, event)
            value = app.ProportionalgainKpSlider.Value;
            value = round(value,-2);
            app.ProportionalgainKpSlider.Value=value;
                        
        end

        % Value changed function: IntegralgainKiSlider
        function IntegralgainKiSliderValueChanged(app, event)
            value = app.IntegralgainKiSlider.Value;
            value = round(value,1);
            app.IntegralgainKiSlider.Value=value;
        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            val = app.StartButton.Text;
            if strcmp(val,'Start');
                val = 'End';
                % Sub function to run the functions required in the manual
                % control tab
                app.StartButton.Text=val;
                app = responseswithuncertainty(app);
            else
                % Stop simulation
                val = 'Start';
                app.StartButton.Text=val;
            end
        end

        % Button pushed function: 
        % IncludingchangesinexternaltemperatureButton
        function IncludingchangesinexternaltemperatureButtonPushed(app, event)
            val = app.IncludingchangesinexternaltemperatureButton.Text;
            if strcmp(val,'Including changes in external temperature');
                val = 'Using Te = 0';
                app.include_dist2 = 0;
            else
                
                val = 'Including changes in external temperature';
                app.include_dist2=1;
            end
            app.IncludingchangesinexternaltemperatureButton.Text=val;
        end

        % Button pushed function: IncludingwindeffectsButton
        function IncludingwindeffectsButtonPushed(app, event)
            val = app.IncludingwindeffectsButton.Text;
            if strcmp(val,'Including wind effects');
                val = 'Using no wind';
                app.include_blockage2 = 0;
            else
                
                val = 'Including wind effects';
                app.include_blockage2=1;
            end
            app.IncludingwindeffectsButton.Text=val;
        end

        % Button pushed function: IncludingmeasurementnoiseButton
        function IncludingmeasurementnoiseButtonPushed(app, event)
            val = app.IncludingmeasurementnoiseButton.Text;
            if strcmp(val,'Including measurement noise');
                val = 'Using no measurement noise';
                app.include_noise = 0;
            else
                
                val = 'Including measurement noise';
                app.include_noise=1;
            end
            app.IncludingmeasurementnoiseButton.Text=val;
        end

        % Button pushed function: IncludingmeasurementdelayButton
        function IncludingmeasurementdelayButtonPushed(app, event)
            val = app.IncludingmeasurementdelayButton.Text;
            if strcmp(val,'Including measurement delay');
                val = 'Using no measurement delay';
                app.include_delay = 0;
            else
                
                val = 'Including measurement delay';
                app.include_delay=1;
            end
            app.IncludingmeasurementdelayButton.Text=val;
        end

        % Button pushed function: UsingPIcontrolButton
        function UsingPIcontrolButtonPushed(app, event)
            val = app.UsingPIcontrolButton.Text;
            if strcmp(val,'Using PI control');
                val = 'Using on-off control';
                app.include_onoff = 0;
            else
                
                val = 'Using PI control';
                app.include_onoff=1;
            end
            app.UsingPIcontrolButton.Text=val;
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
            app.UIFigure.Position = [100 100 1285 832];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1.4x', '2x', '2x'};
            app.GridLayout.RowHeight = {'0.4x', '1x', '1.2x', '2x'};

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Animation of house temperature')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.XTick = [];
            app.UIAxes.XTickLabel = '';
            app.UIAxes.YTick = [];
            app.UIAxes.YTickLabel = '';
            app.UIAxes.Layout.Row = [2 3];
            app.UIAxes.Layout.Column = 2;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout);
            title(app.UIAxes2, 'Stored step responses')
            xlabel(app.UIAxes2, 'Time (hr)')
            ylabel(app.UIAxes2, 'Temperature (deg)')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 14;
            app.UIAxes2.Layout.Row = [2 3];
            app.UIAxes2.Layout.Column = 3;

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.GridLayout);
            title(app.UIAxes3, 'Inputs and disturbances')
            xlabel(app.UIAxes3, 'Time (hr)')
            ylabel(app.UIAxes3, 'Various')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.FontSize = 14;
            app.UIAxes3.Layout.Row = 4;
            app.UIAxes3.Layout.Column = 3;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = 2;
            app.GridLayout2.BackgroundColor = [0.6 1 1];

            % Create stordermodelforhousetemperatureLabel
            app.stordermodelforhousetemperatureLabel = uilabel(app.GridLayout2);
            app.stordermodelforhousetemperatureLabel.BackgroundColor = [0 1 1];
            app.stordermodelforhousetemperatureLabel.HorizontalAlignment = 'center';
            app.stordermodelforhousetemperatureLabel.FontSize = 24;
            app.stordermodelforhousetemperatureLabel.FontWeight = 'bold';
            app.stordermodelforhousetemperatureLabel.Layout.Row = 1;
            app.stordermodelforhousetemperatureLabel.Layout.Column = [1 2];
            app.stordermodelforhousetemperatureLabel.Text = '1st order model for house temperature';

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

            % Create RefreshButton
            app.RefreshButton = uibutton(app.GridLayout3, 'push');
            app.RefreshButton.ButtonPushedFcn = createCallbackFcn(app, @RefreshButtonPushed, true);
            app.RefreshButton.BackgroundColor = [1 0.2 0.702];
            app.RefreshButton.FontSize = 20;
            app.RefreshButton.FontWeight = 'bold';
            app.RefreshButton.Layout.Row = 1;
            app.RefreshButton.Layout.Column = 2;
            app.RefreshButton.Text = 'Refresh';

            % Create AnimationOnButton
            app.AnimationOnButton = uibutton(app.GridLayout3, 'push');
            app.AnimationOnButton.ButtonPushedFcn = createCallbackFcn(app, @AnimationOnButtonPushed, true);
            app.AnimationOnButton.WordWrap = 'on';
            app.AnimationOnButton.BackgroundColor = [1 0.2 0.702];
            app.AnimationOnButton.FontSize = 16;
            app.AnimationOnButton.FontWeight = 'bold';
            app.AnimationOnButton.Layout.Row = 1;
            app.AnimationOnButton.Layout.Column = 3;
            app.AnimationOnButton.Text = 'Animation On';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout4.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout4.Layout.Row = 2;
            app.GridLayout4.Layout.Column = 1;
            app.GridLayout4.BackgroundColor = [0.902 1 0.502];

            % Create HeatlosskkWdegSliderLabel
            app.HeatlosskkWdegSliderLabel = uilabel(app.GridLayout4);
            app.HeatlosskkWdegSliderLabel.HorizontalAlignment = 'right';
            app.HeatlosskkWdegSliderLabel.FontSize = 14;
            app.HeatlosskkWdegSliderLabel.Layout.Row = 2;
            app.HeatlosskkWdegSliderLabel.Layout.Column = 1;
            app.HeatlosskkWdegSliderLabel.Text = {'Heat loss'; 'k (kW/deg)'};

            % Create HeatlosskkWdegSlider
            app.HeatlosskkWdegSlider = uislider(app.GridLayout4);
            app.HeatlosskkWdegSlider.Limits = [0 10];
            app.HeatlosskkWdegSlider.ValueChangedFcn = createCallbackFcn(app, @HeatlosskkWdegSliderValueChanged, true);
            app.HeatlosskkWdegSlider.MinorTicks = [500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000];
            app.HeatlosskkWdegSlider.FontSize = 14;
            app.HeatlosskkWdegSlider.Layout.Row = 2;
            app.HeatlosskkWdegSlider.Layout.Column = 2;
            app.HeatlosskkWdegSlider.Value = 4;

            % Create ThermalcapacityCMJdegSliderLabel
            app.ThermalcapacityCMJdegSliderLabel = uilabel(app.GridLayout4);
            app.ThermalcapacityCMJdegSliderLabel.HorizontalAlignment = 'right';
            app.ThermalcapacityCMJdegSliderLabel.FontSize = 14;
            app.ThermalcapacityCMJdegSliderLabel.Layout.Row = 3;
            app.ThermalcapacityCMJdegSliderLabel.Layout.Column = 1;
            app.ThermalcapacityCMJdegSliderLabel.Text = {'Thermal capacity'; 'C (MJ/deg)'};

            % Create ThermalcapacityCMJdegSlider
            app.ThermalcapacityCMJdegSlider = uislider(app.GridLayout4);
            app.ThermalcapacityCMJdegSlider.Limits = [0 10];
            app.ThermalcapacityCMJdegSlider.ValueChangedFcn = createCallbackFcn(app, @ThermalcapacityCMJdegSliderValueChanged, true);
            app.ThermalcapacityCMJdegSlider.MinorTicks = [0 100 200 300 400 500 600 700 800 900 1000];
            app.ThermalcapacityCMJdegSlider.FontSize = 14;
            app.ThermalcapacityCMJdegSlider.Layout.Row = 3;
            app.ThermalcapacityCMJdegSlider.Layout.Column = 2;
            app.ThermalcapacityCMJdegSlider.Value = 6;

            % Create HouseparametersCdTdtkTTeWLabel
            app.HouseparametersCdTdtkTTeWLabel = uilabel(app.GridLayout4);
            app.HouseparametersCdTdtkTTeWLabel.BackgroundColor = [1 1 0];
            app.HouseparametersCdTdtkTTeWLabel.HorizontalAlignment = 'center';
            app.HouseparametersCdTdtkTTeWLabel.FontSize = 16;
            app.HouseparametersCdTdtkTTeWLabel.FontWeight = 'bold';
            app.HouseparametersCdTdtkTTeWLabel.Layout.Row = 1;
            app.HouseparametersCdTdtkTTeWLabel.Layout.Column = [1 2];
            app.HouseparametersCdTdtkTTeWLabel.Text = 'House parameters: C(dT/dt) + k(T-Te) = W';

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout6.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout6.Layout.Row = 3;
            app.GridLayout6.Layout.Column = 1;
            app.GridLayout6.BackgroundColor = [0.702 1 0.702];

            % Create EnvironmentparametersLabel
            app.EnvironmentparametersLabel = uilabel(app.GridLayout6);
            app.EnvironmentparametersLabel.BackgroundColor = [0 1 0];
            app.EnvironmentparametersLabel.HorizontalAlignment = 'center';
            app.EnvironmentparametersLabel.FontSize = 16;
            app.EnvironmentparametersLabel.FontWeight = 'bold';
            app.EnvironmentparametersLabel.Layout.Row = 1;
            app.EnvironmentparametersLabel.Layout.Column = [1 2];
            app.EnvironmentparametersLabel.Text = 'Environment parameters';

            % Create HeatsupplyWkWSliderLabel
            app.HeatsupplyWkWSliderLabel = uilabel(app.GridLayout6);
            app.HeatsupplyWkWSliderLabel.HorizontalAlignment = 'right';
            app.HeatsupplyWkWSliderLabel.FontSize = 14;
            app.HeatsupplyWkWSliderLabel.Layout.Row = 2;
            app.HeatsupplyWkWSliderLabel.Layout.Column = 1;
            app.HeatsupplyWkWSliderLabel.Text = {'Heat supply '; 'W (kW)'};

            % Create HeatsupplyWkWSlider
            app.HeatsupplyWkWSlider = uislider(app.GridLayout6);
            app.HeatsupplyWkWSlider.ValueChangedFcn = createCallbackFcn(app, @HeatsupplyWkWSliderValueChanged, true);
            app.HeatsupplyWkWSlider.FontSize = 14;
            app.HeatsupplyWkWSlider.Layout.Row = 2;
            app.HeatsupplyWkWSlider.Layout.Column = 2;
            app.HeatsupplyWkWSlider.Value = 40;

            % Create ExternaltemperatureTedegSliderLabel
            app.ExternaltemperatureTedegSliderLabel = uilabel(app.GridLayout6);
            app.ExternaltemperatureTedegSliderLabel.HorizontalAlignment = 'right';
            app.ExternaltemperatureTedegSliderLabel.FontSize = 13;
            app.ExternaltemperatureTedegSliderLabel.Layout.Row = 3;
            app.ExternaltemperatureTedegSliderLabel.Layout.Column = 1;
            app.ExternaltemperatureTedegSliderLabel.Text = {'External temperature '; 'Te (deg)'};

            % Create ExternaltemperatureTedegSlider
            app.ExternaltemperatureTedegSlider = uislider(app.GridLayout6);
            app.ExternaltemperatureTedegSlider.Limits = [-10 20];
            app.ExternaltemperatureTedegSlider.ValueChangedFcn = createCallbackFcn(app, @ExternaltemperatureTedegSliderValueChanged, true);
            app.ExternaltemperatureTedegSlider.FontSize = 13;
            app.ExternaltemperatureTedegSlider.Layout.Row = 3;
            app.ExternaltemperatureTedegSlider.Layout.Column = 2;

            % Create WindspeedmsSliderLabel
            app.WindspeedmsSliderLabel = uilabel(app.GridLayout6);
            app.WindspeedmsSliderLabel.HorizontalAlignment = 'right';
            app.WindspeedmsSliderLabel.FontSize = 13;
            app.WindspeedmsSliderLabel.Layout.Row = 4;
            app.WindspeedmsSliderLabel.Layout.Column = 1;
            app.WindspeedmsSliderLabel.Text = 'Wind speed (m/s)';

            % Create WindspeedmsSlider
            app.WindspeedmsSlider = uislider(app.GridLayout6);
            app.WindspeedmsSlider.Limits = [0 40];
            app.WindspeedmsSlider.ValueChangedFcn = createCallbackFcn(app, @WindspeedmsSliderValueChanged, true);
            app.WindspeedmsSlider.FontSize = 13;
            app.WindspeedmsSlider.Layout.Row = 4;
            app.WindspeedmsSlider.Layout.Column = 2;

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.Layout.Row = 4;
            app.TabGroup.Layout.Column = [1 2];

            % Create OpenloopbehaviourTab
            app.OpenloopbehaviourTab = uitab(app.TabGroup);
            app.OpenloopbehaviourTab.Title = 'Open-loop behaviour';

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.OpenloopbehaviourTab);
            app.GridLayout7.ColumnWidth = {'1.4x', '2x', '2x'};
            app.GridLayout7.RowHeight = {'1x', '1x', '1x'};

            % Create Label
            app.Label = uilabel(app.GridLayout7);
            app.Label.BackgroundColor = [0 1 1];
            app.Label.WordWrap = 'on';
            app.Label.FontSize = 18;
            app.Label.FontWeight = 'bold';
            app.Label.Layout.Row = 1;
            app.Label.Layout.Column = [1 2];
            app.Label.Text = 'Explore how house temperature depends on heating and the environment parameters. ';

            % Create REMARKSLabel
            app.REMARKSLabel = uilabel(app.GridLayout7);
            app.REMARKSLabel.BackgroundColor = [0.902 0.702 1];
            app.REMARKSLabel.FontSize = 18;
            app.REMARKSLabel.FontWeight = 'bold';
            app.REMARKSLabel.Layout.Row = 1;
            app.REMARKSLabel.Layout.Column = 3;
            app.REMARKSLabel.Text = 'REMARKS';

            % Create Label3
            app.Label3 = uilabel(app.GridLayout7);
            app.Label3.BackgroundColor = [0.902 0.702 1];
            app.Label3.WordWrap = 'on';
            app.Label3.FontSize = 18;
            app.Label3.Layout.Row = 2;
            app.Label3.Layout.Column = 3;
            app.Label3.Text = 'The time scale changes to be about 4 time constants (P) for the most recent scenario.';

            % Create StrongwindincreasestheheatlossLabel
            app.StrongwindincreasestheheatlossLabel = uilabel(app.GridLayout7);
            app.StrongwindincreasestheheatlossLabel.BackgroundColor = [0.902 0.702 1];
            app.StrongwindincreasestheheatlossLabel.WordWrap = 'on';
            app.StrongwindincreasestheheatlossLabel.FontSize = 18;
            app.StrongwindincreasestheheatlossLabel.Layout.Row = 3;
            app.StrongwindincreasestheheatlossLabel.Layout.Column = 3;
            app.StrongwindincreasestheheatlossLabel.Text = 'Strong wind increases the heat loss.';

            % Create ExternaltemperatureDropDownLabel
            app.ExternaltemperatureDropDownLabel = uilabel(app.GridLayout7);
            app.ExternaltemperatureDropDownLabel.BackgroundColor = [0.702 1 0.702];
            app.ExternaltemperatureDropDownLabel.HorizontalAlignment = 'right';
            app.ExternaltemperatureDropDownLabel.FontSize = 18;
            app.ExternaltemperatureDropDownLabel.Layout.Row = 2;
            app.ExternaltemperatureDropDownLabel.Layout.Column = 1;
            app.ExternaltemperatureDropDownLabel.Text = 'External temperature';

            % Create ExternaltemperatureDropDown
            app.ExternaltemperatureDropDown = uidropdown(app.GridLayout7);
            app.ExternaltemperatureDropDown.Items = {'Change at t=0', 'Change mid-simulation'};
            app.ExternaltemperatureDropDown.FontSize = 18;
            app.ExternaltemperatureDropDown.BackgroundColor = [0.702 1 0.702];
            app.ExternaltemperatureDropDown.Layout.Row = 2;
            app.ExternaltemperatureDropDown.Layout.Column = 2;
            app.ExternaltemperatureDropDown.Value = 'Change at t=0';

            % Create WindspeedDropDownLabel
            app.WindspeedDropDownLabel = uilabel(app.GridLayout7);
            app.WindspeedDropDownLabel.BackgroundColor = [0.702 1 0.702];
            app.WindspeedDropDownLabel.HorizontalAlignment = 'right';
            app.WindspeedDropDownLabel.FontSize = 18;
            app.WindspeedDropDownLabel.Layout.Row = 3;
            app.WindspeedDropDownLabel.Layout.Column = 1;
            app.WindspeedDropDownLabel.Text = 'Wind speed';

            % Create WindspeedDropDown
            app.WindspeedDropDown = uidropdown(app.GridLayout7);
            app.WindspeedDropDown.Items = {'Change at t=0', 'Change mid-simulation'};
            app.WindspeedDropDown.FontSize = 18;
            app.WindspeedDropDown.BackgroundColor = [0.702 1 0.702];
            app.WindspeedDropDown.Layout.Row = 3;
            app.WindspeedDropDown.Layout.Column = 2;
            app.WindspeedDropDown.Value = 'Change at t=0';

            % Create OpenloopmodellingTab
            app.OpenloopmodellingTab = uitab(app.TabGroup);
            app.OpenloopmodellingTab.Title = 'Open-loop modelling';

            % Create GridLayout8
            app.GridLayout8 = uigridlayout(app.OpenloopmodellingTab);
            app.GridLayout8.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout8.RowHeight = {'1x', '1x', '1x', '1x', '1x'};

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.GridLayout8);
            title(app.UIAxes4, 'Modelling of time constant and gain for current system')
            xlabel(app.UIAxes4, 'Time (hr)')
            ylabel(app.UIAxes4, 'Temperature')
            zlabel(app.UIAxes4, 'Z')
            app.UIAxes4.Layout.Row = [2 5];
            app.UIAxes4.Layout.Column = [2 3];

            % Create Label_2
            app.Label_2 = uilabel(app.GridLayout8);
            app.Label_2.BackgroundColor = [0 1 1];
            app.Label_2.WordWrap = 'on';
            app.Label_2.FontSize = 18;
            app.Label_2.FontWeight = 'bold';
            app.Label_2.Layout.Row = 1;
            app.Label_2.Layout.Column = [1 3];
            app.Label_2.Text = 'This tab does open loop step tests with Te = 0 and no wind. Use to determine time constant ''P'' and gain ''K'' of the model:    P(dT/dt) + T = K W';

            % Create TimeconstanthrPCkLabel
            app.TimeconstanthrPCkLabel = uilabel(app.GridLayout8);
            app.TimeconstanthrPCkLabel.BackgroundColor = [1 0.6 0.8];
            app.TimeconstanthrPCkLabel.HorizontalAlignment = 'center';
            app.TimeconstanthrPCkLabel.WordWrap = 'on';
            app.TimeconstanthrPCkLabel.FontSize = 18;
            app.TimeconstanthrPCkLabel.Layout.Row = 2;
            app.TimeconstanthrPCkLabel.Layout.Column = 1;
            app.TimeconstanthrPCkLabel.Text = {'Time constant (hr) '; '(P=C/k)'};

            % Create GainperkWK1kLabel
            app.GainperkWK1kLabel = uilabel(app.GridLayout8);
            app.GainperkWK1kLabel.BackgroundColor = [1 0.6 0.8];
            app.GainperkWK1kLabel.HorizontalAlignment = 'center';
            app.GainperkWK1kLabel.WordWrap = 'on';
            app.GainperkWK1kLabel.FontSize = 18;
            app.GainperkWK1kLabel.Layout.Row = 4;
            app.GainperkWK1kLabel.Layout.Column = 1;
            app.GainperkWK1kLabel.Text = {'Gain (per kW) '; ' (K=1/k)'};

            % Create EditField
            app.EditField = uieditfield(app.GridLayout8, 'numeric');
            app.EditField.HorizontalAlignment = 'center';
            app.EditField.FontSize = 18;
            app.EditField.Layout.Row = 3;
            app.EditField.Layout.Column = 1;

            % Create EditField_2
            app.EditField_2 = uieditfield(app.GridLayout8, 'numeric');
            app.EditField_2.HorizontalAlignment = 'center';
            app.EditField_2.FontSize = 18;
            app.EditField_2.Layout.Row = 5;
            app.EditField_2.Layout.Column = 1;

            % Create ManualcontrolTab
            app.ManualcontrolTab = uitab(app.TabGroup);
            app.ManualcontrolTab.Title = 'Manual control';

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.ManualcontrolTab);
            app.GridLayout9.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.GridLayout9.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout9.BackgroundColor = [1 0.8 0.6];

            % Create Label_3
            app.Label_3 = uilabel(app.GridLayout9);
            app.Label_3.BackgroundColor = [0 1 1];
            app.Label_3.HorizontalAlignment = 'center';
            app.Label_3.WordWrap = 'on';
            app.Label_3.FontSize = 18;
            app.Label_3.FontWeight = 'bold';
            app.Label_3.Layout.Row = 1;
            app.Label_3.Layout.Column = [1 4];
            app.Label_3.Text = 'Move the slider below to change the heating and try to maintain the desired temperature.';

            % Create Label2
            app.Label2 = uilabel(app.GridLayout9);
            app.Label2.BackgroundColor = [0.6 1 1];
            app.Label2.WordWrap = 'on';
            app.Label2.FontSize = 14;
            app.Label2.Layout.Row = 2;
            app.Label2.Layout.Column = [1 2];
            app.Label2.Text = 'The system will be subject to random external temperature and wind. Set sliders above before you begin simulation.';

            % Create Label3_2
            app.Label3_2 = uilabel(app.GridLayout9);
            app.Label3_2.BackgroundColor = [0.6 1 1];
            app.Label3_2.WordWrap = 'on';
            app.Label3_2.FontSize = 14;
            app.Label3_2.Layout.Row = 2;
            app.Label3_2.Layout.Column = [3 4];
            app.Label3_2.Text = 'This simulation is continuous (up to a time limit). Use the buttons below to stop, pause and change the settings.';

            % Create SetheatingkWSliderLabel
            app.SetheatingkWSliderLabel = uilabel(app.GridLayout9);
            app.SetheatingkWSliderLabel.HorizontalAlignment = 'right';
            app.SetheatingkWSliderLabel.FontSize = 18;
            app.SetheatingkWSliderLabel.Layout.Row = 3;
            app.SetheatingkWSliderLabel.Layout.Column = 1;
            app.SetheatingkWSliderLabel.Text = 'Set heating (kW)';

            % Create SetheatingkWSlider
            app.SetheatingkWSlider = uislider(app.GridLayout9);
            app.SetheatingkWSlider.ValueChangingFcn = createCallbackFcn(app, @SetheatingkWSliderValueChanging, true);
            app.SetheatingkWSlider.Layout.Row = 3;
            app.SetheatingkWSlider.Layout.Column = [2 4];

            % Create StartsimulationButton
            app.StartsimulationButton = uibutton(app.GridLayout9, 'push');
            app.StartsimulationButton.ButtonPushedFcn = createCallbackFcn(app, @StartsimulationButtonPushed, true);
            app.StartsimulationButton.WordWrap = 'on';
            app.StartsimulationButton.BackgroundColor = [1 0.2 0.702];
            app.StartsimulationButton.FontSize = 18;
            app.StartsimulationButton.Layout.Row = 4;
            app.StartsimulationButton.Layout.Column = 1;
            app.StartsimulationButton.Text = 'Start simulation';

            % Create IncludechangesinTeButton
            app.IncludechangesinTeButton = uibutton(app.GridLayout9, 'push');
            app.IncludechangesinTeButton.ButtonPushedFcn = createCallbackFcn(app, @IncludechangesinTeButtonPushed, true);
            app.IncludechangesinTeButton.WordWrap = 'on';
            app.IncludechangesinTeButton.BackgroundColor = [1 0.2 0.702];
            app.IncludechangesinTeButton.FontSize = 18;
            app.IncludechangesinTeButton.Layout.Row = 4;
            app.IncludechangesinTeButton.Layout.Column = 2;
            app.IncludechangesinTeButton.Text = 'Include changes in Te';

            % Create IncludechangesinwindButton
            app.IncludechangesinwindButton = uibutton(app.GridLayout9, 'push');
            app.IncludechangesinwindButton.ButtonPushedFcn = createCallbackFcn(app, @IncludechangesinwindButtonPushed, true);
            app.IncludechangesinwindButton.WordWrap = 'on';
            app.IncludechangesinwindButton.BackgroundColor = [1 0.2 0.702];
            app.IncludechangesinwindButton.FontSize = 18;
            app.IncludechangesinwindButton.Layout.Row = 4;
            app.IncludechangesinwindButton.Layout.Column = 3;
            app.IncludechangesinwindButton.Text = 'Include changes in wind';

            % Create PausesimulationButton
            app.PausesimulationButton = uibutton(app.GridLayout9, 'push');
            app.PausesimulationButton.ButtonPushedFcn = createCallbackFcn(app, @PausesimulationButtonPushed, true);
            app.PausesimulationButton.WordWrap = 'on';
            app.PausesimulationButton.BackgroundColor = [1 0.2 0.702];
            app.PausesimulationButton.FontSize = 18;
            app.PausesimulationButton.Layout.Row = 4;
            app.PausesimulationButton.Layout.Column = 4;
            app.PausesimulationButton.Text = 'Pause simulation';

            % Create PIcontrolTab
            app.PIcontrolTab = uitab(app.TabGroup);
            app.PIcontrolTab.Title = 'PI control';

            % Create GridLayout10
            app.GridLayout10 = uigridlayout(app.PIcontrolTab);
            app.GridLayout10.ColumnWidth = {'1x', '2x', '1x'};
            app.GridLayout10.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout10.BackgroundColor = [1 0.8 0.6];

            % Create ControlparametersLabel
            app.ControlparametersLabel = uilabel(app.GridLayout10);
            app.ControlparametersLabel.BackgroundColor = [1 0.5098 0.302];
            app.ControlparametersLabel.HorizontalAlignment = 'center';
            app.ControlparametersLabel.FontSize = 24;
            app.ControlparametersLabel.FontWeight = 'bold';
            app.ControlparametersLabel.Layout.Row = 1;
            app.ControlparametersLabel.Layout.Column = [1 2];
            app.ControlparametersLabel.Text = 'Control parameters';

            % Create REMARKSLabel_2
            app.REMARKSLabel_2 = uilabel(app.GridLayout10);
            app.REMARKSLabel_2.BackgroundColor = [0.902 0.702 1];
            app.REMARKSLabel_2.HorizontalAlignment = 'center';
            app.REMARKSLabel_2.FontSize = 18;
            app.REMARKSLabel_2.FontWeight = 'bold';
            app.REMARKSLabel_2.Layout.Row = 1;
            app.REMARKSLabel_2.Layout.Column = 3;
            app.REMARKSLabel_2.Text = 'REMARKS';

            % Create Label2_2
            app.Label2_2 = uilabel(app.GridLayout10);
            app.Label2_2.BackgroundColor = [0.902 0.702 1];
            app.Label2_2.HorizontalAlignment = 'center';
            app.Label2_2.WordWrap = 'on';
            app.Label2_2.FontSize = 18;
            app.Label2_2.Layout.Row = 2;
            app.Label2_2.Layout.Column = 3;
            app.Label2_2.Text = 'Use the 2nd tab on modelling to estimate the model, and hence choose the Kp, Ki values systematically.';

            % Create OnthistabblockagesanddisturbancesareconstantforsimplicityLabel
            app.OnthistabblockagesanddisturbancesareconstantforsimplicityLabel = uilabel(app.GridLayout10);
            app.OnthistabblockagesanddisturbancesareconstantforsimplicityLabel.BackgroundColor = [0.902 0.702 1];
            app.OnthistabblockagesanddisturbancesareconstantforsimplicityLabel.HorizontalAlignment = 'center';
            app.OnthistabblockagesanddisturbancesareconstantforsimplicityLabel.WordWrap = 'on';
            app.OnthistabblockagesanddisturbancesareconstantforsimplicityLabel.FontSize = 18;
            app.OnthistabblockagesanddisturbancesareconstantforsimplicityLabel.Layout.Row = 3;
            app.OnthistabblockagesanddisturbancesareconstantforsimplicityLabel.Layout.Column = 3;
            app.OnthistabblockagesanddisturbancesareconstantforsimplicityLabel.Text = 'On this tab, wind and external temperature are constant for simplicity.';

            % Create ProportionalgainKpSliderLabel
            app.ProportionalgainKpSliderLabel = uilabel(app.GridLayout10);
            app.ProportionalgainKpSliderLabel.HorizontalAlignment = 'right';
            app.ProportionalgainKpSliderLabel.FontSize = 18;
            app.ProportionalgainKpSliderLabel.Layout.Row = 2;
            app.ProportionalgainKpSliderLabel.Layout.Column = 1;
            app.ProportionalgainKpSliderLabel.Text = 'Proportional gain (Kp)';

            % Create ProportionalgainKpSlider
            app.ProportionalgainKpSlider = uislider(app.GridLayout10);
            app.ProportionalgainKpSlider.Limits = [0 10000];
            app.ProportionalgainKpSlider.ValueChangedFcn = createCallbackFcn(app, @ProportionalgainKpSliderValueChanged, true);
            app.ProportionalgainKpSlider.Layout.Row = 2;
            app.ProportionalgainKpSlider.Layout.Column = 2;
            app.ProportionalgainKpSlider.Value = 4000;

            % Create IntegralgainKiSliderLabel
            app.IntegralgainKiSliderLabel = uilabel(app.GridLayout10);
            app.IntegralgainKiSliderLabel.HorizontalAlignment = 'right';
            app.IntegralgainKiSliderLabel.FontSize = 18;
            app.IntegralgainKiSliderLabel.Layout.Row = 3;
            app.IntegralgainKiSliderLabel.Layout.Column = 1;
            app.IntegralgainKiSliderLabel.Text = 'Integral gain (Ki)';

            % Create IntegralgainKiSlider
            app.IntegralgainKiSlider = uislider(app.GridLayout10);
            app.IntegralgainKiSlider.Limits = [0 10];
            app.IntegralgainKiSlider.ValueChangedFcn = createCallbackFcn(app, @IntegralgainKiSliderValueChanged, true);
            app.IntegralgainKiSlider.Layout.Row = 3;
            app.IntegralgainKiSlider.Layout.Column = 2;
            app.IntegralgainKiSlider.Value = 2;

            % Create ControlwithuncertaintyTab
            app.ControlwithuncertaintyTab = uitab(app.TabGroup);
            app.ControlwithuncertaintyTab.Title = 'Control with uncertainty';

            % Create GridLayout11
            app.GridLayout11 = uigridlayout(app.ControlwithuncertaintyTab);
            app.GridLayout11.ColumnWidth = {'1x', '1x', '1.2x'};
            app.GridLayout11.RowHeight = {'1.4x', '1x', '1x', '1.2x'};

            % Create Label_4
            app.Label_4 = uilabel(app.GridLayout11);
            app.Label_4.BackgroundColor = [0 1 1];
            app.Label_4.HorizontalAlignment = 'center';
            app.Label_4.WordWrap = 'on';
            app.Label_4.FontSize = 18;
            app.Label_4.FontWeight = 'bold';
            app.Label_4.Layout.Row = 1;
            app.Label_4.Layout.Column = [1 2];
            app.Label_4.Text = 'Real world scenarios have multiple forms of uncertainty. This tab allows you to explore their impact on effective control of temperature.';

            % Create Label_5
            app.Label_5 = uilabel(app.GridLayout11);
            app.Label_5.BackgroundColor = [0.902 0.702 1];
            app.Label_5.HorizontalAlignment = 'center';
            app.Label_5.WordWrap = 'on';
            app.Label_5.FontSize = 18;
            app.Label_5.FontWeight = 'bold';
            app.Label_5.Layout.Row = 1;
            app.Label_5.Layout.Column = 3;
            app.Label_5.Text = 'REMARKS';

            % Create Label_6
            app.Label_6 = uilabel(app.GridLayout11);
            app.Label_6.BackgroundColor = [0.902 0.702 1];
            app.Label_6.WordWrap = 'on';
            app.Label_6.FontSize = 14;
            app.Label_6.Layout.Row = 2;
            app.Label_6.Layout.Column = 3;
            app.Label_6.Text = 'The buttons allow you to dynamically include or exclude different sources of uncertainty.';

            % Create Label_7
            app.Label_7 = uilabel(app.GridLayout11);
            app.Label_7.BackgroundColor = [0.902 0.702 1];
            app.Label_7.HorizontalAlignment = 'center';
            app.Label_7.WordWrap = 'on';
            app.Label_7.FontSize = 14;
            app.Label_7.Layout.Row = 3;
            app.Label_7.Layout.Column = 3;
            app.Label_7.Text = 'The PI parameters are taken from the previous tab and fixed throughout the simulation.';

            % Create Label_8
            app.Label_8 = uilabel(app.GridLayout11);
            app.Label_8.BackgroundColor = [0.902 0.702 1];
            app.Label_8.WordWrap = 'on';
            app.Label_8.FontSize = 14;
            app.Label_8.Layout.Row = 4;
            app.Label_8.Layout.Column = 3;
            app.Label_8.Text = 'The simulation is continuous until you select stop. Ignores the magnitude of the disturbances in sliders above as randomised throughout.';

            % Create StartButton
            app.StartButton = uibutton(app.GridLayout11, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.BackgroundColor = [1 0.2 0.702];
            app.StartButton.FontSize = 24;
            app.StartButton.Layout.Row = 2;
            app.StartButton.Layout.Column = 1;
            app.StartButton.Text = 'Start';

            % Create IncludingmeasurementnoiseButton
            app.IncludingmeasurementnoiseButton = uibutton(app.GridLayout11, 'push');
            app.IncludingmeasurementnoiseButton.ButtonPushedFcn = createCallbackFcn(app, @IncludingmeasurementnoiseButtonPushed, true);
            app.IncludingmeasurementnoiseButton.WordWrap = 'on';
            app.IncludingmeasurementnoiseButton.BackgroundColor = [1 0.2 0.702];
            app.IncludingmeasurementnoiseButton.FontSize = 18;
            app.IncludingmeasurementnoiseButton.Layout.Row = 2;
            app.IncludingmeasurementnoiseButton.Layout.Column = 2;
            app.IncludingmeasurementnoiseButton.Text = 'Including measurement noise';

            % Create IncludingmeasurementdelayButton
            app.IncludingmeasurementdelayButton = uibutton(app.GridLayout11, 'push');
            app.IncludingmeasurementdelayButton.ButtonPushedFcn = createCallbackFcn(app, @IncludingmeasurementdelayButtonPushed, true);
            app.IncludingmeasurementdelayButton.WordWrap = 'on';
            app.IncludingmeasurementdelayButton.BackgroundColor = [1 0.2 0.702];
            app.IncludingmeasurementdelayButton.FontSize = 18;
            app.IncludingmeasurementdelayButton.Layout.Row = 3;
            app.IncludingmeasurementdelayButton.Layout.Column = 2;
            app.IncludingmeasurementdelayButton.Text = 'Including measurement delay';

            % Create IncludingwindeffectsButton
            app.IncludingwindeffectsButton = uibutton(app.GridLayout11, 'push');
            app.IncludingwindeffectsButton.ButtonPushedFcn = createCallbackFcn(app, @IncludingwindeffectsButtonPushed, true);
            app.IncludingwindeffectsButton.WordWrap = 'on';
            app.IncludingwindeffectsButton.BackgroundColor = [1 0.2 0.702];
            app.IncludingwindeffectsButton.FontSize = 18;
            app.IncludingwindeffectsButton.Layout.Row = 4;
            app.IncludingwindeffectsButton.Layout.Column = 1;
            app.IncludingwindeffectsButton.Text = 'Including wind effects';

            % Create IncludingchangesinexternaltemperatureButton
            app.IncludingchangesinexternaltemperatureButton = uibutton(app.GridLayout11, 'push');
            app.IncludingchangesinexternaltemperatureButton.ButtonPushedFcn = createCallbackFcn(app, @IncludingchangesinexternaltemperatureButtonPushed, true);
            app.IncludingchangesinexternaltemperatureButton.WordWrap = 'on';
            app.IncludingchangesinexternaltemperatureButton.BackgroundColor = [1 0.2 0.702];
            app.IncludingchangesinexternaltemperatureButton.FontSize = 18;
            app.IncludingchangesinexternaltemperatureButton.Layout.Row = 4;
            app.IncludingchangesinexternaltemperatureButton.Layout.Column = 2;
            app.IncludingchangesinexternaltemperatureButton.Text = 'Including changes in external temperature';

            % Create UsingPIcontrolButton
            app.UsingPIcontrolButton = uibutton(app.GridLayout11, 'push');
            app.UsingPIcontrolButton.ButtonPushedFcn = createCallbackFcn(app, @UsingPIcontrolButtonPushed, true);
            app.UsingPIcontrolButton.WordWrap = 'on';
            app.UsingPIcontrolButton.BackgroundColor = [1 0.2 0.702];
            app.UsingPIcontrolButton.FontSize = 18;
            app.UsingPIcontrolButton.Layout.Row = 3;
            app.UsingPIcontrolButton.Layout.Column = 1;
            app.UsingPIcontrolButton.Text = 'Using PI control';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = housetemperature_story

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

