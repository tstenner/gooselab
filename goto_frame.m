function goto_frame(frame)
global goose

goose.current.iFrame = max(1,min(goose.video.nFrames-1,frame));
set(goose.gui.edit_pos_frame,'String',num2str(frame));
g_analyze(1);