classdef lead_lag_design_criteria < matlab.apps.AppBase
    %LEAD_LAG_DESIGN_CRITERIA
    %   File written by J.A.Rossiter, University of Sheffield  
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   
    %   A simple interface to compare simple proportional, Lag, Lead and
    %   Lead-Lag compensation design using frequency response analysis.
    %   
    %   Users can select from a number of predefined systems:  2nd and
    %   3rd order. These have a variety of time constants and also some
    %   have under-damped modes to illustrate resonance. 
    %   
    %   Users must also select their design criteria: phase margin,
    %   bandwidth and offset. The compensator designs are then done
    %   automatically and the associated plots are shown. 
    %   
    %   The manual gives more guidance on what happens
    %   behind the scenes to help the user to understand the underlying
    %   designs.
    %   
    %   A group of similar files can be downloaded through MATLAB
    %   add-ons with the toolbox name:  control101

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        GridLayout11                   matlab.ui.container.GridLayout
        UIAxes_2                       matlab.ui.control.UIAxes
        UIAxes                         matlab.ui.control.UIAxes
        GridLayout9                    matlab.ui.container.GridLayout
        Label_2                        matlab.ui.control.Label
        Label_3                        matlab.ui.control.Label
        Label                          matlab.ui.control.Label
        LagzeropoleratioLabel          matlab.ui.control.Label
        LeadpolezeroratioLabel         matlab.ui.control.Label
        KpLabel                        matlab.ui.control.Label
        LeadlagControlparametersLabel  matlab.ui.control.Label
        GridLayout6                    matlab.ui.container.GridLayout
        OffsetSlider                   matlab.ui.control.Slider
        OffsetSliderLabel              matlab.ui.control.Label
        BandwidthSlider                matlab.ui.control.Slider
        OffsetLabel_2                  matlab.ui.control.Label
        PMSlider                       matlab.ui.control.Slider
        PMSliderLabel                  matlab.ui.control.Label
        SpecificationsLabel            matlab.ui.control.Label
        DetailedanalysisoffirstordermodelparametersPanel  matlab.ui.container.Panel
        GridLayout5                    matlab.ui.container.GridLayout
        GridLayout7                    matlab.ui.container.GridLayout
        RamperrorLabel                 matlab.ui.control.Label
        OffsetLabel                    matlab.ui.control.Label
        wcLabel                        matlab.ui.control.Label
        PhiLabel                       matlab.ui.control.Label
        GsLabel                        matlab.ui.control.Label
        CurrentmodelLabel              matlab.ui.control.Label
        ClosedloopoffsetrampsLabel     matlab.ui.control.Label
        ClosedloopoffsetstepsLabel     matlab.ui.control.Label
        GaincrossoverfrequencyLabel    matlab.ui.control.Label
        CurrentphasemarginLabel        matlab.ui.control.Label
        UIAxes2_2                      matlab.ui.control.UIAxes
        UIAxes2                        matlab.ui.control.UIAxes
        GridLayout4                    matlab.ui.container.GridLayout
        HighorderDropDown              matlab.ui.control.DropDown
        HighorderDropDownLabel         matlab.ui.control.Label
        SecondorderDropDown            matlab.ui.control.DropDown
        SecondorderDropDownLabel       matlab.ui.control.Label
        ChoosemodelLabel               matlab.ui.control.Label
        GridLayout3                    matlab.ui.container.GridLayout
        UpdateplotsButton              matlab.ui.control.Button
        GridLayout2                    matlab.ui.container.GridLayout
        Image                          matlab.ui.control.Image
        CompensatordesignwithPMbandwidthandoffsetcriteriaLabel  matlab.ui.control.Label
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
        u   % sinsoidal signal
        y   % response no delay
        yd  % response with delay
        omega % frequency
        tvec  % time vector for plotting
        endtime=5;  % default simulation tome
      
        PM =60 ;  % Target phase margin
        int =0;  % tag for whether an integrator included
        offset = 'step' % tag for ramp or step offset criteria
        Kp = 1;  % Proportional compensator
        MLEAD = 1;  % to store lead compensator
        MLAG = 1; % store lag component
        MLEADLAG =1; % Lead-lag compensator
        wg        % cross over frequency based on G*Kp

        warningtext = ' '% for error messsages

          
    end
    
    methods (Access = private)
        


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  Down load data and create BODE
 %%%%%%%%% and simple data such as offsets and PM
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function app = getbode_diagram(app)
       
       % collect data from sliders
       wgd = app.BandwidthSlider.Value;  % desired bandwith so use for pole/zero choices
  
       
       % get margins with just proportional
       warning('off','Control:analysis:MarginUnstable');
       [GM,PM,wp,wg] = margin(app.G*app.Kp);  % core frequency is wg
       wg = round(wg,2,'significant');
       [GMlag,PMlag,ww,wlag] = margin(app.G*app.MLAG);
       [GMd,PMd,wpl,wgl] = margin(app.G*app.MLEADLAG);
       [GMlead,PMlead,ww,wlead] = margin(app.G*app.MLEAD);
       [lagpole,lagzero]=pzmap(app.MLAG);

       % Set up plots
       app.PM = app.PMSlider.Value;
       offset = app.BandwidthSlider.Value;
       [gain,phase]=bode(app.G,app.wlist);
       [gaind,phased]=bode(app.G*app.MLEAD,app.wlist);
       [gaind2,phased2]=bode(app.G*app.MLEADLAG,app.wlist);
       [gaind3,phased3]=bode(app.G*app.MLAG,app.wlist);
 
       % plot gain
       hold(app.UIAxes,'off')
        
       semilogx(app.UIAxes,app.wlist,20*log10(gain(:)*app.Kp),'linewidth',2)
       hold(app.UIAxes,'on')
       grid(app.UIAxes,'on')
       semilogx(app.UIAxes,app.wlist,20*log10(gaind3(:)),'linewidth',2)
       semilogx(app.UIAxes,app.wlist,20*log10(gaind(:)),'linewidth',2)
       semilogx(app.UIAxes,app.wlist,20*log10(gaind2(:)),'linewidth',2)
       semilogx(app.UIAxes,app.wlist,20*log10(gain(:)),':','color',[0.7 .3 1],'linewidth',2)
       semilogx(app.UIAxes,[app.wlist(1),app.wlist(end)],[1 1]*(0),'k-','linewidth',3)
       %ylim(app.UIAxes,[-20,max(20*log10(gain(:)*2))]);
       plot(app.UIAxes,[wgd,wgd],[-20,20],'g--','linewidth',3);
       legend(app.UIAxes,'G*Kp','G*Lag','G*Lead','G*Lead-lag','G','0dB','Target bandwidth')
       text(app.UIAxes,app.wlist(4),-20,app.warningtext,'fontsize',18,'color','r')

       % plot phase
       hold(app.UIAxes_2,'off')
       semilogx(app.UIAxes_2,app.wlist,phase(:))
       hold(app.UIAxes_2,'on')
       semilogx(app.UIAxes_2,app.wlist,phased3(:))
       semilogx(app.UIAxes_2,app.wlist,phased(:))
       semilogx(app.UIAxes_2,app.wlist,phased2(:))
       semilogx(app.UIAxes_2,[app.wlist(1),app.wlist(end)],[1 1]*(app.PM-180),'g--','linewidth',2)
       grid(app.UIAxes_2,'on')
       ylim(app.UIAxes_2,[-220,max(phase)]);
       %legend(app.UIAxes_2,'G*K_p','G*Lead','G*Lead-lag','Target PM/bandwidth','-180^o','PM')
       
       % add pole and zero positions
       a2  =sqrt(str2num(app.Label_3.Text));
       beta = str2num(app.Label_2.Text);
       plot(app.UIAxes_2,wgd/a2,-180,'ro','linewidth',3,'markersize',16);
       plot(app.UIAxes_2,wgd*a2,-180,'rx','linewidth',3,'markersize',16);
       plot(app.UIAxes_2,[wgd,wgd],[-200,-90],'g:','linewidth',3);       
       plot(app.UIAxes_2,wgd/10,-180,'rs','linewidth',3,'markersize',16);
       plot(app.UIAxes_2,wgd/(10*beta),-180,'r*','linewidth',3,'markersize',16);
       plot(app.UIAxes_2,-lagzero,-180,'bs','linewidth',3,'markersize',16);
       plot(app.UIAxes_2,-lagpole,-180,'b*','linewidth',3,'markersize',16);
              semilogx(app.UIAxes_2,[app.wlist(1),app.wlist(end)],[1 1]*(-180),'k-','linewidth',3)
       legend(app.UIAxes_2,'G*K_p','G*Lag','G*Lead','G*Lead-lag','Target PM','Lead zero','Lead pole','Target bandwidth',...
           'Lead-Lag zero','Lead-Lag pole','Lag zero','Lag pole','Location','Northwest')
       xlim(app.UIAxes_2,[app.wlist(1),app.wlist(end)]);
       
      % Update display of values
      app.PhiLabel.Text = [num2str(round(PM)),',  ',...
          num2str(round(PMlag)),',  ',num2str(round(PMlead)),',  ',num2str(round(PMd))];
      
      app.OffsetLabel.Text = [num2str(1/(1+dcgain(app.G)*app.Kp)),',   ', ...
          num2str(1/(1+dcgain(app.G)*dcgain(app.MLAG))),',   ', ...
          num2str(1/(1+dcgain(app.G)*dcgain(app.MLEAD))),',   ', ...
          num2str(1/(1+dcgain(app.G)*dcgain(app.MLEADLAG)))];
      
      app.wcLabel.Text = num2str([wg,wlag,wlead,wgl]);
        
        if any(roots(app.denExample)==0)
            val = dcgain(tf([1 0],1)*app.G*app.Kp);
            app.RamperrorLabel.Text = [num2str(1/(val)),',   ',...
                num2str(1/(dcgain(app.MLAG)*val)),',   ',num2str(a2/val),...
                ',   ',num2str(a2/(val*beta))];
        else
            app.RamperrorLabel.Text = 'NA';
        end

            
    end   % end of getresponses subfunction


    % PLOT THE SYSTEM RESPONSES for proportional and lead compensation and lead-lag 
     function app = plotresponses(app)

                        
            % Feedback
            G1 = feedback(app.G*app.Kp,1);
            G1u = feedback(app.Kp,app.G);
            G1lag = feedback(app.G*app.MLAG,1);
            G1ulag = feedback(app.MLAG,app.G);
            G1d = feedback(app.G*app.MLEAD,1);
            G1ud = feedback(app.MLEAD,app.G);
            G1d2 = feedback(app.G*app.MLEADLAG,1);
            G1ud2 = feedback(app.MLEADLAG,app.G);
            
            
            % Closed-loop responses either steps or ramps
            if app.int==0  % doing steps
                [y,t] = step(G1,app.endtime);
                [u] = step(G1u,t);
                [ulag] = step(G1ulag,t);
                [ylag] = step(G1lag,t);
                [yd] = step(G1d,t);
                [ud] = step(G1ud,t);
                [yd2] = step(G1d2,t);
                [ud2] = step(G1ud2,t);
                e = 1-y;
                elag = 1 - ylag;
                elead = 1 - yd;
                eleadlag=1-yd2;
            else % doing ramps
                t=linspace(0,app.endtime,101)';
                ylead = lsim(G1d,t,t);
                yleadlag = lsim(G1d2,t,t);
                ylag = lsim(G1lag,t,t);
                ykp = lsim(G1,t,t);
                ud = lsim(G1ud,t,t);
                ud2 = lsim(G1ud2,t,t);
                
                ulag = lsim(G1ulag,t,t);
                u = lsim(G1u,t,t);
                e=t-ykp;
                elag = t-ylag;
                elead= t - ylead;
                eleadlag = t - yleadlag;
            end

            % Output plot
            hold(app.UIAxes2_2,'off')
            plot(app.UIAxes2_2,t,e,t,elag,t,elead,t,eleadlag);
            hold(app.UIAxes2_2,'on')
            plot(app.UIAxes2_2,[t(1),t(end)],[1,1]*(app.OffsetSlider.Value/100),'g--','linewidth',2);
            legend(app.UIAxes2_2, 'G*K_p', 'G*Lag','G*Lead','G*Lead-lag',...
                'Target','Location','northeast');
            grid(app.UIAxes2_2,'on')
            y1 = min([0,min(e)]); y2 = max(e); d = y2-y1;
            ylim(app.UIAxes2_2,[y1-d/10 max([1.05,y2+d/10])]); % Always include unity
            % Input plot
            hold(app.UIAxes2,'off')
            plot(app.UIAxes2,t,u,t,ulag,t,ud,t,ud2);
            legend(app.UIAxes2, 'G*K_p','G*Lag','G*Lead','G*Lead-lag');
            grid(app.UIAxes2,'on')
            
 
        end

        % Display transfer function and control law in text boxes
        function updateTransferFunctionRender(app)
            n=app.numExample; 
            d=app.denExample;
            numerator_str = array2StringPolynomial(app,n);
            denumerator_str = array2StringPolynomial(app,d);
            % alpha = str2num(app.Label_3.Text);
            % beta = str2num(app.Label_2.Text);
            % a2 = sqrt(alpha);
            %delaystr = num2str(app.DelaySlider.Value);
            app.GsLabel.Text = "$\frac{"+numerator_str+"}"+"{"+denumerator_str+"}$";
             
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

        % update plots and data when something is changed
        function updateallplots(app)
            
            app = definecompensators(app);
            app = getbode_diagram(app);
            app = plotresponses(app); 
            updateTransferFunctionRender(app);
            
        end


        % use the mechanistic rules to define all the required compensators
        % if integrator use ramp error offset
        % if no integrator use step offset

        function app = definecompensators(app)
            
            [n,d]= tfdata(app.G,'v');
            if app.int ==1  % Check for integrator
                G2 = tf(n,d(1:end-1));
            end 
            desiredPM =app.PMSlider.Value;  % target PM
            offset = app.OffsetSlider.Value*0.01;  % target offset
            wc =app.BandwidthSlider.Value; % target bandwidth
            app.warningtext=' ';
            
                        
            % proportional design
            wmin=wc/100;
            wmax=wc*10;
            [gain,phase,wlist] = bode(app.G,{wmin,wmax});
            [Gm,Pm,wcp,wcg] = margin(gain(:)',phase(:)'-desiredPM,wlist);
            app.Kp = Gm;wclag=wcp;
            app.Label.Text = num2str(Gm);
            
            % lag design
            if app.int==1
               plag =1/(dcgain(G2)*app.Kp*offset);
            else
                plag =((1/offset)-1)/(dcgain(app.G)*app.Kp);
            end
            if plag>10
                plag =10;                        
               app.warningtext ='Offset not achievable by Lag. ';
               % if app.int==1;
               %     offset = 1/(dcgain(G2*app.Kp*10));
               % else
               %     offset = 1/(1+dcgain(app.G*app.Kp*10));
               % end
               % app.OffsetSlider.Value=offset*100;
            elseif plag<1
                plag =1;
            end
            app.MLAG = minreal(app.Kp*tf([1,wclag/10],[1,wclag/(10*plag)]));          
            
            
            % lead design
            [gainGwc,phaseGwc] = bode(app.G,wc);
            uplift = -180 - phaseGwc +desiredPM;
            if uplift>55
                app.warningtext=[app.warningtext,'Bandwidth not achievable. '];
                wc = wclag*2;
                %app.BandwidthSlider.Value=wc;
                %[gainGwc,phaseGwc] = bode(app.G,wc);
                uplift = 54.9;
            elseif uplift<0
                uplift=0;
                app.warningtext=[app.warningtext,'Lead not needed. '];
            end
            upliftrad=uplift*pi/180;
            r = (sin(upliftrad)+1)/(1-sin(upliftrad));
            sr=sqrt(r);
            K= sr/gainGwc;
            zero = wc/sr;
            pole = wc*sr;
            app.MLEAD = K*tf([1,zero],[1,pole]);
            app.Label_3.Text = num2str(r);
            
            % lead-lag design
            if app.int==1
                p= 1/(dcgain(app.MLEAD)*dcgain(G2)*offset);   %gainrecovery
            else
                p=((1/offset)-1)/(dcgain(app.MLEAD)*dcgain(app.G));
            end
            
            if p<1;p=1;
                app.warningtext=[app.warningtext,'Lag of Lead-lag not needed.'];
            elseif p>10 
                p=10;
                app.warningtext=[app.warningtext,'Offset not achievable by Lead-lag.'];
            end
            app.Label_2.Text = num2str(p);
            app.MLEADLAG=minreal(app.MLEAD*tf([1,wc/10],[1,wc/(p*10)]));
            

        end



        end  % end of sub functions section
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
            % resize to be in middle of  the window
            movegui(app.UIFigure)

            % Open the manual
            if exist('lead_lag_design_criteria_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open lead_lag_design_criteria_mycopy.mlx
            else           
                p1 = which('lead_lag_design_criteria_manual.mlx');
                p2 = strcat(pwd,'/lead_lag_design_criteria_mycopy.mlx');
                copyfile(p1,p2)           
                open lead_lag_design_criteria_mycopy.mlx
            end

            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);

            app.SecondorderDropDown.Value = '8/[(s+1)(s+2)]';
            SecondorderDropDownValueChanged(app);
            
            updateallplots(app);
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
            theme(app.UIFigure,"light")
            end


        end

        % Button pushed function: UpdateplotsButton
        function UpdateplotsButtonPushed(app, event)
           % 
          updateallplots(app)          

        end

        % Size changed function: UIFigure
        function UIFigureSizeChanged(app, event)
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

        % Value changed function: SecondorderDropDown
        function SecondorderDropDownValueChanged(app, event)
            % Select desired second order system and update plots
            value = app.SecondorderDropDown.Value;
            switch value
                case '2/[s(s+1)]' 
                    app.G =tf(2,[1 1 0]);
                    app.numExample =2 ;
                    app.denExample = [1 1 0];
                    app.endtime =15;
                    app.wlist = logspace(-3,1,200); 
                    app.int = 1;
                    app.offset = 'ramp';
                case '8/[(s+1)(s+2)]' 
                    app.G = tf(8,[1 3 2]);
                    app.numExample =8;
                    app.denExample = [1 3 2];
                    app.endtime =6;
                    app.wlist = logspace(-2,2,200); 
                    app.int = 0;
                    app.offset = 'step';
                
                case '0.4/[(s+0.2)(s+0.1)]' 
                    app.G = tf(0.4,[1 0.3 0.02]);
                    app.numExample = 0.4;
                    app.denExample = [1 0.3 0.02];
                    app.endtime =15;
                    app.wlist = logspace(-3,1,200); 
                    app.int = 0;
                    app.offset = 'step';
                case '1/[(s^2+0.2s+1)]' 
                    app.G = tf(1,[1 0.2 1]);
                    app.numExample = 1;
                    app.denExample = [1 0.2 1];
                    app.endtime =15;
                    app.wlist = logspace(-3,1,200); 
                    app.int = 0;
                    app.offset = 'step';
                case '20/[(s^2+s+10)]' 
                    app.G = tf(20,[1 1 10]);
                    app.numExample = 20;
                    app.denExample = [1 1 10];
                    app.endtime =5;
                    app.wlist = logspace(-2,2,200); 
                    app.int = 0;
                    app.offset = 'step';
                case '0.1/[(s^2+0.2s+0.03)]' 
                    app.G = tf(0.1,[1 0.2 0.03]);
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
                case '2/[s(s+1)(s+2)]' 
                    app.G =tf(2,[1 3 2 0]);
                    app.numExample =2;
                    app.denExample = [1 3 2 0];
                    app.endtime =15;
                    app.wlist = logspace(-3,1,200);
                    app.int = 1;
                    app.offset = 'ramp';
                case '20/[(s+1)(s+2)(s+4)]' 
                    app.G = tf(20,[1 7 14 8]);
                    app.numExample =20;
                    app.denExample = [1 7 14 8];
                    app.endtime =5;
                    app.wlist = logspace(-2,2,200);
                    app.int = 0;
                    app.offset = 'step';
                case '5(s+2)/[s(s+1)(s+4)]' 
                    app.G = tf(5*[1 2],[1 5 4 0]);
                    app.numExample =5*[1 2];
                    app.denExample = [1 5 4 0];
                    app.endtime =6;
                    app.wlist = logspace(-3,1,200);
                    app.int = 1;
                    app.offset = 'ramp';
                case '5(s+4)/[(s+1)(s+1)(s+2)]' 
                    app.G = tf(5*[1 4],[1 4 5 2]);
                    app.numExample = 5*[1 4];
                    app.denExample = [1 4 5 2];
                    app.endtime =4;
                    app.wlist = logspace(-3,1,200);
                    app.int = 0;
                    app.offset = 'step';

               case '5(s+2)/[(s+1)(s^2+0.4s+16)]' 
                    app.G = tf(5*[1 2],[1 1.4 16.4 16]);
                    app.numExample = 5*[1 2];
                    app.denExample = [1 1.4 16.4 16];
                    app.endtime =10;
                    app.wlist = logspace(-2,2,200);
                    app.int = 0;
                    app.offset = 'step';

            end
            
            updateallplots(app)


        end

        % Clicked callback: SecondorderDropDown
        function SecondorderDropDownClicked(app, event)
            % item = event.InteractionInformation.Item;
            SecondorderDropDownValueChanged(app);
            updateallplots(app)
            
        end

        % Clicked callback: HighorderDropDown
        function HighorderDropDownClicked(app, event)
            % item = event.InteractionInformation.Item;
            HighorderDropDownValueChanged(app);
            updateallplots(app)
        end

        % Value changed function: BandwidthSlider
        function BandwidthSliderValueChanged(app, event)
            value = app.BandwidthSlider.Value;
            value = round(value,1);
            app.BandwidthSlider.Value = value;
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

        % Value changed function: OffsetSlider
        function OffsetSliderValueChanged(app, event)
            value = app.OffsetSlider.Value;
            value = round(value,0);
            app.OffsetSlider.Value = value;
            updateallplots(app) 
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
            app.UIFigure.Position = [100 100 1197 902];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '2x', '1x'};
            app.GridLayout.RowHeight = {'0.4x', '1.2x', '1x', '1x', '1.8x'};

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = [2 3];
            app.GridLayout2.BackgroundColor = [0.6 1 1];

            % Create CompensatordesignwithPMbandwidthandoffsetcriteriaLabel
            app.CompensatordesignwithPMbandwidthandoffsetcriteriaLabel = uilabel(app.GridLayout2);
            app.CompensatordesignwithPMbandwidthandoffsetcriteriaLabel.BackgroundColor = [0 1 1];
            app.CompensatordesignwithPMbandwidthandoffsetcriteriaLabel.HorizontalAlignment = 'center';
            app.CompensatordesignwithPMbandwidthandoffsetcriteriaLabel.WordWrap = 'on';
            app.CompensatordesignwithPMbandwidthandoffsetcriteriaLabel.FontSize = 18;
            app.CompensatordesignwithPMbandwidthandoffsetcriteriaLabel.FontWeight = 'bold';
            app.CompensatordesignwithPMbandwidthandoffsetcriteriaLabel.Layout.Row = 1;
            app.CompensatordesignwithPMbandwidthandoffsetcriteriaLabel.Layout.Column = [1 2];
            app.CompensatordesignwithPMbandwidthandoffsetcriteriaLabel.Text = 'Compensator design with PM, bandwidth and offset criteria';

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

            % Create UpdateplotsButton
            app.UpdateplotsButton = uibutton(app.GridLayout3, 'push');
            app.UpdateplotsButton.ButtonPushedFcn = createCallbackFcn(app, @UpdateplotsButtonPushed, true);
            app.UpdateplotsButton.WordWrap = 'on';
            app.UpdateplotsButton.BackgroundColor = [1 0.2 0.702];
            app.UpdateplotsButton.FontSize = 18;
            app.UpdateplotsButton.FontWeight = 'bold';
            app.UpdateplotsButton.Layout.Row = 1;
            app.UpdateplotsButton.Layout.Column = 1;
            app.UpdateplotsButton.Text = 'Update plots';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'0.4x', '1x'};
            app.GridLayout4.RowHeight = {'1x', '1x', '1x'};
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

            % Create SecondorderDropDownLabel
            app.SecondorderDropDownLabel = uilabel(app.GridLayout4);
            app.SecondorderDropDownLabel.HorizontalAlignment = 'right';
            app.SecondorderDropDownLabel.WordWrap = 'on';
            app.SecondorderDropDownLabel.FontWeight = 'bold';
            app.SecondorderDropDownLabel.Layout.Row = 2;
            app.SecondorderDropDownLabel.Layout.Column = 1;
            app.SecondorderDropDownLabel.Text = 'Second order';

            % Create SecondorderDropDown
            app.SecondorderDropDown = uidropdown(app.GridLayout4);
            app.SecondorderDropDown.Items = {'2/[s(s+1)]', '8/[(s+1)(s+2)]', '0.4/[(s+0.2)(s+0.1)]', '1/[(s^2+0.2s+1)]', '20/[(s^2+s+10)]', '0.1/[(s^2+0.2s+0.03)]'};
            app.SecondorderDropDown.ValueChangedFcn = createCallbackFcn(app, @SecondorderDropDownValueChanged, true);
            app.SecondorderDropDown.Layout.Row = 2;
            app.SecondorderDropDown.Layout.Column = 2;
            app.SecondorderDropDown.ClickedFcn = createCallbackFcn(app, @SecondorderDropDownClicked, true);
            app.SecondorderDropDown.Value = '2/[s(s+1)]';

            % Create HighorderDropDownLabel
            app.HighorderDropDownLabel = uilabel(app.GridLayout4);
            app.HighorderDropDownLabel.HorizontalAlignment = 'right';
            app.HighorderDropDownLabel.WordWrap = 'on';
            app.HighorderDropDownLabel.FontWeight = 'bold';
            app.HighorderDropDownLabel.Layout.Row = 3;
            app.HighorderDropDownLabel.Layout.Column = 1;
            app.HighorderDropDownLabel.Text = 'High order';

            % Create HighorderDropDown
            app.HighorderDropDown = uidropdown(app.GridLayout4);
            app.HighorderDropDown.Items = {'2/[s(s+1)(s+2)]', '20/[(s+1)(s+2)(s+4)]', '5(s+2)/[s(s+1)(s+4)]', '5(s+4)/[(s+1)(s+1)(s+2)]', '5(s+2)/[(s+1)(s^2+0.4s+16)]'};
            app.HighorderDropDown.ValueChangedFcn = createCallbackFcn(app, @HighorderDropDownValueChanged, true);
            app.HighorderDropDown.Layout.Row = 3;
            app.HighorderDropDown.Layout.Column = 2;
            app.HighorderDropDown.ClickedFcn = createCallbackFcn(app, @HighorderDropDownClicked, true);
            app.HighorderDropDown.Value = '2/[s(s+1)(s+2)]';

            % Create DetailedanalysisoffirstordermodelparametersPanel
            app.DetailedanalysisoffirstordermodelparametersPanel = uipanel(app.GridLayout);
            app.DetailedanalysisoffirstordermodelparametersPanel.AutoResizeChildren = 'off';
            app.DetailedanalysisoffirstordermodelparametersPanel.TitlePosition = 'centertop';
            app.DetailedanalysisoffirstordermodelparametersPanel.Title = 'Detailed analysis of margins, offset  and closed-loop behaviour (Proportional, Lag, Lead and Lead-lag)  [Ramp targets used if integrators]';
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
            title(app.UIAxes2_2, 'Closed-loop errors')
            xlabel(app.UIAxes2_2, 'Time (s)')
            zlabel(app.UIAxes2_2, 'Z')
            app.UIAxes2_2.FontSize = 14;
            app.UIAxes2_2.Layout.Row = 1;
            app.UIAxes2_2.Layout.Column = 3;

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.GridLayout5);
            app.GridLayout7.ColumnWidth = {'1x', '2.5x'};
            app.GridLayout7.RowHeight = {'1x', '1x', '1x', '1x', '1.6x'};
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

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.ColumnWidth = {'0.4x', '1x'};
            app.GridLayout6.RowHeight = {'1x', '1x', '1x', '1x'};
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
            app.OffsetLabel_2.Text = 'Bandwidth';

            % Create BandwidthSlider
            app.BandwidthSlider = uislider(app.GridLayout6);
            app.BandwidthSlider.Limits = [0 6];
            app.BandwidthSlider.ValueChangedFcn = createCallbackFcn(app, @BandwidthSliderValueChanged, true);
            app.BandwidthSlider.Layout.Row = 3;
            app.BandwidthSlider.Layout.Column = 2;
            app.BandwidthSlider.Value = 1;

            % Create OffsetSliderLabel
            app.OffsetSliderLabel = uilabel(app.GridLayout6);
            app.OffsetSliderLabel.HorizontalAlignment = 'right';
            app.OffsetSliderLabel.FontWeight = 'bold';
            app.OffsetSliderLabel.Layout.Row = 4;
            app.OffsetSliderLabel.Layout.Column = 1;
            app.OffsetSliderLabel.Text = 'Offset (%)';

            % Create OffsetSlider
            app.OffsetSlider = uislider(app.GridLayout6);
            app.OffsetSlider.Limits = [0 30];
            app.OffsetSlider.ValueChangedFcn = createCallbackFcn(app, @OffsetSliderValueChanged, true);
            app.OffsetSlider.Layout.Row = 4;
            app.OffsetSlider.Layout.Column = 2;
            app.OffsetSlider.Value = 10;

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.GridLayout);
            app.GridLayout9.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout9.Layout.Row = 4;
            app.GridLayout9.Layout.Column = 1;
            app.GridLayout9.BackgroundColor = [1 0.8 0.6];

            % Create LeadlagControlparametersLabel
            app.LeadlagControlparametersLabel = uilabel(app.GridLayout9);
            app.LeadlagControlparametersLabel.BackgroundColor = [1 0.502 0.302];
            app.LeadlagControlparametersLabel.HorizontalAlignment = 'center';
            app.LeadlagControlparametersLabel.FontSize = 14;
            app.LeadlagControlparametersLabel.FontWeight = 'bold';
            app.LeadlagControlparametersLabel.Layout.Row = 1;
            app.LeadlagControlparametersLabel.Layout.Column = [1 2];
            app.LeadlagControlparametersLabel.Text = 'Lead-lag Control parameters';

            % Create KpLabel
            app.KpLabel = uilabel(app.GridLayout9);
            app.KpLabel.HorizontalAlignment = 'center';
            app.KpLabel.FontWeight = 'bold';
            app.KpLabel.Layout.Row = 2;
            app.KpLabel.Layout.Column = 1;
            app.KpLabel.Text = 'Kp';

            % Create LeadpolezeroratioLabel
            app.LeadpolezeroratioLabel = uilabel(app.GridLayout9);
            app.LeadpolezeroratioLabel.HorizontalAlignment = 'center';
            app.LeadpolezeroratioLabel.FontWeight = 'bold';
            app.LeadpolezeroratioLabel.Layout.Row = 3;
            app.LeadpolezeroratioLabel.Layout.Column = 1;
            app.LeadpolezeroratioLabel.Text = 'Lead pole/zero ratio';

            % Create LagzeropoleratioLabel
            app.LagzeropoleratioLabel = uilabel(app.GridLayout9);
            app.LagzeropoleratioLabel.HorizontalAlignment = 'center';
            app.LagzeropoleratioLabel.FontWeight = 'bold';
            app.LagzeropoleratioLabel.Layout.Row = 4;
            app.LagzeropoleratioLabel.Layout.Column = 1;
            app.LagzeropoleratioLabel.Text = 'Lag zero/pole ratio';

            % Create Label
            app.Label = uilabel(app.GridLayout9);
            app.Label.HorizontalAlignment = 'center';
            app.Label.Layout.Row = 2;
            app.Label.Layout.Column = 2;
            app.Label.Text = '1';

            % Create Label_3
            app.Label_3 = uilabel(app.GridLayout9);
            app.Label_3.HorizontalAlignment = 'center';
            app.Label_3.Layout.Row = 3;
            app.Label_3.Layout.Column = 2;
            app.Label_3.Text = '1';

            % Create Label_2
            app.Label_2 = uilabel(app.GridLayout9);
            app.Label_2.HorizontalAlignment = 'center';
            app.Label_2.Layout.Row = 4;
            app.Label_2.Layout.Column = 2;
            app.Label_2.Text = '1';

            % Create GridLayout11
            app.GridLayout11 = uigridlayout(app.GridLayout);
            app.GridLayout11.RowHeight = {'1.5x', '1x', '1x'};
            app.GridLayout11.Layout.Row = [2 4];
            app.GridLayout11.Layout.Column = [2 3];

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout11);
            title(app.UIAxes, 'Bode gain diagrams')
            xlabel(app.UIAxes, 'Frequency (rad/s)')
            ylabel(app.UIAxes, 'dB')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.FontSize = 14;
            app.UIAxes.Layout.Row = 1;
            app.UIAxes.Layout.Column = [1 2];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.GridLayout11);
            title(app.UIAxes_2, 'Phase diagram and phase margin (PM)')
            xlabel(app.UIAxes_2, 'Frequency (rad/s)')
            ylabel(app.UIAxes_2, 'Degrees')
            zlabel(app.UIAxes_2, 'Z')
            app.UIAxes_2.FontSize = 14;
            app.UIAxes_2.Layout.Row = [2 3];
            app.UIAxes_2.Layout.Column = [1 2];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = lead_lag_design_criteria

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

