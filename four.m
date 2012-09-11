function amp = four(img)
% four
%
% Fourier transform analysis of skin pictures
% img pixmap containing the image to analyse

global goose

frame = goose.current.iFrame;
L = goose.set.visual.imgLen;
Lm = goose.current.imgLenMax;
%Marker (green channel)
sel = img(1:50,(end-50):end, 2); %right-upper window, green channel
green = mean(sel(:));
red_im = img((end-50):end,1:50,1);  %left-lower window, red marker
red = mean(red_im(:));

cut = goose.current.cut_img; %see prepare_four
im = img(cut(1):cut(2), cut(3):cut(4), :);   % centered square area
goose.current.img_cut = im;
%Gray IMage
% Todo: Would rgb2gray be better?
gim = mean(im, 3); % add RGB-channels for gray image
goose.current.img_gray = gim;
% Todo: computationally expensive, enable only of needed
goose.analysis.std(frame) = std(gim(:));


% Adaptive Detrend
if goose.set.analysis.detrend_errorlim > 0
    dev = norm(goose.current.detrend_gray - gim,1);  %check for grey image deviation of last detrend update
else  %non-adaptive, no deviation allowed
    dev = goose.set.analysis.detrend_errorlim + 1;
end
goose.analysis.grayimg_dev(frame) = dev;
if dev > goose.set.analysis.detrend_errorlim
%   goose.current.detrend_smooth = imfilter(gim,goose.current.detrendfilt,'replicate');
    goose.current.detrend_smooth = smooth2(gim, goose.set.analysis.detrendfact, 'mean');
    goose.current.detrend_gray = gim; %Reference image for assessment of next need for new detrend
    goose.analysis.newdetrend(frame) = 1;
    goose.analysis.grayimg_dev(frame) = 0;
end

%Detrend
gim = gim - goose.current.detrend_smooth; %Subtraction of low-frequency image
mgim = mean(gim(:)); % Subtraction of mean to correct for inter-individual differences (i.e. normalization)
sdgim = std(gim(:));
if sdgim > 0.01 %necessary line for black pictures not to result in error
    gim = (gim-mgim);
end

% 2D- Fourier transform
% Fourier transformation (fft2), shift frequency 0 to the middle (fftshift)
fgim = abs(fftshift(fft2(gim))).^2 / (Lm/2)^2; 
fgim = conv2(fgim, goose.current.convwin_fft2, 'same'); %Smoothing FFT2 plot by convolution
fgim = fgim .* goose.current.rwin .^ goose.set.analysis.spectbyf;
goose.current.fft2 = fgim;

% Mean radial spectrum
radspec = mean(fgim(goose.current.radindx),2)';

% Get goose-amp
goose.analysis.rispec(:,frame) = radspec;       %radial integrated spectogram
[amp, mxidx] = max(radspec(goose.set.analysis.gooserange(1):goose.set.analysis.gooserange(2))); %max-amplitude in spectogram (gooserange)
x0_amp = mxidx + goose.set.analysis.gooserange(1) - 1; %x-coordinate auf max-amplitude
fitp = polyfit((goose.set.analysis.gooserange(2)+1):Lm/2, radspec((goose.set.analysis.gooserange(2)+1):Lm/2), goose.set.analysis.basepolydegree); %Parameters of polyfit right side of gooserange
goose.analysis.framedone(frame) = 1;

goose.analysis.amp(frame) = amp;
goose.analysis.x0_amp(frame) = x0_amp;
goose.analysis.fitp(:, frame) = fitp;
goose.analysis.green(frame) = green;
goose.analysis.red(frame) = red;  %%

if goose.current.batchmode
    return;
end


% Plots
isdone = find(goose.analysis.framedone);
mpoly = mean(goose.analysis.fitp(:,isdone),2);
meanbase_goosepix = polyval(mpoly, goose.set.analysis.goosepix);
isgoose = goose.analysis.framedone & (goose.analysis.amp > goose.set.analysis.fac(1)*meanbase_goosepix);
nogoose = goose.analysis.framedone & (goose.analysis.amp < goose.set.analysis.fac(2)*meanbase_goosepix);

%  gray image
if goose.set.visual.updategraphics(2)
    axes(goose.gui.ax_gray);
    %rescale to gray values
    gimrgb = zeros(L,L,3);
    gimmax = max(max(gim));
    gimmin = min(min(gim));
    if gimmax == gimmin, gimmax = gimmin + 1; end
    gimscaled = (gim - gimmin)/(gimmax - gimmin);
    gimrgb(:,:,1) = gimscaled;
    gimrgb(:,:,2) = gimscaled;
    gimrgb(:,:,3) = gimscaled;
    goose.current.gray2img = gimrgb;
    image(gimrgb);
    set(gca,'dataaspectratio',[1 1 1],'FontUnits','normalized');
end

%  fft2-image
if goose.set.visual.updategraphics(3)
    axes(goose.gui.ax_fft2);
    cut = floor((goose.set.visual.fft2_lim-1)/2);
    m = (Lm+1)/2;
    prfgim = rfgim(ceil(m-cut):floor(m+cut+1), ceil(m-cut):floor(m+cut+1));
    goose.current.fft2img = prfgim;%/Lm^3; %log(prfgim+1);
    mx = max(goose.current.fft2img(:));
    goose.current.fft2Max = max(goose.current.fft2Max, mx);
    img = imagesc(goose.current.fft2img, [0, goose.current.fft2Max]);  
    set(img,'ButtonDownFcn','g_showval');
    colormap('jet');
    set(gca,'dataaspectratio',[1 1 1],'FontUnits','normalized', 'XTickLabel',get(goose.gui.ax_fft2,'XTick')-(cut+1), 'YTickLabel',get(goose.gui.ax_fft2,'YTick')-(cut+1));
end

%  radial integrated spectogram
if goose.set.visual.updategraphics(4)
    axes(goose.gui.ax_spec);
    %if ~isempty(goose.set.visual.spect_limy)
    %    yl = goose.set.visual.spect_limy;
    %else
        goose.current.spect_limy = max(max(radspec)*1.2, goose.current.spect_limy);
        yl = goose.current.spect_limy;
    %end
    set(gca, 'XLim',[0 goose.set.visual.spect_limx*min(goose.video.Height, goose.video.Width)], 'Ylim',[0, yl]);
    cla;
    if ishandle(goose.current.legend), delete(goose.current.legend); end
    hold on;
    x = 1:Lm/2;

    if goose.set.visual.showspec(1)
        goose.current.plot_radspec = plot(radspec,'-k');
    end

    if goose.set.visual.showspec(2)
        radbase = polyval(fitp, x);
        goose.current.plot_basefit = plot(radbase,'-b');
    end

    if goose.set.visual.showspec(3)
        goose.current.line_amp = line([x0_amp, x0_amp],[0 amp],'Color','r');
        text(x0_amp+1, .02, num2str(x0_amp),'Color','r','Fontsize',8)
    end
    legendtxt = goose.set.visual.showspecL(logical(goose.set.visual.showspec(1:3)));

    if goose.set.visual.showspec(4)
        if any(isgoose)
            mrispec_isgoose = mean(goose.analysis.rispec(:,isgoose),2);
            goose.current.plot_mrispec_ig = plot(x,mrispec_isgoose','b','LineWidth',2);
        else
            goose.current.plot_mrispec_ig = plot(0,0,'b','LineWidth',2); %dummy plot
        end
        legendtxt = [legendtxt,[goose.set.visual.showspecL{4},' (n=',num2str(length(find(isgoose))),')']];
    end

    if goose.set.visual.showspec(5)
        if any(nogoose)
            mrispec_nogoose = mean(goose.analysis.rispec(:,nogoose),2);
            goose.current.plot_mrispec_ng = plot(x,mrispec_nogoose','c','LineWidth',2);
        else
            goose.current.plot_mrispec_ng = plot(0,0,'c','LineWidth',2); %dummy plot
        end
        legendtxt = [legendtxt,[goose.set.visual.showspecL{5},' (n=',num2str(length(find(nogoose))),')']];
    end

    if goose.set.visual.showspec(6)
        goose.current.plot_mbasefit = plot(x,polyval(mpoly, x),'k','LineWidth',2);
        legendtxt = [legendtxt,[goose.set.visual.showspecL{6},' (n=',num2str(length(isdone)),')']];
    end

    if goose.set.visual.showspec(7)
        goose.current.legend = legend(legendtxt);
    end

end
