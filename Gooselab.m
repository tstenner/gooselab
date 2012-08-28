function Gooselab(pathname, frame_acc)

%Gooselab(pathname, frame_acc)
%
% Gooselab analyzes a video of human skin for the intensity of goosebumps. Type Gooselab to start the GUI.
% You can also use the command line functionality and analyze all videos located in one directory
% For each video you receive feedback on the goose-amp mean and maximum
%
% pathname   analyze alle files in this directory (absolute dir)
% frame_acc  accuracy, video is analyzed in steps of frame_acc frames.
%            for frame_acc = 1 all frames are analyzed (default)


clear global goose
close all
clc;

goosedir = fileparts(which('Gooselab.m'));
addpath(genpath(goosedir)); %add all subdirectories of Gooselab to Matlab path
%savepath;

global goose
goose.version.number = 1.25;
goose.version.datestr = '2012-08-27';





if nargin == 0

    %% Intro
    %if 1
        %g_logo;
        %pause(1);
        %close(goose.gui.fig_logo);
    %end

    %% build GUI
    goose.gui.fig_main = figure('Units','normalized','Position',[0 .03 1 .92],'Menubar','None','Name',['GooseLab ',sprintf('%3.2f',goose.version.number)],'Numbertitle','Off','KeyPressFcn','g_figkeypressfcn');
%   maximize(goose.gui.fig_main);

% Here we define the menus on top. The format is 
% { 'Menutitle', {'Title 1','callbackfn',seperator;
% 'Title 2','fn2',seperator};
% 'Menu 2 Title', { etc...
    menu = {
        'File', {
            'Load Video','g_open(1)',0;
            'Load Image','g_open(2)',0};
        'Settings', {
            'Analysis Settings','g_set_analysis',0;
            'Visual Settings','g_set_visual',0;
            'Refresh Graphics','g_set_refresh',0};
        'Analysis', {
            'Analyze','g_analyze_set',0;
            'Analyze current frame','g_analyze(1)',0;
            'Normalize','g_renorm_gui',1;
            'Reset analysis','g_reset(0)',1};
        'Tools', {
            'Find LED Marker','g_getmarker(0)',0;
            'Add Marker','g_modifymarker(1)',0;
            'Delete Marker','g_modifymarker(2)',0;
            'Remove LED Artifacts','remove_LEDartifact',0;
            'Spectrum','g_spectrum',1};
        'Play', {
            'Play video & sound','g_play(1)',0;
            'Toggle frames','toggle_frames',1;
            'File Mode','g_imaq',1;
            'Stream Mode','g_imaq',0};
        'Export', {
            'Single Picture','g_export(1)',0;
            'Animated Gif','g_export(2)',0;
            'Goose Values','g_export(3)',1};

        'Help', {
            'Info','g_info',0;
            'About Gooselab','g_logo',0}
    };
    sep = {'off','on'};
    for i=1:length(menu)
        submenu = uimenu(goose.gui.fig_main,'Label',menu{i,1});
        for j=1:length(menu{i,2}(:,1))
            entry = menu{i,2}(j,:);
            uimenu(submenu, 'Label', entry{1}, 'Callback', entry{2}, 'Separator', sep{entry{3}+1});
        end
    end

    goose.gui.ax_sound = axes('Units','normalized','Position',[.05 .847 .9 .12],'YLim',[-1, 1],'ButtonDownFcn','g_click','FontUnits','normalized','FontSize',.13);
    goose.gui.text_sound_title = uicontrol('Units','normalized','Style','text','Position',[.25 .967 .5 .03],'String','Soundtrack','BackgroundColor',get(gcf,'Color'),'FontUnits','normalized','FontSize',.65);
    goose.gui.text_sound_xlabel = uicontrol('Units','normalized','Style','text','Position',[.96 .825 .03 .02],'String','s','BackgroundColor',get(gcf,'Color'),'FontUnits','normalized','FontSize',.8,'HorizontalAlignment','left');
    goose.gui.text_sound = uicontrol('Units','normalized','Style','text','Position',[.05 .815 .3 .014],'BackgroundColor',get(gcf,'Color'),'HorizontalAlignment','left');
    goose.gui.ax_gamp = axes('Units','normalized','Position',[.05 .65 .9 .12],'ButtonDownFcn','g_click','YLim',[0, .5],'FontUnits','normalized','FontSize',.13);
    goose.gui.text_gamp_title =uicontrol('Units','normalized','Style','text','Position',[.25 .775 .5 .03],'String','Time Course of Goosebump Values','BackgroundColor',get(gcf,'Color'),'FontUnits','normalized','FontSize',.65);
    goose.gui.text_gamp_xlabel = uicontrol('Units','normalized','Style','text','Position',[.96 .625 .03 .02],'String','s','BackgroundColor',get(gcf,'Color'),'FontUnits','normalized','FontSize',.8,'HorizontalAlignment','left');

    goose.gui.ax_video = axes('Units','normalized','Position',[.05 .05 .3 .4]);
    goose.current.pic = imagesc(imread('Projektlogo.jpg'),'ButtonDownFcn','g_open(1)');
    text(50,365,'Load video...','Color',[1 1 1],'FontUnits','normalized','FontSize',.045,'ButtonDownFcn','g_open(1)');
    set(gca, 'XTick', [], 'YTick', [], 'Box', 'on','XColor',[0 0 0], 'YColor', [0 0 0],'YDir','reverse');
    goose.gui.text_video = uicontrol('Units','normalized','Style','text','Position',[.05 .01 .35 .024],'BackgroundColor',get(gcf,'Color'),'HorizontalAlignment','left','FontUnits','normalized');
    goose.gui.ax_video_title = uicontrol('Units','normalized','Style','text','Position',[.05 .45 .3 .03],'String','Frame of Skin Video','BackgroundColor',get(gcf,'Color'),'FontUnits','normalized','FontSize',.75);

    goose.gui.ax_gray = axes('Units','normalized','Position',[.44 .28 .13 .17],'FontUnits','normalized','FontSize',.1);
    goose.gui.txt_gray_xlabel = uicontrol('Units','normalized','Style','text','Position',[.58 .25 .02 .02],'String','pix','BackgroundColor',get(gcf,'Color'),'FontUnits','normalized','FontSize',.7,'HorizontalAlignment','left');
    goose.gui.txt_gray_ylabel = uicontrol('Units','normalized','Style','text','Position',[.415 .44 .02 .02],'String','pix','BackgroundColor',get(gcf,'Color'),'FontUnits','normalized','FontSize',.7,'HorizontalAlignment','left');
    goose.gui.txt_gray_title = uicontrol('Units','normalized','Style','text','Position',[.46 .45 .15 .025],'String','Gray image','BackgroundColor',get(gcf,'Color'),'FontUnits','normalized','FontSize',.7,'HorizontalAlignment','left');
    goose.gui.ax_fft2 = axes('Units','normalized','Position',[.44 .05 .13 .17],'FontUnits','normalized','FontSize',.1);
    goose.gui.txt_fft2_xlabel = uicontrol('Units','normalized','Style','text','Position',[.58 .02 .04 .02],'String','inv.pix','BackgroundColor',get(gcf,'Color'),'FontUnits','normalized','FontSize',.7,'HorizontalAlignment','left');
    goose.gui.txt_fft2_ylabel = uicontrol('Units','normalized','Style','text','Position',[.405 .21 .03 .02],'String','inv.pix','BackgroundColor',get(gcf,'Color'),'FontUnits','normalized','FontSize',.7,'HorizontalAlignment','left');
    goose.gui.text_fft2_title = uicontrol('Units','normalized','Style','text','Position',[.454 .22 .15 .025],'String','Fourier Transform','BackgroundColor',get(gcf,'Color'),'FontUnits','normalized','FontSize',.7,'HorizontalAlignment','left');
    goose.gui.text_fft2Info = uicontrol('Units','normalized','Style','text','Position',[.43 .00 .15 .025],'BackgroundColor',get(gcf,'Color'),'HorizontalAlignment','center');
    goose.gui.ax_spec = axes('Units','normalized','Position',[.65 .05 .3 .4],'FontUnits','normalized','FontSize',.04);
    goose.gui.txt_spec_xlabel = uicontrol('Units','normalized','Style','text','Position',[.962 .027 .04 .02],'String','inv.pix','BackgroundColor',get(gcf,'Color'),'FontUnits','normalized','FontSize',.7,'HorizontalAlignment','left');
    goose.gui.txt_spec_ylabel = uicontrol('Units','normalized','Style','text','Position',[.61 .45 .03 .02],'String','inv.pix','BackgroundColor',get(gcf,'Color'),'FontUnits','normalized','FontSize',.7,'HorizontalAlignment','left');
    goose.gui.text_spec_title = uicontrol('Units','normalized','Style','text','Position',[.7 .45 .3 .03],'String','Radial Integral of Fourier Transform','BackgroundColor',get(gcf,'Color'),'FontUnits','normalized','FontSize',.6,'HorizontalAlignment','left');

    goose.gui.butt_rec = uicontrol('Units','normalized','Position',[.62 .55 .05 .03],'String','record','Callback','g_record','FontUnits','normalized','FontSize',.5,'Enable','off');
    goose.gui.butt_play = uicontrol('Units','normalized','Position',[.70 .55 .05 .03],'String','play','Callback','g_play','FontUnits','normalized','FontSize',.5);
    goose.gui.chbx_analyze_while_playing = uicontrol('Units','normalized','Style','checkbox','Position',[.83 .55 .13 .03],'BackgroundColor',get(gcf,'Color'),'String','on-the-fly analysis','Value',1,'FontUnits','normalized','FontSize',.6);

    goose.gui.text_pos_sec = uicontrol('Units','normalized','Style','text','Position',[.1 .581 .05 .02],'String','Time','BackgroundColor',get(gcf,'Color'),'FontUnits','normalized','FontSize',.9);
    goose.gui.edit_pos_sec = uicontrol('Units','normalized','Style','edit','Position',[.1 .55 .05 .03],'String','','FontUnits','normalized','FontSize',.55,'Enable','inactive');
    goose.gui.text_pos_frame = uicontrol('Units','normalized','Style','text','Position',[.18 .581 .05 .02],'String','Frame','BackgroundColor',get(gcf,'Color'),'FontUnits','normalized','FontSize',.9);
    goose.gui.edit_pos_frame = uicontrol('Units','normalized','Style','edit','Position',[.18 .55 .05 .03],'String','','FontUnits','normalized','FontSize',.55,'Callback','goto_frame');

    goose.gui.text_gamp = uicontrol('Units','normalized','Style','text','Position',[.29 .581 .07 .02],'String','Goose-Amp','BackgroundColor',get(gcf,'Color'),'FontUnits','normalized','FontSize',.9);
    goose.gui.edit_gamp = uicontrol('Units','normalized','Style','edit','Position',[.3 .55 .05 .03],'String','','FontUnits','normalized','FontSize',.55,'Enable','inactive');

    goose.gui.text_gamp_done = uicontrol('Units','normalized','Style','text','Position',[.39 .581 .07 .02],'String','Analyzed','BackgroundColor',get(gcf,'Color'),'FontUnits','normalized','FontSize',.9);
    goose.gui.edit_gamp_done = uicontrol('Units','normalized','Style','edit','Position',[.39 .55 .07 .03],'String','','FontUnits','normalized','FontSize',.4,'Enable','inactive');
    goose.gui.butt_stop_analysis = uicontrol('Units','normalized','Position',[.39 .52 .07 .025],'String','stop analysis','Callback','g_analyze(0)','Visible','off','FontUnits','normalized','FontSize',.5);

    goose.current = struct('batchmode',0,'isanalyzing',0,'isplaying',0,...
        'istoggling',0,'isrecording',0,'iFrame',1,'jFrame',1,...
        'nFramesDone',0,'spect_limy',0,'legend',[],'imgLenMax',0,'fft2Max',.1);
    %Settings: analysis, process, visual
    goose.set = struct(...
        'analysis',struct(...
            'gausswinsize',.5,...
            'detrend_errorlim',4,... %error tolerance limit before new detrend image updated
            'detrendfact',30,... %smoothing factor: high vals = lower detrend and slower! Choosing lower vals may remove gb frequency
            'spectbyf',2,... %correct for 2D pink noise by * f^2; fixed
            'fac',[1.5,1],...
            'basepolydegree',2,...
            'convwinsize',2,...
            'goosepix',12,...
            'gooserange',[10 14],...
            'specttype',1,...
            'basetype',3,...
            'spectpos',3),...
        'process',struct(...
            'framerange',[1 0],...
            'progressionmode',2,...
            'overwrite',0),...
        'visual',struct(...
            'imgLen',0,...
            'rgb_alpha',[1 1 1],...
            'fft2_lim',60,...
            'fft2_radalpha',2,...
            'spect_limx',.5,...
            'spect_limy',[],...
            'updategraphics',[1 1 1 1],...
            'rotate',0)); %-> goose.set.analysis ?!?
        goose.set.analysis.spectposL = {'goosepix','peak location','mean peak loc (all)','mean peak loc (is goose)','mean peak loc (no goose)'};
        goose.set.process.progressionmodeL = {'linear','progressive'};
%goose.set.analysis.detrend_errorlim = 4;  %error tolerance limit before new detrend image updated

    goose.set.greenLED_thresh = .6;
    goose.set.redLED_thresh = 1;
    goose.set.markerNameL = {'LED Onset','LED-Offset','Goose-Onset','Goose-Offset'};
    
    %Settings: visual
    goose.set.visual.showspecL = {'radial spectogram','current baseline fit','amplitude x0 indicator','spectogram for gb-frames','spectogram for no gb-frames','mean baseline fit','legend'};
    goose.set.visual.showspec = [1 0 1 0 0 0 0];
    %Analysis: options
    goose.video.nFrames = 0;
    goose.video.vidobj = [];
    %%
    goose.gui.line_marker = [];
    goose.gui.text_marker = [];


else %batch mode

    if nargin < 2
        frame_acc = 1;
    end

    g_batchanalysis(pathname, frame_acc);    
    
end
