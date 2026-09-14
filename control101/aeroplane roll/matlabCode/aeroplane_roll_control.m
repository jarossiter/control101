classdef aeroplane_roll_control < matlab.apps.AppBase
    %AEROPLANE_ROLL_CONTROL
    %   File written by J.A.Rossiter, University of Sheffield  
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   
    %   A simple interface to practice behaviour of a simple car model
    %   subject to changes in mass, friction, enging power road slope
    %   and wind 
    %   Some notes and engineering background are in the partner
    %   livescript file:    carmodel_and_behaviour_manual.mlx
    %   A group of similar files can be downloaded through MATLAB
    %   add-ons with the toolbox name:  control101
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
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        GridLayout4                    matlab.ui.container.GridLayout
        DefaultMsEditField             matlab.ui.control.EditField
        DefaultMsEditFieldLabel        matlab.ui.control.Label
        AeroplaneparametersGsAs2saLabel  matlab.ui.control.Label
        ParameteraSlider               matlab.ui.control.Slider
        ParameteraSliderLabel          matlab.ui.control.Label
        ParameterCSlider               matlab.ui.control.Slider
        MassMkgLabel                   matlab.ui.control.Label
        GridLayout6                    matlab.ui.container.GridLayout
        PoletozeroratioSlider          matlab.ui.control.Slider
        LeadfrequencywLabel            matlab.ui.control.Label
        LeadfrequencywSlider           matlab.ui.control.Slider
        LeadfrequencywSliderLabel      matlab.ui.control.Label
        LeadgainKSlider                matlab.ui.control.Slider
        LeadgainKSliderLabel           matlab.ui.control.Label
        LeadcompensatorMsKswbswbLabel  matlab.ui.control.Label
        DetailedanalysisoffirstordermodelparametersPanel  matlab.ui.container.Panel
        GridLayout5                    matlab.ui.container.GridLayout
        UIAxes2                        matlab.ui.control.UIAxes
        UIAxes3                        matlab.ui.control.UIAxes
        GridLayout3                    matlab.ui.container.GridLayout
        AnimationOnButton              matlab.ui.control.Button
        RefreshButton                  matlab.ui.control.Button
        SimulateButton                 matlab.ui.control.Button
        GridLayout2                    matlab.ui.container.GridLayout
        Image                          matlab.ui.control.Image
        LeadcontrolofaeroplanerollLabel  matlab.ui.control.Label
        UIAxes_2                       matlab.ui.control.UIAxes
        UIAxes                         matlab.ui.control.UIAxes
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
        G;   % system transfer function (input to output)
        M;   % compensator
        pole % compensator pole
        zero % compensator zero
        pm   % current phase margin
        wc   % cross over freq.
        aero;  % handle for the aeroplane figure
        xx;   % handles for the aeroplane
        yy;  % 
        runtime = 300; % for simulation the runtime
        time;  % variable to store time instants for simulation plots
        samples = 201;
        animationtime = 8; % how long animation will take
        Tsamp=0.1;  % update rate for animation
        ytotal; % angle response
        
        
    end
    
    methods (Access = private)
        


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  PLOT OF TOP FIGURE - THE AEROPLANE ANIMATION
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function app = createplaneoutline(app)
            %%% Define aeroplane outline
        hold(app.UIAxes3,'off')
        
        theta=-2*pi/3:.02:-pi/3;
        xbody=cos(theta)*2; ybody=sin(theta)+0.84;
        theta2=0.2:.02:pi/2;    %%%pi-0.2;
        xbody2=cos(theta2);
        ybody2=0.4*sin(theta2)-0.08;
        xwing=[3,3.05,3.1,3.05,3]+1;
        ywing=linspace(ybody(end),ybody2(1),5);
        xtail=[0.05,-0.05]; ytail=[0.4,0.4];
        viewx = [0,-0.2,-0.4,0.4,0.2,0];
        viewy = [0.25,0.22,0.15, 0.15,0.22,0.25];
        tailpx=[-xbody2(1),-xbody2(1),-2,-2,-xbody2(2),-xbody2(2)];
        tailpy=[ywing(end),0.04,0.04,0.06,0.06,ywing(end)];
        xx=[xbody,xwing,-(tailpx),xbody2,xtail,viewx,-fliplr(xbody2),tailpx,-fliplr(xwing),xbody(1)];
        yy=[ybody,ywing,tailpy,ybody2,ytail,viewy,fliplr(ybody2),tailpy,fliplr(ywing),ybody(1)];
        xx=xx/max(xx);
        yy=yy/max(yy);
        app.xx=xx;
        app.yy=yy;
        app.aero=fill(app.UIAxes3,xx,yy,'r','linewidth',2);
        hold(app.UIAxes3,'on')
        
        angleplot=plot(app.UIAxes3,[1,0,1],[0,0,sin(0.5)],'b--','linewidth',3);
        xlim(app.UIAxes3,[-1,1]);
        ylim(app.UIAxes3,[-1 1]);
        
        set(app.UIAxes3,'XTick',[])
        set(app.UIAxes3,'YTick',[])
        hold(app.UIAxes3,'off')
        
        
        end      %%% END OF PLANE OUTLINE SUBFUNCTION

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  Down load data from sliders and create models and responses
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function app = createmodels(app)

            % Collect values from sliders and ensure rounded sensibly
            A=app.ParameterCSlider.Value;
            a=app.ParameteraSlider.Value;
            b=app.PoletozeroratioSlider.Value;
            w=app.LeadfrequencywSlider.Value;
            K=app.LeadgainKSlider.Value;
            

            % define transfer functions
            % y = G*u 
            app.G=tf(A,[1,a,0,0]); % AEROPLANE model
            b2=sqrt(b);
            app.pole = b2*w;
            app.zero = w/b2;
            app.wc  = w;
            app.M=K*tf([1,app.zero],[1,app.pole]);     % wind to velocity
            
        end   % end of create models subfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Manage the animation and legends
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        function app = animationoflineplots(app)
            %%  Set up legend
            if isempty(app.legstring{1});
                nlegstring=0;
            else
                nlegstring = length(app.legstring);
            end
            
            app.legstring{nlegstring+1}=['C = ',num2str(app.ParameterCSlider.Value),...
                ', a=',num2str(app.ParameteraSlider.Value),...
                ', K=',num2str(app.LeadgainKSlider.Value),...
                ', w=',num2str(app.LeadfrequencywSlider.Value),...
                ', r=',num2str(app.PoletozeroratioSlider.Value),...
                ', pm=',num2str(app.pm)];
            % collect responses
            Gc=feedback(app.G*app.M,1);
            app.runtime = 20/app.wc;
            app.time=linspace(0,app.runtime,app.samples);
            app.ytotal = 0.5*step(Gc,app.time);
            
            %% initialise figure for ROLL response
            yplot = plot(app.UIAxes2,app.time(1),app.ytotal(1));
            xlabel(app.UIAxes2,'time (sec)')
            hold(app.UIAxes2,'on')
            xlim(app.UIAxes2,[0,app.runtime]);
            kk=legend(app.UIAxes2,app.legstring,'Location','southeast');
            set(kk,'fontsize',8);
            grid(app.UIAxes2,'on')
            
            

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% animation of aeroplaneroll
            % define animation time aspects
            animationsamples = app.animationtime/app.Tsamp; % assume sample time of Tsamp
            updaterate =ceil(app.samples/animationsamples); % no of samples between pauses
            tstart=tic; tsave = tstart;

            
            for k=1:length(app.time);
                set(yplot,'Ydata',app.ytotal(1:k),'Xdata',app.time(1:k));
                
                % animation of plane
                phi=app.ytotal(k);
                xn=app.xx*cos(phi)-app.yy*sin(phi);
                yn=app.xx*sin(phi)+app.yy*cos(phi);
                app.aero.XData = xn;
                app.aero.YData = yn;
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
%%%%%%%%%  Control interaction during the animation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function  disablebuttons(app)
            set(app.SimulateButton, 'Enable', 'off');
            set(app.RefreshButton, 'Enable', 'off');
            set(app.AnimationOnButton, 'Enable', 'off');
            set(app.LeadfrequencywSlider, 'Enable', 'off');
            set(app.LeadgainKSlider, 'Enable', 'off');
            set(app.PoletozeroratioSlider, 'Enable', 'off');
            set(app.ParameteraSlider, 'Enable', 'off');
            set(app.ParameterCSlider, 'Enable', 'off');
        end
        
        function enablebuttons(app)
            set(app.SimulateButton, 'Enable', 'on');
            set(app.RefreshButton, 'Enable', 'on')
            set(app.AnimationOnButton, 'Enable', 'on')
            set(app.LeadfrequencywSlider, 'Enable', 'on');
            set(app.LeadgainKSlider, 'Enable', 'on');
            set(app.PoletozeroratioSlider, 'Enable', 'on');
            set(app.ParameteraSlider, 'Enable', 'on');
            set(app.ParameterCSlider, 'Enable', 'on');
        end


        % Update Bode diagrams and margins whenever the user makes an input
        % through a slider
        function results = updatemargins(app)
            
            % define frequency response data
            app = createmodels(app);
            hold(app.UIAxes,'off')
            hold(app.UIAxes_2,'off')
            warning('off','Control:analysis:MarginUnstable');
            [gm1,pm1] = margin(app.G);
            [gm2,pm2,wg2,wp2] = margin(app.G*app.M);
            warning('on');
            app.pm = pm2; % save the PM for later use
            wrange =logspace(-2,0,200);
            [gain1,phase1] = bode(app.G,wrange);
            [gain2,phase2] = bode(app.G*app.M,wrange);
            [gain3,phase3] = bode(app.M,wrange);
            
            
            % create plots manually
            semilogx(app.UIAxes,wrange,20*log10(gain1(:)),'linewidth',2);
            hold(app.UIAxes,'on');
            semilogx(app.UIAxes,wrange,20*log10(gain2(:)),'linewidth',2);
            semilogx(app.UIAxes,wrange,20*log10(gain3(:)),'linewidth',2);

            semilogx(app.UIAxes_2,wrange,phase1(:),'linewidth',2);
            hold(app.UIAxes_2,'on');
            semilogx(app.UIAxes_2,wrange,phase2(:),'linewidth',2);
            semilogx(app.UIAxes_2,wrange,phase3(:)-180,'linewidth',2);
            plot(app.UIAxes,[wp2,wp2],[-40,40],'g:','linewidth',2)

            grid(app.UIAxes,"on")
            grid(app.UIAxes_2,"on")
            tit = ['(G: gm = ',num2str(gm1),', pm = ',num2str(pm1),...
                '),   (GM: gm = ',num2str(gm2),', pm = ',num2str(pm2),')'];
            title(app.UIAxes,tit)
            
            % add lead pole/zero markers and other useful things
            plot(app.UIAxes_2,[app.pole,app.pole],[-250,-150],'r-','linewidth',2)
            text(app.UIAxes_2,app.pole*1.05,-170,'pole')
            plot(app.UIAxes_2,[app.zero,app.zero],[-250,-150],'m-','linewidth',2)
            text(app.UIAxes_2,app.zero*1.1,-170,'zero')
            plot(app.UIAxes_2,[app.wc,app.wc],[-250,-120],'b-','linewidth',2)
            text(app.UIAxes_2,app.wc,-200,'w')
            plot(app.UIAxes_2,[wp2,wp2],[-250,-120],'g:','linewidth',2)
            legend(app.UIAxes_2,'G','GM','M-180^o','pole','zero','w','w_c')
          
            ylim(app.UIAxes,[-40,40])
            ylim(app.UIAxes_2,[-250,-120])

            
        end
        
        % The default design is based on a target PM of 30
        % and the current frequency in the lead slider
        % This may not be achievable
        function app = defaultMdesign(app)
            wc= app.LeadfrequencywSlider.Value;
   
            [gainGwc,phaseGwc] = bode(app.G,wc);
            theta = (-180-phaseGwc+30)*pi/180;
            r =(sin(theta)+1)/(1-sin(theta));
            sr=sqrt(r);
            K= sr/gainGwc;
            zero = wc/sr;
            pole = wc*sr;
            Mtext = ['K=',num2str(round(K,2)),...
                ', r=',num2str(round(r,2)),...
                ', w = ',num2str(wc)];
            app.DefaultMsEditField.Value=Mtext;
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % resize to be in middle of  the window
            movegui(app.UIFigure)

            % Open the manual
            if exist('aeroplane_roll_control_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open aeroplane_roll_control_mycopy.mlx
            else
                p1 = which('aeroplane_roll_control_manual.mlx');
                p2 = strcat(pwd,'/aeroplane_roll_control_mycopy.mlx');
                copyfile(p1,p2)
                open aeroplane_roll_control_mycopy.mlx
                clear p1 p2
            end
            app=createmodels(app);
            app = defaultMdesign(app);

            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);

            app = createplaneoutline(app); % define car outline for animation
            updatemargins(app);
            app = defaultMdesign(app);
            
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
            theme(app.UIFigure,"light")
            end
        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
            
            disablebuttons(app);

            app = createmodels(app); % define responses
            updatemargins(app);
            app = createplaneoutline(app); % define car outline for animation
            app = animationoflineplots(app); % manage the animations
            
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

        % Value changed function: ParameteraSlider
        function ParameteraSliderValueChanged(app, event)
            value = app.ParameteraSlider.Value;
            value=round(value,2); 
            if value<0.1; value =0.1;end
            app.ParameteraSlider.Value=value;
            updatemargins(app);
            app = defaultMdesign(app);
        end

        % Value changed function: ParameterCSlider
        function ParameterCSliderValueChanged(app, event)
            value = app.ParameterCSlider.Value;
            value=round(value,2);
             if value<0.01; value =0.01;end
            app.ParameterCSlider.Value=value;
            updatemargins(app);    
            app = defaultMdesign(app);
            
        end

        % Value changed function: LeadgainKSlider
        function LeadgainKSliderValueChanged(app, event)
            value = app.LeadgainKSlider.Value;
            value = round(value,2);
            if value<0.01; value =0.01;end

            app.LeadgainKSlider.Value=value;
             updatemargins(app);      
             app = defaultMdesign(app);
        end

        % Value changed function: LeadfrequencywSlider
        function LeadfrequencywSliderValueChanged(app, event)
            value = app.LeadfrequencywSlider.Value;
            value=round(value,3);
            if value<0.02; value =0.02;end

            app.LeadfrequencywSlider.Value=value;
            updatemargins(app);
            app = defaultMdesign(app);
            
            
        end

        % Value changed function: PoletozeroratioSlider
        function PoletozeroratioSliderValueChanged(app, event)
            value = app.PoletozeroratioSlider.Value;
            value = round(value,1);
            if value<1; value =1;end

            app.PoletozeroratioSlider.Value=value;
            updatemargins(app);
            app = defaultMdesign(app);
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
            app.UIFigure.Position = [100 100 1062 825];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '2x'};
            app.GridLayout.RowHeight = {'0.4x', '1.2x', '1.2x', '2x'};

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Bode gain diagram and margins')
            xlabel(app.UIAxes, 'rad/s')
            ylabel(app.UIAxes, 'DB')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.XTick = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
            app.UIAxes.XMinorTick = 'on';
            app.UIAxes.YMinorTick = 'on';
            app.UIAxes.Layout.Row = 2;
            app.UIAxes.Layout.Column = 2;

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.GridLayout);
            title(app.UIAxes_2, 'Bode phase diagram and margins')
            xlabel(app.UIAxes_2, 'rad/s')
            ylabel(app.UIAxes_2, 'Degrees')
            zlabel(app.UIAxes_2, 'Z')
            app.UIAxes_2.Layout.Row = 3;
            app.UIAxes_2.Layout.Column = 2;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = 2;
            app.GridLayout2.BackgroundColor = [0.6 1 1];

            % Create LeadcontrolofaeroplanerollLabel
            app.LeadcontrolofaeroplanerollLabel = uilabel(app.GridLayout2);
            app.LeadcontrolofaeroplanerollLabel.BackgroundColor = [0 1 1];
            app.LeadcontrolofaeroplanerollLabel.HorizontalAlignment = 'center';
            app.LeadcontrolofaeroplanerollLabel.FontSize = 24;
            app.LeadcontrolofaeroplanerollLabel.FontWeight = 'bold';
            app.LeadcontrolofaeroplanerollLabel.Layout.Row = 1;
            app.LeadcontrolofaeroplanerollLabel.Layout.Column = [1 2];
            app.LeadcontrolofaeroplanerollLabel.Text = 'Lead control of aeroplane roll';

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
            app.AnimationOnButton.BackgroundColor = [1 0.2 0.702];
            app.AnimationOnButton.FontSize = 16;
            app.AnimationOnButton.FontWeight = 'bold';
            app.AnimationOnButton.Layout.Row = 1;
            app.AnimationOnButton.Layout.Column = 3;
            app.AnimationOnButton.Text = 'Animation On';

            % Create DetailedanalysisoffirstordermodelparametersPanel
            app.DetailedanalysisoffirstordermodelparametersPanel = uipanel(app.GridLayout);
            app.DetailedanalysisoffirstordermodelparametersPanel.AutoResizeChildren = 'off';
            app.DetailedanalysisoffirstordermodelparametersPanel.TitlePosition = 'centertop';
            app.DetailedanalysisoffirstordermodelparametersPanel.Title = 'Detailed analysis of first order model parameters and behaviour dependence on parameters';
            app.DetailedanalysisoffirstordermodelparametersPanel.BackgroundColor = [0.8902 0.7333 0.9882];
            app.DetailedanalysisoffirstordermodelparametersPanel.Layout.Row = 4;
            app.DetailedanalysisoffirstordermodelparametersPanel.Layout.Column = [1 2];
            app.DetailedanalysisoffirstordermodelparametersPanel.FontWeight = 'bold';
            app.DetailedanalysisoffirstordermodelparametersPanel.FontSize = 18;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.DetailedanalysisoffirstordermodelparametersPanel);
            app.GridLayout5.ColumnWidth = {'1x', '1.4x'};
            app.GridLayout5.RowHeight = {'1x'};

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.GridLayout5);
            title(app.UIAxes3, 'Animation of aeroplane roll')
            xlabel(app.UIAxes3, 'Time (s)')
            ylabel(app.UIAxes3, 'Angle (degrees)')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.FontSize = 14;
            app.UIAxes3.Layout.Row = 1;
            app.UIAxes3.Layout.Column = 1;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout5);
            title(app.UIAxes2, 'Closed-loop responses')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 14;
            app.UIAxes2.Layout.Row = 1;
            app.UIAxes2.Layout.Column = 2;

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout6.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout6.Layout.Row = 3;
            app.GridLayout6.Layout.Column = 1;
            app.GridLayout6.BackgroundColor = [0.702 1 0.702];

            % Create LeadcompensatorMsKswbswbLabel
            app.LeadcompensatorMsKswbswbLabel = uilabel(app.GridLayout6);
            app.LeadcompensatorMsKswbswbLabel.BackgroundColor = [0 1 0];
            app.LeadcompensatorMsKswbswbLabel.HorizontalAlignment = 'center';
            app.LeadcompensatorMsKswbswbLabel.FontSize = 16;
            app.LeadcompensatorMsKswbswbLabel.FontWeight = 'bold';
            app.LeadcompensatorMsKswbswbLabel.Layout.Row = 1;
            app.LeadcompensatorMsKswbswbLabel.Layout.Column = [1 2];
            app.LeadcompensatorMsKswbswbLabel.Text = 'Lead compensator: M(s) = K(s+w/b)/(s+wb)';

            % Create LeadgainKSliderLabel
            app.LeadgainKSliderLabel = uilabel(app.GridLayout6);
            app.LeadgainKSliderLabel.HorizontalAlignment = 'right';
            app.LeadgainKSliderLabel.FontSize = 14;
            app.LeadgainKSliderLabel.Layout.Row = 2;
            app.LeadgainKSliderLabel.Layout.Column = 1;
            app.LeadgainKSliderLabel.Text = 'Lead gain ''K''';

            % Create LeadgainKSlider
            app.LeadgainKSlider = uislider(app.GridLayout6);
            app.LeadgainKSlider.Limits = [0 0.5];
            app.LeadgainKSlider.ValueChangedFcn = createCallbackFcn(app, @LeadgainKSliderValueChanged, true);
            app.LeadgainKSlider.MinorTicks = [-20 -15 -10 -5 0 5 10 15 20];
            app.LeadgainKSlider.FontSize = 14;
            app.LeadgainKSlider.Layout.Row = 2;
            app.LeadgainKSlider.Layout.Column = 2;
            app.LeadgainKSlider.Value = 0.1;

            % Create LeadfrequencywSliderLabel
            app.LeadfrequencywSliderLabel = uilabel(app.GridLayout6);
            app.LeadfrequencywSliderLabel.HorizontalAlignment = 'right';
            app.LeadfrequencywSliderLabel.FontSize = 13;
            app.LeadfrequencywSliderLabel.Layout.Row = 3;
            app.LeadfrequencywSliderLabel.Layout.Column = 1;
            app.LeadfrequencywSliderLabel.Text = 'Lead frequency ''w''';

            % Create LeadfrequencywSlider
            app.LeadfrequencywSlider = uislider(app.GridLayout6);
            app.LeadfrequencywSlider.Limits = [0 0.2];
            app.LeadfrequencywSlider.ValueChangedFcn = createCallbackFcn(app, @LeadfrequencywSliderValueChanged, true);
            app.LeadfrequencywSlider.MinorTicks = [0 5 15 20];
            app.LeadfrequencywSlider.FontSize = 13;
            app.LeadfrequencywSlider.Layout.Row = 3;
            app.LeadfrequencywSlider.Layout.Column = 2;
            app.LeadfrequencywSlider.Value = 0.05;

            % Create LeadfrequencywLabel
            app.LeadfrequencywLabel = uilabel(app.GridLayout6);
            app.LeadfrequencywLabel.HorizontalAlignment = 'right';
            app.LeadfrequencywLabel.FontSize = 13;
            app.LeadfrequencywLabel.Layout.Row = 4;
            app.LeadfrequencywLabel.Layout.Column = 1;
            app.LeadfrequencywLabel.Text = 'Pole to zero ratio';

            % Create PoletozeroratioSlider
            app.PoletozeroratioSlider = uislider(app.GridLayout6);
            app.PoletozeroratioSlider.Limits = [0 10];
            app.PoletozeroratioSlider.ValueChangedFcn = createCallbackFcn(app, @PoletozeroratioSliderValueChanged, true);
            app.PoletozeroratioSlider.FontSize = 13;
            app.PoletozeroratioSlider.Layout.Row = 4;
            app.PoletozeroratioSlider.Layout.Column = 2;
            app.PoletozeroratioSlider.Value = 2;

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout4.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout4.Layout.Row = 2;
            app.GridLayout4.Layout.Column = 1;
            app.GridLayout4.BackgroundColor = [0.902 1 0.502];

            % Create MassMkgLabel
            app.MassMkgLabel = uilabel(app.GridLayout4);
            app.MassMkgLabel.HorizontalAlignment = 'right';
            app.MassMkgLabel.FontSize = 14;
            app.MassMkgLabel.Layout.Row = 2;
            app.MassMkgLabel.Layout.Column = 1;
            app.MassMkgLabel.Text = '''Parameter ''C''';

            % Create ParameterCSlider
            app.ParameterCSlider = uislider(app.GridLayout4);
            app.ParameterCSlider.Limits = [0 0.04];
            app.ParameterCSlider.ValueChangedFcn = createCallbackFcn(app, @ParameterCSliderValueChanged, true);
            app.ParameterCSlider.MinorTicks = [500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000];
            app.ParameterCSlider.FontSize = 14;
            app.ParameterCSlider.Layout.Row = 2;
            app.ParameterCSlider.Layout.Column = 2;
            app.ParameterCSlider.Value = 0.01;

            % Create ParameteraSliderLabel
            app.ParameteraSliderLabel = uilabel(app.GridLayout4);
            app.ParameteraSliderLabel.HorizontalAlignment = 'right';
            app.ParameteraSliderLabel.FontSize = 14;
            app.ParameteraSliderLabel.Layout.Row = 3;
            app.ParameteraSliderLabel.Layout.Column = 1;
            app.ParameteraSliderLabel.Text = 'Parameter ''a''';

            % Create ParameteraSlider
            app.ParameteraSlider = uislider(app.GridLayout4);
            app.ParameteraSlider.Limits = [0 0.4];
            app.ParameteraSlider.ValueChangedFcn = createCallbackFcn(app, @ParameteraSliderValueChanged, true);
            app.ParameteraSlider.MinorTicks = [0 100 200 300 400 500 600 700 800 900 1000];
            app.ParameteraSlider.FontSize = 14;
            app.ParameteraSlider.Layout.Row = 3;
            app.ParameteraSlider.Layout.Column = 2;
            app.ParameteraSlider.Value = 0.1;

            % Create AeroplaneparametersGsAs2saLabel
            app.AeroplaneparametersGsAs2saLabel = uilabel(app.GridLayout4);
            app.AeroplaneparametersGsAs2saLabel.BackgroundColor = [1 1 0];
            app.AeroplaneparametersGsAs2saLabel.HorizontalAlignment = 'center';
            app.AeroplaneparametersGsAs2saLabel.FontSize = 16;
            app.AeroplaneparametersGsAs2saLabel.FontWeight = 'bold';
            app.AeroplaneparametersGsAs2saLabel.Layout.Row = 1;
            app.AeroplaneparametersGsAs2saLabel.Layout.Column = [1 2];
            app.AeroplaneparametersGsAs2saLabel.Text = 'Aeroplane parameters: G(s)=A/[s^2(s+a)]';

            % Create DefaultMsEditFieldLabel
            app.DefaultMsEditFieldLabel = uilabel(app.GridLayout4);
            app.DefaultMsEditFieldLabel.HorizontalAlignment = 'right';
            app.DefaultMsEditFieldLabel.FontSize = 14;
            app.DefaultMsEditFieldLabel.Layout.Row = 4;
            app.DefaultMsEditFieldLabel.Layout.Column = 1;
            app.DefaultMsEditFieldLabel.Text = 'Default M(s)';

            % Create DefaultMsEditField
            app.DefaultMsEditField = uieditfield(app.GridLayout4, 'text');
            app.DefaultMsEditField.FontSize = 14;
            app.DefaultMsEditField.Layout.Row = 4;
            app.DefaultMsEditField.Layout.Column = 2;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = aeroplane_roll_control

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

