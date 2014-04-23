function vd = vDisplayScale(vd,sFactor)
%vDisplayScale -- Scale the pixel size and psf of a display
%
%   vDisp = vDisplayScale(vDisp,sFactor)
%
% This routine adjusts the pixel size in a virtual display.  The pixels are
% adjusted to occupy a new size, sFactor.  Thus, if the original pixel is
% 1x1, the new pixel will be sFactor x sFactor.  The dot density increases
% when  sFactor < 1 and density decreases when sFactor > 1
%
% The pixel point spread functions are adjusted to be the same relative
% intensity but the function spreads over an adjusted (sFactor*sFactor)
% surface area. This is accomplished by resetting the values of the psf
% support, without changing the psf at all.
%
% Example:
%   % Scale the current virtual display
%   vd = displayGet(ctGetObject('display'),'vDisplay');
%   sFactor = 1/2; 
%   halfVD = vDisplayScale(vd,sFactor);
%   
%   % Check that the sample positions have change
%   dixel = vDisplayGet(vd,'dixel'); psf = dixelGet(dixel,'psf');
%   samp = psfGet(psf{1},'samplePositions');
%
%   dixel = displayGet(halfVD,'dixel'); psf = dixelGet(dixel,'psf');
%   samp = psfGet(psf{1},'samplePositions');
%
%   % Check that the rendered image of a single pixel has changed
%   tst = vDisplayCompute(vd,'singlepixel');  figure(1); imagescRGB(tst)
%   tst2 = vDisplayCompute(halfVD,'singlepixel');  figure(1); imagescRGB(tst2)
%

if ieNotDefined('vd'), error('vDisplay required'); end
if ieNotDefined('sFactor'), error('Scale factor required'); end

if sFactor == 1, return; end

% Find the current pixel size
pSize = vDisplayGet(vd,'pixelSize');

% Scale the pixel size parameter; this also scales the sub-pixel point
% spread functions
vd = vDisplaySet(vd,'pixelSizeInMM',pSize*sFactor);

return;

