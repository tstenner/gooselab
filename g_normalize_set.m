function g_normalize_set
global goose

goose.gui.settings.fig = figure('Units','normalized','Position',[.05 .5 .3 .4],'Menubar','None','Name','Normalize ...','Numbertitle','Off');

dx = .15; %Breite der UIs
dy = .05; %Höhe der UIs
dy2 = .02; %Abstand zwischen Zeilen
dw1 = .1; %Abstand Txtfelder von links (west)
dw2 = .5; %Abstand der Edits von links
ds = .86; %Abstand des ersten Felds von unten (south)

%goose.gui.settings.text_specttype = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*0 .5 dy],'String','Rad-Spect Type:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
%goose.gui.settings.popm_specttype = uicontrol('Style','popupmenu','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*0 dx*3 dy],'String', {'smooth'},'Value',goose.set.analysis.specttype);
goose.gui.settings.text_spectpos = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*1 .5 dy],'String','Spectogram Position:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.popm_spectpos = uicontrol('Style','popupmenu','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*1 dx*3 dy],'String', goose.set.analysis.spectposL,'Value',goose.set.analysis.spectpos);
goose.gui.settings.text_basetype = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*2 .5 dy],'String','Base Type:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.popm_basetype = uicontrol('Style','popupmenu','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*2 dx*3 dy],'String', {'none','single frame poly','mean poly'},'Value',goose.set.analysis.basetype);
%goose.gui.settings.text_basepos = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*3 .5 dy],'String','Base Position:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
%goose.gui.settings.popm_basepos = uicontrol('Style','popupmenu','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*3 dx*3 dy],'String', goose.set.analysis.spectposL,'Value',goose.set.analysis.basepos);

goose.gui.settings.text_goosepix = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*5 .5 dy],'String','Goosepix [1/px]:','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.edit_goosepix = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*5 dx dy],'String',goose.set.analysis.goosepix);
goose.gui.settings.butt_apply_gp = uicontrol('Style','pushbutton','Units','normalized','FontUnits','normalized','Position',[dw2+(dx+.02) ds-(dy+dy2)*5 dx dy],'String', 'apply','Callback',@apply_gp);
goose.gui.settings.text_peakloc1 = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*6 .5 dy],'String','Mean peak location (all):','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.edit_peakloc1 = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*6 dx dy],'String','', 'Enable','off');
goose.gui.settings.text_peakloc2 = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*7 .5 dy],'String','Mean peak location (is goose):','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.edit_peakloc2 = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*7 dx dy],'String','', 'Enable','off');
goose.gui.settings.text_peakloc3 = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*8 .5 dy],'String','Mean peak location (no goose):','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.edit_peakloc3 = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*8 dx dy],'String','', 'Enable','off');
goose.gui.settings.text_fac1     = uicontrol('Style','text','Units','normalized','FontUnits','normalized','Position',[dw1 ds-(dy+dy2)*9 .5 dy],'String','Fac 1/2 (over/under baseline):','HorizontalAlignment','left','BackgroundColor',get(gcf,'Color'));
goose.gui.settings.edit_fac1     = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2 ds-(dy+dy2)*9 dx dy],'String', goose.set.analysis.fac(1));
goose.gui.settings.edit_fac2     = uicontrol('Style','edit','Units','normalized','FontUnits','normalized','Position',[dw2+dx+.02  ds-(dy+dy2)*9 dx dy],'String', goose.set.analysis.fac(2));
goose.gui.settings.butt_refesh_peakloc = uicontrol('Style','pushbutton','Units','normalized','FontUnits','normalized','Position',[dw2+(dx+.02) ds-(dy+dy2)*8 dx dy*3+dy2*2],'String', 'refresh','Callback',{@refresh_peakloc,1});

goose.gui.settings.butt_normalize = uicontrol('Style','pushbutton','Units','normalized','FontUnits','normalized','Position',[.75 .05 .15 .05],'String', 'Normalize','Callback',@normalize);

refresh_peakloc(1,1,0);



function apply_gp(src,eventdata)
global goose

goose.set.analysis.goosepix = str2double(get(goose.gui.settings.edit_goosepix,'String'));


function normalize(src,eventdata)
global goose

%goose.set.analysis.specttype = get(goose.gui.settings.popm_specttype,'Value');
goose.set.analysis.basetype = get(goose.gui.settings.popm_basetype,'Value');
goose.set.analysis.spectpos = get(goose.gui.settings.popm_spectpos,'Value');
%goose.set.analysis.basepos = get(goose.gui.settings.popm_basepos,'Value');
goose.set.analysis.goosepix = str2double(get(goose.gui.settings.edit_goosepix,'String'));
goose.set.analysis.fac(1) = str2double(get(goose.gui.settings.edit_fac1,'String'));
goose.set.analysis.fac(2) = str2double(get(goose.gui.settings.edit_fac2,'String'));

close(goose.gui.settings.fig);
figure(goose.gui.fig_main);
drawnow;

g_normalize;


function refresh_peakloc(src,eventdata,flag)
global goose

goose.set.analysis.fac(1) = str2double(get(goose.gui.settings.edit_fac1,'String'));
goose.set.analysis.fac(2) = str2double(get(goose.gui.settings.edit_fac2,'String'));

isdone = find(goose.analysis.framedone);
mpoly = mean(goose.analysis.fitp(:, isdone), 2);
meanbase_goosepix = polyval(mpoly, goose.set.analysis.goosepix);
isgoose = goose.analysis.framedone & (goose.analysis.amp > goose.set.analysis.fac(1)*meanbase_goosepix);
nogoose = goose.analysis.framedone & (goose.analysis.amp < goose.set.analysis.fac(2)*meanbase_goosepix);

amppos1 = mean(goose.analysis.x0_amp(isdone));    %mean peak loc
if any(isgoose)
    amppos2 = mean(goose.analysis.x0_amp(isgoose));   %mean peak loc isgoose
else
    amppos2 = NaN; %??
end
if any(nogoose)
    amppos3 = mean(goose.analysis.x0_amp(nogoose));   %mean peak loc nogoose
else
    amppos3 = NaN; %??
end

if flag
    g_analyze(1);
    figure(goose.gui.settings.fig);
end

set(goose.gui.settings.edit_peakloc1,'String',num2str(amppos1));
set(goose.gui.settings.edit_peakloc2,'String',num2str(amppos2));
set(goose.gui.settings.edit_peakloc3,'String',num2str(amppos3));
