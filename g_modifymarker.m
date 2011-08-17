function g_modifymarker(cmd)
global goose

if cmd == 1 %add marker

    [sel, ok] = listdlg('PromptString','Select a marker type to add:','SelectionMode','single','ListString',goose.analysis.marker.name,'ListSize',[180, 80]);
    if ok
        goose.analysis.marker.frame = [goose.analysis.marker.frame, goose.current.iFrame];
        goose.analysis.marker.nid(end + 1) = sel;

        %sort
        [goose.analysis.marker.frame, idx] = sort(goose.analysis.marker.frame);
        goose.analysis.marker.nid = goose.analysis.marker.nid(idx);

    else
        return;
    end

elseif cmd == 2 %delete marker

    nMarker = length(goose.analysis.marker.nid);

    if nMarker>0
        markerL = {};
        for i = 1:nMarker
            markerL{i} = sprintf('Frame %5.0f: Marker %d (%s)', goose.analysis.marker.frame(i), goose.analysis.marker.nid(i), goose.analysis.marker.name{goose.analysis.marker.nid(i)});
        end

        [sel, ok] = listdlg('PromptString','Select a marker to delete:','SelectionMode','single','ListString',markerL,'ListSize',[260, 80]);
        if ok
            goose.analysis.marker.frame(sel) = [];
            goose.analysis.marker.nid(sel) = [];
        end

    else
        msgbox('There are no markers in the data!');
    end
end

g_plotmarker;