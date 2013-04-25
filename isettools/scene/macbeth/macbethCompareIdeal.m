function [embRGB,mRGB,pSize] = macbethCompareIdeal(mRGB,pSize,illType)
%Create an image of an ideal MCC (color temperature ...) with data embedded
% 
%   [embRGB,mRGB,pSize] = macbethCompareIdeal(mRGB,pSize,illType)
%
% Need parameter for color temperature
%
% Example
%   [embRGB,mRGB,pSize] = macbethCompareIdeal; 
%
%   macbethCompareIdeal(mRGB,pSize,4000);
%   macbethCompareIdeal(mRGB,pSize,6000);
%   macbethCompareIdeal(mRGB,pSize,'d65');
%
% Copyright ImagEval Consultants, LLC, 2003.

vci = vcGetObject('vci');

if ieNotDefined('mRGB') || ieNotDefined('pSize')
    % Now, we get the RGB values for the image data displayed in the
    % image processing window.  We treat this as lRGB (not sRGB) data.
    [mRGB, macbethLocs, pSize]= macbethSelect(vci);
    mRGB = reshape(mRGB,4,6,3);
    mRGB = mRGB/max(mRGB(:));
    mRGB = imageFlip(mRGB,'updown');
end
if ieNotDefined('illType'), illType = 'd65'; end

% Calculate the lRGB values under this illuminant.
ideal  = macbethIdealColor(illType,'lrgb');

% Reshape to the form of the chart
idealLRGB = zeros(4,6,3);
for ii= 1:3
    tmp = ideal(:,ii); 
    idealLRGB(:,:,ii) = flipud(reshape(tmp,4,6));
end

% Old Code - delete some day.
% % Create the linear RGB (lRGB) values for the ideal MCC under D65.
% wave = 400:10:700;
% macbethChart = macbethReadReflectance(wave);
% 
% if ischar(illType)
%     illEnergy = illuminantRead([],illType);
% elseif isnumeric(illType)
%     % Read illumination
%     lightParameters.name = 'blackbody';
%     lightParameters.temperature = 6500;
%     lightParameters.spectrum.wave = wave;
%     % lightParameters.spectrum.binwidth = wave(2)-wave(1);
%     lightParameters.luminance = 100;        %cd/m2
%     illEnergy = illuminantRead(lightParameters);
%     illType = num2str(illType);
% end
% 
% % Create color signal
% colorSignal = diag(illEnergy)*macbethChart;
% 
% % Compute CIE XYZ
% macbethXYZ = ieXYZFromEnergy(colorSignal',wave);
% ideal = (macbethXYZ/max(macbethXYZ(:,2)));  % Previously scaled by 100
% ideal = reshape(ideal,4,6,3);
% ideal = imageFlip(ideal,'updown');
% 
% % Convert to display lRGB and sRGB
% [idealSRGB,idealLRGB] = xyz2srgb(ideal);
% idealLRGB = ieClip(idealLRGB,0,1);

% - End of replacement by macbethIdealColor

% Build an image that contains bigger patches of ideal values (patch size
% like the original data) with smaller inserts for the ideal.  
fullIdealRGB = imageIncreaseImageRGBSize(idealLRGB,pSize);
embRGB = fullIdealRGB;   % imagesc(embRGB)
w = pSize + round([-pSize/3:0]);
n = length(w);
for ii=1:4
    l1 = (ii-1)*pSize + w;
    for jj=1:6
        l2 = (jj-1)*pSize + w;
        rgb = squeeze(mRGB(ii,jj,:));
        for kk=1:3
            embRGB(l1,l2,kk) = rgb(kk);
        end
    end
end

% Display in graph window
figNum = vcNewGraphWin;
str = sprintf('%s: MCC %s',imageGet(vci,'name'),illType);
set(figNum,'name',str);
set(figNum,'Color',[1 1 1]*.7);

subplot(1,2,1), imagesc(mRGB.^0.6), 
axis image; axis off; title('Data')
subplot(1,2,2), imagesc(embRGB.^0.6), 
axis image; axis off; title('Data embedded in ideal')

return;