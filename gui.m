classdef gui < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        SourcePanel             matlab.ui.container.Panel
        Label                   matlab.ui.control.Label
        BrowseSourceButton      matlab.ui.control.Button
        UIAxes                  matlab.ui.control.UIAxes
        UIAxes_2                matlab.ui.control.UIAxes
        DropDown                matlab.ui.control.DropDown
        WatermarkPanel          matlab.ui.container.Panel
        BrowseWMButton          matlab.ui.control.Button
        Label_2                 matlab.ui.control.Label
        UIAxes_3                matlab.ui.control.UIAxes
        UIAxes_4                matlab.ui.control.UIAxes
        UIAxes_5                matlab.ui.control.UIAxes
        DropDown_2              matlab.ui.control.DropDown
        ResultsPanel            matlab.ui.container.Panel
        EmbedButton             matlab.ui.control.Button
        ExtractButton           matlab.ui.control.Button
        UIAxes_6                matlab.ui.control.UIAxes
        UIAxes_7                matlab.ui.control.UIAxes
        EditField               matlab.ui.control.NumericEditField
        EmbeddingStrengthLabel  matlab.ui.control.Label
        SaveButton              matlab.ui.control.Button
        Logic
    end

    methods (Access = private)

        % Button pushed function: BrowseSourceButton
        function BrowseSourceButtonPushed(app, ~)
            
            % Allow only some image extensions for selection from dialog box
            [file,path] = uigetfile({'*.jpg';'*.jpeg';'*.png';'*.tiff';'*.bmp';'*.tif'});
             
            % If file is selected
            if ~isequal(file,0)
                if size(imread(fullfile(path,file)),3) == 3
                    app.DropDown.Enable = 'on';
                else
                    app.DropDown.Value = 'Grayscale';
                    title(app.UIAxes_2, app.DropDown.Value);
                    app.DropDown.Enable = 'off';
                end
                app.UIFigure.Visible = 'off';
                app.UIFigure.Visible = 'on'; 
                
            	% Get Component Type
                type = app.DropDown.Value;
                
                app.Logic.initializeSource(fullfile(path,file),type);
                
                % Show filename in Label
                set(app.Label,'Text',file);
                
                % Display image in 1st Box
                imshow(fullfile(path,file),'Parent',app.UIAxes);
                
                % Display image in 2nd Box
                imshow(app.Logic.SourceImage,'Parent',app.UIAxes_2);
                
                % Enable EmbedButton and Strength Field if EmbedEnable is
                % set
                if app.Logic.EmbedEnable
                    app.EmbedButton.Enable = 'on';
                    app.EditField.Enable = 'on';
                end
                
                % Enable WMButton and it's component dropdown
                app.BrowseWMButton.Enable = 'on';
                app.DropDown_2.Enable = 'on';
            end
            
        end
        
        % Button pushed function: BrowseWMButton
        function BrowseWMButtonPushed(app, ~)
           
            % Allow only some image extensions for selection from dialog box
            [file,path] = uigetfile({'*.jpg';'*.jpeg';'*.png';'*.tiff';'*.bmp';'*.tif'});

            % If file is selected
            if ~isequal(file,0)
                if size(imread(fullfile(path,file)),3) == 3
                    app.DropDown_2.Enable = 'on';
                else
                    app.DropDown_2.Value = 'Grayscale';
                    title(app.UIAxes_4, app.DropDown_2.Value);
                    app.DropDown_2.Enable = 'off';
                end
                app.UIFigure.Visible = 'off';
                app.UIFigure.Visible = 'on'; 
                
                % Get Component Type
                type = app.DropDown_2.Value;
                alteredWM = app.Logic.initializeWM(fullfile(path,file),type);
                
                % Show filename in Label2
                set(app.Label_2,'Text',file);
                
                % Display image in 3rd Box
                imshow(fullfile(path,file),'Parent',app.UIAxes_3);
                
                % Display image in 4th Box
                imshow(alteredWM,'Parent',app.UIAxes_4);
                
                % Display image in 5th Box
                imshow(app.Logic.WMImage,'Parent',app.UIAxes_5);  
                
                % Enable EmbedButton and Strength Field if EmbedEnable is
                % set
                if app.Logic.EmbedEnable
                    app.EmbedButton.Enable = 'on';
                    app.EditField.Enable = 'on';
                end
            end
            
        end
        
        % Button pushed function: EmbedButton
        function EmbedButtonPushed(app, ~)
            
            % Get Embedding Strength from input
            alpha = app.EditField.Value;
            
            % Embed the watermark
            app.Logic.embed(alpha);
            
            % Display image in 6th Box
            imshow(app.Logic.WatermarkedImage,'Parent',app.UIAxes_6);
            
            title(app.UIAxes_6, ['Result: A=',num2str(alpha)])
            
            % Enable ExtractButton
            app.ExtractButton.Enable = 'on';
            
            % Enable SaveButton
            app.SaveButton.Enable = 'on';
        end

        % Button pushed function: ExtractButton
        function ExtractButtonPushed(app, ~)
            
            % Fetch ExtractedImage Object
            ExtractedImage = app.Logic.extract();
            
            % Display image in 7th Box
            imshow(ExtractedImage,'Parent',app.UIAxes_7);
            
            title(app.UIAxes_7, ['Extracted Image: A=',num2str(app.Logic.Alpha)])
        end
        
        % Button pushed function: SaveButton
        function SaveButtonPushed(app, ~)
            
            % Open Save Image dialog
            [fn, ext, ucancel] = imputfile;
            
            if ~isequal(ucancel,1)
                imwrite(app.Logic.WatermarkedImage,fn,ext);
            end
            
            app.UIFigure.Visible = 'off';
            app.UIFigure.Visible = 'on';
            
        end
        
        % Value changed function: DropDown
        function DropDownValueChanged(app, ~)
            % Change title
            title(app.UIAxes_2, app.DropDown.Value);
            
            % Re-evaluate image
            if ~isempty(app.Logic.SourceFile)
                app.Logic.initializeSource(app.Logic.SourceFile,app.DropDown.Value);
                imshow(app.Logic.SourceImage,'Parent',app.UIAxes_2);
            end
        end
        
        % Value changed function: DropDown_2
        function DropDown_2ValueChanged(app, ~)
            
            % Change title
            title(app.UIAxes_4, app.DropDown_2.Value);
            
            % Re-evaluate image
            if ~isempty(app.Logic.WMFile)
                alteredWM = app.Logic.initializeWM(app.Logic.WMFile,app.DropDown_2.Value);
                imshow(alteredWM,'Parent',app.UIAxes_4);
                imshow(app.Logic.WMImage,'Parent',app.UIAxes_5);  
            end
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Color = [0.5098 0.7451 1];
            app.UIFigure.Position = [100 100 1123 744];
            app.UIFigure.Name = 'DWT Watermarking';

            % Create SourcePanel
            app.SourcePanel = uipanel(app.UIFigure);
            app.SourcePanel.Title = 'Source';
            app.SourcePanel.BackgroundColor = [1 1 1];
            app.SourcePanel.Position = [20 509 777 224];

            % Create Label
            app.Label = uilabel(app.SourcePanel);
            app.Label.BackgroundColor = [0.8 0.8 0.8];
            app.Label.Position = [20 91 100 26];
            app.Label.Text = '';

            % Create BrowseSourceButton
            app.BrowseSourceButton = uibutton(app.SourcePanel, 'push');
            app.BrowseSourceButton.BackgroundColor = [0 0.451 0.7412];
            app.BrowseSourceButton.FontColor = [1 1 1];
            app.BrowseSourceButton.Position = [20 135 100 29];
            app.BrowseSourceButton.Text = 'Browse Source';

            % Create UIAxes
            app.UIAxes = uiaxes(app.SourcePanel);
            title(app.UIAxes, 'Original Image')
            app.UIAxes.Box = 'on';
            app.UIAxes.Color = [0 0.451 0.7412];
            app.UIAxes.Position = [139 12 300 185];

            % Create DropDown
            app.DropDown = uidropdown(app.SourcePanel);
            app.DropDown.Items = {'Grayscale', 'R Component', 'G Component', 'B Component'};
            app.DropDown.ValueChangedFcn = createCallbackFcn(app, @DropDownValueChanged, true);
            app.DropDown.Position = [21 45 100 22];
            app.DropDown.Value = 'Grayscale';
            
            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.SourcePanel);
            title(app.UIAxes_2, app.DropDown.Value)
            app.UIAxes_2.Box = 'on';
            app.UIAxes_2.Color = [0 0.451 0.7412];
            app.UIAxes_2.Position = [464 12 300 185];
            
            % Create WatermarkPanel
            app.WatermarkPanel = uipanel(app.UIFigure);
            app.WatermarkPanel.Title = 'Watermark';
            app.WatermarkPanel.Position = [20 269 1086 224];

            % Create BrowseWMButton
            app.BrowseWMButton = uibutton(app.WatermarkPanel, 'push');
            app.BrowseWMButton.BackgroundColor = [0 0.451 0.7412];
            app.BrowseWMButton.FontColor = [1 1 1];
            app.BrowseWMButton.Enable = 'off';
            app.BrowseWMButton.Position = [22 128 100 30];
            app.BrowseWMButton.Text = 'Browse WM';

            % Create Label_2
            app.Label_2 = uilabel(app.WatermarkPanel);
            app.Label_2.BackgroundColor = [0.8 0.8 0.8];
            app.Label_2.Position = [22 84 100 26];
            app.Label_2.Text = '';

            % Create UIAxes_3
            app.UIAxes_3 = uiaxes(app.WatermarkPanel);
            title(app.UIAxes_3, 'Watermark')
            app.UIAxes_3.Box = 'on';
            app.UIAxes_3.Color = [0 0.451 0.7412];
            app.UIAxes_3.Position = [139 9 300 185];

            % Create UIAxes_5
            app.UIAxes_5 = uiaxes(app.WatermarkPanel);
            title(app.UIAxes_5, 'Resized')
            app.UIAxes_5.Box = 'on';
            app.UIAxes_5.Color = [0 0.451 0.7412];
            app.UIAxes_5.Position = [776 9 300 185];

            % Create DropDown_2
            app.DropDown_2 = uidropdown(app.WatermarkPanel);
            app.DropDown_2.Items = {'Grayscale', 'R Component', 'G Component', 'B Component'};
            app.DropDown_2.ValueChangedFcn = createCallbackFcn(app, @DropDown_2ValueChanged, true);
            app.DropDown_2.Position = [22 43 100 22];
            app.DropDown_2.Value = 'Grayscale';
            app.DropDown_2.Enable = 'off';
            
            % Create UIAxes_4
            app.UIAxes_4 = uiaxes(app.WatermarkPanel);
            title(app.UIAxes_4, app.DropDown_2.Value)
            app.UIAxes_4.Box = 'on';
            app.UIAxes_4.Color = [0 0.451 0.7412];
            app.UIAxes_4.Position = [464 9 300 185];
            
            % Create ResultsPanel
            app.ResultsPanel = uipanel(app.UIFigure);
            app.ResultsPanel.Title = 'Results';
            app.ResultsPanel.Position = [20 12 777 236];

            % Create EmbedButton
            app.EmbedButton = uibutton(app.ResultsPanel, 'push');
            app.EmbedButton.BackgroundColor = [0 0.451 0.7412];
            app.EmbedButton.FontColor = [1 1 1];
            app.EmbedButton.Enable = 'off';
            app.EmbedButton.Position = [20 109 100 30];
            app.EmbedButton.Text = 'Embed';

            % Create ExtractButton
            app.ExtractButton = uibutton(app.ResultsPanel, 'push');
            app.ExtractButton.BackgroundColor = [0 0.451 0.7412];
            app.ExtractButton.FontColor = [1 1 1];
            app.ExtractButton.Enable = 'off';
            app.ExtractButton.Position = [20 21 100 30];
            app.ExtractButton.Text = 'Extract';

            % Create UIAxes_6
            app.UIAxes_6 = uiaxes(app.ResultsPanel);
            title(app.UIAxes_6, 'Result')
            app.UIAxes_6.Box = 'on';
            app.UIAxes_6.Color = [0 0.451 0.7412];
            app.UIAxes_6.Position = [139 21 300 185];

            % Create UIAxes_7
            app.UIAxes_7 = uiaxes(app.ResultsPanel);
            title(app.UIAxes_7, 'Extracted Watermark')
            app.UIAxes_7.Box = 'on';
            app.UIAxes_7.Color = [0 0.451 0.7412];
            app.UIAxes_7.Position = [464 21 300 185];

            % Create EditField
            app.EditField = uieditfield(app.ResultsPanel, 'numeric');
            app.EditField.Limits = [0 1];
            app.EditField.ValueDisplayFormat = '%.2f';
            app.EditField.Enable = 'off';
            app.EditField.Position = [20 148 100 22];
            app.EditField.Value = 0.75;
            
            % Create EmbeddingStrengthLabel
            app.EmbeddingStrengthLabel = uilabel(app.ResultsPanel);
            app.EmbeddingStrengthLabel.Position = [13 180 117 15];
            app.EmbeddingStrengthLabel.Text = 'Embedding Strength';
            
            % Create SaveButton
            app.SaveButton = uibutton(app.ResultsPanel, 'push');
            app.SaveButton.BackgroundColor = [0 0.451 0.7412];
            app.SaveButton.FontColor = [1 1 1];
            app.SaveButton.Enable = 'off';
            app.SaveButton.Position = [20 66 100 30];
            app.SaveButton.Text = 'Save';
            
            % Button Callbacks
            app.BrowseSourceButton.ButtonPushedFcn = createCallbackFcn(app, @BrowseSourceButtonPushed, true);
            app.BrowseWMButton.ButtonPushedFcn = createCallbackFcn(app, @BrowseWMButtonPushed, true);
            app.EmbedButton.ButtonPushedFcn = createCallbackFcn(app, @EmbedButtonPushed, true);
            app.ExtractButton.ButtonPushedFcn = createCallbackFcn(app, @ExtractButtonPushed, true);
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            
        end
    end

    methods (Access = public)

        % Construct app
        function app = gui
            
            % Object of logic class
            app.Logic = logic;
            
            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)
            
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