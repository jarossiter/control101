classdef PoleReplacement_control1011 < matlab.apps.AppBase
    %POLEREPLACEMENT_CONTROL1011
    %   This mlapp was written by Gyula Max and Ruth Bars, Budapest
    %   University of Technology and Economics
    %   
    %   The purpose of PoleReplacement.mlapp file is to define the
    %   continuous or the discrete PID controllers for a given plant (G(s))
    %   using the pole replacement method. By this method the transfer
    %   function of the continuous or the discrete controller can be
    %   determined easily and quickly. The application contains 3 sheets in
    %   the main layout.
    %   The purpose of PoleReplacement.mlapp file is to define the
    %   continuous or the discrete PID controllers for a given plant (G(s))
    %   using the pole replacement method. By this method the transfer
    %   function of the continuous or the discrete controller can be
    %   determined easily and quickly. The application contains 3 sheets in
    %   the main layout.
    %   
    %   Users should be familiar with PID controller design with pole
    %   replacement method. In the application the PID controller replaces
    %   the poles of the two largest time constants of the process. It
    %   replaces the largest time constant with a PI controller, ensuring
    %   that the asymptotic Bode diagram of the process begins at least
    %   with a slope of -20 dB/decade, while this range is extended by
    %   replacing also the second largest time constant. Knowing the open
    %   circuit, the gain of the controller is calculated ensuring a 60°
    %   phase margin ( Pm=60° ).
    %   
    %   A simple interface to practice the role of PID compensation for
    %   pole replacement control. Some notes and engineering background are
    %   in the partner livescript: Pole_replacement_manual.mlx

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        GridLayout                   matlab.ui.container.GridLayout
        Title_and_Image              matlab.ui.container.GridLayout
        Image                        matlab.ui.control.Image
        PolereplacementmethodLabel   matlab.ui.control.Label
        TabGroup                     matlab.ui.container.TabGroup
        SystemdetailsTab             matlab.ui.container.Tab
        GridLayout8                  matlab.ui.container.GridLayout
        UIAxes                       matlab.ui.control.UIAxes
        SystembehavioursTab          matlab.ui.container.Tab
        GridLayout7                  matlab.ui.container.GridLayout
        UIAxes_1                     matlab.ui.control.UIAxes
        UIAxes_2                     matlab.ui.control.UIAxes
        UIAxes_3                     matlab.ui.control.UIAxes
        UIAxes_4                     matlab.ui.control.UIAxes
        UIAxes_5                     matlab.ui.control.UIAxes
        UIAxes_6                     matlab.ui.control.UIAxes
        UpdateSummaryTab             matlab.ui.container.Tab
        ValidResults                 matlab.ui.container.GridLayout
        UIAxes_7                     matlab.ui.control.UIAxes
        BigButtons                   matlab.ui.container.GridLayout
        UpdateSystemdetailsButton    matlab.ui.control.Button
        SystembehavioursButton       matlab.ui.control.Button
        UpdateSummaryButton          matlab.ui.control.Button
        SystemDescription            matlab.ui.container.GridLayout
        SampletimesEditField         matlab.ui.control.NumericEditField
        SampletimesEditFieldLabel    matlab.ui.control.Label
        ControllertypeDropDown       matlab.ui.control.DropDown
        ControllertypeDropDownLabel  matlab.ui.control.Label
        UserschoiceDropDown          matlab.ui.control.DropDown
        UserschoiceDropDownLabel     matlab.ui.control.Label
        PlantDropDown                matlab.ui.control.DropDown
        PlantDropDownLabel           matlab.ui.control.Label
        SystemdescriptionGsandMsMzLabel  matlab.ui.control.Label
        ManualSelection              matlab.ui.container.GridLayout
        ManuallyselectedPIDparametersinUserschoiceMsLabel  matlab.ui.control.Label
        KpSlider                     matlab.ui.control.Slider
        TdSliderLabel                matlab.ui.control.Label
        TiSlider                     matlab.ui.control.Slider
        TiSliderLabel                matlab.ui.control.Label
        KpSliderLabel                matlab.ui.control.Label
        TdSlider                     matlab.ui.control.Slider
        MessagesLabel                matlab.ui.control.Label
        SystemTransferFunctions      matlab.ui.container.GridLayout
        GslabelLabel                 matlab.ui.control.Label
        GsLabel                      matlab.ui.control.Label
        MslabelLabel                 matlab.ui.control.Label
        MsLabel                      matlab.ui.control.Label
        CalculatedTransferFunctions  matlab.ui.container.GridLayout
        ClosedLoopLabel              matlab.ui.control.Label
        ClosedloopLabel              matlab.ui.control.Label
        OpenLooplabelLabel           matlab.ui.control.Label
        OpenLoop                     matlab.ui.control.Label
    end

%     File written by G.Max and R. Bars, TU of Budapest
%     See website for more files like this.
%     https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    
%     The next section defines all the core variables used in the code and
%     that it may be convenient to have available in the various
%     subfunctions
    properties (Access = private)
        originalsize            % product of width and height for font sizing

        legstring=cell(1);      % To store legends
        POwn                    % Own controller
        
        Ps                      % Cont. controllers
        PIs
        PDs
        PIDs

        Pz                      % Disc. controllers
        PIz
        PDz
        PIDz
                
        Mactive = tf([1 3],[1 0]);  % current active controller

        G=tf([1 15],[1 9 23 15]);  % store continuous system tf
        Gz=tf(1,[1 -1],1);      % store discrete system tf
        OL                      % open loop
        CL                      % closed loop
        Tdelay                  % system delay
        Ti;                     % time constant of int. tag
        Td;                     % time constant of diff. tag
        p2r = [0 0];            % poles to replace
                                % p2r(1): int. , p2r(2): diff.
        z2r = [0 0 0];          % zeros to replace (Mactive) 3rd param: type of controller
        Ts = 1.0;               % sample time
        runtime = 5;            % time limit of diagrams
        samples = 201;          % number of samples
        time                    % array of runtime
        threshold = 0.0000001;  % minimal value around 0
        Typenum = 0;            % typenumber of the plant
        MessRow = 1;            % rows of messages in the message window

    end
    
    methods (Access = private)
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTIONS FOR POLE REPLACEMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function updateTransferFunctionRender(app)
% This function creates continuous or discrete 
% (P(s),...,PID(z)) controllers to the current plant G(s).
% Set settling time of the controllers and display 
% their transfer functions.
% Inputs: -
% Outputs: -

            p=-app.p2r;             % poles to replace

            for i=1:2
                r=(p(i)+conj(p(i)))/2;
                m=(-1i*p(i)+conj(-1i*p(i)))/2;
                if abs(r) < app.threshold
                    r=0;
                end
                if abs(m) < app.threshold
                    m=0;
                end
                p(i)=r+1i*m;
            end

            % create all controllers
            values = app.ControllertypeDropDown.Value;
            emptyP = 0*tf(1,1);  % empty process
            vari = 's';
            warnmess='';

            if values(1) == 'U'     % Own controller
                if app.Mactive.Variable == 's'
                    app.Mactive.Notes = SetNotes(app, app.Mactive*app.G/(1+app.Mactive*app.G));
                else
            % Change Ts of M(s) and G(s) to the current Ts
                    if app.Mactive.Ts ~= app.Ts
                        app.Mactive = d2d(app.Mactive, app.Ts);
                    end
                    if app.Gz.Ts ~= app.Ts
                        app.Gz = d2d(app.Gz, app.Ts);
                    end
            % Create continuous closed system
                    L=d2c(app.Mactive,'tustin');
                    L=minreal(app.G*L,0.0001);
                    F=feedback(L,1);                    
                    F=minreal(F,0.0001);
                    app.Mactive.Notes = SetNotes(app, F);
                end
                app.POwn = app.Mactive;
                vari = app.Mactive.Variable;

            else
            % Prepared systems
                app.POwn = emptyP;   % empty process
                app.POwn.Notes = num2str(0,'%.1f');
                app.UserschoiceDropDown.Value = ' ';
                vari = values(length(values)-1);
            end

            if vari == 's'
            % Continuous controllers
                emptyP = 0*tf(1,1);  % empty process

                % P(s)
                app.Ps = tf(1,1);
                app.Ps = Margo(app, app.Ps)*app.Ps;
                app.Ps.Notes = SetNotes(app, app.Ps*app.G/(1+app.Ps*app.G));

                % PI(s)
                app.PIs = emptyP;
                if app.Typenum == 0
                    if p(1) ~= 0
                        p(1)=-abs(p(1));
                        app.PIs = tf([1 -p(1)],[1 0]);
                        app.PIs = Margo(app, app.PIs)*app.PIs;
                        app.PIs.Notes = SetNotes(app, app.PIs*app.G/(1+app.PIs*app.G));
                    else
                       app.PIs.Notes = num2str(0,'%.1f');
                       warnmess=cat(1,warnmess,('PI(s), ')');
                    end
                else
                    app.PIs.Notes = num2str(0,'%.1f');
                    warnmess=cat(1,warnmess,('PI(s), ')');
                end

                % PD(s)
                app.PDs = emptyP;
                if app.Typenum <= 2
                    if p(2) ~= 0
                       p(2)=-abs(p(2));
                       app.PDs = tf([1 -p(2)],[1 -3*p(2)]);
                       app.PDs = Margo(app, app.PDs)*app.PDs;
                       app.PDs.Notes = SetNotes(app, app.PDs*app.G/(1+app.PDs*app.G));
                    else
                       app.PDs.Notes = num2str(0,'%.1f');
                       warnmess=cat(1,warnmess,('PD(s), ')');
                    end
                else
                    app.PDs = emptyP;
                    app.PDs.Notes = num2str(0,'%.1f');
                    warnmess=cat(1,warnmess,('PD(s), ')');
                end
                
                % PID(s)
                app.PIDs = emptyP;
                if app.Typenum <= 1
                    if p(1) ~= 0 && p(2) ~= 0
                       p(1)=-abs(p(1));
                       p(2)=-abs(p(2));
                       app.PIDs = tf([1 -p(1)],[1 0]) * tf([1 -p(2)],[1 -3*p(2)]);
                       app.PIDs = Margo(app, app.PIDs)*app.PIDs;
                       app.PIDs.Notes = SetNotes(app, app.PIDs*app.G/(1+app.PIDs*app.G));
                    else
                       app.PIDs.Notes = num2str(0,'%.1f');
                       warnmess=cat(1,warnmess,('PID(s), ')');
                    end
                else
                    app.PIDs.Notes = num2str(0,'%.1f');
                    warnmess=cat(1,warnmess,('PID(s), ')');
                end

            else
            % Discrete controllers
                emptyP = 0*tf(1,1,app.Ts);  % empty process
 
                app.Gz = c2d(app.G,app.Ts);
                app.Gz.Notes = app.G.Notes;
                
                % P(z)
                app.Pz = tf(1,1,app.Ts);
                app.Pz = Margo(app, app.Pz)*app.Pz;
                L=d2c(app.Pz,'tustin');
                L=minreal(app.G*L,0.0001);
                F=minreal(L/(1+L),0.0001);
                app.Pz.Notes = SetNotes(app, F);

                % PI(z)
                app.PIz = emptyP;
                if app.Typenum == 0
                    if p(1) ~= 0
                        app.PIz = tf([1 -exp(-app.Ts*abs(p(1)))],[1 -1],app.Ts);
                        app.PIz = Margo(app, app.PIz)*app.PIz;

                        L=d2c(app.PIz,'tustin');
                        L=minreal(app.G*L,0.0001);
                        F=minreal(L/(1+L),0.0001);

                        app.PIz.Notes = SetNotes(app, F);
                    else
                        app.PIz.Notes = num2str(0,'%.1f');
                        warnmess=cat(1,warnmess,('PI(Z), ')');
                    end
                else
                    app.PIz = emptyP;
                    app.PIz.Notes = num2str(0,'%.1f');
                    warnmess=cat(1,warnmess,('PI(Z), ')');
                end

                % PD(z)
                app.PDz = emptyP;
                if app.Typenum <= 2
                    if p(2) ~= 0
                        app.PDz = tf([1 -exp(-app.Ts*abs(p(2)))],[1 0],app.Ts);
                        app.PDz = Margo(app, app.PDz)*app.PDz;

                        L=d2c(app.PDz,'tustin');
                        L=minreal(app.G*L,0.0001);
                        F=minreal(L/(1+L),0.0001);

                        app.PDz.Notes = SetNotes(app, F);
                    else
                        app.PDz.Notes = num2str(0,'%.1f');
                        warnmess=cat(1,warnmess,('PD(Z), ')');
                    end
                else
                    app.PDz = emptyP;
                    app.PDz.Notes = num2str(0,'%.1f');
                    warnmess=cat(1,warnmess,('PD(Z), ')');
                end

                % PID(z)
                app.PIDz = emptyP;
                if app.Typenum <= 1
                    if p(1) ~= 0 && p(2) ~= 0
                        app.PIDz = tf([1 -exp(-app.Ts*abs(p(1)))],[1 -1],app.Ts)*tf([1 -exp(-app.Ts*abs(p(2)))],[1 0],app.Ts);
                        app.PIDz = Margo(app, app.PIDz)*app.PIDz;
                        L=d2c(app.PIDz,'tustin');
                        L=minreal(app.G*L,0.0001);
                        F=minreal(L/(1+L),0.0001);
                        app.PIDz.Notes = SetNotes(app, F);
                    else
                        app.PIDz.Notes = num2str(0,'%.1f');
                        warnmess=cat(1,warnmess,('PID(Z), ')');
                    end
                else
                    app.PIDz = emptyP;
                    app.PIDz.Notes = num2str(0,'%.1f');
                    warnmess=cat(1,warnmess,('PID(Z), ')');
                end
            end
            if ~isempty(warnmess)
                clc;
                w=cat(1,('Design fails: ')',warnmess);
                warnmess=w';
                updateMessages(app,1,warnmess(1:end-2)); 
            end

            % Select active M(s) and 
            % save zeros of M(s) to replace
            switch values
                case 'User''s choice'    %'Own'
                    app.Mactive = app.Mactive;

                case 'P(s)'  
                    app.Mactive = app.Ps;
                    app.z2r(1)=0;
                    app.z2r(2)=0;
                    app.z2r(3)=2;

                case 'PI(s)' 
                    app.Mactive = app.PIs;
                    app.z2r(1)=-p(1);
                    app.z2r(2)=0;
                    app.z2r(3)=3;
      
                case 'PD(s)' 
                    app.Mactive = app.PDs;
                    app.z2r(1)=0;
                    app.z2r(2)=-p(2);
                    app.z2r(3)=4;

                case 'PID(s)'
                    app.Mactive = app.PIDs;
                    app.z2r(1)=-p(1);
                    app.z2r(2)=-p(2);
                    app.z2r(3)=5;

                case 'P(z)' 
                    app.Mactive = app.Pz;
                    app.z2r(1)=0;
                    app.z2r(2)=0;
                    app.z2r(3)=6;

                case 'PI(z)' 
                    app.Mactive = app.PIz;
                    app.z2r(1)=p(1);
                    app.z2r(2)=0;
                    app.z2r(3)=7;

                case 'PD(z)' 
                    app.Mactive = app.PDz;
                    app.z2r(1)=0;
                    app.z2r(2)=p(2);
                    app.z2r(3)=8;

                case 'PID(z)'
                    app.Mactive = app.PIDz;
                    app.z2r(1)=p(1);
                    app.z2r(2)=p(2);
                    app.z2r(3)=9;

                otherwise 
                    app.Mactive = app.PIs;
            end

            % Plant
            SetSampleTime(app);
            app.G=zpk(app.G);
            % Display transfer function of G(s) in G(s) label of the screen
            app.GslabelLabel.Text = zpkdisp(app,2);

            % Active controller
            app.Mactive=zpk(app.Mactive);
            % Display transfer function of M(s) in M(s/z) label of the screen
            app.MslabelLabel.Text = zpkdisp(app,1);
            % Set default value of Kp slider
            app.KpSliderLabel.Text = cat(1,('Kp(')',char(num2str(app.Mactive.K,'%.2f'))',(')')' )';
            app.KpSlider.Value = SliderLimit(app,1,max(0.1,app.Mactive.K));

            % Change label
            if app.Mactive.Variable == 's'
                app.MsLabel.Text = 'M(s)';
                app.ManuallyselectedPIDparametersinUserschoiceMsLabel.Text = 'Manually selected PID parameters in Users choice M(s)';
            else
                app.MsLabel.Text = 'M(z)';
                app.ManuallyselectedPIDparametersinUserschoiceMsLabel.Text = 'Manually selected PID parameters in Users choice M(s)';
            end
            
            % Display Open loop
            OL=zpkdisp(app,3);
            if length(OL) > 50
                app.OpenLooplabelLabel.FontSize = 12;
            else
                app.OpenLooplabelLabel.FontSize = 18;
            end
            app.OpenLooplabelLabel.Text = OL;

            % Display Closed loop
            CL=zpkdisp(app,4);

            if length(CL) > 80
                app.ClosedLoopLabel.FontSize = 8;
            elseif length(CL) > 50
                app.ClosedLoopLabel.FontSize = 12;
            else
                app.ClosedLoopLabel.FontSize = 18;
            end
            app.ClosedLoopLabel.Text = CL;
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%   SUBFUNCTION TO CREATE A TEXT TO DISPLAY  %%%%%%%%              
%%%%%%%%%           A TRANSFER FUNCTION           %%%%%%%%%

        function results = zpkdisp(app,n)
% This function displays transfer function or error messages
% Input: number of fransfer function to display
% 1: Active controller
% 2: Plant
% 3: Open system
% 4: Closed system
% Output s or z string to display

            if n == 1
                h=minreal(zpk(app.Mactive));
                pr="M";
            elseif n == 2
                h=minreal(zpk(app.G),0.001);
                pr="G";
            elseif n == 3
                if app.Mactive.Variable == 'z'
            % Check sample time of plant and active controller                    
                    tmp=app.SampletimesEditField.Value;
                    app.Gz = d2d(app.Gz,tmp);
                    app.Gz.Notes = SetNotes(app,app.Gz);
                    app.Mactive=d2d(app.Mactive,tmp);
                    h=minreal(zpk(app.Gz*app.Mactive),0.001);
                else
                    h=minreal(zpk(app.G*app.Mactive),0.001);
                end
                pr="O";
            elseif n== 4
                if app.Mactive.Variable == 'z'

                    h=d2c(minreal(zpk(app.Gz*app.Mactive/(1+app.Gz*app.Mactive)),0.001),'tustin');
                    
                else
                    if app.Tdelay > 0
            % In case of time delayed plant
                        M=c2d(app.Mactive,app.Ts);
                        app.Gz=d2d(app.Gz,app.Ts);
                        h=minreal(app.Gz*M,0.0001);
                        h=minreal(h/(1+h),0.0001);
                        clc;
                        m=lasterror().message;
                        % if length(m) > 10
                        %     updateMessages(app,2,'Error: ');
                        %     updateMessages(app,2,char(m));
                        %     lasterror('reset');
                        % end
                        if ~isempty(lastwarn())
                            updateMessages(app,2,lastwarn());
                            lastwarn('');
                        end                        
                        h=d2c(h,'tustin');
                    else
                        h=minreal(zpk(app.G*app.Mactive/(1+app.G*app.Mactive)),0.001);
                    end
                end
                pr="C";
            end

            vari=h.Variable;
            Td=h.OutputDelay+h.InputDelay+h.IODelay;

            % Create zeros and poles of current system
            [z,p,k]=zpkdata(h,'v');
            if length(z) > 1
                z=sort(z,'descend');
            end
            if length(p) > 1
                p=sort(p,'descend');
            end

            % Correct figures if any
            for i=1:length(z)
                r=(z(i)+conj(z(i)))/2;
                m=(-1i*z(i)+conj(-1i*z(i)))/2;
                if abs(r) < app.threshold
                    r=0;
                end
                if abs(m) < app.threshold
                    m=0;
                end
                z(i)=r+1i*m;
            end

            for i=1:length(p)
                r=(p(i)+conj(p(i)))/2;
                m=(-1i*p(i)+conj(-1i*p(i)))/2;
                if abs(r) < app.threshold
                    r=0;
                end
                if abs(m) < app.threshold
                    m=0;
                end
                p(i)=r+1i*m;
            end

            % Create text to display
            if isempty(p)
                results = char(num2str(h.k));
            else
                % Create numerator
                nume= Roots2Str(app,z,vari);
                if nume == '1'
                    nume = char(num2str(k));
                else
                    if k == 1
                        nume = cat(1, (' ')', nume');
                    else
                        nume = cat(1, char(num2str(k))', nume');
                    end
                    nume=strip(nume');
                end

                % Create denominator
                denu=strip(Roots2Str(app,p,vari));

                % Align text to center
                if length(nume) > length(denu)
                    l = int32((length(nume) - length(denu))/2);
                    nume = cat(1,(repelem(' ',   7))', nume'); % strcat(s{1}(1:7), nume{1});
                    denu = cat(1,(repelem(' ', l+7))', denu'); % strcat(s{1}(1:l+7), denu{1});

                else
                    l = int32((length(denu) - length(nume))/2);
                    nume = cat(1,(repelem(' ', l+7))', nume'); % strcat(s{1}(1:7), nume{1});
                    denu = cat(1,(repelem(' ',   7))', denu'); % strcat(s{1}(1:l+7), denu{1});
                end

                l=max(length(nume),length(denu));
                midl=cat(1, pr' ,('(')',vari',(') = ')',(repelem('-', l-7))'  );
                if Td ~= 0
                    if abs(Td-1) < app.threshold
                        tmp='-';
                    else
                        tmp=char(num2str(-Td)');
                    end
                    if strip(convertCharsToStrings(nume)) == "1"
                        if vari == 's'
                % Display time delay if Kp = 1
                            nume = cat(1,('exp(')',tmp,('s)')');
                        else
                            nume = cat(1,('z^{')',tmp,('}')');
                        end
                    else
                        if vari == 's'
                % Display time delay if Kp ≠ 1
                            nume = cat(1,nume,(' exp(')',tmp,('s)')');
                        else
                            nume = cat(1,nume,('z^{')',tmp,('}')');
                        end
                    end
                end

                if max(length(h.Z{1}),length(h.P{1})) > 4
                % If length of text to display is too long
                    if pr == 'C'
                % A time delayed system has no continuous closed loop
                        results='Given in state space form ';
                    else
                        results='Transfer function is too long.';
                    end
                else
                    results=cat(1,('$\frac{')',nume,'}','{',denu,'}','$')';
                end
            end
        end
        
        function results = Roots2Str(app,n,v)
% This function converts roots to transfer function
% Inputs:
% n: vector of roots
% v: type of variables (continuous or discrete)
% Output:
% Equation of transfer function
% Example: results = Roots2Str(app,{-1, -2}, 's')
%   Result: '(s+1)(s+2)'

            % sorting roots
            n=sort(n,'descend');
            if ~isempty(n)
            bbb=('')';
            i=1;
            while i <= length(n) 
                j=0;
            % Same roots?
                for k=1:length(n)-i
                    if abs(n(i) - n(i+k)) < app.threshold 
                        j=j+1;
                   end
                end

                if abs(n(i)) < 0.000001
                    bbb=cat(1,bbb,(' ')',v');
                else
                    if Real(app,n(i)) < 0
                        c= '+';
                    else 
                        c= '-';
                    end

                    if abs(Imag(app,n(i))) < app.threshold
                        bbb=cat(1,bbb,(' (')',v',c',char(num2str(round(abs(n(i)),4)))',(')')');
                    else
                        bbb=cat(1,bbb, (' (')' ,v',('^2 ')',c',char(num2str(2*abs(Real(app,n(i)))))',v',('+')',char(num2str((Real(app,n(i))*Real(app,n(i))+Imag(app,n(i))*Imag(app,n(i)))))' ,(')')'   );
                    end
                end

                if j>0
                    bbb=cat(1,bbb,('^')',char(num2str(j+1))',(' ')');
                end

                if Imag(app,n(i)) ~= 0
                    i=i+j+j+2;
                else
                    i=i+j+1;
                end
            end     % while
                results = bbb';
            else
            % In case of empty input
                results='1';
            end
        end
        
        function results = RuntimeLimit(app)
% This function determines the time range of the figures
% to be displayed
% Input: -
% Output: Upper value of the time range [s] 
%   = 1.5*max(settling time) 
            rt=[0 0 0];
            % Upper value of G(s)
            if ~isempty(app.G)
                if isempty(app.G.Notes)
                    app.G.Notes = SetNotes(app,app.G);
                end
                rt(1)=int32(1.5*str2double(app.G.Notes{1})+0.5);
            end

            if ~isempty(app.Gz)
            % Upper value of G(z)
                if isempty(app.Gz.Notes)
                    app.Gz.Notes = SetNotes(app,app.Gz);
                end
                rt(2)=int32(1.5*str2double(app.Gz.Notes{1})+0.5);
            end

            if ~isempty(app.Mactive)
            % Upper value of M(s/z)
                if isempty(app.Mactive.Notes)
                    app.Mactive.Notes = SetNotes(app,app.Mactive);
                end
                rt(3)=int32(1.5*str2double(app.Mactive.Notes{1})+0.5);
            end

            results = max(rt(rt~=0));
            if abs(results) < app.threshold
                results=10;
            end
        end
        
        function results = SetNotes(app,P)
% Return settling time of process P
% Input: Process
% Output: Settling time of the process
            P=minreal(P,0.0001);
            try
                Tdel=P.IODelay + P.InputDelay + P.OutputDelay;
            catch
                Tdel=app.Tdelay;
            end
%           if app.Tdelay > app.threshold
            if Tdel > app.threshold
                yout=step(P);
                m=max(abs(yout));
                if m>10000
                    results=num2str(0,'%.1f');
                else
                    results=num2str(stepinfo(P).SettlingTime,'%.1f');
                end
            else
                if ~isstable(P)
                    results=num2str(0,'%.1f');
                else
                    results=num2str(stepinfo(P).SettlingTime,'%.1f');
                end
            end
        end
        
        function SetSampleTime(app)
% This function sets sample time of the system
% input: -
% Output: min(Tdelay/2 of G(s), 2/max(abs([zeros or poles ])));

            [z,p,~]=zpkdata(app.G,'v');
            n=[app.Tdelay/2, 1/max(abs([z; p]))/2];
            app.Ts=min(n(n~=0));
            tmp=app.SampletimesEditField.Value;
            if tmp < app.Ts
                app.Ts = tmp;
            end
            app.SampletimesEditField.Value=app.Ts;
            if app.Gz.Ts ~= app.Ts
                d2d(app.Gz,app.Ts)
                if app.G.Variable == 'z'
                    app.G = app.Gz;
                end
            end
        end

        
        function updateMessages(app,n,mess)
% This function writes messages to the message window.
% Message window has 6 rows to display messages.
% Last 6 rows can be read on the screen.
% Input:
% n=1: clear window and write message
% n≠1: append message to the former ones
% last 6 lines are visible

            clc;
            if isempty(mess)
                return;
            end

            if contains(mess,"RCOND")
                return;
            end

            if contains(mess,"YFINAL")
                return;
            end

            if contains(app.MessagesLabel.Text,mess) && n > 1
                return;
            end

            lpl=53;     % letters per line
            mess=replace(eraseBetween(mess, '<', '>'),' <',''); % remove html
            replace(mess, '>', '');
      
            ml=length(mess); %message length
            l = int32(ml/lpl)-1;
            m=mess;

            if ml > 200
                return
            end

            for i=1:l
                k=i*lpl;
                for j=(i-1)*lpl+1:i*lpl
                    if m(j) == " "
                        k=j;
                    end
                end

                if k > ml
                    k=ml-1;
                end
                m=cat(1,m((i-1)+1:k)',newline,m(k+1:ml)')'
                ml=ml+1;
            end
            
            mess=m;

            if n == 1
                % new message
                app.MessRow = 1;
                app.MessagesLabel.Text = mess; % cat(1,('Runtime: ')',char(num2str(results))',(' [sec]')')';
            else
                % add up your message to the former messages
                former=app.MessagesLabel.Text;
                if app.MessRow >= 6
                    app.MessRow = 6;
                    i=1;
                    while former(i) ~= newline
                        i=i+1;
                    end
                    former=former(i+1:length(former));
                else
                    app.MessRow = app.MessRow + 1;
                end
                app.MessagesLabel.Text = cat(1,former',newline,mess')';
            end
        end

        
        function results = Margo(app,F)
% This function substitues margin(gain, phase, omega) function
% In my Matlab margin(gain, phase, omega) does not work
% Input: transfer function of the controller (F)
% Output: Ki = gain of the controller to ensure the required
% appr. 60° phase margin

            % create open loop
                if F.Variable == 'z'              
                    if isempty(app.Gz) || app.G.Variable == 's'
                        app.Gz = c2d(app.G,app.Ts);
                        app.Gz.Notes = SetNotes(app,app.Gz);
                    end
                    F = d2d(F,app.Ts);
                    app.Gz = d2d(app.Gz,app.Ts);
                    app.Gz.Notes = SetNotes(app,app.Gz);
                    L=minreal(F*app.Gz);
                else
                    L=minreal(F*app.G);
                end

            % draft Bode from 0.00001 to 1000 Hz
            n=100;
            [g,p,o]=bode(L,logspace(-5,3,n));
            o=o(:); 
            g=g(:); 
            p=p(:); 

            k=n+1;
            % where is the phase angle = -120°?
            if p(1) >= p(end)
            % Coming from the upper region (from -90°)
                for i=1:n
                    if p(i) > -120
                        k=i;
                    end
                end
                v=k+1;
            else
            % Coming from the lower region (from -270°)
                for i=1:n
                    if p(i) < -120
                        k=i;
                    end
                end
                v=k-1;
            end

            if k < n 
            % Change range[0.00001, 1000] to range[k,v]
            % to get a more precise result
                Ki=1/g(k);
                k=log(o(k))/log(10);
                v=log(o(v))/log(10);

                o=logspace(k,v,n)';
                [g,p] = bode(L,o);
                g=g(:); p=p(:);
                k=n;
                if p(1) >= p(end)
                    for i=1:n
                        if p(i) > -120
                            k=i;
                        end
                    end
                    v=k+1;
                else
                    for i=1:n
                        if p(i) < -120
                            k=i;
                        end
                    end
                    v=k-1;
                end
                if k > n 
                    k=n;
                end
                Ki=1/g(k);
            else
            % Structurally stable system
                Ki=pi;
            end

            if isnan(Ki)
                Ki=1;
            end
            results = Ki;
        end  % margo()
        
        function results = equal(app,d,f)
% This function compares two transfer functions
% Input: transfer function of d and f
% Output: result = 0, if they are not equal
%         result ≠ 0, if they are equal

            results = 0;
            if ~isempty(d) && ~isempty(f)
                if d.OutputDelay+d.InputDelay+d.IODelay==f.OutputDelay+f.InputDelay+f.IODelay
                    [d1,d2,d3]=tfdata(d,'v');
                    A=[d1,d2,d3];

                    [f1,f2,f3]=tfdata(f,'v');
                    B=[f1,f2,f3];

                    if length(A) == length(B)
                        results = prod(A == B);
                    end
                end
            end

        end
        
        function results = zpkback(app,ca)
% This function changes back the transfer function displayed (in text form)
% to matlab transfer function (i.e. tf(num,den))
% Input: ca = transfer function displayed
% Output: matlab transfer function of ca

            if ~isempty(str2num(ca))
                results = cat(1, char(num2str(ca))');
            else
                n=length(ca);
                st=[0 0];
                en=[0 0];
                k=1; l=1;
                for i=1:n
                    if ca(i) == '{'
                        st(k)=i+1;
                        k=k+1;
                    end
                    if ca(i) == '}'
                        en(l)=i-1;
                        l=l+1;
                    end
                end
                % if isnumeric()
                num=strtrim(ca(st(1):en(1)));
                den=strtrim(ca(st(2):en(2)));
                num=strrep(num,'(','*(');
                den=strrep(den,'(','*(');
                num=strrep(num,') z',')*z');
                den=strrep(den,') z',')*z');
                num=strrep(num,' ','');
                den=strrep(den,' ','');
                if num(1)=='*'
                    num = num(2:length(num));
                end
                if den(1)=='*'
                    den = den(2:length(den));
                end

                results = cat(1, char(num)', ('/(')', char(den)',(')')' );
            end
        end
        
        function results = SliderLimit(app,sl,val)
% This function corrects upper value of a slider 
% If the selected value is above 95% of the upper limit, 
% it doubles the upper limit.
% If the selected value is below 45% of the upper limit, 
% it will halve the upper limit
% and displays new limits on the screen
% This function does not work well. Changed values ��are sometimes 
% displayed, but more often they are not. MajorTickLabels are 
% often missing.
% Input: type of the slider
% 1: KpSlider   slider of gain
% 2: TiSlider   slider of time constant of Ti
% 3: TdSlider   slider of time constant of Td
% Output: New upper value
            if sl == 1
                lim=app.KpSlider.Limits;
            elseif sl == 2
                lim=app.TiSlider.Limits;
            elseif sl == 3
                lim=app.TdSlider.Limits;
            end

            if ~( 0.45*lim(2) <= val && val <= 0.95*lim(2) )

                if 0.95*lim(2) <= val
                    while 0.95*lim(2) < val
                        lim(2)=lim(2)+lim(2);
                    end
                else
                    if abs(val) < app.threshold
                        lim(2) = 0.25;
                        val= 0.01;
                    else
                        while lim(2) > val
                            lim(2)=lim(2)/2;
                        end
                        lim(2)=lim(2)+lim(2);
                    end
                end

                MajorTicks = 0:lim(2)/8:lim(2);
                mt = cell(1,9);
                for i=1:9
                    mt(i) = { num2str(MajorTicks(i),'%.1f') };
                end


                if sl == 1
                    app.KpSlider.Limits=lim;
                    app.KpSlider.MajorTicks = MajorTicks;
                    app.KpSlider.MajorTickLabels = mt;
                    app.KpSlider.MinorTicks = 0:lim(2)/32:lim(2);

                elseif sl == 2
                    app.TiSlider.Limits=lim;
                    app.TiSlider.MajorTicks = MajorTicks;
                    app.TiSlider.MajorTickLabels = mt;
                    app.TiSlider.MinorTicks = 0:lim(2)/32:lim(2);

                elseif sl == 3
                    app.TdSlider.Limits=lim;
                    app.TdSlider.MajorTicks = MajorTicks;
                    app.TdSlider.MajorTickLabels = mt;
                    app.TdSlider.MinorTicks = 0:lim(2)/32:lim(2);
                end
            end
            results = val;
        end
        
        function DispRootLocus(app)
 % This function displays root locus diagram and calculates
 % lower and upper limits of the diagram.
 % Input: -
 % Output: -
            cla(app.UIAxes_6);
            if app.Tdelay <= app.threshold
                hold(app.UIAxes_6,'on')
                grid(app.UIAxes_6,"on");
                subtitle(app.UIAxes_6,'');
                vari=app.Mactive.Variable;
                if vari == 'z'
                    [r, ~] = rlocus(app.Mactive*app.Gz);
                else
                    [r, ~] = rlocus(app.Mactive*app.G);
                end
                
                [b,~]=size(r);
                for i=1:b
                    if r(i,end) == Inf
                        r(i,end)=r(i,end-3);
                        r(i,end-1)=r(i,end-3);
                        r(i,end-2)=r(i,end-3);
                    end
                end

                rr=(r+conj(r))/2;           % rr = real(r)
                ri=((r-conj(r))/2)*(0-1i);  % ri = imag(r)
                k = [0 0 0];
                a=min( rr );
                k(1)=int32(min( a )+0.5)-1;
                a=max( rr );
                k(2)=int32(max( a )+0.5)+1;
                a=max( ri );
                k(3)=int32(max( a )+0.5)+1;

                l=ones(1,3);
                for i=1:3
                    if k(i) <= 0
                        while k(i) < -l(i)
                            l(i)=l(i)+l(i);
                        end
                        l(i)=-l(i);
                    else
                        while k(i) > l(i)
                            l(i)=l(i)+l(i);
                        end
                    end
                end
                if l(1)+l(2) < -2
                    l(1)=l(1)+l(2);
                else
                    l(2)=0;
                end
                k = l;

                app.UIAxes_6.XAxisLocation = 'origin';
                app.UIAxes_6.YAxisLocation = 'origin';
                app.UIAxes_6.XTick = k(1):(k(2)-k(1))/8:k(2);
                app.UIAxes_6.YTick = -k(3):k(3)/4:k(3);

                app.UIAxes_6.XTickLabel = k(1):(k(2)-k(1))/8:k(2);
                app.UIAxes_6.YTickLabel = -k(3):k(3)/4:k(3);

                grid(app.UIAxes_6,"on");

                co=['r' 'g' 'b' 'y' 'k' 'm' 'c'];
                for i=1:b
                    n=0;
                    while r(i,end-n) < k(1)
                        rr(i,end-n)=(k(1)+conj(k(1)))/2;
                        ri(i,end-n)=(k(1)-conj(k(1)))/2*(0-1i);
                        n=n+1;
                    end
                    %p = nsidedpoly(1000, 'Center', [0 0], 'Radius', 1);
                    if vari == 'z'
                        th = 0:pi/50:2*pi;
                        x = cos(th); y = sin(th);
                        plot(app.UIAxes_6, x,y); %, 'FaceColor', [0.7, 1.0, 0.7]); %'#8F0');
                    end
                    dr=rr(i,:);
                    di=ri(i,:);
                    jj=int32(int32(i)-7*int32(i/7)+4);
                    plot(app.UIAxes_6, dr, di, co(jj),'LineWidth',2); %, ren(:), -imn(:), 'b');
                    if n == 0
                        plot(app.UIAxes_6,dr(1),di(1),'kx',dr(end),di(end),'ko');
                    else
                        plot(app.UIAxes_6,dr(1),di(1),'kx');
                    end
                end


                hold(app.UIAxes_6,'off')
            else
                subtitle(app.UIAxes_6,'See ERROR...');
                updateMessages(app,1,'ERROR: The [rlocus] command cannot be used for');
                updateMessages(app,2,'continuous-time models with delays.');
                updateMessages(app,2,'Use the [pade] command to approximate delays.'); 
            end
        end
        
        function DispNyquist(app)
% This function displays Nyquist diagram and calculates
% lower and upper limits of the diagram.
% Input: -
% Output: -
            cla(app.UIAxes_5);
            if isempty(app.Mactive)
                app.Mactive=tf(1,1);
            end
            vari=app.Mactive.Variable;
            if vari == 'z'
                [aren, aimn, ~] = nyquist(app.Mactive*app.Gz);
            else
                [aren, aimn, ~] = nyquist(app.Mactive*app.G);
            end

            ren=aren(:);
            imn=aimn(:);
            k(1)=min(ren);
            k(2)=max(ren);
            k(3)=abs(min(imn));
            

            if 2*max(k(1),k(2)) < abs(k(3))
                l=2 * max(k(1),k(2));
            elseif max(k(1),k(2)) < abs(k(3))
                l=max(k(1),k(2));
            else
                l=max(k);
            end

            if l < 0.000001
                l=6;
            elseif l < 6
                l=1.1*l;
            end
            k=double(2*int32((int32(l+0.5)+1)/2));

            cla(app.UIAxes_5);
            hold(app.UIAxes_5,'on')

            app.UIAxes_5.XLim = [min(-k,-2) k];
            app.UIAxes_5.YLim = [-k k];

            if k <= 2
                l=0.5;
            elseif k<=20
                l=2;
            else
                l=k/5;
            end

            app.UIAxes_5.XTickLabel = -k:l:k ;
            app.UIAxes_5.XAxisLocation = 'origin';
            app.UIAxes_5.YAxisLocation = 'origin';
            app.UIAxes_5.XTick = -k:l:k;
            app.UIAxes_5.YTick = -k:l:k;

            grid(app.UIAxes_5,"on");

            plot(app.UIAxes_5, ren(:), imn(:), 'b', ren(:), -imn(:), 'b');
            plot(app.UIAxes_5,-1, 0,'r+','LineWidth',2);

            p1=min(aimn(:));
            for j=1:length(aren)
                if aimn(j) == p1
                    k=j;
                end
            end

            plot(app.UIAxes_5, aren(k), aimn(k),'b<','LineWidth',2);
            plot(app.UIAxes_5, aren(k), -aimn(k),'b>','LineWidth',2);

            hold(app.UIAxes_5,'off')
            
            
        end
        
        function results = Real(app,a)
            results = (a+conj(a))/2;
        end

        function results = Imag(app,a)
            results = ((a-conj(a))/2)*(0-1i);
        end
        
        function appGdisp(app,n)
% This function plots G(s) to Update system details screen 
% and to the left upper diagram of System behaviours.
            [y,t]=step(app.G,app.runtime);
            if n==1
                plot(app.UIAxes,t,y,'linewidth',2)
            else
                plot(app.UIAxes_1,t,y,'linewidth',2)
            end
        end
        
        function appCLdisp(app,n)
% This function plots closed system to Update system details screen 
% and to the left upper diagram of System behaviours.
            if app.Mactive.K ~= 0
            if app.Mactive.Variable == 's'
                L=minreal(app.G*app.Mactive,0.0001);
            else
                L=d2c(app.Mactive,'tustin');
                L=minreal(app.G*L,0.0001);
            end
            
            app.CL=minreal(L/(1+L),0.0001);
            app.CL.Notes=SetNotes(app,app.CL);
            
            
            if str2num(char(app.CL.Notes)) < app.threshold
                updateMessages(app,2,'The closed loop system is unstable.');
            end

            if app.runtime < round(1.5*str2double( app.CL.Notes{1} ), 0);
                app.runtime = round(1.5*str2double( app.CL.Notes{1} ), 0);
            end 


            [y,t]=step(app.CL,app.runtime);

            if n==1
                plot(app.UIAxes,t,y,'linewidth',2)
            else
                plot(app.UIAxes_1,t,y,'linewidth',2)
            end
            end
        end
        
        function results = appUdisp(app)
% This function plots output signal of the controller
% to the right upper diagram of System behaviours.
            if app.Mactive.Variable == 's'
                empty=0*tf(1,1);
                if equal(app,app.Mactive,empty) == 0
                    F=minreal(app.Mactive/(1+app.Mactive*app.G));
                    F.Notes=SetNotes(app,F);
                    [y,time]=step(F,app.runtime);
                    plot(app.UIAxes_2,time,y,'linewidth',2);
                else
                    F=zpk(empty);
                    F.Notes = num2str(0,'%.1f');
                end
            else
                empty=0*tf(1,1,app.Ts);
                if equal(app,app.Mactive,empty) == 0
                    F=minreal(app.Mactive/(1+app.Mactive*app.Gz));
                    [y,time]=step(F,app.runtime);
                    stairs(app.UIAxes_2,time,y,'r');
                    F.Notes=SetNotes(app,F);
clc;
m=lasterror().message;
% if length(m) > 10
%     updateMessages(app,2,'Error: ');
%     updateMessages(app,2,char(m));
%     lasterror('reset');
% end
if ~isempty(lastwarn())
    updateMessages(app,2,lastwarn());
    lastwarn('');
end
                else
                    F=zpk(empty);
                    F.Notes = num2str(0,'%.1f');
                end
            end                               
            results = [cat(1,('Cont.Outp. [')', char(F.Notes)',(' sec]')')];
        end
        
        function appBodedisp(app)
% This function plots Bode diagram of the open loop
% to the left lower diagram of System behaviours.
% Input: -
% Output: -
            vari = app.Mactive.Variable;
            if isempty(app.Mactive)
                vari = 's';
                [aga,aph,aom]=bode(app.G,logspace(-3,2));
                [gm,pm,wcg,wcp]=margin(app.G);
            else
                if vari == 'z'
                    % [aga,aph,aom]=bode(app.Mactive*app.Gz);
                    [~,~,aom]=bode(app.Mactive*app.Gz);
            % lower omega limit of Bode
                    omst=0.0000001;
                    n=-7;
                    while omst < aom(1)
                        omst=10*omst;
                        n=n+1;
                    end
                    omst=n;

            % upper omega limit of Bode
                    omend=100000000000;
                    n=11;
                    while aom(end) < omend
                        omend=omend/10;
                        n=n-1;
                    end
                    omend=n;

            % calculation of cut off frequency (wc) 
                    [gm,pm,wcg,wcp]=margin(app.Mactive*app.Gz);
                    nmax=max(wcg,wcp);
                    nmax=max(nmax,1/app.Ts);
                    while nmax > 10^omend
                        omend=omend+1;
                    end
                    [aga,aph,aom]=bode(app.Mactive*app.Gz,logspace(omst,omend));
                else
                    [~,~,aom]=bode(app.Mactive*app.G);

            % calculate of closer limits
                    omst=0.0000001;
                    n=-7;
                    while omst < aom(1)
                        omst=10*omst;
                        n=n+1;
                    end
                    omst=n;

                    omend=100000000000;
                    n=11;
                    while aom(end) < omend
                        omend=omend/10;
                        n=n-1;
                    end
                    omend=n;

             if str2num(char(SetNotes(app, (app.Mactive*app.G)/(1+app.Mactive*app.G)))) >  app.threshold
                    [gm,pm,wcg,wcp]=margin(app.Mactive*app.G);
                    if isnan(wcg) || wcg == Inf
                        nmax = wcp;
                    elseif isnan(wcp) || wcp == Inf
                        nmax = wcg;
                    else
                        nmax=max(wcg,wcp);
                    end 
             else
                  [gm,pm,wm] = bode(app.Mactive*app.G);
                  wc=10; k=1;
                  for i=1:length(gm)
                    if abs(gm(i)-1) < wc
                        wc=abs(gm(i)-1);
                        k=i;
                    end
                  end
                  nmax=wm(k);
                  wcg=nmax;
                  wcp=nmax;

                  gm = 1/gm(k);
                  pm=pm(k);

             end
            % wend in case of delayed system
                    if app.Tdelay > 0
                        while nmax > max(10^omend,1.1/2/app.Tdelay)
                            omend=omend+1;
                        end
                    else
                        while nmax > 10^omend
                            omend=omend+1;
                        end
                    end

            % plot diagrams
                    [aga,aph,aom]=bode(app.Mactive*app.G,logspace(omst,omend));
                end
            end

            %
            % Values of title, subtitle, x and y axes of Bode Gain
            %

            title(app.UIAxes_3, 'Bode of open loop')
            ylabel(app.UIAxes_3, 'Gain [dB]')
            app.UIAxes_3.XAxisLocation = 'origin';
            app.UIAxes_3.XScale = 'log';
            % app.UIAxes_3.XTick = [];    % see phase
            % app.UIAxes_3.XTickLabel = '';
            app.UIAxes_3.XMinorTick = 'on';
            app.UIAxes_3.XGrid = 'on';

            app.UIAxes_3.YAxisLocation = 'origin';
            app.UIAxes_3.YScale = 'log';
            app.UIAxes_3.YTick = [0.0001 0.001 0.01 0.1 1 10 100];
            app.UIAxes_3.YTickLabel = {'10^{-4}'; ''; '10^{-2}'; ''; '10^{0}'; ''; '10^{2}'};
            app.UIAxes_3.YMinorTick = 'on';
            app.UIAxes_3.YGrid = 'on';

            n=0;
            for i=1:length(aom)-1
                if aom(i) <= wcg
                    n=i;
                end
            end
            hold(app.UIAxes_3,'on');
            plot(app.UIAxes_3, aom(:), aga(:));
            plot(app.UIAxes_3, [aom(1), aom(end)],[1,1],'bl');
            if n ~= 0
                plot(app.UIAxes_3, [wcg,wcg], [1, aga(n+1)],'k','LineWidth',2);
            end
            plot(app.UIAxes_3, [wcp, wcp], [0.6,1.4],  'r','LineWidth',2  );
            if app.Ts > 0 && 1/app.Ts < wcg
                subtitle(app.UIAxes_3, "ωc="+num2str(wcp)+" [Hz]  Gm="+num2str(gm)+" at "+num2str(wcg)+" [Hz]  Pm="+num2str(pm)+" [°] at wc",'Color','r','FontSize',10 );
            else
                subtitle(app.UIAxes_3, "ωc="+num2str(wcp)+" [Hz]     Gm="+num2str(gm)+" at "+num2str(wcg)+" [Hz]    Pm="+num2str(pm)+" [°] at wc",'Color','k','FontSize',10 );
            end
            if vari == 'z'
                plot(app.UIAxes_3, [1/app.Ts, 1/app.Ts], [0.0001,100],  'k','LineWidth',1);
            end

            grid(app.UIAxes_3,"on");
            hold(app.UIAxes_3,'off')

            %
            % Values of title, subtitle, x and y axes of Bode phase
            %

            xlabel(app.UIAxes_4, 'ω [Hz]')
            ylabel(app.UIAxes_4, 'Phase [°]')
            app.UIAxes_4.XScale = 'log';
            app.UIAxes_4.XTick = [0.001 0.01 0.1 1 10 100 1000 10000];
            app.UIAxes_4.XTickLabel = {'0.001'; '0.01'; '0.1'; '1'; '10'; '100'; '1000'; '10000'};
            app.UIAxes_4.XMinorTick = 'on';
            app.UIAxes_4.XGrid = 'on';

            app.UIAxes_4.YLim = [-270 90];
            app.UIAxes_4.YTick = [-240 -180 -120 -60 0 60];
            app.UIAxes_4.YTickLabel = {'-240'; '-180'; '-120'; '-60'; '0'; '60'};
            app.UIAxes_4.YGrid = 'on';

            n=0;
            for i=1:length(aom)
                if aom(i) <= wcp
                    n=i;
                end
            end

            hold(app.UIAxes_4,'on')
            semilogx(app.UIAxes_4, aom(:), aph(:), [aom(1), aom(end)],[-180,-180],'bl');
            if n ~=0
                plot(app.UIAxes_4, [wcp,wcp], [-180, aph(n)],'k','LineWidth',2);
            end
            plot(app.UIAxes_4, [wcg, wcg], [-170,-190],  'r','LineWidth',2);
            if vari == 'z'
                plot(app.UIAxes_4, [1/app.Ts, 1/app.Ts], [-270,30],  'k','LineWidth',1);
            end
            hold(app.UIAxes_4,'off')
            
        end
    end  %% end of methods    
    %%end  %%%*******************************************EZT IRTUK BE UTÓLAG

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
% This function is copied from Rossiter's materials
            % resize to be in middle of the window
            movegui(app.UIFigure)
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
                theme(app.UIFigure,"light")
            end
            % Open the manual
            if exist('PoleReplacement_control101_manual_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open PoleReplacement_control101_manual_mycopy.mlx
            else
                p1 = which('PoleReplacement_control101_manual.mlx');
                p2 = strcat(pwd,'/PoleReplacement_control101_manual_mycopy.mlx');
                copyfile(p1,p2)                
                open PoleReplacement_control101_manual_mycopy.mlx
                clear p1 p2
            end
            
            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);

% Part of PoleReplacement
            event.InteractionInformation.Item=2;
            app.G=tf(15,[1 9 23 15]);
            app.Mactive=tf(0.6, 1, 1/30);
            PlantDropDownValueChanged(app,event);
            UserschoiceDropDownValueChanged(app, event);

            UpdateSystemdetailsButtonPushed(app, event);
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

        % Button pushed function: UpdateSystemdetailsButton
        function UpdateSystemdetailsButtonPushed(app, event)
% This function updates main screen (Update System details)
            app.TabGroup.SelectedTab = app.TabGroup.Children(1);
            clc;
            updateMessages(app,1,'Messages: ');
            updateTransferFunctionRender(app); % ensure current compensator showing

            % Prepare G(z) for later use
            app.Gz = c2d(app.G,app.Ts);
            app.G.Notes = SetNotes(app,app.G);
            app.Gz.Notes = SetNotes(app,app.Gz);
            % Select controller type and set rumtime limit
            switch app.ControllertypeDropDown.Value
                case 'User''s choice'       %'Own'
                    if app.Typenum > 0
                        app.runtime = round(1.5*str2double( app.POwn.Notes{1}), 0);
                    else
                        app.runtime = round(1.5*max([ str2double( app.G.Notes{1}), str2double( app.POwn.Notes{1})]),0);
                    end

                case 'P(s)'  
                    if app.Typenum > 0
                        app.runtime = round(1.5*str2double( app.Ps.Notes{1} ) ,0);
                    else
                        app.runtime = round(1.5*max([ str2double( app.G.Notes{1}), str2double( app.Ps.Notes{1})]),0);
                    end

                case 'PI(s)' 
                    if app.Typenum > 0
                        app.runtime = round(1.5*str2double( app.PIs.Notes{1} ), 0);
                    else
                        app.runtime = round(1.5*max([ str2double( app.G.Notes{1}), str2double( app.PIs.Notes{1})]),0);
                    end 

                case 'PD(s)' 
                    if app.Typenum > 0
                        app.runtime = round(1.5*str2double( app.PDs.Notes{1} ), 0);
                    else
                        app.runtime = round(1.5*max([ str2double( app.G.Notes{1}), str2double( app.PDs.Notes{1})]),0);
                    end

                case 'PID(s)' 
                    if app.Typenum > 0
                        app.runtime = round(1.5*str2double( app.PIDs.Notes{1} ), 0);
                    else
                        app.runtime = round(1.5*max([ str2double( app.G.Notes{1}), str2double( app.PIDs.Notes{1})]),0);
                    end

                case 'P(z)'  
                    if app.Typenum > 0
                        app.runtime = round(1.5*str2double( app.Pz.Notes{1} ), 0);
                    else
                        app.runtime = round(1.5*max([ str2double( app.Gz.Notes{1}), str2double( app.Pz.Notes{1})]),0);
                    end

                case 'PI(z)' 
                    if app.Typenum > 0
                        app.runtime = round(1.5*str2double( app.PIz.Notes{1} ), 0);
                    else
                        app.runtime = round(1.5*max([ str2double( app.Gz.Notes{1}), str2double( app.PIz.Notes{1})]),0);
                    end

                case 'PD(z)' 
                    if app.Typenum > 0
                        app.runtime = round(1.5*str2double( app.PDz.Notes{1} ), 0);
                    else
                        app.runtime = round(1.5*max([ str2double( app.Gz.Notes{1}), str2double( app.PDz.Notes{1})]),0);
                    end

                case 'PID(z)' 
                    if app.Typenum > 0
                        app.runtime = round(1.5*str2double( app.PIDz.Notes{1} ), 0);
                    else
                        app.runtime = round(1.5*max([ str2double( app.Gz.Notes{1}), str2double( app.PIDz.Notes{1})]),0);
                    end

                otherwise 
                        app.runtime = round(2*str2double( app.G.Notes{1}),0);

            end

            app.runtime=int32(app.runtime)+int32(app.runtime)-2*(int32(app.runtime)/2-1);
            if(app.Tdelay > app.threshold) 
                app.runtime=app.runtime+round(app.Tdelay+0.5);
            end

            % Change run time limit if it is necessary
            if(app.runtime < app.threshold) 
                if app.G.Variable == 's'
                    app.runtime = round(1.5*str2double( app.Ps.Notes{1} ), 0);
                else
                    app.runtime = round(1.5*str2double( app.Pz.Notes{1} ), 0);
                end
                if(app.runtime < app.threshold) 
                    app.runtime = 12;
                end
            end
            
            % Plot main screen
            cla(app.UIAxes);
            hold(app.UIAxes,'on');
            appGdisp(app,1);        % Plant
            appCLdisp(app,1);       % Closed loop
            title(app.UIAxes,'Step responses');
            if app.Mactive.K == 0
                legend(app.UIAxes,cat(1,('Plant ')',('[')',(' sec]')'),'FontSize',14);
            else
%                legend(app.UIAxes,cat(1,('Plant ')',('[')', char(app.G.Notes)',(' sec]')'),cat(1,('Closed loop ')',('[')', char(app.CL.Notes)',(' sec]')'),'FontSize',14);
                legend(app.UIAxes,cat(1,('Plant ')',('[')', char(app.G.Notes)',(' sec]')'),cat(1,('Closed loop ')',('[')', char(app.CL.Notes)',(' sec]')'),'FontSize',14);
            end
            grid(app.UIAxes,'on');
            hold(app.UIAxes,'off');

%%**********************************************
%%SystembehavioursButtonPushed(app,event);
% This part defines responses of the plant and compensator
% as well as the plots of Bode and Nyquist/Root Locus diagrams
% Input: -
% Output: -
            app.TabGroup.SelectedTab = app.TabGroup.Children(2);
%            updateTransferFunctionRender(app); % ensure current compensator showing

            % Set time limit: UIAxes_1.XLim = UIAxes_2.XLim = UIAxes.XLim
            app.runtime = app.UIAxes.XLim(end);
            % app.runtime = RuntimeLimit(app);
            if app.runtime < app.threshold
                app.runtime = app.time(end);
                if app.runtime < app.threshold
                    app.runtime = 10;
                end
            end

% Second plot with corrected XLIM
            % Plot main screen
            cla(app.UIAxes);
            hold(app.UIAxes,'on');
            appGdisp(app,1);        % Plant
            appCLdisp(app,1);       % Closed loop
            title(app.UIAxes,'Step responses');
            if app.Mactive.K == 0
                legend(app.UIAxes,cat(1,('Plant ')',('[')',(' sec]')'),'FontSize',14);
            else
                legend(app.UIAxes,cat(1,('Plant ')',('[')', char(app.G.Notes)',(' sec]')'),cat(1,('Closed loop ')',('[')', char(app.CL.Notes)',(' sec]')'),'FontSize',14);
            end
            grid(app.UIAxes,'on');
            hold(app.UIAxes,'off');
% Rnd of 2nd plot
            
            
            
            
            
            %
            %   Step responses diagram
            %

            cla(app.UIAxes_1);
            hold(app.UIAxes_1,"on");
            appGdisp(app,2);
            appCLdisp(app,2);
            if app.Mactive.K == 0
                legend(app.UIAxes_1,cat(1,('PLANT ')',('[')', (' sec]')'),'FontSize',10);
            else
                legend(app.UIAxes_1,cat(1,('Plant ')',('[')', char(app.G.Notes)',(' sec]')'),cat(1,('Closed loop ')',('[')', char(app.CL.Notes)',(' sec]')'),'FontSize',10);
            end
            grid(app.UIAxes_1,'on');
            hold(app.UIAxes_1,'off');

            %
            %   Output of the controller
            %

            cla(app.UIAxes_2);
            legend(app.UIAxes_2,(appUdisp(app))','FontSize',10)
            grid(app.UIAxes_2,'on');

            %
            %   BODE diagram
            %

            cla(app.UIAxes_3);
            cla(app.UIAxes_4);
            appBodedisp(app)

            %
            %   NYQUIST / ROOT LOCUS
            %

            cla(app.UIAxes_5);
            cla(app.UIAxes_6);
            ChangeNyquist2RootLocus(app)


%%UpdateSummaryButtonPushed(app,event);
% This part helps to compare the responses of the
% different controllers by the help of their plots

            app.TabGroup.SelectedTab = app.TabGroup.Children(3);
            vari=app.Mactive.Variable;

            % run time used in the main sheet
            app.runtime = app.UIAxes.XLim(end);
            if app.runtime < app.threshold
                app.runtime = app.time(end);
                if app.runtime < app.threshold
                    app.runtime = 10;
                end
            end

            % Set upper time limit
            if vari == 's'
                app.time = (0 : app.runtime/(app.samples-1) : app.runtime)';
            else
                app.time = (0 : app.Ts : app.runtime)';
            end
            % Set title, subtitle and axes
            y=step(app.G,app.time);
            plot(app.UIAxes_7,app.time,y,'linewidth',2);
            a={ cat(1,('Plant [')', char(app.G.Notes)',(' sec]')') };

            hold(app.UIAxes_7,"on");

            if isempty(app.Ps)
                updateTransferFunctionRender(app)
            end

            % Drawing of the different controllers 
            % that can be used for this plant
            empty=tf(0,1);
            if vari == 's'
                if equal(app,app.Ps,empty) == 0
                    F=minreal(app.Ps*app.G/(1+app.Ps*app.G));
                    y=step(F,app.time);
                    plot(app.UIAxes_7,app.time,y,'linewidth',2);
                    a=[a, cat(1,('Ps [')', char(app.Ps.Notes)',(' sec]')')];
                end

                if equal(app,app.PIs,empty) == 0
                    F=minreal(app.PIs*app.G/(1+app.PIs*app.G));
                    y=step(F,app.time);
                    plot(app.UIAxes_7,app.time,y,'linewidth',2);
                    a=[a, cat(1,('PIs [')', char(app.PIs.Notes)',(' sec]')')];
                end

                if equal(app,app.PDs,empty) == 0
                    F=minreal(app.PDs*app.G/(1+app.PDs*app.G));
                    y=step(F,app.time);
                    plot(app.UIAxes_7,app.time,y,'linewidth',2);
                    a=[a, cat(1,('PDs [')', char(app.PDs.Notes)',(' sec]')')];
                end

                if equal(app,app.PIDs,empty) == 0
                    F=minreal(app.PIDs*app.G/(1+app.PIDs*app.G));
                    if ~isempty(F)
                        y=step(F,app.time);
                        plot(app.UIAxes_7,app.time,y,'linewidth',2);
                        a=[a, cat(1,('PIDs [')', char(app.PIDs.Notes)',(' sec]')')];
                    end
                end

                if equal(app,app.POwn,empty)==0
                    F=minreal(app.POwn*app.G/(1+app.POwn*app.G));
                    y=step(F,app.time);
                    plot(app.UIAxes_7,app.time,y,'linewidth',2);
                    a=[a, cat(1,('POwn [')', char(app.POwn.Notes)',(' sec]')')];
                end
                legend(app.UIAxes_7,a','FontSize',10);

            elseif app.Mactive.Variable == 'z'
                if equal(app,app.POwn,empty)==0
                    % F=minreal(app.POwn*app.Gz/(1+app.POwn*app.Gz));
                    % y=step(F,app.time);
                    L=d2c(app.POwn,'tustin');
                    L=minreal(app.G*L,0.0001);
                    F=minreal(L/(1+L),0.0001);
                    [y,t]=step(F,app.runtime);
                    plot(app.UIAxes_7,t,y,'linewidth',2);
                    a=[a, cat(1,('POwn [')', char(app.POwn.Notes)',(' sec]')')];
                end
                
                empty=0*tf(1,1,app.Ts);
                if equal(app,app.Pz,empty) == 0
                    % F=minreal(app.Pz*app.Gz/(1+app.Pz*app.Gz));
                    % y=step(F,app.time);
                    % plot(app.UIAxes_7,app.time,y,'linewidth',2);
                    L=d2c(app.Pz,'tustin');
                    L=minreal(app.G*L,0.0001);
                    F=minreal(L/(1+L),0.0001);
                    [y,t]=step(F,app.runtime);
                    plot(app.UIAxes_7,t,y,'linewidth',2);
                    a=[a, cat(1,('Pz [')', char(app.Pz.Notes)',(' sec]')')];
                end

                if equal(app,app.PIz,empty) == 0
                    % F=minreal(app.PIz*app.Gz/(1+app.PIz*app.Gz));
                    % y=step(F,app.time);
                    L=d2c(app.PIz,'tustin');
                    L=minreal(app.G*L,0.0001);
                    F=minreal(L/(1+L),0.0001);
                    [y,t]=step(F,app.runtime);
                    plot(app.UIAxes_7,t,y,'linewidth',2);
                    a=[a, cat(1,('PIz [')', char(app.PIz.Notes)',(' sec]')')];
                end

                if equal(app,app.PDz,empty) == 0
                    L=d2c(app.PDz,'tustin');
                    L=minreal(app.G*L,0.0001);
                    F=minreal(L/(1+L),0.0001);
                    [y,t]=step(F,app.runtime);
                    plot(app.UIAxes_7,t,y,'linewidth',2);
                    a=[a, cat(1,('PDz [')', char(app.PDz.Notes)',(' sec]')')];
                end

                if equal(app,app.PIDz,empty) == 0
                    L=d2c(app.PIDz,'tustin');
                    L=minreal(app.G*L,0.0001);
                    F=minreal(L/(1+L),0.0001);
                    [y,t]=step(F,app.runtime);
                    plot(app.UIAxes_7,t,y,'linewidth',2);
                    a=[a, cat(1,('PIDz [')', char(app.PIDz.Notes)',(' sec]')')];
                end

                legend(app.UIAxes_7,a','FontSize',10);
               
            end
            grid(app.UIAxes_7,'on');
            hold(app.UIAxes_7,"off");

            app.TabGroup.SelectedTab = app.TabGroup.Children(1);

            updateMessages(app,2,lastwarn());
            lastwarn('');


%%**********************************************
        end

        % Button pushed function: SystembehavioursButton
        function SystembehavioursButtonPushed(app, event)

        end

        % Button pushed function: UpdateSummaryButton
        function UpdateSummaryButtonPushed(app, event)

        end

        % Value changed function: PlantDropDown
        function PlantDropDownValueChanged(app, event)
            value = app.PlantDropDown.Value;
            q1=event;
            K=app.G;

            s=tf('s');
            b=0;
            try
                app.G = eval(value);
            catch
                b=b+1;
            end

            if b>0
                updateMessages(app,1,'ERROR in tf of plant!');
            else
                updateMessages(app,1,'Messages: ');
                if equal(app,K,app.G)==0 % || old Ts ~= new Ts 
                    app.Tdelay=app.G.OutputDelay+app.G.InputDelay+app.G.IODelay;
                    if isnumeric(app.G)
                        app.G = tf(app.G,1);
                    end
                    % create app.G
                    app.G=minreal(app.G,0.0001);
                    app.G.Notes = SetNotes(app,app.G);

                    % calculate typenumber
                    [~,p,~]=zpkdata(app.G,'v');
                    app.Typenum=0;
                    for i=1:length(p)
                        if abs(p(i))  < app.threshold
                            app.Typenum=app.Typenum+1;
                        end
                    end

                    p=abs(p);
                    p=p(p > app.threshold);
                    p=sort(p);
                    if length(p) == 1
                        if app.Typenum == 1 || app.Typenum == 2
                            app.p2r(1) = 0;
                            app.p2r(2) = p(1);
                        else
                            app.p2r(1) = p(1);
                            app.p2r(2) = 0;
                        end
                    elseif length(p) > 1
                        app.p2r(1) = p(1);
                        app.p2r(2) = p(2);
                    end

                    % calculate sample time
                    SetSampleTime(app);

                    % create z transf. of app.G
                    app.Gz = c2d(app.G,app.Ts);
                    app.Gz.Notes = SetNotes(app,app.Gz);

                    app.runtime = RuntimeLimit(app);


                    % create new drop down list
                    tmp=0;
                    for i=2:6
                        if strcmp(value, app.PlantDropDown.Items(i))
                            tmp=1;
                        end
                    end
                    if tmp == 0
                        app.PlantDropDown.Items = {' ', value, char(app.PlantDropDown.Items(2)), char(app.PlantDropDown.Items(3)),char(app.PlantDropDown.Items(4)),char(app.PlantDropDown.Items(5))};
                    end

%                    UpdateSystemdetailsButtonPushed(app);
                else
                    if isnumeric(app.G)
                        app.G = tf(app.G,1);
                    end
                end
            end
        end

        % Value changed function: UserschoiceDropDown
        function UserschoiceDropDownValueChanged(app, event)
% This function reads values of ControllerDropDown. If valid
% controller is given/selected, M(s/z) is set.
% Input: -
% Output: -
          clc;
          value = app.UserschoiceDropDown.Value;
          if length(value) > 3
            app.ControllertypeDropDown.Value = 'User''s choice'; %'Own';
 
            % create Mactive
            s=tf('s');
            z=tf('z',app.Ts);
            b=0;
            K=app.Mactive;

            % Did you enter the controller correctly?
            try
                app.Mactive = eval(value);
            catch
                b=b+1;
            end
            if b>0
            % If not
                updateMessages(app,1,'Controller ERROR! Type again')
            else
            % Correct controller
                updateMessages(app,1,'Messages: ')
                if isnumeric(app.Mactive)
                    app.Mactive = tf(app.Mactive,1);
                end

                % Is it not the same as the previous one?
                % If not, define details of the process
                if equal(app,K,app.Mactive) == 0
                % Settling and run time
                    app.Mactive.Notes = SetNotes(app,app.Mactive);
                    app.runtime = RuntimeLimit(app);

                % Variable and sample time
                    vari = app.Mactive.Variable;
                    if vari == 'z' && app.Ts > app.threshold
                        app.Gz = c2d(app.G,app.Ts);
                        app.Gz.Notes = SetNotes(app,app.Gz);
                    end
                % type number
                    [z,p,k]=zpkdata(app.Mactive,'v');
                    typenum=0;
                    for i=1:length(p)
                        if vari == 's'
                            if abs(p(i))  < app.threshold
                                typenum=typenum+1;
                            end
                        elseif vari == 'z'
                            if abs(abs(p(i)-1))  < app.threshold
                                typenum=typenum+1;
                            end
                        end
                    end

                % Create numerator of the controller using poles to replace
                    p=abs(z);
                    p=p(p > app.threshold);
                    p=sort(p);
                    if length(p) == 1
                        if typenum == 1 || typenum == 2
                            app.z2r(1) = p(1);
                            app.z2r(2) = 0;
                        else
                            app.z2r(1) = 0;
                            app.z2r(2) = p(1);
                        end
                    elseif length(p) > 1
                        app.z2r(1) = p(1);
                        app.z2r(2) = p(2);
                    end

                % Set sliders according to the controller
                    app.KpSlider.Value = SliderLimit(app,1,k);
                    app.KpSliderLabel.Text = cat(1,('Kp(')',char(num2str(k,'%.2f'))',(')')' )';
                    if length(p) == 0
                        app.TiSlider.Value = 0;
                        app.TdSlider.Value = 0;
                    elseif length(p) == 1
                        app.TiSlider.Value = SliderLimit(app,2,p(1));
                        app.TdSlider.Value = 0;
                    else
                        app.TiSlider.Value = SliderLimit(app,2,p(1));
                        app.TdSlider.Value = SliderLimit(app,3,p(2));
                    end
                    app.TiSliderLabel.Text = cat(1,('1/Ti(')',char(num2str(app.TiSlider.Value,'%.2f'))',(')')' )';
                    app.TdSliderLabel.Text = cat(1,('1/Td(')',char(num2str(app.TdSlider.Value,'%.2f'))',(')')' )';

                    % create new drop down list
                    tmp=0;
                    for i=2:6
                        if strcmp(value, app.UserschoiceDropDown.Items(i))
                            tmp=1;
                        end
                    end
                    if tmp == 0
                        app.UserschoiceDropDown.Items = {' ', value, char(app.UserschoiceDropDown.Items(2)), char(app.UserschoiceDropDown.Items(3)),char(app.UserschoiceDropDown.Items(4)),char(app.UserschoiceDropDown.Items(5))};
                    end
                    % Plot results
%                    UpdateSystemdetailsButtonPushed(app);
                end
            end
          end
        end

        % Value changed function: ControllertypeDropDown
        function ControllertypeDropDownValueChanged(app, event)
            value = app.ControllertypeDropDown.Value;
            updateMessages(app,1,'Messages: ');
%            UpdateSystemdetailsButtonPushed(app);
        end

        % Value changed function: SampletimesEditField
        function SampletimesEditFieldValueChanged(app, event)
            value = app.SampletimesEditField.Value;
            updateMessages(app,2,cat(1,('New Ts: ')',char(num2str(value))',(' [sec]')')')
            SetSampleTime(app);
            PlantDropDownValueChanged(app, event);
            UserschoiceDropDownValueChanged(app, event);
        end

        % Value changed function: KpSlider
        function KpSliderValueChanged(app, event)
            value = app.KpSlider.Value;
            value=round(value,2);
            updateMessages(app,1,'Messages: ');

            % Display new value of Kp
            app.KpSlider.Value=SliderLimit(app,1,value);
            app.KpSliderLabel.Text = cat(1,('Kp(')',char(num2str(value,'%.2f'))',(')')' )';

            [~,~,k]=zpkdata(app.Mactive,'v');
            app.Mactive = value*app.Mactive/k;

            % Create transfer function of M(s/z) by 
            % transfer back text of M(s/z)
            ae=zpkback(app,zpkdisp(app,1));

            % If you change the value of sliders => controller 
            % becomes an Own controller. It is transferred 
            % to the Own window to edit it.
            
            tmp=0;
            for i=2:6
                if strcmp(ae, app.UserschoiceDropDown.Items(i))
                    tmp=1;
                end
            end
            if tmp == 0
                app.UserschoiceDropDown.Items = {' ', char(ae), char(app.UserschoiceDropDown.Items(2)), char(app.UserschoiceDropDown.Items(3)),char(app.UserschoiceDropDown.Items(4)),char(app.UserschoiceDropDown.Items(5))};
            end

            app.ControllertypeDropDown.Value = 'User''s choice'; %'Own';

            app.UserschoiceDropDown.Items(2);
            app.UserschoiceDropDown.Value = char(ae)';

            UpdateSystemdetailsButtonPushed(app, event);
        end

        % Value changed function: TiSlider
        function TiSliderValueChanged(app, event)
            value = app.TiSlider.Value;
            value=round(value,2);
            updateMessages(app,1,'Messages: ');

            % Display new value of Kp
            app.TiSlider.Value=SliderLimit(app,2,value);
            app.TiSliderLabel.Text = cat(1,('1/Ti(')',char(num2str(value,'%.2f'))',(')')' )';
            
            % Can Ti be changed?
            l=0;
            if app.Mactive.Variable == 's'
                if app.z2r(1) > app.threshold && value > app.threshold
                    app.z2r(1) = value;
                    k=zpk(app.Mactive).K;
                    app.Mactive = k*minreal(tf([1 app.z2r(1)],[1 0]) * tf([1 app.z2r(2)],[1 3*app.z2r(2)]));
                    l=1;
                end

            elseif app.Mactive.Variable == 'z' 
                if abs(app.z2r(1)) > app.threshold && value > app.threshold
                    app.z2r(1) = value;
                    k=zpk(app.Mactive).K;
                    if abs(app.z2r(2)) < app.threshold
                        app.Mactive = k*minreal(tf([1 -exp(-app.Ts*abs(app.z2r(1)))],[1 -1],app.Ts)); %*tf([1 -exp(-app.Ts*abs(p(2)))],[1 0],app.Ts);
                    else
                        app.Mactive = k*minreal(tf([1 -exp(-app.Ts*abs(app.z2r(1)))],[1 -1],app.Ts)*tf([1 -exp(-app.Ts*abs(app.z2r(2)))],[1 0],app.Ts));
                    end
                    l=1;
                end
            end

            if l>0
                ae=zpkback(app,zpkdisp(app,1));

                % If you change value of sliders => controller 
            % becomes an Own controller. It is transferred 
            % to the Own window to edit it.

                tmp=0;
                for i=2:6
                    if strcmp(ae, app.UserschoiceDropDown.Items(i))
                         tmp=1;
                    end
                end
                if tmp == 0
                    app.UserschoiceDropDown.Items = {' ', char(ae), char(app.UserschoiceDropDown.Items(2)), char(app.UserschoiceDropDown.Items(3)),char(app.UserschoiceDropDown.Items(4)),char(app.UserschoiceDropDown.Items(5))};
                end

                app.ControllertypeDropDown.Value = 'User''s choice'; %'Own';

                app.UserschoiceDropDown.Value = char(ae)';
            end
            UpdateSystemdetailsButtonPushed(app, event);
        end

        % Value changed function: TdSlider
        function TdSliderValueChanged(app, event)
            value = app.TdSlider.Value;
            value = round(value,2);
            updateMessages(app,1,'Messages: ');

            % New value of Td
            app.TdSlider.Value=SliderLimit(app,3,value);
            app.TdSliderLabel.Text = cat(1,('1/Td(')',char(num2str(value,'%.2f'))',(')')' )';
            % vari = app.Mactive.Variable;

            [z,p,k,Ts]=zpkdata(app.Mactive,'v');
            
            lz=length(z);
            lp=length(p);

            if abs(Ts) < app.threshold
                vari = 's';
            else
                vari = 'z';
            end
            
            l=0;
            if vari == 'z'
                if min(abs(p)) < app.threshold
                    a=min(z(z~=0));
                    for i=1:lz
                        if z(i) == a
                            l=i;
                        end
                    end
                    a=l;
                end
                if l > 0
                    z(a)=exp(-app.Ts*value);
                    app.Mactive=zpk(z,p,k,app.Ts);
                end

            else
                l=0; m=0;
                for i=1:lz
                    for j=1:lp
                        if abs(3*z(i)-p(j)) < app. threshold
                            l=i; m=j;
                        end
                    end
                end

                if l > 0 && m> 0
                    if vari == 's'
                        z(l)=-value; 
                    else
                        z(l)=-exp(-app.Ts*value);
                    end
                    p(m)=-3*value;
                    app.Mactive=zpk(z,p,k);
                end
            end

            if l > 0
                ae=zpkback(app,zpkdisp(app,1));
                tmp=0;
                for i=2:6
                    if strcmp(ae, app.UserschoiceDropDown.Items(i))
                        tmp=1;
                    end
                end
                if tmp == 0
                    app.UserschoiceDropDown.Items = {' ', char(ae), char(app.UserschoiceDropDown.Items(2)), char(app.UserschoiceDropDown.Items(3)),char(app.UserschoiceDropDown.Items(4)),char(app.UserschoiceDropDown.Items(5))};
                end

                app.ControllertypeDropDown.Value = 'User''s choice'; %'Own';

                app.UserschoiceDropDown.Value = char(ae)';
            end
            UpdateSystemdetailsButtonPushed(app, event);              
        end

        % Button down function: UIAxes_5
        function ChangeRootLocus2Nyquist(app, event)
% Clicking on the surface of root locus diagram 
% it changes to Nyquist diagram
            app.UIAxes_5.Toolbar.Visible = 'off';
                app.UIAxes_5.Visible = 'off';
                cla(app.UIAxes_5);
                app.UIAxes_6.Toolbar.Visible = 'on';
                app.UIAxes_6.Visible = 'on';
                DispRootLocus(app);
        end

        % Button down function: UIAxes_6
        function ChangeNyquist2RootLocus(app, event)
% Clicking on the surface of Nyquist diagram 
% it changes to root locus diagram
                app.UIAxes_6.Toolbar.Visible = 'off';
                app.UIAxes_6.Visible = 'off';
                cla(app.UIAxes_6);
                app.UIAxes_5.Toolbar.Visible = 'on';
                app.UIAxes_5.Visible = 'on';
                DispNyquist(app);
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
            app.UIFigure.Position = [100 100 1193 921];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout.RowHeight = {'0.4x', '0.15x', '1.5x', 0, '1.16x', '1x'};

            % Create CalculatedTransferFunctions
            app.CalculatedTransferFunctions = uigridlayout(app.GridLayout);
            app.CalculatedTransferFunctions.ColumnWidth = {'1x', '3x'};
            app.CalculatedTransferFunctions.Padding = [0 0 0 0];
            app.CalculatedTransferFunctions.Layout.Row = 6;
            app.CalculatedTransferFunctions.Layout.Column = 3;
            app.CalculatedTransferFunctions.BackgroundColor = [1 1 1];

            % Create OpenLoop
            app.OpenLoop = uilabel(app.CalculatedTransferFunctions);
            app.OpenLoop.BackgroundColor = [0.9294 0.6941 0.1255];
            app.OpenLoop.HorizontalAlignment = 'center';
            app.OpenLoop.FontSize = 18;
            app.OpenLoop.Layout.Row = 1;
            app.OpenLoop.Layout.Column = 1;
            app.OpenLoop.Text = {'Open'; 'loop'};

            % Create OpenLooplabelLabel
            app.OpenLooplabelLabel = uilabel(app.CalculatedTransferFunctions);
            app.OpenLooplabelLabel.BackgroundColor = [0.9294 0.6941 0.1255];
            app.OpenLooplabelLabel.HorizontalAlignment = 'center';
            app.OpenLooplabelLabel.FontSize = 18;
            app.OpenLooplabelLabel.Layout.Row = 1;
            app.OpenLooplabelLabel.Layout.Column = 2;
            app.OpenLooplabelLabel.Interpreter = 'latex';
            app.OpenLooplabelLabel.Text = 'OpenLooplabel';

            % Create ClosedloopLabel
            app.ClosedloopLabel = uilabel(app.CalculatedTransferFunctions);
            app.ClosedloopLabel.BackgroundColor = [0.9294 0.6941 0.1255];
            app.ClosedloopLabel.HorizontalAlignment = 'center';
            app.ClosedloopLabel.FontSize = 18;
            app.ClosedloopLabel.Layout.Row = 2;
            app.ClosedloopLabel.Layout.Column = 1;
            app.ClosedloopLabel.Text = {'Closed'; 'loop'};

            % Create ClosedLoopLabel
            app.ClosedLoopLabel = uilabel(app.CalculatedTransferFunctions);
            app.ClosedLoopLabel.BackgroundColor = [0.9294 0.6941 0.1255];
            app.ClosedLoopLabel.HorizontalAlignment = 'center';
            app.ClosedLoopLabel.FontSize = 18;
            app.ClosedLoopLabel.Layout.Row = 2;
            app.ClosedLoopLabel.Layout.Column = 2;
            app.ClosedLoopLabel.Interpreter = 'latex';
            app.ClosedLoopLabel.Text = 'ClosedLoopLabel';

            % Create SystemTransferFunctions
            app.SystemTransferFunctions = uigridlayout(app.GridLayout);
            app.SystemTransferFunctions.ColumnWidth = {'1x', '3x'};
            app.SystemTransferFunctions.Padding = [0 0 0 0];
            app.SystemTransferFunctions.Layout.Row = 6;
            app.SystemTransferFunctions.Layout.Column = 2;
            app.SystemTransferFunctions.BackgroundColor = [1 1 1];

            % Create MsLabel
            app.MsLabel = uilabel(app.SystemTransferFunctions);
            app.MsLabel.BackgroundColor = [0.9294 0.6941 0.1255];
            app.MsLabel.HorizontalAlignment = 'center';
            app.MsLabel.FontSize = 18;
            app.MsLabel.Layout.Row = 2;
            app.MsLabel.Layout.Column = 1;
            app.MsLabel.Text = 'M(s)';

            % Create MslabelLabel
            app.MslabelLabel = uilabel(app.SystemTransferFunctions);
            app.MslabelLabel.BackgroundColor = [0.9294 0.6941 0.1255];
            app.MslabelLabel.HorizontalAlignment = 'center';
            app.MslabelLabel.FontSize = 18;
            app.MslabelLabel.Layout.Row = 2;
            app.MslabelLabel.Layout.Column = 2;
            app.MslabelLabel.Interpreter = 'latex';
            app.MslabelLabel.Text = 'Mslabel';

            % Create GsLabel
            app.GsLabel = uilabel(app.SystemTransferFunctions);
            app.GsLabel.BackgroundColor = [0.9294 0.6941 0.1255];
            app.GsLabel.HorizontalAlignment = 'center';
            app.GsLabel.FontSize = 18;
            app.GsLabel.Layout.Row = 1;
            app.GsLabel.Layout.Column = 1;
            app.GsLabel.Text = 'G(s)';

            % Create GslabelLabel
            app.GslabelLabel = uilabel(app.SystemTransferFunctions);
            app.GslabelLabel.BackgroundColor = [0.9294 0.6941 0.1255];
            app.GslabelLabel.HorizontalAlignment = 'center';
            app.GslabelLabel.FontSize = 18;
            app.GslabelLabel.Layout.Row = 1;
            app.GslabelLabel.Layout.Column = 2;
            app.GslabelLabel.Interpreter = 'latex';
            app.GslabelLabel.Text = 'Gslabel';

            % Create MessagesLabel
            app.MessagesLabel = uilabel(app.GridLayout);
            app.MessagesLabel.BackgroundColor = [0.9294 0.6941 0.1255];
            app.MessagesLabel.VerticalAlignment = 'top';
            app.MessagesLabel.WordWrap = 'on';
            app.MessagesLabel.Layout.Row = 6;
            app.MessagesLabel.Layout.Column = 1;
            app.MessagesLabel.Interpreter = 'latex';
            app.MessagesLabel.Text = 'Messages';

            % Create ManualSelection
            app.ManualSelection = uigridlayout(app.GridLayout);
            app.ManualSelection.ColumnWidth = {'1x', '3x'};
            app.ManualSelection.RowHeight = {'1x', '1x', '1x', '1x'};
            app.ManualSelection.Layout.Row = 5;
            app.ManualSelection.Layout.Column = 1;
            app.ManualSelection.BackgroundColor = [1 0.8 0.6];

            % Create TdSlider
            app.TdSlider = uislider(app.ManualSelection);
            app.TdSlider.Limits = [0 4];
            app.TdSlider.MajorTicks = [0 0.5 1 1.5 2 2.5 3 3.5 4];
            app.TdSlider.ValueChangedFcn = createCallbackFcn(app, @TdSliderValueChanged, true);
            app.TdSlider.MinorTicks = [0 0.125 0.25 0.375 0.5 0.625 0.75 0.875 1 1.125 1.25 1.375 1.5 1.625 1.75 1.875 2 2.125 2.25 2.375 2.5 2.625 2.75 2.875 3 3.125 3.25 3.375 3.5 3.625 3.75 3.875 4];
            app.TdSlider.FontSize = 14;
            app.TdSlider.Layout.Row = 4;
            app.TdSlider.Layout.Column = 2;
            app.TdSlider.Value = 0.5;

            % Create KpSliderLabel
            app.KpSliderLabel = uilabel(app.ManualSelection);
            app.KpSliderLabel.HorizontalAlignment = 'center';
            app.KpSliderLabel.FontSize = 14;
            app.KpSliderLabel.Layout.Row = 2;
            app.KpSliderLabel.Layout.Column = 1;
            app.KpSliderLabel.Text = 'Kp';

            % Create TiSliderLabel
            app.TiSliderLabel = uilabel(app.ManualSelection);
            app.TiSliderLabel.HorizontalAlignment = 'center';
            app.TiSliderLabel.FontSize = 14;
            app.TiSliderLabel.Layout.Row = 3;
            app.TiSliderLabel.Layout.Column = 1;
            app.TiSliderLabel.Text = 'Ti';

            % Create TiSlider
            app.TiSlider = uislider(app.ManualSelection);
            app.TiSlider.Limits = [0 4];
            app.TiSlider.MajorTicks = [0 0.5 1 1.5 2 2.5 3 3.5 4];
            app.TiSlider.ValueChangedFcn = createCallbackFcn(app, @TiSliderValueChanged, true);
            app.TiSlider.MinorTicks = [0 0.125 0.25 0.375 0.5 0.625 0.75 0.875 1 1.125 1.25 1.375 1.5 1.625 1.75 1.875 2 2.125 2.25 2.375 2.5 2.625 2.75 2.875 3 3.125 3.25 3.375 3.5 3.625 3.75 3.875 4];
            app.TiSlider.FontSize = 14;
            app.TiSlider.Layout.Row = 3;
            app.TiSlider.Layout.Column = 2;
            app.TiSlider.Value = 0.5;

            % Create TdSliderLabel
            app.TdSliderLabel = uilabel(app.ManualSelection);
            app.TdSliderLabel.HorizontalAlignment = 'center';
            app.TdSliderLabel.FontSize = 14;
            app.TdSliderLabel.Layout.Row = 4;
            app.TdSliderLabel.Layout.Column = 1;
            app.TdSliderLabel.Text = 'Td';

            % Create KpSlider
            app.KpSlider = uislider(app.ManualSelection);
            app.KpSlider.Limits = [0 4];
            app.KpSlider.MajorTicks = [0 0.5 1 1.5 2 2.5 3 3.5 4];
            app.KpSlider.ValueChangedFcn = createCallbackFcn(app, @KpSliderValueChanged, true);
            app.KpSlider.MinorTicks = [0 0.125 0.25 0.375 0.5 0.625 0.75 0.875 1 1.125 1.25 1.375 1.5 1.625 1.75 1.875 2 2.125 2.25 2.375 2.5 2.625 2.75 2.875 3 3.125 3.25 3.375 3.5 3.625 3.75 3.875 4];
            app.KpSlider.FontSize = 14;
            app.KpSlider.Layout.Row = 2;
            app.KpSlider.Layout.Column = 2;
            app.KpSlider.Value = 1;

            % Create ManuallyselectedPIDparametersinUserschoiceMsLabel
            app.ManuallyselectedPIDparametersinUserschoiceMsLabel = uilabel(app.ManualSelection);
            app.ManuallyselectedPIDparametersinUserschoiceMsLabel.BackgroundColor = [1 0.502 0.302];
            app.ManuallyselectedPIDparametersinUserschoiceMsLabel.HorizontalAlignment = 'center';
            app.ManuallyselectedPIDparametersinUserschoiceMsLabel.WordWrap = 'on';
            app.ManuallyselectedPIDparametersinUserschoiceMsLabel.FontSize = 16;
            app.ManuallyselectedPIDparametersinUserschoiceMsLabel.FontWeight = 'bold';
            app.ManuallyselectedPIDparametersinUserschoiceMsLabel.Layout.Row = 1;
            app.ManuallyselectedPIDparametersinUserschoiceMsLabel.Layout.Column = [1 2];
            app.ManuallyselectedPIDparametersinUserschoiceMsLabel.Text = 'Manually selected PID parameters in Users choice M(s)';

            % Create SystemDescription
            app.SystemDescription = uigridlayout(app.GridLayout);
            app.SystemDescription.ColumnWidth = {'0.8x', '1x'};
            app.SystemDescription.RowHeight = {'0.7x', '0.8x', '0.8x', '0.8x', '0.8x'};
            app.SystemDescription.Layout.Row = 3;
            app.SystemDescription.Layout.Column = 1;
            app.SystemDescription.BackgroundColor = [0.902 1 0.502];

            % Create SystemdescriptionGsandMsMzLabel
            app.SystemdescriptionGsandMsMzLabel = uilabel(app.SystemDescription);
            app.SystemdescriptionGsandMsMzLabel.BackgroundColor = [1 1 0];
            app.SystemdescriptionGsandMsMzLabel.HorizontalAlignment = 'center';
            app.SystemdescriptionGsandMsMzLabel.FontSize = 16;
            app.SystemdescriptionGsandMsMzLabel.FontWeight = 'bold';
            app.SystemdescriptionGsandMsMzLabel.Layout.Row = 1;
            app.SystemdescriptionGsandMsMzLabel.Layout.Column = [1 2];
            app.SystemdescriptionGsandMsMzLabel.Text = 'System description G(s) and M(s)/M(z)';

            % Create PlantDropDownLabel
            app.PlantDropDownLabel = uilabel(app.SystemDescription);
            app.PlantDropDownLabel.HorizontalAlignment = 'center';
            app.PlantDropDownLabel.FontSize = 16;
            app.PlantDropDownLabel.Layout.Row = 2;
            app.PlantDropDownLabel.Layout.Column = 1;
            app.PlantDropDownLabel.Text = 'Plant';

            % Create PlantDropDown
            app.PlantDropDown = uidropdown(app.SystemDescription);
            app.PlantDropDown.Items = {' ', '2*exp(-5*s)/(1+10*s)', '4/((s+1)*(s+2))', '2/((s+1)*(s+0.5)*(s+2))', '(s+15)/((s+1)*(s+3)*(s+5))', 'exp(-0.5*s)*(s+15)/((s+1)*(s+3)*(s+5))', '2/(s^2+0.4*s+1)', '10*(s+1)/((s*s+4*s+10))'};
            app.PlantDropDown.Editable = 'on';
            app.PlantDropDown.ValueChangedFcn = createCallbackFcn(app, @PlantDropDownValueChanged, true);
            app.PlantDropDown.FontSize = 18;
            app.PlantDropDown.Layout.Row = 2;
            app.PlantDropDown.Layout.Column = 2;
            app.PlantDropDown.Value = '(s+15)/((s+1)*(s+3)*(s+5))';

            % Create UserschoiceDropDownLabel
            app.UserschoiceDropDownLabel = uilabel(app.SystemDescription);
            app.UserschoiceDropDownLabel.HorizontalAlignment = 'center';
            app.UserschoiceDropDownLabel.FontSize = 16;
            app.UserschoiceDropDownLabel.Layout.Row = 3;
            app.UserschoiceDropDownLabel.Layout.Column = 1;
            app.UserschoiceDropDownLabel.Text = 'Users choice';

            % Create UserschoiceDropDown
            app.UserschoiceDropDown = uidropdown(app.SystemDescription);
            app.UserschoiceDropDown.Items = {' ', '10/((s+1)*(s+2))', '(s+1)/s*(s+2)/(s+4)', '(s+10)/(s+2)', '(s+2)/s', '12'};
            app.UserschoiceDropDown.Editable = 'on';
            app.UserschoiceDropDown.ValueChangedFcn = createCallbackFcn(app, @UserschoiceDropDownValueChanged, true);
            app.UserschoiceDropDown.FontSize = 18;
            app.UserschoiceDropDown.Layout.Row = 3;
            app.UserschoiceDropDown.Layout.Column = 2;
            app.UserschoiceDropDown.Value = ' ';

            % Create ControllertypeDropDownLabel
            app.ControllertypeDropDownLabel = uilabel(app.SystemDescription);
            app.ControllertypeDropDownLabel.HorizontalAlignment = 'center';
            app.ControllertypeDropDownLabel.FontSize = 16;
            app.ControllertypeDropDownLabel.Layout.Row = 4;
            app.ControllertypeDropDownLabel.Layout.Column = 1;
            app.ControllertypeDropDownLabel.Text = 'Controller type';

            % Create ControllertypeDropDown
            app.ControllertypeDropDown = uidropdown(app.SystemDescription);
            app.ControllertypeDropDown.Items = {'User''s choice', 'P(s)', 'PI(s)', 'PD(s)', 'PID(s)', 'P(z)', 'PI(z)', 'PD(z)', 'PID(z)'};
            app.ControllertypeDropDown.ValueChangedFcn = createCallbackFcn(app, @ControllertypeDropDownValueChanged, true);
            app.ControllertypeDropDown.FontSize = 18;
            app.ControllertypeDropDown.Layout.Row = 4;
            app.ControllertypeDropDown.Layout.Column = 2;
            app.ControllertypeDropDown.Value = 'User''s choice';

            % Create SampletimesEditFieldLabel
            app.SampletimesEditFieldLabel = uilabel(app.SystemDescription);
            app.SampletimesEditFieldLabel.HorizontalAlignment = 'center';
            app.SampletimesEditFieldLabel.FontSize = 16;
            app.SampletimesEditFieldLabel.Layout.Row = 5;
            app.SampletimesEditFieldLabel.Layout.Column = 1;
            app.SampletimesEditFieldLabel.Text = 'Sample time [s]';

            % Create SampletimesEditField
            app.SampletimesEditField = uieditfield(app.SystemDescription, 'numeric');
            app.SampletimesEditField.Limits = [0 Inf];
            app.SampletimesEditField.ValueChangedFcn = createCallbackFcn(app, @SampletimesEditFieldValueChanged, true);
            app.SampletimesEditField.FontSize = 18;
            app.SampletimesEditField.Layout.Row = 5;
            app.SampletimesEditField.Layout.Column = 2;
            app.SampletimesEditField.Value = 0.5;

            % Create BigButtons
            app.BigButtons = uigridlayout(app.GridLayout);
            app.BigButtons.ColumnWidth = {'1x', '0.9x', '1.1x'};
            app.BigButtons.RowHeight = {'1x'};
            app.BigButtons.Layout.Row = [1 2];
            app.BigButtons.Layout.Column = 1;
            app.BigButtons.BackgroundColor = [1 0.6 0.8];

            % Create UpdateSummaryButton
            app.UpdateSummaryButton = uibutton(app.BigButtons, 'push');
            app.UpdateSummaryButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateSummaryButtonPushed, true);
            app.UpdateSummaryButton.WordWrap = 'on';
            app.UpdateSummaryButton.BackgroundColor = [1 0.2 0.702];
            app.UpdateSummaryButton.FontSize = 20;
            app.UpdateSummaryButton.FontWeight = 'bold';
            app.UpdateSummaryButton.Layout.Row = 1;
            app.UpdateSummaryButton.Layout.Column = 3;
            app.UpdateSummaryButton.Text = 'Update Summary';

            % Create SystembehavioursButton
            app.SystembehavioursButton = uibutton(app.BigButtons, 'push');
            app.SystembehavioursButton.ButtonPushedFcn = createCallbackFcn(app, @SystembehavioursButtonPushed, true);
            app.SystembehavioursButton.WordWrap = 'on';
            app.SystembehavioursButton.BackgroundColor = [1 0.2 0.702];
            app.SystembehavioursButton.FontSize = 20;
            app.SystembehavioursButton.FontWeight = 'bold';
            app.SystembehavioursButton.Layout.Row = 1;
            app.SystembehavioursButton.Layout.Column = 2;
            app.SystembehavioursButton.Text = 'System behaviours';

            % Create UpdateSystemdetailsButton
            app.UpdateSystemdetailsButton = uibutton(app.BigButtons, 'push');
            app.UpdateSystemdetailsButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateSystemdetailsButtonPushed, true);
            app.UpdateSystemdetailsButton.WordWrap = 'on';
            app.UpdateSystemdetailsButton.BackgroundColor = [1 0.2 0.702];
            app.UpdateSystemdetailsButton.FontSize = 20;
            app.UpdateSystemdetailsButton.FontWeight = 'bold';
            app.UpdateSystemdetailsButton.Layout.Row = 1;
            app.UpdateSystemdetailsButton.Layout.Column = [1 3];
            app.UpdateSystemdetailsButton.Text = 'Update System details';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.Layout.Row = [2 5];
            app.TabGroup.Layout.Column = [2 3];

            % Create SystemdetailsTab
            app.SystemdetailsTab = uitab(app.TabGroup);
            app.SystemdetailsTab.Title = 'System details';

            % Create GridLayout8
            app.GridLayout8 = uigridlayout(app.SystemdetailsTab);
            app.GridLayout8.ColumnWidth = {'1x'};
            app.GridLayout8.RowHeight = {'1x'};

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout8);
            title(app.UIAxes, 'Characterisation of step response')
            xlabel(app.UIAxes, 't [sec]')
            ylabel(app.UIAxes, 'y(t)')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.FontSize = 18;
            app.UIAxes.Layout.Row = 1;
            app.UIAxes.Layout.Column = 1;

            % Create SystembehavioursTab
            app.SystembehavioursTab = uitab(app.TabGroup);
            app.SystembehavioursTab.Title = 'System behaviours';

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.SystembehavioursTab);
            app.GridLayout7.RowHeight = {'1x', '1x', '1x'};

            % Create UIAxes_6
            app.UIAxes_6 = uiaxes(app.GridLayout7);
            title(app.UIAxes_6, 'Root locus diagram of open loop')
            xlabel(app.UIAxes_6, 'Real [Hz]')
            ylabel(app.UIAxes_6, 'Imag [Hz]')
            zlabel(app.UIAxes_6, 'Z')
            app.UIAxes_6.Toolbar.Visible = 'off';
            app.UIAxes_6.Layout.Row = [2 3];
            app.UIAxes_6.Layout.Column = 2;
            app.UIAxes_6.ButtonDownFcn = createCallbackFcn(app, @ChangeNyquist2RootLocus, true);
            app.UIAxes_6.Visible = 'off';

            % Create UIAxes_5
            app.UIAxes_5 = uiaxes(app.GridLayout7);
            title(app.UIAxes_5, 'Nyquist diagram of open loop')
            xlabel(app.UIAxes_5, 'Real')
            ylabel(app.UIAxes_5, 'Imag')
            zlabel(app.UIAxes_5, 'Z')
            app.UIAxes_5.Layout.Row = [2 3];
            app.UIAxes_5.Layout.Column = 2;
            app.UIAxes_5.ButtonDownFcn = createCallbackFcn(app, @ChangeRootLocus2Nyquist, true);

            % Create UIAxes_4
            app.UIAxes_4 = uiaxes(app.GridLayout7);
            xlabel(app.UIAxes_4, 'ω [Hz]')
            ylabel(app.UIAxes_4, 'Phase [°]')
            zlabel(app.UIAxes_4, 'Z')
            app.UIAxes_4.Layout.Row = 3;
            app.UIAxes_4.Layout.Column = 1;

            % Create UIAxes_3
            app.UIAxes_3 = uiaxes(app.GridLayout7);
            title(app.UIAxes_3, 'Bode diagram of open loop')
            xlabel(app.UIAxes_3, 'ω [Hz]')
            ylabel(app.UIAxes_3, 'Gain [dB]')
            zlabel(app.UIAxes_3, 'Z')
            subtitle(app.UIAxes_3, 'Gain')
            app.UIAxes_3.Layout.Row = 2;
            app.UIAxes_3.Layout.Column = 1;

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.GridLayout7);
            title(app.UIAxes_2, 'Output response of the controller')
            xlabel(app.UIAxes_2, 't [s]')
            ylabel(app.UIAxes_2, 'u(t)')
            zlabel(app.UIAxes_2, 'Z')
            app.UIAxes_2.Layout.Row = 1;
            app.UIAxes_2.Layout.Column = 2;

            % Create UIAxes_1
            app.UIAxes_1 = uiaxes(app.GridLayout7);
            title(app.UIAxes_1, 'Output responses of plant and closed loop')
            xlabel(app.UIAxes_1, 't [s]')
            ylabel(app.UIAxes_1, 'y(t)')
            zlabel(app.UIAxes_1, 'Z')
            app.UIAxes_1.Layout.Row = 1;
            app.UIAxes_1.Layout.Column = 1;

            % Create UpdateSummaryTab
            app.UpdateSummaryTab = uitab(app.TabGroup);
            app.UpdateSummaryTab.Title = 'Update Summary';

            % Create ValidResults
            app.ValidResults = uigridlayout(app.UpdateSummaryTab);
            app.ValidResults.ColumnWidth = {'1x'};
            app.ValidResults.RowHeight = {'1x'};

            % Create UIAxes_7
            app.UIAxes_7 = uiaxes(app.ValidResults);
            title(app.UIAxes_7, 'Results of pole replacement methods')
            xlabel(app.UIAxes_7, 'time (sec)')
            ylabel(app.UIAxes_7, 'y(time)')
            zlabel(app.UIAxes_7, 'Z')
            subtitle(app.UIAxes_7, 'with settling times')
            app.UIAxes_7.FontSize = 18;
            app.UIAxes_7.Layout.Row = 1;
            app.UIAxes_7.Layout.Column = 1;

            % Create Title_and_Image
            app.Title_and_Image = uigridlayout(app.GridLayout);
            app.Title_and_Image.ColumnWidth = {'1.8x', '1x'};
            app.Title_and_Image.RowHeight = {'1x'};
            app.Title_and_Image.Layout.Row = 1;
            app.Title_and_Image.Layout.Column = [2 3];
            app.Title_and_Image.BackgroundColor = [0.6 1 1];

            % Create PolereplacementmethodLabel
            app.PolereplacementmethodLabel = uilabel(app.Title_and_Image);
            app.PolereplacementmethodLabel.BackgroundColor = [0 1 1];
            app.PolereplacementmethodLabel.HorizontalAlignment = 'center';
            app.PolereplacementmethodLabel.FontSize = 24;
            app.PolereplacementmethodLabel.FontWeight = 'bold';
            app.PolereplacementmethodLabel.Layout.Row = 1;
            app.PolereplacementmethodLabel.Layout.Column = 1;
            app.PolereplacementmethodLabel.Text = 'Pole replacement method';

            % Create Image
            app.Image = uiimage(app.Title_and_Image);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 2;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'bme_cimer.png');

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = PoleReplacement_control1011

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

