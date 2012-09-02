function g_batchanalysis(pathname, frame_acc)
global goose

goose.current.batchmode = 1;

if ~strcmp(pathname(end),'/')
    pathname = [pathname,'/'];
end
dirL = dir([pathname,'*.avi']);  %*.mat

%write timeinfo to log-file
add2log(sprintf('%s, path: %s, frame accuracy: %4.0f\n', datestr(now,0), pathname, frame_acc),0);


for i = 1:length(dirL)

    try
        %open file
        filename = dirL(i).name;
        disp([datestr(now,13),' Analyzing: ',filename]);
        g_open(1, filename, pathname)
        
        %analyze file
        for iFrame = 1:frame_acc:goose.video.nFrames  %goose.video.nFrames/nFrames
            pixmap = read(goose.video.aviobj, goose.current.iFrame);
            pic = reshape(pixmap/255, [goose.video.Height, goose.video.Width, 3]);
            goose.current.iFrame = iFrame;
            four(pic);
        end

        %get marker
        g_getmarker;

        %remove LED artifact
        remove_LEDartifact

        %save project file
        g_save(pathname, filename(1:end-4));

        %save overview to jpg
        analysis_overview;

        %give feedback
        add2log(sprintf('%s %s: \tmean = %3.2f, max = %3.2f', datestr(now,13), filename, mean(goose.analysis.amp(logical(goose.analysis.framedone))), max(goose.analysis.amp)),0);

     catch
         add2log(sprintf('%s Error at %s !!', datestr(now,13), filename),1)
     end

end


function add2log(txt, display)

if display
    disp(txt);
end
fid_glog = fopen('gooselog.txt','a');
fprintf(fid_glog,'%s\n', txt);
fclose(fid_glog);

function analysis_overview
global goose

filename = goose.video.filename;
figure('Units','normalized','Position',[0 0.05 1 .9],'MenuBar','none','Name',filename);
fd = find(goose.analysis.framedone);
n = goose.video.nFrames;
fps = goose.video.fps;

%plot gamp
axes('Units','normalized','Position',[.05 .55 .9 .4]);
hold on
plot(fd, goose.analysis.amp(fd))
%plot(fd, goose.analysis.amp_norm(fd),'k')
set(gca,'XLim',[1 n],'YLim',[0, 30])
%plot-marker
colL = {[0 .6 0], [0 0 0], [0 0 0], [0 0 0], [0 0 0]};
ylim = get(gca,'ylim');
for iMarker = 1:length(goose.analysis.marker.nid)
    nid = goose.analysis.marker.nid(iMarker);
    frame = goose.analysis.marker.frame(iMarker);
    plot([frame frame], ylim, 'Color', colL{nid});
    text(frame, ylim(2)-(ylim(2)-ylim(1))*.03, sprintf('%1.0f', nid),'rotation',90,'HorizontalAlignment','right','verticalalignment','baseline','Color',colL{nid});
end
%plot max-line
[s, s_idx] = sort(goose.analysis.amp(fd));
mx = s(end); mx_idx = fd(s_idx(end));
pr = round(length(s)*.1);  %precentage rank
gpr = s(pr); gpr_idx = fd(s_idx(pr));
plot([mx_idx mx_idx], [0 mx], 'Color', [1 0 0]);
plot([gpr_idx gpr_idx], [0 gpr], 'Color', [0 0 1]);

% green/red values
axes('Units','normalized','Position',[.05 .40 .9 .1]);
hold on
plot(fd, goose.analysis.red(fd), 'r');
plot(fd, goose.analysis.green(fd), 'g');
set(gca, 'XLim',[1 n], 'YLim',[0 1]);

% plot spectrum
axes('Units','normalized','Position',[.05 .05 .3 .25]);
x = goose.analysis.amp(fd);
n2 = length(fd);
fps2 = fps * n2/n;
hw = .5*(1-cos(2*pi*(1:n2)/(n2+1)));
hw = hw ./ sum(hw(:));
x = x .* hw; %hanning window to avoid leakage
Y = fft(x);
Pyy = Y.* conj(Y) / (n2/2)^2;
Pyy = Pyy(1:floor(n2/2)); %2nd half is redundant
f = (0:floor(n2/2)-1)/n2*fps2; %meaningful frequency scale
f_min = 0; %select frequency range
f_max = fps2/2;
idx = find(f >= f_min & f <= f_max);
fr = f(idx);
Pyyr = Pyy(idx);
plot(fr, Pyyr)
set(gca,'XLim',[f_min, f_max],'YScale','log');  %,'YLim',[0, mx*1.3]

%plot p-rank frame
axes('Units','normalized','Position',[.4 .05 .25 .3]);
%pixmap = dxAviReadMex(goose.video.avi_hdl, gpr_idx);
pixmap = read(goose.video.aviobj, gpr_idx);
pic = reshape(pixmap/255, [goose.video.Height, goose.video.Width, 3]);
imagesc(pic);
set(gca,'XTick', [], 'YTick', [], 'Box', 'on','YDir','reverse')
%plot maximum frame
axes('Units','normalized','Position',[.7 .05 .25 .3]);
%pixmap = dxAviReadMex(goose.video.avi_hdl, mx_idx);
pixmap = read(goose.video.aviobj, mx_idx);
pic = reshape(pixmap/255, [goose.video.Height, goose.video.Width, 3]);
imagesc(pic);
set(gca,'XTick', [], 'YTick', [], 'Box', 'on','YDir','reverse')

%save & close
saveas(gcf,fullfile(goose.video.pathname, filename(1:end-4)),'jpg')
close(gcf)
drawnow;
