classdef behaviours < matlab.apps.AppBase
    %BEHAVIOURS
    %   File written by J.A.Rossiter, University of Sheffield
    %   See website for more files like this.
    %   https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
    %   
    %   A simple interface to practice the impact on behaviour of changing
    %   the poles and zeros of a transfer function. 
    %   
    %   Users can use a default model, or enter their own transfer
    %   function coefficients or generate random examples. They can also
    %   move the poles and zeros directly with the mouse in the bottom
    %   right figure.
    %   
    %   Some notes and engineering background are in the partner
    %   livescript file:    behaviours_manual.mlx
    %       
    %   A group of similar files can be downloaded through MATLAB
    %   add-ons with the toolbox name: control101
    %   
    %       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    FILE ORGANISATION
    %   A section defining the core variables stored in "app"
    %       
    %   A section with subfunctions doing the core computations.
    %   
    %   A section with callback functions linked to the items in the
    %   interface.
    %          
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        GridLayout9                    matlab.ui.container.GridLayout
        GridLayout5_2                  matlab.ui.container.GridLayout
        Image                          matlab.ui.control.Image
        BehaviouroflinearmodelsLabel   matlab.ui.control.Label
        UIAxesY                        matlab.ui.control.UIAxes
        PolesZerosAxis                 matlab.ui.control.UIAxes
        GridLayout2                    matlab.ui.container.GridLayout
        ShowTransferFunction           matlab.ui.control.Label
        OpenlooppolesandzerosPanel     matlab.ui.container.Panel
        GridLayout15                   matlab.ui.container.GridLayout
        ClosedLoopZerosDisp            matlab.ui.control.EditField
        ClosedLoopZerosLabel           matlab.ui.control.Label
        ClosedLoopPolesDisp            matlab.ui.control.EditField
        ClosedLoopPolesLabel           matlab.ui.control.Label
        GridLayout5                    matlab.ui.container.GridLayout
        TabGroup                       matlab.ui.container.TabGroup
        ExampleTab                     matlab.ui.container.Tab
        GridLayout19                   matlab.ui.container.GridLayout
        ChoosePlantDropDown            matlab.ui.control.DropDown
        ChooseplantLabel               matlab.ui.control.Label
        NumExample                     matlab.ui.control.EditField
        NumeratorLabel                 matlab.ui.control.Label
        DenExample                     matlab.ui.control.EditField
        DenominatorLabel               matlab.ui.control.Label
        CustomTab                      matlab.ui.container.Tab
        GridLayout20                   matlab.ui.container.GridLayout
        NumCustom                      matlab.ui.control.EditField
        NumeratorLabel_2               matlab.ui.control.Label
        DenCustom                      matlab.ui.control.EditField
        DenominatorLabel_2             matlab.ui.control.Label
        RandomchoiceTab                matlab.ui.container.Tab
        GridLayout18                   matlab.ui.container.GridLayout
        CreatenewrandomexampleButton   matlab.ui.control.Button
        StableorunstablepolesDropDown  matlab.ui.control.DropDown
        StableorunstablepolesDropDownLabel  matlab.ui.control.Label
        LoworhighorderDropDown         matlab.ui.control.DropDown
        LoworhighorderDropDownLabel    matlab.ui.control.Label
        RealorcomplexpolesDropDown     matlab.ui.control.DropDown
        RealorcomplexpolesDropDownLabel  matlab.ui.control.Label
        PlanttransferfunctionGsLabel   matlab.ui.control.Label
    end

% File written by Ioannis Myrsinias (Mathworks) and J.A.Rossiter, University of Sheffield
%     See website for more files like this.
%     https://sites.google.com/sheffield.ac.uk/controleducation/mainindex
%     A simple interface to practice the tuning of PI compensation for
%     a variety of models
%     Students can use a default model, or enter their own transfer
%     function
%     Some notes and engineering background are in the partner livescript
%     file:    pi_tuning_manual.mlx
%     A group of similar files can be downloaded through MATLAB add-ons
%     with the toolbox name:  ********************
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%  FILE ORGANISATION
%     A section defining the core variables stored in "app"
%     
%     A section with subfunctions doing the core computations
%     SEE CALLBACKS IN LEFT HAND TAB
%     1. Largely these do self-evident checks and updates when the user
%     interacts with a slider/button/choice
%     2. A few do computations of the closed-loop step responses and manage
%     the animation.
%     3. Some do interface management, such as preventing interaction while
%     an animation is running and refreshing axes as required.
%     4. The 'simulation' button runs the subfunctions in turn 
%     as required to manage the animation and data updates.
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
    
    % The next section defines all the core variables used in the code and
    % that it may be convenient to have available in the various
    % subfunctions

    properties (Access = private)
        originalsize     % product of width and height for font sizing
        plantTrFcn      % transfer function
        poles           % poles
        zeros           % zeros
        poles_saved     % for movements during mouse click
        zeros_saved     % for movements during mouse click
        G0              % dc gain
        t               % time
        u               % controller's output
        y               % system's output
        Gc1             % closed loop transfer function
        Gc1u            % closed loop transfer function
        legstring       % closed loop transfer function
        numerator       % mumerator of open loop transfer function
        denumerator     % denominator of open loop transfer function
        mode            % 0 for example, 1 for custom
        endtime=5;      % default simulation runtime
        samples = 201;  % number of points in simulation
        curobj          
        xdata           
        ydata 
        ind  
    end

    methods (Access = private)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION to define default  transfer function models
        function out = exampleTransferFcn(app,orderchoice)
            switch orderchoice
                case 'First order'
                    n=[1.6]; d = [1 2];
                case 'Second order'
                    n=[4]; d = [1 5 6];
                case 'Under-damped'
                    n=[4];
                    d = [1 2 6];
                case 'High-order'
                    n=[4 1.2]; d = [1 6 11 6];
            end
            app.updateTransferFunctionRender(n, d);
            out = tf(n,d);
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% TWO SUBFUNCTIONS to display the transfer function     

        function updateTransferFunctionRender(app,n,d)
            app.updateTextFieldFromArray(app.NumExample,n, " ",3); % 3 is the number of digits
            app.updateTextFieldFromArray(app.DenExample,d, " ",3); % 3 is the number of digits

            numerator_str = app.array2StringPolynomial(n);
            denumerator_str = app.array2StringPolynomial(d);

            app.ShowTransferFunction.Text = "$G(s) = \frac{"+numerator_str+"}"+"{"+denumerator_str+"}$";

        end


        function updateTextFieldFromArray(app, field, arr, delimiter, digts)

            arr = string(round(arr,digts));
            allOneString = sprintf('%s'+delimiter, arr);
            field.Value = allOneString;


        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION TO CREATE A TEXT DISPLAY OF A POLYNOMIAL
        function auxmsgNum = array2StringPolynomial(app, n)
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION TO UPDATE POLE/ZERO PLOT AND NUMERICAL DISPLAY
        function updatePoleZeroPlot(app)

            hold(app.PolesZerosAxis,'off');
            [p,z] = pzmap(app.plantTrFcn);
            app.G0 = dcgain(app.plantTrFcn);
            app.poles_saved = p;
            app.zeros_saved = z;

            zReal = round(real(z),3,'significant');
            zImag = round(imag(z),3,'significant');
            pReal = round(real(p),3,'significant');
            pImag = round(imag(p),3,'significant');

            app.poles=plot(app.PolesZerosAxis, pReal, pImag,"x", ...
                "MarkerSize",15,'linewidth',3, ...
                'buttondownfcn',{@app.Mouse_Callback,'down'});
            hold(app.PolesZerosAxis,'on');
            app.zeros=plot(app.PolesZerosAxis,zReal, zImag,"o", "MarkerSize",15,'linewidth',3, ...
                'buttondownfcn',{@app.Mouse_Callback,'down'});

            app.updateTextFieldFromArray(app.ClosedLoopPolesDisp, p',"\t", 3)
            app.updateTextFieldFromArray(app.ClosedLoopZerosDisp, z', "\t", 3)

            % Update step response
            % calculation of step responses in time 
            h=step(app.plantTrFcn,app.t);
            plot(app.UIAxesY,app.t,h); 
            
            % rescale axis if needed
            rescale(app)
                       
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTION TO UPDATE POLE/ZERO PLOT 
% %%%%%%%%%% AFTER MOUSE MOVE 
        function updatePoleZeroPlot2(app)
            % Update model
            
            p = app.poles.XData+j*app.poles.YData;
            p = (p+conj(p))/2;
            if length(app.zeros)==0;
                G =zpk([],p, app.G0);
            else
                z = app.zeros.XData+j*app.zeros.YData;
                z = (z+conj(z))/2;
                G =zpk([z],p, app.G0);
            end
            
            [n,d]=tfdata(G,'v');
            app.numerator=n(2:end);
            if n(1)==0;n=n(2:end);end
            app.denumerator=d;
            %
            app.updateTextFieldFromArray(app.ClosedLoopPolesDisp, p',"\t", 3)
            if length(app.zeros)>0;
                app.updateTextFieldFromArray(app.ClosedLoopZerosDisp, z', "\t", 3)
            end
            app.updateTransferFunctionRender(real(n(2:end)), real(d));
            % Update step response
            % calculation of step responses in time 
            h=step(G,app.t);
            plot(app.UIAxesY,app.t,h); 
            
            rescale(app)
           
        end
           
        
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %%%%%%%%%%%% SUBFUNCTION to be used when any of the buttons in the random example are
        % selected
        function app = createrandomexample(app)

           % Stable or unstable poles
           
           if strcmp(app.StableorunstablepolesDropDown.Value,'Stable only'); % only stable poles
            psec=[-10:-1]; 
            psec2 = [-1+j,-2+j,-3+j,-1+2j,-2+2j,-1+3j,-5+j,-5+5j];          
           else
            psec=[-10:-1,1:0.5:5]; 
            psec2 = [-1+j,-2+j,-3+j,-1+2j,-2+2j,-1+3j,-5+j,-5+5j,1+j,2+j,1.5+j,0.5+j];
           end          
           lp=length(psec);
           lp2=length(psec2);
                  
           % random selection from allowable poles         
           if strcmp(app.LoworhighorderDropDown.Value,'Low order')                
               np=2;nz=np-1;compn=0;compd=(randi([1,2],1,1)-1)*2;
             else
               rn=rand(1);rd=rand(1);
               nz= randi([1,3],1,1);
               np= randi([nz+1,5],1,1);
           p=[];
           if rn>0.6;compn=2;
           elseif and(rn>0.9,nz>=4);compn=4;
           else compn=0;    
           end
            if rd>0.5;compd=2;
           elseif and(rd>0.8,np>=4);compd=4;
           else compd=0;    
            end
           end
           
           % Ony real roots or complex
           if strcmp(app.RealorcomplexpolesDropDown.Value,'Real poles only');
               compd=0;end
                  
           p1=randi([1,lp],np-compd,1);
           if compd>0;p2 = randi([1,lp2],compd/2,1);else p2=[];end
           poles = [psec2(p2)]; poles= [poles,conj(poles)];
           poles = [poles,psec(p1)];
           
           nsec=[-10.5:4.5]; lm=length(nsec);
           n1=randi([1,lm],nz-compn,1);
           nsec2 = [-1+j,-2+j,-3+j,-1+2j,-2+2j,-1+3j,-5+j,-5+5j,1+j,2+j]+0.3;
           lm2=length(nsec2);
           if compn>0;n2 = randi([1,lm2],compn/2,1);else n2=[];end
           zeross = [nsec2(n2)]; zeross= [zeross,conj(zeross)];
           zeross = [zeross,nsec(n1)];
           
           d=poly(poles);
           n=poly(zeross); if isempty(n);n=1;end
           app.updateTransferFunctionRender(n, d);

           % save results into app
           app.numerator=n;
           app.denumerator=d;
           app.plantTrFcn = tf(app.numerator,app.denumerator);
           updatePoleZeroPlot(app)
         
        end

        % rescale axis if needed
        function rescale(app)
           
            xmin = min([real(app.zeros_saved(:))',real(app.poles_saved(:))'])-0.1;
            xmax = max([real(app.zeros_saved(:))',real(app.poles_saved(:))'])+0.1;
            xlim(app.PolesZerosAxis,[xmin,xmax]);
            ymin = min([imag(app.zeros_saved(:))',imag(app.poles_saved(:))'])-0.1;
            ymax = max([imag(app.zeros_saved(:))',imag(app.poles_saved(:))'])+0.1;
            ylim(app.PolesZerosAxis,[ymin,ymax]);
            
            
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%  Callback function for using the mouse to move poles and zeros

        function Mouse_Callback(app,hObj,~,action) 
        % we made the persistant variables into properties 
        pos = get(app.PolesZerosAxis,'CurrentPoint'); 
        switch action 
            case 'down'
            app.PolesZerosAxis.XLimMode = 'manual';   %to allow movement without messing up the axes
            app.PolesZerosAxis.YLimMode = 'manual';  

            app.curobj = hObj; 
            app.xdata = get(hObj,'xdata'); 
            app.ydata = get(hObj,'ydata'); 
            [~,app.ind] = min(sum((app.xdata-pos(1)).^2+(app.ydata-pos(3)).^2,1)); 
            set(app.UIFigure,... 
                'WindowButtonMotionFcn', {@app.Mouse_Callback,'move'},... 
                'WindowButtonUpFcn', {@app.Mouse_Callback,'up'}); 
            case 'move' 
                % horizontal move 
                 app.xdata(app.ind) = pos(1); 
                 set(app.curobj,'xdata',app.xdata) 
                 % vertical move 
                 app.ydata(app.ind) = pos(3);
                 set(app.curobj,'ydata',app.ydata) 
                
            case 'up' 
                set(app.UIFigure,... %this needs to be the "Figure" not "Axes"
                    'WindowButtonMotionFcn', '',...
                    'WindowButtonUpFcn', ''); 
                app.PolesZerosAxis.XLimMode = 'auto';  %recenters around the points if required
                app.PolesZerosAxis.YLimMode = 'auto';  
        end
          
% edit poles and zeros so that movs consistent.
% real stay real and complex in pairs
   
        % check poles
        pnew = app.poles.XData+j*app.poles.YData;
        out = consistentroots(app,app.poles_saved,pnew);
        app.poles_saved=out;
        app.poles.XData = real(out);
        app.poles.YData = imag(out);
        % check zeros
        if length(app.zeros)>0;
         znew = app.zeros.XData+j*app.zeros.YData;
         out = consistentroots(app,app.zeros_saved,znew);
        app.zeros_saved=out;
        app.zeros.XData = real(out);
        app.zeros.YData = imag(out);
        end 
        
        updatePoleZeroPlot2(app);

        

        end
        %%% end of mouse call back

% edit poles and zeros so that move consistent.
% real stay real and complex in pairs
% only use where order greater than one
function results = consistentroots(app,rold,rnew);
    
    % saved roots given here and sorted  
    rold = sort(rold,'ascend','ComparisonMethod','real');
    rnew = sort(rnew,'ascend','ComparisonMethod','real');
    order = length(rold);  % number of roots
    % Find position of changed root
    f=(rold==rnew);
    [p,p1]=sort(f);
    pos = p1(1); % position where roots differ

% need to check if original root was complex
new_imag_component = imag(rold(pos)); 
complexnotzero = (abs(new_imag_component)>1e-12);
if and(complexnotzero,order>1); % part of a conjugage pair
    if new_imag_component<0;
        rnew(pos+1)=conj(rnew(pos));
    else
        rnew(pos-1)=conj(rnew(pos));
    end
else
    %force to stay real
    rnew(pos)=real(rnew(pos));
end

results = rnew; % new root positions
results = round(results,3,'significant');
     
end  % end of consistent roots
        
    end  %  end of subfunctions
    %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% SUBFUNCTIONS BELOW ACT WHEN A COMPONENT IS SELECTED IN THE
%%%%%%%%%%%% INTERFACE. LARGELY THE CODE IS MINIMAL AND SELF-EXPLANATORY

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % resize to be in middle of  the window
            movegui(app.UIFigure)
            
            % variables to manage re-sizing. Save values at start up
            position = app.UIFigure.Position;
            app.originalsize = position(3)*position(4);
            app.t = linspace(0,app.endtime,app.samples);
            model = app.ChoosePlantDropDown.Value;
            
            app.plantTrFcn = app.exampleTransferFcn(model);
            [n,d] = tfdata(app.plantTrFcn,'v');
            app.numerator=n;
            app.denumerator=d;
            app.G0 = dcgain(app.plantTrFcn);
            updatePoleZeroPlot(app);

            % Open the manual
            if exist('behaviours_mycopy.mlx','file')
                disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
                open behaviours_mycopy.mlx
            else
                p1 = which('behaviours_manual.mlx');
                p2 = strcat(pwd,'/behaviours_mycopy.mlx');
                copyfile(p1,p2)             
                open behaviours_mycopy.mlx
                clear p1 p2
            end

            if ~isMATLABReleaseOlderThan('R2025a') %%(as in it is newer than 25a)
            theme(app.UIFigure,"light")
            end
        end

        % Value changed function: ChoosePlantDropDown
        function ChoosePlantDropDownValueChanged(app, event)
            
            value = app.ChoosePlantDropDown.Value;
            app.plantTrFcn = app.exampleTransferFcn(value);
            updatePoleZeroPlot(app);
            [n,d] = tfdata(app.plantTrFcn,'v');
            app.numerator=n;
            app.denumerator=d;
            
        end

        % Value changed function: NumCustom
        function NumCustomValueChanged(app, event)
            value = app.NumCustom.Value;
            
            if isempty(value);value ='1';app.NumCustom.Value=value;end
            app.numerator=str2num(value);
            app.plantTrFcn = tf(app.numerator,app.denumerator);
            app.updateTransferFunctionRender(app.numerator,app.denumerator);
            updatePoleZeroPlot(app);

        end

        % Value changed function: DenCustom
        function DenCustomValueChanged(app, event)
            value = app.DenCustom.Value;
            if isempty(value);value ='1 2';app.DenCustom.Value=value;end
            app.denumerator=str2num(value);
            app.plantTrFcn = tf(app.numerator,app.denumerator);
            app.updateTransferFunctionRender(app.numerator,app.denumerator);
            updatePoleZeroPlot(app);
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

        % Selection change function: TabGroup
        function TabGroupSelectionChanged(app, event)
            selectedTab = app.TabGroup.SelectedTab.Title;
            
            switch selectedTab;
                case 'Custom';
                  app.numerator = str2num(app.NumCustom.Value);
                  app.denumerator = str2num(app.DenCustom.Value);
                  app.plantTrFcn = tf(app.numerator,app.denumerator);
                  app.updateTransferFunctionRender(app.numerator,app.denumerator);
                case 'Example';
                    model = app.ChoosePlantDropDown.Value;      
                    app.plantTrFcn = app.exampleTransferFcn(model);
                    app.updateTransferFunctionRender(app.numerator,app.denumerator);
                case 'Random choice';
                    app = createrandomexample(app);
            end
            updatePoleZeroPlot(app);
        end

        % Value changed function: RealorcomplexpolesDropDown
        function RealorcomplexpolesDropDownValueChanged(app, event)
            app = createrandomexample(app);
        end

        % Value changed function: LoworhighorderDropDown
        function LoworhighorderDropDownValueChanged(app, event)
           app = createrandomexample(app);
            
        end

        % Value changed function: StableorunstablepolesDropDown
        function StableorunstablepolesDropDownValueChanged(app, event)
            
            app = createrandomexample(app);
        end

        % Button pushed function: CreatenewrandomexampleButton
        function CreatenewrandomexampleButtonPushed(app, event)
            app = createrandomexample(app);
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
            app.UIFigure.Position = [100 100 1167 812];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @UIFigureSizeChanged, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '2x'};
            app.GridLayout.RowHeight = {'3x'};
            app.GridLayout.Scrollable = 'on';

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x'};
            app.GridLayout2.RowHeight = {'5x', '1.5x', '1.5x'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = 1;

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout2);
            app.GridLayout5.ColumnWidth = {'1x'};
            app.GridLayout5.RowHeight = {'1x', '4x'};
            app.GridLayout5.ColumnSpacing = 0;
            app.GridLayout5.RowSpacing = 0;
            app.GridLayout5.Layout.Row = 1;
            app.GridLayout5.Layout.Column = 1;
            app.GridLayout5.Scrollable = 'on';
            app.GridLayout5.BackgroundColor = [0.902 1 0.502];

            % Create PlanttransferfunctionGsLabel
            app.PlanttransferfunctionGsLabel = uilabel(app.GridLayout5);
            app.PlanttransferfunctionGsLabel.BackgroundColor = [1 1 0];
            app.PlanttransferfunctionGsLabel.HorizontalAlignment = 'center';
            app.PlanttransferfunctionGsLabel.FontSize = 18;
            app.PlanttransferfunctionGsLabel.FontWeight = 'bold';
            app.PlanttransferfunctionGsLabel.Layout.Row = 1;
            app.PlanttransferfunctionGsLabel.Layout.Column = 1;
            app.PlanttransferfunctionGsLabel.Text = 'Plant transfer function G(s)';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout5);
            app.TabGroup.AutoResizeChildren = 'off';
            app.TabGroup.SelectionChangedFcn = createCallbackFcn(app, @TabGroupSelectionChanged, true);
            app.TabGroup.Layout.Row = 2;
            app.TabGroup.Layout.Column = 1;

            % Create ExampleTab
            app.ExampleTab = uitab(app.TabGroup);
            app.ExampleTab.AutoResizeChildren = 'off';
            app.ExampleTab.Title = 'Example';
            app.ExampleTab.BackgroundColor = [0.902 1 0.502];
            app.ExampleTab.Scrollable = 'on';

            % Create GridLayout19
            app.GridLayout19 = uigridlayout(app.ExampleTab);
            app.GridLayout19.RowHeight = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout19.BackgroundColor = [0.902 1 0.502];

            % Create DenominatorLabel
            app.DenominatorLabel = uilabel(app.GridLayout19);
            app.DenominatorLabel.HorizontalAlignment = 'center';
            app.DenominatorLabel.FontSize = 18;
            app.DenominatorLabel.Enable = 'off';
            app.DenominatorLabel.Layout.Row = 3;
            app.DenominatorLabel.Layout.Column = 1;
            app.DenominatorLabel.Text = 'Denominator';

            % Create DenExample
            app.DenExample = uieditfield(app.GridLayout19, 'text');
            app.DenExample.Editable = 'off';
            app.DenExample.FontSize = 18;
            app.DenExample.Enable = 'off';
            app.DenExample.Layout.Row = 3;
            app.DenExample.Layout.Column = 2;
            app.DenExample.Value = '1 1';

            % Create NumeratorLabel
            app.NumeratorLabel = uilabel(app.GridLayout19);
            app.NumeratorLabel.HorizontalAlignment = 'center';
            app.NumeratorLabel.FontSize = 18;
            app.NumeratorLabel.Enable = 'off';
            app.NumeratorLabel.Layout.Row = 2;
            app.NumeratorLabel.Layout.Column = 1;
            app.NumeratorLabel.Text = 'Numerator';

            % Create NumExample
            app.NumExample = uieditfield(app.GridLayout19, 'text');
            app.NumExample.Editable = 'off';
            app.NumExample.FontSize = 18;
            app.NumExample.Enable = 'off';
            app.NumExample.Layout.Row = 2;
            app.NumExample.Layout.Column = 2;
            app.NumExample.Value = '1 0';

            % Create ChooseplantLabel
            app.ChooseplantLabel = uilabel(app.GridLayout19);
            app.ChooseplantLabel.HorizontalAlignment = 'center';
            app.ChooseplantLabel.FontSize = 18;
            app.ChooseplantLabel.Layout.Row = 1;
            app.ChooseplantLabel.Layout.Column = 1;
            app.ChooseplantLabel.Text = 'Choose plant';

            % Create ChoosePlantDropDown
            app.ChoosePlantDropDown = uidropdown(app.GridLayout19);
            app.ChoosePlantDropDown.Items = {'First order', 'Second order', 'Under-damped', 'High-order'};
            app.ChoosePlantDropDown.ValueChangedFcn = createCallbackFcn(app, @ChoosePlantDropDownValueChanged, true);
            app.ChoosePlantDropDown.FontSize = 18;
            app.ChoosePlantDropDown.Layout.Row = 1;
            app.ChoosePlantDropDown.Layout.Column = 2;
            app.ChoosePlantDropDown.Value = 'First order';

            % Create CustomTab
            app.CustomTab = uitab(app.TabGroup);
            app.CustomTab.AutoResizeChildren = 'off';
            app.CustomTab.Title = 'Custom';
            app.CustomTab.BackgroundColor = [0.902 1 0.502];

            % Create GridLayout20
            app.GridLayout20 = uigridlayout(app.CustomTab);
            app.GridLayout20.RowHeight = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout20.BackgroundColor = [0.902 1 0.502];

            % Create DenominatorLabel_2
            app.DenominatorLabel_2 = uilabel(app.GridLayout20);
            app.DenominatorLabel_2.HorizontalAlignment = 'center';
            app.DenominatorLabel_2.FontSize = 18;
            app.DenominatorLabel_2.Layout.Row = 2;
            app.DenominatorLabel_2.Layout.Column = 1;
            app.DenominatorLabel_2.Text = 'Denominator';

            % Create DenCustom
            app.DenCustom = uieditfield(app.GridLayout20, 'text');
            app.DenCustom.ValueChangedFcn = createCallbackFcn(app, @DenCustomValueChanged, true);
            app.DenCustom.FontSize = 18;
            app.DenCustom.Layout.Row = 2;
            app.DenCustom.Layout.Column = 2;
            app.DenCustom.Value = '1 5 6';

            % Create NumeratorLabel_2
            app.NumeratorLabel_2 = uilabel(app.GridLayout20);
            app.NumeratorLabel_2.HorizontalAlignment = 'center';
            app.NumeratorLabel_2.FontSize = 18;
            app.NumeratorLabel_2.Layout.Row = 1;
            app.NumeratorLabel_2.Layout.Column = 1;
            app.NumeratorLabel_2.Text = 'Numerator';

            % Create NumCustom
            app.NumCustom = uieditfield(app.GridLayout20, 'text');
            app.NumCustom.ValueChangedFcn = createCallbackFcn(app, @NumCustomValueChanged, true);
            app.NumCustom.FontSize = 18;
            app.NumCustom.Layout.Row = 1;
            app.NumCustom.Layout.Column = 2;
            app.NumCustom.Value = '1 1';

            % Create RandomchoiceTab
            app.RandomchoiceTab = uitab(app.TabGroup);
            app.RandomchoiceTab.Title = 'Random choice';

            % Create GridLayout18
            app.GridLayout18 = uigridlayout(app.RandomchoiceTab);
            app.GridLayout18.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout18.BackgroundColor = [0.902 1 0.502];

            % Create RealorcomplexpolesDropDownLabel
            app.RealorcomplexpolesDropDownLabel = uilabel(app.GridLayout18);
            app.RealorcomplexpolesDropDownLabel.BackgroundColor = [0 1 0];
            app.RealorcomplexpolesDropDownLabel.HorizontalAlignment = 'right';
            app.RealorcomplexpolesDropDownLabel.FontSize = 18;
            app.RealorcomplexpolesDropDownLabel.Layout.Row = 1;
            app.RealorcomplexpolesDropDownLabel.Layout.Column = 1;
            app.RealorcomplexpolesDropDownLabel.Text = 'Real or complex poles';

            % Create RealorcomplexpolesDropDown
            app.RealorcomplexpolesDropDown = uidropdown(app.GridLayout18);
            app.RealorcomplexpolesDropDown.Items = {'Real poles only', 'Allow complex poles'};
            app.RealorcomplexpolesDropDown.ValueChangedFcn = createCallbackFcn(app, @RealorcomplexpolesDropDownValueChanged, true);
            app.RealorcomplexpolesDropDown.FontSize = 18;
            app.RealorcomplexpolesDropDown.Layout.Row = 1;
            app.RealorcomplexpolesDropDown.Layout.Column = 2;
            app.RealorcomplexpolesDropDown.Value = 'Real poles only';

            % Create LoworhighorderDropDownLabel
            app.LoworhighorderDropDownLabel = uilabel(app.GridLayout18);
            app.LoworhighorderDropDownLabel.BackgroundColor = [0 1 0];
            app.LoworhighorderDropDownLabel.HorizontalAlignment = 'right';
            app.LoworhighorderDropDownLabel.FontSize = 18;
            app.LoworhighorderDropDownLabel.Layout.Row = 3;
            app.LoworhighorderDropDownLabel.Layout.Column = 1;
            app.LoworhighorderDropDownLabel.Text = 'Low or high order';

            % Create LoworhighorderDropDown
            app.LoworhighorderDropDown = uidropdown(app.GridLayout18);
            app.LoworhighorderDropDown.Items = {'Low order', 'High order'};
            app.LoworhighorderDropDown.ValueChangedFcn = createCallbackFcn(app, @LoworhighorderDropDownValueChanged, true);
            app.LoworhighorderDropDown.FontSize = 18;
            app.LoworhighorderDropDown.Layout.Row = 3;
            app.LoworhighorderDropDown.Layout.Column = 2;
            app.LoworhighorderDropDown.Value = 'Low order';

            % Create StableorunstablepolesDropDownLabel
            app.StableorunstablepolesDropDownLabel = uilabel(app.GridLayout18);
            app.StableorunstablepolesDropDownLabel.BackgroundColor = [0 1 0];
            app.StableorunstablepolesDropDownLabel.HorizontalAlignment = 'right';
            app.StableorunstablepolesDropDownLabel.FontSize = 18;
            app.StableorunstablepolesDropDownLabel.Layout.Row = 2;
            app.StableorunstablepolesDropDownLabel.Layout.Column = 1;
            app.StableorunstablepolesDropDownLabel.Text = 'Stable or unstable poles';

            % Create StableorunstablepolesDropDown
            app.StableorunstablepolesDropDown = uidropdown(app.GridLayout18);
            app.StableorunstablepolesDropDown.Items = {'Stable only', 'Allow unstable poles'};
            app.StableorunstablepolesDropDown.ValueChangedFcn = createCallbackFcn(app, @StableorunstablepolesDropDownValueChanged, true);
            app.StableorunstablepolesDropDown.FontSize = 18;
            app.StableorunstablepolesDropDown.Layout.Row = 2;
            app.StableorunstablepolesDropDown.Layout.Column = 2;
            app.StableorunstablepolesDropDown.Value = 'Stable only';

            % Create CreatenewrandomexampleButton
            app.CreatenewrandomexampleButton = uibutton(app.GridLayout18, 'push');
            app.CreatenewrandomexampleButton.ButtonPushedFcn = createCallbackFcn(app, @CreatenewrandomexampleButtonPushed, true);
            app.CreatenewrandomexampleButton.WordWrap = 'on';
            app.CreatenewrandomexampleButton.BackgroundColor = [0 1 0];
            app.CreatenewrandomexampleButton.FontSize = 24;
            app.CreatenewrandomexampleButton.Layout.Row = 4;
            app.CreatenewrandomexampleButton.Layout.Column = [1 2];
            app.CreatenewrandomexampleButton.Text = 'Create new random example';

            % Create OpenlooppolesandzerosPanel
            app.OpenlooppolesandzerosPanel = uipanel(app.GridLayout2);
            app.OpenlooppolesandzerosPanel.AutoResizeChildren = 'off';
            app.OpenlooppolesandzerosPanel.TitlePosition = 'centertop';
            app.OpenlooppolesandzerosPanel.Title = 'Open-loop poles and zeros';
            app.OpenlooppolesandzerosPanel.BackgroundColor = [0.902 0.2 1];
            app.OpenlooppolesandzerosPanel.Layout.Row = 3;
            app.OpenlooppolesandzerosPanel.Layout.Column = 1;
            app.OpenlooppolesandzerosPanel.FontWeight = 'bold';
            app.OpenlooppolesandzerosPanel.FontSize = 16;

            % Create GridLayout15
            app.GridLayout15 = uigridlayout(app.OpenlooppolesandzerosPanel);
            app.GridLayout15.ColumnWidth = {'0.4x', '1x', '1x'};
            app.GridLayout15.Scrollable = 'on';
            app.GridLayout15.BackgroundColor = [0.902 0.702 1];

            % Create ClosedLoopPolesLabel
            app.ClosedLoopPolesLabel = uilabel(app.GridLayout15);
            app.ClosedLoopPolesLabel.FontSize = 18;
            app.ClosedLoopPolesLabel.Layout.Row = 1;
            app.ClosedLoopPolesLabel.Layout.Column = 1;
            app.ClosedLoopPolesLabel.Text = 'Poles';

            % Create ClosedLoopPolesDisp
            app.ClosedLoopPolesDisp = uieditfield(app.GridLayout15, 'text');
            app.ClosedLoopPolesDisp.Editable = 'off';
            app.ClosedLoopPolesDisp.FontSize = 18;
            app.ClosedLoopPolesDisp.Layout.Row = 1;
            app.ClosedLoopPolesDisp.Layout.Column = [2 3];

            % Create ClosedLoopZerosLabel
            app.ClosedLoopZerosLabel = uilabel(app.GridLayout15);
            app.ClosedLoopZerosLabel.FontSize = 18;
            app.ClosedLoopZerosLabel.Layout.Row = 2;
            app.ClosedLoopZerosLabel.Layout.Column = 1;
            app.ClosedLoopZerosLabel.Text = 'Zeros';

            % Create ClosedLoopZerosDisp
            app.ClosedLoopZerosDisp = uieditfield(app.GridLayout15, 'text');
            app.ClosedLoopZerosDisp.Editable = 'off';
            app.ClosedLoopZerosDisp.FontSize = 18;
            app.ClosedLoopZerosDisp.Layout.Row = 2;
            app.ClosedLoopZerosDisp.Layout.Column = [2 3];

            % Create ShowTransferFunction
            app.ShowTransferFunction = uilabel(app.GridLayout2);
            app.ShowTransferFunction.BackgroundColor = [0.902 1 0.502];
            app.ShowTransferFunction.HorizontalAlignment = 'center';
            app.ShowTransferFunction.FontSize = 24;
            app.ShowTransferFunction.Layout.Row = 2;
            app.ShowTransferFunction.Layout.Column = 1;
            app.ShowTransferFunction.Interpreter = 'latex';
            app.ShowTransferFunction.Text = '$\frac{s}{s+1}$';

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.GridLayout);
            app.GridLayout9.ColumnWidth = {'1x'};
            app.GridLayout9.RowHeight = {'0.3x', '1x', '1x'};
            app.GridLayout9.ColumnSpacing = 0;
            app.GridLayout9.RowSpacing = 0;
            app.GridLayout9.Padding = [0 0 0 0];
            app.GridLayout9.Layout.Row = 1;
            app.GridLayout9.Layout.Column = 2;

            % Create PolesZerosAxis
            app.PolesZerosAxis = uiaxes(app.GridLayout9);
            title(app.PolesZerosAxis, 'Closed-loop poles and zeros')
            xlabel(app.PolesZerosAxis, 'Real')
            ylabel(app.PolesZerosAxis, 'Imaginary')
            zlabel(app.PolesZerosAxis, 'Z')
            app.PolesZerosAxis.XGrid = 'on';
            app.PolesZerosAxis.YGrid = 'on';
            app.PolesZerosAxis.FontSize = 16;
            app.PolesZerosAxis.Layout.Row = 3;
            app.PolesZerosAxis.Layout.Column = 1;

            % Create UIAxesY
            app.UIAxesY = uiaxes(app.GridLayout9);
            title(app.UIAxesY, 'Output response')
            xlabel(app.UIAxesY, 'Time(s)')
            ylabel(app.UIAxesY, 'y(t)')
            zlabel(app.UIAxesY, 'Z')
            app.UIAxesY.XGrid = 'on';
            app.UIAxesY.YGrid = 'on';
            app.UIAxesY.FontSize = 16;
            app.UIAxesY.Layout.Row = 2;
            app.UIAxesY.Layout.Column = 1;

            % Create GridLayout5_2
            app.GridLayout5_2 = uigridlayout(app.GridLayout9);
            app.GridLayout5_2.ColumnWidth = {'1.8x', '1x'};
            app.GridLayout5_2.RowHeight = {'1x'};
            app.GridLayout5_2.Layout.Row = 1;
            app.GridLayout5_2.Layout.Column = 1;
            app.GridLayout5_2.BackgroundColor = [0.6 1 1];

            % Create BehaviouroflinearmodelsLabel
            app.BehaviouroflinearmodelsLabel = uilabel(app.GridLayout5_2);
            app.BehaviouroflinearmodelsLabel.BackgroundColor = [0 1 1];
            app.BehaviouroflinearmodelsLabel.HorizontalAlignment = 'center';
            app.BehaviouroflinearmodelsLabel.FontSize = 24;
            app.BehaviouroflinearmodelsLabel.FontWeight = 'bold';
            app.BehaviouroflinearmodelsLabel.Layout.Row = 1;
            app.BehaviouroflinearmodelsLabel.Layout.Column = 1;
            app.BehaviouroflinearmodelsLabel.Text = 'Behaviour of linear models';

            % Create Image
            app.Image = uiimage(app.GridLayout5_2);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 2;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'UoSlogo.png');

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = behaviours

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

