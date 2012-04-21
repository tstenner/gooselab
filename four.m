function amp = four(img)
global goose

% four
%
% Fourier transform analysis of skin pictures
% img             pixmap

frame = goose.current.iFrame;
L = goose.set.visual.imgLen;
Lm = goose.current.imgLenMax;
%Marker (Gr�nwert)
sel = img(1:50,(end-50):end, 2); %right-upper window, green channel
green = mean(sel(:));
red_im = img((end-50):end,1:50,1);  %left-lower window, red marker
red = mean(red_im(:));
% Quadratischer Ausschnitt
cut = goose.current.cut_img; %von prepare_four
im = img(cut(1):cut(2), cut(3):cut(4), :);   % quadratischen zentrierten Bildausschnitt bilden
goose.current.img_cut = im;
%Graubbild
gim = mean(im, 3);                           % und RGB-Kan�le addieren f�r Graubild
%gim = mean(im(:,:,[1,3]), 3);  %Grau = Rot+Blau
goose.current.img_gray = gim;
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

% if ~any(goose.current.detrend_smooth)
% 
%     acc = round(goose.video.nFrames/(goose.set.analysis.detrend_errorlim+1))+1;
%     frameL = acc:acc:goose.video.nFrames;
%     for i = 1:length(frameL)
%         iFrame = frameL(i);
%         pixmap = dxAviReadMex(goose.video.avi_hdl, iFrame); %load pic
%         img_detr = reshape(pixmap/255, [goose.video.Height, goose.video.Width, 3]);
%         im_detr = img_detr(cut(1):cut(2), cut(3):cut(4), :);   % cut
%         gim_detr(:,:,i) = mean(im_detr,3); %#ok<AGROW> %gray-img
%     end
%     gim_detr = mean(gim_detr,3);
%     goose.current.detrend_smooth = smooth2(gim_detr, goose.set.analysis.detrendfact, 'mean');
%     goose.current.detrend_gray = gim;
% 
% end


%Detrend
gim = gim - goose.current.detrend_smooth;                   %Subtraction of low-frequency image
mgim = mean(mean(gim));             % Subtraction of mean to correct for inter-individual differences (i.e. normalization)
sdgim = std(gim(:));
 if sdgim > 0.01                     %necessary line for black pictures not to result in error
     gim = (gim-mgim);%./sdgim;%; %/15
 end

% Reduce leakage: multiply with 2D-Gauss
%gim = gim .* goose.current.gausswin;

% 2D- Fourier transform
fgim = fft2(gim,Lm,Lm);                 % Fouriertransformation
fgim = fftshift(fgim);              % Shift: Frequenz 0 in die Mitte
fgim = abs(fgim) .^2 / (Lm/2)^2;
fgim = conv2(fgim, goose.current.convwin_fft2, 'same'); %Smoothing FFT2 plot by convolution
rfgim = fgim .* goose.current.rwin .^ goose.set.analysis.spectbyf; %= 2 (fixed)
goose.current.fft2 = rfgim;

% Mean radial spectrum
radspec = mean(rfgim(goose.current.radindx),2)';
%radspec = radspec/Lm^2;  %???

% Get goose-amp
goose.analysis.rispec(:,frame)= radspec;       %radial integrated spectogram
[amp, mxidx] = max(radspec(goose.set.analysis.gooserange(1):goose.set.analysis.gooserange(2))); %max-amplitude in spectogram (gooserange)
%amp = sum(radspec(goose.set.analysis.gooserange(1):goose.set.analysis.gooserange(2)));  %frequency range
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
    %rfgim = fgim .* goose.current.rwin .^ goose.set.visual.fft2_radalpha; % = 2 (default visual setting)
    prfgim = rfgim(ceil(m-cut):floor(m+cut+1), ceil(m-cut):floor(m+cut+1));
    goose.current.fft2img = prfgim;%/Lm^3; %log(prfgim+1);
    mx = max(goose.current.fft2img(:));
    %mx = max(mx, 2);
    goose.current.fft2Max = max(goose.current.fft2Max, mx);
    %set(goose.gui.txt_fft2Info, 'String', ['max: ',num2str(mx,'%4.2f'),' (overall: ',num2str(goose.current.fft2Max,'%4.2f'),')']);
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