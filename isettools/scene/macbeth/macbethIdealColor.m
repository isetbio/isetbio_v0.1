function target  = macbethIdealColor(illuminant,colorSpace)
%Calculate MCC values for given an illuminant in a color space
%
%   target = macbethIdealColor(illuminant,colorSpace)
%
% Possible illuminants are listed in illuminantRead
%
% Possible color spaces are
%    'LAB'
%    'XYZ'
%    'lRGB'          linear RGB (from sRGB)
%    'sRGB'          display sRGB
%    'Stockman'      (not yet)
%    'SmithPokorny'  (not yet)
%
% Example:
%    macbethXYZ = macbethIdealColor('d65','xyz');
%    xy = chromaticity(macbethXYZ);
%    plot(xy(:,1), xy(:,2),'o'); hold on; plotSpectrumLocus
%
%    lRGB = macbethIdealColor('d65','lrgb');
%
%
%   lightParameters.name = 'blackbody';
%   lightParameters.temperature = 3000;
%   lightParameters.spectrum.wave = 400:10:700;
%   lightParameters.luminance = 100;
%   lRGB = macbethIdealColor(lightParameters,'lrgb');
%
%   macbethLAB = macbethIdealColor('tungsten','lab');
%   plot3(macbethLAB(:,1),macbethLAB(:,2),macbethLAB(:,3),'o')
%
% Copyright ImagEval Consultants, LLC, 2005.


if ieNotDefined('illuminant'), illuminant = 'D65'; end
if ieNotDefined('colorSpace'), colorSpace = 'XYZ'; end
if checkfields(illuminant,'spectrum','wave'), wave = illuminant.spectrum.wave;
else                           wave = 400:10:700;
end

patchList = 1:24;
macbethChart = macbethReadReflectance(wave,patchList);

% Read illumination.  Could be a string or a structure describing a
% blackbody illuminant.
if ischar(illuminant), illEnergy = illuminantRead([],illuminant);
else                   illEnergy = illuminantRead(illuminant);
end

colorSignal = diag(illEnergy)*macbethChart;

switch lower(colorSpace)
    case 'xyz'
        % Sets the max Y value to 100 cd/m2
        macbethXYZ = ieXYZFromEnergy(colorSignal',wave);
        target = 100*(macbethXYZ/max(macbethXYZ(:,2)));
    case 'lab'
        macbethXYZ = ieXYZFromEnergy(colorSignal',wave);
        macbethXYZ = 100*(macbethXYZ/max(macbethXYZ(:,2)));
        whiteXYZ = macbethXYZ(1,:);
        target =  xyz2lab(macbethXYZ,whiteXYZ);
    case 'lrgb'
        % Linear RGB values from srgb space; these don't include gamma
        macbethXYZ = macbethIdealColor(illuminant,'xyz');
        % For xyz2srgb, the XYZ is scaled so that max is around
        % 1. We want the linear RGB to really correspond to the Y values we
        % send in.  So, we must scale back.
        macbethXYZ = macbethXYZ/100;  % Set max to 1 - max Y is 100.
        [idealSRGB,idealLRGB] = xyz2srgb(XW2RGBFormat(macbethXYZ,1,24));
        idealLRGB = RGB2XWFormat(idealLRGB);
        % Not sure why we clip at 1.  0 makes sense.
        target = ieClip(idealLRGB,0,1);
    case 'srgb'
        macbethXYZ = macbethIdealColor(illuminant,'xyz');
        idealSRGB = xyz2srgb(XW2RGBFormat(macbethXYZ,1,24));
        target = RGB2XWFormat(idealSRGB);
    case 'stockman'
        disp('Not yet implemented')
    case 'smithpokorny'
        disp('Not yet implemented')
    otherwise
        error('Unknown color space.')
end

return;
