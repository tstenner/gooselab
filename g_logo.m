function g_logo
global goose

goose.gui.fig_logo = figure('Menubar','None','Name',['GooseLab ',sprintf('%3.2f',goose.version.number)],'Numbertitle','Off');
imagesc(imread('Projektlogo.jpg'));
set(gca,'Position',[0,0,1,1]);
axis off;
text(35,345,['GooseLab ',sprintf('%3.2f',goose.version.number), '   (',goose.version.datestr,')'],'Color',[1 1 1],'FontSize',8)
text(35,360,'Contact: Christian Kaernbach','Color',[1 1 1],'FontSize',8)
text(35,370,'www.kaernbach.de','Color',[1 1 1],'FontSize',8)
text(35,385,'Code by C. Kaernbach & M. Benedek','Color',[1 1 1],'FontSize',7)
