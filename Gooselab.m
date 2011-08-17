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
goose.version.number = 1.21;
goose.version.datestr = '2009-07-13';

%Settings: analysis
goose.set.analysis.gausswinsize = .5;
goose.set.analysis.detrend_errorlim = 4;  %error tolerance limit before new detrend image updated
goose.set.analysis.detrendfact = 30; %40      %smoothing factor: high vals = lower detrend and slower! Choosing lower vals may remove gb frequency
goose.set.analysis.spectbyf = 2; %correct for 2D pink noise by * f^2; fixed
goose.set.analysis.convwinsize = 2;
goose.set.analysis.goosepix = 12;
goose.set.analysis.gooserange = [10 14]; %[5,10]; %
goose.set.analysis.specttype = 1;
goose.set.analysis.basetype = 3;
goose.set.analysis.spectposL = {'goosepix','peak location','mean peak loc (all)','mean peak loc (is goose)','mean peak loc (no goose)'};
goose.set.analysis.spectpos = 3;
goose.set.analysis.fac = [1.5, 1];
goose.set.analysis.basepolydegree = 2;

goose.set.greenLED_thresh = .6;
goose.set.redLED_thresh = 1;
goose.set.markerNameL = {'LED Onset','LED-Offset','Goose-Onset','Goose-Offset'};

goose.set.visual.rotate = 0; %-> goose.set.analysis ?!?



if nargin == 0

    %% Intro
    if 1
        g_logo;
        pause(1);
        close(goose.gui.fig_logo);
    end

    %% build GUI
    goose.gui.fig_main = figure('Units','normalized','Position',[0 .03 1 .92],'Menubar','None','Name',['GooseLab ',sprintf('%3.2f',goose.version.number)],'Numbertitle','Off','KeyPressFcn','g_figkeypressfcn');
%   maximize(goose.gui.fig_main);
    goose.gui.menu_1  = uimenu(goose.gui.fig_main,'Label','File');
    goose.gui.menu_1a = uimenu(goose.gui.menu_1,'Label','Load Video','Callback','g_open(1)');
    goose.gui.menu_1b = uimenu(goose.gui.menu_1,'Label','Load Image','Callback','g_open(2)');
    goose.gui.menu_1c = uimenu(goose.gui.menu_1,'Label','Associate Stimulus','Callback','g_open(4)');
    goose.gui.menu_1d = uimenu(goose.gui.menu_1,'Label','Open GooseLab Project','Callback','g_open(3)','Separator','on');
    goose.gui.menu_1e = uimenu(goose.gui.menu_1,'Label','Save GooseLab Project','Callback','g_save');
    goose.gui.menu_1x = uimenu(goose.gui.menu_1,'Label','Exit','Callback','delete(gcf)','Separator','on');

    goose.gui.menu_2  = uimenu(goose.gui.fig_main,'Label','Settings');
    goose.gui.menu_2a = uimenu(goose.gui.menu_2,'Label','Analysis Settings','Callback','g_set_analysis');
    goose.gui.menu_2b = uimenu(goose.gui.menu_2,'Label','Visual Settings','Callback','g_set_visual');
    goose.gui.menu_2c = uimenu(goose.gui.menu_2,'Label','Resfresh Graphics','Callback','g_set_refresh');

    goose.gui.menu_3  = uimenu(goose.gui.fig_main,'Label','Analysis');
    goose.gui.menu_3a = uimenu(goose.gui.menu_3,'Label','Analyze ...','Callback','g_analyze_set');
    goose.gui.menu_3b = uimenu(goose.gui.menu_3,'Label','Analyze current frame','Callback','g_analyze(1)');
    goose.gui.menu_3c = uimenu(goose.gui.menu_3,'Label','Normalize','Callback','g_renorm_gui','Separator','on','Accelerator','n');
    %goose.gui.menu_3c = uimenu(goose.gui.menu_3,'Label','Normalize ...','Callback','g_normalize_set','Separator','on');
    goose.gui.menu_3d = uimenu(goose.gui.menu_3,'Label','Reset analysis','Callback','g_reset(1)','Separator','on');

    goose.gui.menu_4  = uimenu(goose.gui.fig_main,'Label','Tools');
    goose.gui.menu_4a = uimenu(goose.gui.menu_4,'Label','Find LED Marker','Callback','g_getmarker(0)');
    goose.gui.menu_4b = uimenu(goose.gui.menu_4,'Label','Add Marker','Callback','g_modifymarker(1)');
    goose.gui.menu_4c = uimenu(goose.gui.menu_4,'Label','Delete Marker','Callback','g_modifymarker(2)');
    goose.gui.menu_4d = uimenu(goose.gui.menu_4,'Label','Remove LED Artifacts','Callback','remove_LEDartifact');
    %    goose.gui.menu_4b = uimenu(goose.gui.menu_4,'Label','Get Marker (< V1.15)','Callback','get_marker(0)');
    goose.gui.menu_4e = uimenu(goose.gui.menu_4,'Label','Spectrum ','Callback','g_spectrum','Separator','on');

    goose.gui.menu_5  = uimenu(goose.gui.fig_main,'Label','Play');
    goose.gui.menu_5a = uimenu(goose.gui.menu_5,'Label','Play video & sound','Callback','g_play(1)');
    goose.gui.menu_5b = uimenu(goose.gui.menu_5,'Label','Toggle Frames','Callback','toggle_frames','Separator','on');
    goose.gui.menu_5c = uimenu(goose.gui.menu_5,'Label','File Mode','Callback','g_imaq','Enable','off','Separator','on');
    goose.gui.menu_5d = uimenu(goose.gui.menu_5,'Label','Stream Mode','Callback','g_imaq');

    goose.gui.menu_6  = uimenu(goose.gui.fig_main,'Label','Export');
    goose.gui.menu_6a = uimenu(goose.gui.menu_6,'Label','Single Picture','Callback','g_export(1)');
    goose.gui.menu_6b = uimenu(goose.gui.menu_6,'Label','Animated Gif','Callback','g_export(2)');
    goose.gui.menu_6c = uimenu(goose.gui.menu_6,'Label','Goose Values','Callback','g_export(3)','Separator','on');

    goose.gui.menu_7  = uimenu(goose.gui.fig_main,'Label','Help');
    goose.gui.menu_7a = uimenu(goose.gui.menu_7,'Label','Info','Callback','g_info');
    goose.gui.menu_7b = uimenu(goose.gui.menu_7,'Label','About Gooselab','Callback','g_logo','Separator','on');


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

    goose.current.batchmode = 0;
    goose.current.isanalyzing = 0;
    goose.current.isplaying = 0;
    goose.current.istoggling = 0;
    goose.current.isrecording = 0;
    goose.current.iFrame = 1;
    goose.current.jFrame = 1;
    goose.current.nFramesDone = 0;
    goose.current.spect_limy = 0;
    goose.current.legend = [];
    goose.current.imgLenMax = 0;
    goose.current.fft2Max = 0;
    %Settings: visual
    goose.set.visual.imgLen = 0;
    goose.set.visual.rgb_alpha = [1 1 1];
    goose.set.visual.fft2_lim = 60;
    goose.set.visual.fft2_radalpha = 2;
    goose.set.visual.spect_limx = .5;
    goose.set.visual.spect_limy = [];
    goose.set.visual.updategraphics = [1 1 1 1];  %video, gray image, FFT2, spectogram
    goose.set.visual.showspecL = {'radial spectogram','current baseline fit','amplitude x0 indicator','spectogram for gb-frames','spectogram for no gb-frames','mean baseline fit','legend'};
    goose.set.visual.showspec = [1 0 1 0 0 0 0];
    %Analysis: options
    goose.set.process.framerange = [1 0];
    goose.set.process.progressionmodeL = {'linear','progressive'};
    goose.set.process.progressionmode = 2;
    goose.set.process.overwrite = 0;
    goose.video.nFrames = 0;
    goose.video.vidobj = [];
    %%%
    goose.gui.line_marker = [];
    goose.gui.text_marker = [];


else %batch mode

    if nargin < 2
        frame_acc = 1;
    end

    g_batchanalysis(pathname, frame_acc);    
    
end
