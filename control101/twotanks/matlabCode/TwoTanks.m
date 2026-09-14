classdef TwoTanks < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        TabGroup                    matlab.ui.container.TabGroup
        DefinetwotankparametersTab  matlab.ui.container.Tab
        GridLayout                  matlab.ui.container.GridLayout
        GridLayout2                 matlab.ui.container.GridLayout
        OpenloopparameterssimulationButton  matlab.ui.control.Button
        GridLayout6                 matlab.ui.container.GridLayout
        h1mEditFieldLabel           matlab.ui.control.Label
        h1mEditField                matlab.ui.control.NumericEditField
        A1mEditFieldLabel           matlab.ui.control.Label
        h1relEditField              matlab.ui.control.NumericEditField
        h1maxmEditField             matlab.ui.control.NumericEditField
        h1relEditFieldLabel         matlab.ui.control.Label
        a1mEditFieldLabel           matlab.ui.control.Label
        a1mEditField                matlab.ui.control.NumericEditField
        A1mEditField                matlab.ui.control.NumericEditField
        urelEditFieldLabel          matlab.ui.control.Label
        urelEditField               matlab.ui.control.NumericEditField
        h1maxmEditFieldLabel        matlab.ui.control.Label
        Label_7                     matlab.ui.control.Label
        Label_6                     matlab.ui.control.Label
        umaxmsEditFieldLabel        matlab.ui.control.Label
        umaxmsEditField             matlab.ui.control.NumericEditField
        tankparametersLabel         matlab.ui.control.Label
        tankparametersDropDown      matlab.ui.control.DropDown
        GridLayout7                 matlab.ui.container.GridLayout
        ParametersLabel             matlab.ui.control.Label
        Label_4                     matlab.ui.control.Label
        Label_3                     matlab.ui.control.Label
        RelativeliquidheightLabel   matlab.ui.control.Label
        LiquidheightLabel_2         matlab.ui.control.Label
        UIAxes5                     matlab.ui.control.UIAxes
        UIAxes4                     matlab.ui.control.UIAxes
        UIAxes                      matlab.ui.control.UIAxes
        UIAxes2                     matlab.ui.control.UIAxes
        ClosedloopsimulationTab     matlab.ui.container.Tab
        GridLayout_2                matlab.ui.container.GridLayout
        GridLayout2_2               matlab.ui.container.GridLayout
        CreateclosedloopresponsesButton  matlab.ui.control.Button
        GridLayout7_2               matlab.ui.container.GridLayout
        TextArea_3Label             matlab.ui.control.Label
        TextArea_4Label             matlab.ui.control.Label
        TextArea_4                  matlab.ui.control.TextArea
        TextArea_3                  matlab.ui.control.TextArea
        ParametersLabel_2           matlab.ui.control.Label
        GridLayout8                 matlab.ui.container.GridLayout
        Seth1h2EditField            matlab.ui.control.NumericEditField
        Label_2                     matlab.ui.control.Label
        Label                       matlab.ui.control.Label
        MLabel                      matlab.ui.control.Label
        GLabel                      matlab.ui.control.Label
        PSliderLabel                matlab.ui.control.Label
        ISliderLabel                matlab.ui.control.Label
        DSliderLabel                matlab.ui.control.Label
        DSlider                     matlab.ui.control.Slider
        ISlider                     matlab.ui.control.Slider
        PSlider                     matlab.ui.control.Slider
        SelectPIDparametersLabel    matlab.ui.control.Label
        TargetdepthofDropDownLabel  matlab.ui.control.Label
        TargetdepthofDropDown       matlab.ui.control.DropDown
        ControlScreen               matlab.ui.control.Label
        LiquidheightoftanksLabel    matlab.ui.control.Label
        CalculatedfiguresLabel      matlab.ui.control.Label
        UIAxes8                     matlab.ui.control.UIAxes
        UIAxes7                     matlab.ui.control.UIAxes
        UIAxes6                     matlab.ui.control.UIAxes
        Image_3                     matlab.ui.control.Image
        TwoTanksLabel_3             matlab.ui.control.Label
        Label_5                     matlab.ui.control.Label
    end


    properties (Access = private)
        color = 1; % Description
        originalsize;

        T1umax = 0.01;  % m3/s
        T1urel = 0.25;  % []
        T1A1 = 0.05;    % m2
        T1a1 = 0.001;   % m2
        T1H = 0.8;      % Description
        T1Hmax = 2;     % m
        T1hrel = 0.4;   % app.T1H / app.T1Hmax;     % []

        Viscosity = 1;  % [Ns/m2] (water)
        T2H = 1;        % Description
        T2Hmax = 2;     % m
        T2hrel = 0.5;   % app.T2H / app.T2Hmax;     % []
        T2A2 = 0.05;    % m2
        T2a2= 0.0005;   % m

        T1T = 0;        % Time constant of upper tank
        T2T = 0;        % Time constant of lower tank
        T1K = 0;        % Gain of upper tank
        T2K = 0;        % Gain of upper tank

        GU = zpk(tf(1,1));  % Transfer function of upper tanks
        GL = zpk(tf(1,1));  % Transfer function of kower tanks

        NewData = 1;    % Entered new 
        NewDispl = 0;   % Were new data displayed?
        beta1 = 0.1;   % app.T1umax/app.T1A1/app.T1Hmax;      % 1/s
        beta2 = 0.62641;% app.Viscosity*app.T1a1*sqrt(19.62)/app.T1A1/sqrt(app.T1Hmax);     % 1/s
        gamma1= 0.62642;% app.Viscosity*app.T1a1*sqrt(19.62)/app.T1A1/sqrt(app.T1Hmax);     % 1/s
        gamma2= 1.4765; % app.Viscosity*app.T2a2*sqrt(19.62)/app.T2A2/sqrt(app.T2Hmax);     % 1/s
      
        UpperTankSelected = 1; % Upper tank is visible
        Sliders = 0; % Value of one of the sliders  is changed
        Property31 % Description
        Property32 % Description
        Property33 % Description
        Property34 % Description
    end
    
  
    methods (Access = private)
       
    function xtank=tank22(app,~,x) 
        % input t is unused
        xtank1=[0 0];
        xtank1(1)=app.beta1*app.T1urel-app.gamma1*sqrt(x(1));
        xtank1(2)=app.beta2*sqrt(x(1))-app.gamma2*sqrt(x(2));
        xtank=[xtank1(1) xtank1(2)]';

    end % xtank='g',t,x)
        
                   
    function recalc(app)
        % Recalculate variables from 
        % umax, urel, A1, a1, A2, a2, h1max, h2max, viscosity

        %H1
        app.T1H = (app.T1umax*app.T1urel)/(app.Viscosity*app.T1a1);
        app.T1H = app.T1H * app.T1H / 19.62;

        %H2
        app.T2H = (app.T1umax*app.T1urel)/(app.Viscosity*app.T2a2);
        app.T2H = app.T2H * app.T2H / 19.62;

        %H1,2rel
        app.T1hrel = app.T1H/app.T1Hmax;
        app.T2hrel = app.T2H/app.T2Hmax;

        %Parameters for ODE
        app.beta1  = app.T1umax/(app.T1A1*app.T1Hmax);
        app.gamma1 = app.Viscosity*app.T1a1*sqrt(19.62)/(app.T1A1*sqrt(app.T1Hmax));
        app.beta2  = (app.Viscosity*app.T1a1*sqrt(19.62)*sqrt(app.T1Hmax))/(app.T2A2*app.T2Hmax);
        app.gamma2 = app.Viscosity*app.T2a2*sqrt(19.62)/(app.T2A2*sqrt(app.T2Hmax));

        % Time scalar of upper tank
        app.T1T = (app.T1umax*app.T1urel*app.T1A1)/...
             ((app.Viscosity*app.T1a1)* ...
             (app.Viscosity*app.T1a1)*9.81);

        % Time scalar of lower tank
        app.T2T = (app.T1umax*app.T1urel*app.T2A2)/...
             ((app.Viscosity*app.T2a2)* ...
             (app.Viscosity*app.T2a2)*9.81);
        
        %Gain
        K  = app.T1urel*app.T1umax*app.T1umax*app.T2A2/(app.T1A1*app.T1Hmax*9.81...
            *(app.Viscosity*app.T2a2)*(app.Viscosity*app.T2a2));

        %Gain of tanks
        app.T1K = app.T1umax/(app.T1A1*app.T1Hmax)*app.T1T;
        app.T2K = K/app.T1K;

        % Upper and lower transfer funcion
        s=zpk('s');
        app.GU = app.T1K/(1+s*app.T1T);    % Upper tank
        app.GL = app.T2K/(1+s*app.T2T);    % Lower tank

        app.NewData = 0;

    end
        
    function DispData(app)
    % display basic and calculated figures on both sheets
    % 1st text window of Check and create parameters    
        app.Label_3.Text = "Upper tank"+newline  ...
        +"umax = "+app.T1umax+" m³/s"+newline ...
        +"urel = "+round(app.T1urel,3)+newline ...
        +"A1 = "+app.T1A1+" m²"+newline  ...
        +"a1 = "+app.T1a1+" m²"+newline  ...
        +"h1max = "+round(app.T1Hmax,3)+" m"+newline ...           
        +"h1 = "+round(app.T1H,3)+" m"+newline ...
        +"h1rel = "+round(app.T1hrel,3)+newline ...
        +"β1="+round(app.beta1,4)+" 1/s "+newline+"β2="+round(app.beta2,4)+" 1/s "+newline ...
        +"γ1="+round(app.gamma1,4)+" 1/s "+newline+"γ2="+round(app.gamma2,4)+" 1/s ";
        
    % 2nd text window of Check and create parameters
        app.Label_4.Text = "Lower tank"+newline  ...
        +"Viscosity = "+app.Viscosity+" Ns/m²"+newline ...
        +"A2 = "+app.T2A2+" m²"+newline ...
        +"a2 = "+app.T2a2+" m²"+newline ...
        +"h2max = "+round(app.T2Hmax,3)+" m"+newline ...
        +"h2 = "+round(app.T2H,3)+" m"+newline ...
        +"h2rel = "+round(app.T2hrel,3)+newline ...
        +"T1 = "+round(app.T1T,2)+" s"+newline ...
        +"T2 = "+round(app.T2T,2)+" s"+newline ...
        +"K = "+round(app.T1K * app.T2K,2)+" s/m²" ;

    %copy values to Create closed loop sheet
        app.TextArea_3.Value =app.Label_3.Text;
        app.TextArea_4.Value =app.Label_4.Text;

    %copy values to Upper tank or Lower tank window
        if app.UpperTankSelected == 1 
            app.Label_7.Text = ''; %'Upper tank';

            if app.T1urel * app.T1umax * app.T1a1 * app.T1Hmax> 0
                app.h1mEditField.Value = app.T1H;
                app.h1relEditField.Value = app.T1hrel;
                if app.T1hrel > 1
                    app.h1relEditFieldLabel.Text = 'h1rel [] < 1';
                    app.h1relEditFieldLabel.FontColor = 'r';
                    app.h1relEditField.FontColor = 'r';
                else 
                    app.h1relEditFieldLabel.Text = 'h1rel []';
                    app.h1relEditFieldLabel.FontColor = 'k';
                    app.h1relEditField.FontColor = 'k';
                end
            end
        else
            app.Label_7.Text = ''; %'Lower tank';
            if app.T1urel * app.T1umax * app.T2a2 * app.T2Hmax > 0
                app.h1mEditField.Value = app.T2H;
                app.h1relEditField.Value = app.T2hrel;
                if app.T2hrel > 1
                    app.h1relEditFieldLabel.Text = 'h2rel [] < 1';
                    app.h1relEditFieldLabel.FontColor = 'r';
                    app.h1relEditField.FontColor = 'r';
                else 
                    app.h1relEditFieldLabel.Text = 'h2rel []';
                    app.h1relEditFieldLabel.FontColor = 'k';
                    app.h1relEditField.FontColor = 'k';
                end
            end
        end

    end
        
        function results = Roots2Str(~,n)
            % This function convert roots to transfer function form
            % Inputs:
            % n: vector of roots
            % v: type of variables (continouos or discrete)
            % Output:
            % Equation of transfer function
            % Example: results = Roots2Str({-1, -2}, 's')
            %   Result: '(s+1)(s+2)'

            a=size(n);
            a=a(1);
            Z=zeros(a,1);

            for i=1:a
                Z(i)=n(i);
            end
            n=Z;
            v="s";

            % sorting roots
            n=sort(n);
            if ~isempty(n)
                bbb="";
                i=1;
                while i <= length(n)
                    j=0;
                    % Same roots?
                    for k=1:length(n)-i
                        if abs(n(i) - n(i+k)) <  1E-7 && abs(imag(n(i))) < 1E-7 && abs(imag(n(i+1))) < 1E-7
                            j=j+1;
                        end
                    end
                    if n(i) == Inf
                        bbb=bbb;
                    elseif abs(n(i)) < 1E-7
                        bbb=bbb+" s";
                    else
                        if real(n(i)) < 0
                            c= "+";
                        else
                            c= "-";
                        end

                        if abs(imag(n(i))) <  1E-7
                            if abs(n(i)) > 1E-7
                                if bbb == "1"
                                    bbb=" (1" + c + round(abs(n(i)),2) + v + ")";
                                else
                                    bbb=bbb+" (1" + c + round(abs(n(i)),2) + v + ")";
                                end
                            end
                        else
                            bbb=bbb+ " (1" +c+ round(2*abs(real(n(i))),2)+v+"+"+round((real(n(i))*real(n(i))+imag(n(i))*imag(n(i))),2)+ v+ "^2)";
                        end
                    end

                    if j>0
                        if j+1 ~= 1
                            bbb=bbb+('^')'+(j+1)+" ";
                        end 
                    end

                    if imag(n(i)) ~= 0
                        i=i+j+j+2;
                    else
                        i=i+j+1;
                    end
                end     % while

                results = bbb;

            else
                % In case of empty input
                results="1";
            end
        end
        
        function results = outstr(app,tf)
            % create transfer funcion image in a/b form
            K=tf.K;
            zi=1;
            n=0;
            if isempty(tf.Z{1})
                Z=Inf;
            else
                n=size(tf.Z{1});
                n=n(1);
                Z=zeros(n,1);
                for i=1:n
                    Z(i)=tf.Z{1}(i);
                    if abs(Z(i)) > 1E-7
                        zi=zi*Z(i);
                        Z(i)=1/Z(i);
                    end
                    zi=abs(zi);
                end
            end

            m=0;
            if isempty(tf.P{1})
                P=1;
            else
                m=size(tf.P{1});
                m=m(1);
                P=zeros(m,1);
                pi=1;
                for i=1:m
                    P(i)=tf.P{1}(i);
                    if abs(P(i)) > 1E-7
                        pi=pi*P(i);
                        P(i) = 1/P(i);
                    end
                end
                pi=abs(pi);
                K=K*zi/pi;
            end

            qwe = Roots2Str(app,Z);
            qwe2 = Roots2Str(app,P);

            results = "\frac{"+round(K,2)+" "+qwe+"}{"+qwe2+"}";
            % ostr = "\frac{"+round(K,2)+" "+qwe+"}{"+qwe2+"}";
           
        end
        
    end % methods

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function StartupFcn(app)
            clc
            % resize to be in middle of  the window
            movegui(app.UIFigure)
            winopen("TwoTank.pdf" );
            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);
 
            % start with 1st sheet and display data
            UpperTankButtonPushed(app);
            recalc(app);
            DispData(app);

        end

        % Size changed function: UIFigure
        function UIFigureSizeChanged(app, event)
           % This function is copied from Rossiter's materials
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

        % Callback function
        function UpperTankButtonPushed(app, event)
            app.UpperTankSelected = 1;
            app.urelEditField.Visible = 'on';

            % Create UppertankLabel
            app.Label_7.Text = 'Upper tank';

            % Create Tapm3sEditFieldLabel
            app.umaxmsEditFieldLabel.Text = 'umax [m³/s]';
            app.urelEditFieldLabel.Text = 'urel []';
            app.A1mEditFieldLabel.Text = 'A1  [m²]';
            app.a1mEditFieldLabel.Text = 'a1 [m²]';
            app.h1maxmEditFieldLabel.Text = 'h1max [m]';
            app.h1mEditFieldLabel.Text = 'h1 [m]';
            app.h1relEditFieldLabel.Text = 'h1rel []';

            %copy figures to edit fields of Upper tank
            app.umaxmsEditField.Value = app.T1umax;
            app.urelEditField.Value = app.T1urel;
            app.A1mEditField.Value = app.T1A1;
            app.a1mEditField.Value = app.T1a1;
            app.h1maxmEditField.Value = app.T1Hmax;
            app.h1mEditField.Value = app.T1H;
            app.h1relEditField.Value = app.T1hrel;

        end

        % Callback function
        function LowerTankButtonPushed(app, event)
            % Create LowertankLabel
            app.UpperTankSelected = 0;
            app.urelEditField.Visible = 'off';
            app.Label_7.Text = ''; %'Lower tank';

            % Create Tapm3sEditFieldLabel
            app.umaxmsEditFieldLabel.Text = 'Viscosity [Ns/m²]';
            app.A1mEditFieldLabel.Text = 'A2 [m²]';
            app.a1mEditFieldLabel.Text = 'a2 [m²]';
            app.h1maxmEditFieldLabel.Text = 'h2max [m]';
            app.h1mEditFieldLabel.Text = 'h2 [m]';
            app.h1relEditFieldLabel.Text = 'h2rel []';
            app.urelEditFieldLabel.Text = ' ';

            %copy figures to edit fields of Lower tank
            app.umaxmsEditField.Value = app.Viscosity;
            app.urelEditField.Value = 0;
            app.A1mEditField.Value = app.T2A2;
            app.a1mEditField.Value = app.T2a2;
            app.h1maxmEditField.Value = app.T2Hmax;

            app.h1mEditField.Value = app.T2H;
            app.h1relEditField.Value = app.T2hrel;


        end

        % Button pushed function: OpenloopparameterssimulationButton
        function TwoTanksSimulation(app, event)
            % '---------------------------- SIMULATION --------------------'
            % TwoTanks sheet -> Update button
            % Data recalculation
            recalc(app);

            % Sliders set to 0
            app.PSlider.Value = 0;
            app.ISlider.Value = 0;
            app.DSlider.Value = 0;

            % Create transfer funcions
            W1=app.GU;
            W1.DisplayFormat ='timeconstant';
            W2=app.GL;
            W2.DisplayFormat ='timeconstant';
            Ws=W1*W2;
            Ws.DisplayFormat ='timeconstant';
            
            % Round and set simulation time
            Tmax = 5*(max(app.T1T,app.T2T));
            n=1; 
            while( Tmax/n > 1) 
                n=n*10; 
            end
            n=n/10; 
            i=n*fix(Tmax/n); 
            if (Tmax*1.25 > i) 
                i=i+n; 
            end 
            Tmax=i;
            
            % Start simulation with ODE23 
            % Funcion tank22 uses recalculated parameters
            [t,x] = ode23(@(t,x) tank22(app,t,x),[0; Tmax],[0;0]);
            Y3 = x(:,1);
            Y4 = x(:,2);
            
            % Calculate settling time
            s=zpk('s');
            Y1=Y3*app.T1Hmax;
            Y1set=stepinfo(app.T1K/(1+s*app.T1T));
            Y2=Y4*app.T2Hmax;
            Y2set=stepinfo(app.T1K*app.T2K/(1+s*app.T1T)/(1+s*app.T2T));

            % Display data
            cla(app.UIAxes);
            cla(app.UIAxes2);
            cla(app.UIAxes4);
            cla(app.UIAxes5);

            % Axes X
            app.UIAxes.XLim = [0 Tmax];
            app.UIAxes2.XLim = [0 Tmax];

            app.UIAxes6.XLim = [0 Tmax];
            app.UIAxes7.XLim = [0 Tmax];

            app.UIAxes.XTickLabel = 0:Tmax/4:Tmax;
            app.UIAxes.XTick = 0:Tmax/4:Tmax;

            app.UIAxes2.XTickLabel = 0:Tmax/4:Tmax;
            app.UIAxes2.XTick = 0:Tmax/4:Tmax;

            A=max(app.T1A1,app.T2A2);
            app.UIAxes4.XLim = [0 A];
            app.UIAxes4.XTick = [0 app.T1A1];
            app.UIAxes4.XTickLabel = [0 app.T1A1];
                
            app.UIAxes5.XLim = [0 A];
            app.UIAxes5.XTick = [0 app.T2A2];
            app.UIAxes5.XTickLabel = [0 app.T2A2];

            % Axes Y
            Y1max = max(round(1.3*max(Y1),1),0.2);
            Y2max = max(round(1.3*max(Y2),1),0.2);


            app.UIAxes.YLim  = [0 Y1max];
            app.UIAxes2.YLim = [0 Y2max];

            app.UIAxes.YTickLabel  = 0:Y1max/4:Y1max;
            app.UIAxes.YTick       = 0:Y1max/4:Y1max;
            app.UIAxes2.YTickLabel = 0:Y2max/4:Y2max;
            app.UIAxes2.YTick      = 0:Y2max/4:Y2max;

            app.UIAxes4.YLim = [0 120];
            app.UIAxes5.YLim = [0 100];

            hold(app.UIAxes,'on');
            hold(app.UIAxes2,'on');

            grid(app.UIAxes,"on");
            grid(app.UIAxes2,"on");
            
            hold(app.UIAxes4,'on');
            hold(app.UIAxes5,'on');
            
            grid(app.UIAxes4,'on');
            grid(app.UIAxes5,'on');


            % Display results
            % Dark blue means water in each axis
            % Process is slow to see results
            for k=1:length(Y3)-1

                plot(app.UIAxes,  [t(k) t(k+1)],[Y1(k) Y1(k+1)],'g','LineWidth',2);
                plot(app.UIAxes2, [t(k) t(k+1)],[Y2(k) Y2(k+1)],'r','LineWidth',2);

                % plot(app.UIAxes, [t(k) t(k+1)],[Y3(k) Y3(k+1)],'b','LineWidth',2);
                % plot(app.UIAxes2,[t(k) t(k+1)],[1.1*Y4(k) 1.1*Y4(k+1)],'b','LineWidth',2);

                ytag = fill(app.UIAxes4,[0 0 app.T1A1 app.T1A1],[100*Y3(2),0,0,100*Y3(2)],'b');  
                set(ytag,'Ydata',[1 0 0 1]*100*Y3(k));

                ytag = fill(app.UIAxes5,[0 0 app.T2A2 app.T2A2 app.T1A1],[100*Y4(2),0,0,100*Y4(2),0],'b');  
                set(ytag,'Ydata',[1 0 0 1]*100*Y4(k));

                pause(0.2); 
            end

            legend(app.UIAxes4,    "h1 = "+round(app.T1H,2)+" m"+newline ...
            +"h1rel = "+100*round(app.T1hrel,4)+"%"+newline ...
            ,'FontSize',14,"AutoUpdate","off");
            legend(app.UIAxes5,    "h2 = "+round(app.T2H,2)+" m"+newline+"h2rel = "+100*round(app.T2hrel,4)+"%"+newline,'FontSize',14,"AutoUpdate","off");

            aux = "Settling time: "+round(Y1set.SettlingTime,2)+" sec";
            legend(app.UIAxes,aux,'FontSize',12,"AutoUpdate","off");
            aux = "Settling time: "+round(Y2set.SettlingTime,2)+" sec";
            legend(app.UIAxes2,aux,'FontSize',12,"AutoUpdate","off");


            hold(app.UIAxes,'off');
            hold(app.UIAxes2,'off');

            hold(app.UIAxes4,'off');
            hold(app.UIAxes5,'off');

            % Display has done
            app.NewDispl = 1;
            clc;

        end

        % Button pushed function: CreateclosedloopresponsesButton
        function CreateclosedloopresponsesButtonPushed(app, event)
            % '---------------------------- CONTROLLER --------------------'
            % TwoTanks Controller sheet -> Create controller button

        % Clear axes and controll window
        cla(app.UIAxes6);    
        cla(app.UIAxes7);    
        cla(app.UIAxes8);
        app.ControlScreen.FontSize = 14;
        app.ControlScreen.FontColor = [0 0 0]; % black
        app.ControlScreen.Text = " ";

        if app.Sliders == 0
            app.PSlider.Value = 0;
            app.ISlider.Value = 0;
            app.DSlider.Value = 0;
        end
        app.Sliders = 0;

        % If the final changes are made and displayed as well as none of the tanks are overflowing
        if app.NewData == 0 && app.NewDispl == 1 && app.T1hrel <= 1 || app.T2hrel <= 1                                               
            W1=app.GU;
            W1.DisplayFormat ='timeconstant';
            W2=app.GL;
            W2.DisplayFormat ='timeconstant';
            
            % Display process
            aux1="$\frac{"+round(app.T1K*app.T2K,2)+"}{(1+"+round(app.T1T,2)+"s)(1+"+round(app.T2T,2)+"s)}$";
            app.Label.FontName ="Arial";
            app.Label.FontSize = 14;
            app.Label.Text = aux1;

            % Processing changes around the working point if h1 is selected
            if app.TargetdepthofDropDown.Value == "h1"
                h1new = app.Seth1h2EditField.Value;
                if h1new < 0.001
                    h1new=0.001;
                end
                h1relnew = h1new / app.T1Hmax;
                urelnew = sqrt(h1new * ((app.Viscosity*app.T1a1)*(app.Viscosity*app.T1a1)*19.62)/(app.T1umax * app.T1umax));
                h2new = app.T1umax*urelnew*app.T1umax*urelnew/((app.Viscosity*app.T2a2)*(app.Viscosity*app.T2a2)*19.62);
                h2relnew = h2new / app.T2Hmax;
                app.DSlider.Value = 0;
            else
            % Processing changes around the working point if h2 is selected
                h2new = app.Seth1h2EditField.Value;
                if h2new < 0.001
                    h2new=0.001;
                end
                h2relnew = h2new / app.T2Hmax;
                urelnew = app.Viscosity*app.T2a2*sqrt(19.62*h2new)/app.T1umax  ;
                h1new = app.T1umax*urelnew*app.T1umax*urelnew/((app.Viscosity*app.T1a1)*(app.Viscosity*app.T1a1)*19.62);
                h1relnew = h1new / app.T1Hmax;
            end

            % Create error messages if any
            if h1relnew > 1 || h2relnew > 1
                if h1relnew > 1
                    rel1="≥";
                else 
                    rel1="≤";
                end

                if h2relnew > 1
                    rel2="≥";
                else 
                    rel2="≤";
                end
                
                if h1relnew > 1
                    app.ControlScreen.Text = [ "Overflow" ; "Check upper tank."; "H1: "+h1new+"m  "+rel1+"   H1max: "+app.T1Hmax+"m !!!"; "H2: "+h2new+"m  "+rel2+" H2max: "+app.T2Hmax+"m"];
                    app.ControlScreen.FontColor = [1 0 0]; % red
                else 
                    app.ControlScreen.Text = [ "Overflow" ; "Check lower tank."; "H1: "+h1new+"m  "+rel1+"   H1max: "+app.T1Hmax+"m"; "H2: "+h2new+"m  "+rel2+" H2max: "+app.T2Hmax+"m !!!"];
                    app.ControlScreen.FontColor = [1 0 0]; % red
                end

                return;
           end

           if h2relnew > 1
                app.ControlScreen.FontColor = [1 0 0]; % red
                app.ControlScreen.Text = [ "Overflow" ; "Check lower tank."; "H2: "+h2new+"m  "+rel2+" H2max: "+app.T2Hmax+"m !!!"];
                return;
            end

            % Set simulation time
            Tmax=app.UIAxes6.XLim(2);

            % calculate new working point with ODE
            aux=app.T1urel;
            app.T1urel = urelnew;
            [t12,x12] = ode23(@(t12,x12) tank22(app,t12,x12),[0; Tmax],[app.T1hrel;app.T2hrel]);

            y1 = app.T1Hmax * x12(:,1);
            y2 = app.T2Hmax * x12(:,2);
            app.T1urel = aux;

            % If the sliders are in the default position, 
            % display new controller parameters calculated below 
            if app.PSlider.Value < 1E-7 && app.ISlider.Value < 1E-7 && app.DSlider.Value < 1E-7
                app.PSlider.Value = 1;
                if app.TargetdepthofDropDown.Value == "h1"
                    app.ISlider.Value = min(max(0,app.T1T),100);
                else
                    app.ISlider.Value = min(max(0,app.T2T),100);
                end
                app.DSlider.Value = 0;
            end
  
            % Set new parameters
            TCK = app.PSlider.Value;
            TC2 = app.ISlider.Value;
            TC1 = app.DSlider.Value;
            

            % Create transfer funcion of the controller
            s=zpk('s');
            if TC1 < 1E-7
                Wc = minreal((1+TC2*s)/(TC2*s));
            else
                if app.TargetdepthofDropDown.Value == "h1"
                    Wc = minreal((1+TC2*s)/(TC2*s));
                else
                    if TC2 < 1E-7
                        Wc = minreal((1+TC1*s)/(TC1*s));
                    else
                        Wc = minreal((1+TC2*s)/(TC2*s)*(1+TC1*s)/(1+TC1/3*s));
                    end
                end
            end

            if TC1 < 1E-7 && TC2 < 1E-7
                Wc = tf(1,1);
            else 
                Wc.DisplayFormat ='timeconstant';
            end
            
            
            % Check stability of the new closed system
            aTCK=margin(Wc*W1*W2);
            [auxA, auxf, ~]=bode(Wc*W1*W2);

            if (isnan(aTCK) || isinf(aTCK) )
                if TCK < 1E-7
                    TCK=3.14;
                    app.PSlider.Value = TCK;
                end
            else % ~(isnan(aTCK) || isinf(aTCK) )
                n=0;
                for i=1:length(auxf) 
                    if auxf(i) > -120   % auf(0) = pi/2, look at the denominator of the controller
                        n=i;
                    end
                end
                
                if n==0     % no value over -120°
                    app.ControlScreen.Text = [ "Error" ; "No P for the controller"];
                    return;
                end
                
                % New value of gain
                if TCK < 1E-7 
                    TCK=1/auxA(n);
                end

            end

            % Set I slider
            if TC2 < 1E-7
                TC2 = app.ISlider.Value;
            end

            % Display transfer funcion of the controller
            if  TC1 < 1E-7 && TC2 < 1E-7
                aux="${"+round(TCK,2)+"}$";
            elseif TC1 < 1E-7
                aux="$\frac{"+round(TCK,2)+"(1+"+round(TC2,2)+"s)}{"+round(TC2,2)+"s}$";
            elseif TC2 < 1E-7
                aux="$\frac{"+round(TCK,2)+"(1+"+round(TC1,2)+"s)}{1+"+round(TC1/3,2)+"s}$";
            else
                aux = "$\frac{"+round(TCK,2)+"(1+"+round(TC2,2)+"s)"+"(1+"+round(TC1)+"s)}{"+round(TC2,2)+" s"+"(1+"+round(TC1/3,2)+"s)}$";
            end
           
            app.Label_2.FontName ="Arial";
            app.Label_2.FontSize = 14;
            app.Label_2.Text = aux;

            Wc=TCK*Wc;

            % Calclating outputs 
            wc=Wc;
            % wc.DisplayFormat='timeconstant';
            w1=app.T1K/(1+app.T1T*s);
            w1.DisplayFormat='timeconstant';
            w2=app.T2K/(1+app.T2T*s);
            w2.DisplayFormat='timeconstant';
                        
            if app.TargetdepthofDropDown.Value == "h1"
                W0=minreal(wc/(1+wc*w1));
                W1=minreal((wc*w1)/(1+wc*w1));
                W=minreal((wc*w1*w2)/(1+wc*w1));
                [y3,t]=step((h1relnew-app.T1hrel)*W0,Tmax);
                y4=step((h1relnew-app.T1hrel)*W1,t);
                W2=(h1relnew-app.T1hrel)*W;
                y5=step((h1relnew-app.T1hrel)*W,t);
            else
                W0=minreal(wc/(1+wc*w1*w2));
                W1=minreal((wc*w1)/(1+wc*w1*w2));
                W=minreal((wc*w1*w2)/(1+wc*w1*w2));
                [y3,t]=step((h2relnew-app.T2hrel)*W0,Tmax);
                y4=step((h2relnew-app.T2hrel)*W1,t);
                W2=(h2relnew-app.T2hrel)*W;
                y5=step((h2relnew-app.T2hrel)*W,t);
            end

            % Change relative values to real values 
            y3 = app.T1umax * (y3 + app.T1urel);
            y4 = app.T1Hmax * (y4 + app.T1hrel);
            y5 = app.T2Hmax * (y5 + app.T2hrel);

            % Saturation: 
            y3 = min(max(y3,0),app.T1umax);
            y4 = min(max(y4,0),app.T1Hmax);
            y5 = min(max(y5,0),app.T2Hmax);
            
            % Display results
            % Green indicates results without controller and
            % red shows results around the working point(?)
            % Range of working point is not defined!!!!!
            cla(app.UIAxes6);
            hold(app.UIAxes6,'on');

            app.UIAxes6.XLim = [0 Tmax];
            app.UIAxes6.XTickLabel = round(0:Tmax/4:Tmax,3);
            app.UIAxes6.XTick = 0:Tmax/4:Tmax;
            
            plot(app.UIAxes6, t12,y1,'g','LineWidth',2);
            plot(app.UIAxes6,  t,y4,'r','LineWidth',2);

            if app.TargetdepthofDropDown.Value == "h1"
                plot(app.UIAxes6,  [0, Tmax] ,[h1new, h1new],'b- ','LineWidth',1);
                aux = [ "Without controller", "With controller", "Target" ];
            else 
                aux = [ "Without controller", "With controller" ];
            end
            legend(app.UIAxes6,aux,'FontSize',12);            

            hold(app.UIAxes6,'off'); 
            

            cla(app.UIAxes7);
            hold(app.UIAxes7,'on');

            app.UIAxes7.XLim = [0 Tmax];
            app.UIAxes7.XTickLabel = 0:Tmax/4:Tmax;
            app.UIAxes7.XTick = 0:Tmax/4:Tmax;
            
            plot(app.UIAxes7, t12,y2,'g','LineWidth',2);
            plot(app.UIAxes7,  t,y5,'r','LineWidth',2);

            if app.TargetdepthofDropDown.Value == "h2"
                plot(app.UIAxes7,  [0, Tmax] ,[h2new, h2new],'b- ','LineWidth',1);
                aux = [ "Without controller", "With controller", "Target" ];
            else 
                aux = [ "Without controller", "With controller" ];
            end
            legend(app.UIAxes7,aux,'FontSize',12);            

            hold(app.UIAxes7,'off');


            cla(app.UIAxes8);
            hold(app.UIAxes8,'on');
            app.UIAxes8.XLim = [0 Tmax];
            app.UIAxes8.XTickLabel = 0:Tmax/4:Tmax;
            app.UIAxes8.XTick = 0:Tmax/4:Tmax;
            plot(app.UIAxes8,  t,y3,'r','LineWidth',2);

            hold(app.UIAxes8,'off');

            if app.DSlider.Value > 0
                app.ControlScreen.FontSize = 10;
            end
            aux0 = "With controller:";
            aux1 = "$Yc(s) = "+outstr(app,W0)+"$";
            aux2 = "$Yu(s) = "+outstr(app,W1)+"$";
            aux3 = "$Y(s) = Yl(s) = "+outstr(app,W)+"$";

            T1new = app.T1T *urelnew / app.T1urel;
            T2new = app.T2T *urelnew / app.T1urel;
            K1new = app.T1K * T1new / app.T1T;
            Knew = app.T1K * app.T2K * urelnew / app.T1urel;


            % If new system is unstable (There are positive poles)
            pp=pzmap(W2);
            for i=1:length(pp)
                if real(pp(i)) > 0
                    app.ControlScreen.FontSize = 12;
                    WW=minreal(W2)
                    app.ControlScreen.Text = [ "Error: Closed system is unstable"; "$Y(s) = Yl(s) = "+outstr(app,WW)+"$"];
                    clc;
                    return;                    
                end
            end

            
            aux4 = "Without controller:";
            aux5 = "$Yu(s) = \frac{"+round(K1new,2)+"}{(1+"+round(T1new,2)+"s)}$";
            aux6 = "$Yl(s) = \frac{"+round(Knew,2)+"}{(1+"+round(T1new,2)+"s)(1+"+round(T2new,2)+"s)}$";
            aux=[aux0; aux1; aux2; aux3; aux4; aux5; aux6];

            app.ControlScreen.Text = aux;
%-------------------
            % Update Create closed loop responses text fields βγ
            app.TextArea_3.Value = "Upper tank"+newline  ...
            +"umax = "+app.T1umax+" m³/s"+newline ...
            +"urel = "+round(100*urelnew,2)+"%"+newline ...
            +"A1 = "+app.T1A1+" m²"+newline  ...
            +"a1 = "+app.T1a1+" m²"+newline  ...
            +"h1max = "+round(app.T1Hmax,3)+" m"+newline ...           
            +"h1 = "+round(h1new,3)+" m"+newline ...
            +"h1rel = "+round(100*h1relnew,2)+"% "+newline ...
            +"β1="+round(app.beta1,4)+" 1/s"+newline+"β2="+round(app.beta2,4)+" 1/s"+newline ...
            +"γ1="+round(app.gamma1,4)+" 1/s"+newline+"γ2="+round(app.gamma2,4)+" 1/s";
            
            app.TextArea_4.Value = "Lower tank"+newline  ...
            +"Viscosity = "+app.Viscosity+" Ns/m²"+newline ...
            +"A2 = "+app.T2A2+" m²"+newline ...
            +"a2 = "+app.T2a2+" m²"+newline ...
            +"h2max = "+round(app.T2Hmax,3)+" m"+newline ...
            +"h2 = "+round(h2new,3)+" m"+newline ...
            +"h2rel = "+round(100*h2relnew,2)+"% "+newline ...
            +"T1 = "+round(T1new,2)+" s"+newline ...
            +"T2 = "+round(T2new,2)+" s"+newline ...
            +"K = "+round(Knew,2)+" s/m²";
 
        else 
            % In case of error: New data are not updated
            if abs(app.NewData) > 1E-7 
                app.ControlScreen.Text = [ "First run Define two tank parameters sheet." ; "Its results are necessaryfor this sheet."];
            end

            % In case of error: New data are not displayed
            if abs(app.NewDispl-1) > 1E-7 
                app.ControlScreen.Text = [ "First run Define two tank parameters sheet." ; "Its results are necessaryfor this sheet."];
            end

            % In case of error: Upper tank overflowed
            if app.T1hrel > 1
                if app.T2hrel > 1
                    rel2="> ";
                else
                    rel2="<=";
                end
                app.ControlScreen.Text = [ "Overflow" ; "Check upper tank."; "H1: "+app.T1H +" > H1max: "+app.T1Hmax; "H2: "+app.T2H+" "+rel2+" H2max: "+app.T2Hmax];
            end

            % In case of error: Lower tank overflowed
            if app.T2hrel > 1
                if app.T1hrel > 1
                    rel1="> ";
                else
                    rel1="<=";
                end
                app.ControlScreen.Text = [ "Overflow" ; "Check lower tank."; "H1: "+app.T1H+" "+rel1+" H1max: "+app.T1Hmax; "H2: "+app.T2H+" > H2max: "+app.T2Hmax];
            end

        end
        clc;

        end

        % Value changed function: umaxmsEditField
        function umaxChanged(app, event)
            value = app.umaxmsEditField.Value;
            if app.UpperTankSelected == 1 
                app.T1umax = value;
            else
                app.Viscosity = value;
            end
            recalc(app);
            DispData(app);
            app.NewData = 1;    % There are new data
            app.NewDispl = 0;   % They are not displayed 
        end

        % Value changed function: urelEditField
        function urelChanged(app, event)
            value = app.urelEditField.Value;
            if app.UpperTankSelected == 1 
                app.T1urel = value;
            end
            recalc(app);
            DispData(app);
            app.NewData = 1;
            app.NewDispl = 0;
        end

        % Value changed function: A1mEditField
        function A1Changed(app, event)
            value = app.A1mEditField.Value;
            if app.UpperTankSelected == 1 
                app.T1A1 = value;
            else
                app.T2A2 = value;
            end
            recalc(app);
            DispData(app);
            app.NewData = 1;
            app.NewDispl = 0;
        end

        % Value changed function: a1mEditField
        function a1Changed(app, event)
            value = app.a1mEditField.Value;
            if app.UpperTankSelected == 1 
                app.T1a1 = value;
            else
                app.T2a2 = value;
            end
            recalc(app);
            DispData(app);
            app.NewData = 1;
            app.NewDispl = 0;
        end

        % Value changed function: h1maxmEditField
        function h1maxChanged(app, event)
            value = app.h1maxmEditField.Value;
            if app.UpperTankSelected == 1 
                app.T1Hmax =  value; % m
            else 
                app.T2Hmax =  value; % m
            end
            recalc(app);
            DispData(app);
            app.NewData = 1;
            app.NewDispl = 0;
        end

        % Value changed function: PSlider
        function PSliderChanged(app, event)
            % value = app.PSlider.Value;
            app.Sliders = 1;
            CreateclosedloopresponsesButtonPushed(app);
        end

        % Value changed function: ISlider
        function ISliderChanged(app, event)
            % value = app.ISlider.Value;
            app.Sliders = 1;
            CreateclosedloopresponsesButtonPushed(app);
        end

        % Value changed function: DSlider
        function DSliderChanged(app, event)
            % value = app.DSlider.Value;
            app.Sliders = 1;
            CreateclosedloopresponsesButtonPushed(app);
        end

        % Value changed function: Seth1h2EditField
        function H1H2Changed(app, event)
            value = app.Seth1h2EditField.Value;
            app.PSlider.Value = 0;
            app.ISlider.Value = 0;
            app.DSlider.Value = 0;
            app.Label_2.Text = " ";
            if app.TargetdepthofDropDown.Value == "h1"
                if app.Seth1h2EditField.Value > app.T1Hmax    
                   app.Seth1h2EditField.Value = 0;
                end
            else
                if app.Seth1h2EditField.Value > app.T2Hmax    
                   app.Seth1h2EditField.Value = 0;
                end
            end
        end

        % Value changed function: tankparametersDropDown
        function TankParametersChanged(app, event)
            value = app.tankparametersDropDown.Value;
            if value == 'Upper'
                UpperTankButtonPushed(app);
            else
                LowerTankButtonPushed(app);
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
            app.UIFigure.Position = [100 100 1108 868];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create Label_5
            app.Label_5 = uilabel(app.UIFigure);
            app.Label_5.BackgroundColor = [0.6 1 1];
            app.Label_5.Position = [13 751 839 83];
            app.Label_5.Text = '';

            % Create TwoTanksLabel_3
            app.TwoTanksLabel_3 = uilabel(app.UIFigure);
            app.TwoTanksLabel_3.BackgroundColor = [0 1 1];
            app.TwoTanksLabel_3.HorizontalAlignment = 'center';
            app.TwoTanksLabel_3.Position = [60 769 713 47];
            app.TwoTanksLabel_3.Text = 'Control and behaviour of a two tank system';

            % Create Image_3
            app.Image_3 = uiimage(app.UIFigure);
            app.Image_3.Position = [862 755 159 74];
            app.Image_3.ImageSource = fullfile(pathToMLAPP, 'bme_cimer.png');

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.AutoResizeChildren = 'off';
            app.TabGroup.Position = [12 20 1008 704];

            % Create DefinetwotankparametersTab
            app.DefinetwotankparametersTab = uitab(app.TabGroup);
            app.DefinetwotankparametersTab.Title = 'Define two tank parameters';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.DefinetwotankparametersTab);
            app.GridLayout.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout.RowHeight = {'0.4x', '2.2x', '2x'};

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout);
            title(app.UIAxes2, 'Lower tank')
            xlabel(app.UIAxes2, 'Time [s]')
            ylabel(app.UIAxes2, 'Liquid height [m]')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.Layout.Row = 3;
            app.UIAxes2.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Upper tank')
            xlabel(app.UIAxes, 'Time [s]')
            ylabel(app.UIAxes, 'Liquid height [m]')
            app.UIAxes.XTick = [0 1 2];
            app.UIAxes.XTickLabel = {'0'; '5'};
            app.UIAxes.YTick = 1;
            app.UIAxes.YTickLabel = {'0.5'};
            app.UIAxes.ZTick = [];
            app.UIAxes.Layout.Row = 2;
            app.UIAxes.Layout.Column = 2;

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.GridLayout);
            title(app.UIAxes4, 'Upper tank')
            xlabel(app.UIAxes4, 'A [m²]')
            ylabel(app.UIAxes4, 'Relative liquid height [%]')
            zlabel(app.UIAxes4, 'Z')
            app.UIAxes4.Layout.Row = 2;
            app.UIAxes4.Layout.Column = 3;

            % Create UIAxes5
            app.UIAxes5 = uiaxes(app.GridLayout);
            title(app.UIAxes5, 'Lower tank')
            xlabel(app.UIAxes5, 'A [m²]')
            ylabel(app.UIAxes5, 'Relative liquid height [%]')
            zlabel(app.UIAxes5, 'Z')
            app.UIAxes5.Layout.Row = 3;
            app.UIAxes5.Layout.Column = 3;

            % Create LiquidheightLabel_2
            app.LiquidheightLabel_2 = uilabel(app.GridLayout);
            app.LiquidheightLabel_2.BackgroundColor = [0.0745 0.6235 1];
            app.LiquidheightLabel_2.HorizontalAlignment = 'center';
            app.LiquidheightLabel_2.Layout.Row = 1;
            app.LiquidheightLabel_2.Layout.Column = 2;
            app.LiquidheightLabel_2.Text = 'Liquid height';

            % Create RelativeliquidheightLabel
            app.RelativeliquidheightLabel = uilabel(app.GridLayout);
            app.RelativeliquidheightLabel.BackgroundColor = [0.0745 0.6235 1];
            app.RelativeliquidheightLabel.HorizontalAlignment = 'center';
            app.RelativeliquidheightLabel.Layout.Row = 1;
            app.RelativeliquidheightLabel.Layout.Column = 3;
            app.RelativeliquidheightLabel.Text = 'Relative liquid height';

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.GridLayout);
            app.GridLayout7.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout7.Layout.Row = 3;
            app.GridLayout7.Layout.Column = 1;
            app.GridLayout7.Scrollable = 'on';
            app.GridLayout7.BackgroundColor = [0.702 1 0.702];

            % Create Label_3
            app.Label_3 = uilabel(app.GridLayout7);
            app.Label_3.VerticalAlignment = 'top';
            app.Label_3.WordWrap = 'on';
            app.Label_3.Layout.Row = [2 6];
            app.Label_3.Layout.Column = 1;
            app.Label_3.Interpreter = 'latex';
            app.Label_3.Text = '';

            % Create Label_4
            app.Label_4 = uilabel(app.GridLayout7);
            app.Label_4.VerticalAlignment = 'top';
            app.Label_4.WordWrap = 'on';
            app.Label_4.Layout.Row = [2 6];
            app.Label_4.Layout.Column = 2;
            app.Label_4.Interpreter = 'latex';
            app.Label_4.Text = '';

            % Create ParametersLabel
            app.ParametersLabel = uilabel(app.GridLayout7);
            app.ParametersLabel.BackgroundColor = [0 1 0];
            app.ParametersLabel.HorizontalAlignment = 'center';
            app.ParametersLabel.Layout.Row = 1;
            app.ParametersLabel.Layout.Column = [1 2];
            app.ParametersLabel.Text = 'Parameters';

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.ColumnWidth = {'0.3x', '0.7x', '0.7x', '0.3x'};
            app.GridLayout6.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout6.Layout.Row = 2;
            app.GridLayout6.Layout.Column = 1;
            app.GridLayout6.BackgroundColor = [0.902 1 0.502];

            % Create tankparametersDropDown
            app.tankparametersDropDown = uidropdown(app.GridLayout6);
            app.tankparametersDropDown.Items = {'Upper', 'Lower'};
            app.tankparametersDropDown.ValueChangedFcn = createCallbackFcn(app, @TankParametersChanged, true);
            app.tankparametersDropDown.BackgroundColor = [1 1 0];
            app.tankparametersDropDown.Layout.Row = 1;
            app.tankparametersDropDown.Layout.Column = 2;
            app.tankparametersDropDown.Value = 'Upper';

            % Create tankparametersLabel
            app.tankparametersLabel = uilabel(app.GridLayout6);
            app.tankparametersLabel.BackgroundColor = [1 1 0];
            app.tankparametersLabel.HorizontalAlignment = 'center';
            app.tankparametersLabel.Layout.Row = 1;
            app.tankparametersLabel.Layout.Column = [1 4];
            app.tankparametersLabel.Text = '                            tank parameters';

            % Create umaxmsEditField
            app.umaxmsEditField = uieditfield(app.GridLayout6, 'numeric');
            app.umaxmsEditField.Limits = [0 Inf];
            app.umaxmsEditField.ValueChangedFcn = createCallbackFcn(app, @umaxChanged, true);
            app.umaxmsEditField.Layout.Row = 2;
            app.umaxmsEditField.Layout.Column = [3 4];

            % Create umaxmsEditFieldLabel
            app.umaxmsEditFieldLabel = uilabel(app.GridLayout6);
            app.umaxmsEditFieldLabel.Layout.Row = 2;
            app.umaxmsEditFieldLabel.Layout.Column = [1 2];
            app.umaxmsEditFieldLabel.Text = 'umax [m³/s]';

            % Create Label_6
            app.Label_6 = uilabel(app.GridLayout6);
            app.Label_6.Layout.Row = 2;
            app.Label_6.Layout.Column = 2;
            app.Label_6.Text = '';

            % Create Label_7
            app.Label_7 = uilabel(app.GridLayout6);
            app.Label_7.BackgroundColor = [1 1 0];
            app.Label_7.HorizontalAlignment = 'center';
            app.Label_7.VerticalAlignment = 'top';
            app.Label_7.Layout.Row = 1;
            app.Label_7.Layout.Column = [1 4];
            app.Label_7.Text = '';

            % Create h1maxmEditFieldLabel
            app.h1maxmEditFieldLabel = uilabel(app.GridLayout6);
            app.h1maxmEditFieldLabel.Layout.Row = 6;
            app.h1maxmEditFieldLabel.Layout.Column = [1 2];
            app.h1maxmEditFieldLabel.Text = 'h1max [m]';

            % Create urelEditField
            app.urelEditField = uieditfield(app.GridLayout6, 'numeric');
            app.urelEditField.ValueChangedFcn = createCallbackFcn(app, @urelChanged, true);
            app.urelEditField.Layout.Row = 3;
            app.urelEditField.Layout.Column = [3 4];

            % Create urelEditFieldLabel
            app.urelEditFieldLabel = uilabel(app.GridLayout6);
            app.urelEditFieldLabel.Layout.Row = 3;
            app.urelEditFieldLabel.Layout.Column = [1 2];
            app.urelEditFieldLabel.Text = 'urel []';

            % Create A1mEditField
            app.A1mEditField = uieditfield(app.GridLayout6, 'numeric');
            app.A1mEditField.ValueChangedFcn = createCallbackFcn(app, @A1Changed, true);
            app.A1mEditField.Layout.Row = 4;
            app.A1mEditField.Layout.Column = [3 4];

            % Create a1mEditField
            app.a1mEditField = uieditfield(app.GridLayout6, 'numeric');
            app.a1mEditField.Limits = [0 Inf];
            app.a1mEditField.ValueChangedFcn = createCallbackFcn(app, @a1Changed, true);
            app.a1mEditField.Layout.Row = 5;
            app.a1mEditField.Layout.Column = [3 4];

            % Create a1mEditFieldLabel
            app.a1mEditFieldLabel = uilabel(app.GridLayout6);
            app.a1mEditFieldLabel.Layout.Row = 5;
            app.a1mEditFieldLabel.Layout.Column = [1 2];
            app.a1mEditFieldLabel.Text = 'a1 [m²]';

            % Create h1relEditFieldLabel
            app.h1relEditFieldLabel = uilabel(app.GridLayout6);
            app.h1relEditFieldLabel.Layout.Row = 8;
            app.h1relEditFieldLabel.Layout.Column = [1 2];
            app.h1relEditFieldLabel.Text = 'h1rel []';

            % Create h1maxmEditField
            app.h1maxmEditField = uieditfield(app.GridLayout6, 'numeric');
            app.h1maxmEditField.Limits = [0 Inf];
            app.h1maxmEditField.ValueChangedFcn = createCallbackFcn(app, @h1maxChanged, true);
            app.h1maxmEditField.Layout.Row = 6;
            app.h1maxmEditField.Layout.Column = [3 4];

            % Create h1relEditField
            app.h1relEditField = uieditfield(app.GridLayout6, 'numeric');
            app.h1relEditField.Limits = [0 Inf];
            app.h1relEditField.Editable = 'off';
            app.h1relEditField.Layout.Row = 8;
            app.h1relEditField.Layout.Column = [3 4];

            % Create A1mEditFieldLabel
            app.A1mEditFieldLabel = uilabel(app.GridLayout6);
            app.A1mEditFieldLabel.Layout.Row = 4;
            app.A1mEditFieldLabel.Layout.Column = [1 2];
            app.A1mEditFieldLabel.Text = 'A1  [m²]';

            % Create h1mEditField
            app.h1mEditField = uieditfield(app.GridLayout6, 'numeric');
            app.h1mEditField.Limits = [0 Inf];
            app.h1mEditField.Editable = 'off';
            app.h1mEditField.Layout.Row = 7;
            app.h1mEditField.Layout.Column = [3 4];

            % Create h1mEditFieldLabel
            app.h1mEditFieldLabel = uilabel(app.GridLayout6);
            app.h1mEditFieldLabel.Layout.Row = 7;
            app.h1mEditFieldLabel.Layout.Column = [1 2];
            app.h1mEditFieldLabel.Text = 'h1 [m]';

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = 1;
            app.GridLayout2.BackgroundColor = [1 0.6 0.8];

            % Create OpenloopparameterssimulationButton
            app.OpenloopparameterssimulationButton = uibutton(app.GridLayout2, 'push');
            app.OpenloopparameterssimulationButton.ButtonPushedFcn = createCallbackFcn(app, @TwoTanksSimulation, true);
            app.OpenloopparameterssimulationButton.BackgroundColor = [1 0.2 0.702];
            app.OpenloopparameterssimulationButton.Layout.Row = 1;
            app.OpenloopparameterssimulationButton.Layout.Column = [1 3];
            app.OpenloopparameterssimulationButton.Text = 'Open-loop parameters & simulation';

            % Create ClosedloopsimulationTab
            app.ClosedloopsimulationTab = uitab(app.TabGroup);
            app.ClosedloopsimulationTab.AutoResizeChildren = 'off';
            app.ClosedloopsimulationTab.Title = 'Closed-loop simulation';

            % Create GridLayout_2
            app.GridLayout_2 = uigridlayout(app.ClosedloopsimulationTab);
            app.GridLayout_2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout_2.RowHeight = {'0.4x', '2x', '2x'};

            % Create UIAxes6
            app.UIAxes6 = uiaxes(app.GridLayout_2);
            title(app.UIAxes6, 'Upper tank')
            xlabel(app.UIAxes6, 'Time [s]')
            ylabel(app.UIAxes6, 'Liquid height [m]')
            app.UIAxes6.ZTick = [];
            app.UIAxes6.Layout.Row = 2;
            app.UIAxes6.Layout.Column = 2;

            % Create UIAxes7
            app.UIAxes7 = uiaxes(app.GridLayout_2);
            title(app.UIAxes7, 'Lower tank')
            xlabel(app.UIAxes7, 'Time [s]')
            ylabel(app.UIAxes7, 'Liquid height [m]')
            zlabel(app.UIAxes7, 'Z')
            app.UIAxes7.ZTick = [];
            app.UIAxes7.Layout.Row = 3;
            app.UIAxes7.Layout.Column = 2;

            % Create UIAxes8
            app.UIAxes8 = uiaxes(app.GridLayout_2);
            title(app.UIAxes8, 'Output of Controller')
            xlabel(app.UIAxes8, 'Time [s]')
            ylabel(app.UIAxes8, 'Liquid flow [m³]')
            zlabel(app.UIAxes8, 'Z')
            app.UIAxes8.ZTick = [];
            app.UIAxes8.Layout.Row = 2;
            app.UIAxes8.Layout.Column = 3;

            % Create CalculatedfiguresLabel
            app.CalculatedfiguresLabel = uilabel(app.GridLayout_2);
            app.CalculatedfiguresLabel.BackgroundColor = [0.0745 0.6235 1];
            app.CalculatedfiguresLabel.HorizontalAlignment = 'center';
            app.CalculatedfiguresLabel.Layout.Row = 1;
            app.CalculatedfiguresLabel.Layout.Column = 3;
            app.CalculatedfiguresLabel.Text = 'Calculated figures';

            % Create LiquidheightoftanksLabel
            app.LiquidheightoftanksLabel = uilabel(app.GridLayout_2);
            app.LiquidheightoftanksLabel.BackgroundColor = [0.0745 0.6235 1];
            app.LiquidheightoftanksLabel.HorizontalAlignment = 'center';
            app.LiquidheightoftanksLabel.Layout.Row = 1;
            app.LiquidheightoftanksLabel.Layout.Column = 2;
            app.LiquidheightoftanksLabel.Text = 'Liquid height of tanks';

            % Create ControlScreen
            app.ControlScreen = uilabel(app.GridLayout_2);
            app.ControlScreen.VerticalAlignment = 'top';
            app.ControlScreen.FontColor = [0.0745 0.6235 1];
            app.ControlScreen.Layout.Row = 3;
            app.ControlScreen.Layout.Column = 3;
            app.ControlScreen.Interpreter = 'latex';
            app.ControlScreen.Text = '';

            % Create GridLayout8
            app.GridLayout8 = uigridlayout(app.GridLayout_2);
            app.GridLayout8.ColumnWidth = {'0.2x', '0.25x', '0.25x', '0.25x', '0.25x', '1x'};
            app.GridLayout8.RowHeight = {'0.6x', '0.5x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout8.Layout.Row = 2;
            app.GridLayout8.Layout.Column = 1;
            app.GridLayout8.BackgroundColor = [0.902 1 0.502];

            % Create TargetdepthofDropDown
            app.TargetdepthofDropDown = uidropdown(app.GridLayout8);
            app.TargetdepthofDropDown.Items = {'h1', 'h2'};
            app.TargetdepthofDropDown.Layout.Row = 1;
            app.TargetdepthofDropDown.Layout.Column = [4 5];
            app.TargetdepthofDropDown.Value = 'h2';

            % Create TargetdepthofDropDownLabel
            app.TargetdepthofDropDownLabel = uilabel(app.GridLayout8);
            app.TargetdepthofDropDownLabel.HorizontalAlignment = 'right';
            app.TargetdepthofDropDownLabel.Layout.Row = 1;
            app.TargetdepthofDropDownLabel.Layout.Column = [1 3];
            app.TargetdepthofDropDownLabel.Text = 'Target depth of';

            % Create SelectPIDparametersLabel
            app.SelectPIDparametersLabel = uilabel(app.GridLayout8);
            app.SelectPIDparametersLabel.HorizontalAlignment = 'center';
            app.SelectPIDparametersLabel.Layout.Row = 2;
            app.SelectPIDparametersLabel.Layout.Column = [1 6];
            app.SelectPIDparametersLabel.Text = 'Select PID parameters';

            % Create PSlider
            app.PSlider = uislider(app.GridLayout8);
            app.PSlider.Limits = [0 10];
            app.PSlider.ValueChangedFcn = createCallbackFcn(app, @PSliderChanged, true);
            app.PSlider.Layout.Row = 3;
            app.PSlider.Layout.Column = [2 6];

            % Create ISlider
            app.ISlider = uislider(app.GridLayout8);
            app.ISlider.ValueChangedFcn = createCallbackFcn(app, @ISliderChanged, true);
            app.ISlider.Layout.Row = 4;
            app.ISlider.Layout.Column = [2 6];

            % Create DSlider
            app.DSlider = uislider(app.GridLayout8);
            app.DSlider.ValueChangedFcn = createCallbackFcn(app, @DSliderChanged, true);
            app.DSlider.Layout.Row = 5;
            app.DSlider.Layout.Column = [2 6];

            % Create DSliderLabel
            app.DSliderLabel = uilabel(app.GridLayout8);
            app.DSliderLabel.HorizontalAlignment = 'center';
            app.DSliderLabel.Layout.Row = 5;
            app.DSliderLabel.Layout.Column = 1;
            app.DSliderLabel.Text = 'D';

            % Create ISliderLabel
            app.ISliderLabel = uilabel(app.GridLayout8);
            app.ISliderLabel.HorizontalAlignment = 'center';
            app.ISliderLabel.Layout.Row = 4;
            app.ISliderLabel.Layout.Column = 1;
            app.ISliderLabel.Text = 'I';

            % Create PSliderLabel
            app.PSliderLabel = uilabel(app.GridLayout8);
            app.PSliderLabel.HorizontalAlignment = 'center';
            app.PSliderLabel.Layout.Row = 3;
            app.PSliderLabel.Layout.Column = 1;
            app.PSliderLabel.Text = 'P';

            % Create GLabel
            app.GLabel = uilabel(app.GridLayout8);
            app.GLabel.HorizontalAlignment = 'center';
            app.GLabel.Layout.Row = 6;
            app.GLabel.Layout.Column = 1;
            app.GLabel.Text = 'G';

            % Create MLabel
            app.MLabel = uilabel(app.GridLayout8);
            app.MLabel.HorizontalAlignment = 'center';
            app.MLabel.Layout.Row = 7;
            app.MLabel.Layout.Column = 1;
            app.MLabel.Text = 'M';

            % Create Label
            app.Label = uilabel(app.GridLayout8);
            app.Label.Layout.Row = 6;
            app.Label.Layout.Column = [2 6];
            app.Label.Interpreter = 'latex';
            app.Label.Text = '';

            % Create Label_2
            app.Label_2 = uilabel(app.GridLayout8);
            app.Label_2.Layout.Row = 7;
            app.Label_2.Layout.Column = [2 6];
            app.Label_2.Interpreter = 'latex';
            app.Label_2.Text = '';

            % Create Seth1h2EditField
            app.Seth1h2EditField = uieditfield(app.GridLayout8, 'numeric');
            app.Seth1h2EditField.Limits = [0 Inf];
            app.Seth1h2EditField.ValueChangedFcn = createCallbackFcn(app, @H1H2Changed, true);
            app.Seth1h2EditField.Layout.Row = 1;
            app.Seth1h2EditField.Layout.Column = 6;
            app.Seth1h2EditField.Value = 1.8;

            % Create GridLayout7_2
            app.GridLayout7_2 = uigridlayout(app.GridLayout_2);
            app.GridLayout7_2.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout7_2.Layout.Row = 3;
            app.GridLayout7_2.Layout.Column = 1;
            app.GridLayout7_2.Scrollable = 'on';
            app.GridLayout7_2.BackgroundColor = [0.702 1 0.702];

            % Create ParametersLabel_2
            app.ParametersLabel_2 = uilabel(app.GridLayout7_2);
            app.ParametersLabel_2.BackgroundColor = [0 1 0];
            app.ParametersLabel_2.HorizontalAlignment = 'center';
            app.ParametersLabel_2.Layout.Row = 1;
            app.ParametersLabel_2.Layout.Column = [1 2];
            app.ParametersLabel_2.Text = 'Parameters';

            % Create TextArea_3
            app.TextArea_3 = uitextarea(app.GridLayout7_2);
            app.TextArea_3.BackgroundColor = [0.702 1 0.702];
            app.TextArea_3.Layout.Row = [2 6];
            app.TextArea_3.Layout.Column = 1;

            % Create TextArea_4
            app.TextArea_4 = uitextarea(app.GridLayout7_2);
            app.TextArea_4.BackgroundColor = [0.702 1 0.702];
            app.TextArea_4.Layout.Row = [2 6];
            app.TextArea_4.Layout.Column = 2;

            % Create TextArea_4Label
            app.TextArea_4Label = uilabel(app.GridLayout7_2);
            app.TextArea_4Label.HorizontalAlignment = 'right';
            app.TextArea_4Label.Layout.Row = 2;
            app.TextArea_4Label.Layout.Column = 1;
            app.TextArea_4Label.Text = '';

            % Create TextArea_3Label
            app.TextArea_3Label = uilabel(app.GridLayout7_2);
            app.TextArea_3Label.BackgroundColor = [0.702 1 0.702];
            app.TextArea_3Label.HorizontalAlignment = 'right';
            app.TextArea_3Label.Layout.Row = 2;
            app.TextArea_3Label.Layout.Column = 1;
            app.TextArea_3Label.Text = 'Text Area';

            % Create GridLayout2_2
            app.GridLayout2_2 = uigridlayout(app.GridLayout_2);
            app.GridLayout2_2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2_2.RowHeight = {'1x'};
            app.GridLayout2_2.Layout.Row = 1;
            app.GridLayout2_2.Layout.Column = 1;
            app.GridLayout2_2.BackgroundColor = [1 0.6 0.8];

            % Create CreateclosedloopresponsesButton
            app.CreateclosedloopresponsesButton = uibutton(app.GridLayout2_2, 'push');
            app.CreateclosedloopresponsesButton.ButtonPushedFcn = createCallbackFcn(app, @CreateclosedloopresponsesButtonPushed, true);
            app.CreateclosedloopresponsesButton.BackgroundColor = [1 0.2 0.702];
            app.CreateclosedloopresponsesButton.Layout.Row = 1;
            app.CreateclosedloopresponsesButton.Layout.Column = [1 3];
            app.CreateclosedloopresponsesButton.Text = 'Create closed-loop responses';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = TwoTanks

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @StartupFcn)

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

