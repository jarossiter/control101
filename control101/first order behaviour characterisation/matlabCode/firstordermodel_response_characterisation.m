classdef firstordermodel_response_characterisation < matlab.apps.AppBase
    %FIRSTORDERMODEL_RESPONSE_CHARACTERISATION
    %   File written by J.A.Rossiter, University of Sheffield  
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   
    %   A simple interface to illustrate the significance of time constant
    %   and gain to the step response for a 1st order model.
    %   
    %   Some notes and engineering background are in the partner
    %   livescript file:   
    %   firstordermodel_response_characterisation_manual.mlx
    %   
    %   A group of similar files can be downloaded through MATLAB
    %   add-ons with the toolbox name:  control101
    %     
    %      
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   %%%%%%%%%%%%  FILE ORGANISATION
    %   
    %   A section with a single core subfunction doing the core
    %   computations by collecting model parameters and producing the plot.
    %   
    %       
    %   Separate subfunctions ensure the sliders only return integers (for
    %   simplicity) and manage window resizing.

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure           matlab.ui.Figure
        GridLayout         matlab.ui.container.GridLayout
        GridLayout6        matlab.ui.container.GridLayout
        EnteryourestimatesofthemodelparametersfromtheplotbelowLabel_3  matlab.ui.control.Label
        ODEEditField       matlab.ui.control.EditField
        ODEEditFieldLabel  matlab.ui.control.Label
        CurrentmodelLabel  matlab.ui.control.Label
        GridLayout4        matlab.ui.container.GridLayout
        x0Slider           matlab.ui.control.Slider
        x0Label            matlab.ui.control.Label
        EnteryourestimatesofthemodelparametersfromtheplotbelowLabel_2  matlab.ui.control.Label
        EnteryourestimatesofthemodelparametersfromtheplotbelowLabel  matlab.ui.control.Label
        CSlider            matlab.ui.control.Slider
        CSliderLabel       matlab.ui.control.Label
        TSlider            matlab.ui.control.Slider
        TSliderLabel       matlab.ui.control.Label
        GridLayout2        matlab.ui.container.GridLayout
        stordermodelunitstepresponsesTdxdtxCff1orXsCTs1FsFs1sLabel  matlab.ui.control.Label
        Image              matlab.ui.control.Image
        UIAxes             matlab.ui.control.UIAxes
    end

    
    % The next section defines all the core variables used in the code and
    % that it may be convenient to have available in the various
    % subfunctions
    properties (Access = private)
        originalsize     % product of width and height for font sizing

        endtime=30   % simulation time
        
    end
    
    methods (Access = private)
      
   % This subfunction creates the plot     
    function updatefigure(app)

        % Update model text
        K=app.CSlider.Value;
        T = app.TSlider.Value;
        x0 = app.x0Slider.Value;
        app.ODEEditField.Value = [num2str(T),...
                'dx/dt + x(t) = ',num2str(K),'u(t); x(0) = ',...
                num2str(x0)];
        

        % Find and plot the step response
        app.endtime = 4*T;
        syms x(t) t
        Dx = diff(x);
        t= linspace(0,app.endtime,101);
        xt = dsolve(T*Dx+x == K,x(0)==x0);
        y = subs(xt,t);
        upper = max([x0,K]);
        lower = min([x0,K]);

        plot(app.UIAxes,t,y,'Linewidth',3);
        hold(app.UIAxes,'on')
        xlim(app.UIAxes,[0,app.endtime]);
        grid(app.UIAxes,'on')
       

        % Add horizontal and vertical lines which characterise a first order
        % response and suitable text defining the lines  
        line63 = x0 + (K-x0)*0.63;
        line86 = x0 + (K-x0)*0.86;
        line95 = x0 + (K-x0)*0.95;
        Tmarker = x0 + 0.1*(K-x0);
        plot(app.UIAxes,[0 app.endtime],[1,1]*line63,'r--','Linewidth',2);
        plot(app.UIAxes,[T,T],[lower,upper],'r--','Linewidth',2);
        plot(app.UIAxes,[0 app.endtime],[1 1]*line86,'g--','Linewidth',2);
        plot(app.UIAxes,[2*T,2*T],[lower,upper],'g--','Linewidth',2);
        plot(app.UIAxes,[0 app.endtime],[1 1]*line95,'m--','Linewidth',2);
        plot(app.UIAxes,[3*T,3*T],[lower,upper],'m--','Linewidth',2);
        plot(app.UIAxes,[0 app.endtime],[1,1]*K,'k--','Linewidth',3);             
        plot(app.UIAxes,[0,T],[app.x0Slider.Value,K],'c--','Linewidth',2);
        text(app.UIAxes,T,Tmarker,'T sec.','Fontsize',24);
        text(app.UIAxes,2*T,Tmarker,'2T sec.','Fontsize',24);
        text(app.UIAxes,3*T,Tmarker,'3T sec.','Fontsize',24);
        text(app.UIAxes,0.5,line63,'63%','Fontsize',24);
        text(app.UIAxes,0.5,line86,'86%','Fontsize',24);
        text(app.UIAxes,0.5,line95,'95%','Fontsize',24);
        text(app.UIAxes,0.5,K,'Steady-state','Fontsize',24);
        
        hold(app.UIAxes,'off')

    end  % end of updatefigure subfunction

    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % resize to be in middle of  the window
            movegui(app.UIFigure)
            
            % Open the manual
            if exist('firstordermodels_response_characterisation_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open firstordermodels_response_characterisation_mycopy.mlx
            else            
                p1 = which('firstordermodels_response_characterisation_manual.mlx');
                p2 = strcat(pwd,'/firstordermodels_response_characterisation_mycopy.mlx');
                copyfile(p1,p2)                
                open firstordermodels_response_characterisation_mycopy.mlx
                clear p1 p2
            end
            
            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);

            updatefigure(app)

            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
            theme(app.UIFigure,"light")
            end

            
        end

        % Value changed function: CSlider
        function CSliderValueChanged(app, event)
            value = app.CSlider.Value;
            value = round(value,0);
            if value<2; value=2;end;
            app.CSlider.Value=value;
            updatefigure(app)
            
        end

        % Value changed function: TSlider
        function TSliderValueChanged(app, event)
            value = app.TSlider.Value;
            value=round(value,0); 
            if value<2; value =2;end
            app.TSlider.Value=value;
            updatefigure(app)
            
        end

        % Value changed function: x0Slider
        function x0SliderValueChanged(app, event)
            value = app.x0Slider.Value;
            value=round(value,0); 
            app.x0Slider.Value=value;
            updatefigure(app)
            
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
            app.UIFigure.Position = [100 100 1193 741];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1.1x', '2x'};
            app.GridLayout.RowHeight = {'0.4x', '1.4x', '0.8x'};

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Unit step response for current model')
            xlabel(app.UIAxes, 'Seconds')
            ylabel(app.UIAxes, 'x(t)')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.FontSize = 16;
            app.UIAxes.Layout.Row = [2 3];
            app.UIAxes.Layout.Column = 2;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = [1 2];
            app.GridLayout2.BackgroundColor = [0.6 1 1];

            % Create Image
            app.Image = uiimage(app.GridLayout2);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 3;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'UoSlogo.png');

            % Create stordermodelunitstepresponsesTdxdtxCff1orXsCTs1FsFs1sLabel
            app.stordermodelunitstepresponsesTdxdtxCff1orXsCTs1FsFs1sLabel = uilabel(app.GridLayout2);
            app.stordermodelunitstepresponsesTdxdtxCff1orXsCTs1FsFs1sLabel.BackgroundColor = [0 1 1];
            app.stordermodelunitstepresponsesTdxdtxCff1orXsCTs1FsFs1sLabel.HorizontalAlignment = 'center';
            app.stordermodelunitstepresponsesTdxdtxCff1orXsCTs1FsFs1sLabel.WordWrap = 'on';
            app.stordermodelunitstepresponsesTdxdtxCff1orXsCTs1FsFs1sLabel.FontSize = 24;
            app.stordermodelunitstepresponsesTdxdtxCff1orXsCTs1FsFs1sLabel.FontWeight = 'bold';
            app.stordermodelunitstepresponsesTdxdtxCff1orXsCTs1FsFs1sLabel.Layout.Row = 1;
            app.stordermodelunitstepresponsesTdxdtxCff1orXsCTs1FsFs1sLabel.Layout.Column = [1 2];
            app.stordermodelunitstepresponsesTdxdtxCff1orXsCTs1FsFs1sLabel.Text = {'1st order model unit step responses: '; '{T(dx/dt) + x = C f,  f=1} or {X(s) = [C/(Ts+1)] F(s), F(s)=1/s}'};

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'0.3x', '1x'};
            app.GridLayout4.RowHeight = {'1x', '1.4x', '1x', '1x', '1x'};
            app.GridLayout4.Layout.Row = 2;
            app.GridLayout4.Layout.Column = 1;
            app.GridLayout4.BackgroundColor = [0.902 1 0.502];

            % Create TSliderLabel
            app.TSliderLabel = uilabel(app.GridLayout4);
            app.TSliderLabel.HorizontalAlignment = 'center';
            app.TSliderLabel.FontSize = 24;
            app.TSliderLabel.FontWeight = 'bold';
            app.TSliderLabel.Layout.Row = 3;
            app.TSliderLabel.Layout.Column = 1;
            app.TSliderLabel.Text = 'T';

            % Create TSlider
            app.TSlider = uislider(app.GridLayout4);
            app.TSlider.Limits = [0 10];
            app.TSlider.MajorTicks = [0 1 2 3 4 5 6 7 8 9 10];
            app.TSlider.ValueChangedFcn = createCallbackFcn(app, @TSliderValueChanged, true);
            app.TSlider.MinorTicks = [0 100 200 300 400 500 600 700 800 900 1000];
            app.TSlider.FontSize = 24;
            app.TSlider.Layout.Row = 3;
            app.TSlider.Layout.Column = 2;
            app.TSlider.Value = 6;

            % Create CSliderLabel
            app.CSliderLabel = uilabel(app.GridLayout4);
            app.CSliderLabel.HorizontalAlignment = 'center';
            app.CSliderLabel.FontSize = 24;
            app.CSliderLabel.FontWeight = 'bold';
            app.CSliderLabel.Layout.Row = 4;
            app.CSliderLabel.Layout.Column = 1;
            app.CSliderLabel.Text = 'C';

            % Create CSlider
            app.CSlider = uislider(app.GridLayout4);
            app.CSlider.Limits = [0 10];
            app.CSlider.MajorTicks = [0 1 2 3 4 5 6 7 8 9 10];
            app.CSlider.ValueChangedFcn = createCallbackFcn(app, @CSliderValueChanged, true);
            app.CSlider.MinorTicks = [0 10 20 30 40 50];
            app.CSlider.FontSize = 24;
            app.CSlider.Layout.Row = 4;
            app.CSlider.Layout.Column = 2;
            app.CSlider.Value = 8;

            % Create EnteryourestimatesofthemodelparametersfromtheplotbelowLabel
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel = uilabel(app.GridLayout4);
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel.BackgroundColor = [1 1 0.0667];
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel.HorizontalAlignment = 'center';
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel.WordWrap = 'on';
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel.FontSize = 24;
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel.FontWeight = 'bold';
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel.Layout.Row = 1;
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel.Layout.Column = [1 2];
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel.Text = 'Enter your choices of the model parameters in the sliders below';

            % Create EnteryourestimatesofthemodelparametersfromtheplotbelowLabel_2
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel_2 = uilabel(app.GridLayout4);
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel_2.WordWrap = 'on';
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel_2.FontSize = 18;
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel_2.FontWeight = 'bold';
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel_2.Layout.Row = 2;
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel_2.Layout.Column = [1 2];
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel_2.Text = 'The step response is updated automatically and appended with vertical/horizontal lines showing the core characterisation.';

            % Create x0Label
            app.x0Label = uilabel(app.GridLayout4);
            app.x0Label.HorizontalAlignment = 'center';
            app.x0Label.FontSize = 24;
            app.x0Label.FontWeight = 'bold';
            app.x0Label.Layout.Row = 5;
            app.x0Label.Layout.Column = 1;
            app.x0Label.Text = 'x(0)';

            % Create x0Slider
            app.x0Slider = uislider(app.GridLayout4);
            app.x0Slider.Limits = [-5 5];
            app.x0Slider.MajorTicks = [-5 -4 -3 -2 -1 0 1 2 3 4 5];
            app.x0Slider.MajorTickLabels = {'-5', '-4', '-3', '-2', '-1', '0', '1', '2', '3', '4', '5'};
            app.x0Slider.ValueChangedFcn = createCallbackFcn(app, @x0SliderValueChanged, true);
            app.x0Slider.FontSize = 24;
            app.x0Slider.Layout.Row = 5;
            app.x0Slider.Layout.Column = 2;
            app.x0Slider.Value = -2;

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.ColumnWidth = {'0.3x', '1x'};
            app.GridLayout6.RowHeight = {'0.7x', '1x', '1.1x'};
            app.GridLayout6.Layout.Row = 3;
            app.GridLayout6.Layout.Column = 1;
            app.GridLayout6.BackgroundColor = [1 0.6 0.8];

            % Create CurrentmodelLabel
            app.CurrentmodelLabel = uilabel(app.GridLayout6);
            app.CurrentmodelLabel.HorizontalAlignment = 'center';
            app.CurrentmodelLabel.FontSize = 24;
            app.CurrentmodelLabel.FontWeight = 'bold';
            app.CurrentmodelLabel.Layout.Row = 1;
            app.CurrentmodelLabel.Layout.Column = [1 2];
            app.CurrentmodelLabel.Text = 'Current model';

            % Create ODEEditFieldLabel
            app.ODEEditFieldLabel = uilabel(app.GridLayout6);
            app.ODEEditFieldLabel.BackgroundColor = [1 0.2 0.702];
            app.ODEEditFieldLabel.HorizontalAlignment = 'center';
            app.ODEEditFieldLabel.FontSize = 24;
            app.ODEEditFieldLabel.Layout.Row = 2;
            app.ODEEditFieldLabel.Layout.Column = 1;
            app.ODEEditFieldLabel.Text = 'ODE';

            % Create ODEEditField
            app.ODEEditField = uieditfield(app.GridLayout6, 'text');
            app.ODEEditField.HorizontalAlignment = 'center';
            app.ODEEditField.FontSize = 18;
            app.ODEEditField.FontWeight = 'bold';
            app.ODEEditField.BackgroundColor = [1 0.2 0.702];
            app.ODEEditField.Layout.Row = 2;
            app.ODEEditField.Layout.Column = 2;
            app.ODEEditField.Value = 'Initialise';

            % Create EnteryourestimatesofthemodelparametersfromtheplotbelowLabel_3
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel_3 = uilabel(app.GridLayout6);
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel_3.WordWrap = 'on';
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel_3.FontSize = 18;
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel_3.FontWeight = 'bold';
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel_3.Layout.Row = 3;
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel_3.Layout.Column = [1 2];
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel_3.Text = {'Note how following lines always intercept irrespective of T, C and x(0): '; '63% and T, 86% and 2T, 95% and 3T.'};

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = firstordermodel_response_characterisation

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

