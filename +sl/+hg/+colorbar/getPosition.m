function pos = getPosition(cb,varargin)
%   
%   pos = sl.hg.colorbar.getPosition(cb,varargin)
%
%   Optional Inputs
%   ---------------
%   constrain : default true
%       Since we don't get the property directly but only via an
%       approximation if we exceed 0 or 1 for units we force them to be in
%       range ...
%   type : string
%       - 'innerposition' 'p' 'i'
%       - 'outerposition' 'o'
%       - 'tightposition' 't'
%
%
%   Copied From
%   -----------
%   https://stackoverflow.com/questions/42692628/obtain-full-size-of-colorbar-in-matlab

    %TODO: Requires units comparison
    %in.constrain = true;
    in.type = 'tight';
    in = sl.in.processVarargin(in,varargin);

    temp = cb.Position;
    %temp(1) = temp(1)-0.1;
    h_axes = axes(...
            'Units', cb.Units, ...
            'Position', temp,...
            'BoxStyle','full',...
            'YAxisLocation', 'right', ...
            'YLim', cb.Limits,...
            'FontSize', cb.FontSize,...
            'FontWeight', cb.FontWeight,...
            'Visible', 'on', ...
            'FontName', cb.FontName,...
            'YTick', cb.Ticks, ...
            'YTickLabels', cb.TickLabels, 'XTick', [],'TickDir',cb.TickDirection);

    if ~isempty(cb.Label)
        ylabel(h_axes, cb.Label.String, 'FontSize', cb.Label.FontSize, ...
        'FontWeight', cb.Label.FontWeight, 'FontWeight', cb.Label.FontWeight)
    end

    switch lower(in.type(1))
        case {'p' 'i'}
            pos = get(h_axes, 'Position');
        case 't'
            pos = sl.hg.axes.getPosition(h_axes,'type','t',...
                'add_legend',false,'add_colorbar',false);
        case 'o'
            pos = get(h_axes, 'OuterPosition');
        otherwise
            error('Unrecognized position type')
    end

    delete(h_axes);
end