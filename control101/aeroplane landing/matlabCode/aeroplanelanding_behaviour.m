classdef aeroplanelanding_behaviour < matlab.apps.AppBase
    %AEROPLANELANDING_BEHAVIOUR
    %   File written by J.A.Rossiter, University of Sheffield  
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   
    %   A simple interface to practice behaviour of a mass-spring-damper
    %   system or suspension unit through the illustration of an aeroplane
    %   landing. 
    %   
    %   Users can change the sizes of the basic suspension elements, that
    %   is spring stifness, damping and aeroplane mass. Also the vertical
    %   landing speed.
    %   
    %   The animation is intended to be partially humourous in order to
    %   engage students in the topic. Othe elements of the app give
    %   pictorial impressions of the impact of changing the component sizes
    %   and plots that can be used to assess damping, overshoot and the
    %   like.
    %   
    %   Some notes and engineering background are in the partner
    %   livescript file:    aeroplanelanding_behaviour_manual.mlx
    %   A group of similar files can be downloaded through MATLAB
    %   add-ons with the toolbox name:  control101
    %     
    %      
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   %%%%%%%%%%%%  FILE ORGANISATION
    %   A section defining the core variables stored in "app"
    %   
    %       A section with subfunctions doing the core computations
    %       i) define behaviour models and associated responses; 
    %       ii) initialise figures for animations and analysis; 
    %       iii) several subfunctions are used to control the animations
    %       iv) switch interaction on and off during animations
    %       v) clean figures and legends so can begin a new investigation
    %       vii) callbacks (subfunctions) for every item in the interface
    %   to control decimal places and the like.    
    %       viii) A callback which activates with the 'start simulation'
    %   button and runs the subfunctions in turn.

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        GridLayout                  matlab.ui.container.GridLayout
        GridLayout6                 matlab.ui.container.GridLayout
        v0msSlider                  matlab.ui.control.Slider
        v0msSliderLabel             matlab.ui.control.Label
        EnvironmentparametersLabel  matlab.ui.control.Label
        DetailedanalysisoffirstordermodelparametersPanel  matlab.ui.container.Panel
        GridLayout5                 matlab.ui.container.GridLayout
        UIAxes2_2                   matlab.ui.control.UIAxes
        UIAxes2                     matlab.ui.control.UIAxes
        UIAxes3                     matlab.ui.control.UIAxes
        GridLayout4                 matlab.ui.container.GridLayout
        kkNmSlider                  matlab.ui.control.Slider
        kkNmSliderLabel             matlab.ui.control.Label
        SuspensionparametersMdvdtBvkxCfLabel  matlab.ui.control.Label
        BkNsmSlider                 matlab.ui.control.Slider
        BkNsmSliderLabel            matlab.ui.control.Label
        MtonSlider                  matlab.ui.control.Slider
        MtonSliderLabel             matlab.ui.control.Label
        GridLayout3                 matlab.ui.container.GridLayout
        AnimationOnButton           matlab.ui.control.Button
        RefreshButton               matlab.ui.control.Button
        SimulateButton              matlab.ui.control.Button
        GridLayout2                 matlab.ui.container.GridLayout
        Image                       matlab.ui.control.Image
        ndorderMSDmodelforaeroplanelandingLabel  matlab.ui.control.Label
        UIAxes                      matlab.ui.control.UIAxes
        UIAxes4                     matlab.ui.control.UIAxes
    end

    
    
    
    % The next section defines all the core variables used in the code and
    % that it may be convenient to have available in the various
    % subfunctions
    properties (Access = private)
        originalsize     % product of width and height for font sizing

        legstring=cell(1); % To store legends
        M;   %  mass
        B;   % friction
        k    % spring stiffness
        h   % a handle for animation of pilot

        runtime = 10; % for simulation the runtime
        time;  % variable to store time instants for simulation plots
        samples = 201;
        animationtime = 8; % how long animation will take
        Tsamp=0.1;  % update rate for animation

         % displacement relative to ground level/ss
         % Force on the passenger
        ytotal % save output values for plotting
        accn % acceleration
        Dampingratio % current damping ratio
        
    end
    
    methods (Access = private)
        


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  PLOT OF TOP FIGURE - THE passenger/plane/suspension system
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function app = createpassengeroutline(app)
            %%% Spring corordinates
            xspring=[1,0.5,0.5,1,0,1,0,1,0,1,0,0.5,0.5];
            yspring=[0,0.5,0.8,1,1.4,1.8,2.2,2.6,3,3.4,3.8,4,4.2];
            
            %%% Damper coordinates
            xdamper1 = [1,1.6,1.6];
            xdamper2 = [1.2,1.2,2,2];
            ydamper1 = [0,0.5,2];
            ydamper2 = [1.5,2.2,2.2,1.5];
            xdamper3 = [1.6,1.6];
            ydamper3 = [2.2,4.2];
            
            %%% Seat coordinates
            xseat1=[-1,-1,-0.5,-0.5];
            yseat1=[8,4.2,4.2,8];
            xseat2=[-1,-1.5,-1.7,-1.8,-2.2,-2.5,-2.6,-2.2,-1.4,-1.2,-0.8,-0.5,3,5,5.5,5];
            yseat2=[6.2,8,9.1,10.4,10.5,9.1,8.5,6,4.7,4.5 ,4.3 ,4.2,4.2,5.3,5.8,6.3];
            
            %%%% Body co-ordinates
            x= [-0.5,0,-0.2,-0.2,1,1,0.5,0.5,1.2,1,2.5,3.5,3.5,3.4,3.7 3.7,3,3.1,3,2.9,3,1.5,-0.3,-0.5];
            y= [6.5,8,8.3,9.5,9.4,8.5 8.5,8,8,6,5.8,5.5,4,1.2,1.2,0.8 0.8,1,1.4,2.9,4.9,4.7,4.7,6.5];
            hold(app.UIAxes,'off')
            
            
            
            %%%%%% Plot picture
            h.spring=plot(app.UIAxes,xspring,yspring,'b','Linewidth',2); 
            hold(app.UIAxes,'on')
            h.damper = plot(app.UIAxes,xdamper1,ydamper1,'b',xdamper2,ydamper2,'b',xdamper3,ydamper3,'b');
            set(h.damper,'Linewidth',2);
            h.wheel=plot(app.UIAxes,1,-0.5,'ro','MarkerSize',20,'Linewidth',3);
            %h.seat1=fill(app.UIAxes,xseat1,yseat1,'g');
            h.seat2=fill(app.UIAxes,xseat2,yseat2,'g');
            h.hbody=plot(app.UIAxes,x,y,'r','LineWidth',6);
            xlim(app.UIAxes,[-3,6]);
            ylim(app.UIAxes,[-2,12]);

            app.h = h;
            
            % Initialise plots
            axis(app.UIAxes,[-10,20,-10,20]);
            plot(app.UIAxes,[-10,20],[-1.5,-1.5],'k','Linewidth',4);
            
            app=movespringfly(app,8,-8);
            app = movepilot(app,8,-8);
            app=movespringland(app,2,0);
            app = movepilot(app,2,0);
            
        end      %%% END OF PASSENGEROUTLINE SUBFUNCTION

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  Down load data from sliders and create responses
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function app = findbehaviour(app)

            % collect values from sliders
            B=app.BkNsmSlider.Value*1000;
            M=app.MtonSlider.Value*1000;
            k=app.kkNmSlider.Value*1000;
            v0=app.v0msSlider.Value;
            
            % create 2nd order model and characterise
            p=[M,B,k]; 
            r= roots(p); 
            p1 = max(real(r));
            wn=sqrt(k/M);
            zeta = (B/M)/(2*wn);
            T=-1/p1;
            T1 = pi/(wn*sqrt(1-zeta^2));
            app.Dampingratio=round(zeta,3);
            Steadystate= 1/k;
            Slowesttimeconstant= T;
            app.runtime = round(4*T);
            overshoot = exp(-zeta*pi/sqrt(1-zeta^2));
            
            % Solve for behaviour with standard forced step response
            syms y(t);
            Dy = diff(y);
            D2y=diff(Dy);
            y=dsolve(M*D2y+B*Dy+k*y == 1,y(0)==0, Dy(0)==0);
            tt=linspace(0,app.runtime,app.samples);
            yt = double(subs(y,tt))*10^6;
            app.UIAxes3.XGrid='on';
            app.UIAxes3.YGrid='on';
            plot(app.UIAxes3,tt,yt,'linewidth',2); 
            hold(app.UIAxes3,'on')
            plot(app.UIAxes3,[T,T],[0,10^6/k],'r--','LineWidth',2)
            plot(app.UIAxes3,[0,app.runtime],10^6*[1/k,1/k],'m--','LineWidth',2)        
            maxyt = max(yt);
            plot(app.UIAxes3,[0,app.runtime],[1,1]*maxyt,'g-.','LineWidth',2)   
            plot(app.UIAxes3,[T1,T1],[0,maxyt],'-.k','Linewidth',2)
            hold(app.UIAxes3,'off')
            kk=legend(app.UIAxes3,'Step response',['Time constant = ',num2str(round(T,2))],['Steady state = ',num2str(round(Steadystate*10^6,2))],['Overshoot = ',num2str(round(100*overshoot,0)),'%'],['Peak time = ',num2str(round(T1,2))],'Location','southeast');
            set(kk,'fontsize',12);
            

            % Solve for behaviour with an initial impact speed
            syms y(t);
            Dy = diff(y);
            D2y=diff(Dy);
            y=dsolve(M*D2y+B*Dy+k*y == 0,y(0)==0, Dy(0)== v0);
            y2 = diff(diff(y)); % 2nd derivative
            tt=linspace(0,app.runtime,app.samples);
            yt = double(subs(y,tt));    % displacement
            accn = double(subs(y2,tt)); % acceleration

            app.ytotal = yt;
            app.accn = accn;
            app.time=tt;

            
            
        end   % end of findbehaviour subfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Manage the animation and legends
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function app = animationoflineplots(app)
            % collect core values
            B=app.BkNsmSlider.Value;
            M=app.MtonSlider.Value;
            k=app.kkNmSlider.Value;
            v0=app.v0msSlider.Value;

            % Set up and update legend
            if isempty(app.legstring{1});
                nlegstring=0;
            else
                nlegstring = length(app.legstring);
            end
            app.legstring{nlegstring+1}=['M = ',num2str(M),', B = ',num2str(B),...
                ', k = ',num2str(k),', v(0) = ',num2str(v0),', \zeta = ',num2str(app.Dampingratio)];
            
            % initialise figure for speed response
            yplot = plot(app.UIAxes2,app.time(1),app.ytotal(1));
            xlabel(app.UIAxes2,'time (sec)')
            hold(app.UIAxes2,'on')
            xlim(app.UIAxes2,[0,app.runtime]);
            kk=legend(app.UIAxes2,app.legstring,'Location','southeast');
            set(kk,'fontsize',8);
            grid(app.UIAxes2,'on')
            
            % Acceleration figure
            plot(app.UIAxes2_2,app.time,app.accn);
            hold(app.UIAxes2_2,'on');
            grid(app.UIAxes2_2,'on');
            xlim(app.UIAxes2_2,[0,app.runtime]);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% animation of pilot and displacement/acceleration plot
            % define animation time aspects
            animationsamples = app.animationtime/app.Tsamp; % assume sample time of Tsamp
            updaterate =ceil(app.samples/animationsamples); % no of samples between pauses
            tstart=tic; tsave = tstart;

            
            for k=1:length(app.time)+39;
                
                %%%% Animate picture of landing using pause to run a sensible time scale
                if k<41; % First part of landing
                    app=movespringfly(app,-0.2,0.2);
                    app=movepilot(app,-0.2,0.2);
                else % 2nd part of landing, that is after contact
                    deltay = (app.ytotal(k-39)-app.ytotal(k-40))*10;
                    app=movespringland(app,deltay,0.08);
                    app=movepilot(app,deltay,0.08);
                    % Animate the line plot
                    set(yplot,'Ydata',app.ytotal(1:k-40),'Xdata',app.time(1:k-40));
  
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
        end  % end of animation

 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%  Control interaction during the animation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function  disablebuttons(app)
            set(app.SimulateButton, 'Enable', 'off');
            set(app.RefreshButton, 'Enable', 'off');
            set(app.AnimationOnButton, 'Enable', 'off');
            set(app.v0msSlider, 'Enable', 'off');
            set(app.kkNmSlider, 'Enable', 'off');
            set(app.BkNsmSlider, 'Enable', 'off');
            set(app.MtonSlider, 'Enable', 'off');
        end
        
        function enablebuttons(app)
            set(app.SimulateButton, 'Enable', 'on');
            set(app.RefreshButton, 'Enable', 'on')
            set(app.AnimationOnButton, 'Enable', 'on')
            set(app.v0msSlider, 'Enable', 'on');
            set(app.kkNmSlider, 'Enable', 'on');
            set(app.BkNsmSlider, 'Enable', 'on');
            set(app.MtonSlider, 'Enable', 'on');
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update picture to represent sizes of the suspension components
        function app = massspringdamper(app)
            B=app.BkNsmSlider.Value;
            M=app.MtonSlider.Value;
            k=app.kkNmSlider.Value;
                     
            box = [-10,10];
            plot(app.UIAxes4,box,box,'w');
            hold(app.UIAxes4,'on')
            
            %%% mass parameters
            factor = M/40;
            xm = [-9,9,9,-9]; ym = [ 4 4 4+factor 4+factor];
            fill(app.UIAxes4,xm,ym,'b')
            plot(app.UIAxes4,[-6 6],[4 4],'k-','linewidth',6);
            
            %%% damper parameters
            width = B/80; % width must go from about 0 to 3
            if width <0.3;width=0.3;end 
            if width>3;width=3;end
            plot(app.UIAxes4,[2 8 5 5],[-9 -9 -9 -5],'k-','linewidth',4);
            plot(app.UIAxes4,[5 5],[0 4],'k-','linewidth',4);
              plot(app.UIAxes4,[2 2 8 8],[2 -5 -5 2],'k-','linewidth',4);
            plot(app.UIAxes4,[5-width 5+width],[0 0 ],'k-','linewidth',width*8);

            %%% Spring parameters
            width2 = k/50; if width2>20;width2=20;end
            plot(app.UIAxes4,[-2 -8],[-9 -9],'k-','linewidth',4);
            xk=[-5 -5,-8 -2 -8 -2 -8 -2 -5 -5];
            yk = [-9 -8.5 -7 -5.5 -4 -1.5,0,1.5,3,4];
            plot(app.UIAxes4,xk,yk,'k-','linewidth',width2);
            hold(app.UIAxes4,'off')

        end % end of set up for MSD object
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to move the spring/damper while flying
        function app=movespringfly(app,changeseatheight,changeinx)

            yy=changeseatheight;
            xx=changeinx;
                        
            app.h.spring.YData = app.h.spring.YData +yy;
            app.h.spring.XData = app.h.spring.XData +xx;
            for k=1:3;
                ydata=app.h.damper(k).YData;
                xdata=app.h.damper(k).XData;
                app.h.damper(k).YData = ydata+yy;
                app.h.damper(k).XData = xdata+xx;
            end
           
            app.h.wheel.XData = app.h.wheel.XData + xx;
            app.h.wheel.YData = app.h.wheel.YData + yy;

        end  % end of spring/damper movement

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to manage spring/damper movement and spring compression on
% landing
       function app=movespringland(app,changeseatheight,changeinx)

            yy=changeseatheight;
            xx=changeinx;
            oldheight=app.h.spring.YData(end);
            
            % variable needed for bouncing action
            ratio=(changeseatheight+oldheight)/oldheight;
            newy = oldheight*ratio;
            
            %%% Move spring and damper in proportion
            app.h.spring.YData = app.h.spring.YData*ratio;
            app.h.spring.XData = app.h.spring.XData+xx;
            for k=1:3;
                ydata=app.h.damper(k).YData;
                xdata=app.h.damper(k).XData;
                app.h.damper(k).YData = ydata*ratio;
                app.h.damper(k).XData = xdata+xx;
            end
           
            app.h.wheel.XData = app.h.wheel.XData+xx;

       end  % end of spring/damper movement
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Move body and seat in absolute terms
      function app=movepilot(app,changeseatheight,changeinx)
            
            xx=changeinx;
            yy=changeseatheight;
            
            % app.h.seat1.YData = app.h.seat1.YData + yy;
            % app.h.seat1.XData = app.h.seat1.XData + xx;
            app.h.seat2.YData = app.h.seat2.YData + yy;
            app.h.seat2.XData = app.h.seat2.XData + xx;
            app.h.hbody.YData = app.h.hbody.YData + yy;
            app.h.hbody.XData = app.h.hbody.XData + xx;
   
      end  % end of movepilot subfunction
        
                 
        
        end  % end of sub functions section
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
            % resize to be in middle of  the window
            movegui(app.UIFigure)

            % Open the manual
            if exist('aeroplanelanding_behaviour_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open aeroplanelanding_behaviour_mycopy.mlx
            else
                p1 = which('aeroplanelanding_behaviour_manual.mlx');
                p2 = strcat(pwd,'/aeroplanelanding_behaviour_mycopy.mlx');
                copyfile(p1,p2)                
                open aeroplanelanding_behaviour_mycopy.mlx
                clear p1 p2
            end
                       
            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);

            app = createpassengeroutline(app); % define car outline for animation
            app = massspringdamper(app);       % Define MSD image

            
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
            theme(app.UIFigure,"light")
            end
            
        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
            
            disablebuttons(app);

            app = createpassengeroutline(app); % define car outline for animation
            app = findbehaviour(app);          % solve for the behaviour
            app = animationoflineplots(app);   % manage the animations

            enablebuttons(app);

        end

        % Button pushed function: RefreshButton
        function RefreshButtonPushed(app, event)
            %% Clean all the figures and legend so user can begin afresh
             hold(app.UIAxes3,'off')
             hold(app.UIAxes2,'off')
             hold(app.UIAxes2_2,'off')
             plot(app.UIAxes3,0,0)
             plot(app.UIAxes2,0,0)
             plot(app.UIAxes2_2,0,0)
             app.legstring=cell(1);
             app = createpassengeroutline(app);
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

        % Value changed function: kkNmSlider
        function kkNmSliderValueChanged(app, event)
            value = app.kkNmSlider.Value;
            value = round(value,-2);
            if value<100; value=100;end;
            app.kkNmSlider.Value=value;
            app = createpassengeroutline(app);
            app = massspringdamper(app);

        end

        % Value changed function: BkNsmSlider
        function BkNsmSliderValueChanged(app, event)
            value = app.BkNsmSlider.Value;
            value=round(value*2,-1)/2; 
            if value<10; value =10;end
            app.BkNsmSlider.Value=value;
            app = createpassengeroutline(app);
            app = massspringdamper(app);
        end

        % Value changed function: MtonSlider
        function MtonSliderValueChanged(app, event)
            value = app.MtonSlider.Value;
            value=round(value/2,-1)*2;
            if value<20; value=20;end
            app.MtonSlider.Value=value;
            app = createpassengeroutline(app);
            app = massspringdamper(app);
           
        end

        % Value changed function: v0msSlider
        function v0msSliderValueChanged(app, event)
            value = app.v0msSlider.Value;
            value = round(value,1);
            if value>-0.1; value = -0.1;end
            app.v0msSlider.Value=value;
            app = createpassengeroutline(app);
            
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
            app.UIFigure.Position = [100 100 1252 858];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '2x', '1x'};
            app.GridLayout.RowHeight = {'0.4x', '1.2x', '0.6x', '2x'};

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.GridLayout);
            title(app.UIAxes4, 'Representation of MSD values')
            zlabel(app.UIAxes4, 'Z')
            app.UIAxes4.XTick = [];
            app.UIAxes4.YTick = [];
            app.UIAxes4.Layout.Row = [2 3];
            app.UIAxes4.Layout.Column = 3;

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Animation of landing')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.XTickLabel = '';
            app.UIAxes.YTickLabel = '';
            app.UIAxes.FontSize = 18;
            app.UIAxes.Layout.Row = [2 3];
            app.UIAxes.Layout.Column = 2;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = [2 3];
            app.GridLayout2.BackgroundColor = [0.6 1 1];

            % Create ndorderMSDmodelforaeroplanelandingLabel
            app.ndorderMSDmodelforaeroplanelandingLabel = uilabel(app.GridLayout2);
            app.ndorderMSDmodelforaeroplanelandingLabel.BackgroundColor = [0 1 1];
            app.ndorderMSDmodelforaeroplanelandingLabel.HorizontalAlignment = 'center';
            app.ndorderMSDmodelforaeroplanelandingLabel.FontSize = 24;
            app.ndorderMSDmodelforaeroplanelandingLabel.FontWeight = 'bold';
            app.ndorderMSDmodelforaeroplanelandingLabel.Layout.Row = 1;
            app.ndorderMSDmodelforaeroplanelandingLabel.Layout.Column = [1 2];
            app.ndorderMSDmodelforaeroplanelandingLabel.Text = '2nd order MSD model for aeroplane landing';

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
            app.GridLayout4.ColumnWidth = {'0.4x', '1x'};
            app.GridLayout4.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout4.Layout.Row = 2;
            app.GridLayout4.Layout.Column = 1;
            app.GridLayout4.BackgroundColor = [0.902 1 0.502];

            % Create MtonSliderLabel
            app.MtonSliderLabel = uilabel(app.GridLayout4);
            app.MtonSliderLabel.HorizontalAlignment = 'right';
            app.MtonSliderLabel.FontSize = 14;
            app.MtonSliderLabel.Layout.Row = 2;
            app.MtonSliderLabel.Layout.Column = 1;
            app.MtonSliderLabel.Text = 'M (ton)';

            % Create MtonSlider
            app.MtonSlider = uislider(app.GridLayout4);
            app.MtonSlider.Limits = [0 200];
            app.MtonSlider.ValueChangedFcn = createCallbackFcn(app, @MtonSliderValueChanged, true);
            app.MtonSlider.MinorTicks = [500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000];
            app.MtonSlider.FontSize = 14;
            app.MtonSlider.Layout.Row = 2;
            app.MtonSlider.Layout.Column = 2;
            app.MtonSlider.Value = 80;

            % Create BkNsmSliderLabel
            app.BkNsmSliderLabel = uilabel(app.GridLayout4);
            app.BkNsmSliderLabel.HorizontalAlignment = 'right';
            app.BkNsmSliderLabel.FontSize = 14;
            app.BkNsmSliderLabel.Layout.Row = 3;
            app.BkNsmSliderLabel.Layout.Column = 1;
            app.BkNsmSliderLabel.Text = 'B (kNs/m)';

            % Create BkNsmSlider
            app.BkNsmSlider = uislider(app.GridLayout4);
            app.BkNsmSlider.Limits = [0 200];
            app.BkNsmSlider.ValueChangedFcn = createCallbackFcn(app, @BkNsmSliderValueChanged, true);
            app.BkNsmSlider.MinorTicks = [0 100 200 300 400 500 600 700 800 900 1000];
            app.BkNsmSlider.FontSize = 14;
            app.BkNsmSlider.Layout.Row = 3;
            app.BkNsmSlider.Layout.Column = 2;
            app.BkNsmSlider.Value = 30;

            % Create SuspensionparametersMdvdtBvkxCfLabel
            app.SuspensionparametersMdvdtBvkxCfLabel = uilabel(app.GridLayout4);
            app.SuspensionparametersMdvdtBvkxCfLabel.BackgroundColor = [1 1 0];
            app.SuspensionparametersMdvdtBvkxCfLabel.HorizontalAlignment = 'center';
            app.SuspensionparametersMdvdtBvkxCfLabel.WordWrap = 'on';
            app.SuspensionparametersMdvdtBvkxCfLabel.FontSize = 18;
            app.SuspensionparametersMdvdtBvkxCfLabel.FontWeight = 'bold';
            app.SuspensionparametersMdvdtBvkxCfLabel.Layout.Row = 1;
            app.SuspensionparametersMdvdtBvkxCfLabel.Layout.Column = [1 2];
            app.SuspensionparametersMdvdtBvkxCfLabel.Text = {'Suspension parameters: '; 'M(dv/dt) + Bv + kx = C f'};

            % Create kkNmSliderLabel
            app.kkNmSliderLabel = uilabel(app.GridLayout4);
            app.kkNmSliderLabel.HorizontalAlignment = 'right';
            app.kkNmSliderLabel.FontSize = 13;
            app.kkNmSliderLabel.Layout.Row = 4;
            app.kkNmSliderLabel.Layout.Column = 1;
            app.kkNmSliderLabel.Text = 'k (kN/m)';

            % Create kkNmSlider
            app.kkNmSlider = uislider(app.GridLayout4);
            app.kkNmSlider.Limits = [0 1000];
            app.kkNmSlider.ValueChangedFcn = createCallbackFcn(app, @kkNmSliderValueChanged, true);
            app.kkNmSlider.FontSize = 13;
            app.kkNmSlider.Layout.Row = 4;
            app.kkNmSlider.Layout.Column = 2;
            app.kkNmSlider.Value = 200;

            % Create DetailedanalysisoffirstordermodelparametersPanel
            app.DetailedanalysisoffirstordermodelparametersPanel = uipanel(app.GridLayout);
            app.DetailedanalysisoffirstordermodelparametersPanel.AutoResizeChildren = 'off';
            app.DetailedanalysisoffirstordermodelparametersPanel.TitlePosition = 'centertop';
            app.DetailedanalysisoffirstordermodelparametersPanel.Title = 'Detailed analysis of secondorder model parameters and behaviour dependence on parameters';
            app.DetailedanalysisoffirstordermodelparametersPanel.BackgroundColor = [0.8902 0.7333 0.9882];
            app.DetailedanalysisoffirstordermodelparametersPanel.Layout.Row = 4;
            app.DetailedanalysisoffirstordermodelparametersPanel.Layout.Column = [1 3];
            app.DetailedanalysisoffirstordermodelparametersPanel.FontWeight = 'bold';
            app.DetailedanalysisoffirstordermodelparametersPanel.FontSize = 18;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.DetailedanalysisoffirstordermodelparametersPanel);
            app.GridLayout5.ColumnWidth = {'1x', '1.4x', '1x'};
            app.GridLayout5.RowHeight = {'1x'};

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.GridLayout5);
            title(app.UIAxes3, '2nd order characteristics')
            xlabel(app.UIAxes3, 'Time (s)')
            ylabel(app.UIAxes3, 'Displacement (f=10^6N)')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.FontSize = 14;
            app.UIAxes3.Layout.Row = 1;
            app.UIAxes3.Layout.Column = 1;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout5);
            title(app.UIAxes2, 'Passenger movement history after landing')
            xlabel(app.UIAxes2, 'Time (s)')
            ylabel(app.UIAxes2, 'Displacement (m)')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 14;
            app.UIAxes2.Layout.Row = 1;
            app.UIAxes2.Layout.Column = 2;

            % Create UIAxes2_2
            app.UIAxes2_2 = uiaxes(app.GridLayout5);
            title(app.UIAxes2_2, 'Acceleration on passenger')
            xlabel(app.UIAxes2_2, 'Time (s)')
            ylabel(app.UIAxes2_2, 'Acceleration (m^2/s)')
            zlabel(app.UIAxes2_2, 'Z')
            app.UIAxes2_2.FontSize = 14;
            app.UIAxes2_2.Layout.Row = 1;
            app.UIAxes2_2.Layout.Column = 3;

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.ColumnWidth = {'0.4x', '1x'};
            app.GridLayout6.Layout.Row = 3;
            app.GridLayout6.Layout.Column = 1;
            app.GridLayout6.BackgroundColor = [0.702 1 0.702];

            % Create EnvironmentparametersLabel
            app.EnvironmentparametersLabel = uilabel(app.GridLayout6);
            app.EnvironmentparametersLabel.BackgroundColor = [0 1 0];
            app.EnvironmentparametersLabel.HorizontalAlignment = 'center';
            app.EnvironmentparametersLabel.FontSize = 18;
            app.EnvironmentparametersLabel.FontWeight = 'bold';
            app.EnvironmentparametersLabel.Layout.Row = 1;
            app.EnvironmentparametersLabel.Layout.Column = [1 2];
            app.EnvironmentparametersLabel.Text = 'Environment parameters';

            % Create v0msSliderLabel
            app.v0msSliderLabel = uilabel(app.GridLayout6);
            app.v0msSliderLabel.HorizontalAlignment = 'right';
            app.v0msSliderLabel.FontSize = 14;
            app.v0msSliderLabel.Layout.Row = 2;
            app.v0msSliderLabel.Layout.Column = 1;
            app.v0msSliderLabel.Text = 'v(0) (m/s)';

            % Create v0msSlider
            app.v0msSlider = uislider(app.GridLayout6);
            app.v0msSlider.Limits = [-1 0];
            app.v0msSlider.ValueChangedFcn = createCallbackFcn(app, @v0msSliderValueChanged, true);
            app.v0msSlider.MinorTicks = [-20 -15 -10 -5 0 5 10 15 20];
            app.v0msSlider.FontSize = 14;
            app.v0msSlider.Layout.Row = 2;
            app.v0msSlider.Layout.Column = 2;
            app.v0msSlider.Value = -1;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = aeroplanelanding_behaviour

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

