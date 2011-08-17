function g_export(cmd)
global goose

if nargin < 1, cmd = 2; end
if cmd == 3,
    export_values;
    return;
end

goose.gui.fig_export = figure('Units','normalized','Position',[.1 .4 .6 .5],'Menubar','None','Name','Export','Numbertitle','Off');

dx = .1; %Breite der UIs
dy = .04; %Höhe der UIs
dy2 = .02; %Abstand zwischen Zeilen
dw1 = .1; %Abstand Txtfelder von links (west)
dw2 = .3; %Abstand der Edits von links
ds = .88; %Abstand des ersten Felds von unten (south)


goose.set.process.exportimgtypeL = {'bmp','jpg','gif','tif','animated gif'};
imagetypenr = length(goose.set.process.exportimgtypeL); %the last option is animated gif
step = 100;
show_video = 1;
show_fft2 = 1;
show_gbar = 1;

if cmd == 1,
    goose.set.process.framerange(1) = goose.current.iFrame;
    goose.set.process.framerange(2) = goose.current.iFrame;
    imagetypenr = 1;
    step = 1;
    show_fft2 = 0;
    show_gbar = 0;
end

goose.gui.export.text_framerange = uicontrol('Style','text','Units','normalized','FontUnits','normalized','FontSize',.6,'Position',[dw1 ds-(dy+dy2)*0 .2 dy],'String','Frame range (from : step : to):','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.export.edit_framerange1 = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*0 dx dy],'String', goose.set.process.framerange(1));
goose.gui.export.edit_framerangek = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2+dx+.03 ds-(dy+dy2)*0 dx dy],'String', step);
goose.gui.export.edit_framerange2 = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2+(dx+.03)*2 ds-(dy+dy2)*0 dx dy],'String', goose.set.process.framerange(2));
goose.gui.export.text_imagetype = uicontrol('Style','text','Units','normalized','FontUnits','normalized','FontSize',.6,'Position',[dw1 ds-(dy+dy2)*1 .2 dy],'String','Image type:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.export.popm_imagetype = uicontrol('Style','popupmenu','Units','normalized','FontUnits','normalized','FontSize',.6,'Position',[dw2 ds-(dy+dy2)*1 .22 dy],'String',goose.set.process.exportimgtypeL,'HorizontalAlignment','left','Value',imagetypenr);
goose.gui.export.text_delay = uicontrol('Style','text','Units','normalized','FontUnits','normalized','FontSize',.6,'Position',[dw1 ds-(dy+dy2)*3 .2 dy],'String','Delay time (anim-gif):','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.export.edit_delay = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*3 dx dy],'String', .1);
goose.gui.export.text_loop = uicontrol('Style','text','Units','normalized','FontUnits','normalized','FontSize',.6,'Position',[.55 ds-(dy+dy2)*3 .2 dy],'String','Loop (anim-gif):','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.export.edit_loop = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[.7 ds-(dy+dy2)*3 dx dy],'String', 'Inf');
goose.gui.export.chbx_video = uicontrol('Style','checkbox','Units','normalized','FontUnits','normalized','Position',[.80 ds-(dy+dy2)*6 dx dy],'String', 'Video frame','Value',show_video,'Callback',@build_frame,'BackgroundColor',get(gcf,'Color'));
goose.gui.export.chbx_fft2 = uicontrol('Style','checkbox','Units','normalized','FontUnits','normalized','Position',[.80 ds-(dy+dy2)*7 dx dy],'String', 'FFT2','Value',show_fft2,'Callback',@build_frame,'BackgroundColor',get(gcf,'Color'));
goose.gui.export.chbx_gbar = uicontrol('Style','checkbox','Units','normalized','FontUnits','normalized','Position',[.80 ds-(dy+dy2)*8 dx dy],'String', 'Goose-Bar','Value',show_gbar,'Callback',@build_frame,'BackgroundColor',get(gcf,'Color'));
goose.gui.export.chbx_fixscaling = uicontrol('Style','checkbox','Units','normalized','FontUnits','normalized','Position',[.80 ds-(dy+dy2)*10 .18 dy],'String', 'fix 1:1 pixel scaling','Value',1,'Callback',@build_frame,'BackgroundColor',get(gcf,'Color'));

goose.gui.export.text_preview = uicontrol('Style','text','Units','normalized','FontUnits','normalized','FontSize',.6,'Position',[dw1 ds-(dy+dy2)*4 .2 dy],'String','Preview:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.export.ax_preview = axes('Units','normalized','Position',[.1 .15 .5 .4]);

goose.gui.export.butt_export = uicontrol('Style','pushbutton','Units','normalized','FontUnits','normalized','Position',[.75 .05 .15 .05],'String', 'Export','Callback',@export_image);

build_frame;



function build_frame(scr, event)
global goose

axes(goose.gui.export.ax_preview);
cla;
hold on;

show_video = get(goose.gui.export.chbx_video,'Value');
show_fft2 = get(goose.gui.export.chbx_fft2,'Value');
show_gbar = get(goose.gui.export.chbx_gbar,'Value');
fix_scaling = get(goose.gui.export.chbx_fixscaling,'Value');

pdx = 0; %Width of Image (so far)
dx = 20; %space between image components

L = goose.set.visual.imgLen;

if show_video
    imagesc(1:L, 1:L, goose.current.img_cut);
    pdx = L;
    if show_fft2 || show_gbar, pdx = pdx + dx; end
end

if show_fft2
    imagesc(pdx:pdx+L, 1:L, goose.current.fft2img, [1, goose.current.fft2Max]);
    pdx = pdx + L;
    if show_gbar, pdx = pdx + dx; end
end

if show_gbar
    fill([pdx, pdx, pdx+40, pdx+40], [1 L L 1],[1 0 0], 'FaceColor',[.9 .9 .9],'EdgeColor',[0 0 0]);
    amp = goose.analysis.amp(goose.current.iFrame);
    amp_mn = min(nonzeros(goose.analysis.amp));
    amp_mx = max(nonzeros(goose.analysis.amp));
    ampr = (amp - amp_mn) / (amp_mx - amp_mn); %relative amp: 0 - 1
    amph = ampr * (L-20);
    fill([pdx+10, pdx+10, pdx+30, pdx+30], [L L-amph L-amph L],[1 0 0], 'FaceColor',[1 0 0],'EdgeColor',[0 0 0]);
    pdx = pdx + 40;
end

axis equal
set(gca, 'XLim', [1 pdx], 'YLim', [1 L], 'XTick', [], 'YTick', [], 'Box', 'off','XColor',[1 1 1], 'YColor', [1 1 1],'YDir','reverse'); %Rand schaffen, Ticks und Axen verstecken

if fix_scaling
    set(gca, 'Units','pixel');
    pos = get(gca,'Position');
    set(gca,'Position',[pos(1:2) pdx L]);
else
    set(gca, 'Units', 'normalized');
    %pos = get(gca,'Position');
    set(gca,'Position',[.1 .15 .5 .4]);
end

frame = getframe;
goose.current.exportimg = frame.cdata;



function export_image(scr,event)
global goose

step = str2double(get(goose.gui.export.edit_framerangek,'String'));
goose.set.process.framerange(1) = str2double(get(goose.gui.export.edit_framerange1,'String'));
goose.set.process.framerange(2) = str2double(get(goose.gui.export.edit_framerange2,'String'));
imagetypenr = get(goose.gui.export.popm_imagetype,'Value');
imagetype = goose.set.process.exportimgtypeL{imagetypenr};
delay = str2double(get(goose.gui.export.edit_delay,'String'));
loop = str2double(get(goose.gui.export.edit_loop,'String'));

filename = [goose.video.filename(1:end-4),'_export'];

for iFrame = goose.set.process.framerange(1):step:goose.set.process.framerange(2)

    goose.current.iFrame = iFrame;
    g_analyze(1);
    build_frame;
    if strcmp(imagetype, 'animated gif')
        [X, map] = rgb2ind(goose.current.exportimg, 128);   %requires Images Processing Toolbox!!
        if iFrame == goose.set.process.framerange(1)
            imwrite(X, map, [filename,'.gif'], 'gif', 'DelayTime', delay, 'WriteMode','overwrite', 'LoopCount', loop);
        else
            imwrite(X, map, [filename,'.gif'], 'gif', 'DelayTime', delay, 'WriteMode','append');
        end
    elseif strcmp(imagetype, 'gif')
        [X, map] = rgb2ind(goose.current.exportimg, 256);   %requires Images Processing Toolbox!!
        imwrite(X, map, [filename,'_fr',num2str(iFrame),'.',imagetype]);
    else
        imwrite(goose.current.exportimg, [filename,'_fr',num2str(iFrame),'.',imagetype]);
    end

end



function export_values
global goose

idx = find(goose.analysis.framedone);
M = [idx; goose.analysis.amp(idx)];

if ~isempty(goose.analysis.amp_norm)
    M = [M; goose.analysis.amp_norm(idx)];
end

[filename, pathname, filter] = uiputfile({'*.xls';'*.txt'},'Save goose values as..', goose.video.filename(1:end-4));

if ~all(filename == 0) %cancel
    if filter == 2 %*.txt
        dlmwrite(fullfile(pathname, filename), M', 'delimiter','\t', 'newline','pc');
    else % *.xls, *.*
        xlswrite(fullfile(pathname, filename), M');
    end
end