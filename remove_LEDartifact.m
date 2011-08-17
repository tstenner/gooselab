function remove_LEDartifact
global goose

m1_idx = find(goose.analysis.marker.nid == 1);
if isempty(m1_idx)
    return;
end
m1_fr = goose.analysis.marker.frame(m1_idx);
n = goose.video.nFrames;

%Interpolate missing vals
% idx = find(goose.analysis.framedone);
% if length(idx) < n
%     amp = interp1(idx, goose.analysis.amp(idx), 1:n);
% else
amp = goose.analysis.amp;
% end


smooth_width = 3;
amps = smooth(amp,2*smooth_width,'gauss');
%interp_width = 5;
art_rg = [-1-smooth_width, 20+smooth_width];


for i = 1:length(m1_idx)

    art_idx = max(2, m1_fr(i)+art_rg(1)) : min(n-1, m1_fr(i)+art_rg(2));
    %outside_idx = [max(1, m1_fr(i)+art_rg(1)-interp_width), max(1, m1_fr(i)+art_rg(1)-1),  min(n, m1_fr(i)+art_rg(2)+1), min(n, m1_fr(i)+art_rg(2)+interp_width)];
    %outside_idx = unique(outside_idx);
    outside_idx = [max(1, m1_fr(i)+art_rg(1)-1),  min(n, m1_fr(i)+art_rg(2)+1)];

    art_amp = interp1(outside_idx, amps(outside_idx), art_idx, 'linear');   %{'linear','spline','cubic'}
    %figure; plot([outside_idx(1:2),art_idx,outside_idx(3:4)], [amp(outside_idx(1:2)), amp(art_idx), amp(outside_idx(3:4))] ,'o')
    %hold on; plot([outside_idx(1:2),art_idx,outside_idx(3:4)], [amp(outside_idx(1:2)), art_amp, amp(outside_idx(3:4))] ,'ro')
    amp(art_idx) = art_amp;

end


goose.analysis.amp = amp;  %(idx)

if ~goose.current.batchmode
    set(goose.current.plot_gamp, 'YData', amp);  %(idx)
end