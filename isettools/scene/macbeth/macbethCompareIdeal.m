function [embRGB,mRGB,pSize] = macbethCompareIdeal(mRGB,pSize,illType)
%Create an image of an ideal MCC (color temperature ...) with data embedded
% 
%   [embRGB,mRGB,pSize] = macbethCompareIdeal(mRGB,pSize,illType)
%
% mRGB:    Macbeth RGB values of the data in the vcimageWindow
% pSize:   Patch size
% illType: Illuminant name (e.g., 'd65'). See illuminantRead contains all
%          the options
%
% TODO: Need to be able to set illType parameter for color temperature
%
% Example
%   [embRGB,mRGB,pSize] = macbethCompareIdeal; 
%
%   macbethCompareIdeal(mRGB,pSize,4000);
%   macbethCompareIdeal(mRGB,pSize,6000);
%   macbethCompareIdeal(mRGB,pSize,'d65');
%
% See also:  macbethIdealColor
%
% Copyright ImagEval Consultants, LLC, 2003.

%% Arguments
vci = vcGetObject('vci');

% If the mRGB or pSize not defined, we need to do some processing.
if ieNotDefined('mRGB') || ieNotDefined('pSize')
    % Now, we get the RGB values for the image data displayed in the
    % image processing window.  We treat this as lRGB (not sRGB) data.
    [mRGB, macbethLocs, pSize]= macbethSelect(vci);
    mRGB = reshape(mRGB,4,6,3);
    mRGB = mRGB/max(mRGB(:));
end
if ieNotDefined('illType'), illType = 'd65'; end

%% Calculate the lRGB values under this illuminant.
ideal  = macbethIdealColor(illType,'lrgb');
idealLRGB = XW2RGBFormat(ideal,4,6);

%% Build an image that contains bigger patches of ideal values 
% Patch size like the original data) with smaller inserts for the ideal.  
fullIdealRGB = imageIncreaseImageRGBSize(idealLRGB,pSize);
embRGB       = fullIdealRGB;   % imagesc(embRGB)

w = pSize + round(-pSize/3:0);
% n = length(w);
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

%% Display in graph window
figNum = vcNewGraphWin([],'wide');
str = sprintf('%s: MCC %s',imageGet(vci,'name'),illType);
set(figNum,'name',str);
set(figNum,'Color',[1 1 1]*.7);

subplot(1,2,1), imagesc(mRGB.^0.6), 
axis image; axis off; title('Data')
subplot(1,2,2), imagesc(embRGB.^0.6), 
axis image; axis off; title('Data embedded in ideal')

end