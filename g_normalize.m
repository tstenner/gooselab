function g_normalize
global goose

isdone = find(goose.analysis.framedone);
mpoly = mean(goose.analysis.fitp(:, isdone), 2);
meanbase_goosepix = polyval(mpoly, goose.set.analysis.goosepix);
isgoose = goose.analysis.framedone & (goose.analysis.amp > goose.set.analysis.fac(1)*meanbase_goosepix);
nogoose = goose.analysis.framedone & (goose.analysis.amp < goose.set.analysis.fac(2)*meanbase_goosepix);
amp_norm = zeros(size(goose.analysis.amp));

for iFrame = isdone

    radspect = goose.analysis.rispec(:,iFrame);

    switch goose.set.analysis.spectpos
        case 1, pos = round(goose.set.analysis.goosepix);
        case 2, pos = round(goose.analysis.x0_amp(iFrame));
        case 3, pos = round(mean(goose.analysis.x0_amp(isdone)));    %mean peak loc
        case 4, pos = round(mean(goose.analysis.x0_amp(isgoose)));   %mean peak loc isgoose
        case 5, pos = round(mean(goose.analysis.x0_amp(nogoose)));   %mean peak loc nogoose
    end

    switch goose.set.analysis.basetype
        case 1, base = 1;
        case 2, base = goose.analysis.fitp(:, iFrame);
        case 3, base = mean(goose.analysis.fitp(:, isdone), 2);
    end

    amp_norm(iFrame) = radspect(pos) / polyval(base, pos);

end
goose.analysis.amp_norm = amp_norm;

if ~goose.current.batchmode
    set(goose.current.plot_gamp,'XData',isdone, 'YData',amp_norm(isdone));
    ylim = [0, max(amp_norm*1.2)];
    set(goose.gui.ax_gamp,'YLim',ylim);
    set(goose.gui.line_pos_ind_gamp,'YData',ylim)
end

%g_plotmarker;