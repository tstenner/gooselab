function g_imaq
global goose

if ~isempty(goose.video.vidobj)
    if strcmp(get(goose.video.vidobj, 'Running'), 'on')

        stop(goose.video.vidobj);

        delete(goose.video.vidobj)
        goose.video.vidobj = [];

        set(goose.gui.butt_rec,'Enable','off');
        set(goose.gui.butt_play,'enable','on');
        set(goose.gui.menu_5c,'Enable','off');
        set(goose.gui.menu_5d,'Enable','on');

        return;
    end
end

goose.video.nFrames = 0;
goose.audio.nSamples = 0;
goose.audio.filename = [];
goose.audio.pathname = [];
goose.video.pathname = [];
goose.video.filename = [];
set(goose.gui.butt_play,'Enable','off');
set(goose.gui.menu_5c,'Enable','on');
set(goose.gui.menu_5d,'Enable','off');

imaqreset;
goose.video.vidobj = videoinput('winvideo');
src = getselectedsource(goose.video.vidobj);
%set(src,'WhiteBalance',0);
triggerconfig(goose.video.vidobj, 'manual')
set(goose.video.vidobj,'Timerfcn',@imaq_timer,'TimerPeriod',1)

res = get(goose.video.vidobj,'VideoResolution');
goose.video.Width = res(1);
goose.video.Height = res(2);
goose.video.fps = str2double(get(src,'FrameRate'));
goose.video.nFrames = 1;
goose.video.time = 0;
set(goose.gui.text_video,'String',[num2str(goose.video.time),' sec, ',num2str(goose.video.nFrames), ' frames (',num2str(goose.video.Width),' x ',num2str(goose.video.Height),' at ',num2str(goose.video.fps),' fps)'])

l = min(goose.video.Width, goose.video.Height); %minimale Dimension
goose.set.visual.imgLen = floor(l/2)*2; %forciert gerade Zahl
goose.current.imgLenMax = goose.set.visual.imgLen;
g_reset(0);
goose.analysis.marker = [];
prepare_four;

%dummy goose-amp plot
axes(goose.gui.ax_gamp);
cla;
hold on
goose.current.plot_gamp = plot(1,'ButtonDownFcn','g_click','Color',[.4 .4 1],'Marker','s','MarkerEdgeColor',[0 0 1],'MarkerSize',1,'MarkerFaceColor',[0 0 1]);
goose.gui.line_pos_ind_gamp = line([1, 1], get(goose.gui.ax_gamp,'ylim'), 'Visible','off'); %dummy

%reset sound plot
axes(goose.gui.ax_sound);
cla;

start(goose.video.vidobj)

%pause(1);
axes(goose.gui.ax_video)
goose.current.img = rand(goose.video.Height, goose.video.Width, 3);%peekdata(goose.video.vidobj,1);
goose.current.pic = imagesc(goose.current.img);
set(gca, 'XTick', [], 'YTick', [], 'Box', 'on','XColor',[0 0 0], 'YColor', [0 0 0],'YDir','reverse');

set(goose.gui.butt_rec,'Enable','on');



function imaq_timer(scr, event)
global goose

if goose.current.isrecording
    goose.current.iFrame = goose.video.vidobj.FramesAcquired;
    if goose.current.iFrame == 0
        return;
    end
    goose.video.nFrames = goose.video.vidobj.FramesAcquired;
    goose.video.time = goose.video.nFrames/goose.video.fps;
    goose.analysis.framedone(goose.current.iFrame) = 0;
end

%axes(goose.gui.ax_video)
%set(gca, 'XTick', [], 'YTick', [], 'Box', 'on','XColor',[0 0 0], 'YColor', [0 0 0],'YDir','reverse');
goose.current.img = peekdata(goose.video.vidobj,1);
if isempty(goose.current.img)
    return;
end
%if goose.current.iFrame >1
%    disp('')
%end

g_analyze(1);
axes(goose.gui.ax_gamp);
tick_fac = round(goose.video.nFrames/goose.video.fps / 5);%20; %sec
xticki = goose.video.fps * tick_fac;
XTick = 0:xticki:goose.video.nFrames;
set(goose.gui.ax_gamp,'XLim',[0, goose.video.nFrames],'XTick',XTick,'XTickLabel',XTick / goose.video.fps)

if goose.current.isrecording
    flushdata(goose.video.vidobj);
end