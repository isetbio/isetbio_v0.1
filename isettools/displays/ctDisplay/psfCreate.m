function psf = psfCreate(dixelType,varargin)
%Create a point spread function structure for a sub-pixel
%
%   psf = psfCreate(dixelType,varargin)
%
% Each sub-dixel has a psf.  We usually store all of the point spread
% functions in a psf cell array. 
%
% This routine is called by psfGroupCreate, which makes the complete group
% of psfs at different positions, and with different primaries.
%
% See also:  psfGroupCreate, psfSet, psfGet, s_CustomPixelData
%
% Models:
%   Gaussian: psfGaussian = psfCreate('gaussiancrt');
%   Custom:   psfCreate('custom',fileName);
%   LCD:      psfR = psfCreate('rectangular');
%             psfR = psfCreate('rectangular',254,5,-1/3,0,'v');
%
%
%Examples:
%  pixelPSF{1} = psfCreate('custom','red-Dell-LCD');
%  pixelPSF{2} = psfCreate('custom','green-Dell-LCD');
%  pixelPSF{3} = psfCreate('custom','blue-Dell-LCD');
%
%  pixelPSF{1} = psfCreate('default');
%
%  pixelPSF{1} = psfCreate('custom',samp,psfImage);
%
% (c) Stanford, PDCSOFT, Wandell, 2006

if ieNotDefined('dixelType'), dixelType = 'gaussianCRT'; end

% Height, width and dSpace (sample spacing) are in units of microns
psf.type = 'psf';
if ~isempty(varargin), dixelWidth = varargin{1};    else dixelWidth = 254; end
if length(varargin) > 1, dixelHeight = varargin{2}; else dixelHeight = 254; end
if length(varargin) > 2, dSpace = varargin{3};      else dSpace = 10; end
if length(varargin) > 3, xC = varargin{4};          else xC = 0; end
if length(varargin) > 4, yC = varargin{5};          else yC = 0; end

switch lower(dixelType)
    case {'default','gaussian','gaussiancrt'}
        if length(varargin) > 5, sigma = varargin{6};       else sigma = dixelWidth/5; end
        psf = psfGaussian(psf, dixelWidth, dSpace, xC, yC, sigma);
        % samp = psf.sCustomData.samp; 
        % figure; mesh(samp,samp,psf.sCustomData.aRawData)
        
        %     case {'OLDrectangular'}
        %         % Set up rectangular psf shape parameters ...
        %         if length(varargin) > 5, ori = varargin{6}; else ori = 'h'; end
        %         if length(varargin) > 6, subDixelHalfWidth  = varargin{7}; else subDixelHalfWidth  = 1/6; end
        %         if length(varargin) > 7, subDixelHalfHeight = varargin{8}; else subDixelHalfHeight = 1/2; end
        %
        %         psf = OLDpsfRectangular(psf,dixelWidth,dSpace,xC,yC,ori,subDixelHalfWidth,subDixelHalfHeight);
        %         % figure; samp = psf.sCustomData.samp; mesh(samp,samp,psf.sCustomData.aRawData)

    case {'rectangular'}
        % Set up rectangular psf shape parameters ...
        if length(varargin) > 5, ori = varargin{6}; else ori = 'h'; end
        if length(varargin) > 6, subDixelHalfWidth  = varargin{7}; else subDixelHalfWidth  = 1/6; end
        if length(varargin) > 7, subDixelHalfHeight = varargin{8}; else subDixelHalfHeight = 1/2; end

        % sd means sub-dixel - they appear to be in relative coordinates,
        % while the dixelWidth/Height are in microns.  Is that right?
        psf = psfRectangular(psf,dixelWidth,dixelHeight,dSpace,xC,yC,subDixelHalfWidth,subDixelHalfHeight);

    case {'elliptical'}
        psf = psfElliptical(psf);
    case {'custom'}
        if length(varargin) < 3, error('samp,psfImage required'); end 
        psf = psfCustom(psf,varargin{1},varargin{3});
    otherwise
        error('Unknown sub-pixel psf name');
end

% psf = ieCreateSampledPSF(psf);

return;

%----------------------------
function psf = psfGaussian(psf,dixelWidth,dSpace,xC,yC,sigma)
% Used to simulate CRT pixels
%
% The Gaussian is circularly symmetric.  Perhaps we should absorbe the
% elliptical case into this one.
%

% These should all be psfSet() calls
psf = psfSet(psf,'name','Gaussian');

% MTODO: Move out - shouldn't be set within each psfGaussian -  instead
% should be gotten with psfGet

support = 3*dixelWidth;     % This allows the PSF to expand outside the dixel
samp = 0:dSpace:support;    % dSpace has units of microns
samp = samp - mean(samp);   % Centers the samples on the dixel
psf = psfSet(psf,'psfsamples',samp);

% Create the pixel point spread
[X, Y] = meshgrid(samp,samp);
psfImage = (1/(2*pi)*exp(-0.5*(((X-xC)/sigma).^2 + ((Y-yC)/sigma).^2)));
psf = psfSet(psf,'psfImage',psfImage);

return


%---------------
function psf = psfRectangular(psf, dixelWidth, dixelHeight, dSpace, xC, yC, halfWidth, halfHeight)
%
% Used to simulate LCD pixels
%
% On Entry:
%   psf          = PSF struct with some variables initialised
%   dixelWidth   = Width of the repeating block. Units are mm
%   dixelHeight  = Height of the repeating block. Units are mm
%   dSpace       = Sample spacing of psf representation. Units are mm.
%   xC           = X location to center PSF on (within whole dixel)
%   yC           = Y location to center PSF on (Within whole dixel)
%   halfWidth    = Half width of PSF (within coordinate system of dixel)
%   halfHeight   = Half height of PSF (within coordinate system of dixel)
%
% On Return:
%   psf          = Point spread function, where PSF is located within a
%                  pixel (this implicitly means PSF + location are
%                  integrated - I don't like that, they should be separate
%                  but maintaining it for legacy support).
%
% NOTE: Axis X & Y ranges from -1 to 1
%
% MTODO: Break out PSF so no longer stored at a specific position in pixel
%
% MNOTE: Replacement written by Mike Bennett. Old version was buggy and
%        unable to consistently and correctly handle NxM sub-pixel layouts
%        (changing the position a PSF was located at ALSO changed the PSFs
%        shape!!!).
%

% These are the sub-dixel half values for the rectangle.
if ieNotDefined('halfWidth'),  halfWidth  = 1/6; end
if ieNotDefined('halfHeight'), halfHeight = 1/2; end

% Not sure why these were scaled.  If we need them in millimeters, then we
% can't do it this way.  To check.  (BW).
%
% dixelWidth = dixelWidth * ieUnitScaleFactor('mm');
% dixelHeight = dixelHeight * ieUnitScaleFactor('mm');

psf = psfSet(psf,'name','Rectangular');

% Row sample positions in um, 0 at center
sampRow = 0:dSpace:dixelWidth;
sampRow = sampRow - mean(sampRow);
if length(sampRow) < 2
    error('Bad units on sample spacing and dixel size')
end
psf = psfSet(psf, 'psfsamplesrow', sampRow);

numAxisUnitsRow = length(sampRow);

% Figure out granularity for height
sampCol = 0:dSpace:dixelHeight;
sampCol = sampCol - mean(sampCol);
psf = psfSet(psf, 'psfsamplescol', sampCol);

numAxisUnitsCol = length(sampCol);

% Adjust coordinate so it ranges between 0 and 1, reduces number of later
% calcs when not dealing with postive & negative corrdinate system.
% Assuming initial range of inputs is along -1 to +1 axis.
normXc = (xC + 1) / 2;
normYc = (yC + 1) / 2;

psfQuantWidth = (2 * halfWidth) * numAxisUnitsRow;
psfQuantHeight = (2 * halfHeight) * numAxisUnitsCol;

% What is the location within the pixel we should draw the PSF at (location in terms of quantized space)?
centerPsfX = normXc * numAxisUnitsRow;
centerPsfY = normYc * numAxisUnitsCol;

leftBoundOfPsf = centerPsfX - (psfQuantWidth / 2);
topBoundOfPsf = centerPsfY + (psfQuantHeight / 2);

% Lets check for rounding errors with related out of bounds errors (due to
% quantization and calcs). MTODO: Manage rounding errors better and
% quantization.
bottomBoundOfPsf = topBoundOfPsf - psfQuantHeight;
rightBoundOfPsf = leftBoundOfPsf + psfQuantWidth;

topBoundOfPsf = round(topBoundOfPsf);
bottomBoundOfPsf = round(bottomBoundOfPsf);
leftBoundOfPsf = round(leftBoundOfPsf);
rightBoundOfPsf = round(rightBoundOfPsf);

if bottomBoundOfPsf <= 0
    bottomBoundOfPsf = 1;
end

if leftBoundOfPsf <= 0
    leftBoundOfPsf = 1;
end

if topBoundOfPsf > numAxisUnitsCol
    topBoundOfPsf = numAxisUnitsCol;
end

if rightBoundOfPsf > numAxisUnitsRow
    rightBoundOfPsf = numAxisUnitsRow;
end

% Create our pre-Gaussian PSF
% MIKE TEST
[X, Y] = meshgrid(sampRow, sampCol);
%[X, Y] = meshgrid(sampCol, sampRow);

psfImage = zeros(size(X));

psfImage(bottomBoundOfPsf:topBoundOfPsf, leftBoundOfPsf:rightBoundOfPsf) = 1;

g = fspecial('gaussian');
psfImage = conv2(psfImage, g, 'same');
% mesh(psfImage)

psf = psfSet(psf, 'psfImage', psfImage);

return


%---------------
% MTODO: Remove, no longer used
function psf = OLDpsfRectangular(psf,dixelWidth,dSpace,xC,yC,ori,halfWidth,halfHeight)
%
% Used to simulate LCD pixels
%

% Default is right for an RGB LCD style
% 1/8 is right for an RGBW style
if ieNotDefined('halfWidth'),  halfWidth  = 1/6; end
if ieNotDefined('halfHeight'), halfHeight = 1/2; end

% Pixels are square
dixelHeight = dixelWidth;

% These should all be psfSet() calls
psf = psfSet(psf,'name','Rectangular');

samp = 0:dSpace:dixelWidth;
samp = samp - mean(samp);
psf = psfSet(psf,'psfsamples',samp);

% Create the rectangular pixel point spread
[X, Y] = meshgrid(samp,samp);
psfImage = zeros(size(X));
if strcmp(ori,'v'), 
    on = (abs(X - xC*dixelWidth)  < halfWidth*dixelWidth) & ...
         (abs(Y - yC*dixelHeight) < halfHeight*dixelHeight);
    psfImage(on) = 1;
elseif strcmp(ori,'h'),
    psfImage(abs(Y - yC*dixelWidth) < halfWidth*dixelWidth) = 1;
end

%
g = fspecial('gaussian');
psfImage = conv2(psfImage,g,'same');

psf = psfSet(psf,'psfImage',psfImage);
% figure; mesh(X,Y,psfImage)
return;

%--------------------------
function psf = psfCustom(psf,samp,psfImage)

psf = psfSet(psf,'name','Custom');

% samp is the position (in microns) along each axis of the pixel
% coordinates. We assume that the grid of the image is square because
% displays have to have square pixels or else everything would look
% distorted. Also, the origin should be at the center.  So, we always make
% sure that the mean(samp) is zero by this subtraction.
samp = samp - mean(samp);

% 
psf = psfSet(psf,'psfsamples',samp);

% Create the pixel point spread
psf = psfSet(psf,'psfImage',psfImage);

return;


%----------------
function psf = psfElliptical(psf)
%Note this is half box size, ie. from 0 to fFiniteSupportX.
%In terms of the pixel size. So '1/6' means '0.4/6' mm
%physically.

disp('Elliptical not really checked')

psf.strFiniteSupportX = '1/6';
psf.strFiniteSupportY = '1/2';

% Again, just made up strings that aren't used.  And the parameters of the
% ellipse are fixed.  This is not good.  See comments for Gaussian above.
% -- BW
psf.strSigmaX = '0';
psf.strSigmaY = '0';
psf.strPSFFunction='((x.^2/(1/6)^2+y.^2/(1/2)^2)<1)';

return;


