function g_record
global goose

if ~goose.current.isrecording

    [filename, pathname] = uiputfile('test.avi','Save as...');
    goose.video.filename = filename;
    goose.video.pathname = pathname;
    if all(filename == 0) || all(pathname == 0)
        return;
    end

    stop(goose.video.vidobj);
    triggerconfig(goose.video.vidobj, 'immediate')
    set(goose.video.vidobj,'TriggerRepeat',Inf)
    set(goose.video.vidobj,'LoggingMode','disk&memory');

    file = avifile(fullfile(pathname, filename), 'fps',25,'Compression','Indeo5','quality',100,'keyframe',20);

    set(goose.video.vidobj,'DiskLogger',file);
    start(goose.video.vidobj);
    goose.current.isrecording = 1;

    set(goose.gui.butt_rec,'String','stop');

else %isrecording

    stop(goose.video.vidobj);

    if goose.current.isrecording
        while goose.video.vidobj.FramesAcquired > goose.video.vidobj.DiskLoggerFrameCount
            pause(.1)
        end
        aviobj = close(goose.video.vidobj.DiskLogger);
        goose.current.isrecording = 0;
        set(goose.gui.text_video,'String',[num2str(goose.video.time),' sec, ',num2str(goose.video.nFrames), ' frames (',num2str(goose.video.Width),' x ',num2str(goose.video.Height),' at ',num2str(goose.video.fps),' fps)'])
    end
    delete(goose.video.vidobj)
    goose.video.vidobj = [];

    set(goose.gui.butt_rec,'Enable','off');

    done_idx = find(goose.analysis.framedone);
    g_open(1, goose.video.filename, goose.video.pathname);
    for iFrame = done_idx
        goose.current.iFrame = iFrame;
        g_analyze(1);
    end

    set(goose.gui.butt_rec,'String','record');
    set(goose.gui.butt_play,'enable','on');
    set(goose.gui.menu_5c,'Enable','off');
    set(goose.gui.menu_5d,'Enable','on');

end