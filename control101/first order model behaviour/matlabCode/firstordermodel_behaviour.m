classdef firstordermodel_behaviour < matlab.apps.AppBase
    %FIRSTORDERMODEL_BEHAVIOUR
    %   File written by J.A.Rossiter, University of Sheffield  
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   
    %   A simple interface to practice estimation of time constant and gain
    %   from a step response for a 1st order model.
    %   
    %   Some notes and engineering background are in the partner
    %   livescript file:    firstordermodel_behaviour_manual.mlx
    %   
    %   A group of similar files can be downloaded through MATLAB
    %   add-ons with the toolbox name:  control101
    %     
    %      
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   %%%%%%%%%%%%  FILE ORGANISATION
    %   A section defining the core variables stored in "app"
    %   
    %   A section with subfunctions doing the core computations
    %       i) Define a randomised model and create step response.
    %       ii) Student enters estimates and system creates associated
    %           responses; can iterate to correct answer.
    %       iii) System creates and overlays correct answer on request.
    %       
    %   Separate subfunctions ensure the sliders only return integers (for
    %   simplicity) and manage window resizing.

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        GridLayout6                    matlab.ui.container.GridLayout
        TellmethecorrectanswersButton  matlab.ui.control.Button
        CorrectCEditField              matlab.ui.control.NumericEditField
        CorrectCEditFieldLabel         matlab.ui.control.Label
        CorrectTEditField              matlab.ui.control.NumericEditField
        CorrectTEditFieldLabel         matlab.ui.control.Label
        CheckmyestimatesButton         matlab.ui.control.Button
        GridLayout4                    matlab.ui.container.GridLayout
        EnteryourestimatesofthemodelparametersfromtheplotbelowLabel  matlab.ui.control.Label
        CreatenewrandomexampleButton   matlab.ui.control.Button
        EnterCestimateSlider           matlab.ui.control.Slider
        EnterCestimateSliderLabel      matlab.ui.control.Label
        EnterTestimateSlider           matlab.ui.control.Slider
        EnterTestimateSliderLabel      matlab.ui.control.Label
        GridLayout2                    matlab.ui.container.GridLayout
        stordermodelbehaviourTdxdtxCff1Label  matlab.ui.control.Label
        Image                          matlab.ui.control.Image
        UIAxes                         matlab.ui.control.UIAxes
    end

    
    % The next section defines all the core variables used in the code and
    % that it may be convenient to have available in the various
    % subfunctions
    properties (Access = private)
        originalsize     % product of width and height for font sizing

        legstring=cell(1); % To store legends

        T  % Time constant
        C  % System gain
        y0 % initial condition
        Testimate % user estimate
        Cestimate % user estimate
        runtime   % simulation time
        tt        % time instants used in plot
       
        
    end
    
    methods (Access = private)
      


    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % resize to be in middle of  the window
            movegui(app.UIFigure)
            
            % Open the manual
            if exist('firstordermodel_behaviour_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open firstordermodel_behaviour_mycopy.mlx
            else
                p1 = which('firstordermodel_behaviour_manual.mlx');
                p2 = strcat(pwd,'/firstordermodel_behaviour_mycopy.mlx');
                copyfile(p1,p2)                
                open firstordermodel_behaviour_mycopy.mlx
                clear p1 p2
            end
            
            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);

            % initialise with a random example
            CreatenewrandomexampleButtonPushed(app);

            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
            theme(app.UIFigure,"light")
            end
        end

        % Value changed function: EnterCestimateSlider
        function EnterCestimateSliderValueChanged(app, event)
            value = app.EnterCestimateSlider.Value;
            value = round(value,0);
            if value<1; value=1;end;
            app.EnterCestimateSlider.Value=value;
            
        end

        % Value changed function: EnterTestimateSlider
        function EnterTestimateSliderValueChanged(app, event)
            value = app.EnterTestimateSlider.Value;
            value=round(value,0); 
            if value<1; value =1;end
            app.EnterTestimateSlider.Value=value;
            
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

        % Button pushed function: CreatenewrandomexampleButton
        function CreatenewrandomexampleButtonPushed(app, event)
            
            % reset estimate boxes
            app.CorrectTEditField.Value = 0;
            app.CorrectCEditField.Value = 0;
            
            % create random time constant and gain between 1 and 10
            app.T=round(rand(1)*9+1);
            app.C=round(rand(1)*9+1);
            app.y0=round(rand(1)*19+1)-10;
            if app.y0==app.C;app.y0=-2;app.C=6;end
            app.runtime = 4*app.T;

            % Create step response and plot
            syms y(t);
            Dy = diff(y);
            y=dsolve(app.T*Dy+y == app.C,y(0)==app.y0);
            app.tt=linspace(0,app.runtime,41);
            yt = subs(y,app.tt);
            hold(app.UIAxes,'off')
            app.UIAxes.XGrid='on';
            app.UIAxes.YGrid='on';
            plot(app.UIAxes,app.tt,yt,'-o','linewidth',2); 
            app.legstring = cell(1);
            app.legstring{1} = 'System step response';
            legend(app.UIAxes,app.legstring,'Location','SouthEast')
            hold(app.UIAxes,'on')


        end

        % Button pushed function: CheckmyestimatesButton
        function CheckmyestimatesButtonPushed(app, event)
            % this subfunction reads the user estimates and adds the
            % corresponding step response to the figure
            app.Testimate = app.EnterTestimateSlider.Value;
            app.Cestimate = app.EnterCestimateSlider.Value;
            syms y(t);
            Dy = diff(y);
            y=dsolve(app.Testimate*Dy+y == app.Cestimate,y(0)==app.y0);
            yt = subs(y,app.tt);
            plot(app.UIAxes,app.tt,yt,'linewidth',2); 
            
            % Augment legend
            nleg =length(app.legstring);
            app.legstring{nleg+1} = ['T = ',num2str(app.Testimate),', C = ',num2str(app.Cestimate)];
            legend(app.UIAxes,app.legstring,'Location','SouthEast')
        

        end

        % Button pushed function: TellmethecorrectanswersButton
        function TellmethecorrectanswersButtonPushed(app, event)
            % Adds time constant and steady-state lines to the plot to make
            % their selection evident
            % Also updates the displayed values
            x63 = (app.C-app.y0)*0.63+app.y0;
            plot(app.UIAxes,[app.T,app.T],[app.y0,app.C],'-.','Color',[1.00,0.20,0.70],'linewidth',3)
            plot(app.UIAxes,[0,app.runtime],[app.C,app.C],':','Color',[1.00,0.20,0.70],'linewidth',3)
            plot(app.UIAxes,[0,app.runtime],[x63,x63],'--','Color',[1.00,0.20,0.70],'linewidth',3);
            text(app.UIAxes,app.runtime/20,0.9*app.C+0.1*app.y0,...
                ['T = ',num2str(app.T),', C = ',num2str(app.C)],...
                'fontsize', 18,'Color',[1.00,0.20,0.70]);
            app.CorrectTEditField.Value = app.T;
            app.CorrectCEditField.Value = app.C;
            nleg =length(app.legstring);
            app.legstring{nleg+1} = ['Time constant line'];
            app.legstring{nleg+2} = ['Steady-state line'];
            app.legstring{nleg+3} = ['63% movement'];
            legend(app.UIAxes,app.legstring,'Location','SouthEast')
        
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
            app.UIFigure.Position = [100 100 1062 532];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1.1x', '2x'};
            app.GridLayout.RowHeight = {'0.4x', '1.4x', '1x'};

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Original response and responses with estimated models')
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

            % Create stordermodelbehaviourTdxdtxCff1Label
            app.stordermodelbehaviourTdxdtxCff1Label = uilabel(app.GridLayout2);
            app.stordermodelbehaviourTdxdtxCff1Label.BackgroundColor = [0 1 1];
            app.stordermodelbehaviourTdxdtxCff1Label.HorizontalAlignment = 'center';
            app.stordermodelbehaviourTdxdtxCff1Label.FontSize = 24;
            app.stordermodelbehaviourTdxdtxCff1Label.FontWeight = 'bold';
            app.stordermodelbehaviourTdxdtxCff1Label.Layout.Row = 1;
            app.stordermodelbehaviourTdxdtxCff1Label.Layout.Column = [1 2];
            app.stordermodelbehaviourTdxdtxCff1Label.Text = '1st order model behaviour:   T(dx/dt) + x = C f,  f=1';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout);
            app.GridLayout4.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout4.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout4.Layout.Row = 2;
            app.GridLayout4.Layout.Column = 1;
            app.GridLayout4.BackgroundColor = [0.902 1 0.502];

            % Create EnterTestimateSliderLabel
            app.EnterTestimateSliderLabel = uilabel(app.GridLayout4);
            app.EnterTestimateSliderLabel.HorizontalAlignment = 'right';
            app.EnterTestimateSliderLabel.FontSize = 16;
            app.EnterTestimateSliderLabel.Layout.Row = 3;
            app.EnterTestimateSliderLabel.Layout.Column = 1;
            app.EnterTestimateSliderLabel.Text = 'Enter T estimate';

            % Create EnterTestimateSlider
            app.EnterTestimateSlider = uislider(app.GridLayout4);
            app.EnterTestimateSlider.Limits = [0 10];
            app.EnterTestimateSlider.MajorTicks = [0 1 2 3 4 5 6 7 8 9 10];
            app.EnterTestimateSlider.ValueChangedFcn = createCallbackFcn(app, @EnterTestimateSliderValueChanged, true);
            app.EnterTestimateSlider.MinorTicks = [0 100 200 300 400 500 600 700 800 900 1000];
            app.EnterTestimateSlider.FontSize = 16;
            app.EnterTestimateSlider.Layout.Row = 3;
            app.EnterTestimateSlider.Layout.Column = 2;
            app.EnterTestimateSlider.Value = 5;

            % Create EnterCestimateSliderLabel
            app.EnterCestimateSliderLabel = uilabel(app.GridLayout4);
            app.EnterCestimateSliderLabel.HorizontalAlignment = 'right';
            app.EnterCestimateSliderLabel.FontSize = 16;
            app.EnterCestimateSliderLabel.Layout.Row = 4;
            app.EnterCestimateSliderLabel.Layout.Column = 1;
            app.EnterCestimateSliderLabel.Text = 'Enter C estimate';

            % Create EnterCestimateSlider
            app.EnterCestimateSlider = uislider(app.GridLayout4);
            app.EnterCestimateSlider.Limits = [0 10];
            app.EnterCestimateSlider.MajorTicks = [0 1 2 3 4 5 6 7 8 9 10];
            app.EnterCestimateSlider.ValueChangedFcn = createCallbackFcn(app, @EnterCestimateSliderValueChanged, true);
            app.EnterCestimateSlider.MinorTicks = [0 10 20 30 40 50];
            app.EnterCestimateSlider.FontSize = 16;
            app.EnterCestimateSlider.Layout.Row = 4;
            app.EnterCestimateSlider.Layout.Column = 2;
            app.EnterCestimateSlider.Value = 5;

            % Create CreatenewrandomexampleButton
            app.CreatenewrandomexampleButton = uibutton(app.GridLayout4, 'push');
            app.CreatenewrandomexampleButton.ButtonPushedFcn = createCallbackFcn(app, @CreatenewrandomexampleButtonPushed, true);
            app.CreatenewrandomexampleButton.BackgroundColor = [1 1 0];
            app.CreatenewrandomexampleButton.FontSize = 18;
            app.CreatenewrandomexampleButton.FontWeight = 'bold';
            app.CreatenewrandomexampleButton.Layout.Row = 1;
            app.CreatenewrandomexampleButton.Layout.Column = [1 2];
            app.CreatenewrandomexampleButton.Text = 'Create new random example';

            % Create EnteryourestimatesofthemodelparametersfromtheplotbelowLabel
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel = uilabel(app.GridLayout4);
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel.HorizontalAlignment = 'center';
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel.WordWrap = 'on';
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel.FontSize = 16;
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel.Layout.Row = 2;
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel.Layout.Column = [1 2];
            app.EnteryourestimatesofthemodelparametersfromtheplotbelowLabel.Text = 'Enter your estimates of the model parameters from the plot in the sliders below';

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout);
            app.GridLayout6.ColumnWidth = {'0.6x', '1x'};
            app.GridLayout6.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout6.Layout.Row = 3;
            app.GridLayout6.Layout.Column = 1;
            app.GridLayout6.BackgroundColor = [1 0.6 0.8];

            % Create CheckmyestimatesButton
            app.CheckmyestimatesButton = uibutton(app.GridLayout6, 'push');
            app.CheckmyestimatesButton.ButtonPushedFcn = createCallbackFcn(app, @CheckmyestimatesButtonPushed, true);
            app.CheckmyestimatesButton.BackgroundColor = [1 0.2 0.702];
            app.CheckmyestimatesButton.FontSize = 20;
            app.CheckmyestimatesButton.FontWeight = 'bold';
            app.CheckmyestimatesButton.Layout.Row = 1;
            app.CheckmyestimatesButton.Layout.Column = [1 2];
            app.CheckmyestimatesButton.Text = 'Check my estimates';

            % Create CorrectTEditFieldLabel
            app.CorrectTEditFieldLabel = uilabel(app.GridLayout6);
            app.CorrectTEditFieldLabel.HorizontalAlignment = 'right';
            app.CorrectTEditFieldLabel.FontSize = 18;
            app.CorrectTEditFieldLabel.Layout.Row = 3;
            app.CorrectTEditFieldLabel.Layout.Column = 1;
            app.CorrectTEditFieldLabel.Text = 'Correct T';

            % Create CorrectTEditField
            app.CorrectTEditField = uieditfield(app.GridLayout6, 'numeric');
            app.CorrectTEditField.FontSize = 18;
            app.CorrectTEditField.Layout.Row = 3;
            app.CorrectTEditField.Layout.Column = 2;

            % Create CorrectCEditFieldLabel
            app.CorrectCEditFieldLabel = uilabel(app.GridLayout6);
            app.CorrectCEditFieldLabel.HorizontalAlignment = 'right';
            app.CorrectCEditFieldLabel.FontSize = 18;
            app.CorrectCEditFieldLabel.Layout.Row = 4;
            app.CorrectCEditFieldLabel.Layout.Column = 1;
            app.CorrectCEditFieldLabel.Text = 'Correct C';

            % Create CorrectCEditField
            app.CorrectCEditField = uieditfield(app.GridLayout6, 'numeric');
            app.CorrectCEditField.FontSize = 18;
            app.CorrectCEditField.Layout.Row = 4;
            app.CorrectCEditField.Layout.Column = 2;

            % Create TellmethecorrectanswersButton
            app.TellmethecorrectanswersButton = uibutton(app.GridLayout6, 'push');
            app.TellmethecorrectanswersButton.ButtonPushedFcn = createCallbackFcn(app, @TellmethecorrectanswersButtonPushed, true);
            app.TellmethecorrectanswersButton.BackgroundColor = [1 0.2 0.702];
            app.TellmethecorrectanswersButton.FontSize = 20;
            app.TellmethecorrectanswersButton.FontWeight = 'bold';
            app.TellmethecorrectanswersButton.Layout.Row = 2;
            app.TellmethecorrectanswersButton.Layout.Column = [1 2];
            app.TellmethecorrectanswersButton.Text = 'Tell me the correct answers';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = firstordermodel_behaviour

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

