function g_set_analysis
global goose

goose.gui.settings.fig = figure('Units','normalized','Position',[.05 .5 .3 .4],'Menubar','None','Name','Settings','Numbertitle','Off');

dx = .15; %Breite der UIs
dy = .05; %Höhe der UIs
dy2 = .02; %Abstand zwischen Zeilen
dw1 = .1; %Abstand Txtfelder von links (west)
dw2 = .5; %Abstand der Edits von links
ds = .86; %Abstand des ersten Felds von unten (south)


goose.gui.settings.text_winsize     = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*0 .5 dy],'String','Anti-Leakage Window Size:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.edit_winsize     = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*0 dx dy],'String', goose.set.analysis.gausswinsize);
goose.gui.settings.text_detrend = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*1 .5 dy],'String','Detrend error limit / factor:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.edit_detrend_errorlim = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*1 dx dy],'String', goose.set.analysis.detrend_errorlim);
goose.gui.settings.edit_detrendfact = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2+dx+.02 ds-(dy+dy2)*1 dx dy],'String', goose.set.analysis.detrendfact);
goose.gui.settings.text_convwinsize = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*2 .5 dy],'String','FFT2 Smoothing Window Size:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.edit_convwinsize = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*2 dx dy],'String', goose.set.analysis.convwinsize);
goose.gui.settings.text_goosepix = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*4 .5 dy],'String','Goosepix [1/px]:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.edit_goosepix = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*4 dx dy],'String', goose.set.analysis.goosepix);
goose.gui.settings.text_gooserange = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*5 .5 dy],'String','GooseRange (left - right) [1/px] :','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.edit_gooserange1 = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*5 dx dy],'String', goose.set.analysis.gooserange(1));
goose.gui.settings.edit_gooserange2 = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2+dx+.02 ds-(dy+dy2)*5 dx dy],'String', goose.set.analysis.gooserange(2));
goose.gui.settings.text_fac1     = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*6 .5 dy],'String','Fac 1/2 (over/under baseline):','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.edit_fac1     = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*6 dx dy],'String', goose.set.analysis.fac(1));
goose.gui.settings.edit_fac2     = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2+dx+.02  ds-(dy+dy2)*6 dx dy],'String', goose.set.analysis.fac(2));
goose.gui.settings.text_basepoly = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*7 .5 dy],'String','Polynom degree of base:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.edit_basepoly = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*7 dx dy],'String', goose.set.analysis.basepolydegree);


goose.gui.settings.butt_apply = uicontrol('Style','pushbutton','Units','normalized','FontUnits','normalized','Position',[.75 .05 .15 .05],'String', 'Apply','Callback',@apply_settings);


function apply_settings(src,eventdata)
global goose

goose.set.analysis.gausswinsize = str2double(get(goose.gui.settings.edit_winsize,'String'));
goose.set.analysis.detrend_errorlim = str2double(get(goose.gui.settings.edit_detrend_errorlim,'String'));
goose.set.analysis.detrendfact = str2double(get(goose.gui.settings.edit_detrendfact,'String'));
goose.set.analysis.goosepix = str2double(get(goose.gui.settings.edit_goosepix,'String'));
goose.set.analysis.gooserange(1) = str2double(get(goose.gui.settings.edit_gooserange1,'String'));
goose.set.analysis.gooserange(2) = str2double(get(goose.gui.settings.edit_gooserange2,'String'));
goose.set.analysis.convwinsize = str2double(get(goose.gui.settings.edit_convwinsize,'String'));
goose.set.analysis.fac(1) = str2double(get(goose.gui.settings.edit_fac1,'String'));
goose.set.analysis.fac(2) = str2double(get(goose.gui.settings.edit_fac2,'String'));
goose.set.analysis.basepolydegree = str2double(get(goose.gui.settings.edit_basepoly,'String'));

goose.current.detrend_gray = zeros(goose.current.imgLenMax, goose.current.imgLenMax);  %%
goose.current.detrend_smooth = zeros(goose.current.imgLenMax, goose.current.imgLenMax);  %%

close(goose.gui.settings.fig);
drawnow;

%if goose.video.vidobj
prepare_four;
goose.current.spect_limy = 0;
g_analyze(1);
%end