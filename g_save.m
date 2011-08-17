function g_save(pathname, filename)
global goose

if nargin < 2
    [filename,pathname] = uiputfile({'*.mat'},'Save goose-project',goose.video.filename(1:end-4));
end

if all(filename == 0) || all(pathname == 0) %Cancel
    return
end

sources.video.filename = goose.video.filename;
sources.video.pathname = goose.video.pathname;
sources.video.fps = goose.video.fps;
sources.video.nFrames = goose.video.nFrames;
sources.audio.filename = goose.audio.filename;
sources.audio.pathname = goose.audio.pathname;
analysis = goose.analysis;
version = goose.version;

save([pathname,filename], 'sources', 'analysis','version');