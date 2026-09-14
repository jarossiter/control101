classdef myfirstsimulink_control101 < matlab.apps.AppBase
    %MYFIRSTSIMULINK_CONTROL101
    %   This app gives an introduction to simulink. It opens a blank
    %   simulink file which users must edit and then the interactive
    %   elements in the app test the accuracy of the student created model.
    %   
    %   Only elementary tools of transfer function blocks, step inputs,
    %   ouput to workspace, summing junctions, gains and mux components are
    %   used.
    %   
    %   It encourages the user to open the blocks and make minor changes to
    %   the values and settings to increase awareness of these.
    %   
    %   The resource is part of the control101 toolbox, which can be
    %   downloaded from the add-ons button.

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        GridLayout                 matlab.ui.container.GridLayout
        Label2                     matlab.ui.control.Label
        Label_5                    matlab.ui.control.Label
        UsesadifferenttoworkspaceoptiondefaultnaminginLabel  matlab.ui.control.Label
        Label_3                    matlab.ui.control.Label
        SofarnothingtoreportLabel  matlab.ui.control.Label
        Label_2                    matlab.ui.control.Label
        ConciseerrormessagesLabel  matlab.ui.control.Label
        Task3Label                 matlab.ui.control.Label
        Task2Label                 matlab.ui.control.Label
        Task1Label                 matlab.ui.control.Label
        PictureofthesimulinkdiagramwewanttoproduceDropDown  matlab.ui.control.DropDown
        PictureofthesimulinkdiagramwewanttoproduceDropDownLabel  matlab.ui.control.Label
        Image2                     matlab.ui.control.Image
        Label                      matlab.ui.control.Label
        GridLayout3                matlab.ui.container.GridLayout
        Comparetask2Button         matlab.ui.control.Button
        Comparetask3Button         matlab.ui.control.Button
        Comparetask1Button         matlab.ui.control.Button
        GridLayout2                matlab.ui.container.GridLayout
        Image                      matlab.ui.control.Image
        MyfirstsimulinkfileLabel   matlab.ui.control.Label
        UIAxes                     matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        n =[1 7] % Model numerator
        d =[1 8 12] % model denominator
        endtime = 3 % length of simulation
        Kp = 2 % value of gain

        originalsize  % GUI property for resizing
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
            if exist('myfirstsimulinkfile_control101_manual_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open myfirstsimulinkfile_control101_manual_mycopy.mlx
            else
                p1 = which('myfirstsimulinkfile_control101_manual.mlx');
                try copyfile(p1,pwd)
                system("rename " + "myfirstsimulinkfile_control101_manual.mlx" + " " + "myfirstsimulinkfile_control101_manual_mycopy.mlx");
                open myfirstsimulinkfile_control101_manual_mycopy.mlx
                catch
                   system("copy " + "myfirstsimulinkfile_control101_manual.mlx" + " " + "myfirstsimulinkfile_control101_manual_mycopy.mlx");
                   open myfirstsimulinkfile_control101_manual_mycopy.mlx
                   disp('***********************************************************************************')
                   disp('WARNING - YOU ARE IN THE SAME FOLDER AS THE SOURCES FILES SO MAY BE CORRUPTING THEM')
                   disp('***********************************************************************************')
                end
                clear p1
            end


            % open the simulink file
            if exist('myfirstsimulinkfile_control101_task1_mycopy.slx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open myfirstsimulinkfile_control101_task1_mycopy.slx
            else
                p1 = which('myfirstsimulinkfile_control101_task1.slx');
                try 
                   copyfile(p1,pwd)
                   system("rename " + "myfirstsimulinkfile_control101_task1.slx" + " " + "myfirstsimulinkfile_control101_task1_mycopy.slx");
                catch
                   system("copy " + "myfirstsimulinkfile_control101_task1.slx" + " " + "myfirstsimulinkfile_control101_task1_mycopy.slx");
                   disp('***********************************************************************************')
                   disp('WARNING - YOU ARE IN THE SAME FOLDER AS THE SOURCES FILES SO MAY BE CORRUPTING THEM')
                   disp('***********************************************************************************')
                end
                open myfirstsimulinkfile_control101_task1_mycopy.slx
                clear p1
            end

            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);

            % send core data to the workspace so students can run simulink files from
            % there if needed
            assignin('base','Kp',app.Kp);
            assignin('base','n',app.n);
            assignin('base','d',app.d);
            assignin('base','endtime',app.endtime);

            % Create figures as needed
            %print(['-smyfirstsimulinkfile'],'-djpeg',['myfirstsimulinkfile.jpg'])
            %print(['-smyfirstsimulinkfileb'],'-djpeg',['myfirstsimulinkfileb.jpg'])
            %print(['-smyfirstsimulinkfilec'],'-djpeg',['myfirstsimulinkfilec.jpg'])

            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
                theme(app.UIFigure,"light")
            end
        end

        % Button pushed function: Comparetask1Button
        function Comparetask1ButtonPushed(app, event)
            % compares the responses from the stored file and a student
            % generated file
             tt = ['No obvious errors to report. If the plots are different then', ...
                 ' your simulink file is incorrect. Have you entered the parameters correctly',...
                 ' including the simulation time?'];
             app.SofarnothingtoreportLabel.Text = tt;

            % Take stored data and supply to the simulink files
            simIn = Simulink.SimulationInput('myfirstsimulinkfile_control101');
            simIn = simIn.setVariable('n',app.n);
            simIn = simIn.setVariable('d',app.d);
            simIn = simIn.setVariable('Kp',app.Kp);
            simIn = simIn.setVariable('endtime',app.endtime);
            
            % Run and plot data for correct file
            y=sim(simIn);
            hold(app.UIAxes,'off');
            plot(app.UIAxes,y.tout,y.output.signals.values,'b','linewidth',2);
            hold(app.UIAxes,'on')

            try; % Check whether student simulation runs correctly
                simIn2 = Simulink.SimulationInput('myfirstsimulinkfile_control101_task1_mycopy');
                simIn2 = simIn2.setVariable('n',app.n);
                simIn2 = simIn2.setVariable('d',app.d);
                simIn2 = simIn2.setVariable('Kp',app.Kp);
                simIn2 = simIn2.setVariable('endtime',app.endtime);
                y2 = sim(simIn2);
                
            catch
                y2=y;
                y2.output.signals.values =y2.output.signals.values*0;
                app.SofarnothingtoreportLabel.Text = ['Simulation has failed to run.',...
                    ' Check for variables being defined correctly in the simulink blocks', ...
                    ' and connections'];
                %keyboard
            end

            try % Check whether student data has correct format
                plot(app.UIAxes,y2.tout,y2.output.signals.values,'ro','linewidth',2);
            catch
                y2=y;
                y2.output.signals.values =y2.output.signals.values*0;
                plot(app.UIAxes,y2.tout,y2.output.signals.values,'ro','linewidth',2);
                app.SofarnothingtoreportLabel.Text = ['Data output has the incorrect format or naming.',...
                    ' Have you updated the output name in the to workspace block?'];
                %keyboard
            end

            legend(app.UIAxes,'Correct response','Student model response')
            
        end

        % Button pushed function: Comparetask3Button
        function Comparetask3ButtonPushed(app, event)
            % compares the responses from the stored file and a student
            % generated file for task 3
             tt = ['No obvious errors to report. If the plots are different then', ...
                 ' your simulink file is incorrect. Have you entered the parameters correctly?'];
             app.SofarnothingtoreportLabel.Text = tt;

            % Take stored data and supply to the simulink files
            simIn = Simulink.SimulationInput('myfirstsimulinkfilec_control101');
            simIn = simIn.setVariable('n',app.n);
            simIn = simIn.setVariable('d',app.d);
            simIn = simIn.setVariable('Kp',app.Kp);
            simIn = simIn.setVariable('endtime',app.endtime);
            
            %keyboard
            % Run and plot data for correct file
            y=sim(simIn);
            hold(app.UIAxes,'off');
            %y=closedloopsignals;
            plot(app.UIAxes,y.closedloopsignals.Time,y.closedloopsignals.Data,'linewidth',2);
            hold(app.UIAxes,'on')

            try; % Check whether student simulation runs correctly
                simIn2 = Simulink.SimulationInput('myfirstsimulinkfile_control101_task1_mycopy');
                simIn2 = simIn2.setVariable('n',app.n);
                simIn2 = simIn2.setVariable('d',app.d);
                simIn2 = simIn2.setVariable('Kp',app.Kp);
                simIn2 = simIn2.setVariable('endtime',app.endtime);
                y2=sim(simIn2);
                
            catch
                y2=y;
                y2.closedloopsignals.Data =y2.closedloopsignals.Data*0;
                app.SofarnothingtoreportLabel.Text = ['Simulation has failed to run.',...
                    ' Check for variables being defined correctly in the simulink blocks', ...
                    ' and connections'];
                %keyboard
            end

            try % Check whether student data has correct format
                plot(app.UIAxes,y2.closedloopsignals.Time,y2.closedloopsignals.Data,'o','linewidth',2);
            catch
                y2=y;
                plot(app.UIAxes,y2.closedloopsignals.Time,y2.closedloopsignals.Data*0,'o','linewidth',2);
                app.SofarnothingtoreportLabel.Text = ['Data output has the incorrect format or naming',...
                    ' Have you updated the output name in the to workspace block?'];
                %keyboard
            end

            legend(app.UIAxes,'Target','Input','Output','Student target','Student input','Student output')
        end

        % Button pushed function: Comparetask2Button
        function Comparetask2ButtonPushed(app, event)
            % compares the responses from the stored file and a student
            % generated file for task 2
             tt = ['No obvious errors to report. If the plots are different then', ...
                 ' your simulink file is incorrect. Have you entered the parameters correctly?'];
             app.SofarnothingtoreportLabel.Text = tt;

            % Take stored data and supply to the simulink files
            simIn = Simulink.SimulationInput('myfirstsimulinkfileb_control101');
            simIn = simIn.setVariable('n',app.n);
            simIn = simIn.setVariable('d',app.d);
            simIn = simIn.setVariable('Kp',app.Kp);
            simIn = simIn.setVariable('endtime',app.endtime);
            
            
            % Run and plot data for correct file
            
            yy= sim(simIn);  % Fails [tout,xout,yout] = sim(simIn);
            
            %xx = find(yy.yout,'yout');
            yout = yy.yout;
            tout = yy.tout;

            
            hold(app.UIAxes,'off');
            plot(app.UIAxes,tout,yout,'linewidth',2);
            hold(app.UIAxes,'on')

            try; % Check whether student simulation runs correctly
                simIn2 = Simulink.SimulationInput('myfirstsimulinkfile_control101_task1_mycopy');
                simIn2 = simIn2.setVariable('n',app.n);
                simIn2 = simIn2.setVariable('d',app.d);
                simIn2 = simIn2.setVariable('Kp',app.Kp);
                simIn2 = simIn2.setVariable('endtime',app.endtime);
                
                yy2 = sim(simIn2);
               % xx2 = find(yy2.yout,'yout');
                y2 = yy2.yout;
                t2 = yy2.tout;
                
            catch
                y2=yout*0; t2 = tout;
                app.SofarnothingtoreportLabel.Text = ['Simulation has failed to run.',...
                    ' Check for variables being defined correctly in the simulink blocks', ...
                    ' and connections'];
                %keyboard
            end

            try % Check whether student data has correct format
                plot(app.UIAxes,t2,y2,'o','linewidth',2);
            catch
                y2=yout*0;
                t2= tout;
                plot(app.UIAxes,t2,y2,'o','linewidth',2);
                app.SofarnothingtoreportLabel.Text = ['Data output has the incorrect format or naming',...
                    ' Have you updated the output name in the to workspace block?'];
                %keyboard
            end

          legend(app.UIAxes,'Target','Input','Output','Student target','Student input','Student output')
 
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

        % Value changed function: 
        % PictureofthesimulinkdiagramwewanttoproduceDropDown
        function PictureofthesimulinkdiagramwewanttoproduceDropDownValueChanged(app, event)
            value = app.PictureofthesimulinkdiagramwewanttoproduceDropDown.Value;
            switch value
                case 'Task 1'
                  app.Image2.ImageSource= 'myfirstsimulinkfile_control101.jpg';

                case 'Task 2'
                  app.Image2.ImageSource= 'myfirstsimulinkfileb_control101.jpg';

                case 'Task 3'
                  app.Image2.ImageSource= 'myfirstsimulinkfilec_control101.jpg';

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
            app.UIFigure.Position = [100 100 1241 612];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout.RowHeight = {'2x', '1x', '1.5x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};

            % Create UIAxes
            app.UIAxes = uiaxes(app.GridLayout);
            title(app.UIAxes, 'Responses')
            xlabel(app.UIAxes, 'Time (sec)')
            ylabel(app.UIAxes, 'Outputs')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Layout.Row = [2 9];
            app.UIAxes.Layout.Column = [4 7];

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = [4 7];
            app.GridLayout2.BackgroundColor = [0.6 1 1];

            % Create MyfirstsimulinkfileLabel
            app.MyfirstsimulinkfileLabel = uilabel(app.GridLayout2);
            app.MyfirstsimulinkfileLabel.BackgroundColor = [0 1 1];
            app.MyfirstsimulinkfileLabel.HorizontalAlignment = 'center';
            app.MyfirstsimulinkfileLabel.FontSize = 24;
            app.MyfirstsimulinkfileLabel.FontWeight = 'bold';
            app.MyfirstsimulinkfileLabel.Layout.Row = 1;
            app.MyfirstsimulinkfileLabel.Layout.Column = [1 2];
            app.MyfirstsimulinkfileLabel.Text = 'My first simulink file';

            % Create Image
            app.Image = uiimage(app.GridLayout2);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 3;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'UoSlogo.png');

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout);
            app.GridLayout3.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout3.RowHeight = {'1x'};
            app.GridLayout3.Layout.Row = 1;
            app.GridLayout3.Layout.Column = [1 3];
            app.GridLayout3.BackgroundColor = [1 0.6 0.8];

            % Create Comparetask1Button
            app.Comparetask1Button = uibutton(app.GridLayout3, 'push');
            app.Comparetask1Button.ButtonPushedFcn = createCallbackFcn(app, @Comparetask1ButtonPushed, true);
            app.Comparetask1Button.BackgroundColor = [1 0.2 0.702];
            app.Comparetask1Button.FontSize = 20;
            app.Comparetask1Button.FontWeight = 'bold';
            app.Comparetask1Button.Layout.Row = 1;
            app.Comparetask1Button.Layout.Column = 1;
            app.Comparetask1Button.Text = 'Compare task 1';

            % Create Comparetask3Button
            app.Comparetask3Button = uibutton(app.GridLayout3, 'push');
            app.Comparetask3Button.ButtonPushedFcn = createCallbackFcn(app, @Comparetask3ButtonPushed, true);
            app.Comparetask3Button.BackgroundColor = [1 0.2 0.702];
            app.Comparetask3Button.FontSize = 20;
            app.Comparetask3Button.FontWeight = 'bold';
            app.Comparetask3Button.Layout.Row = 1;
            app.Comparetask3Button.Layout.Column = 3;
            app.Comparetask3Button.Text = 'Compare task 3';

            % Create Comparetask2Button
            app.Comparetask2Button = uibutton(app.GridLayout3, 'push');
            app.Comparetask2Button.ButtonPushedFcn = createCallbackFcn(app, @Comparetask2ButtonPushed, true);
            app.Comparetask2Button.BackgroundColor = [1 0.2 0.702];
            app.Comparetask2Button.FontSize = 20;
            app.Comparetask2Button.FontWeight = 'bold';
            app.Comparetask2Button.Layout.Row = 1;
            app.Comparetask2Button.Layout.Column = 2;
            app.Comparetask2Button.Text = 'Compare task 2';

            % Create Label
            app.Label = uilabel(app.GridLayout);
            app.Label.BackgroundColor = [0 1 0];
            app.Label.WordWrap = 'on';
            app.Label.FontSize = 14;
            app.Label.Layout.Row = 2;
            app.Label.Layout.Column = [1 3];
            app.Label.Text = 'After making edits to your simulink file, save in the given name/folder and use the compare buttons above to evaluate. The plots in the figure should overlap.';

            % Create Image2
            app.Image2 = uiimage(app.GridLayout);
            app.Image2.Layout.Row = [10 12];
            app.Image2.Layout.Column = [5 7];
            app.Image2.ImageSource = fullfile(pathToMLAPP, 'myfirstsimulinkfile_control101.jpg');

            % Create PictureofthesimulinkdiagramwewanttoproduceDropDownLabel
            app.PictureofthesimulinkdiagramwewanttoproduceDropDownLabel = uilabel(app.GridLayout);
            app.PictureofthesimulinkdiagramwewanttoproduceDropDownLabel.BackgroundColor = [0 1 0];
            app.PictureofthesimulinkdiagramwewanttoproduceDropDownLabel.HorizontalAlignment = 'right';
            app.PictureofthesimulinkdiagramwewanttoproduceDropDownLabel.FontSize = 14;
            app.PictureofthesimulinkdiagramwewanttoproduceDropDownLabel.Layout.Row = 13;
            app.PictureofthesimulinkdiagramwewanttoproduceDropDownLabel.Layout.Column = [5 6];
            app.PictureofthesimulinkdiagramwewanttoproduceDropDownLabel.Text = 'Picture of the simulink diagram we want to produce.';

            % Create PictureofthesimulinkdiagramwewanttoproduceDropDown
            app.PictureofthesimulinkdiagramwewanttoproduceDropDown = uidropdown(app.GridLayout);
            app.PictureofthesimulinkdiagramwewanttoproduceDropDown.Items = {'Task 1', 'Task 2', 'Task 3'};
            app.PictureofthesimulinkdiagramwewanttoproduceDropDown.ValueChangedFcn = createCallbackFcn(app, @PictureofthesimulinkdiagramwewanttoproduceDropDownValueChanged, true);
            app.PictureofthesimulinkdiagramwewanttoproduceDropDown.FontSize = 14;
            app.PictureofthesimulinkdiagramwewanttoproduceDropDown.BackgroundColor = [0.702 1 0.702];
            app.PictureofthesimulinkdiagramwewanttoproduceDropDown.Layout.Row = 13;
            app.PictureofthesimulinkdiagramwewanttoproduceDropDown.Layout.Column = 7;
            app.PictureofthesimulinkdiagramwewanttoproduceDropDown.Value = 'Task 1';

            % Create Task1Label
            app.Task1Label = uilabel(app.GridLayout);
            app.Task1Label.BackgroundColor = [0.7765 0.4196 1];
            app.Task1Label.HorizontalAlignment = 'center';
            app.Task1Label.FontSize = 24;
            app.Task1Label.Layout.Row = [4 5];
            app.Task1Label.Layout.Column = 1;
            app.Task1Label.Text = 'Task 1';

            % Create Task2Label
            app.Task2Label = uilabel(app.GridLayout);
            app.Task2Label.BackgroundColor = [0.7765 0.4196 1];
            app.Task2Label.HorizontalAlignment = 'center';
            app.Task2Label.FontSize = 24;
            app.Task2Label.Layout.Row = [6 7];
            app.Task2Label.Layout.Column = 1;
            app.Task2Label.Text = 'Task 2';

            % Create Task3Label
            app.Task3Label = uilabel(app.GridLayout);
            app.Task3Label.BackgroundColor = [0.7765 0.4196 1];
            app.Task3Label.HorizontalAlignment = 'center';
            app.Task3Label.FontSize = 24;
            app.Task3Label.Layout.Row = [8 9];
            app.Task3Label.Layout.Column = 1;
            app.Task3Label.Text = 'Task 3';

            % Create ConciseerrormessagesLabel
            app.ConciseerrormessagesLabel = uilabel(app.GridLayout);
            app.ConciseerrormessagesLabel.BackgroundColor = [1 1 0.0667];
            app.ConciseerrormessagesLabel.HorizontalAlignment = 'center';
            app.ConciseerrormessagesLabel.FontSize = 24;
            app.ConciseerrormessagesLabel.FontWeight = 'bold';
            app.ConciseerrormessagesLabel.Layout.Row = 10;
            app.ConciseerrormessagesLabel.Layout.Column = [1 3];
            app.ConciseerrormessagesLabel.Text = 'Concise error messages ';

            % Create Label_2
            app.Label_2 = uilabel(app.GridLayout);
            app.Label_2.BackgroundColor = [0 1 0];
            app.Label_2.WordWrap = 'on';
            app.Label_2.FontSize = 14;
            app.Label_2.Layout.Row = 3;
            app.Label_2.Layout.Column = [1 3];
            app.Label_2.Text = 'The simulink file should open automatically (may take 30sec) in a separate window and contains the blocks you need. The diagram you need to code up is in the bottom right figure and is task specific.';

            % Create SofarnothingtoreportLabel
            app.SofarnothingtoreportLabel = uilabel(app.GridLayout);
            app.SofarnothingtoreportLabel.BackgroundColor = [1 1 0.549];
            app.SofarnothingtoreportLabel.WordWrap = 'on';
            app.SofarnothingtoreportLabel.FontSize = 14;
            app.SofarnothingtoreportLabel.Layout.Row = [11 13];
            app.SofarnothingtoreportLabel.Layout.Column = [1 3];
            app.SofarnothingtoreportLabel.Text = 'So far nothing to report. If the plots are different then your simulink file is incorrect.';

            % Create Label_3
            app.Label_3 = uilabel(app.GridLayout);
            app.Label_3.BackgroundColor = [0.9137 0.7922 0.9882];
            app.Label_3.WordWrap = 'on';
            app.Label_3.Layout.Row = [4 5];
            app.Label_3.Layout.Column = [2 3];
            app.Label_3.Text = 'The gain parameter uses variable ''Kp'', the transfer function has numerator ''n'' and denominator ''d'', the to workspace block uses ''structure'' as the format. The simulation Stop Time is ''endtime''.';

            % Create UsesadifferenttoworkspaceoptiondefaultnaminginLabel
            app.UsesadifferenttoworkspaceoptiondefaultnaminginLabel = uilabel(app.GridLayout);
            app.UsesadifferenttoworkspaceoptiondefaultnaminginLabel.BackgroundColor = [0.9137 0.7922 0.9882];
            app.UsesadifferenttoworkspaceoptiondefaultnaminginLabel.WordWrap = 'on';
            app.UsesadifferenttoworkspaceoptiondefaultnaminginLabel.Layout.Row = [6 7];
            app.UsesadifferenttoworkspaceoptiondefaultnaminginLabel.Layout.Column = [2 3];
            app.UsesadifferenttoworkspaceoptiondefaultnaminginLabel.Text = {'Use a different to workspace option: use single simulation output in the configure logging settings (under simulation tab) and select data type of ''array''.  '; 'Also combine 3 core signals into a vector output.'};

            % Create Label_5
            app.Label_5 = uilabel(app.GridLayout);
            app.Label_5.BackgroundColor = [0.9137 0.7922 0.9882];
            app.Label_5.WordWrap = 'on';
            app.Label_5.Layout.Row = [8 9];
            app.Label_5.Layout.Column = [2 3];
            app.Label_5.Text = 'Create a unity negative feedback loop and use a ''to workspace'' block with ''timeseries'' as the output type and name ''closedloopsignals''. Make sure signs of the summing junction are correct.';

            % Create Label2
            app.Label2 = uilabel(app.GridLayout);
            app.Label2.BackgroundColor = [1 0 0];
            app.Label2.WordWrap = 'on';
            app.Label2.FontSize = 14;
            app.Label2.Layout.Row = [10 13];
            app.Label2.Layout.Column = 4;
            app.Label2.Text = 'To recover the original ''simulink'' file, delete the ''**_mycopy'' version in the present working directory and rerun this app.';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = myfirstsimulink_control101

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

