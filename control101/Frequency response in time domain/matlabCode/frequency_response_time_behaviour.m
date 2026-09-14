classdef frequency_response_time_behaviour < matlab.apps.AppBase
    %FREQUENCY_RESPONSE_TIME_BEHAVIOUR
    %   File written by J.A.Rossiter, University of Sheffield  
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   
    %   A simple interface to illustrate the concept of frequency response
    %   for linear systems
    %   
    %   Users can select from a number of predefined systems: 1st , 2nd and
    %   3rd order. These have a variety of time constants and also some
    %   have under-damped modes to illustrate resonance.
    %   
    %   
    %   Some notes and engineering background are in the partner
    %   livescript file:    frequency_response_behaviour_manual.mlx
    %   A group of similar files can be downloaded through MATLAB
    %   add-ons with the toolbox name:  control101

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        GridLayout                  matlab.ui.container.GridLayout
        GridLayout6                 matlab.ui.container.GridLayout
        FrequencySlider             matlab.ui.control.Slider
        FrequencySliderLabel        matlab.ui.control.Label
        FrequencyofinputradsLabel   matlab.ui.control.Label
        DetailedanalysisoffirstordermodelparametersPanel  matlab.ui.container.Panel
        GridLayout5                 matlab.ui.container.GridLayout
        GridLayout7                 matlab.ui.container.GridLayout
        phiLabel                    matlab.ui.control.Label
        t2Label                     matlab.ui.control.Label
        t1Label                     matlab.ui.control.Label
        ALabel                      matlab.ui.control.Label
        GsLabel                     matlab.ui.control.Label
        CurrentmodelLabel           matlab.ui.control.Label
        CorrectphaseshiftdegLabel   matlab.ui.control.Label
        OutputpeaktimeLabel         matlab.ui.control.Label
        InputpeaktimeLabel          matlab.ui.control.Label
        MagnitudeofoutputLabel      matlab.ui.control.Label
        UIAxes2_2                   matlab.ui.control.UIAxes
        UIAxes2                     matlab.ui.control.UIAxes
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
        UpdatefiguresanddataButton  matlab.ui.control.Button
        GridLayout2                 matlab.ui.container.GridLayout
        Image                       matlab.ui.control.Image
        FrequencyresponseoflinearmodelsLabel  matlab.ui.control.Label
        UIAxes                      matlab.ui.control.UIAxes
    end

    
    
    
    % The next section defines all the core variables used in the code and
    % that it may be convenient to have available in the various
    % subfunctions
    properties (Access = private)
        originalsize     % product of width and height for font sizing

        
        G   % model no delay
        Gd  % Model with delay
        u   % sinsoidal signal
        y   % response no delay
        yd  % response with delay
        omega % frequency
        tvec  % time vector for plotting
        endtime=15;  % default simulation tome
        nperiods;    % number of periods in simulation time
        numExample   % system numerator
        denExample   % system denominator

          
    end
    
    methods (Access = private)
        


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%  Down load data from sliders and create responses
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function app = getresponses(app)
       
       % collect data from sliders
       delay = app.DelaySlider.Value;
       app.Gd = app.G*tf(1,1,'iodelay',delay);
       app.omega = app.FrequencySlider.Value;
       singleperiod  = 2*pi/app.omega; 
       app.nperiods = ceil(app.endtime/singleperiod); 
       app.endtime = app.nperiods*singleperiod;
       app.tvec = linspace(0,app.endtime,80*app.nperiods + 1);  %% vector of time instants for the plot
       app.u=sin(app.omega*app.tvec);     %%% input signal
       app.y=lsim(app.G,app.u,app.tvec);
       app.yd=lsim(app.Gd,app.u,app.tvec);
            
    end   % end of getresponses subfunction


       % manage the plotting and the zoom on a later part to discern the
       % differences in magnitude and phase
        function app = plotresponses(app)
            % Main plot
            hold(app.UIAxes,'off')
            plot(app.UIAxes,app.tvec,app.y,'b',app.tvec,app.u,app.tvec,app.yd,'g--');
            title(app.UIAxes,['Output response y(t) of G(s) with input u(t)=sin(wt) for w = ',num2str(app.omega),' rad/s'])
            xlabel(app.UIAxes,'time(s)')
            
            grid(app.UIAxes,'on')
            hold(app.UIAxes,'on')
 
            % Zoom on the input
            % computer zoom parameters for the plots
            lefttime=(app.nperiods-2)*80;arrowtime=(app.nperiods-1.75)*80;
            righttime=(app.nperiods-1)*80; mid = (app.nperiods-1.8)*80;
            plot(app.UIAxes,app.tvec(lefttime)*[1,1],[-1 1],'k--','linewidth',2)
            plot(app.UIAxes,app.tvec(righttime)*[1,1],[-1 1],'k--','linewidth',2)
            legend(app.UIAxes, 'y(t)','u(t)','y(t) with delay','zoom zone','zoom zone')

            pts = lefttime:righttime;
            ymax = max(app.y(pts)); ymin = min(app.y(pts));
            [mag,phase]=bode(app.G,app.omega);
            shift = phase*pi/(app.omega(:)*180);
            [magd,phased]=bode(app.Gd,app.omega);
            shiftd = phased*pi/(app.omega(:)*180);
            
            %% Display of core numerical answers
            app.ALabel.Text = ['A = ',num2str((ymax-ymin)/2)];
            app.t1Label.Text = ['t1 = ',num2str(app.tvec(arrowtime))];
            app.t2Label.Text = ['t2 = ',num2str(app.tvec(arrowtime)-shift),',   ',num2str(app.tvec(arrowtime)-shiftd)];
            app.phiLabel.Text = ['$\phi = $',num2str(phase),',   ',num2str(phased)];
            
           
            % zoomed figure on the input
            hold(app.UIAxes2,'off')
            plot(app.UIAxes2,app.tvec(pts),app.y(pts),'b',app.tvec(pts),app.u(pts),app.tvec,app.yd,'g--');
            grid(app.UIAxes2,'on');
            hold(app.UIAxes2,'on')
            
            ylim(app.UIAxes2,[-1.1,1.1]);
            xlim(app.UIAxes2,[app.tvec(pts(1)),app.tvec(pts(end))])
            x=app.tvec(arrowtime+10);
            y=0.2;
            vx = app.tvec(arrowtime)-app.tvec(arrowtime+10);
            vy = 1 - 0.2;
            quiver(app.UIAxes2,x,y,vx,vy,1,'k','filled','LineWidth',2,'MaxHeadSize',50000,'AutoScale','off'); 
            text(app.UIAxes2,app.tvec(arrowtime+10),0.1,'t1','fontsize',18)
            legend(app.UIAxes2,'y(t)','u(t)','Delayed','t1')
            
            % zoomed figure on the output
            hold(app.UIAxes2_2,'off')
            plot(app.UIAxes2_2,app.tvec(pts),app.y(pts),'b',app.tvec(pts),app.u(pts),app.tvec(pts),app.yd(pts),'g--');
            grid(app.UIAxes2_2,'on');
            hold(app.UIAxes2_2,'on')
            ylim(app.UIAxes2_2,[ymin-0.1,ymax+0.1])
           
            x=app.tvec(mid);
            y=ymin;
            vx = 0;
            vy = ymax-ymin;
            quiver(app.UIAxes2_2,x,y,vx,vy,1,'m','filled','LineWidth',2,'MaxHeadSize',50000,'AutoScale','off'); 
            text(app.UIAxes2_2,app.tvec(mid+2),(ymax+ymin)/2,'2A','fontsize',18)
           
            x=app.tvec(arrowtime-10)-shift;
            y=(ymax+ymin)/2;
            vx = app.tvec(arrowtime)-app.tvec(arrowtime-10);
            vy = (ymax-ymin)/2;
            quiver(app.UIAxes2_2,x,y,vx,vy,1,'k','filled','LineWidth',2,'MaxHeadSize',50000,'AutoScale','off'); 
            legend(app.UIAxes2_2,'y(t)','u(t)','Delayed','2A','t2')
            text(app.UIAxes2_2,app.tvec(arrowtime-10)-shift,(0.45*ymax+0.55*ymin),'t2','fontsize',18)
            

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



        end  % end of sub functions section
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
            % resize to be in middle of  the window
            movegui(app.UIFigure)

            % Open the manual
            if exist('frequency_response_time_behaviour_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open frequency_response_time_behaviour_mycopy.mlx
            else           
                p1 = which('frequency_response_time_behaviour_manual.mlx');
                p2 = strcat(pwd,'/frequency_response_time_behaviour_mycopy.mlx');
                copyfile(p1,p2)           
                open frequency_response_time_behaviour_mycopy.mlx
            end

            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);

            app.G = tf(1,[1 1]);
            app.numExample = 1;
            app.denExample = [1 1];
            updateTransferFunctionRender(app);
            app = getresponses(app);
            app = plotresponses(app);
            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
            theme(app.UIFigure,"light")
            end


        end

        % Button pushed function: UpdatefiguresanddataButton
        function UpdatefiguresanddataButtonPushed(app, event)
            
          

            app = getresponses(app);
            app = plotresponses(app);   % manage the display

           

        end

        % Value changed function: FrequencySlider
        function FrequencySliderValueChanged(app, event)
            value = app.FrequencySlider.Value;
            value = round(value,0);
            if value<1; value = 1;end
            app.FrequencySlider.Value=value;
            
            
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
            value = app.FirstorderDropDown.Value;
            switch value
                case '1/s'; 
                    app.G =tf(1,[1 0]);
                    app.numExample =1;
                    app.denExample = [1 0];
                    app.endtime =15;
                case '1/(s+1)'; 
                    app.G = tf(1,[1 1]);
                    app.numExample =1;
                    app.denExample = [1 1];
                    app.endtime =15;
                case '(s+1)/s'; 
                    app.G = tf([1 1],[1 0]);
                    app.numExample =[1 1];
                    app.denExample = [1 0];
                    app.endtime =15;
                case '(s+1)/(s+3)'; 
                    app.G = tf([1 1],[1 3]);
                    app.numExample = [1 1];
                    app.denExample = [1 3];
                    app.endtime =15;
                case '0.5/(s+0.1)'; 
                    app.G = tf([0.5],[1 0.1]);
                    app.numExample = [0.5];
                    app.denExample = [1 0.1];
                    app.endtime =55;
                    
            end
            updateTransferFunctionRender(app);

        end

        % Value changed function: DelaySlider
        function DelaySliderValueChanged(app, event)
            value = app.DelaySlider.Value;
            value = round(value,1);
            app.DelaySlider.Value=value;
            updateTransferFunctionRender(app);
            
        end

        % Value changed function: SecondorderDropDown
        function SecondorderDropDownValueChanged(app, event)
            value = app.SecondorderDropDown.Value;
            switch value
                case '1/[s(s+1)]'; 
                    app.G =tf(1,[1 1 0]);
                    app.numExample =1;
                    app.denExample = [1 1 0];
                    app.endtime =15;
                case '2/[(s+1)(s+2)]'; 
                    app.G = tf(2,[1 3 2]);
                    app.numExample =2;
                    app.denExample = [1 3 2];
                    app.endtime =15;
                case '2(s+1)/[s(s+3)]'; 
                    app.G = tf(2*[1 1],[1 3 0]);
                    app.numExample =2*[1 1];
                    app.denExample = [1 3 0];
                    app.endtime =15;
                case '10(s+1)/[(s+3)(s+5)]'; 
                    app.G = tf(10*[1 1],[1 8 15]);
                    app.numExample = 10*[1 1];
                    app.denExample = [1 8 15];
                    app.endtime =15;
                case '1/[(s+0.2)(s+0.1)]'; 
                    app.G = tf([1],[1 0.3 0.02]);
                    app.numExample = 1;
                    app.denExample = [1 0.3 0.02];
                    app.endtime =55;
                case '1/[(s^2+0.2s+1)]'; 
                    app.G = tf([1],[1 0.2 1]);
                    app.numExample = 1;
                    app.denExample = [1 0.2 1];
                    app.endtime =65;
                case '10/[(s^2+s+10)]'; 
                    app.G = tf([10],[1 1 10]);
                    app.numExample = 10;
                    app.denExample = [1 1 10];
                    app.endtime =20;
                case '2.5/[(s^2+0.2s+0.03)]'; 
                    app.G = tf([2.5],[1 0.2 0.03]);
                    app.numExample = 2.5;
                    app.denExample = [1 .2 0.03];
                    app.endtime =55;
                    
            end
            updateTransferFunctionRender(app);
        end

        % Value changed function: HighorderDropDown
        function HighorderDropDownValueChanged(app, event)
            value = app.HighorderDropDown.Value;
            
            switch value
                case '2/[s(s+1)(s+2)]'; 
                    app.G =tf(2,[1 3 2 0]);
                    app.numExample =1;
                    app.denExample = [1 3 2 0];
                    app.endtime =15;
                case '6/[(s+1)(s+2)(s+4)]'; 
                    app.G = tf(6,[1 7 14 8]);
                    app.numExample =6;
                    app.denExample = [1 7 14 8];
                    app.endtime =15;
                case '3(s+2)/[s(s+1)(s+4)]'; 
                    app.G = tf(3*[1 2],[1 5 4 0]);
                    app.numExample =3*[1 2];
                    app.denExample = [1 5 4 0];
                    app.endtime =15;
                case '0.5(s+4)/[(s+1)(s+1)(s+2)]'; 
                    app.G = tf(0.5*[1 4],[1 4 5 2]);
                    app.numExample = 0.5*[1 4];
                    app.denExample = [1 4 5 2];
                    app.endtime =15;
               case '6(s+2)/[(s+1)(s^2+0.4s+16)]'; 
                    app.G = tf(6*[1 2],[1 1.4 16.4 16]);
                    app.numExample = 6*[1 2];
                    app.denExample = [1 1.4 16.4 16];
                    app.endtime =20;
            end
            
            updateTransferFunctionRender(app);


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

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Time domain behaviour')
            xlabel(app.UIAxes, 'Time (seconds)')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.FontSize = 18;
            app.UIAxes.Layout.Row = [2 3];
            app.UIAxes.Layout.Column = [2 3];

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = [2 3];
            app.GridLayout2.BackgroundColor = [0.6 1 1];

            % Create FrequencyresponseoflinearmodelsLabel
            app.FrequencyresponseoflinearmodelsLabel = uilabel(app.GridLayout2);
            app.FrequencyresponseoflinearmodelsLabel.BackgroundColor = [0 1 1];
            app.FrequencyresponseoflinearmodelsLabel.HorizontalAlignment = 'center';
            app.FrequencyresponseoflinearmodelsLabel.FontSize = 24;
            app.FrequencyresponseoflinearmodelsLabel.FontWeight = 'bold';
            app.FrequencyresponseoflinearmodelsLabel.Layout.Row = 1;
            app.FrequencyresponseoflinearmodelsLabel.Layout.Column = [1 2];
            app.FrequencyresponseoflinearmodelsLabel.Text = 'Frequency response of linear models';

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

            % Create UpdatefiguresanddataButton
            app.UpdatefiguresanddataButton = uibutton(app.GridLayout3, 'push');
            app.UpdatefiguresanddataButton.ButtonPushedFcn = createCallbackFcn(app, @UpdatefiguresanddataButtonPushed, true);
            app.UpdatefiguresanddataButton.WordWrap = 'on';
            app.UpdatefiguresanddataButton.BackgroundColor = [1 0.2 0.702];
            app.UpdatefiguresanddataButton.FontSize = 20;
            app.UpdatefiguresanddataButton.FontWeight = 'bold';
            app.UpdatefiguresanddataButton.Layout.Row = 1;
            app.UpdatefiguresanddataButton.Layout.Column = 1;
            app.UpdatefiguresanddataButton.Text = 'Update figures and data';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'0.4x', '1x'};
            app.GridLayout4.RowHeight = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout4.Layout.Row = 2;
            app.GridLayout4.Layout.Column = 1;
            app.GridLayout4.BackgroundColor = [0.902 1 0.502];

            % Create ChoosemodelLabel
            app.ChoosemodelLabel = uilabel(app.GridLayout4);
            app.ChoosemodelLabel.BackgroundColor = [1 1 0];
            app.ChoosemodelLabel.HorizontalAlignment = 'center';
            app.ChoosemodelLabel.WordWrap = 'on';
            app.ChoosemodelLabel.FontSize = 18;
            app.ChoosemodelLabel.FontWeight = 'bold';
            app.ChoosemodelLabel.Layout.Row = 1;
            app.ChoosemodelLabel.Layout.Column = [1 2];
            app.ChoosemodelLabel.Text = 'Choose model';

            % Create FirstorderDropDownLabel
            app.FirstorderDropDownLabel = uilabel(app.GridLayout4);
            app.FirstorderDropDownLabel.HorizontalAlignment = 'right';
            app.FirstorderDropDownLabel.WordWrap = 'on';
            app.FirstorderDropDownLabel.FontSize = 14;
            app.FirstorderDropDownLabel.FontWeight = 'bold';
            app.FirstorderDropDownLabel.Layout.Row = 2;
            app.FirstorderDropDownLabel.Layout.Column = 1;
            app.FirstorderDropDownLabel.Text = 'First order';

            % Create FirstorderDropDown
            app.FirstorderDropDown = uidropdown(app.GridLayout4);
            app.FirstorderDropDown.Items = {'1/s', '1/(s+1)', '(s+1)/s', '(s+1)/(s+3)', '0.5/(s+0.1)'};
            app.FirstorderDropDown.ValueChangedFcn = createCallbackFcn(app, @FirstorderDropDownValueChanged, true);
            app.FirstorderDropDown.FontSize = 14;
            app.FirstorderDropDown.Layout.Row = 2;
            app.FirstorderDropDown.Layout.Column = 2;
            app.FirstorderDropDown.ClickedFcn = createCallbackFcn(app, @FirstorderDropDownClicked, true);
            app.FirstorderDropDown.Value = '1/s';

            % Create SecondorderDropDownLabel
            app.SecondorderDropDownLabel = uilabel(app.GridLayout4);
            app.SecondorderDropDownLabel.HorizontalAlignment = 'right';
            app.SecondorderDropDownLabel.WordWrap = 'on';
            app.SecondorderDropDownLabel.FontSize = 14;
            app.SecondorderDropDownLabel.FontWeight = 'bold';
            app.SecondorderDropDownLabel.Layout.Row = 3;
            app.SecondorderDropDownLabel.Layout.Column = 1;
            app.SecondorderDropDownLabel.Text = 'Second order';

            % Create SecondorderDropDown
            app.SecondorderDropDown = uidropdown(app.GridLayout4);
            app.SecondorderDropDown.Items = {'1/[s(s+1)]', '2/[(s+1)(s+2)]', '2(s+1)/[s(s+3)]', '10(s+1)/[(s+3)(s+5)]', '1/[(s+0.2)(s+0.1)]', '1/[(s^2+0.2s+1)]', '10/[(s^2+s+10)]', '2.5/[(s^2+0.2s+0.03)]'};
            app.SecondorderDropDown.ValueChangedFcn = createCallbackFcn(app, @SecondorderDropDownValueChanged, true);
            app.SecondorderDropDown.FontSize = 14;
            app.SecondorderDropDown.Layout.Row = 3;
            app.SecondorderDropDown.Layout.Column = 2;
            app.SecondorderDropDown.ClickedFcn = createCallbackFcn(app, @SecondorderDropDownClicked, true);
            app.SecondorderDropDown.Value = '1/[s(s+1)]';

            % Create HighorderDropDownLabel
            app.HighorderDropDownLabel = uilabel(app.GridLayout4);
            app.HighorderDropDownLabel.HorizontalAlignment = 'right';
            app.HighorderDropDownLabel.WordWrap = 'on';
            app.HighorderDropDownLabel.FontSize = 14;
            app.HighorderDropDownLabel.FontWeight = 'bold';
            app.HighorderDropDownLabel.Layout.Row = 4;
            app.HighorderDropDownLabel.Layout.Column = 1;
            app.HighorderDropDownLabel.Text = 'High order';

            % Create HighorderDropDown
            app.HighorderDropDown = uidropdown(app.GridLayout4);
            app.HighorderDropDown.Items = {'2/[s(s+1)(s+2)]', '6/[(s+1)(s+2)(s+4)]', '3(s+2)/[s(s+1)(s+4)]', '0.5(s+4)/[(s+1)(s+1)(s+2)]', '6(s+2)/[(s+1)(s^2+0.4s+16)]'};
            app.HighorderDropDown.ValueChangedFcn = createCallbackFcn(app, @HighorderDropDownValueChanged, true);
            app.HighorderDropDown.FontSize = 14;
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

            % Create DetailedanalysisoffirstordermodelparametersPanel
            app.DetailedanalysisoffirstordermodelparametersPanel = uipanel(app.GridLayout);
            app.DetailedanalysisoffirstordermodelparametersPanel.AutoResizeChildren = 'off';
            app.DetailedanalysisoffirstordermodelparametersPanel.TitlePosition = 'centertop';
            app.DetailedanalysisoffirstordermodelparametersPanel.Title = 'Detailed analysis of gain (A) and phase (phi = w(t1-t2)) in zoom zone:       (ONLY valid if response has no more transients)';
            app.DetailedanalysisoffirstordermodelparametersPanel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.DetailedanalysisoffirstordermodelparametersPanel.Layout.Row = 4;
            app.DetailedanalysisoffirstordermodelparametersPanel.Layout.Column = [1 3];
            app.DetailedanalysisoffirstordermodelparametersPanel.FontWeight = 'bold';
            app.DetailedanalysisoffirstordermodelparametersPanel.FontSize = 18;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.DetailedanalysisoffirstordermodelparametersPanel);
            app.GridLayout5.ColumnWidth = {'1.4x', '1.4x', '1.4x'};
            app.GridLayout5.RowHeight = {'1x'};

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GridLayout5);
            title(app.UIAxes2, 'Zoom on input')
            xlabel(app.UIAxes2, 'Time (s)')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontSize = 18;
            app.UIAxes2.Layout.Row = 1;
            app.UIAxes2.Layout.Column = 2;

            % Create UIAxes2_2
            app.UIAxes2_2 = uiaxes(app.GridLayout5);
            title(app.UIAxes2_2, 'Zoom on output')
            xlabel(app.UIAxes2_2, 'Time (s)')
            zlabel(app.UIAxes2_2, 'Z')
            app.UIAxes2_2.FontSize = 18;
            app.UIAxes2_2.Layout.Row = 1;
            app.UIAxes2_2.Layout.Column = 3;

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.GridLayout5);
            app.GridLayout7.ColumnWidth = {'1x', '2.5x'};
            app.GridLayout7.RowHeight = {'1x', '1x', '1x', '1x', '2x'};
            app.GridLayout7.Layout.Row = 1;
            app.GridLayout7.Layout.Column = 1;

            % Create MagnitudeofoutputLabel
            app.MagnitudeofoutputLabel = uilabel(app.GridLayout7);
            app.MagnitudeofoutputLabel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.MagnitudeofoutputLabel.WordWrap = 'on';
            app.MagnitudeofoutputLabel.FontSize = 14;
            app.MagnitudeofoutputLabel.FontWeight = 'bold';
            app.MagnitudeofoutputLabel.Layout.Row = 1;
            app.MagnitudeofoutputLabel.Layout.Column = 1;
            app.MagnitudeofoutputLabel.Text = 'Magnitude of output';

            % Create InputpeaktimeLabel
            app.InputpeaktimeLabel = uilabel(app.GridLayout7);
            app.InputpeaktimeLabel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.InputpeaktimeLabel.WordWrap = 'on';
            app.InputpeaktimeLabel.FontSize = 14;
            app.InputpeaktimeLabel.FontWeight = 'bold';
            app.InputpeaktimeLabel.Layout.Row = 2;
            app.InputpeaktimeLabel.Layout.Column = 1;
            app.InputpeaktimeLabel.Text = 'Input peak time';

            % Create OutputpeaktimeLabel
            app.OutputpeaktimeLabel = uilabel(app.GridLayout7);
            app.OutputpeaktimeLabel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.OutputpeaktimeLabel.WordWrap = 'on';
            app.OutputpeaktimeLabel.FontSize = 14;
            app.OutputpeaktimeLabel.FontWeight = 'bold';
            app.OutputpeaktimeLabel.Layout.Row = 3;
            app.OutputpeaktimeLabel.Layout.Column = 1;
            app.OutputpeaktimeLabel.Text = 'Output peak time';

            % Create CorrectphaseshiftdegLabel
            app.CorrectphaseshiftdegLabel = uilabel(app.GridLayout7);
            app.CorrectphaseshiftdegLabel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.CorrectphaseshiftdegLabel.WordWrap = 'on';
            app.CorrectphaseshiftdegLabel.FontSize = 14;
            app.CorrectphaseshiftdegLabel.FontWeight = 'bold';
            app.CorrectphaseshiftdegLabel.Layout.Row = 4;
            app.CorrectphaseshiftdegLabel.Layout.Column = 1;
            app.CorrectphaseshiftdegLabel.Text = 'Correct phase shift (deg)';

            % Create CurrentmodelLabel
            app.CurrentmodelLabel = uilabel(app.GridLayout7);
            app.CurrentmodelLabel.BackgroundColor = [0.9294 0.6941 0.1255];
            app.CurrentmodelLabel.HorizontalAlignment = 'center';
            app.CurrentmodelLabel.WordWrap = 'on';
            app.CurrentmodelLabel.FontSize = 24;
            app.CurrentmodelLabel.FontWeight = 'bold';
            app.CurrentmodelLabel.Layout.Row = 5;
            app.CurrentmodelLabel.Layout.Column = 1;
            app.CurrentmodelLabel.Interpreter = 'latex';
            app.CurrentmodelLabel.Text = 'Current model ';

            % Create GsLabel
            app.GsLabel = uilabel(app.GridLayout7);
            app.GsLabel.BackgroundColor = [0.9294 0.6941 0.1255];
            app.GsLabel.HorizontalAlignment = 'center';
            app.GsLabel.FontSize = 18;
            app.GsLabel.FontWeight = 'bold';
            app.GsLabel.Layout.Row = 5;
            app.GsLabel.Layout.Column = 2;
            app.GsLabel.Interpreter = 'latex';
            app.GsLabel.Text = 'G(s)';

            % Create ALabel
            app.ALabel = uilabel(app.GridLayout7);
            app.ALabel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.ALabel.HorizontalAlignment = 'center';
            app.ALabel.WordWrap = 'on';
            app.ALabel.FontSize = 14;
            app.ALabel.FontWeight = 'bold';
            app.ALabel.Layout.Row = 1;
            app.ALabel.Layout.Column = 2;
            app.ALabel.Text = 'A=';

            % Create t1Label
            app.t1Label = uilabel(app.GridLayout7);
            app.t1Label.BackgroundColor = [0.8902 0.7294 0.9882];
            app.t1Label.HorizontalAlignment = 'center';
            app.t1Label.WordWrap = 'on';
            app.t1Label.FontSize = 14;
            app.t1Label.FontWeight = 'bold';
            app.t1Label.Layout.Row = 2;
            app.t1Label.Layout.Column = 2;
            app.t1Label.Text = 't1 =';

            % Create t2Label
            app.t2Label = uilabel(app.GridLayout7);
            app.t2Label.BackgroundColor = [0.8902 0.7294 0.9882];
            app.t2Label.HorizontalAlignment = 'center';
            app.t2Label.FontSize = 14;
            app.t2Label.FontWeight = 'bold';
            app.t2Label.Layout.Row = 3;
            app.t2Label.Layout.Column = 2;
            app.t2Label.Text = 't2 = ';

            % Create phiLabel
            app.phiLabel = uilabel(app.GridLayout7);
            app.phiLabel.BackgroundColor = [0.8902 0.7294 0.9882];
            app.phiLabel.HorizontalAlignment = 'center';
            app.phiLabel.FontSize = 14;
            app.phiLabel.FontWeight = 'bold';
            app.phiLabel.Layout.Row = 4;
            app.phiLabel.Layout.Column = 2;
            app.phiLabel.Interpreter = 'latex';
            app.phiLabel.Text = '$\phi =$';

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.ColumnWidth = {'0.4x', '1x'};
            app.GridLayout6.Layout.Row = 3;
            app.GridLayout6.Layout.Column = 1;
            app.GridLayout6.BackgroundColor = [0.702 1 0.702];

            % Create FrequencyofinputradsLabel
            app.FrequencyofinputradsLabel = uilabel(app.GridLayout6);
            app.FrequencyofinputradsLabel.BackgroundColor = [0 1 0];
            app.FrequencyofinputradsLabel.HorizontalAlignment = 'center';
            app.FrequencyofinputradsLabel.FontSize = 18;
            app.FrequencyofinputradsLabel.FontWeight = 'bold';
            app.FrequencyofinputradsLabel.Layout.Row = 1;
            app.FrequencyofinputradsLabel.Layout.Column = [1 2];
            app.FrequencyofinputradsLabel.Text = 'Frequency of input (rad/s)';

            % Create FrequencySliderLabel
            app.FrequencySliderLabel = uilabel(app.GridLayout6);
            app.FrequencySliderLabel.HorizontalAlignment = 'right';
            app.FrequencySliderLabel.FontSize = 14;
            app.FrequencySliderLabel.Layout.Row = 2;
            app.FrequencySliderLabel.Layout.Column = 1;
            app.FrequencySliderLabel.Text = 'Frequency';

            % Create FrequencySlider
            app.FrequencySlider = uislider(app.GridLayout6);
            app.FrequencySlider.Limits = [0 10];
            app.FrequencySlider.ValueChangedFcn = createCallbackFcn(app, @FrequencySliderValueChanged, true);
            app.FrequencySlider.MinorTicks = [-20 -15 -10 -5 0 5 10 15 20];
            app.FrequencySlider.FontSize = 14;
            app.FrequencySlider.Layout.Row = 2;
            app.FrequencySlider.Layout.Column = 2;
            app.FrequencySlider.Value = 2;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = frequency_response_time_behaviour

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

