function prepare_four
global goose

%Preparation of constant data needed in four for faster processing

if any(goose.set.visual.rotate == [0,2])
    l1 = goose.video.Height;
    l2 = goose.video.Width;
else
    l1 = goose.video.Width;
    l2 = goose.video.Height;
end
L = goose.set.visual.imgLen;
Lm = goose.current.imgLenMax;

%Grenzen für quadratischen Bildausschnitt
d1a = round((1+l1)/2 - (L-1)/2);  % Start und
d1e = round((1+l1)/2 + (L-1)/2);  %   Ende der ersten Dimension
d2a = round((1+l2)/2 - (L-1)/2);  % Start und
d2e = round((1+l2)/2 + (L-1)/2);  %   Ende der zweite Dimension
goose.current.cut_img = [d1a, d1e, d2a, d2e];

% Gauss-Window
gws = L*goose.set.analysis.gausswinsize;
g = exp(-(((.5:L)-L/2)/gws).^2);
%g = hannwin(L/2);
goose.current.gausswin = g'*g;

% R-Window
xr = zeros(Lm, Lm);
m = (Lm/2)+1;
for xi = 1:Lm  %mit r multiplizieren
    for yi = 1:Lm
        xr(xi,yi) = norm([xi,yi]-[m,m]);
    end
end
goose.current.rwin = xr;

% Radiales Spektrum Index bilden
rad = 1:(Lm/2);
goose.current.radindx = zeros(length(rad), 180);
for phi = 1:180
    x = round(m + cos(phi/180*pi)*(rad-.5));
    y = round(m + sin(phi/180*pi)*(rad-.5));

    goose.current.radindx(:, phi) = (x-1)*Lm+y;
end

% Convolution Window
g = hannwin(goose.set.analysis.convwinsize);
goose.current.convwin_fft2 = g'*g;

% Detrend Filter
goose.current.detrendfilt = fspecial('disk', goose.set.analysis.detrendfact);


% give FFTW more time to figure out the best strategy
fftw('planner','patient');

function hw = hannwin(winsize)

hw = .5*(1-cos(2*pi*(1:2*winsize+1)/(2*winsize+2)));
hw = hw ./ sum(hw(:));