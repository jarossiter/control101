classdef lag_design_phase_margin < matlab.apps.AppBase
    %LAG_DESIGN_PHASE_MARGIN
    %   File written by J.A.Rossiter, University of Sheffield  
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   
    %   A simple interface to illustrate the concept of simple Lag
    %   compensation design using frequency response analysis.
    %   
    %   Users can select from a number of predefined systems: 1st , 2nd and
    %   3rd order. These have a variety of time constants and also some
    %   have under-damped modes to illustrate resonance. Secondly they can
    %   change the proportional gain and pole/zero ratio and see how the
    %   phase margin and closed-loop behaviour changes.
    %   
    %   Some notes and engineering background are in the partner
    %   livescript file:    lag_design_phase_margin_manual.mlx
    %   A group of similar files can be downloaded through MATLAB
    %   add-ons with the toolbox name:  control101

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        GridLayout                   matlab.ui.container.GridLayout
        GridLayout9                  matlab.ui.container.GridLayout
        polezeroratioSlider          matlab.ui.control.Slider
        polezeroratioSliderLabel     matlab.ui.control.Label
        KpSlider                     matlab.ui.control.Slider
        KpSliderLabel                matlab.ui.control.Label
        ControlparametersLabel       matlab.ui.control.Label
        GridLayout6                  matlab.ui.container.GridLayout
        OffsetSlider                 matlab.ui.control.Slider
        OffsetLabel_2                matlab.ui.control.Label
        PMSlider                     matlab.ui.control.Slider
        PMSliderLabel                matlab.ui.control.Label
        SpecificationsLabel          matlab.ui.control.Label
        DetailedanalysisoffirstordermodelparametersPanel  matlab.ui.container.Panel
        GridLayout5                  matlab.ui.container.GridLayout
        GridLayout7                  matlab.ui.container.GridLayout
        MsLabel                      matlab.ui.control.Label
        ControlLawLabel              matlab.ui.control.Label
        RamperrorLabel               matlab.ui.control.Label
        OffsetLabel                  matlab.ui.control.Label
        wcLabel                      matlab.ui.control.Label
        PhiLabel                     matlab.ui.control.Label
        GsLabel                      matlab.ui.control.Label
        CurrentmodelLabel            matlab.ui.control.Label
        ClosedloopoffsetrampsLabel   matlab.ui.control.Label
        ClosedloopoffsetstepsLabel   matlab.ui.control.Label
        GaincrossoverfrequencyLabel  matlab.ui.control.Label
        CurrentphasemarginLabel      matlab.ui.control.Label
        UIAxes2_2                    matlab.ui.control.UIAxes
        UIAxes2                      matlab.ui.control.UIAxes
        GridLayout4                  matlab.ui.container.GridLayout
        HighorderDropDown            matlab.ui.control.DropDown
        HighorderDropDownLabel       matlab.ui.control.Label
        SecondorderDropDown          matlab.ui.control.DropDown
        SecondorderDropDownLabel     matlab.ui.control.Label
        FirstorderDropDown           matlab.ui.control.DropDown
        FirstorderDropDownLabel      matlab.ui.control.Label
        ChoosemodelLabel             matlab.ui.control.Label
        GridLayout3                  matlab.ui.container.GridLayout
        GridLayout10                 matlab.ui.container.GridLayout
        OverlayseveralLagButton      matlab.ui.control.Button
        OverlayseveralKpButton       matlab.ui.control.Button
        GridLayout2                  matlab.ui.container.GridLayout
        Image                        matlab.ui.control.Image
        LagdesignwithaphasemarginandoffsetLabel  matlab.ui.control.Label
        UIAxes                       matlab.ui.control.UIAxes
        UIAxes_2                     matlab.ui.control.UIAxes
    end

    
    
    
    % The next section defines all the core variables used in the code and
    % that it may be convenient to have available in the various
    % subfunctions
    properties (Access = private)
        originalsize     % product of width and height for font sizing

        G = tf(2,[1 1]);  % model no delay
        numExample =2   % system numerator
        denExample =[1 1]  % system denominator
        wlist = logspace(-2,1,200) ;  % frequency list
        Gd  % Model with delay
        u   % sinsoidal signal
        y   % response no delay
        yd  % response with delay
        omega % frequency
        tvec  % time vector for plotting
        endtime=5;  % default simulation tome
      
        PM =60 ;  % Target phase margin
        int =0;  % tag for whether an integrator included
        offset = 'step' % tag for ramp or step offset criteria
        Lag = 1;  % to store lag compensator
        wg        % cross over frequency based on G*Kp

          
    end
    
    methods (Access = private)
        


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  Down load data from sliders and create responses AND BODE
 %%%%%%%%% and simple data such as offsets and PM
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function app = getbode_diagram(app)
       
       % collect data from sliders
       Kp = app.KpSlider.Value;
       alpha = app.polezeroratioSlider.Value;
       
       % get margins with just proportional
       warning('off','Control:analysis:MarginUnstable');
       [GM,PM,wp,wg] = margin(app.G*Kp);  % core frequency is wg
       wg = round(wg,2,'significant');
       
       % check that cross over frequency is meaningful
       if isnan(wg);
           app.wg=1;
           alpha=1;
           LAG=1;
           PM=0;
           PMd=0;
       else
           app.wg = wg;  % Save cross over frequency
           % Lag design
           LAG = Kp*tf([1,wg/10],[1,wg/(10*alpha)]);
           [GMd,PMd,wpd,wgd] = margin(app.G*LAG);
           
           
       end
       app.Lag = LAG;
       

       % Set up plots
       app.PM = app.PMSlider.Value;
       offset = app.OffsetSlider.Value;
       [gain,phase]=bode(app.G,app.wlist);
       [gaind,phased]=bode(app.G*LAG,app.wlist);
      
       % plot gain
       hold(app.UIAxes,'off')
       semilogx(app.UIAxes,app.wlist,20*log10(gain(:)),':','color',[0.7 .3 1],'linewidth',2)
       hold(app.UIAxes,'on')
       grid(app.UIAxes,'on')
       semilogx(app.UIAxes,app.wlist,20*log10(gain(:)*Kp),'b','linewidth',2)
       semilogx(app.UIAxes,app.wlist,20*log10(gaind(:)),'r','linewidth',2)

       semilogx(app.UIAxes,[app.wlist(1),app.wlist(end)],[1 1]*(0),'k-','linewidth',3)
       ylim(app.UIAxes,[-20,max(20*log10(gain(:)*2))]);
       legend(app.UIAxes,'G','G*Kp','G*Lag','0dB')
       text(app.UIAxes,app.wlist(10),-10,['K_p = ',num2str(Kp), ',   \alpha = ',num2str(alpha)],'fontsize',24)



       % plot phase
       hold(app.UIAxes_2,'off')
       semilogx(app.UIAxes_2,app.wlist,phase(:),'b')
       hold(app.UIAxes_2,'on')
       semilogx(app.UIAxes_2,app.wlist,phased(:),'r')
       semilogx(app.UIAxes_2,[app.wlist(1),app.wlist(end)],[1 1]*(app.PM-180),'g--','linewidth',2)
       semilogx(app.UIAxes_2,[app.wlist(1),app.wlist(end)],[1 1]*(-180),'k-','linewidth',3)
       grid(app.UIAxes_2,'on')
       ylim(app.UIAxes_2,[-220,max(phase)]);
       plot(app.UIAxes_2,[wg,wg],[-180,-180+PM],'m:','linewidth',3);
       legend(app.UIAxes_2,'G*K_p','G*Lag','Target PM','-180^o','PM')
       % add pole and zero positions
       plot(app.UIAxes_2,wg/10,[-180],'ro','linewidth',3,'markersize',16);
       plot(app.UIAxes_2,wg/(10*alpha),[-180],'rx','linewidth',3,'markersize',16);
       legend(app.UIAxes_2,'G*K_p','G*Lag','Target PM','-180^o','PM','Lag zero','Lag pole')


       
      % Update display of values
      app.PhiLabel.Text = ['\phi = ',num2str(round(PM)),' and ',num2str(round(PMd))];
      app.OffsetLabel.Text = [num2str(1/(1+dcgain(app.G)*Kp)),',   ', ...
          num2str(1/(1+dcgain(app.G)*Kp*alpha))];
      app.wcLabel.Text = num2str(wg);
        
        if any(roots(app.denExample)==0);
            val = dcgain(tf([1 0],1)*app.G*Kp);
            app.RamperrorLabel.Text = [num2str(1/(val)),',   ',num2str(1/(alpha*val))];
        else
            app.RamperrorLabel.Text = 'NA';
        end

            
    end   % end of getresponses subfunction


    % PLOT THE SYSTEM RESPONSES for proportional and lag compensation   
     function app = plotresponses(app)

            Kp = app.KpSlider.Value;
            
            % Feedback
            G1 = feedback(app.G*Kp,1);
            G1u = feedback(Kp,app.G);
            G1d = feedback(app.G*app.Lag,1);
            G1ud = feedback(app.Lag,app.G);
            % Closed-loop responses
            [y,t] = step(G1,app.endtime);
            [u] = step(G1u,t);
            [yd] = step(G1d,t);
            [ud] = step(G1ud,t);

            % Output plot
            hold(app.UIAxes2_2,'off')
            plot(app.UIAxes2_2,t,y,'b',t,yd,'r-');
            hold(app.UIAxes2_2,'on')
            plot(app.UIAxes2_2,[t(1),t(end)],[1,1]*(1-app.OffsetSlider.Value/100),'g--','linewidth',2);
            legend(app.UIAxes2_2, 'G*K_p', 'G*Lag','Target','Location','southeast');
            grid(app.UIAxes2_2,'on')
            y1 = min(y); y2 = max(y); d = y2-y1;
            ylim(app.UIAxes2_2,[y1-d/10 max([1.05,y2+d/10])]); % Always include unity
            % Input plot
            hold(app.UIAxes2,'off')
            plot(app.UIAxes2,t,u,'b',t,ud,'r-');
            legend(app.UIAxes2, 'G*K_p', 'G*Lag');
            grid(app.UIAxes2,'on')
            
 
        end

        % Display transfer function and control law in text boxes
        function updateTransferFunctionRender(app)
            n=app.numExample; 
            d=app.denExample;
            numerator_str = array2StringPolynomial(app,n);
            denumerator_str = array2StringPolynomial(app,d);
            alpha = app.polezeroratioSlider.Value;
            %delaystr = num2str(app.DelaySlider.Value);
            app.GsLabel.Text = "$\frac{"+numerator_str+"}"+"{"+denumerator_str+"}$";


            if isnumeric(app.Lag);
                numerator_str=num2str(app.KpSlider.Value);
                denumerator_str ='1';
            else
                [n,d]=tfdata(app.Lag,'v');
                n=[1,app.wg/10];
                d=[1,round(app.wg/(10*alpha),2,'significant')];
            
                numerator_str = strcat(num2str(app.KpSlider.Value),"(",array2StringPolynomial(app,n),")");
                denumerator_str = array2StringPolynomial(app,d);
            end
            app.MsLabel.Text = "$\frac{"+numerator_str+"}"+"{"+denumerator_str+"}$";
            

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



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Illustrates a range of Kp choices on a single figure
        function results = rangeofkp(app)

            Kp=[0.1,0.2,0.4,0.7,1,1.4,2];
            app.PM = app.PMSlider.Value;
            [gain,phase]=bode(app.G,app.wlist);
            hold(app.UIAxes,'off')
            hold(app.UIAxes_2,'off')
            hold(app.UIAxes2,'off')
            hold(app.UIAxes2_2,'off')
            cla(app.UIAxes)
            cla(app.UIAxes_2)
            cla(app.UIAxes2_2)
            cla(app.UIAxes2)
           hold(app.UIAxes,'on')
           hold(app.UIAxes_2,'on')
           hold(app.UIAxes2,'on')
           hold(app.UIAxes2_2,'on')


           for k=1:length(Kp);
                  
               % Frequency domain plots
               semilogx(app.UIAxes,app.wlist,20*log10(gain(:)*Kp(k)));
               legstring{k}=['K_p = ',num2str(Kp(k))];

               [GM,PM,wp,wg] = margin(app.G*Kp(k)); 
               if PM == Inf; PM=1;end   % to manage plotting colours    
               plot(app.UIAxes_2,[wg,wg],[-180,-180+PM],'linewidth',3);

                % Closed-loop responses
                G1 = feedback(app.G*Kp(k),1);
                G1u = feedback(Kp(k),app.G);
                [y,t] = step(G1,app.endtime);
                [u] = step(G1u,t);
                plot(app.UIAxes2_2,t,y);
                plot(app.UIAxes2,t,u);
            
               
           end

           % Augment plots with useful lines
            semilogx(app.UIAxes,[app.wlist(1),app.wlist(end)],[1 1]*(0),'k-','linewidth',3)
            ylim(app.UIAxes,[-20,max(20*log10(gain(:)*2))]);
            legend(app.UIAxes,legstring)
            legend(app.UIAxes2,legstring)
            
            semilogx(app.UIAxes_2,[app.wlist(1),app.wlist(end)],[1 1]*(-180),'k-','linewidth',3)
            semilogx(app.UIAxes_2,app.wlist,phase(:),'k')
            semilogx(app.UIAxes_2,[app.wlist(1),app.wlist(end)],[1 1]*(app.PM-180),'g--','linewidth',2)
            ylim(app.UIAxes_2,[-220,max(phase)]);
            legend(app.UIAxes_2,'off')
            legend(app.UIAxes2_2,'off')

            
        end

        % update plots and data when something is changed
        function updateallplots(app)
            
            app = getbode_diagram(app);
            app = plotresponses(app); 
            updateTransferFunctionRender(app);
            
        end


        end  % end of sub functions section
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
            % resize to be in middle of  the window
            movegui(app.UIFigure)

            % Open the manual
            if exist('lag_design_phase_margin_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open lag_design_phase_margin_mycopy.mlx
            else           
                p1 = which('lag_design_phase_margin_manual.mlx');
                p2 = strcat(pwd,'/lag_design_phase_margin_mycopy.mlx');
                copyfile(p1,p2)           
                open lag_design_phase_margin_mycopy.mlx
            end

            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);

            
            updateTransferFunctionRender(app);
            app = getbode_diagram(app);
            app = plotresponses(app); 
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
            theme(app.UIFigure,"light")
            end


        end

        % Button pushed function: OverlayseveralKpButton
        function OverlayseveralKpButtonPushed(app, event)
           % Dsiplays  the impact of a range of Kp for the current choice
           % of system
           rangeofkp(app);          

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

        % Value changed function: FirstorderDropDown
        function FirstorderDropDownValueChanged(app, event)
            % Select desired first order system and update plots
            value = app.FirstorderDropDown.Value;
            switch value
                case '1/s'; 
                    app.G =tf(1,[1 0]);
                    app.numExample =1;
                    app.denExample = [1 0];
                    app.endtime =15;
                    app.wlist = logspace(-3,1,200);
                    app.endtime = 5;
                    app.int = 1;
                    app.offset = 'ramp';
                case '2/(s+1)'; 
                    app.G = tf(2,[1 1]);
                    app.numExample =2;
                    app.denExample = [1 1];
                    app.endtime =15;
                    app.wlist = logspace(-3,1,200); 
                    app.endtime = 3;
                    app.int = 0;
                    app.offset = 'step';
                
                case '0.5/(s+0.1)'; 
                    app.G = tf([0.5],[1 0.1]);
                    app.numExample = [0.5];
                    app.denExample = [1 0.1];
                    app.endtime =55;
                    app.wlist = logspace(-3,1,200); 
                    app.endtime = 10;
                    app.int = 0;
                    app.offset = 'step';
                    
            end
            updateallplots(app)

        end

        % Value changed function: SecondorderDropDown
        function SecondorderDropDownValueChanged(app, event)
            % Select desired second order system and update plots
            value = app.SecondorderDropDown.Value;
            switch value
                case '2/[s(s+1)]'; 
                    app.G =tf(2,[1 1 0]);
                    app.numExample =2 ;
                    app.denExample = [1 1 0];
                    app.endtime =15;
                    app.wlist = logspace(-3,1,200); 
                    app.int = 1;
                    app.offset = 'ramp';
                case '8/[(s+1)(s+2)]'; 
                    app.G = tf(8,[1 3 2]);
                    app.numExample =8;
                    app.denExample = [1 3 2];
                    app.endtime =15;
                    app.wlist = logspace(-2,2,200); 
                    app.int = 0;
                    app.offset = 'step';
                case '6(s+1)/[s(s+3)]'; 
                    app.G = tf(6*[1 1],[1 3 0]);
                    app.numExample =6*[1 1];
                    app.denExample = [1 3 0];
                    app.endtime =10;
                    app.wlist = logspace(-2,2,200); 
                    app.int = 1;
                    app.offset = 'ramp';
                case '10(s+1)/[(s+3)(s+5)]'; 
                    app.G = tf(10*[1 1],[1 8 15]);
                    app.numExample = 10*[1 1];
                    app.denExample = [1 8 15];
                    app.endtime =5;
                    app.wlist = logspace(-2,2,200); 
                    app.int = 0;
                    app.offset = 'step';
                case '0.4/[(s+0.2)(s+0.1)]'; 
                    app.G = tf([0.4],[1 0.3 0.02]);
                    app.numExample = 0.4;
                    app.denExample = [1 0.3 0.02];
                    app.endtime =55;
                    app.wlist = logspace(-3,1,200); 
                    app.int = 0;
                    app.offset = 'step';
                case '1/[(s^2+0.2s+1)]'; 
                    app.G = tf([1],[1 0.2 1]);
                    app.numExample = 1;
                    app.denExample = [1 0.2 1];
                    app.endtime =65;
                    app.wlist = logspace(-3,1,200); 
                    app.int = 0;
                    app.offset = 'step';
                case '20/[(s^2+s+10)]'; 
                    app.G = tf([20],[1 1 10]);
                    app.numExample = 20;
                    app.denExample = [1 1 10];
                    app.endtime =20;
                    app.wlist = logspace(-2,2,200); 
                    app.int = 0;
                    app.offset = 'step';
                case '0.1/[(s^2+0.2s+0.03)]'; 
                    app.G = tf([0.1],[1 0.2 0.03]);
                    app.numExample = .1;
                    app.denExample = [1 .2 0.03];
                    app.endtime =55;
                    app.wlist = logspace(-3,1,200); 
                    app.int = 0;
                    app.offset = 'step';
                    
            end
            updateallplots(app)

        end

        % Value changed function: HighorderDropDown
        function HighorderDropDownValueChanged(app, event)
            % Select desired high order system and update plots
            value = app.HighorderDropDown.Value;
            
            switch value
                case '2/[s(s+1)(s+2)]'; 
                    app.G =tf(2,[1 3 2 0]);
                    app.numExample =2;
                    app.denExample = [1 3 2 0];
                    app.endtime =15;
                    app.wlist = logspace(-3,1,200);
                    app.int = 1;
                    app.offset = 'ramp';
                case '20/[(s+1)(s+2)(s+4)]'; 
                    app.G = tf(20,[1 7 14 8]);
                    app.numExample =20;
                    app.denExample = [1 7 14 8];
                    app.endtime =15;
                    app.wlist = logspace(-2,2,200);
                    app.int = 0;
                    app.offset = 'step';
                case '5(s+2)/[s(s+1)(s+4)]'; 
                    app.G = tf(5*[1 2],[1 5 4 0]);
                    app.numExample =5*[1 2];
                    app.denExample = [1 5 4 0];
                    app.endtime =8;
                    app.wlist = logspace(-3,1,200);
                    app.int = 1;
                    app.offset = 'ramp';
                case '5(s+4)/[(s+1)(s+1)(s+2)]'; 
                    app.G = tf(5*[1 4],[1 4 5 2]);
                    app.numExample = 5*[1 4];
                    app.denExample = [1 4 5 2];
                    app.endtime =10;
                    app.wlist = logspace(-3,1,200);
                    app.int = 0;
                    app.offset = 'step';

               case '5(s+2)/[(s+1)(s^2+0.4s+16)]'; 
                    app.G = tf(5*[1 2],[1 1.4 16.4 16]);
                    app.numExample = 5*[1 2];
                    app.denExample = [1 1.4 16.4 16];
                    app.endtime =30;
                    app.wlist = logspace(-2,2,200);
                    app.int = 0;
                    app.offset = 'step';

            end
            
            updateallplots(app)


        end

        % Clicked callback: SecondorderDropDown
        function SecondorderDropDownClicked(app, event)
            item = event.InteractionInformation.Item;
            SecondorderDropDownValueChanged(app);
            updateallplots(app)
            
        end

        % Clicked callback: FirstorderDropDown
        function FirstorderDropDownClicked(app, event)
            item = event.InteractionInformation.Item;
            FirstorderDropDownValueChanged(app);
            updateallplots(app)
        end

        % Clicked callback: HighorderDropDown
        function HighorderDropDownClicked(app, event)
            item = event.InteractionInformation.Item;
            HighorderDropDownValueChanged(app);
            updateallplots(app)
        end

        % Value changed function: KpSlider
        function KpSliderValueChanged(app, event)
            value = app.KpSlider.Value;
            value = round(value,2);
            app.KpSlider.Value = value;
            updateallplots(app)

        end

        % Value changed function: polezeroratioSlider
        function polezeroratioSliderValueChanged(app, event)
            value = app.polezeroratioSlider.Value;
            value = round(value,0);
            app.polezeroratioSlider.Value = value;
            updateallplots(app) 
            
        end

        % Value changed function: OffsetSlider
        function OffsetSliderValueChanged(app, event)
            value = app.OffsetSlider.Value;
            value = round(value,0);
            app.OffsetSlider.Value = value;
            updateallplots(app)
            
        end

        % Value changed function: PMSlider
        function PMSliderValueChanged(app, event)
            value = app.PMSlider.Value;
            value = round(value*2,-1)/2;
            app.PMSlider.Value=value;
            app.PM=value;
            updateallplots(app)
           
            
        end

        % Button pushed function: OverlayseveralLagButton
        function OverlayseveralLagButtonPushed(app, event)
            % Change the pole zero ratio for a fixed Kp
            % and overlay the Bode and step response plots for all these
            % choices of lag compensation

            % Define all lag compensators
            alpha=[1,2,3,4,5,7,10];  % pole/zero ratio choices
            Lag = cell(1);gain=cell(1); phase = cell(1);
            for k=1:length(alpha);
                Lag{k} = app.KpSlider.Value*tf([1,app.wg/10],[1,app.wg/(10*alpha(k))]);
                [gain{k},phase{k}]=bode(app.G*Lag{k},app.wlist);
            end
            app.PM = app.PMSlider.Value;
            
            hold(app.UIAxes,'off')
            hold(app.UIAxes_2,'off')
            hold(app.UIAxes2,'off')
            hold(app.UIAxes2_2,'off')
            cla(app.UIAxes)
            cla(app.UIAxes_2)
            cla(app.UIAxes2_2)
            cla(app.UIAxes2)
           hold(app.UIAxes,'on')
           hold(app.UIAxes_2,'on')
           hold(app.UIAxes2,'on')
           hold(app.UIAxes2_2,'on')

            % use a loop to create Bode and step responses for all the choices
           for k=1:length(alpha);
                  
               % Frequency domain plots
               semilogx(app.UIAxes,app.wlist,20*log10(gain{k}(:)));
               legstring{k}=['\alpha = ',num2str(alpha(k))];
               semilogx(app.UIAxes_2,app.wlist,phase{k}(:));

               [GM,PM,wp,wg] = margin(app.G*Lag{k}); 
               if PM == Inf; PM=1;end   % to manage plotting colours    
               plot(app.UIAxes_2,[wg,wg],[-180,-180+PM],'linewidth',3);

                % Closed-loop responses
                G1 = feedback(app.G*Lag{k},1);
                G1u = feedback(Lag{k},app.G);
                [y,t] = step(G1,app.endtime);
                [u] = step(G1u,t);
                plot(app.UIAxes2_2,t,y);
                plot(app.UIAxes2,t,u);
            
               
           end

           % Augment plots with useful lines
            semilogx(app.UIAxes,[app.wlist(1),app.wlist(end)],[1 1]*(0),'k-','linewidth',3)
            ylim(app.UIAxes,[-20,max(20*log10(gain{4}(:)*2))]);
            legend(app.UIAxes,legstring)
            legend(app.UIAxes2,legstring)
            
            semilogx(app.UIAxes_2,[app.wlist(1),app.wlist(end)],[1 1]*(-180),'k-','linewidth',3)
            semilogx(app.UIAxes_2,app.wlist,phase{1}(:),'k')
            semilogx(app.UIAxes_2,[app.wlist(1),app.wlist(end)],[1 1]*(app.PM-180),'g--','linewidth',2)
            ylim(app.UIAxes_2,[-220,max(phase{1})]);
            legend(app.UIAxes_2,'off')
            legend(app.UIAxes2_2,'off')

            
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
            app.UIFigure.Position = [100 100 1139 844];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '2x', '1x'};
            app.GridLayout.RowHeight = {'0.6x', '1x', '0.8x', '0.8x', '2x'};

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.GridLayout);
            title(app.UIAxes_2, 'Phase diagram and phase margin (PM)')
            xlabel(app.UIAxes_2, 'Frequency (rad/s)')
            ylabel(app.UIAxes_2, 'Degrees')
            zlabel(app.UIAxes_2, 'Z')
            app.UIAxes_2.FontSize = 14;
            app.UIAxes_2.Layout.Row = [3 4];
            app.UIAxes_2.Layout.Column = [2 3];

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Bode gain diagrams')
            xlabel(app.UIAxes, 'Frequency (rad/s)')
            ylabel(app.UIAxes, 'dB')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.FontSize = 14;
            app.UIAxes.Layout.Row = 2;
            app.UIAxes.Layout.Column = [2 3];

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = [2 3];
            app.GridLayout2.BackgroundColor = [0.6 1 1];

            % Create LagdesignwithaphasemarginandoffsetLabel
            app.LagdesignwithaphasemarginandoffsetLabel = uilabel(app.GridLayout2);
            app.LagdesignwithaphasemarginandoffsetLabel.BackgroundColor = [0 1 1];
            app.LagdesignwithaphasemarginandoffsetLabel.HorizontalAlignment = 'center';
            app.LagdesignwithaphasemarginandoffsetLabel.FontSize = 18;
            app.LagdesignwithaphasemarginandoffsetLabel.FontWeight = 'bold';
            app.LagdesignwithaphasemarginandoffsetLabel.Layout.Row = 1;
            app.LagdesignwithaphasemarginandoffsetLabel.Layout.Column = [1 2];
            app.LagdesignwithaphasemarginandoffsetLabel.Text = 'Lag design with a phase margin and offset';

            % Create Image
            app.Image = uiimage(app.GridLayout2);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 3;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'UoSlogo.png');

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout);
            app.GridLayout3.ColumnWidth = {'0.95x'};
            app.GridLayout3.RowHeight = {'1x'};
            app.GridLayout3.Layout.Row = 1;
            app.GridLayout3.Layout.Column = 1;
            app.GridLayout3.BackgroundColor = [1 0.6 0.8];

            % Create GridLayout10
            app.GridLayout10 = uigridlayout(app.GridLayout3);
            app.GridLayout10.RowHeight = {'1x'};
            app.GridLayout10.Layout.Row = 1;
            app.GridLayout10.Layout.Column = 1;
            app.GridLayout10.BackgroundColor = [1 0.6 0.8];

            % Create OverlayseveralKpButton
            app.OverlayseveralKpButton = uibutton(app.GridLayout10, 'push');
            app.OverlayseveralKpButton.ButtonPushedFcn = createCallbackFcn(app, @OverlayseveralKpButtonPushed, true);
            app.OverlayseveralKpButton.WordWrap = 'on';
            app.OverlayseveralKpButton.BackgroundColor = [1 0.2 0.702];
            app.OverlayseveralKpButton.FontSize = 18;
            app.OverlayseveralKpButton.FontWeight = 'bold';
            app.OverlayseveralKpButton.Layout.Row = 1;
            app.OverlayseveralKpButton.Layout.Column = 1;
            app.OverlayseveralKpButton.Text = 'Overlay several Kp';

            % Create OverlayseveralLagButton
            app.OverlayseveralLagButton = uibutton(app.GridLayout10, 'push');
            app.OverlayseveralLagButton.ButtonPushedFcn = createCallbackFcn(app, @OverlayseveralLagButtonPushed, true);
            app.OverlayseveralLagButton.WordWrap = 'on';
            app.OverlayseveralLagButton.BackgroundColor = [1 0.2 0.702];
            app.OverlayseveralLagButton.FontSize = 18;
            app.OverlayseveralLagButton.FontWeight = 'bold';
            app.OverlayseveralLagButton.Layout.Row = 1;
            app.OverlayseveralLagButton.Layout.Column = 2;
            app.OverlayseveralLagButton.Text = 'Overlay several Lag';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'0.4x', '1x'};
            app.GridLayout4.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout4.Layout.Row = 2;
            app.GridLayout4.Layout.Column = 1;
            app.GridLayout4.BackgroundColor = [0.902 1 0.502];

            % Create ChoosemodelLabel
            app.ChoosemodelLabel = uilabel(app.GridLayout4);
            app.ChoosemodelLabel.BackgroundColor = [1 1 0];
            app.ChoosemodelLabel.HorizontalAlignment = 'center';
            app.ChoosemodelLabel.WordWrap = 'on';
            app.ChoosemodelLabel.FontSize = 14;
            app.ChoosemodelLabel.FontWeight = 'bold';
            app.ChoosemodelLabel.Layout.Row = 1;
            app.ChoosemodelLabel.Layout.Column = [1 2];
            app.ChoosemodelLabel.Text = 'Choose model';

            % Create FirstorderDropDownLabel
            app.FirstorderDropDownLabel = uilabel(app.GridLayout4);
            app.FirstorderDropDownLabel.HorizontalAlignment = 'right';
            app.FirstorderDropDownLabel.WordWrap = 'on';
            app.FirstorderDropDownLabel.FontWeight = 'bold';
            app.FirstorderDropDownLabel.Layout.Row = 2;
            app.FirstorderDropDownLabel.Layout.Column = 1;
            app.FirstorderDropDownLabel.Text = 'First order';

            % Create FirstorderDropDown
            app.FirstorderDropDown = uidropdown(app.GridLayout4);
            app.FirstorderDropDown.Items = {'2/(s+1)', '0.5/(s+0.1)', '1/s'};
            app.FirstorderDropDown.ValueChangedFcn = createCallbackFcn(app, @FirstorderDropDownValueChanged, true);
            app.FirstorderDropDown.Layout.Row = 2;
            app.FirstorderDropDown.Layout.Column = 2;
            app.FirstorderDropDown.ClickedFcn = createCallbackFcn(app, @FirstorderDropDownClicked, true);
            app.FirstorderDropDown.Value = '2/(s+1)';

            % Create SecondorderDropDownLabel
            app.SecondorderDropDownLabel = uilabel(app.GridLayout4);
            app.SecondorderDropDownLabel.HorizontalAlignment = 'right';
            app.SecondorderDropDownLabel.WordWrap = 'on';
            app.SecondorderDropDownLabel.FontWeight = 'bold';
            app.SecondorderDropDownLabel.Layout.Row = 3;
            app.SecondorderDropDownLabel.Layout.Column = 1;
            app.SecondorderDropDownLabel.Text = 'Second order';

            % Create SecondorderDropDown
            app.SecondorderDropDown = uidropdown(app.GridLayout4);
            app.SecondorderDropDown.Items = {'2/[s(s+1)]', '8/[(s+1)(s+2)]', '6(s+1)/[s(s+3)]', '10(s+1)/[(s+3)(s+5)]', '0.4/[(s+0.2)(s+0.1)]', '1/[(s^2+0.2s+1)]', '20/[(s^2+s+10)]', '0.1/[(s^2+0.2s+0.03)]'};
            app.SecondorderDropDown.ValueChangedFcn = createCallbackFcn(app, @SecondorderDropDownValueChanged, true);
            app.SecondorderDropDown.Layout.Row = 3;
            app.SecondorderDropDown.Layout.Column = 2;
            app.SecondorderDropDown.ClickedFcn = createCallbackFcn(app, @SecondorderDropDownClicked, true);
            app.SecondorderDropDown.Value = '2/[s(s+1)]';

            % Create HighorderDropDownLabel
            app.HighorderDropDownLabel = uilabel(app.GridLayout4);
            app.HighorderDropDownLabel.HorizontalAlignment = 'right';
            app.HighorderDropDownLabel.WordWrap = 'on';
            app.HighorderDropDownLabel.FontWeight = 'bold';
            app.HighorderDropDownLabel.Layout.Row = 4;
            app.HighorderDropDownLabel.Layout.Column = 1;
            app.HighorderDropDownLabel.Text = 'High order';

            % Create HighorderDropDown
            app.HighorderDropDown = uidropdown(app.GridLayout4);
            app.HighorderDropDown.Items = {'2/[s(s+1)(s+2)]', '20/[(s+1)(s+2)(s+4)]', '5(s+2)/[s(s+1)(s+4)]', '5(s+4)/[(s+1)(s+1)(s+2)]', '5(s+2)/[(s+1)(s^2+0.4s+16)]'};
            app.HighorderDropDown.ValueChangedFcn = createCallbackFcn(app, @HighorderDropDownValueChanged, true);
            app.HighorderDropDown.Layout.Row = 4;
            app.HighorderDropDown.Layout.Column = 2;
            app.HighorderDropDown.ClickedFcn = createCallbackFcn(app, @HighorderDropDownClicked, true);
            app.HighorderDropDown.Value = '2/[s(s+1)(s+2)]';

            % Create DetailedanalysisoffirstordermodelparametersPanel
            app.DetailedanalysisoffirstordermodelparametersPanel = uipanel(app.GridLayout);
            app.DetailedanalysisoffirstordermodelparametersPanel.AutoResizeChildren = 'off';
            app.DetailedanalysisoffirstordermodelparametersPanel.TitlePosition = 'centertop';
            app.DetailedanalysisoffirstordermodelparametersPanel.Title = 'Detailed analysis of margins, offset  and closed-loop behaviour (Proportional and Lag)';
            app.DetailedanalysisoffirstordermodelparametersPanel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.DetailedanalysisoffirstordermodelparametersPanel.Layout.Row = 5;
            app.DetailedanalysisoffirstordermodelparametersPanel.Layout.Column = [1 3];
            app.DetailedanalysisoffirstordermodelparametersPanel.FontWeight = 'bold';
            app.DetailedanalysisoffirstordermodelparametersPanel.FontSize = 14;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.DetailedanalysisoffirstordermodelparametersPanel);
            app.GridLayout5.ColumnWidth = {'1.4x', '1.4x', '1.4x'};
            app.GridLayout5.RowHeight = {'1x'};

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout5);
            title(app.UIAxes2, 'Closed-loop input')
            xlabel(app.UIAxes2, 'Time (s)')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 14;
            app.UIAxes2.Layout.Row = 1;
            app.UIAxes2.Layout.Column = 2;

            % Create UIAxes2_2
            app.UIAxes2_2 = uiaxes(app.GridLayout5);
            title(app.UIAxes2_2, 'Closed-loop output')
            xlabel(app.UIAxes2_2, 'Time (s)')
            zlabel(app.UIAxes2_2, 'Z')
            app.UIAxes2_2.FontSize = 14;
            app.UIAxes2_2.Layout.Row = 1;
            app.UIAxes2_2.Layout.Column = 3;

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.GridLayout5);
            app.GridLayout7.ColumnWidth = {'1x', '2.5x'};
            app.GridLayout7.RowHeight = {'1x', '1x', '1x', '1x', '1.6x', '1.6x'};
            app.GridLayout7.Layout.Row = 1;
            app.GridLayout7.Layout.Column = 1;

            % Create CurrentphasemarginLabel
            app.CurrentphasemarginLabel = uilabel(app.GridLayout7);
            app.CurrentphasemarginLabel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.CurrentphasemarginLabel.WordWrap = 'on';
            app.CurrentphasemarginLabel.FontWeight = 'bold';
            app.CurrentphasemarginLabel.Layout.Row = 1;
            app.CurrentphasemarginLabel.Layout.Column = 1;
            app.CurrentphasemarginLabel.Text = 'Current phase margin';

            % Create GaincrossoverfrequencyLabel
            app.GaincrossoverfrequencyLabel = uilabel(app.GridLayout7);
            app.GaincrossoverfrequencyLabel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.GaincrossoverfrequencyLabel.WordWrap = 'on';
            app.GaincrossoverfrequencyLabel.FontWeight = 'bold';
            app.GaincrossoverfrequencyLabel.Layout.Row = 2;
            app.GaincrossoverfrequencyLabel.Layout.Column = 1;
            app.GaincrossoverfrequencyLabel.Text = 'Gain cross over frequency';

            % Create ClosedloopoffsetstepsLabel
            app.ClosedloopoffsetstepsLabel = uilabel(app.GridLayout7);
            app.ClosedloopoffsetstepsLabel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.ClosedloopoffsetstepsLabel.WordWrap = 'on';
            app.ClosedloopoffsetstepsLabel.FontWeight = 'bold';
            app.ClosedloopoffsetstepsLabel.Layout.Row = 3;
            app.ClosedloopoffsetstepsLabel.Layout.Column = 1;
            app.ClosedloopoffsetstepsLabel.Text = 'Closed-loop offset (steps)';

            % Create ClosedloopoffsetrampsLabel
            app.ClosedloopoffsetrampsLabel = uilabel(app.GridLayout7);
            app.ClosedloopoffsetrampsLabel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.ClosedloopoffsetrampsLabel.WordWrap = 'on';
            app.ClosedloopoffsetrampsLabel.FontWeight = 'bold';
            app.ClosedloopoffsetrampsLabel.Layout.Row = 4;
            app.ClosedloopoffsetrampsLabel.Layout.Column = 1;
            app.ClosedloopoffsetrampsLabel.Text = 'Closed-loop offset (ramps)';

            % Create CurrentmodelLabel
            app.CurrentmodelLabel = uilabel(app.GridLayout7);
            app.CurrentmodelLabel.BackgroundColor = [0.9294 0.6941 0.1255];
            app.CurrentmodelLabel.HorizontalAlignment = 'center';
            app.CurrentmodelLabel.WordWrap = 'on';
            app.CurrentmodelLabel.FontSize = 14;
            app.CurrentmodelLabel.FontWeight = 'bold';
            app.CurrentmodelLabel.Layout.Row = 5;
            app.CurrentmodelLabel.Layout.Column = 1;
            app.CurrentmodelLabel.Interpreter = 'latex';
            app.CurrentmodelLabel.Text = 'Current model ';

            % Create GsLabel
            app.GsLabel = uilabel(app.GridLayout7);
            app.GsLabel.BackgroundColor = [0.9294 0.6941 0.1255];
            app.GsLabel.HorizontalAlignment = 'center';
            app.GsLabel.FontSize = 14;
            app.GsLabel.FontWeight = 'bold';
            app.GsLabel.Layout.Row = 5;
            app.GsLabel.Layout.Column = 2;
            app.GsLabel.Interpreter = 'latex';
            app.GsLabel.Text = 'G(s)';

            % Create PhiLabel
            app.PhiLabel = uilabel(app.GridLayout7);
            app.PhiLabel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.PhiLabel.HorizontalAlignment = 'center';
            app.PhiLabel.WordWrap = 'on';
            app.PhiLabel.FontWeight = 'bold';
            app.PhiLabel.Layout.Row = 1;
            app.PhiLabel.Layout.Column = 2;
            app.PhiLabel.Interpreter = 'latex';
            app.PhiLabel.Text = 'Phi =';

            % Create wcLabel
            app.wcLabel = uilabel(app.GridLayout7);
            app.wcLabel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.wcLabel.HorizontalAlignment = 'center';
            app.wcLabel.WordWrap = 'on';
            app.wcLabel.FontWeight = 'bold';
            app.wcLabel.Layout.Row = 2;
            app.wcLabel.Layout.Column = 2;
            app.wcLabel.Text = 'wc =';

            % Create OffsetLabel
            app.OffsetLabel = uilabel(app.GridLayout7);
            app.OffsetLabel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.OffsetLabel.HorizontalAlignment = 'center';
            app.OffsetLabel.FontWeight = 'bold';
            app.OffsetLabel.Layout.Row = 3;
            app.OffsetLabel.Layout.Column = 2;
            app.OffsetLabel.Text = 'Offset = ';

            % Create RamperrorLabel
            app.RamperrorLabel = uilabel(app.GridLayout7);
            app.RamperrorLabel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.RamperrorLabel.HorizontalAlignment = 'center';
            app.RamperrorLabel.FontWeight = 'bold';
            app.RamperrorLabel.Layout.Row = 4;
            app.RamperrorLabel.Layout.Column = 2;
            app.RamperrorLabel.Text = 'Ramp error = ';

            % Create ControlLawLabel
            app.ControlLawLabel = uilabel(app.GridLayout7);
            app.ControlLawLabel.BackgroundColor = [0.9294 0.6941 0.1255];
            app.ControlLawLabel.HorizontalAlignment = 'center';
            app.ControlLawLabel.WordWrap = 'on';
            app.ControlLawLabel.FontSize = 14;
            app.ControlLawLabel.FontWeight = 'bold';
            app.ControlLawLabel.Layout.Row = 6;
            app.ControlLawLabel.Layout.Column = 1;
            app.ControlLawLabel.Interpreter = 'latex';
            app.ControlLawLabel.Text = 'Control Law';

            % Create MsLabel
            app.MsLabel = uilabel(app.GridLayout7);
            app.MsLabel.BackgroundColor = [0.9294 0.6941 0.1255];
            app.MsLabel.HorizontalAlignment = 'center';
            app.MsLabel.FontSize = 14;
            app.MsLabel.FontWeight = 'bold';
            app.MsLabel.Layout.Row = 6;
            app.MsLabel.Layout.Column = 2;
            app.MsLabel.Interpreter = 'latex';
            app.MsLabel.Text = 'M(s)';

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.ColumnWidth = {'0.4x', '1x'};
            app.GridLayout6.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout6.Layout.Row = 3;
            app.GridLayout6.Layout.Column = 1;
            app.GridLayout6.BackgroundColor = [0.702 1 0.702];

            % Create SpecificationsLabel
            app.SpecificationsLabel = uilabel(app.GridLayout6);
            app.SpecificationsLabel.BackgroundColor = [0 1 0];
            app.SpecificationsLabel.HorizontalAlignment = 'center';
            app.SpecificationsLabel.FontSize = 14;
            app.SpecificationsLabel.FontWeight = 'bold';
            app.SpecificationsLabel.Layout.Row = 1;
            app.SpecificationsLabel.Layout.Column = [1 2];
            app.SpecificationsLabel.Text = 'Specifications';

            % Create PMSliderLabel
            app.PMSliderLabel = uilabel(app.GridLayout6);
            app.PMSliderLabel.HorizontalAlignment = 'right';
            app.PMSliderLabel.FontWeight = 'bold';
            app.PMSliderLabel.Layout.Row = 2;
            app.PMSliderLabel.Layout.Column = 1;
            app.PMSliderLabel.Text = 'PM';

            % Create PMSlider
            app.PMSlider = uislider(app.GridLayout6);
            app.PMSlider.Limits = [30 80];
            app.PMSlider.ValueChangedFcn = createCallbackFcn(app, @PMSliderValueChanged, true);
            app.PMSlider.MinorTicks = [-20 -15 -10 -5 0 5 10 15 20];
            app.PMSlider.Layout.Row = 2;
            app.PMSlider.Layout.Column = 2;
            app.PMSlider.Value = 60;

            % Create OffsetLabel_2
            app.OffsetLabel_2 = uilabel(app.GridLayout6);
            app.OffsetLabel_2.HorizontalAlignment = 'right';
            app.OffsetLabel_2.FontWeight = 'bold';
            app.OffsetLabel_2.Layout.Row = 3;
            app.OffsetLabel_2.Layout.Column = 1;
            app.OffsetLabel_2.Text = 'Offset (%)';

            % Create OffsetSlider
            app.OffsetSlider = uislider(app.GridLayout6);
            app.OffsetSlider.Limits = [0 20];
            app.OffsetSlider.ValueChangedFcn = createCallbackFcn(app, @OffsetSliderValueChanged, true);
            app.OffsetSlider.Layout.Row = 3;
            app.OffsetSlider.Layout.Column = 2;
            app.OffsetSlider.Value = 10;

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.GridLayout);
            app.GridLayout9.ColumnWidth = {'1x', '3x'};
            app.GridLayout9.RowHeight = {'1x', '1x', '1x'};
            app.GridLayout9.Layout.Row = 4;
            app.GridLayout9.Layout.Column = 1;
            app.GridLayout9.BackgroundColor = [1 0.8 0.6];

            % Create ControlparametersLabel
            app.ControlparametersLabel = uilabel(app.GridLayout9);
            app.ControlparametersLabel.BackgroundColor = [1 0.502 0.302];
            app.ControlparametersLabel.HorizontalAlignment = 'center';
            app.ControlparametersLabel.FontSize = 14;
            app.ControlparametersLabel.FontWeight = 'bold';
            app.ControlparametersLabel.Layout.Row = 1;
            app.ControlparametersLabel.Layout.Column = [1 2];
            app.ControlparametersLabel.Text = 'Control parameters';

            % Create KpSliderLabel
            app.KpSliderLabel = uilabel(app.GridLayout9);
            app.KpSliderLabel.HorizontalAlignment = 'right';
            app.KpSliderLabel.FontWeight = 'bold';
            app.KpSliderLabel.Layout.Row = 2;
            app.KpSliderLabel.Layout.Column = 1;
            app.KpSliderLabel.Text = 'Kp';

            % Create KpSlider
            app.KpSlider = uislider(app.GridLayout9);
            app.KpSlider.Limits = [0 2];
            app.KpSlider.ValueChangedFcn = createCallbackFcn(app, @KpSliderValueChanged, true);
            app.KpSlider.Layout.Row = 2;
            app.KpSlider.Layout.Column = 2;
            app.KpSlider.Value = 0.6;

            % Create polezeroratioSliderLabel
            app.polezeroratioSliderLabel = uilabel(app.GridLayout9);
            app.polezeroratioSliderLabel.HorizontalAlignment = 'right';
            app.polezeroratioSliderLabel.WordWrap = 'on';
            app.polezeroratioSliderLabel.FontWeight = 'bold';
            app.polezeroratioSliderLabel.Layout.Row = 3;
            app.polezeroratioSliderLabel.Layout.Column = 1;
            app.polezeroratioSliderLabel.Text = 'pole/zero ratio';

            % Create polezeroratioSlider
            app.polezeroratioSlider = uislider(app.GridLayout9);
            app.polezeroratioSlider.Limits = [0 10];
            app.polezeroratioSlider.ValueChangedFcn = createCallbackFcn(app, @polezeroratioSliderValueChanged, true);
            app.polezeroratioSlider.Layout.Row = 3;
            app.polezeroratioSlider.Layout.Column = 2;
            app.polezeroratioSlider.Value = 1;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = lag_design_phase_margin

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

