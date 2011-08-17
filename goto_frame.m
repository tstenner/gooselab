function goto_frame
global goose

frame = str2double(get(goose.gui.edit_pos_frame,'String'));
goose.current.iFrame = frame;
g_analyze(1);