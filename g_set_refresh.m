function g_set_refresh
global goose

goose.gui.settings.fig = figure('Units','normalized','Position',[.05 .5 .35 .4],'Menubar','None','Name','Refresh Graphics','Numbertitle','Off');

dx = .15; %Breite der UIs
dy = .05; %Höhe der UIs
dy2 = .02; %Abstand zwischen Zeilen
dw1 = .1; %Abstand Txtfelder von links (west)
dw2 = .5; %Abstand der Edits von links
ds = .86; %Abstand des ersten Felds von unten (south)


goose.gui.settings.text_updategraphics = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*0 .5 dy],'String','Update graphics:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.chbx_updategraph(1) = uicontrol('Style','checkbox','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*1 dx*2.5 dy],'String','Video','Value', goose.set.visual.updategraphics(1));
goose.gui.settings.chbx_updategraph(2) = uicontrol('Style','checkbox','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*2 dx*2.5 dy],'String','Gray image','Value', goose.set.visual.updategraphics(2));
goose.gui.settings.chbx_updategraph(3) = uicontrol('Style','checkbox','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*3 dx*2.5 dy],'String','FFT2','Value', goose.set.visual.updategraphics(3));
goose.gui.settings.chbx_updategraph(4) = uicontrol('Style','checkbox','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*4 dx*2.5 dy],'String','Spectogram','Value', goose.set.visual.updategraphics(4));
goose.gui.settings.text_showspec    = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*6 .5 dy],'String','Show spectogram features:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.chbx_showspec(1) = uicontrol('Style','checkbox','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*7 dx*2.5 dy],'String',goose.set.visual.showspecL{1},'Value', goose.set.visual.showspec(1));
goose.gui.settings.chbx_showspec(2) = uicontrol('Style','checkbox','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*8 dx*2.5 dy],'String',goose.set.visual.showspecL{2},'Value', goose.set.visual.showspec(2));
goose.gui.settings.chbx_showspec(3) = uicontrol('Style','checkbox','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*9 dx*2.5 dy],'String',goose.set.visual.showspecL{3},'Value', goose.set.visual.showspec(3));
goose.gui.settings.chbx_showspec(4) = uicontrol('Style','checkbox','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*10 dx*2.5 dy],'String',goose.set.visual.showspecL{4},'Value', goose.set.visual.showspec(4));
goose.gui.settings.chbx_showspec(5) = uicontrol('Style','checkbox','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*7 dx*2.5 dy],'String',goose.set.visual.showspecL{5},'Value', goose.set.visual.showspec(5));
goose.gui.settings.chbx_showspec(6) = uicontrol('Style','checkbox','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*8 dx*2.5 dy],'String',goose.set.visual.showspecL{6},'Value', goose.set.visual.showspec(6));
goose.gui.settings.chbx_showspec(7) = uicontrol('Style','checkbox','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*9 dx*2.5 dy],'String',goose.set.visual.showspecL{7},'Value', goose.set.visual.showspec(7));

goose.gui.settings.butt_apply = uicontrol('Style','pushbutton','Units','normalized','FontUnits','normalized','Position',[.75 .05 .15 .05],'String', 'Apply','Callback',@apply_settings);


function apply_settings(src,eventdata)
global goose

for i = 1:4
    goose.set.visual.updategraphics(i) = get(goose.gui.settings.chbx_updategraph(i),'Value');
end
for i = 1:length(goose.set.visual.showspecL)
    goose.set.visual.showspec(i) = get(goose.gui.settings.chbx_showspec(i),'Value');
end


close(goose.gui.settings.fig);
figure(goose.gui.fig_main);
drawnow;

g_analyze(1);