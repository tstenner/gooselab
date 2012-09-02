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
        goto_frame(goose.current.iFrame-1);

    case 29 %right
        goto_frame(goose.current.iFrame+1);

    case 'a'
        g_analyze_set;
        
    case 'c'
        g_analyze(1);
        
    case 'n'
        g_normalize_set;
        
    case 'o'
        g_open(1);
        
    case 's'
        g_save;
        
    case 't'
        i = goose.current.iFrame;
        goose.current.iFrame = goose.current.jFrame;
        goose.current.jFrame = i;
        g_analyze(1);
    otherwise

end