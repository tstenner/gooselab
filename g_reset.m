function g_reset(flag)
global goose

reset_analysis;

if flag
    %reset plot
    delete(goose.current.plot_gamp);
    delete(goose.gui.line_marker(ishandle(goose.gui.line_marker)))

    axes(goose.gui.ax_gamp);
    goose.current.plot_gamp = plot(1,'ButtonDownFcn','g_click','Color',[.4 .4 1],'Marker','s','MarkerEdgeColor',[0 0 1],'MarkerSize',1,'MarkerFaceColor',[0 0 1]); %dummy plot
    ylim([0,2]);

    prepare_four;
    g_analyze(1);
end


function reset_analysis
global goose

goose.analysis = [];
goose.analysis.amp = zeros(1, goose.video.nFrames);
goose.analysis.x0_amp = zeros(1, goose.video.nFrames);
goose.analysis.fitp = zeros(goose.set.analysis.basepolydegree+1, goose.video.nFrames);
goose.analysis.framedone = zeros(1, goose.video.nFrames);
goose.analysis.amp_norm = [];
goose.analysis.rispec = zeros(goose.current.imgLenMax/2, goose.video.nFrames);
goose.analysis.green = zeros(1, goose.video.nFrames);
goose.analysis.red = zeros(1, goose.video.nFrames);
goose.analysis.marker.nid = [];
goose.analysis.marker.frame = [];
goose.analysis.marker.name = goose.set.markerNameL;

goose.analysis.grayimg_dev = zeros(1, goose.video.nFrames);
goose.analysis.newdetrend = zeros(1, goose.video.nFrames);
goose.analysis.std = zeros(1, goose.video.nFrames);

goose.set.process.framerange = [1 goose.video.nFrames];
goose.current.iFrame = 1;
goose.current.jFrame = 1;
goose.current.nFramesDone = 0;
goose.current.spect_limy = .0001;
goose.current.gausswin = [];
goose.current.rwin = [];
goose.current.radindx = [];
goose.current.fft2Max = 0;
goose.current.detrend_gray = zeros(goose.current.imgLenMax, goose.current.imgLenMax);
goose.current.detrend_smooth = zeros(goose.current.imgLenMax, goose.current.imgLenMax);