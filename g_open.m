function g_open(filetype, filename, pathname)
% g_open opens the specified file in Gooselab
% filetype 0: guess, 1: video, 2: image, 3: project file, 4: sound file
% filename name of the file without path
% pathname path to the file

global goose

if nargin < 2
    [filename, pathname] = uigetfile('*.*');
    if all(filename == 0) || all(pathname == 0) %Cancel
        return
    end
    filetype = 0;
end

[~,~,ext] = fileparts([pathname filename]);
if filetype < 3
    if filetype==2 || any(strcmpi(ext,{'.bmp','.gif','.jpeg','.jpg','.png','.pgf'}))
        pic = imread(fullfile(pathname, filename));
        pic = double(pic) / double(intmax(class(pic)));
        goose.current.img = pic;

        goose.video = struct('Width',size(pic, 2), 'Height', size(pic, 1),'nFrames',1,'fps',1,'time',1,'vidobj',[]);

        if ~goose.current.batchmode %graphics
            axes(goose.gui.ax_gamp);
            cla;
            hold on
            goose.current.plot_gamp = plot(1,'ButtonDownFcn','g_click','Color',[.4 .4 1],'Marker','s','MarkerEdgeColor',[0 0 1],'MarkerSize',1,'MarkerFaceColor',[0 0 1]);
            goose.gui.line_pos_ind_gamp = line([1, 1], get(goose.gui.ax_gamp,'ylim'), 'Visible','off'); %dummy

            %reset sound plot
            axes(goose.gui.ax_sound);
            cla;
        end
    % We can't use the supported file formats from mmreader.getFileFormats,
    % not all supported formats are in the list and not all formats in the
    % list are supported, so we offer most common formats.
    elseif filetype==1 || any(strcmpi(ext,{'.mkv','.avi','.mov','.mj2','.ogg','.ogv','.mp4','.mpg','.mpeg'}))
        % ignore the warning, since mmreader's replacement VideoReader
        % isn't available in commonly used matlab versions
        warning('off','MATLAB:audiovideo:mmreader:mmreaderToBeRemoved');
        try
            aviObj = mmreader(fullfile(pathname, filename));
        catch e
            warndlg({'Loading video failed:',e.message});
        end
        goose.video.nFrames = get(aviObj, 'NumberOfFrames')-1; %-1, since last frame cannot be opened
        goose.video.Width = get(aviObj, 'Width');
        goose.video.Height = get(aviObj, 'Height');
        goose.video.fps = get(aviObj, 'FrameRate');
        goose.video.time = get(aviObj, 'Duration');
        goose.video.aviobj = aviObj;

        goose.current.img = double(read(goose.video.aviobj, goose.current.iFrame))/255;

        if ~goose.current.batchmode %graphics
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

        end
    end
    
    goose.audio.nSamples = 0;
    goose.audio.filename = [];
    goose.audio.pathname = [];
    goose.video.pathname = pathname;
    goose.video.filename = filename;

    l = min(goose.video.Width, goose.video.Height); %minimal Dimension
    goose.set.visual.imgLen = floor(l/2)*2; % imgLen should be even
    goose.current.imgLenMax = goose.set.visual.imgLen;

    g_reset(0);
    prepare_four;

    if ~goose.current.batchmode %graphics
        goose.set.visual.fft2_lim = min(goose.set.visual.fft2_lim, goose.current.imgLenMax);
        set(goose.gui.fig_main,'Name',['GooseLab ',sprintf('%3.2f',goose.version.number),' - ',fullfile(pathname, filename)])
        set(goose.gui.text_video,'String',[num2str(goose.video.time),' sec, ',num2str(goose.video.nFrames), ' frames (',num2str(goose.video.Width),' x ',num2str(goose.video.Height),' at ',num2str(goose.video.fps),' fps)'],'FontUnits','normalized','FontSize',.7)
        %plot first frame with imagesc to readjust axes
        axes(goose.gui.ax_video);
        goose.current.pic = imagesc(goose.current.img);
    end
    g_analyze(1);

end


if filetype==3 || strcmpi(ext,'.mat') %open goose project file
        projectfile = load(fullfile(pathname, filename));
        if ~isempty(projectfile) && (any(strcmp(fieldnames(projectfile),'sources')) && any(strcmp(fieldnames(projectfile),'analysis'))) %valid file

            %opening file making use of g_open
            %video
            try
                g_open(1, projectfile.sources.video.filename, pathname); %including analysis of current frame, which becomes overwrite some lines later on
            catch e
                h = warndlg({'Could not open video at : ', fullfile(pathname,projectfile.sources.video.filename),e.message},'Error loading video source');
                waitfor(h);
                drawnow;
                g_open(1);
            end

            %audio
            try
                if ~(isempty(projectfile.sources.audio.filename) || isempty(projectfile.sources.audio.pathname))
                    g_open(4, projectfile.sources.audio.filename, projectfile.sources.audio.pathname)
                end
            catch e
                h = warndlg({'Could not open audio at source: ', fullfile(projectfile.sources.audio.pathname,projectfile.sources.audio.filename),e.message},'Error loading audio source');
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
                goose.current.nFramesDone = sum(goose.analysis.framedone);
                prepare_four;
                g_analyze(1); %current frame analyzed another time in order to have g_analyze refresh all displays
                g_plotmarker;
            end

        else
            msgbox('Could not open GooseLab project file','','error');
        end


elseif filetype==4 %open audio file
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
end
