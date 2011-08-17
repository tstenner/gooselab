function g_showval
global goose

p = get(goose.gui.ax_fft2,'CurrentPoint');
p = round(p(1,1:2));

set(goose.gui.txt_fft2Info, 'String', ['max: ',num2str(max(goose.current.fft2img(:)),'%4.2f'),' (overall: ',num2str(goose.current.fft2Max,'%4.2f'),'), current: ',num2str(goose.current.fft2img(p(2), p(1)),'%4.2f')]);