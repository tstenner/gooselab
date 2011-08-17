function g_getmarker(loading_project)
global goose

if goose.video.nFrames == 0
    return;
end

%remove old markers
if ~isempty(goose.analysis.marker.nid)
    idx = find(goose.analysis.marker.nid == 1 | goose.analysis.marker.nid == 2);
    if ~isempty(idx)
        goose.analysis.marker.nid(idx) = [];
        goose.analysis.marker.frame(idx) = [];
    end
end

%find red or green LED onsets
frdone = find(goose.analysis.framedone);
g = goose.analysis.green(frdone) >= goose.set.greenLED_thresh | goose.analysis.red(frdone) >= goose.set.redLED_thresh;
g_change = diff([0 g]) == 1;  %extend
marker = frdone(g_change);

if ~isempty(marker)
    %save markers
    goose.analysis.marker.frame = [goose.analysis.marker.frame, marker];
    goose.analysis.marker.nid = [goose.analysis.marker.nid, ones(1, length(marker))];
    [goose.analysis.marker.frame, idx] = sort(goose.analysis.marker.frame);
    goose.analysis.marker.nid = goose.analysis.marker.nid(idx);
end

g_plotmarker;