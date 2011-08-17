function g_analyze_set
global goose

goose.gui.settings.fig = figure('Units','normalized','Position',[.05 .5 .3 .4],'Menubar','None','Name','Analyze ...','Numbertitle','Off');

dx = .15; %Breite der UIs
dy = .05; %Höhe der UIs
dy2 = .02; %Abstand zwischen Zeilen
dw1 = .1; %Abstand Txtfelder von links (west)
dw2 = .5; %Abstand der Edits von links
ds = .86; %Abstand des ersten Felds von unten (south)

goose.gui.analyze_set.text_framerange1 = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*0 .5 dy],'String','Frame range (from - to):','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.analyze_set.edit_framerange1 = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*0 dx dy],'String', goose.set.process.framerange(1));
goose.gui.analyze_set.edit_framerange2 = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2+dx+.02 ds-(dy+dy2)*0 dx dy],'String', goose.set.process.framerange(2));
goose.gui.analyze_set.text_framerangemax = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw2+dx*2+.02*2 ds-(dy+dy2)*0 .1 dy],'String',['(',num2str(goose.video.nFrames),')'],'HorizontalAlignment','center','BackgroundColor',get(gcf,'Color'));
goose.gui.analyze_set.text_progressionmode = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*1 .5 dy],'String','progression mode:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.analyze_set.popm_progressionmode = uicontrol('Style','popupmenu','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*1 dx*2 dy],'String',goose.set.process.progressionmodeL,'Value',goose.set.process.progressionmode,'HorizontalAlignment','left');
goose.gui.analyze_set.text_overwrite = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*2 .5 dy],'String','Overwrite:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.analyze_set.chbx_overwrite = uicontrol('Style','checkbox','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*2 .05 dy],'String','','Value', goose.set.process.overwrite);

goose.gui.settings.butt_resetanalyze = uicontrol('Style','pushbutton','Units','normalized','FontUnits','normalized','Position',[.45 .05 .22 .05],'String', 'Reset & Analyze','Callback',{@apply_settings,2});
goose.gui.settings.butt_analyze = uicontrol('Style','pushbutton','Units','normalized','FontUnits','normalized','Position',[.75 .05 .15 .05],'String', 'Analyze','Callback',{@apply_settings,1});


function apply_settings(src,eventdata, flag)
global goose

if flag == 2,
    g_reset(1);
end

goose.set.process.framerange(1) = str2double(get(goose.gui.analyze_set.edit_framerange1,'String'));
if goose.set.process.framerange(1) < 1, goose.set.process.framerange(1) = 1; end 
goose.set.process.framerange(2) = str2double(get(goose.gui.analyze_set.edit_framerange2,'String'));
if goose.set.process.framerange(2) > goose.video.nFrames, goose.set.process.framerange(2) = goose.video.nFrames; end 
goose.set.process.progressionmode = get(goose.gui.analyze_set.popm_progressionmode,'Value');
goose.set.process.overwrite = get(goose.gui.analyze_set.chbx_overwrite,'Value');

close(goose.gui.settings.fig);
figure(goose.gui.fig_main);
drawnow;

switch goose.set.process.progressionmode
    case 1, g_analyze(3);
    case 2, g_analyze(2);
end