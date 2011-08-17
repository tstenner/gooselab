function g_plotmarker
global goose

if goose.current.batchmode
    return;
end

%remove old markers
delete(goose.gui.line_marker(ishandle(goose.gui.line_marker)))
delete(goose.gui.text_marker(ishandle(goose.gui.text_marker)))

name = goose.analysis.marker.name;
colL = {[0 .6 0], [0 0 0], [0 0 0], [0 0 0], [0 0 0]};

for i = 1:length(goose.analysis.marker.nid)

    nid = goose.analysis.marker.nid(i);
    frame = goose.analysis.marker.frame(i);
    
    axes(goose.gui.ax_gamp)
    ylim = get(goose.gui.ax_gamp,'ylim');
    goose.gui.line_marker(i) = plot([frame frame], ylim, 'Color', colL{nid}, 'ButtonDownFcn','g_click');
    goose.gui.text_marker(i) = text(frame, ylim(2)-(ylim(2)-ylim(1))*.03, sprintf('%1.0f', nid),'rotation',90,'HorizontalAlignment','right','verticalalignment','baseline','Color',colL{nid});  % (%s)  .. , name{nid}

end