classdef proportional_design_phase_margin < matlab.apps.AppBase
    %PROPORTIONAL_DESIGN_PHASE_MARGIN
    %   File written by J.A.Rossiter, University of Sheffield  
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   
    %   A simple interface to illustrate the concept of simple proportional
    %   design using frequency response analysis.
    %   
    %   Users can select from a number of predefined systems: 1st , 2nd and
    %   3rd order. These have a variety of time constants and also some
    %   have under-damped modes to illustrate resonance. Secondly they can
    %   change the proportional gain and see how the phase margin and
    %   closed-loop behaviour changes.
    %   
    %   The app also allows the user to add a dead-time to the system to
    %   determine what impact this has on behaviour.
    %   
    %   Some notes and engineering background are in the partner
    %   livescript file:    frequency_response_behaviour_manual.mlx
    %   A group of similar files can be downloaded through MATLAB
    %   add-ons with the toolbox name:  control101

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        GridLayout                  matlab.ui.container.GridLayout
        GridLayout9                 matlab.ui.container.GridLayout
        KpSlider                    matlab.ui.control.Slider
        KpSliderLabel               matlab.ui.control.Label
        ChoiceofgainKpLabel         matlab.ui.control.Label
        GridLayout6                 matlab.ui.container.GridLayout
        DegreesSlider               matlab.ui.control.Slider
        DegreesSliderLabel          matlab.ui.control.Label
        TargetphasemarginLabel      matlab.ui.control.Label
        DetailedanalysisoffirstordermodelparametersPanel  matlab.ui.container.Panel
        GridLayout5                 matlab.ui.container.GridLayout
        GridLayout7                 matlab.ui.container.GridLayout
        RamperrorLabel              matlab.ui.control.Label
        OffsetLabel                 matlab.ui.control.Label
        wcLabel                     matlab.ui.control.Label
        PhiLabel                    matlab.ui.control.Label
        GsLabel                     matlab.ui.control.Label
        CurrentmodelLabel           matlab.ui.control.Label
        ClosedloopoffsetrampsLabel  matlab.ui.control.Label
        ClosedloopoffsetstepsLabel  matlab.ui.control.Label
        GaincrossoverfreqLabel      matlab.ui.control.Label
        CurrentphasemarginsLabel    matlab.ui.control.Label
        UIAxes2                     matlab.ui.control.UIAxes
        UIAxes2_2                   matlab.ui.control.UIAxes
        GridLayout4                 matlab.ui.container.GridLayout
        DelaySlider                 matlab.ui.control.Slider
        DelaySliderLabel            matlab.ui.control.Label
        HighorderDropDown           matlab.ui.control.DropDown
        HighorderDropDownLabel      matlab.ui.control.Label
        SecondorderDropDown         matlab.ui.control.DropDown
        SecondorderDropDownLabel    matlab.ui.control.Label
        FirstorderDropDown          matlab.ui.control.DropDown
        FirstorderDropDownLabel     matlab.ui.control.Label
        ChoosemodelLabel            matlab.ui.control.Label
        GridLayout3                 matlab.ui.container.GridLayout
        OverlayseveralKpButton      matlab.ui.control.Button
        GridLayout2                 matlab.ui.container.GridLayout
        Image                       matlab.ui.control.Image
        ProportionaldesignwithaphasemarginLabel  matlab.ui.control.Label
        UIAxes                      matlab.ui.control.UIAxes
        UIAxes_2                    matlab.ui.control.UIAxes
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
        nperiods;    % number of periods in simulation time
      
        PM =60 ;  % Target phase margin

          
    end
    
    methods (Access = private)
        


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  Down load data from sliders and create responses AND BODE
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function app = getbode_diagram(app)
       
       % collect data from sliders
       Kp = app.KpSlider.Value;
       delay = app.DelaySlider.Value;
       app.Gd = app.G*tf(1,1,'iodelay',delay);
       app.PM = app.DegreesSlider.Value;
       [gain,phase]=bode(app.G,app.wlist);
       [gaind,phased]=bode(app.Gd,app.wlist);
       app.PM = app.DegreesSlider.Value;

       % Find current margins
       warning('off','Control:analysis:MarginUnstable');
       [GM,PM,wp,wg] = margin(app.G*Kp);
       [GMd,PMd,wpd,wg] = margin(app.Gd*Kp);

       % plot gain
       hold(app.UIAxes,'off')
       semilogx(app.UIAxes,app.wlist,20*log10(gain(:)),':','color',[0.7 .3 1],'linewidth',2)
       hold(app.UIAxes,'on')
       semilogx(app.UIAxes,app.wlist,20*log10(gain(:)*Kp),'b')
       grid(app.UIAxes,'on')
       semilogx(app.UIAxes,[app.wlist(1),app.wlist(end)],[1 1]*(0),'k-','linewidth',3)
       ylim(app.UIAxes,[-20,max(20*log10(gain(:)*2))]);
       legend(app.UIAxes,'G','GK_p','0dB')
       text(app.UIAxes,app.wlist(10),-10,['K_p = ',num2str(Kp)],'fontsize',24)

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
       legend(app.UIAxes_2,'GK_p','GK_p+delay','Target PM','-180^o','PM')

       
      % Update display of values
      app.PhiLabel.Text = ['\phi = ',num2str(round(PM)),' and ',num2str(round(PMd))];
        app.OffsetLabel.Text = num2str(1/(1+dcgain(app.G)*Kp));
        app.wcLabel.Text = num2str(wg);
        
        if any(roots(app.denExample)==0);
            val = dcgain(tf([1 0],1)*app.G*Kp);
            app.RamperrorLabel.Text = num2str(1/val);
        else
            app.RamperrorLabel.Text = 'NA';
        end

            
    end   % end of getresponses subfunction


    % PLOT THE SYSTEM RESPONSES AND ALSO   
    % manage the plotting and the zoom on a later part to discern the
    % differences in magnitude and phase
        function app = plotresponses(app)

            Kp = app.KpSlider.Value;
            delay = app.DelaySlider.Value;
            app.Gd = app.G*tf(1,1,'iodelay',delay);
            % Feedback
            G1 = feedback(app.G*Kp,1);
            G1u = feedback(Kp,app.G);
            G1d = feedback(app.Gd*Kp,1);
            G1ud = feedback(Kp,app.Gd);
            % Closed-loop responses
            [y,t] = step(G1,app.endtime);
            [u] = step(G1u,t);
            [yd] = step(G1d,t);
            [ud] = step(G1ud,t);

            % Output plot
            hold(app.UIAxes2_2,'off')
            plot(app.UIAxes2_2,t,y,'b',t,yd,'r-');
            legend(app.UIAxes2_2, 'GK_p', 'GK_p + delay','Location','southeast');
            grid(app.UIAxes2_2,'on')
            y1 = min(y); y2 = max(y); d = y2-y1;
            ylim(app.UIAxes2_2,[y1-d/10 y2+d/10]);
            % Input plot
            hold(app.UIAxes2,'off')
            plot(app.UIAxes2,t,u,'b',t,ud,'r-');
            legend(app.UIAxes2, 'GK_p', 'GK_p + delay');
            grid(app.UIAxes2,'on')
           

        end

        % Display transfer function
        function updateTransferFunctionRender(app)
            n=app.numExample;
            d=app.denExample;
            numerator_str = array2StringPolynomial(app,n);
            denumerator_str = array2StringPolynomial(app,d);
            delaystr = num2str(app.DelaySlider.Value);

            app.GsLabel.Text = "$e^{-s"+delaystr+"}\frac{"+numerator_str+"}"+"{"+denumerator_str+"}$";

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
            app.PM = app.DegreesSlider.Value;
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




        end  % end of sub functions section
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
            % resize to be in middle of  the window
            movegui(app.UIFigure)

            % Open the manual
            if exist('proportional_design_phase_margin_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open proportional_design_phase_margin_mycopy.mlx
            else           
                p1 = which('proportional_design_phase_margin_manual.mlx');
                p2 = strcat(pwd,'/proportional_design_phase_margin_mycopy.mlx');
                copyfile(p1,p2)           
                open proportional_design_phase_margin_mycopy.mlx
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

        % Value changed function: DegreesSlider
        function DegreesSliderValueChanged(app, event)
            value = app.DegreesSlider.Value;
            value = round(value*2,-1)/2;
            app.DegreesSlider.Value=value;
            app.PM=value;
            app = getbode_diagram(app);
            app = plotresponses(app); 
            
            
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
                    app.wlist = logspace(-2,1,200);
                    app.endtime = 5;
                case '2/(s+1)'; 
                    app.G = tf(2,[1 1]);
                    app.numExample =2;
                    app.denExample = [1 1];
                    app.endtime =15;
                    app.wlist = logspace(-2,1,200); 
                    app.endtime = 3;
                
                case '0.5/(s+0.1)'; 
                    app.G = tf([0.5],[1 0.1]);
                    app.numExample = [0.5];
                    app.denExample = [1 0.1];
                    app.endtime =55;
                    app.wlist = logspace(-2,1,200); 
                    app.endtime = 10;
                    
            end
            updateTransferFunctionRender(app);
            app = getbode_diagram(app);
            app = plotresponses(app); 

        end

        % Value changed function: DelaySlider
        function DelaySliderValueChanged(app, event)
            value = app.DelaySlider.Value;
            value = round(value,1);
            app.DelaySlider.Value=value;
            updateTransferFunctionRender(app);
            app = getbode_diagram(app);
            app = plotresponses(app); 
            
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
                    app.wlist = logspace(-2,1,200); 
                    app.endtime = 10;
                case '8/[(s+1)(s+2)]'; 
                    app.G = tf(8,[1 3 2]);
                    app.numExample =8;
                    app.denExample = [1 3 2];
                    app.endtime =15;
                    app.wlist = logspace(-1,2,200); 
                    app.endtime = 5;
                case '6(s+1)/[s(s+3)]'; 
                    app.G = tf(6*[1 1],[1 3 0]);
                    app.numExample =6*[1 1];
                    app.denExample = [1 3 0];
                    app.endtime =15;
                    app.wlist = logspace(-1,2,200); 
                    app.endtime = 5;
                case '10(s+1)/[(s+3)(s+5)]'; 
                    app.G = tf(10*[1 1],[1 8 15]);
                    app.numExample = 10*[1 1];
                    app.denExample = [1 8 15];
                    app.endtime =15;
                    app.wlist = logspace(-1,2,200); 
                    app.endtime = 3;
                case '0.4/[(s+0.2)(s+0.1)]'; 
                    app.G = tf([0.4],[1 0.3 0.02]);
                    app.numExample = 0.4;
                    app.denExample = [1 0.3 0.02];
                    app.endtime =55;
                    app.wlist = logspace(-2,1,200); 
                    app.endtime = 30;
                case '1/[(s^2+0.2s+1)]'; 
                    app.G = tf([1],[1 0.2 1]);
                    app.numExample = 1;
                    app.denExample = [1 0.2 1];
                    app.endtime =65;
                    app.wlist = logspace(-2,1,200); 
                    app.endtime = 30;
                case '20/[(s^2+s+10)]'; 
                    app.G = tf([20],[1 1 10]);
                    app.numExample = 20;
                    app.denExample = [1 1 10];
                    app.endtime =20;
                    app.wlist = logspace(-1,2,200); 
                    app.endtime = 10;
                case '0.1/[(s^2+0.2s+0.03)]'; 
                    app.G = tf([0.1],[1 0.2 0.03]);
                    app.numExample = .1;
                    app.denExample = [1 .2 0.03];
                    app.endtime =55;
                    app.wlist = logspace(-2,1,200); 
                    app.endtime = 40;
                    
            end
            updateTransferFunctionRender(app);
            app = getbode_diagram(app);
            app = plotresponses(app); 
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
                    app.wlist = logspace(-2,1,200);
                    app.endtime = 15;
                case '20/[(s+1)(s+2)(s+4)]'; 
                    app.G = tf(20,[1 7 14 8]);
                    app.numExample =20;
                    app.denExample = [1 7 14 8];
                    app.endtime =15;
                    app.wlist = logspace(-1,2,200);
                    app.endtime = 5;
                case '5(s+2)/[s(s+1)(s+4)]'; 
                    app.G = tf(5*[1 2],[1 5 4 0]);
                    app.numExample =5*[1 2];
                    app.denExample = [1 5 4 0];
                    app.endtime =15;
                    app.wlist = logspace(-2,1,200);
                    app.endtime = 8;
                case '5(s+4)/[(s+1)(s+1)(s+2)]'; 
                    app.G = tf(5*[1 4],[1 4 5 2]);
                    app.numExample = 5*[1 4];
                    app.denExample = [1 4 5 2];
                    app.endtime =15;
                    app.wlist = logspace(-2,1,200);
                    app.endtime = 8;
               case '5(s+2)/[(s+1)(s^2+0.4s+16)]'; 
                    app.G = tf(5*[1 2],[1 1.4 16.4 16]);
                    app.numExample = 5*[1 2];
                    app.denExample = [1 1.4 16.4 16];
                    app.endtime =20;
                    app.wlist = logspace(-1,2,200);
                    app.endtime = 20;
            end
            
            updateTransferFunctionRender(app);
            app = getbode_diagram(app);
            app = plotresponses(app); 


        end

        % Clicked callback: SecondorderDropDown
        function SecondorderDropDownClicked(app, event)
            item = event.InteractionInformation.Item;
            SecondorderDropDownValueChanged(app);
            
        end

        % Clicked callback: FirstorderDropDown
        function FirstorderDropDownClicked(app, event)
            item = event.InteractionInformation.Item;
            FirstorderDropDownValueChanged(app);
        end

        % Clicked callback: HighorderDropDown
        function HighorderDropDownClicked(app, event)
            item = event.InteractionInformation.Item;
            HighorderDropDownValueChanged(app);
        end

        % Value changed function: KpSlider
        function KpSliderValueChanged(app, event)
            value = app.KpSlider.Value;
            value = round(value,2);
            app.KpSlider.Value = value;
            app = getbode_diagram(app);
            app = plotresponses(app); 

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
            app.UIFigure.Position = [100 100 1054 823];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '2x', '1x'};
            app.GridLayout.RowHeight = {'0.4x', '1.2x', '0.6x', '0.6x', '2x'};

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

            % Create ProportionaldesignwithaphasemarginLabel
            app.ProportionaldesignwithaphasemarginLabel = uilabel(app.GridLayout2);
            app.ProportionaldesignwithaphasemarginLabel.BackgroundColor = [0 1 1];
            app.ProportionaldesignwithaphasemarginLabel.HorizontalAlignment = 'center';
            app.ProportionaldesignwithaphasemarginLabel.FontSize = 18;
            app.ProportionaldesignwithaphasemarginLabel.FontWeight = 'bold';
            app.ProportionaldesignwithaphasemarginLabel.Layout.Row = 1;
            app.ProportionaldesignwithaphasemarginLabel.Layout.Column = [1 2];
            app.ProportionaldesignwithaphasemarginLabel.Text = 'Proportional design with a phase margin';

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

            % Create OverlayseveralKpButton
            app.OverlayseveralKpButton = uibutton(app.GridLayout3, 'push');
            app.OverlayseveralKpButton.ButtonPushedFcn = createCallbackFcn(app, @OverlayseveralKpButtonPushed, true);
            app.OverlayseveralKpButton.WordWrap = 'on';
            app.OverlayseveralKpButton.BackgroundColor = [1 0.2 0.702];
            app.OverlayseveralKpButton.FontSize = 18;
            app.OverlayseveralKpButton.FontWeight = 'bold';
            app.OverlayseveralKpButton.Layout.Row = 1;
            app.OverlayseveralKpButton.Layout.Column = 1;
            app.OverlayseveralKpButton.Text = 'Overlay several Kp';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'0.4x', '1x'};
            app.GridLayout4.RowHeight = {'1x', '1x', '1x', '1x', '1.2x'};
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

            % Create DelaySliderLabel
            app.DelaySliderLabel = uilabel(app.GridLayout4);
            app.DelaySliderLabel.HorizontalAlignment = 'right';
            app.DelaySliderLabel.FontSize = 14;
            app.DelaySliderLabel.FontWeight = 'bold';
            app.DelaySliderLabel.Layout.Row = 5;
            app.DelaySliderLabel.Layout.Column = 1;
            app.DelaySliderLabel.Text = 'Delay';

            % Create DelaySlider
            app.DelaySlider = uislider(app.GridLayout4);
            app.DelaySlider.Limits = [0 1];
            app.DelaySlider.ValueChangedFcn = createCallbackFcn(app, @DelaySliderValueChanged, true);
            app.DelaySlider.Layout.Row = 5;
            app.DelaySlider.Layout.Column = 2;
            app.DelaySlider.Value = 0.2;

            % Create DetailedanalysisoffirstordermodelparametersPanel
            app.DetailedanalysisoffirstordermodelparametersPanel = uipanel(app.GridLayout);
            app.DetailedanalysisoffirstordermodelparametersPanel.AutoResizeChildren = 'off';
            app.DetailedanalysisoffirstordermodelparametersPanel.TitlePosition = 'centertop';
            app.DetailedanalysisoffirstordermodelparametersPanel.Title = 'Detailed analysis of margins, offset  and closed-loop behaviour';
            app.DetailedanalysisoffirstordermodelparametersPanel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.DetailedanalysisoffirstordermodelparametersPanel.Layout.Row = 5;
            app.DetailedanalysisoffirstordermodelparametersPanel.Layout.Column = [1 3];
            app.DetailedanalysisoffirstordermodelparametersPanel.FontWeight = 'bold';
            app.DetailedanalysisoffirstordermodelparametersPanel.FontSize = 14;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.DetailedanalysisoffirstordermodelparametersPanel);
            app.GridLayout5.ColumnWidth = {'1.4x', '1.4x', '1.4x'};
            app.GridLayout5.RowHeight = {'1x'};

            % Create UIAxes2_2
            app.UIAxes2_2 = uiaxes(app.GridLayout5);
            title(app.UIAxes2_2, 'Closed-loop output')
            xlabel(app.UIAxes2_2, 'Time (s)')
            zlabel(app.UIAxes2_2, 'Z')
            app.UIAxes2_2.FontSize = 14;
            app.UIAxes2_2.Layout.Row = 1;
            app.UIAxes2_2.Layout.Column = 3;

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout5);
            title(app.UIAxes2, 'Closed-loop input')
            xlabel(app.UIAxes2, 'Time (s)')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 14;
            app.UIAxes2.Layout.Row = 1;
            app.UIAxes2.Layout.Column = 2;

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.GridLayout5);
            app.GridLayout7.ColumnWidth = {'1x', '2.5x'};
            app.GridLayout7.RowHeight = {'1x', '1x', '1x', '1x', '2x'};
            app.GridLayout7.Layout.Row = 1;
            app.GridLayout7.Layout.Column = 1;

            % Create CurrentphasemarginsLabel
            app.CurrentphasemarginsLabel = uilabel(app.GridLayout7);
            app.CurrentphasemarginsLabel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.CurrentphasemarginsLabel.WordWrap = 'on';
            app.CurrentphasemarginsLabel.FontWeight = 'bold';
            app.CurrentphasemarginsLabel.Layout.Row = 1;
            app.CurrentphasemarginsLabel.Layout.Column = 1;
            app.CurrentphasemarginsLabel.Text = 'Current phase margins';

            % Create GaincrossoverfreqLabel
            app.GaincrossoverfreqLabel = uilabel(app.GridLayout7);
            app.GaincrossoverfreqLabel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.GaincrossoverfreqLabel.WordWrap = 'on';
            app.GaincrossoverfreqLabel.FontWeight = 'bold';
            app.GaincrossoverfreqLabel.Layout.Row = 2;
            app.GaincrossoverfreqLabel.Layout.Column = 1;
            app.GaincrossoverfreqLabel.Text = 'Gain cross over freq.';

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
            app.CurrentmodelLabel.FontSize = 18;
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
            app.PhiLabel.FontSize = 14;
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
            app.wcLabel.FontSize = 14;
            app.wcLabel.FontWeight = 'bold';
            app.wcLabel.Layout.Row = 2;
            app.wcLabel.Layout.Column = 2;
            app.wcLabel.Text = 'wc =';

            % Create OffsetLabel
            app.OffsetLabel = uilabel(app.GridLayout7);
            app.OffsetLabel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.OffsetLabel.HorizontalAlignment = 'center';
            app.OffsetLabel.FontSize = 14;
            app.OffsetLabel.FontWeight = 'bold';
            app.OffsetLabel.Layout.Row = 3;
            app.OffsetLabel.Layout.Column = 2;
            app.OffsetLabel.Text = 'Offset = ';

            % Create RamperrorLabel
            app.RamperrorLabel = uilabel(app.GridLayout7);
            app.RamperrorLabel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.RamperrorLabel.HorizontalAlignment = 'center';
            app.RamperrorLabel.FontSize = 14;
            app.RamperrorLabel.FontWeight = 'bold';
            app.RamperrorLabel.Layout.Row = 4;
            app.RamperrorLabel.Layout.Column = 2;
            app.RamperrorLabel.Text = 'Ramp error = ';

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.ColumnWidth = {'0.4x', '1x'};
            app.GridLayout6.Layout.Row = 3;
            app.GridLayout6.Layout.Column = 1;
            app.GridLayout6.BackgroundColor = [0.702 1 0.702];

            % Create TargetphasemarginLabel
            app.TargetphasemarginLabel = uilabel(app.GridLayout6);
            app.TargetphasemarginLabel.BackgroundColor = [0 1 0];
            app.TargetphasemarginLabel.HorizontalAlignment = 'center';
            app.TargetphasemarginLabel.FontSize = 14;
            app.TargetphasemarginLabel.FontWeight = 'bold';
            app.TargetphasemarginLabel.Layout.Row = 1;
            app.TargetphasemarginLabel.Layout.Column = [1 2];
            app.TargetphasemarginLabel.Text = 'Target phase margin';

            % Create DegreesSliderLabel
            app.DegreesSliderLabel = uilabel(app.GridLayout6);
            app.DegreesSliderLabel.HorizontalAlignment = 'right';
            app.DegreesSliderLabel.Layout.Row = 2;
            app.DegreesSliderLabel.Layout.Column = 1;
            app.DegreesSliderLabel.Text = 'Degrees';

            % Create DegreesSlider
            app.DegreesSlider = uislider(app.GridLayout6);
            app.DegreesSlider.Limits = [30 90];
            app.DegreesSlider.ValueChangedFcn = createCallbackFcn(app, @DegreesSliderValueChanged, true);
            app.DegreesSlider.MinorTicks = [-20 -15 -10 -5 0 5 10 15 20];
            app.DegreesSlider.Layout.Row = 2;
            app.DegreesSlider.Layout.Column = 2;
            app.DegreesSlider.Value = 60;

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.GridLayout);
            app.GridLayout9.ColumnWidth = {'1x', '3x'};
            app.GridLayout9.Layout.Row = 4;
            app.GridLayout9.Layout.Column = 1;
            app.GridLayout9.BackgroundColor = [1 0.8 0.6];

            % Create ChoiceofgainKpLabel
            app.ChoiceofgainKpLabel = uilabel(app.GridLayout9);
            app.ChoiceofgainKpLabel.BackgroundColor = [1 0.502 0.302];
            app.ChoiceofgainKpLabel.HorizontalAlignment = 'center';
            app.ChoiceofgainKpLabel.FontSize = 14;
            app.ChoiceofgainKpLabel.FontWeight = 'bold';
            app.ChoiceofgainKpLabel.Layout.Row = 1;
            app.ChoiceofgainKpLabel.Layout.Column = [1 2];
            app.ChoiceofgainKpLabel.Text = 'Choice of gain Kp';

            % Create KpSliderLabel
            app.KpSliderLabel = uilabel(app.GridLayout9);
            app.KpSliderLabel.HorizontalAlignment = 'right';
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

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = proportional_design_phase_margin

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

