function g_spectrum
global goose

if length(find(goose.analysis.framedone)) < goose.video.nFrames
    warndlg('Spectrum will only be calculated after all frames have been analyzed','Warning')
    return;
end
    
n = goose.video.nFrames;
fps = goose.video.fps;

x = goose.analysis.amp;
hw = hannwin(n);
hw = hw * n;
%x = x .* hw; %hanning window to avoid leakage

%FFT
Y = fft(x);
Pyy = Y.* conj(Y) / (n/2)^2;
Pyy = Pyy(1:floor(n/2)); %2nd half is redundant
f = fps*(0:floor(n/2)-1)/n; %meaningful frequency scale
%scale from hz to bpm
bpm = f * 60; 

%select frequency range
 f_min = .5;
 f_max = 3;
 idx = find(f >= f_min & f <= f_max);
 fr = f(idx);
 Pyyr = Pyy(idx);
 bpmr = bpm(idx);

%get maximum
[mx, idx] = max(Pyyr);
max_bpm = bpmr(idx);


%Plot FFT
if 1
    figure('Menubar','None','Name',['FFT Spectrum for Goose values'],'Numbertitle','Off');
    ax = axes;
    plot(bpm, Pyy)
    text(max_bpm+3, mx, ['BPM = ',sprintf('%4.2f', max_bpm),sprintf(' (%4.2fHz)', fr(idx))]);
    set(gca,'YLim',[0, mx*1.3],'XLim',[20, 220]);
end




function hw = hannwin(winsize)

hw = .5*(1-cos(2*pi*(1:winsize)/(winsize+1)));
hw = hw ./ sum(hw(:));