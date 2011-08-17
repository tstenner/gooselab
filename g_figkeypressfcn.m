function g_figkeypressfcn
global goose

ch = double(get(goose.gui.fig_main,'CurrentCharacter'));
if isempty(ch),
    return;
end

switch ch,
    case 27, %Esc
        goose.current.isanalyzing = 0; %abort current analysis
        goose.current.isplaying = 0;
        goose.current.istoggling = 0;
        set(goose.gui.butt_stop_analysis,'Visible','off');

    case 28 %left
        goose.current.iFrame = goose.current.iFrame - 1;
        goose.current.iFrame = max(1, goose.current.iFrame);
        %refresh_display;
        g_analyze(1);

    case 29 %right
        goose.current.iFrame = goose.current.iFrame + 1;
        goose.current.iFrame = min(goose.video.nFrames, goose.current.iFrame);
        %refresh_display;
        g_analyze(1);

    case 97 %"a"
        g_analyze_set;
        
    case 99 %"c"
        g_analyze(1);
        
    case 110 %"n"
        g_normalize_set;
        
    case 111 %"o"
        g_open(1);
        
    case 115 %"s"
        g_save;
        
    case 116 %"t"
        i = goose.current.iFrame;
        goose.current.iFrame = goose.current.jFrame;
        goose.current.jFrame = i;
        g_analyze(1);
    otherwise

end