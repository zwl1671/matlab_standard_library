classdef subplotter < sl.obj.display_class
    %
    %   Class:
    %   sl.plot.subplotter
    %
    %   TODO: Add usage documentation below
    %
    %   Example
    %   -------
    %   sp = sl.plot.subplotter(2,2);
    %   sp.subplot(1,1);
    %   plot(1:10,1:10)
    %   title('1,1');
    %   sp.subplot(1,2);
    %   plot(11:20,11:20)
    %   title('1,2');
    %   sp.subplot(2,1);
    %   plot(101:110,101:110)
    %   title('2,1');
    %   sp.subplot(2,2);
    %   plot(111:120,111:120)
    %   title('2,2');
    
    
    %
    %   Both of the below methods require
    %   TODO: We could allow passing in columns with which to work
    %   like only work with a given set of columns ...
    %sp.setColWidthByTime
    %sp.setColWidthByPct
    
    
    properties
        dims
        handles %cell array of Axes objects - some may be empty ...
        %
        %
        %
        
        last_index = 0
        %This can be used to omit specification of the axes
        %when calling the axes() method
        
        row_first_indexing %logical (default true)
        %
        %   NOT YET IMPLEMENTED
        %
        %   This would require something like sp.next() to be implemented.
        %
        %
    end
    properties (Dependent)
        n_rows
        n_columns
    end
    
    methods
        function value = get.n_rows(obj)
            value = obj.dims(1);
        end
        function value = get.n_columns(obj)
            value = obj.dims(2);
        end
    end
    
    %Static Methods
    %-----------------------------------------------
    methods (Static)
        function subplot_index = linearToSubplotIndex(id,n_rows,n_cols)
            %
            %    TODO: Document the point of the function ...
            %
            %    subplot_index = sl.plot.subplotter.linearToSubplotIndex(id,n_rows,n_cols)
            %
            %    Also works for a vector ...
            
            
            %    TODO: We might want to shadow this in a sl.hg.subplot class
            
            %    1  4     =>    1  2
            %    2  5           3  4
            %    3  6           5  6
            
            col = floor((id-1)./n_rows) + 1;
            row = id - n_rows.*(col-1);
            
            subplot_index = (row - 1).*n_cols + col;
        end
    end
    
    %Constructors
    %-----------------------------------------------
    methods (Static)
        function obj = fromFigure(fig_handle,shape)
            %
            %
            %   sp = sl.plot.subplotter.fromFigure(fig_handle,*shape)
            %
            %   Inputs
            %   ------
            %   shape : 2 element vector [n_rows, n_columns]
            %
            
            %Push this to getSubplotAxesHandles??
            if exist('shape','var')
                handles = findobj(gcf,'Type','axes');
                grid_handles = reshape(flip(handles),shape(1),shape(2));
            else
                temp = sl.hg.figure.getSubplotAxesHandles(fig_handle);
                grid_handles = temp.grid_handles;
            end
            sz = size(grid_handles);
            
            obj = sl.plot.subplotter(sz(1),sz(2));
            obj.handles = num2cell(grid_handles);
            
        end
    end
    
    
    methods
        function obj = subplotter(n_rows,n_columns,varargin)
            %
            %   obj = sl.plot.subplotter(n_rows,n_columns)
            %
            %   Note, as much as I would like to be able to support
            %
            %   Optional Inputs
            %   ---------------
            %   row_first_indexing : logical (default true)
            %       NOT YET IMPLEMENTED
            %
            
            in.row_first_indexing = true;
            in = sl.in.processVarargin(in,varargin);
            
            if isempty(n_rows)
                obj.dims = n_columns;
            else
                obj.dims = [n_rows,n_columns];
            end
            
            obj.row_first_indexing = in.row_first_indexing;
            obj.handles = cell(n_rows,n_columns);
        end
        function varargout = subplot(obj,row,column)
            % Create the actual subplot axis
            %
            %   ax = subplot(obj,row,column);
            %
            %   Example
            %   -------
            %   Plot to the 2nd row, 3rd column
            %   ax = sp.subplot(2,3);
            %
            %   Return regular or special axes?
            I = (row-1)*obj.n_columns + column;
            ax = subplot(obj.n_rows,obj.n_columns,I);
            obj.handles{row,column} = ax;
            
            if nargout
                varargout{1} = ax;
            end
        end
        function axes(obj,row,column)
            %x NYI - this is supposed to activate a particular axes
            %
            %    Calling Forms:
            %    --------------
            %    1) Specify the index to make active
            %    axes(obj,index)
            %
            %    2) Specify the location to make active by row & column
            %    axes(obj,row,column)
            %
            %    3) Make the next axes active (increment index by 1)
            %    axes(obj)
            %
            %    The goals is to have this be equivalent
            %    to calling subplot()
            %
            %    1) call subplot
            %
            %    Improvement:
            %    ------------
            %    1) Implement row_first_indexing
            %    2)
            %
            %    sp = sl.plot.subplotter
            
            error('Not yet implemented')
            
            %
            keyboard
            if nargin == 0
                %Use last index
            elseif nargin == 1
                sp_index = row;
            else
                %1 2
                %3 4
                %NOTE: This is currently for row_first_indexing = true
                sp_index = column + (row-1)*obj.dims(2);
            end
            obj.last_index = sp_index;
        end
        function setRowYLim(obj,row_I,ylim)
            ax = [obj.handles{row_I,:}];
            set(ax,'ylim',ylim);
        end
        function setColWidthByTime(obj,varargin)
            %x Adjust column widths so that they are proportional to time
            %
            %   setColWidthByTime(obj)
            %
            %   This function adjusts column widths so that column
            %   widths are proportional to their time. In other words
            %   if one column spans 1 second and another 2 seconds, the
            %   latter column would be made to take up 2/3 of the available
            %   width.
            %
            %   This can change the xlim, so the xlim neeeds to be manual
            %   before this ...
            %
            %   Yikes, I wonder if this is going to change my xlim
            %   which would make this circular ...
            %   - it does, so the xlim needs to be manual before this ...
            %
            %   TODO: Units need to be normalized ...
            %
            %   Optional Inputs
            %   ---------------
            %   axis : default 'normal'
            %       'auto'
            %       'normal'
            %       'tight'
            %       'fill'
            %       etc => see help(axis)
            %
            %   axis: 'auto', 'normal' (default), 'tight', 'fill' (etc. see
            %   help(axis))
            
            
            in.axis = 'normal';
            in = sl.in.processVarargin(in,varargin);
            
            all_positions = get([obj.handles{1,:}],'position');
            all_xlims     = get([obj.handles{1,:}],'xlim');
            
            all_lefts = cellfun(@(x) x(1),all_positions);
            all_rights = cellfun(@(x) x(1)+x(3),all_positions);
            
            left_extent  = all_lefts(1);
            right_extent = all_rights(end);
            
            all_widths = all_rights - all_lefts;
            all_time_durations = cellfun(@(x) x(2)-x(1),all_xlims);
            
            total_width = sum(all_widths);
            
            pct_durations = all_time_durations/sum(all_time_durations);
            new_widths = pct_durations*total_width;
            
            gap_widths = all_lefts(2:end) - all_rights(1:end-1);
            
            next_left = left_extent;
            n_columns_l = obj.dims(2); %l => local
            n_rows_l = obj.dims(1);
            for iColumn = 1:n_columns_l
                cur_width = new_widths(iColumn);
                for iRow = 1:n_rows_l
                    cur_axes = obj.handles{iRow,iColumn};
                    cur_position = get(cur_axes,'position');
                    cur_position(1) = next_left;
                    cur_position(3) = cur_width;
                    set(cur_axes,'position',cur_position)
                    
                    axis(cur_axes,in.axis)
                end
                if iColumn ~= n_columns_l
                    next_left = next_left + cur_width + gap_widths(iColumn);
                end
            end
        end
        function setHeightByPct(obj,pct)
            %X Scale all subplot heights by specified pct
            %
            %   setHeightByPct(obj,pct)
            %
            %   Inputs
            %   ------
            %   pct : array
            %       Same # of elements as rows, scales each row by
            %       specified percentage. Note the final heights are
            %       normalized to 1
            %
            %   Example
            %   -------
            %   sp = sl.plot.subplotter(3,1);
            %   for i = 1:3
            %       sp.subplot(i,1);
            %       plot(1:1000)
            %   end
            %   sp.setHeightByPct([0.1 0.2 0.3])
            
            n_columns_l = obj.dims(2); %l => local
            n_rows_l = obj.dims(1);
            
            %Normalize
            pct = pct./sum(pct);
            
            if length(pct) ~= n_rows_l
                error('PCT input must have same length as # of rows')
            end
            
            all_positions = get([obj.handles{:,1}],'position');
            
            all_bottoms = cellfun(@(x) x(2),all_positions);
            all_tops = cellfun(@(x) x(2)+x(4),all_positions);
            
            top_extent = all_tops(1);
            
            all_heights = all_tops - all_bottoms;
            total_height = sum(all_heights);
            
            new_heights = pct.*total_height;
            
            gap_heights = all_bottoms(1:end-1) - all_tops(2:end);
            
            next_top = top_extent;
            
            for iRow = 1:n_rows_l
                cur_height = new_heights(iRow);
                for iColumn = 1:n_columns_l
                    
                    cur_axes = obj.handles{iRow,iColumn};
                    cur_position = get(cur_axes,'position');
                    cur_position(2) = next_top - cur_height;
                    cur_position(4) = cur_height;
                    set(cur_axes,'position',cur_position)
                    
                    %axis(cur_axes,in.axis)
                end
                if iRow ~= n_rows_l
                    next_top = next_top - cur_height - gap_heights(iRow);
                end
            end
        end
        function removeVerticalGap(obj,rows,columns,varargin)
            %x Removes vertical gaps from subplots
            %
            %    removeVerticalGap(obj,rows,columns,varargin)
            %
            %    Inputs:
            %    -------
            %    rows : array
            %        Must be more than 1, should be continuous, starts at
            %        the top
            %        The value -1 indicates that all rows should be
            %        compressed.
            %    columns :
            %        Which columns are affected
            %
            %    Optional Inputs:
            %    ----------------
            %    gap_size: default 0.02
            %        The normalized figure space that should be placed
            %        between figures.
            %    remove_x_labels : logical (default true)
            %
            %
            
            if nargin == 1
                rows = 1:obj.n_rows;
                columns = 1:obj.n_columns;
            end
            
            %{
           subplot(2,1,1)
           plot(1:10)
           xlabel('testing')
           subplot(2,1,2)
           plot(2:20)
           xlabel('testing')
           sp = sl.plot.subplotter.fromFigure(gcf)
           sp.removeVerticalGap(1:2,1)
            %}
            
            in.gap_size = 0.02;
            in.keep_relative_size = true;
            in.remove_x_labels = true;
            in.remove_x_ticks = true;
            in = sl.in.processVarargin(in,varargin);
            
            %What's our expansion algorithm??????
            %Outer Position
            
            if rows == -1
                rows = 1:obj.n_rows;
            end
            
            
            all_axes = cellfun(@(x) sl.hg.axes(x),obj.handles(rows(1:end),columns(1)),'un',0);
            all_axes = [all_axes{:}];
            
            all_heights = [all_axes.height];
            pct_all_heights = all_heights./sum(all_heights);
            
            for iRow = 1:length(rows)-1
                cur_row_I = rows(iRow);
                for iCol = 1:length(columns)
                    cur_col_I = columns(iCol);
                    cur_ax = obj.handles{cur_row_I,cur_col_I};
                    a = sl.hg.axes(cur_ax);
                    a.clearLabel('x');
                    a.clearTicks('x');
                end
            end
            
            %Assuming all columns are the same ...
            top_axes    = all_axes(1);
            bottom_axes = all_axes(end);
            
            top_position = top_axes.position.top;
            bottom_position = bottom_axes.position.bottom;
            
            %TODO: This algorithm makes everything the same size. We need
            %to divy up based on the height
            
            if in.keep_relative_size
                total_height = top_position - bottom_position;
                gap_height   = (length(rows)-1)*in.gap_size;
                available_height = total_height - gap_height;
                new_heights = available_height*pct_all_heights;
                
                temp_start_heights = [0 cumsum(new_heights(1:end-1)+in.gap_size)];
                new_tops = top_position - temp_start_heights;
                new_bottoms = new_tops - new_heights;
            else
                %Add 1 due to edges
                %
                %        top     row 1   TOP OF TOP AXES
                %
                %        bottom  row 1  & top row 2
                %
                %        bottom  row 2  & top row 3
                %
                %        bottom  row 3   BOTTOM OF BOTTOM AXES
                %
                %    fill in so that each axes has the same height and so that
                %    all axes span from the top of the top axes to the bottom of
                %    the bottom axes
                temp = linspace(bottom_position,top_position,length(rows)+1);
                new_bottoms = temp(end-1:-1:1);
                new_tops = temp(end:-1:2);
            end
            
            for iRow = 1:length(rows)
                cur_row_I = rows(iRow);
                cur_new_top = new_tops(iRow);
                cur_new_bottom = new_bottoms(iRow);
                for iCol = 1:length(columns)
                    cur_col_I = columns(iCol);
                    cur_ax = obj.handles{cur_row_I,cur_col_I};
                    a = sl.hg.axes(cur_ax);
                    
                    %We can run into problems if we get a negative
                    %height between these two calls, so we need one that
                    %sets these at the same time
                    a.position.setTopAndBottom(cur_new_top,cur_new_bottom);
                    %                     a.position.top = cur_new_top;
                    %                     a.position.bottom = cur_new_bottom;
                end
            end
            %TODO: Verify continuity of rows
            %TODO: Verify same axes if removing x labels ...
        end
        function removeHorizontalGap(obj,varargin)
            %X removes horizontal gap
            %
            %   Optional Inputs
            %   ---------------
            %   remove_ticks : default false
            %       If true the y-ticks are removed, otherwise
            %       just the numbers are removed (if we remove the labels)
            %   no_gap_width : default 0.005
            %       This assumes normalized units. To make things look
            %       better we keep a very small gap between figures ...
            %   gap_width : default 0.02
            %       Gap to use when keeping labels
            %   remove_labels : default []
            %       - [] , remove labels if all the same
            %       - true, forces removal but errors on different 
            %         y-labels
            %       - false, don't remove labels
            %       
            %
            %   Improvements
            %   ------------
            %   1) Allow optionally y-syncing first
            %   2) Optional # removal - currently forced with labels
            %   3) check y-lim
            
            in.remove_ticks = false;
            in.no_gap_width = 0.005;
            in.gap_width = 0.02;
            in.remove_labels = []; %empty means do it if you can
            in = sl.in.processVarargin(in,varargin);
            
            n_columns_l = obj.n_columns;
            n_rows_l = obj.n_rows;
            
            remove_y_labels = true;
            if isempty(in.remove_labels) || in.remove_labels
                y_labels = cellfun(@(x) x.YLabel.String,obj.handles,'un',0);
                for i = 1:n_rows_l
                    if ~all(strcmp(y_labels(i,:),y_labels{i,1}))
                        if isempty(in.remove_labels)
                            remove_y_labels = false;
                            break
                        else
                            error('Currently can''t remove ylabels when not the same')
                            %Requested
                        end
                    end
                end
            else
                remove_y_labels = false;
            end
            
            if remove_y_labels
                for r = 1:n_rows_l
                    for c = 2:n_columns_l
                        cur_axis = obj.handles{r,c};
                        if in.remove_ticks
                            cur_axis.YTick = [];
                        else
                            cur_axis.YTickLabel = [];
                        end
                        %TODO: Have option to keep ticks but to remove #s
                        cur_axis.YLabel = [];
                    end
                end
            end
            
            %--------------------------------------------------------------
            all_positions = get([obj.handles{1,:}],'position');
            
            all_lefts = cellfun(@(x) x(1),all_positions);
            all_rights = cellfun(@(x) x(1)+x(3),all_positions);
            
            left_extent  = all_lefts(1);
            
            gap_widths = all_lefts(2:end) - all_rights(1:end-1);
            
            total_gap_width = sum(gap_widths);
            
            if remove_y_labels
                gap_widths(:) = in.no_gap_width;
            else
                gap_widths(:) = in.gap_width;
            end
            
            extra_space = total_gap_width - sum(gap_widths);
            
            all_widths = all_rights - all_lefts;
            
            pct_widths = all_widths./sum(all_widths);
            total_width = sum(all_widths) + extra_space;
            
            new_widths = pct_widths.*total_width;
            
            %Resizing
            %--------------------------------------------------------------
            
            next_left = left_extent;
            n_columns_l = obj.dims(2); %l => local
            n_rows_l = obj.dims(1);
            for iColumn = 1:n_columns_l
                cur_width = new_widths(iColumn);
                for iRow = 1:n_rows_l
                    cur_axes = obj.handles{iRow,iColumn};
                    cur_position = get(cur_axes,'position');
                    cur_position(1) = next_left;
                    cur_position(3) = cur_width;
                    set(cur_axes,'position',cur_position)
                    
                end
                if iColumn ~= n_columns_l
                    next_left = next_left + cur_width + gap_widths(iColumn);
                end
            end
            
        end
        function linkXAxes(obj,varargin)
            %X Keep same x-limits for all axes
            %
            %   linkXAxes(obj,varargin)
            %
            %   Optional Inputs
            %   ---------------
            %   by_column : default false
            %       - true, columns are linked
            %       - false, all axes are linked, even across columns
            %
            %   See Also
            %   --------
            %   linkaxes
            
            in.clear_previous_links = false; %NYI
            in.by_column = false;
            in = sl.in.processVarargin(in,varargin);
            
            h = obj.handles;
            if in.by_column
                for i = 1:obj.n_columns
                    column_h = [h{:,i}];
                    %syncLimits(column_h,'XLim');
                    %linkprop(column_h,'XLim');
                    linkaxes(column_h,'x');
                end
            else
                all_handles = [h{:}];
                linkaxes(all_handles,'x');
                %syncLimits(all_handles,'XLim');
                %linkprop(ax,'XLim');
            end
        end
        function linkYAxes(obj,varargin)
            %X Keep same y-limits for all axes
            %
            %   linkYAxes(obj,varargin)
            %
            %   Currently I've only implemented linking each row
            %   independently, eventually we could link all rows ...
            %
            %   See Also
            %   --------
            %   linkaxes
            
            in.clear_previous_links = false; %NYI
            in.by_row = true; %NYI
            in = sl.in.processVarargin(in,varargin);
            
            for i = 1:obj.n_rows
                %TODO: Do we need to expand first
                %I think this sometimes shrinks rather than expanding :/
                ax = [obj.handles{i,:}];
                linkaxes(ax,'y')
                %syncLimits(ax,'YLim');
                %linkprop(ax,'YLim');
            end
        end
        function changeWidths(obj,new_width)
            %X NYI
            %TODO: Not sure how we want to organize this ...
            error('Not yet implemented')
        end
    end
    
    
end

% function h__linkAxes(ax,
function syncLimits(ax,prop)
bestlim = [inf -inf];
nonNumericLims = false(size(ax));
classes = cell(size(ax));
for k=1:length(ax)
    axlim = get(ax(k),prop);
    if isnumeric(axlim)
        bestlim = [min(axlim(1),bestlim(1)) max(axlim(2),bestlim(2))];
    else
        nonNumericLims(k) = true;
        classes{k} = class(axlim);
    end
end
if any(nonNumericLims)
    if ~all(nonNumericLims) || ~all(strcmp(classes{1},classes))
        error(message('MATLAB:linkaxes:CompatibleData'))
    end
end
set(ax,[prop 'Mode'],'manual')
if bestlim(1) < bestlim(2)
    set(ax, prop, bestlim)
end
end

