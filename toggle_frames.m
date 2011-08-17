function toggle_frames
global goose

goose.gui.play.fig_toggle = figure('Units','normalized','Position',[.05 .5 .3 .2],'Menubar','None','Name','Toggle Frames','Numbertitle','Off');

dx = .15; %Breite der UIs
dy = .1; %Höhe der UIs
dy2 = .04; %Abstand zwischen Zeilen
dw1 = .1; %Abstand Txtfelder von links (west)
dw2 = .5; %Abstand der Edits von links
ds = .66; %Abstand des ersten Felds von unten (south)

goose.gui.play.text_2frames = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*0 .5 dy],'String','Frame 1 - Frame 2:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.play.edit_frame1 = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*0 dx dy],'String', goose.current.iFrame);
goose.gui.play.edit_frame2 = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2+dx+.02 ds-(dy+dy2)*0 dx dy],'String', goose.current.jFrame);
goose.gui.play.text_pause = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*1 .5 dy],'String','Toggle time interval:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.play.popm_pause = uicontrol('Style','popupmenu','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*1 dx*2+.02 dy],'String', {'no fixed interval','0.25s','0.5s','1s', '2s','3s'},'Value',1);
goose.gui.play.butt_go = uicontrol('Style','pushbutton','Units','normalized','FontUnits','normalized','Position',[.75 .05 .15 dy],'String', 'Go','Callback',@toggle);


function toggle(src,eventdata)
global goose

pauseTL = [.25, .5, 1, 2, 3];
goose.current.iFrame = str2double(get(goose.gui.play.edit_frame1,'String'));
goose.current.jFrame = str2double(get(goose.gui.play.edit_frame2,'String'));
ipause = get(goose.gui.play.popm_pause,'Value');

if ipause > 1

    goose.current.istoggling = 1;

    while goose.current.istoggling

        i = goose.current.iFrame;
        goose.current.iFrame = goose.current.jFrame;
        goose.current.jFrame = i;
        g_analyze(1);
        pause(pauseTL(ipause-1));

    end
end

close(goose.gui.play.fig_toggle);