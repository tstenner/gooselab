function goto_frame(frame)
global goose

goose.current.iFrame = max(0,min(goose.video.nFrames-1,frame));
set(goose.gui.pos_frame_edit,'String',num2str(frame));
g_analyze(1);