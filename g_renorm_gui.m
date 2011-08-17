function g_renorm_gui
global goose

goose.gui.renorm_fig = figure('Units','normalized','Position',[.05 .1 .9 .8],'Menubar','None','Name','Renorm ...','Numbertitle','Off');
goose.gui.renorm_ax1 = axes('Units','normalized','Position',[.05 .8 .9 .15]);
goose.gui.renorm_ax2 = axes('Units','normalized','Position',[.05 .6 .9 .15],'ButtonDownFcn',{@renorm_click,1});
goose.gui.renorm_ax3 = axes('Units','normalized','Position',[.05 .35 .9 .15]);
goose.gui.renorm_ax4 = axes('Units','normalized','Position',[.05 .15 .9 .15],'ButtonDownFcn',{@renorm_click,2});
goose.gui.renorm_butt = uicontrol('Style','pushbutton','Units','normalized','Position',[.8 .03 .1 .05],'String','Apply','Callback',@renorm_apply);

%Initial values
if isempty(goose.analysis.amp_norm)
    nBin = 100;
    amp = goose.analysis.amp;
    [amphis, amphis_x] = hist(amp, nBin);
    [amphis_max, max_idx] = max(amphis);  %max bin

    goose.analysis.renorm.base_max = amphis_x(min(max_idx+2, nBin));  % first guess of baseline amplitude
    goose.analysis.renorm.goose_min = .2;

else
    goose.analysis.renorm.base_max = goose.analysis.base_max;
    goose.analysis.renorm.goose_min = goose.analysis.goose_rnmin;

end

refresh_renorm_gui


function refresh_renorm_gui
global goose

amp = goose.analysis.amp;
amp = smooth(amp,4,'gauss');
nFrames = goose.video.nFrames;
fps = goose.video.fps;
t = (1:nFrames) / fps;

nBin = 100;   % number of histogram bins for first histogram. Eventually adapt depending on frame number.

base_max = goose.analysis.renorm.base_max;
base_idx = amp <= base_max;
if length(find(base_idx)) > 2
    base_amp = amp(base_idx);
    basepoly = polyfit(t(base_idx), base_amp, 2);
    baseline = polyval(basepoly, t);
else  %everything is goosbump
    base_idx = [];
    base_amp = [];
    baseline = ones(size(amp)) * base_max;
end

amp_renorm = amp;% ./ baseline - 1;
goose.analysis.renorm.amp_norm = amp_renorm;

%deconv
tau = 2.5;
sigma = 2 * fps;
sigma = sigma * tau;
tmax = t(end);
expmaxtime = min(tau*10, tmax);
kerneltime = t(t <= expmaxtime);
kernel = exp(-kerneltime/tau);
kernel = kernel / sum(kernel);
expandno = length(kernel) - 1;
paddedamp = [amp_renorm amp_renorm(end)*ones(1,expandno)];
goose_driver = deconv(paddedamp,kernel);
goose_driver = smooth(goose_driver, round(sigma),'gauss');
goose.analysis.renorm.amp_driver = goose_driver;

%goose onset
goose_min = goose.analysis.renorm.goose_min;
goose_rnidx = goose_driver >= goose_min;
goose_amprn = goose_driver(goose_rnidx);
onset_idx = find(diff(goose_rnidx) == 1);
offset_idx = find(diff(goose_rnidx) == -1);
%force minimum length for goose phases
if ~isempty(onset_idx) || ~ isempty(offset_idx)
    if isempty(offset_idx)
        offset_idx = nFrames;
    elseif isempty(onset_idx)
        onset_idx = 1;
    end
    if offset_idx(1) < onset_idx(1)
        onset_idx = [1, onset_idx];
    end
    if offset_idx(end) < onset_idx(end)
        offset_idx = [offset_idx, nFrames];
    end

    for i = 1:length(onset_idx)
        if offset_idx(i) - onset_idx(i) < 2*fps
            onset_idx(i) = 0;
        end
    end
    remove_idx = onset_idx == 0;
    onset_idx(remove_idx) = [];
    offset_idx(remove_idx) = [];
end
goose.analysis.renorm.onset = onset_idx;
goose.analysis.renorm.offset = offset_idx;


axes(goose.gui.renorm_ax1);
cla; hold on;
plot(t, amp,'k')
plot(t(base_idx), base_amp, '.','Color',[.5 .5 .5])
plot(t, baseline,'b')
set(gca,'XLim',[0, t(end)])

axes(goose.gui.renorm_ax2);
cla; hold on;
hist(amp, nBin);
plot([base_max, base_max], [0, 1000], 'r', 'ButtonDownFcn',{@renorm_click,1});
[amphis, amphis_x] = hist(amp, nBin);
[amphis_max, max_idx] = max(amphis);
amphis_dx = amphis_x(2) - amphis_x(1);
set(gca,'XLim',[amphis_x(1)-2*amphis_dx, amphis_x(end)+2*amphis_dx], 'YLim',[0 amphis_max*1.2])

axes(goose.gui.renorm_ax3);
cla; hold on;
plot(t, amp_renorm, 'k')
plot(t, goose_driver, 'b');
plot(t(goose_rnidx), goose_amprn, 'm.')
for i = 1:length(onset_idx)
    plot([t(onset_idx(i)), t(onset_idx(i))], [-10, 1000], 'g')
end
for i = 1:length(offset_idx)
    plot([t(offset_idx(i)), t(offset_idx(i))], [-10, 1000], 'b')
end
plot([1, nFrames], [goose_min, goose_min], 'r')
set(gca,'XLim',[0, t(end)], 'YLim',[-.1 max(amp_renorm)*1.2])

axes(goose.gui.renorm_ax4);
cla; hold on;
hist(amp_renorm, nBin);
plot([goose_min, goose_min], [0, 1000], 'r', 'ButtonDownFcn',{@renorm_click,2});
[amprnhis, amprnhis_x] = hist(amp_renorm, nBin);
[amprnhis_max, max_rnidx] = max(amprnhis);  %max bin
amprnhis_dx = amprnhis_x(2) - amprnhis_x(1);
set(gca,'XLim',[amprnhis_x(1)-2*amprnhis_dx, amprnhis_x(end)+2*amprnhis_dx], 'YLim',[0 amprnhis_max*1.2])



function renorm_click(scr, event, ax_flag)
global goose

if ax_flag == 1
    point = get(goose.gui.renorm_ax2,'currentpoint');
    point = point(1);

    goose.analysis.renorm.base_max = point;

else
    point = get(goose.gui.renorm_ax4,'currentpoint');
    point = point(1);

    goose.analysis.renorm.goose_min = point;
end

refresh_renorm_gui;


function renorm_apply(scr, event)
global goose

goose.analysis.amp_norm = goose.analysis.renorm.amp_norm;
goose.analysis.base_max = goose.analysis.renorm.base_max;
goose.analysis.goose_rnmin = goose.analysis.renorm.goose_min;
goose.analysis.amp_driver = goose.analysis.renorm.amp_driver;
goose_onset = goose.analysis.renorm.onset;
goose_offset = goose.analysis.renorm.offset;

goose.analysis = rmfield(goose.analysis, 'renorm');

%Add goose onset marker
if ~isempty(goose_onset)
    %delete goose onset marker
    if ~isempty(goose.analysis.marker.nid)
        idx3 = find(goose.analysis.marker.nid == 3);
        if ~isempty(idx3)
            goose.analysis.marker.nid(idx3) = [];
            goose.analysis.marker.frame(idx3) = [];
        end
        idx4 = find(goose.analysis.marker.nid == 4);
        if ~isempty(idx4)
            goose.analysis.marker.nid(idx4) = [];
            goose.analysis.marker.frame(idx4) = [];
        end
    end

    if ~isempty(goose_onset)
        %save markers
        goose.analysis.marker.frame = [goose.analysis.marker.frame, goose_onset, goose_offset];
        goose.analysis.marker.nid = [goose.analysis.marker.nid, 3*ones(1, length(goose_onset)), 4*ones(1, length(goose_offset))];
        [goose.analysis.marker.frame, idx] = sort(goose.analysis.marker.frame);
        goose.analysis.marker.nid = goose.analysis.marker.nid(idx);
    end
end


close(goose.gui.renorm_fig)
g_plotmarker;