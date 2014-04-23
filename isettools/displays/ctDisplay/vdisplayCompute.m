function [outImage, support] = vdisplayCompute(vd, computationType, waitBarOn, varPos)
% Render image data from input image and display model parameters
%
%  [outImage, support] = ...
%    vDisplayCompute(vDisplay, [computationType='inputimage'], ...
%        [waitBarOn=1], [varPos])
%
% This routine converts an  input image that is (row,col,p) where p is the
% number of sub-pixels in the virtual display, vd, into a higher
% resolution format.  
%
% Calculation notes:  We define a sub-pixel as a combination of primary SPD
% and position within the pixel.  Hence, it is possible to have two sub
% pixels with the same SPD that are located at different positions.  It
% also possible to have two pixels at the same position, but with different
% SPDs.  
%
% Take some time and think about this: In the second case only one of the
% sub-pixels can be present within a pixel.  Hence, different pixels can
% have slightly different configurations.  This occurs for CRTs, where the
% spatial position of the RGB phosphors changes from pixel to pixel.  In
% that case, the fundamental repeating block of the display is not the
% pixel, but a block of pixels. 
%
% The high resolution can be rendered into an RGB image that  appears in
% the display main window during the refresh operation.
%
% The variable support is the spatial support of the image in units of
% microns. 
%
% The display model principles are described in the header to
% vDisplayCreate. 
%
% The input image should be an m x n x p image in the range [0,1], where m
% and n is the number of rows and p is the number of sub-pixel types.
%
% The outImage ( k*m x k*n x p) is returned.  The parameter k is the number
% of spatial samples per pixel.  This must be an integer and is specified
% in the vd field osampling.
%
% There are two types of computations.
%
%  inputImage:   Render the input image data.  (Default)
%  singlePixel:  Show a single pixel image at max resolution.
%
% All coordinates have [0, 0] on the left-top corner, the same as screen
% coordinates.
%
% All coordinate or size vectors (x, y) have the first element to be the
% x-axis, the second element to be the y-axis. This means (column, row).
%
% The output is in linear space (proportional to intensity units), not
% gamma corrected for your display. 
%
% Position variance:  Not yet implemented.
%
% It will be possible to simulate a display with some position variance.
% This is handled by the varPos input argument.  This is a matrix of size
% (row,col,subPixel,2) that defines the shift of each subpixel (in microns)
% with respect to its perfect position. If varPos is empty or undefined, no
% sub-pixel shifting is applied.  If this matrix is filled, each sub-pixel
% is rendered at a shifted location defined by the entries of varPos.  The
% first dimension is the row shift (y) and the second is the column shift
% (x).  (N.B.  Must figure out what happens when we have 6 sub-pixels, not
% 3.  Sigh.)
%
% We plan to implement amplitude variance.
%
% About units:  The spectrophotometer measures a spectral power
% distribtuion (SPD) in units of quanta/s/nm/m2.  The returned value (m2)
% makes sense if we are characterizing light emitted from a pixel or more.
%
% When we represent the SPD, the subpixel surface is smaller surface area
% than the average pixel, so  to calculate the total number of photons
% emitted by samples within a subpixel, we must calculate the (SPD *
% subpixel area) appropriately.  Here is the problem:
%  
% When we measure with the spectrophotometer, we collect light averaged
% over many pixels.  But within a pixel, for a particular primary, only a
% fraction of the area is illuminated. Say, for the R primary the actual
% illuminated area is about 1/3 of the screen.  The photometer doesn't know
% this when it returns a measurement in q/s/nm/m2.  So if we are to
% describe the light at  subpixel resolution, we have to correct the
% measurements from the photometer for this factor (about 3 for RGB or 1/P
% for a P primary display). The SPD at over the subpixel sample positions
% is about P x greater than the calibrated value.  When we average across
% the whole pixel, the SPD should equal the calibrated value.
%
% At present, the numbers we are putting in the sampled subpixels are
% pretty much unconnected to the physical area or the true measurements.
% We have to get them to be closer to physical units.
%
%
% Example
%   vd = displayGet(ctGetObject('Display'),'vdisplay');
%   outImage = vdisplayCompute(vd);
%
%   [outImage,supp] = vdisplayCompute(vd,'inputimage',0);
%   mesh(supp{1},supp{2},outImage(:,:,1));
%
%   [outImage,supp] = vdisplayCompute(vd,'inputimage',0,30);
%   figure(1); mesh(supp{1},supp{2},outImage(:,:,2));
%
% VarPos defines the shift in the position of each subpixel. The subpixels
% (spPos) are (row,col, primary). We create a new array that is
% (row,col,primary,shiftSize) the shiftSize entries (1,2) are row and col
% shift (yShift and xShift)
%
% The units of VarPos
%  nSubPixels = displayGet(vd,'nSubPixels');
%  row = displayGet(vd,'inputRow');
%  col = displayGet(vd,'inputCol');
%  varPos(:,:,:,1) = randn([row,col,nSubPixels])*15;
%  varPos(:,:,:,2) = randn([row,col,nSubPixels])*15;
%  outImage = vDisplayCompute(vd, 'inputImage',0, [], varPos);
%  figure; imagesc(outImage)
%
% ---- More comments to be edited ----
%
% We find all the pixels that contain each sub-pixel (spPos).  The spPos
% routine returns a 0 or 1 according to whether that particular sub-pixel
% is in each pixel.  This is managed for different types of displays by the
% routine subPixPositions.
%
% Then we up-sample this image to the spatial resolultion we are using for
% the point spread function.
%
% We convolve the upsampled image with the psf, and add together the images
% for each of the sub-pixels, using the appropriate color channel for each
% sub-pixel. Then we are done.
%
% This routine should work for any number of sub-pixels and for any
% arrangement of sub-pixels within the pixels.
%
% Always three display primaries.  In the future we might have more and
% write a rendering algorithm for N primaries to the RGB on a typical
% display.
%
% See also: subPixPositions
%
% (c) Stanford, PDCSOFT, Wandell, 2010

% Verify input arguments
if ieNotDefined('vd'),        error('Virtual display required.'); end
if ieNotDefined('computationType'), computationType = 'inputImage'; end
if ieNotDefined('waitBarOn'),       waitBarOn = 1; end
if ieNotDefined('varPos'), varPos = [];
else warning('varPos not implemented yet');
end

% The image of primary intensities
inputImage = vDisplayGet(vd, 'inputImage');   

sPSF       = vDisplayGet(vd, 'PSFStructure');
% sSPPS      = vDisplayGet(vd,'SPPatternStructure');
nSubPixels = vDisplayGet(vd, 'nSubPixels');
%pixelSize  = vDisplayGet(vd,'pixelsize','um');% In microns

% The output sampling (in mm) for the computed (high-resolution) image. The
% pixel size must be an integer multiple of the output spacing.  In other
% words, if the pixel size is SZ there must be an integer K such that K *
% oSpacing = SZ. This is necessary because the high-resolution image pixels
% have to be on a uniform sampling grid for the convolution with the point
% spread function to work  properly. 
oSpacing = vDisplayGet(vd, 'sample spacing', 'mm');

% Number of row and col spatial samples within each pixel.
sampPerPix = vDisplayGet(vd, 'samples per pixel');

% if ~isempty(varPos)
    % The position variance is specified in microns.  The shifting is
    % in pixels.  oSpacing defines the number of microns per pixel.
    % So, we define varPos by oSpacing to put it in pixel units.
%    varPos = varPos / oSpacing;
% end

% We produce either a single pixel or a general image.  These two cases are
% managed a little differently.
computationType = ieParamFormat(computationType);
switch computationType
    case 'singlepixel'
        sPSF = vDisplayGet(vd, 'PSFStructure');

        nPrimaries = vDisplayGet(vd, 'nsubpixels');
        inputImage = zeros(3, 3, nPrimaries);
        inputImage(2, 2, 1:nPrimaries) = 1;

    case 'inputimage'
        % Full input image data
        if isempty(inputImage), outImage=[]; return; end

    otherwise
        error('Unknown vdisplay compute type')
end

vdGam = vDisplayGet(vd, 'gammaStructure');
numGammas = size(vdGam, 2);

for ii = 1:numGammas;
    gTable = gammaGet(vdGam{ii}, 'table');
    tSize = gammaGet(vdGam{ii}, 'tableSize');
    idx = round((inputImage(:, :, ii) * (tSize - 1))) + 1;
    inputImage(:, :, ii) =  gTable(idx);
end

% inputImage is defined by now, but not earlier.
[row, col, sp] = size(inputImage);

% This cell array defines which sub-pixel is located in each pixel.  This
% is a little complex.  A sub-pixel is defined by both its spectral power
% distribution AND its position within the pixel.  You can have the same
% red SPD appear to different positions, say in a CRT.  We treat the red
% pixel in the upper left of the pixel as a DIFFERENT sub-pixel from the
% red pixel that appears in the lower right of the pixel.  In this matrix
% we indicate which of these (red,upper) or (red,lower) is present in the
% pixel.  When we create the sub-pixels, we create them with the proper
% combination of SPD and position.
spPos = vDisplayGet(vd, 'subPixelPositions', [row col sp]);

% Prepare the output image as zeros.  We will add into it.
outImage = zeros(row * sampPerPix, col * sampPerPix, sp);

% Then we have sampPerPix pixels and we are going to shift the output by
% this much.  More explanation here ...
shft = round(sampPerPix / 2);

% Compute the rendered image
if waitBarOn, wBar = waitbar(0,'vdisplayCompute'); end

for ii=1:nSubPixels
    if waitBarOn, waitbar(ii / nSubPixels, wBar); end

    % Find the pixels that contain this sub-pixel
    img = spPos(:, :, ii) .* inputImage(:, :, ii);

    % Upsample the input image so that its spacing is oSpacing
    % figure(1); imagesc(img); colormap(gray)
    img = upsample2(img, sampPerPix);

    % Single pixel case
    if (row == 1) && (col == 1)
        img = reshape(img, sampPerPix, sampPerPix); 
    end

    % Place the pixels in the center of the samples, rather than at the
    % edge as upsample does.
    img = circshift(img, [shft, shft]);
    % figure(1); imagesc(img); colormap(gray);

    % Introduce position variance in this sub-pixel class.
    %    if ~isempty(varPos)
    %         iVarY = upsample2(varPos(:,:,ii,1),sampPerPix);
    %         iVarX = upsample2(varPos(:,:,ii,2),sampPerPix);
    %         iVar(:,:,1) = circshift(iVarY ,[shft,shft]);
    %         iVar(:,:,2) = circshift(iVarX ,[shft,shft]);
    %         img  = subPixelShift(img, iVar);
    %     end

    % Get the psf image at the desired spacing in mm
    % figure(1); mesh(psfData)
    psfData = psfGet(sPSF{ii}, 'sampled PSF', oSpacing, 'mm');

    % Convolve and save in the appropriate output primary
    % We end up with a problem is size(psfData) > size(img).
    % Deal with this some day.
    outImage(:, :, ii) = outImage(: , :, ii) + ieConv2FFT(img, psfData, 'same');
    % figure(1); imagesc(outImage(:,:,ii)); mesh(outImage(:,:,ii))
end
if waitBarOn, close(wBar); end

% Normalise outImage to range between 0 and 1
%outImage = outImage - min(outImage(:));
%outImage = outImage ./ max(outImage(:));

support = {};

% This is the sampling grid in millimeters of subpixel sampling positions
if nargout == 2
    r = size(outImage, 1);
    c = size(outImage, 2);
    y = (1:r) * oSpacing;
    y = y - mean(y);
    x = (1:c) * oSpacing;
    x = x - mean(x);
    [X, Y] = meshgrid(x, y);
    support{1} = X;
    support{2} = Y;
end
% figure; mesh(support{1},support{2},outImage(:,:,ii))

return;
