function g_play  %(cmd)
global goose

%check if mode is not already on
if ~goose.current.isplaying 
    goose.current.isplaying = 1; %play    

    goose.current.startFrame = goose.current.iFrame;

    if goose.audio.nSamples > 0 %sound exists
        curr_audio_sample = goose.current.iFrame/goose.video.fps*goose.audio.Fs;
        play(goose.audio.audplayer, curr_audio_sample);
    end
    set(goose.gui.butt_play,'String','stop');

    start = clock;
    while goose.current.isplaying
        play_time = etime(clock, start);
        goose.current.iFrame = round(goose.current.startFrame + play_time * goose.video.fps);
        if get(goose.gui.chbx_analyze_while_playing,'Value')
            g_analyze(1);
        else
            refresh_display;
            drawnow;
        end
    end


else 
    goose.current.isplaying = 0; %stop
        
    if goose.audio.nSamples > 0
        stop(goose.audio.audplayer)
    end
    set(goose.gui.butt_play,'String','play');
    
end