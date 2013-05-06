function refresh_display
global goose

iFrame = goose.current.iFrame;
if iFrame > goose.video.nFrames %redundant with analyze_frame (but mind g_play)
    goose.current.isplaying = 0;
    set(goose.gui.butt_play,'String','play');
    goose.current.iFrame = goose.video.nFrames;
    iFrame = goose.current.iFrame;
end

if goose.video.nFrames > 1 || ~isempty(goose.video.vidobj) %video, no picture

    if isempty(goose.video.vidobj) %video
        % When using mmreader, reshape isn't needed anymore
        try
            goose.current.img = double(read(goose.video.aviobj, goose.current.iFrame))/255;
        catch e
            goose.current.img = zeros(goose.video.Height,goose.video.Width,3,'double');
        end
    end

    if ~all(goose.set.visual.rgb_alpha == 1)
        goose.current.img(:,:,1) = goose.current.img(:,:,1).^(1/goose.set.visual.rgb_alpha(1)); %change rgb weighting
        goose.current.img(:,:,2) = goose.current.img(:,:,2).^(1/goose.set.visual.rgb_alpha(2));
        goose.current.img(:,:,3) = goose.current.img(:,:,3).^(1/goose.set.visual.rgb_alpha(3));
    end

    if goose.set.visual.rotate
        img(:,:,1) = rot90(goose.current.img(:,:,1), goose.set.visual.rotate);  %rotate image
        img(:,:,2) = rot90(goose.current.img(:,:,2), goose.set.visual.rotate);
        img(:,:,3) = rot90(goose.current.img(:,:,3), goose.set.visual.rotate);
        goose.current.img = img;
    end

    if goose.set.visual.updategraphics(1)

        set(goose.current.pic,'cdata',goose.current.img);
        axes(goose.gui.ax_video)
        set(gca, 'XTick', [], 'YTick', [], 'Box', 'on','XColor',[0 0 0], 'YColor', [0 0 0],'YDir','reverse');
        %axis image off
    end
end


set(goose.gui.line_pos_ind_gamp,'XData',[iFrame, iFrame]);
if goose.audio.nSamples > 0
    set(goose.gui.line_pos_ind_sound,'XData',[iFrame, iFrame]);
end

set(goose.gui.edit_pos_sec,'String',sprintf('%5.2f',(iFrame-1)/goose.video.fps));
set(goose.gui.edit_pos_frame,'String',iFrame);
if goose.analysis.framedone(iFrame) %gamp
    set(goose.gui.edit_gamp,'String',sprintf('%3.2f%',goose.analysis.amp(iFrame)));
else
    set(goose.gui.edit_gamp,'String','');
end