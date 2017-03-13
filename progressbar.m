classdef progressbar < handle
    properties(Access = protected)
        h_panel         % Panel on which everything sits
        h_ax            % The progress range axes
        h_pbar          % The bar representing progress (patch)
        h_ptext         % Percentage label
    end
    properties(Access = public, Dependent = true)
        range           % Progress range
        pvalue          % Current value
        percent         % Percentage complete (relative within range)
        position        % Position of the object (panel)
        ax_tag          % Tag of the axes
        visible         % Is the object (panel) visible?
    end
    properties(Constant = true)
        default_color = [.75 .75 .9];
    end
    methods
        % Initializer
        function obj = progressbar(fig, pos, range)
            if nargin < 3
                range = [0 1];
            end
            obj.h_panel = uipanel('Parent', fig, 'Units', 'Inches', ...
                'Position', pos, 'Tag', 'progbar_panel');
            obj.h_ax = axes('Parent', obj.h_panel, ...
                'Units', 'Inches', 'Position', [0 0 obj.position(3) obj.position(4)], ...
                'XTickLabel', '', 'XTick', [], 'YTickLabel', '', 'YTick', []);
            obj.h_pbar = patch([range(1) range(1) range(1) range(1)], [0 0 2 2], ...
                obj.default_color, 'Parent', obj.h_ax, 'Tag', 'progbar_patch');
            obj.h_ptext = text(obj.position(3)/2, obj.position(4)/2, '0%', ...
                'Parent', obj.h_ax, 'FontWeight', 'bold', 'Units', 'Inches', ...
                'HorizontalAlignment', 'center', 'Tag', 'progbar_text');
            obj.range = range;
            obj.ax_tag = 'progbar_ax';
        end

        % Property Access Methods
        function set.range(obj, value)
            % Instead of replotting, just reset the XLim to the
            % extremities of the input range. If the values are not
            % increasing, just default to [0 1].
            if value(end) > value(1)
                set(obj.h_ax, 'XLim', value([1,end]), 'YLim', [0 2]);
            else
                set(obj.h_ax, 'XLim', [0 1], 'YLim', [0 2]);
            end
            % Reset progress.
            obj.pvalue = value(1);
        end
        function value = get.range(obj)
            value = get(obj.h_ax, 'XLim');
        end
        function set.pvalue(obj, value)
            % Expects a single value to represent progress value and
            % constructs the selection rectangle from that. If multiple
            % values are passed in, all are ignored but the last, since the
            % left edge of the bar is always the first element of the
            % range.
            set(obj.h_pbar, 'XData', [obj.range(1) value(end) value(end) obj.range(1)], ...
                'FaceColor', obj.default_color);
            set(obj.h_ptext, 'String', sprintf('%3.0f%%', obj.percent * 100));
        end
        function value = get.pvalue(obj)
            % The progress bar is actually 2D, but we treat as if it is 1D.
            % Hence the XData is actually an array of four values but we
            % only consider the second (progress maximum).
            limits = get(obj.h_pbar, 'XData');
            value = limits(2);
        end
        function set.percent(obj, value)
            % Expects a single value between 0 and 1.
            limits = obj.range;
            obj.pvalue = value * (limits(2) - limits(1)) + limits(1);
        end
        function value = get.percent(obj)
            limits = obj.range;
            value = (obj.pvalue - limits(1)) / (limits(2) - limits(1));
        end
        function set.position(obj, value)
            % Once upon a time you couldn't change the width and height of
            % the object, but I couldn't see any good reason to impose that
            % restriction.
            set(obj.h_panel, 'Position', value);
        end
        function value = get.position(obj)
            value = get(obj.h_panel, 'Position');
        end
        function set.ax_tag(obj, value)
            set(obj.h_ax, 'Tag', value);
        end
        function value = get.ax_tag(obj)
            value = get(obj.h_ax, 'Tag');
        end
        function set.visible(obj, value)
            if (isnumeric(value) && value >= 1) || strcmp(value, 'on') == 1 || strcmp(value, 'On') == 1
                set(obj.h_panel, 'Visible', 'on');
            else
                set(obj.h_panel, 'Visible', 'off');
            end
        end
        function value = get.visible(obj)
            vis = get(obj.h_panel, 'Visible');
            value = strcmp(vis, 'on');
        end

        % Public member functions
        function increment(obj)
            % Don't use this if the range is less than 1.
            obj.pvalue = obj.pvalue + 1;
        end
        function display_text(obj, text, color)
            if nargin == 3 && ~isempty(color)
                set(obj.h_pbar, 'FaceColor', color);
            end
            set(obj.h_ptext, 'String', text);
        end
    end
end

