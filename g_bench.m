function msPerFrame = g_bench(videofile,profiler)
%G_BENCH Calculates time per frame

tic;
Gooselab;
fprintf('Startup time: %2fs\n',toc);

[p,n,e] = fileparts(videofile);

tic;
g_open(1,[n e],p);
fprintf('Time to load video file: %2fs\n',toc);

% Analyze the current frame to preallocate some variables and let the FFTW
% library determine the best strategy.
g_analyze(1);

if nargin>1 && profiler
    profile('on');
end
tic;
g_analyze(3);

profile('viewer');
t = toc;
global goose;
msPerFrame = 1000*t/goose.video.nFrames;
fprintf('Time spent analyzing %d frames: %2.2fs (%2.1f ms/frame, %2.2f fps)\n',...
    goose.video.nFrames,t,msPerFrame,1000/msPerFrame);
close('all');
end

