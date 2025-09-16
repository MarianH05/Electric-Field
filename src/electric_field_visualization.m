function electric_field_visualization()
    clear all;
    close all;
       fig = figure('Name', 'Electric Field Visualization', ...
                 'Position', [100, 100, 1200, 700], ...
                 'MenuBar', 'none', ...
                 'NumberTitle', 'off', ...
                 'CloseRequestFcn', @closeFigure);
    
    % Initialize charge storage
    charges = struct('x', [], 'y', [], 'q', []);
    
    % Create main axes
 ax = axes('Parent', fig, ...
              'Position', [0.05, 0.15, 0.65, 0.75], ...
              'Box', 'on', ...
              'GridLineStyle', '--', ...
              'GridAlpha', 0.3);
    hold(ax, 'on');
    % Set and lock axis limits so they never auto-rescale
    set(ax, 'XLim', [-10, 10], 'YLim', [-10, 10], ...
            'XLimMode', 'manual', 'YLimMode', 'manual');
    daspect(ax, [1 1 1]);  % preserve aspect ratio without changing limits
    grid(ax, 'on');
    xlabel(ax, 'X Position (m)');
    ylabel(ax, 'Y Position (m)');
    title(ax, 'Electric Field Visualization');
    
    % Control panel
    panel = uipanel('Parent', fig, ...
                    'Title', 'Controls', ...
                    'Position', [0.72, 0.15, 0.26, 0.75]);
    
    % Charge controls
    uicontrol('Parent', panel, 'Style', 'text', ...
              'String', 'Charge Magnitude (μC):', ...
              'Position', [10, 450, 150, 20], ...
              'HorizontalAlignment', 'left');
    
    chargeSlider = uicontrol('Parent', panel, 'Style', 'slider', ...
                             'Position', [10, 430, 150, 20], ...
                             'Min', 0, 'Max', 10, 'Value', 5, ...
                             'Callback', @updateChargeValue);
    
    chargeValueText = uicontrol('Parent', panel, 'Style', 'text', ...
                                'String', '5.0 μC', ...
                                'Position', [170, 430, 60, 20]);
    
    % Add charge buttons
    uicontrol('Parent', panel, 'Style', 'pushbutton', ...
              'String', 'Add Positive Charge', ...
              'Position', [10, 390, 120, 30], ...
              'Callback', @(~,~) addChargeMode(1));
    
    uicontrol('Parent', panel, 'Style', 'pushbutton', ...
              'String', 'Add Negative Charge', ...
              'Position', [140, 390, 120, 30], ...
              'Callback', @(~,~) addChargeMode(-1));
    
    % Visualization toggles
    uicontrol('Parent', panel, 'Style', 'text', ...
              'String', 'Visualization Options:', ...
              'Position', [10, 340, 150, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontWeight', 'bold');
    
    showFieldLines = uicontrol('Parent', panel, 'Style', 'checkbox', ...
                               'String', 'Show Field Lines', ...
                               'Position', [10, 310, 150, 20], ...
                               'Value', 1, ...
                               'Callback', @(src,~) updateVisualization());
    
    showElectricField = uicontrol('Parent', panel, 'Style', 'checkbox', ...
                                  'String', 'Show Electric Field Vectors', ...
                                  'Position', [10, 280, 180, 20], ...
                                  'Value', 0, ...
                                  'Callback', @(src,~) updateVisualization());
    
    showEquipotentials = uicontrol('Parent', panel, 'Style', 'checkbox', ...
                                   'String', 'Show Equipotential Lines', ...
                                   'Position', [10, 250, 180, 20], ...
                                   'Value', 0, ...
                                   'Callback', @(src,~) updateVisualization());
    
    % Field line density control
    uicontrol('Parent', panel, 'Style', 'text', ...
              'String', 'Field Line Density:', ...
              'Position', [10, 210, 150, 20], ...
              'HorizontalAlignment', 'left');
    
       densitySlider = uicontrol('Parent', panel, 'Style', 'slider', ...
                              'Position', [10, 190, 150, 20], ...
                              'Min', 4, 'Max', 16, 'Value', 8, ...
                              'SliderStep', [1/12, 2/12], ...
                              'Callback', @(src,~) updateVisualization());
    
    % Action buttons
    uicontrol('Parent', panel, 'Style', 'pushbutton', ...
          'String', 'Simulate Motion', ...
          'Position', [10, 80, 120, 30], ...
          'Callback', @(~,~)simulateMotion(fig));

    uicontrol('Parent', panel, 'Style', 'pushbutton', ...
              'String', 'Clear All Charges', ...
              'Position', [10, 130, 120, 30], ...
              'Callback', @clearCharges);
    
    uicontrol('Parent', panel, 'Style', 'pushbutton', ...
              'String', 'Save Figure', ...
              'Position', [140, 130, 120, 30], ...
              'Callback', @saveFigure);
    
    % Example configurations
    uicontrol('Parent', panel, 'Style', 'text', ...
              'String', 'Example Configurations:', ...
              'Position', [10, 55, 150, 20], ...
              'HorizontalAlignment', 'left', ...
              'FontWeight', 'bold');
    
    uicontrol('Parent', panel, 'Style', 'pushbutton', ...
              'String', 'Dipole', ...
              'Position', [10, 25, 75, 25], ...
              'Callback', @loadDipole);
    
    uicontrol('Parent', panel, 'Style', 'pushbutton', ...
              'String', 'Quadrupole', ...
              'Position', [95, 25, 75, 25], ...
              'Callback', @loadQuadrupole);
    
    uicontrol('Parent', panel, 'Style', 'pushbutton', ...
              'String', 'Line Charge', ...
              'Position', [180, 25, 80, 25], ...
              'Callback', @loadLineCharge);
    
    % Store handles in figure
    handles = struct('ax', ax, ...
                    'charges', charges, ...
                    'chargeSlider', chargeSlider, ...
                    'chargeValueText', chargeValueText, ...
                    'showFieldLines', showFieldLines, ...
                    'showElectricField', showElectricField, ...
                    'showEquipotentials', showEquipotentials, ...
                    'densitySlider', densitySlider, ...
                    'addMode', 0, ...
                    'chargeSign', 1, ...
                    'crosshairHandles', []);
    guidata(fig, handles);
    
    % Nested functions
    function updateChargeValue(src, ~)
        val = get(src, 'Value');
        set(chargeValueText, 'String', sprintf('%.1f μC', val));
    end
    
   function addChargeMode(sign)
    handles = guidata(fig);
    handles.addMode = 1;
    handles.chargeSign = sign;
    handles.crosshairHandles = [];        % reset any previous crosshair
    guidata(fig, handles);

    % change cursor to crosshair and set motion/click/key callbacks
    set(fig, 'Pointer', 'crosshair');
    set(fig, 'WindowButtonMotionFcn', @mouseMove);
    set(fig, 'WindowButtonDownFcn', @mouseClick);
    set(fig, 'KeyPressFcn', @keyPress);

    % Update title/instructions
    if sign > 0
        title(ax, 'Click to add positive charge (ESC to cancel)');
    else
        title(ax, 'Click to add negative charge (ESC to cancel)');
    end

    function mouseMove(~, ~)
        % Draw or update crosshair lines that follow the mouse on the axes
        st = guidata(fig);
        cp = get(ax, 'CurrentPoint');
        mx = cp(1,1);
        my = cp(1,2);
        xlim_ = get(ax,'XLim'); ylim_ = get(ax,'YLim');

        % only show crosshair when inside axes limits
        if mx < xlim_(1) || mx > xlim_(2) || my < ylim_(1) || my > ylim_(2)
            % delete if exists
            if ~isempty(st.crosshairHandles)
                safeDelete(st.crosshairHandles);
                st.crosshairHandles = [];
                guidata(fig,st);
            end
            return;
        end

        % create crosshair lines if they don't exist, else update
        if isempty(st.crosshairHandles)
            hold(ax,'on');
            h1 = line(ax, [xlim_(1) xlim_(2)], [my my], 'Color',[0 0 0], 'LineStyle','--', 'HitTest','off');
            h2 = line(ax, [mx mx], [ylim_(1) ylim_(2)], 'Color',[0 0 0], 'LineStyle','--', 'HitTest','off');
            st.crosshairHandles = [h1; h2];
        else
            try
                set(st.crosshairHandles(1), 'YData', [my my], 'XData', [xlim_(1) xlim_(2)]);
                set(st.crosshairHandles(2), 'XData', [mx mx], 'YData', [ylim_(1) ylim_(2)]);
            catch
                % if handles invalid, recreate next loop
                safeDelete(st.crosshairHandles);
                st.crosshairHandles = [];
            end
        end
        guidata(fig, st);
    end
end
    
   function mouseClick(~, ~)
    handles = guidata(fig);
    if handles.addMode
        coords = get(ax, 'CurrentPoint');
        x = coords(1, 1);
        y = coords(1, 2);

        % Check axes limits safely
        limsX = get(ax,'XLim'); limsY = get(ax,'YLim');
        if x >= limsX(1) && x <= limsX(2) && y >= limsY(1) && y <= limsY(2)
            % Add charge (store only)
            q = get(chargeSlider, 'Value') * handles.chargeSign;
            handles.charges.x(end+1) = x;
            handles.charges.y(end+1) = y;
            handles.charges.q(end+1) = q;
            guidata(fig, handles);

            % Plot charge marker only (no axis autoscale)
            plotCharges(ax, handles.charges);

            % Reset add mode and remove motion/click/key callbacks and crosshair
            handles.addMode = 0;
            set(fig, 'WindowButtonDownFcn', '');
            set(fig, 'WindowButtonMotionFcn', '');
            set(fig, 'KeyPressFcn', '');
            set(fig, 'Pointer', 'arrow');

            if isfield(handles,'crosshairHandles') && ~isempty(handles.crosshairHandles)
                safeDelete(handles.crosshairHandles);
                handles.crosshairHandles = [];
                guidata(fig, handles);
            end

            title(ax, 'Charge placed — updating visuals...');
            % === AUTO-UPDATE HERE ===
            % Call your visualization updater so things refresh immediately.
            % Use updateVisualization to respect current checkboxes/slider settings.
            try
                updateVisualization();   % nested function in your file
            catch
                try plotEquipotentialLines(ax, handles.charges); end
                try plotFieldLines(ax, handles.charges, round(get(densitySlider,'Value'))); end
                try plotElectricFieldVectors(ax, handles.charges); end
            end
            % ========================

            title(ax, 'Electric Field Visualization');
        end
    end
end
    
    function keyPress(~, evt)
    if strcmp(evt.Key, 'escape')
        handles = guidata(fig);
        handles.addMode = 0;
        % delete crosshair if present
        if isfield(handles,'crosshairHandles') && ~isempty(handles.crosshairHandles)
            safeDelete(handles.crosshairHandles);
            handles.crosshairHandles = [];
        end
        guidata(fig, handles);
        title(ax, 'Electric Field Visualization');
        set(fig, 'WindowButtonDownFcn', '');
        set(fig, 'WindowButtonMotionFcn', '');
        set(fig, 'KeyPressFcn', '');
        set(fig, 'Pointer', 'arrow');
    end
end
    
    function updateVisualization(~, ~)
        handles = guidata(fig);
        
        % Clear axes except charges
        cla(ax);
        hold(ax, 'on');
        
        if isempty(handles.charges.x)
            title(ax, 'No charges - Add charges to visualize fields');
            return;
        end
        
        % Plot charges first
        plotCharges(ax, handles.charges);
        
        % Get visualization options
        showFL = get(showFieldLines, 'Value');
        showEF = get(showElectricField, 'Value');
        showEP = get(showEquipotentials, 'Value');
        density = round(get(densitySlider, 'Value'));
        
        % Create field visualization
        if showEP
            plotEquipotentialLines(ax, handles.charges);
        end
        
        if showFL
            plotFieldLines(ax, handles.charges, density);
        end
        
        if showEF
            plotElectricFieldVectors(ax, handles.charges);
        end
        
        % Replot charges on top
        plotCharges(ax, handles.charges);
        
        title(ax, 'Electric Field Visualization');
        drawnow;
    end
    
function clearCharges(~, ~)
    handles = guidata(fig);
    handles.charges = struct('x', [], 'y', [], 'q', []);
    guidata(fig, handles);

    % Preserve current axis limits, clear graphics and restore limits
    xl = get(ax, 'XLim'); yl = get(ax, 'YLim');
    cla(ax); grid(ax,'on'); hold(ax,'on');
    set(ax, 'XLim', xl, 'YLim', yl, 'XLimMode', 'manual', 'YLimMode', 'manual');

    title(ax, 'Electric Field Visualization - No charges');
end
    
    function saveFigure(~, ~)
        [filename, pathname] = uiputfile({'*.png';'*.jpg';'*.pdf';'*.fig'}, ...
                                        'Save Figure As');
        if filename ~= 0
            saveas(fig, fullfile(pathname, filename));
            msgbox('Figure saved successfully!', 'Success');
        end
    end
    
    function loadDipole(~, ~)
        handles = guidata(fig);
        handles.charges.x = [-3, 3];
        handles.charges.y = [0, 0];
        handles.charges.q = [5, -5];
        guidata(fig, handles);
        updateVisualization();
    end
    
    function loadQuadrupole(~, ~)
        handles = guidata(fig);
        handles.charges.x = [-3, 3, -3, 3];
        handles.charges.y = [3, 3, -3, -3];
        handles.charges.q = [5, -5, -5, 5];
        guidata(fig, handles);
        updateVisualization();
    end
    
    function loadLineCharge(~, ~)
        handles = guidata(fig);
        n = 10;
        handles.charges.x = linspace(-8, 8, n);
        handles.charges.y = zeros(1, n);
        handles.charges.q = ones(1, n) * 2;
        guidata(fig, handles);
        updateVisualization();
    end
    
    function closeFigure(src, ~)
        delete(src);
    end

end
