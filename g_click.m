function g_click
global goose

point1 = get(goose.gui.ax_gamp,'currentpoint');
finalRect = rbbox;
point2 = get(goose.gui.ax_gamp,'currentpoint');
point1 = point1(1,1:2);
point2 = point2(1,1:2);
pt1 = min(point1, point2); %left-bottom (x,y)
pt2 = max(point1, point2); %right-top (x,y)

st = get(gcf, 'SelectionType');
switch st
    case 'normal' %left-click

        goose.current.iFrame = round(pt1(1));

        if pt2(1) - pt1(1) < goose.video.nFrames/100  % minimum 1% frames difference for range, else smeared click is assumed
            g_analyze(1);
        else
            goose.set.process.framerange = [round(pt1(1)), round(pt2(1))];
            g_analyze_set;
        end

    case 'alt' %right-click
        goose.current.jFrame = round(pt1(1));
        set(goose.gui.line_pos_ind_gamp,'XData',[goose.current.jFrame, goose.current.jFrame]);
        pause(.5)
        set(goose.gui.line_pos_ind_gamp,'XData',[goose.current.iFrame, goose.current.iFrame]);

end