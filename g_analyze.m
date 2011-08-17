function g_analyze(cmd)
global goose

if cmd == 0
    goose.current.isanalyzing = 0;
    set(goose.gui.butt_stop_analysis,'Visible','off');


elseif cmd == 1 %analyze current frame
    ov = goose.set.process.overwrite;
    gr = goose.set.visual.updategraphics;
    goose.set.process.overwrite = 1; %overwrite settings temporarily
    goose.set.visual.updategraphics = [1 1 1 1];

    analyze_frame(goose.current.iFrame);

    goose.set.process.overwrite = ov;
    goose.set.visual.updategraphics = gr;

elseif cmd == 2 %analyze progressively

    goose.current.isanalyzing = 1;
    set(goose.gui.butt_stop_analysis,'Visible','on');

    f1 = goose.set.process.framerange(1);
    fn = goose.set.process.framerange(2);

    N = fn-f1+1;
    analyze_frame(1);
    analyze_frame(fn);

    %% find order of frames to analyze: continuous bisecting stepsize
    for i = 1:log2(N) %theoretical maximum of needed runs
        fac = 2^(i-1);
        stepsize = N/fac;
        for j = 1:fac %nummer of steps of size stepsize
            frame = f1-1+round(stepsize*(j-.5));%always shifted half stepsize
            analyze_frame(frame);

            if ~goose.current.isanalyzing || goose.current.nFramesDone == goose.video.nFrames  %stop condition
                set(goose.gui.butt_stop_analysis,'Visible','off');
                return;
            end
        end
    end
    g_analyze(3); %analyze all, i.e. the remaining frames that may have been skipped due to rounding errors

elseif cmd == 3 %analyze all
    goose.current.isanalyzing = 1;
    set(goose.gui.butt_stop_analysis,'Visible','on');

    for iFrame = goose.set.process.framerange(1):goose.set.process.framerange(2)  %goose.analysis.marker.start:goose.analysis.marker.end
        analyze_frame(iFrame);

        if ~goose.current.isanalyzing, %abort
            return;
        end
    end
    set(goose.gui.butt_stop_analysis,'Visible','off');
end

% if cmd > 1
%     goose.analysis.version = goose.version;
% end



function analyze_frame(frame)
global goose

%check for bad frame input
if frame > goose.video.nFrames
    frame = goose.video.nFrames;
    goose.current.isplaying = 0;
    set(goose.gui.butt_play,'String','play');
elseif frame < 1
    frame = 1;
end
goose.current.iFrame = frame;

if ~goose.analysis.framedone(frame) || goose.set.process.overwrite

    refresh_display;

    four(goose.current.img);

    ylim = [0, max(goose.analysis.amp*1.2)+.00001];  %
    set(goose.gui.ax_gamp,'YLim',ylim);
    set(goose.gui.line_pos_ind_gamp,'YData',ylim)

    %plot amp
    x = find(goose.analysis.framedone);
    y = goose.analysis.amp(x);
    set(goose.current.plot_gamp, 'XData',x, 'YData',y);
    drawnow;

    goose.current.nFramesDone = length(x);
    set(goose.gui.edit_gamp_done,'String',[num2str(goose.current.nFramesDone),' (',sprintf('%4.2f',goose.current.nFramesDone/goose.video.nFrames*100),'%)'])
    set(goose.gui.edit_gamp,'String',sprintf('%3.2f%', goose.analysis.amp(frame)));
end