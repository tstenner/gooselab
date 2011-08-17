function g_set_visual
global goose

goose.gui.settings.fig = figure('Units','normalized','Position',[.05 .5 .35 .4],'Menubar','None','Name','Visual Settings','Numbertitle','Off');

dx = .15; %Breite der UIs
dy = .05; %Höhe der UIs
dy2 = .02; %Abstand zwischen Zeilen
dw1 = .1; %Abstand Txtfelder von links (west)
dw2 = .5; %Abstand der Edits von links
ds = .86; %Abstand des ersten Felds von unten (south)

goose.gui.settings.text_imgL      = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*0 .5 dy],'String','Image  length [px]:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.edit_imgL      = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*0 dx dy],'String', goose.set.visual.imgLen);
goose.gui.settings.text_rotate       = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*1 .5 dy],'String','Rotate image (counterclockwise):','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.popm_rotate       = uicontrol('Style','popupmenu','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*1 dx dy],'String', {'0°';'90°';'180°';'270°'},'Value',goose.set.visual.rotate+1);
goose.gui.settings.text_rgb_alpha    = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*2 .5 dy],'String','RGB Alpha (y=x^alpha):','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.edit_rgb_alpha(1) = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*2 dx dy],'String', goose.set.visual.rgb_alpha(1));
goose.gui.settings.edit_rgb_alpha(2) = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*3 dx dy],'String', goose.set.visual.rgb_alpha(2));
goose.gui.settings.edit_rgb_alpha(3) = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*4 dx dy],'String', goose.set.visual.rgb_alpha(3));
goose.gui.settings.text_fft2lim      = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*6 .5 dy],'String','FFT-2D Axes Limit [px]:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.edit_fft2lim      = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*6 dx dy],'String', goose.set.visual.fft2_lim);
goose.gui.settings.text_fft2alpha    = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*7 .5 dy],'String','FFT2-2D Radial r^alpha:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.edit_fft2alpha    = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*7 dx dy],'String', goose.set.visual.fft2_radalpha);
goose.gui.settings.text_spectlim     = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*9 .5 dy],'String','Rad-Spect Limit (x, y):','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.edit_spectlimx    = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*9 dx dy],'String', goose.set.visual.spect_limx);
goose.gui.settings.edit_spectlimy    = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2+dx+.02 ds-(dy+dy2)*9 dx dy],'String', goose.set.visual.spect_limy);

goose.gui.settings.butt_apply = uicontrol('Style','pushbutton','Units','normalized','FontUnits','normalized','Position',[.6 .05 .15 .05],'String', 'Apply','Callback',@apply_settings);
goose.gui.settings.butt_close = uicontrol('Style','pushbutton','Units','normalized','FontUnits','normalized','Position',[.77 .05 .13 .05],'String', 'Close','Callback',@closefig);


function apply_settings(src,eventdata)
global goose

%L_img = goose.set.visual.imgLen;
goose.set.visual.imgLen = str2double(get(goose.gui.settings.edit_imgL,'String'));

goose.set.visual.rotate = get(goose.gui.settings.popm_rotate,'Value') - 1;
for i = 1:3
    goose.set.visual.rgb_alpha(i) = str2double(get(goose.gui.settings.edit_rgb_alpha(i),'String'));
end
goose.set.visual.fft2_lim = str2double(get(goose.gui.settings.edit_fft2lim,'String'));
%goose.set.visual.fft2_lim = min(goose.set.visual.imgLen, goose.set.visual.fft2_lim);
goose.set.visual.spect_limx = str2double(get(goose.gui.settings.edit_spectlimx,'String'));
goose.set.visual.spect_limx = max(min(goose.set.visual.spect_limx,1), 0);
goose.set.visual.spect_limy = str2double(get(goose.gui.settings.edit_spectlimy,'String'));
if isnan(goose.set.visual.spect_limy), goose.set.visual.spect_limy = []; end
goose.set.visual.fft2_radalpha = str2double(get(goose.gui.settings.edit_fft2alpha,'String'));

%reset necessary because of different spect size
% iFrame = goose.current.iFrame;
% if L_img ~= goose.set.visual.imgLen %was modified
%      g_reset(1);
% end
% goose.current.iFrame = iFrame;

prepare_four;
g_analyze(1);
figure(goose.gui.settings.fig);


function closefig(scr, event)
global goose

close(goose.gui.settings.fig);
figure(goose.gui.fig_main);