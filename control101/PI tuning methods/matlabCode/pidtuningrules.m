classdef pidtuningrules < matlab.apps.AppBase
    %PIDTUNINGRULES
    %   A simple interface to practice the auto-tuning of PID using various
    %   rule bases 
    %   
    %   File written by J.A.Rossiter, University of Sheffield
    %        See website for more files like this.
    %       
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   
    %        A simple interface to compar and contrast different PID
    %   auto-tuning algorithms.  A group of similar files can be downloaded
    %   through MATLAB add-ons with the toolbox name:  control101

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        GridLayout                   matlab.ui.container.GridLayout
        GridLayout15                 matlab.ui.container.GridLayout
        GridLayout16                 matlab.ui.container.GridLayout
        CHRButton                    matlab.ui.control.Button
        SkogestadButton              matlab.ui.control.Button
        ManualButton                 matlab.ui.control.Button
        OnethirdButton               matlab.ui.control.Button
        LambdaButton                 matlab.ui.control.Button
        AMIGOButton                  matlab.ui.control.Button
        CohenCoonButton              matlab.ui.control.Button
        ZNButton                     matlab.ui.control.Button
        GridLayout4                  matlab.ui.container.GridLayout
        ControllawDropDown           matlab.ui.control.DropDown
        ControllawDropDownLabel      matlab.ui.control.Label
        TuningruleDropDown           matlab.ui.control.DropDown
        TuningruleDropDownLabel      matlab.ui.control.Label
        SimulationparametersLabel    matlab.ui.control.Label
        GridLayout11                 matlab.ui.container.GridLayout
        GridLayout14                 matlab.ui.container.GridLayout
        Image4                       matlab.ui.control.Image
        Image3                       matlab.ui.control.Image
        Image2                       matlab.ui.control.Image
        Image                        matlab.ui.control.Image
        GridLayout10                 matlab.ui.container.GridLayout
        MslabelLabel                 matlab.ui.control.Label
        MsLabel                      matlab.ui.control.Label
        GslabelLabel                 matlab.ui.control.Label
        GsLabel                      matlab.ui.control.Label
        GridLayout9                  matlab.ui.container.GridLayout
        KdSlider                     matlab.ui.control.Slider
        KdSliderLabel                matlab.ui.control.Label
        KiSlider                     matlab.ui.control.Slider
        KiSliderLabel                matlab.ui.control.Label
        KpSlider                     matlab.ui.control.Slider
        KpSliderLabel                matlab.ui.control.Label
        ManuallyselectPIDparametersMsLabel  matlab.ui.control.Label
        TabGroup                     matlab.ui.container.TabGroup
        CharacterisesystemTab        matlab.ui.container.Tab
        GridLayout8                  matlab.ui.container.GridLayout
        GridLayout13                 matlab.ui.container.GridLayout
        GslabelLabel_8               matlab.ui.control.Label
        GslabelLabel_7               matlab.ui.control.Label
        GslabelLabel_6               matlab.ui.control.Label
        GridLayout12                 matlab.ui.container.GridLayout
        GslabelLabel_5               matlab.ui.control.Label
        GslabelLabel_4               matlab.ui.control.Label
        GslabelLabel_3               matlab.ui.control.Label
        GslabelLabel_2               matlab.ui.control.Label
        UIAxes2                      matlab.ui.control.UIAxes
        ClosedloopbehaviourTab       matlab.ui.container.Tab
        GridLayout7                  matlab.ui.container.GridLayout
        UIAxes_8                     matlab.ui.control.UIAxes
        UIAxes_7                     matlab.ui.control.UIAxes
        UIAxes_6                     matlab.ui.control.UIAxes
        UIAxes_5                     matlab.ui.control.UIAxes
        UIAxes_4                     matlab.ui.control.UIAxes
        UIAxes_3                     matlab.ui.control.UIAxes
        UIAxes_2                     matlab.ui.control.UIAxes
        UIAxes                       matlab.ui.control.UIAxes
        GridLayout6                  matlab.ui.container.GridLayout
        OverlaymultipletuningButton  matlab.ui.control.Button
        CreateresponsesButton        matlab.ui.control.Button
        CharacterisesystemButton     matlab.ui.control.Button
        GridLayout5                  matlab.ui.container.GridLayout
        ThecompensatorshowingwillbnelinkedtothelastinteractionLabel  matlab.ui.control.Label
        ComparisonofPIDtuningrulesLabel  matlab.ui.control.Label
        GridLayout3                  matlab.ui.container.GridLayout
        GainKSlider                  matlab.ui.control.Slider
        GainKSliderLabel             matlab.ui.control.Label
        TimeconstantTSlider          matlab.ui.control.Slider
        TimeconstantTSliderLabel     matlab.ui.control.Label
        DelayLSlider                 matlab.ui.control.Slider
        DelayLSliderLabel            matlab.ui.control.Label
        EstimateparametersusedinautotuningLabel  matlab.ui.control.Label
        GridLayout2                  matlab.ui.container.GridLayout
        SystemdelaySlider            matlab.ui.control.Slider
        SystemdelaySliderLabel       matlab.ui.control.Label
        HighorderDropDown            matlab.ui.control.DropDown
        HighorderDropDownLabel       matlab.ui.control.Label
        SecondorderDropDown          matlab.ui.control.DropDown
        SecondorderDropDownLabel     matlab.ui.control.Label
        ChoosesystemGsLabel          matlab.ui.control.Label
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
        MP =1;  % store proportional controller
        MPI =tf([1 1],[1 0]); % store PI controller
        MPID =tf([1 1],[1 0]); % store PID controller
        Mactive = tf([1 1],[1 0]);  % current active controller
        Mactivetext = 'Manual';
        SP   %  sensitivity functions
        SPI  %  sensitivity functions
        SPID %  sensitivity functions
        YP   % responses for proportional
        YPI  % responses for PI
        YPID % responses for PID
        G=tf(10,[1 7 14 8]);  % store system tf
        Td=0.5; % target closed-loop time constant
        delay = 0 ;% intrinsic system delay
        DELAY % in tf format
        
        runtime = 10;
        samples = 201;
        time
        noise = randn(1,201)*0.1;

        Kp1 % proportional
        Kp2 % proportional for PI
        Kp3 % proportional for PID
        Ki2 % integral for PI
        Ki3 % integral for PID
        Kd3 % derivative for PID

        templegstring  % legend for overlaying with different L, T, K
        kk % counter for length of legend
        
        

    end
    
    methods (Access = private)
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION FOR BASIC STEP RESPONSES

        function y = determineresponses(app,cltf)
            % This function determines all the closed-loop UNIT step
            % responses 
            % Uses the pre-defined sensitivity functions
            t = linspace(0,app.runtime,app.samples);
            y=cell(1);
            
            for k=1:length(cltf);
                if app.delay~=0
                    y{k} = step(cltf{k},t);
                else
               % these checks fail with delay systems
                if and(isproper(cltf{k}),isstable(cltf{k}))
                    y{k} = step(cltf{k},t);
                else
                    y{k}= ones(1,app.samples)*0.01;
                end
                end
            end
            app.time = t;
            
        end  % end of determineresponses

        function y = determinenoise(app,cltf)
            % This function determines all the closed-loop  step
            % responses for measurement noise
            % Uses the pre-defined sensitivity functions
            
            
            y=cell(1);
            y{1} = lsim(cltf{7},app.noise,app.time);
            y{2} = lsim(cltf{8},app.noise,app.time);
                
            
        end  % end of noise responses



        % Define the  PID laws using the current values in the sliders
        % Derivative needs a filter, logically much faster than the loop
        % dynamics of T, for example s==> as/(s+a)  where a = 10/T
        %
        % also update all the sensitivity functions
        %          
        function app = define_PID_laws(app)
            T = app.TimeconstantTSlider.Value;
            K = app.GainKSlider.Value;
            L = app.DelayLSlider.Value;
            Td = app.Td; T2=Td;

            switch app.TuningruleDropDown.Value
                case 'Ziegler Nichols'
                    app.MP = tf(T/(K*L),1);
                    Kp=0.9*T/(K*L); Ki=Kp/(3.33*L); 
                    app.Kp1=Kp;
                    app.MPI = tf([Kp,Ki],[1 0]);
                    app.Kp2=Kp;app.Ki2 = Ki;
                    Kp=1.2*T/(K*L); Ki=Kp/(2*L); Kd=Kp*0.5*L;
                    app.MPID = tf([Kp,Ki],[1 0]) + Kd*tf([10,0],[Td,10]);
                    app.Kp3=Kp;app.Ki3 = Ki; app.Kd3 = Kd;
                    app. Mactivetext = 'ZN';

                case 'Cohen Coon'
                    Kp = 1.03*T/(K*(L+0.34));
                    app.Kp1=Kp;
                    app.MP=tf(Kp,1);
                    Kp=(0.9*T)/(K*(L+0.0092)); Ti=3.33*L*(T+0.0092*L)/(T+2.22*L);
                    app.MPI = tf([Kp,Kp/Ti],[1 0]);
                    app.Kp2=Kp;app.Ki2 = Kp/Ti;
                    Kp=(1.24*T/K)*(L+0.129); Ti=2.5*L*(T+0.185*L)/(T+0.611*L); 
                    Kd=Kp*0.37*L*T/(T+0.185*L);
                    app.MPID = tf([Kp,Kp/Ti],[1 0]) + Kd*tf([10,0],[Td,10]);
                    app.Kp3=Kp;app.Ki3 = Kp/Ti; app.Kd3 = Kd;
                    app. Mactivetext = 'CC';
                    

                case 'Skogestad'
                    
                    Kp=(1/K)*T/(L+L); Ti = min([T,4*(L+L)]); Td=T2;
                    app.MPI = tf(Kp*[Ti,1],[Ti 0]);  
                    app.MPID = app.MPI;
                    app.MP = tf(Kp,1);
                    app.Kp1=Kp;
                    app.Kp2=Kp; app.Ki2 = Kp/Ti;
                    app.Kp3=Kp; app.Ki3 = Kp/Ti; app.Kd3 = 0;
                    app. Mactivetext = 'Skog';


               case 'Chien-Hrones-Reswick'
                    
                    Kp=(0.3*T/(L*K));
                    app.Kp1=Kp;
                    Kp=(0.35*T/(L*K)); Ti=1.2*T;
                    app.MP=tf(Kp,1);
                    app.MPI = tf([Kp,Kp/Ti],[1 0]);
                    app.Kp2=Kp;app.Ki2 = Kp/Ti;
                    Kp=(0.6*T/(L*K)); Ti=T; Td2=0.5*L; Kd = 0.5*Td2;
                    app.MPID = tf([Kp,Kp/Ti],[1 0]) + Kd*tf([10,0],[Td,10]);
                    app.Kp3=Kp;app.Ki3 = Kp/Ti; app.Kd3 = Kd;
                    app. Mactivetext =  'CHR';

               case 'AMIGO'
                    
                    Kp=(0.15/K) + (0.35-L*T/(L+T)^2)*(T/(K*L)); Ti=0.35*L+6.7*L*T^2/(T^2+12*L*T+7*L^2);
                    app.Kp1=Kp;
                    app.MP=tf(Kp,1);
                    app.MPI = tf([Kp,Kp/Ti],[1 0]);
                    app.Kp2=Kp;app.Ki2 = Kp/Ti;
                    Kp=1/K*(0.2+0.45*T/L); Ti=(0.4*L+0.8*T)/((L+0.1*T)*L); Td2 = 0.5*L*T/(0.3*L+T);
                    app.MPID = tf([Kp,Kp/Ti],[1 0]) + Kp*Td2*tf([10,0],[Td,10]);
                    app.Kp3=Kp;app.Ki3 = Kp/Ti; app.Kd3 = Kp*Td2;
                    app. Mactivetext = 'AMIGO';

                case 'One-third tuning'
                    
                    Kp=1/(3*K); Ti=(L/3)+T;
                    app.Kp1=Kp;
                    app.MP=tf(Kp,1);
                    app.MPI = tf([Kp,Kp/Ti],[1 0]);
                    app.Kp2=Kp;app.Ki2 = Kp/Ti;
                    app.MPID = app.MPI;
                    app.Kp3=Kp;app.Ki3 = Kp/Ti; app.Kd3 = 0;
                    app. Mactivetext = 'One third';
                    
                case 'Lambda tuning'
                    
                    Kp=T/(K*(Td+L)); Ti=T;
                    app.Kp1=Kp;
                    app.MP=tf(Kp,1);
                    app.MPI = tf([Kp,Kp/Ti],[1 0]);
                    app.Kp2=Kp;app.Ki2 = Kp/Ti;
                    app.MPID = app.MPI;
                    app.Kp3=Kp;app.Ki3 = Kp/Ti; app.Kd3 = 0;
                    app. Mactivetext = 'Lambda';

                case 'Manual Choice'
                    Kp = app.KpSlider.Value;
                    Ki = app.KiSlider.Value;
                    Kd = app.KdSlider.Value;
                    app.MP = tf(Kp,1);
                    app.MPI = tf([Kp,Ki],[1 0]);
                    app.MPID = tf([Kp,Ki],[1 0]) + Kd*tf([10,0],[Td,10]);
                    app.Kp1=Kp;app.Kp2=Kp;app.Kp3=Kp;
                    app.Ki2 = Ki;app.Ki3 = Ki;
                    app. Mactivetext = 'Manual';
            end

            app.SP = define_sensitivity(app,app.MP);
            app.SPI = define_sensitivity(app,app.MPI);
            app.SPID = define_sensitivity(app,app.MPID);

            % update active law displayed in  bottom of screen
            switch app.ControllawDropDown.Value
                case 'P';  
                    app.Mactive = app.MP;
                case 'PI'; 
                    app.Mactive = app.MPI;
                case 'PID'; 
                    app.Mactive = app.MPID;
                otherwise; 
                    app.Mactive = app.MPI;
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % determine closed-loop transfer functions
        function out = define_sensitivity(app,M)
            
            out{1}=feedback(app.G*app.DELAY*M,1);    % r to y
            out{2}=feedback(M,app.G*app.DELAY);      % r to u
            out{3}=feedback(1,M*app.G*app.DELAY);    % yno to y
            out{4}=-feedback(M,app.G*app.DELAY);     % yno to u
            out{5}=feedback(app.G*app.DELAY,M);     % yni to y
            out{6}=feedback(1,app.G*M*app.DELAY);   % yni to u
            out{7}=-out{1};                         % yz to y
            out{8}=-out{2};   % yz to u
                        
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Produce the responses for each sensitivity
        % Assumes the the derviative filtered to 
        % avoid derivative kick
        
        function y = updateresponses(app,TF)
             y = determineresponses(app,TF);
             n = determinenoise(app,TF);
             plot(app.UIAxes,app.time,y{1},'linewidth',2)
             plot(app.UIAxes_2,app.time,y{2},'linewidth',2)
             plot(app.UIAxes_3,app.time,y{3},'linewidth',2)
             plot(app.UIAxes_4,app.time,y{4},'linewidth',2)
             plot(app.UIAxes_5,app.time,y{5},'linewidth',2)
             plot(app.UIAxes_6,app.time,y{6},'linewidth',2)
             plot(app.UIAxes_7,app.time,n{1},'linewidth',2)
             plot(app.UIAxes_8,app.time,n{2},'linewidth',2)
             if app.delay>0;  % needed as stability check disabled
                 ylim(app.UIAxes,[-0.4,1.4]);
                 ylim(app.UIAxes_3,[-0.4,1.4]);
                 ylim(app.UIAxes_5,[-0.4,1.4]);
                 ylim(app.UIAxes_2,[-2,2]);
                 ylim(app.UIAxes_4,[-2,2]);
                 ylim(app.UIAxes_6,[-2,2]);
                 ylim(app.UIAxes_7,[-1 1]);
                 ylim(app.UIAxes_8,[-2,2]);
             end

             
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%% manage hold on and hold off of response figs more efficiently
        function cleantab2(app)
            hold(app.UIAxes,'off')
            hold(app.UIAxes_2,'off')
            hold(app.UIAxes_3,'off')
            hold(app.UIAxes_4,'off')
            hold(app.UIAxes_5,'off')
            hold(app.UIAxes_6,'off')
            hold(app.UIAxes_7,'off')
            hold(app.UIAxes_8,'off')
            
        end
      
        function holdtab2(app)
            hold(app.UIAxes,'on')
            hold(app.UIAxes_2,'on')
            hold(app.UIAxes_3,'on')
            hold(app.UIAxes_4,'on')
            hold(app.UIAxes_5,'on')
            hold(app.UIAxes_6,'on')
            hold(app.UIAxes_7,'on')
            hold(app.UIAxes_8,'on')
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Used for putting transfer functions into a text box
function updateTransferFunctionRender(app)
            [n,d] = tfdata(app.G,'v'); 
            n=n(n~=0);  % remove extra zeros
            numerator_str = array2StringPolynomial(app,n);
            denumerator_str = array2StringPolynomial(app,d);
            app.GslabelLabel.Text = "$\frac{"+numerator_str+"}"+"{"+denumerator_str+"}$";
            app.GslabelLabel.Text = [app.GslabelLabel.Text,',  Delay = ',num2str(app.delay)];
            
            [n,d] = tfdata(app.Mactive,'v'); 
            n=n(n~=0);  % remove extra zeros
            numerator_str = array2StringPolynomial(app,round(n,2));
            denumerator_str = array2StringPolynomial(app,round(d,2));
            app.MslabelLabel.Text = "$\frac{"+numerator_str+"}"+"{"+denumerator_str+"}$";
            app.MslabelLabel.Text =[app.MslabelLabel.Text,',  "',app.Mactivetext,'"'];
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION TO CREATE A TEXT DISPLAY OF A POLYNOMIAL
        function auxmsgNum = array2StringPolynomial(app,n)
            lenNum = length(n);
            auxmsgNum= "";
            ind = 1;
            for i=lenNum:-1:1
                ncoef = n(ind);
                if n(ind)<0
                    prefix = '';
                else
                    prefix = '+';
                end

                if abs(n(ind))==1 && ind~=lenNum
                    ncoef=[];
                end

                if lenNum==1
                    auxmsgNum = auxmsgNum + num2str(ncoef);
                else
                    if i==lenNum && lenNum~=2
                        auxmsgNum = auxmsgNum + num2str(ncoef) +"s^"+num2str(i-1);

                    elseif i==lenNum && lenNum==2
                        auxmsgNum = auxmsgNum + num2str(ncoef) +"s";

                    elseif i == 1

                        auxmsgNum = auxmsgNum + prefix+ num2str(ncoef);

                    elseif i==2
                        auxmsgNum = auxmsgNum + prefix+ num2str(ncoef) +"s";

                    else
                        auxmsgNum = auxmsgNum + prefix +num2str(ncoef) +"s^"+num2str(i-1);
                    end
                end
                ind = ind + 1;
            end
        end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Overlay performance linked to all possible tuning laws in the same figures
% Check button group to decide which ones to include
        
        function results = overlayalllaws(app,choice)
            app.TabGroup.SelectedTab = app.TabGroup.Children(2);
            cleantab2(app)  % removes existing plots
            savetext = app.TuningruleDropDown.Value;
            legall=cell(1);k=1;

            if app.ZNButton.BackgroundColor == [0.4,0.8,0.1];
            app.TuningruleDropDown.Value = 'Ziegler Nichols';
            app = define_PID_laws(app);  % defines all the PID laws
            switch choice
                case 'PID'
                    yzn = updateresponses(app,app.SPID);
                case 'PI'
                    yzn = updateresponses(app,app.SPI);
            end
            holdtab2(app);  % hold all figures so later plots add
            legall{1}='ZN'; k =2;

            end

            if app.CohenCoonButton.BackgroundColor == [0.4,0.8,0.1];
            app.TuningruleDropDown.Value = 'Cohen Coon';
            app = define_PID_laws(app);  % defines all the PID laws
            switch choice
                case 'PID'
                    ycc = updateresponses(app,app.SPID);
                case 'PI'
                    ycc = updateresponses(app,app.SPI);
            end 
            holdtab2(app);  % hold all figures so later plots add
            if k==1; 
                legall{1}='Cohen Coon';k=2;
            else;
                legall{length(legall)+1} = 'Cohen Coon';
            end

            end

            if app.LambdaButton.BackgroundColor == [0.4,0.8,0.1]
            app.TuningruleDropDown.Value = 'Lambda tuning';
            app = define_PID_laws(app);  % defines all the PID laws
            switch choice
                case 'PID'
                    yl = updateresponses(app,app.SPID);
                case 'PI'
                    yl = updateresponses(app,app.SPI);
            end
            holdtab2(app);  % hold all figures so later plots add
            if k==1; 
                legall{1}='Lambda';k=2;
            else;
                legall{length(legall)+1} = 'Lambda';
            end

            end

            if app.SkogestadButton.BackgroundColor == [0.4,0.8,0.1]
            app.TuningruleDropDown.Value = 'Skogestad';
            app = define_PID_laws(app);  % defines all the PID laws
            switch choice
                case 'PID'
                    ys = updateresponses(app,app.SPID);
                case 'PI'
                    ys = updateresponses(app,app.SPI);
            end
            holdtab2(app);  % hold all figures so later plots add
            if k==1; 
                legall{1}='Skogestad';k=2;
            else;
                legall{length(legall)+1} = 'Skogestad';
            end

            end

            if app.CHRButton.BackgroundColor == [0.4,0.8,0.1]
            app.TuningruleDropDown.Value = 'Chien-Hrones-Reswick';
            app = define_PID_laws(app);  % defines all the PID laws
            switch choice
                case 'PID'
                    ychr = updateresponses(app,app.SPID);
                case 'PI'
                    ychr = updateresponses(app,app.SPI);
            end
            holdtab2(app);  % hold all figures so later plots add
            if k==1; 
                legall{1}='CHR';k=2;
            else;
                legall{length(legall)+1} = 'CHR';
            end
            end
            

            if app.AMIGOButton.BackgroundColor == [0.4,0.8,0.1]
            app.TuningruleDropDown.Value = 'AMIGO';
            app = define_PID_laws(app);  % defines all the PID laws
            switch choice
                case 'PID'
                    ya = updateresponses(app,app.SPID);
                case 'PI'
                    ya = updateresponses(app,app.SPI);
            end 
            holdtab2(app);  % hold all figures so later plots add
            if k==1; 
                legall{1}='AMIGO';k=2;
            else;
                legall{length(legall)+1} = 'AMIGO';
            end

            end

            if app.OnethirdButton.BackgroundColor == [0.4,0.8,0.1]
            app.TuningruleDropDown.Value = 'One-third tuning';
            app = define_PID_laws(app);  % defines all the PID laws
            switch choice
                case 'PID'
                    y3 = updateresponses(app,app.SPID);
                case 'PI'
                    y3 = updateresponses(app,app.SPI);
            end
            holdtab2(app);  % hold all figures so later plots add
            if k==1; 
                legall{1}='One third';k=2;
            else;
                legall{length(legall)+1} = 'One third';
            end

            end

            if app.ManualButton.BackgroundColor == [0.4,0.8,0.1]
            app.TuningruleDropDown.Value = 'Manual Choice';
            app = define_PID_laws(app);  % defines all the PID laws
            switch choice
                case 'PID'
                    ym = updateresponses(app,app.SPID);
                case 'PI'
                    ym = updateresponses(app,app.SPI);
            end 
            holdtab2(app);  % hold all figures so later plots add
            if k==1; 
                legall{1}='Manual';k=2;
            else;
                legall{length(legall)+1} = 'Manual';
            end

            end
            
            
            app.TuningruleDropDown.Value = savetext;
            % Add legend if at least one plot created
            if k~=1; 
             legend(app.UIAxes_2,legall,'Fontsize',8)
            end
             
            
        end
    end  %% end of methods
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
           % resize to be in middle of  the window
            movegui(app.UIFigure)
            
            %Open the manual
            if exist('pidtuningrules_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open pidtuningrules_mycopy.mlx
            else
                p1 = which('pidtuningrules_manual.mlx');
                p2 = strcat(pwd,'/pidtuningrules_mycopy.mlx');
                copyfile(p1,p2)                
                open pidtuningrules_mycopy.mlx
                clear p1 p2
            end


            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);

            CharacterisesystemButtonPushed(app);
            updateTransferFunctionRender(app)  % update values in the boxes

            app.ZNButton.BackgroundColor = [0.4 0.8 0.1];
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
                theme(app.UIFigure,"light")
            end
        end

        % Button pushed function: CharacterisesystemButton
        function CharacterisesystemButtonPushed(app, event)
            % Creates the plot that illustrates the current choices of L, T
            % and K
            app.TabGroup.SelectedTab = app.TabGroup.Children(1);
            app.DELAY=tf(1,1,'iodelay',app.delay);

            [y,t]=step(app.G*app.DELAY,app.runtime);
            plot(app.UIAxes2,t,y,'linewidth',2)
            T = app.TimeconstantTSlider.Value;
            K = app.GainKSlider.Value;
            L = app.DelayLSlider.Value;
            hold(app.UIAxes2,'on')
            plot(app.UIAxes2,[1,1]*L,[-0.2,0.5],'r--','linewidth',2)
            plot(app.UIAxes2,[L+0.1,T+L+0.3],[1,1]*0.63*K,'m:','linewidth',2)
            plot(app.UIAxes2,[1,1]*(L+T),[-0,K],'m:','linewidth',2)
            plot(app.UIAxes2,[0,app.runtime],[1,1]*K,'g-.','linewidth',2)
            
            text(app.UIAxes2,T+L+0.4,K*0.6,'63% line','fontsize',16)
            text(app.UIAxes2,L+0.1,K*0.2,'L','fontsize',20)
            text(app.UIAxes2,T+L,K*0.4,'T+L','fontsize',20)
            text(app.UIAxes2,app.runtime*0.8,K*1.01,'K','fontsize',20)
            title(app.UIAxes2,'Step response with estimated parameters')
            hold(app.UIAxes2,'off')
            grid(app.UIAxes2,'on')

            app = define_PID_laws(app);
            updateTransferFunctionRender(app); % ensure current compensator showing

            % Update text boxes showing current options
            app.GslabelLabel_2.Text = app.TuningruleDropDown.Value;
            app.GslabelLabel_3.Text = ['Kp = ',num2str(app.Kp1)];
            app.GslabelLabel_5.Text = ['Ki = ',num2str(app.Ki2)];
            app.GslabelLabel_4.Text = ['Kp = ',num2str(app.Kp2)];
            app.GslabelLabel_6.Text = ['Kp = ',num2str(app.Kp3)];
            app.GslabelLabel_7.Text = ['Ki = ',num2str(app.Ki3)];
            app.GslabelLabel_8.Text = ['Kd = ',num2str(app.Kd3)];
            
        end

        % Button pushed function: CreateresponsesButton
        function CreateresponsesButtonPushed(app, event)
            % define the compensators, sensitivities and closed-loop
            % responses and then create the plots
            app.TabGroup.SelectedTab = app.TabGroup.Children(2);


            switch app.TuningruleDropDown.Value
                case 'All PID'
                    app.OverlaymultipletuningButton.Text ='Overlay multiple tuning';
                    overlayalllaws(app,'PID')
                case 'All PI'
                    app.OverlaymultipletuningButton.Text ='Overlay multiple tuning';
                    overlayalllaws(app,'PI')
                otherwise 
            
          
            
            app = define_PID_laws(app);  % defines all the PID laws
            

            % options = [P,PI,PID]    logical variable
            % calculate and plot the closed-loop responses for P, PI and
            % PID as needed
            legstring = cell(1);
            switch app.ControllawDropDown.Value
                case 'P';  
                    options = logical([1 0 0]);
                    legstring{1} = 'Proportional';
                    
                case 'PI'; 
                    options = logical([0 1 0]);
                    legstring{1} = 'PI';
                    
                case 'PID'; 
                    options = logical([0 0 1]);
                    legstring{1} = 'PID';
                    
                case 'All'; 
                    options = logical([1 1 1]);
                    legstring{1}='P'; legstring{2}='PI'; legstring{3} = 'PID';
                    

                case 'PID and PI'; 
                    options = logical([0 1 1]);
                    legstring{1}='PI'; legstring{2}='PID';
                    

            end
             updateTransferFunctionRender(app); % ensure current compensator showing
            % Manage plots according to the drop down choices
            
            
            % manage the legend for overlays or not
            switch app.OverlaymultipletuningButton.Text;
                case 'Stop overlaying';
                  app.kk = app.kk+1;
                  
                  switch app.TuningruleDropDown.Value % Text depends on tuning rule or manual
                      case 'Manual Choice'; % Display the Kp, Ki, Kd values
                          app.templegstring{app.kk} = ['K_p = ',num2str(app.KpSlider.Value),', K_i = ', ...
                              num2str(app.KiSlider.Value),', K_d = ', num2str(app.KdSlider.Value), ', Manual'];
                      otherwise % Display the L,T, K values
                        app.templegstring{app.kk} = ['L = ',num2str(app.DelayLSlider.Value),', T = ',...
                       num2str(app.TimeconstantTSlider.Value),', K = ',num2str(app.GainKSlider.Value),...
                      ', ',app.ControllawDropDown.Value,', ',app.TuningruleDropDown.Value];
                    
                  end
                  legstring = app.templegstring;
                otherwise  
                 cleantab2(app)  % removes existing plots
            
                 
            end

            if options(1);
               app.YP = updateresponses(app,app.SP);
               holdtab2(app)
               
            end
            if options(2);
               app.YPI = updateresponses(app,app.SPI);
               holdtab2(app);
              
            end
            if options(3);
               app.YPID = updateresponses(app,app.SPID);
               holdtab2(app)
            end
            legend(app.UIAxes_2,legstring)
            
             
            end % switch at very top of subfunction

         

             
        end

        % Button pushed function: OverlaymultipletuningButton
        function OverlaymultipletuningButtonPushed(app, event)
          %  The idea here is to compare the different control laws, but for a single option
          % define the compensators, sensitivities and closed-loop
          % responses and then create the plots

          % make sure just a single control law selected
          value = app.ControllawDropDown.Value;
          switch value
              case 'PI'

              case 'PID'

              otherwise
                  app.ControllawDropDown.Value = 'PID';
          end

          % update the text box
          textstring = app.OverlaymultipletuningButton.Text;
          switch textstring
              case 'Overlay multiple tuning';
                 app.OverlaymultipletuningButton.Text = 'Stop overlaying';
                 app.templegstring = cell(1);
                 app.kk=0;
                 if or(strcmp(app.TuningruleDropDown.Value,'All PI'),...
                     strcmp(app.TuningruleDropDown.Value,'All PID'))
                     app.TuningruleDropDown.Value = 'AMIGO';
                 end

              otherwise
                  app.OverlaymultipletuningButton.Text ='Overlay multiple tuning';
          end

           cleantab2(app)   % first  clean all figures
           CreateresponsesButtonPushed(app);
           holdtab2(app)  % now insure that figures do not change
            
             
        end

        % Value changed function: TimeconstantTSlider
        function TimeconstantTSliderValueChanged(app, event)
            value = app.TimeconstantTSlider.Value;
            value = round(value,2);
            if value==0;value=0.2;end
            app.TimeconstantTSlider.Value=value;
            CharacterisesystemButtonPushed(app);

        end

        % Value changed function: DelayLSlider
        function DelayLSliderValueChanged(app, event)
            value = app.DelayLSlider.Value;
            value=round(value,2);
            if value==0;value =0.01;end
            app.DelayLSlider.Value=value;
            CharacterisesystemButtonPushed(app);
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

        % Value changed function: GainKSlider
        function GainKSliderValueChanged(app, event)
            value = app.GainKSlider.Value;
            value=round(value,2);
            if value==0; value =0.1;end
            app.GainKSlider.Value=value;
            CharacterisesystemButtonPushed(app);
            %TabGroupSelectionChanged(app)
        end

        % Value changed function: ControllawDropDown
        function ControllawDropDownValueChanged(app, event)
            value = app.ControllawDropDown.Value;
            % if and(strcmp(value,'All'),or(strcmp(app.TuningruleDropDown.Value,'All PI'),...
            %     strcmp(app.TuningruleDropDown.Value,'All PID')))
            % app.TuningruleDropDown.Value = 'AMIGO';
            % end

            TabGroupSelectionChanged(app)
           
        end

        % Value changed function: TuningruleDropDown
        function TuningruleDropDownValueChanged(app, event)
            value = app.TuningruleDropDown.Value;
            % if and(strcmp(app.ControllawDropDown.Value,'All'),or(strcmp(app.TuningruleDropDown.Value,'All PI'),...
            %     strcmp(app.TuningruleDropDown.Value,'All PID')))
            % app.TuningruleDropDown.Value = 'AMIGO';
            % end
            
            TabGroupSelectionChanged(app)
            
        end

        % Value changed function: KdSlider
        function KdSliderValueChanged(app, event)
            value = app.KdSlider.Value;
            value=round(value,2);
            
            app.KdSlider.Value=value;
            %TabGroupSelectionChanged(app)
        end

        % Value changed function: KiSlider
        function KiSliderValueChanged(app, event)
            value = app.KiSlider.Value;
            value=round(value,2);
            
            app.KiSlider.Value=value;
            %TabGroupSelectionChanged(app)
        end

        % Value changed function: KpSlider
        function KpSliderValueChanged(app, event)
            value = app.KpSlider.Value;
            value=round(value,2);
            
            app.KpSlider.Value=value;
            %TabGroupSelectionChanged(app)
        end

        % Clicked callback: SecondorderDropDown
        function SecondorderDropDownClicked(app, event)
            item = event.InteractionInformation.Item;
            value = app.SecondorderDropDown.Value;
            
            switch value
                case '6/[(s+5)(s+1)]'; 
                    app.G =tf(6,[1 6 5]);
                    app.runtime =8;
                    T=1;K=1;L=0.1;
                    Td=0.8; % target closed-loop time constant
                    app.KpSlider.Value = 0.8;
                    app.KiSlider.Value = 0.6;
                    app.KdSlider.Value = 0;
                case '2.1/[(s+1)(s+2)]'; 
                    app.G = tf(2.1,[1 3 2]);
                    app.runtime =8;
                    T=2;K=1;L=0.1;
                    Td=1.5; % target closed-loop time constant
                    app.KpSlider.Value = 1;
                    app.KiSlider.Value = 1.2;
                    app.KdSlider.Value = 0;
                case '1.2(s+1)/[(s+0.5)(s+2)]'; 
                    app.G = tf(1.2*[1 1],[1 2.5 1]);
                    app.runtime =8;
                    T=1.2;K=1.1;L=0.1;
                    Td=2; % target closed-loop time constant
                    app.KpSlider.Value = 1.2;
                    app.KiSlider.Value = 0.8;
                    app.KdSlider.Value = 0;
                case '(s+15)/[(s+3)(s+5)]'; 
                    app.G = tf([1 15],[1 8 15]);
                    app.runtime =2.5;
                    T=0.4;K=1;L=0.05;
                    Td=0.4; % target closed-loop time constant
                    app.KpSlider.Value = 1;
                    app.KiSlider.Value = 2;
                    app.KdSlider.Value = 0;
                case '12/[(s^2+2s+10)]'; 
                    app.G = tf([12],[1 2 10]);
                    app.runtime =4;
                    T=0.4;K=1;L=0.1;
                    Td=0.4; % target closed-loop time constant
                    app.KpSlider.Value = 0.8;
                    app.KiSlider.Value = 0.4;
                    app.KdSlider.Value = 0;
                case '8/[(s^2+s+10)]'; 
                    app.G = tf([8],[1 1 10]);
                    app.runtime =5;
                    T=0.4;K=1;L=0.1;
                    Td=0.4; % target closed-loop time constant
                    app.KpSlider.Value = 1;
                    app.KiSlider.Value = 1;
                    app.KdSlider.Value = 0;
                case '10(s+1)/[(s^2+4s+10)]'; 
                    app.G = tf(10*[1 1],[1 4 10]);
                    app.runtime =2;
                    T=0.1;K=1;L=0.01;
                    Td=0.1; % target closed-loop time constant
                    app.KpSlider.Value = 1;
                    app.KiSlider.Value = 2;
                    app.KdSlider.Value = 0;
                case '20(1-s)/[s^2+20]'; 
                    app.G =tf(20*[-1 1],[1 0 20]);
                    app.runtime =4;
                    T=1;K=1;L=0.1;
                    Td=0.8; % target closed-loop time constant
                    app.KpSlider.Value = 0.8;
                    app.KiSlider.Value = 0.6;
                    app.KdSlider.Value = 0;
                    

                    
            end
            app.TimeconstantTSlider.Value = T;
            app.GainKSlider.Value = K;
            app.DelayLSlider.Value = L;
            app.Td= Td;
            CharacterisesystemButtonPushed(app);
        end

        % Clicked callback: HighorderDropDown
        function HighorderDropDownClicked(app, event)
            item = event.InteractionInformation.Item;
            value = app.HighorderDropDown.Value;
            
            
            switch value
                case '20/[(s+10)(s+1)(s+2)]'; 
                    app.G =tf(20,poly([-10 -1 -2]));
                    app.runtime =6;
                    T=2;K=1;L=0.3;
                    Td=1.5; % target closed-loop time constant
                    app.KpSlider.Value = 1;
                    app.KiSlider.Value = 1.2;
                    app.KdSlider.Value = 0;
                case '10/[(s+1)(s+2)(s+4)]'; 
                    app.G = tf(10,[1 7 14 8]);
                    app.runtime =5;
                    T=1;K=1;L=0.3;
                    Td=0.8; % target closed-loop time constant
                    app.KpSlider.Value = 0.8;
                    app.KiSlider.Value = 1;
                    app.KdSlider.Value = 0;
                case '8.5(s+2)/[(s+5)(s+1)(s+4)]'; 
                    app.G = tf(8.5*[1 2],poly([-5 -1 -4]));
                    app.runtime =6;
                    T=1.2;K=1;L=0.2;
                    Td=1; % target closed-loop time constant
                    app.KpSlider.Value = 1.2;
                    app.KiSlider.Value = 1;
                    app.KdSlider.Value = 0;
                case '0.6(s+4)/[(s+1)(s+1)(s+2)]'; 
                    app.G = tf(0.6*[1 4],[1 4 5 2]);
                    app.runtime =6;
                    T=2;K=1;L=0.4;
                    Td=1.5; % target closed-loop time constant
                    app.KpSlider.Value = 0.8;
                    app.KiSlider.Value = 0.6;
                    app.KdSlider.Value = 0;
               case '10(s+2)/[(s+1)(s^2+0.4s+16)]'; 
                    app.G = tf(10*[1 2],[1 1.4 16.4 16]);
                    app.runtime =6;
                    T=0.4;K=1;L=0.1;
                    Td=0.4; % target closed-loop time constant
                    app.KpSlider.Value = 0.5;
                    app.KiSlider.Value = 0.02;
                    app.KdSlider.Value = 0;
               case '10(4-s)/[(s+3)(s+3)(s+6)]'; 
                    app.G = tf(100*[-0.1 0.4],poly([-3 -3 -6]));
                    app.runtime =6;
                    T=0.4;K=0.9;L=0.5;
                    Td=0.6; % target closed-loop time constant
                    app.KpSlider.Value = 1;
                    app.KiSlider.Value = 0.3;
                    app.KdSlider.Value = 0;
               case '8^8/[(s+8)^8)]'; 
                    app.G = tf(8^8,poly([-1 -1 -1 -1 -1 -1 -1 -1]*8));
                    app.runtime =4;
                    T=0.4;K=0.9;L=0.5;
                    Td=0.6; % target closed-loop time constant
                    app.KpSlider.Value = 1;
                    app.KiSlider.Value = 0.3;
                    app.KdSlider.Value = 0;
                    

            end
            app.TimeconstantTSlider.Value = T;
            app.GainKSlider.Value = K;
            app.DelayLSlider.Value = L;
            app.Td= Td;
            CharacterisesystemButtonPushed(app);
        end

        % Selection change function: TabGroup
        function TabGroupSelectionChanged(app, event)
            selectedTab = app.TabGroup.SelectedTab;
            switch selectedTab
                case app.TabGroup.Children(1)
                    CharacterisesystemButtonPushed(app);
                case app.TabGroup.Children(2)
                    CreateresponsesButtonPushed(app);
            end
            
        end

        % Value changed function: SystemdelaySlider
        function SystemdelaySliderValueChanged(app, event)
            value = app.SystemdelaySlider.Value;
            value = round(value,2);
            app.SystemdelaySlider.Value = value;
            app.delay=value;
            CharacterisesystemButtonPushed(app);
            

        end

        % Button pushed function: ZNButton
        function ZNButtonPushed(app, event)
            Value = app.ZNButton.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.ZNButton.BackgroundColor = [1 0 0];
            else
                    app.ZNButton.BackgroundColor = [0.4,0.8,0.1];
            end

        end

        % Button pushed function: CohenCoonButton
        function CohenCoonButtonPushed(app, event)
            Value = app.CohenCoonButton.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.CohenCoonButton.BackgroundColor = [1 0 0];
            else
                    app.CohenCoonButton.BackgroundColor = [0.4,0.8,0.1];
            end
        end

        % Button pushed function: AMIGOButton
        function AMIGOButtonPushed(app, event)
            Value = app.AMIGOButton.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.AMIGOButton.BackgroundColor = [1 0 0];
            else
                    app.AMIGOButton.BackgroundColor = [0.4,0.8,0.1];
            end
        end

        % Button pushed function: LambdaButton
        function LambdaButtonPushed(app, event)
            Value = app.LambdaButton.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.LambdaButton.BackgroundColor = [1 0 0];
            else
                    app.LambdaButton.BackgroundColor = [0.4,0.8,0.1];
            end
        end

        % Button pushed function: OnethirdButton
        function OnethirdButtonPushed(app, event)
            Value = app.OnethirdButton.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.OnethirdButton.BackgroundColor = [1 0 0];
            else
                    app.OnethirdButton.BackgroundColor = [0.4,0.8,0.1];
            end
        end

        % Button pushed function: ManualButton
        function ManualButtonPushed(app, event)
            Value = app.ManualButton.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.ManualButton.BackgroundColor = [1 0 0];
            else
                    app.ManualButton.BackgroundColor = [0.4,0.8,0.1];
            end
        end

        % Button pushed function: SkogestadButton
        function SkogestadButtonPushed(app, event)
            Value = app.SkogestadButton.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.SkogestadButton.BackgroundColor = [1 0 0];
            else
                    app.SkogestadButton.BackgroundColor = [0.4,0.8,0.1];
            end
        end

        % Button pushed function: CHRButton
        function CHRButtonPushed(app, event)
            Value = app.CHRButton.BackgroundColor;
            if Value== [0.4,0.8,0.1]
                    app.CHRButton.BackgroundColor = [1 0 0];
            else
                    app.CHRButton.BackgroundColor = [0.4,0.8,0.1];
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
            app.UIFigure.Position = [100 100 1492 1065];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout.RowHeight = {'0.4x', '0.2x', '1x', '1x', '1x', '1x'};

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout2.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout2.Layout.Row = 3;
            app.GridLayout2.Layout.Column = 1;
            app.GridLayout2.BackgroundColor = [0.902 1 0.502];

            % Create ChoosesystemGsLabel
            app.ChoosesystemGsLabel = uilabel(app.GridLayout2);
            app.ChoosesystemGsLabel.BackgroundColor = [1 1 0];
            app.ChoosesystemGsLabel.HorizontalAlignment = 'center';
            app.ChoosesystemGsLabel.FontSize = 18;
            app.ChoosesystemGsLabel.FontWeight = 'bold';
            app.ChoosesystemGsLabel.Layout.Row = 1;
            app.ChoosesystemGsLabel.Layout.Column = [1 2];
            app.ChoosesystemGsLabel.Text = 'Choose system G(s)';

            % Create SecondorderDropDownLabel
            app.SecondorderDropDownLabel = uilabel(app.GridLayout2);
            app.SecondorderDropDownLabel.HorizontalAlignment = 'center';
            app.SecondorderDropDownLabel.FontSize = 18;
            app.SecondorderDropDownLabel.Layout.Row = 2;
            app.SecondorderDropDownLabel.Layout.Column = 1;
            app.SecondorderDropDownLabel.Text = 'Second order';

            % Create SecondorderDropDown
            app.SecondorderDropDown = uidropdown(app.GridLayout2);
            app.SecondorderDropDown.Items = {'6/[(s+5)(s+1)]', '2.1/[(s+1)(s+2)]', '1.2(s+1)/[(s+0.5)(s+2)]', '(s+15)/[(s+3)(s+5)]', '12/[(s^2+2s+10)]', '8/[(s^2+s+10)]', '10(s+1)/[(s^2+4s+10)]', '20(1-s)/[s^2+20]'};
            app.SecondorderDropDown.FontSize = 18;
            app.SecondorderDropDown.Layout.Row = 2;
            app.SecondorderDropDown.Layout.Column = 2;
            app.SecondorderDropDown.ClickedFcn = createCallbackFcn(app, @SecondorderDropDownClicked, true);
            app.SecondorderDropDown.Value = '6/[(s+5)(s+1)]';

            % Create HighorderDropDownLabel
            app.HighorderDropDownLabel = uilabel(app.GridLayout2);
            app.HighorderDropDownLabel.HorizontalAlignment = 'center';
            app.HighorderDropDownLabel.FontSize = 18;
            app.HighorderDropDownLabel.Layout.Row = 3;
            app.HighorderDropDownLabel.Layout.Column = 1;
            app.HighorderDropDownLabel.Text = 'High order';

            % Create HighorderDropDown
            app.HighorderDropDown = uidropdown(app.GridLayout2);
            app.HighorderDropDown.Items = {'20/[(s+10)(s+1)(s+2)]', '10/[(s+1)(s+2)(s+4)]', '8.5(s+2)/[(s+5)(s+1)(s+4)]', '0.6(s+4)/[(s+1)(s+1)(s+2)]', '10(s+2)/[(s+1)(s^2+0.4s+16)]', '10(4-s)/[(s+3)(s+3)(s+6)]', '8^8/[(s+8)^8)]'};
            app.HighorderDropDown.FontSize = 18;
            app.HighorderDropDown.Layout.Row = 3;
            app.HighorderDropDown.Layout.Column = 2;
            app.HighorderDropDown.ClickedFcn = createCallbackFcn(app, @HighorderDropDownClicked, true);
            app.HighorderDropDown.Value = '20/[(s+10)(s+1)(s+2)]';

            % Create SystemdelaySliderLabel
            app.SystemdelaySliderLabel = uilabel(app.GridLayout2);
            app.SystemdelaySliderLabel.HorizontalAlignment = 'center';
            app.SystemdelaySliderLabel.FontSize = 18;
            app.SystemdelaySliderLabel.Layout.Row = 4;
            app.SystemdelaySliderLabel.Layout.Column = 1;
            app.SystemdelaySliderLabel.Text = 'System delay';

            % Create SystemdelaySlider
            app.SystemdelaySlider = uislider(app.GridLayout2);
            app.SystemdelaySlider.Limits = [0 0.5];
            app.SystemdelaySlider.ValueChangedFcn = createCallbackFcn(app, @SystemdelaySliderValueChanged, true);
            app.SystemdelaySlider.FontSize = 18;
            app.SystemdelaySlider.Layout.Row = 4;
            app.SystemdelaySlider.Layout.Column = 2;

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout);
            app.GridLayout3.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout3.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout3.Layout.Row = 4;
            app.GridLayout3.Layout.Column = 1;
            app.GridLayout3.BackgroundColor = [1 0.8 0.6];

            % Create EstimateparametersusedinautotuningLabel
            app.EstimateparametersusedinautotuningLabel = uilabel(app.GridLayout3);
            app.EstimateparametersusedinautotuningLabel.BackgroundColor = [1 0.502 0.302];
            app.EstimateparametersusedinautotuningLabel.HorizontalAlignment = 'center';
            app.EstimateparametersusedinautotuningLabel.FontSize = 18;
            app.EstimateparametersusedinautotuningLabel.FontWeight = 'bold';
            app.EstimateparametersusedinautotuningLabel.Layout.Row = 1;
            app.EstimateparametersusedinautotuningLabel.Layout.Column = [1 2];
            app.EstimateparametersusedinautotuningLabel.Text = 'Estimate parameters used in auto-tuning';

            % Create DelayLSliderLabel
            app.DelayLSliderLabel = uilabel(app.GridLayout3);
            app.DelayLSliderLabel.HorizontalAlignment = 'right';
            app.DelayLSliderLabel.FontSize = 18;
            app.DelayLSliderLabel.Layout.Row = 2;
            app.DelayLSliderLabel.Layout.Column = 1;
            app.DelayLSliderLabel.Text = 'Delay (L)';

            % Create DelayLSlider
            app.DelayLSlider = uislider(app.GridLayout3);
            app.DelayLSlider.Limits = [0 0.5];
            app.DelayLSlider.ValueChangedFcn = createCallbackFcn(app, @DelayLSliderValueChanged, true);
            app.DelayLSlider.FontSize = 18;
            app.DelayLSlider.Layout.Row = 2;
            app.DelayLSlider.Layout.Column = 2;
            app.DelayLSlider.Value = 0.3;

            % Create TimeconstantTSliderLabel
            app.TimeconstantTSliderLabel = uilabel(app.GridLayout3);
            app.TimeconstantTSliderLabel.HorizontalAlignment = 'right';
            app.TimeconstantTSliderLabel.FontSize = 18;
            app.TimeconstantTSliderLabel.Layout.Row = 3;
            app.TimeconstantTSliderLabel.Layout.Column = 1;
            app.TimeconstantTSliderLabel.Text = 'Time constant (T)';

            % Create TimeconstantTSlider
            app.TimeconstantTSlider = uislider(app.GridLayout3);
            app.TimeconstantTSlider.Limits = [0 3];
            app.TimeconstantTSlider.ValueChangedFcn = createCallbackFcn(app, @TimeconstantTSliderValueChanged, true);
            app.TimeconstantTSlider.FontSize = 18;
            app.TimeconstantTSlider.Layout.Row = 3;
            app.TimeconstantTSlider.Layout.Column = 2;
            app.TimeconstantTSlider.Value = 1.5;

            % Create GainKSliderLabel
            app.GainKSliderLabel = uilabel(app.GridLayout3);
            app.GainKSliderLabel.HorizontalAlignment = 'right';
            app.GainKSliderLabel.FontSize = 18;
            app.GainKSliderLabel.Layout.Row = 4;
            app.GainKSliderLabel.Layout.Column = 1;
            app.GainKSliderLabel.Text = 'Gain (K)';

            % Create GainKSlider
            app.GainKSlider = uislider(app.GridLayout3);
            app.GainKSlider.Limits = [0 1.5];
            app.GainKSlider.ValueChangedFcn = createCallbackFcn(app, @GainKSliderValueChanged, true);
            app.GainKSlider.FontSize = 18;
            app.GainKSlider.Layout.Row = 4;
            app.GainKSlider.Layout.Column = 2;
            app.GainKSlider.Value = 1.1;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout);
            app.GridLayout5.ColumnWidth = {'1.4x', '1x'};
            app.GridLayout5.RowHeight = {'1x'};
            app.GridLayout5.Layout.Row = 1;
            app.GridLayout5.Layout.Column = [2 3];
            app.GridLayout5.BackgroundColor = [0.6 1 1];

            % Create ComparisonofPIDtuningrulesLabel
            app.ComparisonofPIDtuningrulesLabel = uilabel(app.GridLayout5);
            app.ComparisonofPIDtuningrulesLabel.BackgroundColor = [0 1 1];
            app.ComparisonofPIDtuningrulesLabel.HorizontalAlignment = 'center';
            app.ComparisonofPIDtuningrulesLabel.FontSize = 24;
            app.ComparisonofPIDtuningrulesLabel.FontWeight = 'bold';
            app.ComparisonofPIDtuningrulesLabel.Layout.Row = 1;
            app.ComparisonofPIDtuningrulesLabel.Layout.Column = 1;
            app.ComparisonofPIDtuningrulesLabel.Text = 'Comparison of PID tuning rules';

            % Create ThecompensatorshowingwillbnelinkedtothelastinteractionLabel
            app.ThecompensatorshowingwillbnelinkedtothelastinteractionLabel = uilabel(app.GridLayout5);
            app.ThecompensatorshowingwillbnelinkedtothelastinteractionLabel.BackgroundColor = [0.6 1 1];
            app.ThecompensatorshowingwillbnelinkedtothelastinteractionLabel.WordWrap = 'on';
            app.ThecompensatorshowingwillbnelinkedtothelastinteractionLabel.FontSize = 16;
            app.ThecompensatorshowingwillbnelinkedtothelastinteractionLabel.Layout.Row = 1;
            app.ThecompensatorshowingwillbnelinkedtothelastinteractionLabel.Layout.Column = 2;
            app.ThecompensatorshowingwillbnelinkedtothelastinteractionLabel.Text = 'The compensator showing will be linked to the drop-down selections (e.g. auto-tuned or manual, PI or PID). Flat responses are shown when the loop is unstable.';

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.ColumnWidth = {'1x', '0.9x', '1.1x'};
            app.GridLayout6.RowHeight = {'1x'};
            app.GridLayout6.Layout.Row = [1 2];
            app.GridLayout6.Layout.Column = 1;
            app.GridLayout6.BackgroundColor = [1 0.6 0.8];

            % Create CharacterisesystemButton
            app.CharacterisesystemButton = uibutton(app.GridLayout6, 'push');
            app.CharacterisesystemButton.ButtonPushedFcn = createCallbackFcn(app, @CharacterisesystemButtonPushed, true);
            app.CharacterisesystemButton.WordWrap = 'on';
            app.CharacterisesystemButton.BackgroundColor = [1 0.2 0.702];
            app.CharacterisesystemButton.FontSize = 20;
            app.CharacterisesystemButton.FontWeight = 'bold';
            app.CharacterisesystemButton.Layout.Row = 1;
            app.CharacterisesystemButton.Layout.Column = 1;
            app.CharacterisesystemButton.Text = 'Characterise system';

            % Create CreateresponsesButton
            app.CreateresponsesButton = uibutton(app.GridLayout6, 'push');
            app.CreateresponsesButton.ButtonPushedFcn = createCallbackFcn(app, @CreateresponsesButtonPushed, true);
            app.CreateresponsesButton.WordWrap = 'on';
            app.CreateresponsesButton.BackgroundColor = [1 0.2 0.702];
            app.CreateresponsesButton.FontSize = 20;
            app.CreateresponsesButton.FontWeight = 'bold';
            app.CreateresponsesButton.Layout.Row = 1;
            app.CreateresponsesButton.Layout.Column = 2;
            app.CreateresponsesButton.Text = 'Create responses';

            % Create OverlaymultipletuningButton
            app.OverlaymultipletuningButton = uibutton(app.GridLayout6, 'push');
            app.OverlaymultipletuningButton.ButtonPushedFcn = createCallbackFcn(app, @OverlaymultipletuningButtonPushed, true);
            app.OverlaymultipletuningButton.WordWrap = 'on';
            app.OverlaymultipletuningButton.BackgroundColor = [1 0.2 0.702];
            app.OverlaymultipletuningButton.FontSize = 20;
            app.OverlaymultipletuningButton.FontWeight = 'bold';
            app.OverlaymultipletuningButton.Layout.Row = 1;
            app.OverlaymultipletuningButton.Layout.Column = 3;
            app.OverlaymultipletuningButton.Text = 'Overlay multiple tuning';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.SelectionChangedFcn = createCallbackFcn(app, @TabGroupSelectionChanged, true);
            app.TabGroup.Layout.Row = [2 5];
            app.TabGroup.Layout.Column = [2 3];

            % Create CharacterisesystemTab
            app.CharacterisesystemTab = uitab(app.TabGroup);
            app.CharacterisesystemTab.Title = 'Characterise system';

            % Create GridLayout8
            app.GridLayout8 = uigridlayout(app.CharacterisesystemTab);
            app.GridLayout8.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.GridLayout8.RowHeight = {'1x', '1x', '1x', '1x', '1x'};

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout8);
            title(app.UIAxes2, 'Characterisation of step response')
            xlabel(app.UIAxes2, 'time (sec)')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 18;
            app.UIAxes2.Layout.Row = [1 4];
            app.UIAxes2.Layout.Column = [1 4];

            % Create GslabelLabel_2
            app.GslabelLabel_2 = uilabel(app.GridLayout8);
            app.GslabelLabel_2.BackgroundColor = [0.9294 0.6941 0.1255];
            app.GslabelLabel_2.HorizontalAlignment = 'center';
            app.GslabelLabel_2.FontSize = 18;
            app.GslabelLabel_2.Layout.Row = 5;
            app.GslabelLabel_2.Layout.Column = 1;
            app.GslabelLabel_2.Interpreter = 'latex';
            app.GslabelLabel_2.Text = 'Gslabel';

            % Create GslabelLabel_3
            app.GslabelLabel_3 = uilabel(app.GridLayout8);
            app.GslabelLabel_3.BackgroundColor = [0.9294 0.6941 0.1255];
            app.GslabelLabel_3.HorizontalAlignment = 'center';
            app.GslabelLabel_3.FontSize = 18;
            app.GslabelLabel_3.Layout.Row = 5;
            app.GslabelLabel_3.Layout.Column = 2;
            app.GslabelLabel_3.Interpreter = 'latex';
            app.GslabelLabel_3.Text = 'Gslabel';

            % Create GridLayout12
            app.GridLayout12 = uigridlayout(app.GridLayout8);
            app.GridLayout12.ColumnWidth = {'1x'};
            app.GridLayout12.Layout.Row = 5;
            app.GridLayout12.Layout.Column = 3;

            % Create GslabelLabel_4
            app.GslabelLabel_4 = uilabel(app.GridLayout12);
            app.GslabelLabel_4.BackgroundColor = [0.9294 0.6941 0.1255];
            app.GslabelLabel_4.HorizontalAlignment = 'center';
            app.GslabelLabel_4.FontSize = 18;
            app.GslabelLabel_4.Layout.Row = 1;
            app.GslabelLabel_4.Layout.Column = 1;
            app.GslabelLabel_4.Interpreter = 'latex';
            app.GslabelLabel_4.Text = 'Gslabel';

            % Create GslabelLabel_5
            app.GslabelLabel_5 = uilabel(app.GridLayout12);
            app.GslabelLabel_5.BackgroundColor = [0.9294 0.6941 0.1255];
            app.GslabelLabel_5.HorizontalAlignment = 'center';
            app.GslabelLabel_5.FontSize = 18;
            app.GslabelLabel_5.Layout.Row = 2;
            app.GslabelLabel_5.Layout.Column = 1;
            app.GslabelLabel_5.Interpreter = 'latex';
            app.GslabelLabel_5.Text = 'Gslabel';

            % Create GridLayout13
            app.GridLayout13 = uigridlayout(app.GridLayout8);
            app.GridLayout13.ColumnWidth = {'1x'};
            app.GridLayout13.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout13.Layout.Row = 5;
            app.GridLayout13.Layout.Column = 4;

            % Create GslabelLabel_6
            app.GslabelLabel_6 = uilabel(app.GridLayout13);
            app.GslabelLabel_6.BackgroundColor = [0.9294 0.6941 0.1255];
            app.GslabelLabel_6.HorizontalAlignment = 'center';
            app.GslabelLabel_6.FontSize = 18;
            app.GslabelLabel_6.Layout.Row = 1;
            app.GslabelLabel_6.Layout.Column = 1;
            app.GslabelLabel_6.Interpreter = 'latex';
            app.GslabelLabel_6.Text = 'Gslabel';

            % Create GslabelLabel_7
            app.GslabelLabel_7 = uilabel(app.GridLayout13);
            app.GslabelLabel_7.BackgroundColor = [0.9294 0.6941 0.1255];
            app.GslabelLabel_7.HorizontalAlignment = 'center';
            app.GslabelLabel_7.FontSize = 18;
            app.GslabelLabel_7.Layout.Row = 2;
            app.GslabelLabel_7.Layout.Column = 1;
            app.GslabelLabel_7.Interpreter = 'latex';
            app.GslabelLabel_7.Text = 'Gslabel';

            % Create GslabelLabel_8
            app.GslabelLabel_8 = uilabel(app.GridLayout13);
            app.GslabelLabel_8.BackgroundColor = [0.9294 0.6941 0.1255];
            app.GslabelLabel_8.HorizontalAlignment = 'center';
            app.GslabelLabel_8.FontSize = 18;
            app.GslabelLabel_8.Layout.Row = 3;
            app.GslabelLabel_8.Layout.Column = 1;
            app.GslabelLabel_8.Interpreter = 'latex';
            app.GslabelLabel_8.Text = 'Gslabel';

            % Create ClosedloopbehaviourTab
            app.ClosedloopbehaviourTab = uitab(app.TabGroup);
            app.ClosedloopbehaviourTab.Title = 'Closed-loop behaviour';

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.ClosedloopbehaviourTab);
            app.GridLayout7.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout7.RowHeight = {'1.5x', '1x', '1x'};

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout7);
            title(app.UIAxes, 'Output response to target')
            xlabel(app.UIAxes, 'Time (s)')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Layout.Row = 1;
            app.UIAxes.Layout.Column = [1 3];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.GridLayout7);
            title(app.UIAxes_2, 'Input response to target')
            xlabel(app.UIAxes_2, 'Time (s)')
            zlabel(app.UIAxes_2, 'Z')
            app.UIAxes_2.Layout.Row = 1;
            app.UIAxes_2.Layout.Column = [4 6];

            % Create UIAxes_3
            app.UIAxes_3 = uiaxes(app.GridLayout7);
            title(app.UIAxes_3, 'Output response to output disturbance')
            xlabel(app.UIAxes_3, 'Time (s)')
            zlabel(app.UIAxes_3, 'Z')
            app.UIAxes_3.Layout.Row = 2;
            app.UIAxes_3.Layout.Column = [1 2];

            % Create UIAxes_4
            app.UIAxes_4 = uiaxes(app.GridLayout7);
            title(app.UIAxes_4, 'Input response to output disturbance')
            xlabel(app.UIAxes_4, 'Time (s)')
            zlabel(app.UIAxes_4, 'Z')
            app.UIAxes_4.Layout.Row = 3;
            app.UIAxes_4.Layout.Column = [1 2];

            % Create UIAxes_5
            app.UIAxes_5 = uiaxes(app.GridLayout7);
            title(app.UIAxes_5, 'Output response to input disturbance')
            xlabel(app.UIAxes_5, 'Time (s)')
            zlabel(app.UIAxes_5, 'Z')
            app.UIAxes_5.Layout.Row = 2;
            app.UIAxes_5.Layout.Column = [3 4];

            % Create UIAxes_6
            app.UIAxes_6 = uiaxes(app.GridLayout7);
            title(app.UIAxes_6, 'Input response to input disturbance')
            xlabel(app.UIAxes_6, 'Time (s)')
            zlabel(app.UIAxes_6, 'Z')
            app.UIAxes_6.Layout.Row = 3;
            app.UIAxes_6.Layout.Column = [3 4];

            % Create UIAxes_7
            app.UIAxes_7 = uiaxes(app.GridLayout7);
            title(app.UIAxes_7, 'Output response to measurement noise')
            xlabel(app.UIAxes_7, 'Time (s)')
            zlabel(app.UIAxes_7, 'Z')
            app.UIAxes_7.Layout.Row = 2;
            app.UIAxes_7.Layout.Column = [5 6];

            % Create UIAxes_8
            app.UIAxes_8 = uiaxes(app.GridLayout7);
            title(app.UIAxes_8, 'Input response to measurement noise')
            xlabel(app.UIAxes_8, 'Time (s)')
            zlabel(app.UIAxes_8, 'Z')
            app.UIAxes_8.Layout.Row = 3;
            app.UIAxes_8.Layout.Column = [5 6];

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.GridLayout);
            app.GridLayout9.ColumnWidth = {'1x', '3x'};
            app.GridLayout9.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout9.Layout.Row = 6;
            app.GridLayout9.Layout.Column = 1;
            app.GridLayout9.BackgroundColor = [1 0.8 0.6];

            % Create ManuallyselectPIDparametersMsLabel
            app.ManuallyselectPIDparametersMsLabel = uilabel(app.GridLayout9);
            app.ManuallyselectPIDparametersMsLabel.BackgroundColor = [1 0.502 0.302];
            app.ManuallyselectPIDparametersMsLabel.HorizontalAlignment = 'center';
            app.ManuallyselectPIDparametersMsLabel.FontSize = 18;
            app.ManuallyselectPIDparametersMsLabel.FontWeight = 'bold';
            app.ManuallyselectPIDparametersMsLabel.Layout.Row = 1;
            app.ManuallyselectPIDparametersMsLabel.Layout.Column = [1 2];
            app.ManuallyselectPIDparametersMsLabel.Text = 'Manually select PID parameters M(s)';

            % Create KpSliderLabel
            app.KpSliderLabel = uilabel(app.GridLayout9);
            app.KpSliderLabel.HorizontalAlignment = 'center';
            app.KpSliderLabel.FontSize = 18;
            app.KpSliderLabel.Layout.Row = 2;
            app.KpSliderLabel.Layout.Column = 1;
            app.KpSliderLabel.Text = 'Kp';

            % Create KpSlider
            app.KpSlider = uislider(app.GridLayout9);
            app.KpSlider.Limits = [0 4];
            app.KpSlider.ValueChangedFcn = createCallbackFcn(app, @KpSliderValueChanged, true);
            app.KpSlider.FontSize = 18;
            app.KpSlider.Layout.Row = 2;
            app.KpSlider.Layout.Column = 2;
            app.KpSlider.Value = 1;

            % Create KiSliderLabel
            app.KiSliderLabel = uilabel(app.GridLayout9);
            app.KiSliderLabel.HorizontalAlignment = 'center';
            app.KiSliderLabel.FontSize = 18;
            app.KiSliderLabel.Layout.Row = 3;
            app.KiSliderLabel.Layout.Column = 1;
            app.KiSliderLabel.Text = 'Ki';

            % Create KiSlider
            app.KiSlider = uislider(app.GridLayout9);
            app.KiSlider.Limits = [0 2];
            app.KiSlider.ValueChangedFcn = createCallbackFcn(app, @KiSliderValueChanged, true);
            app.KiSlider.FontSize = 18;
            app.KiSlider.Layout.Row = 3;
            app.KiSlider.Layout.Column = 2;
            app.KiSlider.Value = 0.5;

            % Create KdSliderLabel
            app.KdSliderLabel = uilabel(app.GridLayout9);
            app.KdSliderLabel.HorizontalAlignment = 'center';
            app.KdSliderLabel.FontSize = 18;
            app.KdSliderLabel.Layout.Row = 4;
            app.KdSliderLabel.Layout.Column = 1;
            app.KdSliderLabel.Text = 'Kd';

            % Create KdSlider
            app.KdSlider = uislider(app.GridLayout9);
            app.KdSlider.Limits = [0 4];
            app.KdSlider.ValueChangedFcn = createCallbackFcn(app, @KdSliderValueChanged, true);
            app.KdSlider.FontSize = 18;
            app.KdSlider.Layout.Row = 4;
            app.KdSlider.Layout.Column = 2;
            app.KdSlider.Value = 0.3;

            % Create GridLayout10
            app.GridLayout10 = uigridlayout(app.GridLayout);
            app.GridLayout10.ColumnWidth = {'1x', '3x'};
            app.GridLayout10.Layout.Row = 6;
            app.GridLayout10.Layout.Column = 2;
            app.GridLayout10.BackgroundColor = [1 1 1];

            % Create GsLabel
            app.GsLabel = uilabel(app.GridLayout10);
            app.GsLabel.BackgroundColor = [0.9294 0.6941 0.1255];
            app.GsLabel.HorizontalAlignment = 'center';
            app.GsLabel.FontSize = 18;
            app.GsLabel.Layout.Row = 1;
            app.GsLabel.Layout.Column = 1;
            app.GsLabel.Text = 'G(s)';

            % Create GslabelLabel
            app.GslabelLabel = uilabel(app.GridLayout10);
            app.GslabelLabel.BackgroundColor = [0.9294 0.6941 0.1255];
            app.GslabelLabel.HorizontalAlignment = 'center';
            app.GslabelLabel.FontSize = 18;
            app.GslabelLabel.Layout.Row = 1;
            app.GslabelLabel.Layout.Column = 2;
            app.GslabelLabel.Interpreter = 'latex';
            app.GslabelLabel.Text = 'Gslabel';

            % Create MsLabel
            app.MsLabel = uilabel(app.GridLayout10);
            app.MsLabel.BackgroundColor = [0.9294 0.6941 0.1255];
            app.MsLabel.HorizontalAlignment = 'center';
            app.MsLabel.FontSize = 18;
            app.MsLabel.Layout.Row = 2;
            app.MsLabel.Layout.Column = 1;
            app.MsLabel.Text = 'M(s)';

            % Create MslabelLabel
            app.MslabelLabel = uilabel(app.GridLayout10);
            app.MslabelLabel.BackgroundColor = [0.9294 0.6941 0.1255];
            app.MslabelLabel.HorizontalAlignment = 'center';
            app.MslabelLabel.FontSize = 18;
            app.MslabelLabel.Layout.Row = 2;
            app.MslabelLabel.Layout.Column = 2;
            app.MslabelLabel.Interpreter = 'latex';
            app.MslabelLabel.Text = 'Mslabel';

            % Create GridLayout11
            app.GridLayout11 = uigridlayout(app.GridLayout);
            app.GridLayout11.ColumnWidth = {'1x'};
            app.GridLayout11.RowHeight = {'1x'};
            app.GridLayout11.Layout.Row = 6;
            app.GridLayout11.Layout.Column = 3;

            % Create GridLayout14
            app.GridLayout14 = uigridlayout(app.GridLayout11);
            app.GridLayout14.Layout.Row = 1;
            app.GridLayout14.Layout.Column = 1;

            % Create Image
            app.Image = uiimage(app.GridLayout14);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 1;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'UoSlogo.png');

            % Create Image2
            app.Image2 = uiimage(app.GridLayout14);
            app.Image2.Layout.Row = 1;
            app.Image2.Layout.Column = 2;
            app.Image2.ImageSource = fullfile(pathToMLAPP, 'ruth_logo.jpg');

            % Create Image3
            app.Image3 = uiimage(app.GridLayout14);
            app.Image3.Layout.Row = 2;
            app.Image3.Layout.Column = 1;
            app.Image3.ImageSource = fullfile(pathToMLAPP, 'logo_brescia.png');

            % Create Image4
            app.Image4 = uiimage(app.GridLayout14);
            app.Image4.Layout.Row = 2;
            app.Image4.Layout.Column = 2;
            app.Image4.ImageSource = fullfile(pathToMLAPP, 'Logo-UNED.png');

            % Create GridLayout15
            app.GridLayout15 = uigridlayout(app.GridLayout);
            app.GridLayout15.ColumnWidth = {'2x', '1x'};
            app.GridLayout15.RowHeight = {'1x'};
            app.GridLayout15.Layout.Row = 5;
            app.GridLayout15.Layout.Column = 1;

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout15);
            app.GridLayout4.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout4.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout4.Layout.Row = 1;
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

            % Create TuningruleDropDownLabel
            app.TuningruleDropDownLabel = uilabel(app.GridLayout4);
            app.TuningruleDropDownLabel.HorizontalAlignment = 'center';
            app.TuningruleDropDownLabel.WordWrap = 'on';
            app.TuningruleDropDownLabel.FontSize = 18;
            app.TuningruleDropDownLabel.Layout.Row = 3;
            app.TuningruleDropDownLabel.Layout.Column = 1;
            app.TuningruleDropDownLabel.Text = 'Tuning rule';

            % Create TuningruleDropDown
            app.TuningruleDropDown = uidropdown(app.GridLayout4);
            app.TuningruleDropDown.Items = {'Ziegler Nichols', 'Cohen Coon', 'Skogestad', 'Chien-Hrones-Reswick', 'AMIGO', 'One-third tuning', 'Lambda tuning', 'Manual Choice', 'All PID', 'All PI'};
            app.TuningruleDropDown.ValueChangedFcn = createCallbackFcn(app, @TuningruleDropDownValueChanged, true);
            app.TuningruleDropDown.FontSize = 18;
            app.TuningruleDropDown.Layout.Row = 3;
            app.TuningruleDropDown.Layout.Column = 2;
            app.TuningruleDropDown.Value = 'Ziegler Nichols';

            % Create ControllawDropDownLabel
            app.ControllawDropDownLabel = uilabel(app.GridLayout4);
            app.ControllawDropDownLabel.HorizontalAlignment = 'center';
            app.ControllawDropDownLabel.FontSize = 18;
            app.ControllawDropDownLabel.Layout.Row = 2;
            app.ControllawDropDownLabel.Layout.Column = 1;
            app.ControllawDropDownLabel.Text = 'Control law';

            % Create ControllawDropDown
            app.ControllawDropDown = uidropdown(app.GridLayout4);
            app.ControllawDropDown.Items = {'P', 'PI', 'PID', 'PID and PI', 'All'};
            app.ControllawDropDown.ValueChangedFcn = createCallbackFcn(app, @ControllawDropDownValueChanged, true);
            app.ControllawDropDown.FontSize = 18;
            app.ControllawDropDown.Layout.Row = 2;
            app.ControllawDropDown.Layout.Column = 2;
            app.ControllawDropDown.Value = 'PI';

            % Create GridLayout16
            app.GridLayout16 = uigridlayout(app.GridLayout15);
            app.GridLayout16.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout16.Layout.Row = 1;
            app.GridLayout16.Layout.Column = 2;
            app.GridLayout16.BackgroundColor = [0.702 1 0.702];

            % Create ZNButton
            app.ZNButton = uibutton(app.GridLayout16, 'push');
            app.ZNButton.ButtonPushedFcn = createCallbackFcn(app, @ZNButtonPushed, true);
            app.ZNButton.BackgroundColor = [0.4 0.8 0.102];
            app.ZNButton.FontSize = 14;
            app.ZNButton.Layout.Row = 1;
            app.ZNButton.Layout.Column = 1;
            app.ZNButton.Text = 'ZN';

            % Create CohenCoonButton
            app.CohenCoonButton = uibutton(app.GridLayout16, 'push');
            app.CohenCoonButton.ButtonPushedFcn = createCallbackFcn(app, @CohenCoonButtonPushed, true);
            app.CohenCoonButton.WordWrap = 'on';
            app.CohenCoonButton.BackgroundColor = [1 0 0];
            app.CohenCoonButton.FontSize = 14;
            app.CohenCoonButton.Layout.Row = 1;
            app.CohenCoonButton.Layout.Column = 2;
            app.CohenCoonButton.Text = 'Cohen Coon';

            % Create AMIGOButton
            app.AMIGOButton = uibutton(app.GridLayout16, 'push');
            app.AMIGOButton.ButtonPushedFcn = createCallbackFcn(app, @AMIGOButtonPushed, true);
            app.AMIGOButton.BackgroundColor = [1 0 0];
            app.AMIGOButton.FontSize = 14;
            app.AMIGOButton.Layout.Row = 2;
            app.AMIGOButton.Layout.Column = 1;
            app.AMIGOButton.Text = 'AMIGO';

            % Create LambdaButton
            app.LambdaButton = uibutton(app.GridLayout16, 'push');
            app.LambdaButton.ButtonPushedFcn = createCallbackFcn(app, @LambdaButtonPushed, true);
            app.LambdaButton.BackgroundColor = [1 0 0];
            app.LambdaButton.FontSize = 14;
            app.LambdaButton.Layout.Row = 2;
            app.LambdaButton.Layout.Column = 2;
            app.LambdaButton.Text = 'Lambda';

            % Create OnethirdButton
            app.OnethirdButton = uibutton(app.GridLayout16, 'push');
            app.OnethirdButton.ButtonPushedFcn = createCallbackFcn(app, @OnethirdButtonPushed, true);
            app.OnethirdButton.WordWrap = 'on';
            app.OnethirdButton.BackgroundColor = [1 0 0];
            app.OnethirdButton.FontSize = 14;
            app.OnethirdButton.Layout.Row = 3;
            app.OnethirdButton.Layout.Column = 1;
            app.OnethirdButton.Text = 'One third';

            % Create ManualButton
            app.ManualButton = uibutton(app.GridLayout16, 'push');
            app.ManualButton.ButtonPushedFcn = createCallbackFcn(app, @ManualButtonPushed, true);
            app.ManualButton.BackgroundColor = [1 0 0];
            app.ManualButton.FontSize = 14;
            app.ManualButton.Layout.Row = 4;
            app.ManualButton.Layout.Column = 1;
            app.ManualButton.Text = 'Manual';

            % Create SkogestadButton
            app.SkogestadButton = uibutton(app.GridLayout16, 'push');
            app.SkogestadButton.ButtonPushedFcn = createCallbackFcn(app, @SkogestadButtonPushed, true);
            app.SkogestadButton.BackgroundColor = [1 0 0];
            app.SkogestadButton.FontSize = 14;
            app.SkogestadButton.Layout.Row = 3;
            app.SkogestadButton.Layout.Column = 2;
            app.SkogestadButton.Text = 'Skogestad';

            % Create CHRButton
            app.CHRButton = uibutton(app.GridLayout16, 'push');
            app.CHRButton.ButtonPushedFcn = createCallbackFcn(app, @CHRButtonPushed, true);
            app.CHRButton.BackgroundColor = [1 0 0];
            app.CHRButton.FontSize = 14;
            app.CHRButton.Layout.Row = 4;
            app.CHRButton.Layout.Column = 2;
            app.CHRButton.Text = 'CHR';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = pidtuningrules

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

