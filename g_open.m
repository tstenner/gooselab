function g_open(filetype, filename, pathname)
global goose

if nargin < 2
    filterL = {{'*.avi'},{'*.*'},{'*.mat'},{'*.wav'}};
    requestL = {'Select video file','Select stimulus file','Select GooseLab project file','Select an image file'};

    [filename, pathname] = uigetfile(filterL{filetype}, requestL{filetype});
    if all(filename == 0) || all(pathname == 0) %Cancel
        return
    end
end


if filetype < 3 %load new video/image data
    %reset file info
    goose.video.nFrames = 0;
    goose.audio.nSamples = 0;
    goose.audio.filename = [];
    goose.audio.pathname = [];
    goose.video.pathname = pathname;
    goose.video.filename = filename;
end

switch filetype
    case 1, %open video file

        aviObj = mmreader(fullfile(pathname, filename));
%       [goose.video.avi_hdl, avi_inf] = dxAviOpen(fullfile(pathname, filename));
        goose.video.nFrames = get(aviObj, 'NumberOfFrames'); %-1, since last frame cannot be opened
        goose.video.Width = get(aviObj, 'Width');
        goose.video.Height = get(aviObj, 'Height');
        goose.video.fps = get(aviObj, 'FrameRate');
        goose.video.time = get(aviObj, 'Duration');
        goose.video.aviobj = aviObj;

        l = min(goose.video.Width, goose.video.Height); %minimale Dimension
        goose.set.visual.imgLen  = floor(l/2) * 2; %forciert gerade Zahl
        goose.current.imgLenMax = goose.set.visual.imgLen;

        g_reset(0); %reset analysis without plot

        prepare_four;

        if ~goose.current.batchmode %graphics
            set(goose.gui.fig_main,'Name',['GooseLab ',sprintf('%3.2f',goose.version.number),' - ',fullfile(pathname, filename)])
            set(goose.gui.text_video,'String',[num2str(goose.video.time),' sec, ',num2str(goose.video.nFrames), ' frames (',num2str(goose.video.Width),' x ',num2str(goose.video.Height),' at ',num2str(goose.video.fps),' fps)'],'FontUnits','normalized','FontSize',.7)
            %plot first frame with imagesc to readjust axes
            axes(goose.gui.ax_video);
            pixmap = read(goose.video.aviobj, goose.current.iFrame);
            goose.current.img = reshape(pixmap/255, [goose.video.Height, goose.video.Width, 3]);
            goose.current.pic = imagesc(goose.current.img);
            %axis image off;
            %fix 1:1 pixel scaling
            set(gca,'Units','pixel');
            pos = get(gca,'Position');
            set(gca,'Position',[pos(1:2) goose.video.Width goose.video.Height]);

            goose.set.visual.fft2_lim = min(goose.set.visual.fft2_lim, goose.current.imgLenMax);

            %dummy goose-amp plot %
            axes(goose.gui.ax_gamp);
            cla;
            hold on
            goose.current.plot_gamp = plot(1,'ButtonDownFcn','g_click','Color',[.4 .4 1],'Marker','s','MarkerEdgeColor',[0 0 1],'MarkerSize',1,'MarkerFaceColor',[0 0 1]);
            tick_fac = round(goose.video.nFrames/goose.video.fps / 5); %20 %sec
            xticki = goose.video.fps * tick_fac;
            XTick = 0:xticki:goose.video.nFrames;

            %position indicator
            goose.gui.line_pos_ind_gamp = line([1, 1], get(goose.gui.ax_gamp,'ylim'), 'Color',[1 0 1],'LineStyle','--','ButtonDownFcn','g_click');
            set(goose.gui.ax_gamp,'XLim',[1, goose.video.nFrames],'XTick',XTick,'XTickLabel',XTick / goose.video.fps)

            %reset sound plot
            axes(goose.gui.ax_sound);
            cla;
            hold on
            set(goose.gui.ax_sound,'XLim',[1, goose.video.nFrames],'XTick',XTick,'XTickLabel',XTick / goose.video.fps)

            g_analyze(goose.current.iFrame);
        end


    case 2 %open image

        pic = imread(fullfile(pathname, filename));
        if isa(pic,'uint8') %geht sicher eleganter, aber wie?
            pic = double(pic)/255;
        elseif isa(pic, 'uint16')
            pic = double(pic)/65535;
        end
        goose.video.Width = size(pic, 2);
        goose.video.Height = size(pic, 1);
        goose.video.nFrames = 1;
        goose.video.fps = 1; %dummy value
        goose.video.time = 0; %dummy value
        l = min(goose.video.Width, goose.video.Height); %minimale Dimension
        goose.set.visual.imgLen = floor(l/2)*2; %forciert gerade Zahl
        goose.current.imgLenMax = goose.set.visual.imgLen;

        g_reset(0);
        %goose.analysis.marker = [];

        prepare_four;

        if ~goose.current.batchmode %graphics
            axes(goose.gui.ax_video);
            goose.current.img = pic;
            goose.current.pic = imagesc(pic);
            %axis image off;

            goose.set.visual.fft2_lim = min(goose.set.visual.fft2_lim, goose.current.imgLenMax);

            %dummy goose-amp plot
            axes(goose.gui.ax_gamp);
            cla;
            hold on
            goose.current.plot_gamp = plot(1,'ButtonDownFcn','g_click','Color',[.4 .4 1],'Marker','s','MarkerEdgeColor',[0 0 1],'MarkerSize',1,'MarkerFaceColor',[0 0 1]);
            goose.gui.line_pos_ind_gamp = line([1, 1], get(goose.gui.ax_gamp,'ylim'), 'Visible','off'); %dummy

            %reset sound plot
            axes(goose.gui.ax_sound);
            cla;

            g_analyze(1);
        end


    case 3, %open goose project file
        projectfile = load(fullfile(pathname, filename));
        if ~isempty(projectfile) && (any(strcmp(fieldnames(projectfile),'sources')) && any(strcmp(fieldnames(projectfile),'analysis'))) %valid file

            %opening file making use of g_open
            %video
            try
                g_open(1, projectfile.sources.video.filename, pathname); %including analysis of current frame, which becomes overwrite some lines later on
            catch
                h = warndlg(['Could not open video at : ', fullfile(pathname,projectfile.sources.video.filename)],'Error loading video source');
                waitfor(h);
                drawnow;
                g_open(1);
            end

            %audio
            try
                if ~(isempty(projectfile.sources.audio.filename) || isempty(projectfile.sources.audio.pathname))
                    g_open(4, projectfile.sources.audio.filename, projectfile.sources.audio.pathname)
                end
            catch
                h = warndlg(['Could not open audio at source: ', fullfile(projectfile.sources.audio.pathname,projectfile.sources.audio.filename)],'Error loading audio source');
                waitfor(h);
                drawnow;
                g_open(4);
            end

            %marker
            goose.analysis = projectfile.analysis;
            if any(strcmp(fieldnames(goose.analysis.marker),'start'))  %old project file
                goose.analysis.marker.nid = [];
                goose.analysis.marker.frame = [];
            end
            goose.analysis.marker.name = goose.set.markerNameL; %overwrite old name convention

            if ~goose.current.batchmode
                done_idx = find(goose.analysis.framedone);
                goose.current.nFramesDone = length(done_idx);
                prepare_four;
                g_analyze(1); %current frame analyzed another time in order to have g_analyze refresh all displays
                g_plotmarker;
            end

        else
            msgbox('Could not open GooseLab project file','','error');
        end


    case 4, %open audio file
        goose.audio.pathname = pathname;
        goose.audio.filename = filename;
        [goose.audio.data, goose.audio.Fs, goose.audio.bits] = wavread([pathname, filename]);
        goose.audio.nSamples = length(goose.audio.data);
        set(goose.gui.text_sound,'String',[num2str(goose.audio.nSamples/goose.audio.Fs),' sec, ',num2str(goose.audio.nSamples),' smpls (', num2str(goose.audio.Fs),' Hz, ',num2str(goose.audio.bits),' Bit)'],'FontUnits','normalized','FontSize',.93,'Position',[.07 .805 .259 .019]);

        %adjust for video-length
        goose.audio.data = [zeros(round((goose.analysis.marker.start-1)*goose.audio.Fs/goose.video.fps), 1); goose.audio.data; zeros(round((goose.video.nFrames - goose.analysis.marker.end)*goose.audio.Fs/goose.video.fps), 1)];  %consider marker
        goose.audio.audplayer = audioplayer(goose.audio.data, goose.audio.Fs, goose.audio.bits);
        %adjust for plot
        goose.audio.data_short = goose.audio.data(1:round(goose.audio.Fs/goose.video.fps):end); %change to video sampling frequency

        %plot
        axes(goose.gui.ax_sound);
        cla;
        hold on
        goose.audio.plot = plot(goose.audio.data_short,'ButtonDownFcn','g_click');
        set(gca,'XLim',[1, goose.video.nFrames], 'Xtick',get(goose.gui.ax_gamp,'XTick'), 'XTickLabel', get(goose.gui.ax_gamp,'XTickLabel'));
        goose.gui.line_pos_ind_sound = line([1, 1], get(goose.gui.ax_sound,'ylim'), 'Color',[1 0 1],'LineStyle','--','ButtonDownFcn','g_click');

        %add boxes if marker were found
        if goose.analysis.marker.start ~=1 || goose.analysis.marker.end ~= goose.video.nFrames
            ylim = get(goose.gui.ax_sound,'ylim');
            goose.gui.fill_offset_start = fill([1, 1, goose.analysis.marker.start-1, goose.analysis.marker.start-1], [ylim, fliplr(ylim)], [.9 .9 .9], 'ButtonDownFcn','g_click'); %, 'Erasemode','xor'
            goose.gui.fill_offset_end = fill([goose.analysis.marker.end+1, goose.analysis.marker.end+1, goose.video.nFrames, goose.video.nFrames], [ylim, fliplr(ylim)], [.9 .9 .9], 'ButtonDownFcn','g_click'); %,'Erasemode','xor'
            ch = get(goose.gui.ax_sound,'Children');
            set(goose.gui.ax_sound,'Children',ch([3:end,1:2])); %get the fill behind
        end

        %its not correct to take XLim from video data
        %        set(gca,'XLim',[1, length(get(goose.audio.plot,'YData'))],'Xtick',get(goose.gui.ax_gamp,'XTick'), 'XTickLabels', get(goose.gui.ax_gamp,'XTickLabels'));

end