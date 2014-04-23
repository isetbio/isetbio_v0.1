function val = vDisplayGet(vd, varargin)
%  Get Virtual Display values and properties
%
%   val = vDisplayGet(vd, varargin)
%
% The virtual display structure (vd) has many fields. This is the routine
% that accesses the information from the virtual display.
% 
% The input arguments apart from vd are parameter strings defining the
% information you wish to retrieve from the display. The result is either
% the value (if only one parameter is requested), or a cell array of
% returned values.
%
% The current virtual display is normally stored in the Display window
% GUIDATA field and can be retrieved as
%
%    dispGD = ctGetObject('displayGD');
%    vd = displayGet(dispGD,'currentDisplay')
% or
%    vd = displayGet(ctGetObject('displayGD'),'currentDisplay');
%
% The display model has both primaries and sub-pixels.  This notion is
% slightly complex and requires some discussion.  See the discussion in
% vDisplayCreate.
%
% This routine returns virtual display parameters; it will call dixelGet if
% the parameter is not contained in this file. You should use this routine,
% vDisplayGet, and you should not use dixelGet directly.  Read the routine,
% make sure it works, but don't use outside of here (say in a script).
% 
% See also vDisplaySet, vDisplayCreate, and dixelGet/Set
%
% Note: This routine might have been named vdGet.
%
% Examples:
%
%   vd = vDisplayCreate;
%   vDisplayGet(vd,'Type')
%   vDisplayGet(vd,'RoomAmbientLighting')
%   vDisplayGet(vd,'WavelengthSamples')
%   vDisplayGet(vd,'pixelSize','um')
%   vDisplayGet(vd,'pixelSize','mm')
%   psf = vDisplayGet(vd,'psf');
%    data = psfGet(psf{2},'rawData');
%    cdSupport = psfGet(psf{2},'cdSupport');   % Sample position in um
%    figure; mesh(cdSupport{2},cdSupport{1},data);
%    xlabel('um'), ylabel('um'); zlabel('Relative intensity'); 
%    title('PSF mesh')
%
%   vd = displayGet(ctGetObject('displayGD'),'vd');
%   vDisplayGet(vd,'outputHeight','mm')
%
% ** Parameter information below is not up to date and needs updating **
%
% General descriptions
%  'type'   - Always the string 'VirtualDisplay'
%  'name'   - LCD, L6W, CRT, so forth
%
% Display Geometry
%  'displaySizeinpixelx' -
%  'displaySizeinpixely' -
%  'viewingDistance'
%  'viewingAnglex'
%  'viewingAngley'
%
% Input to display
%  'inputimage','imagerawdata' - Defined in terms of primary intensities
%  'inputrow'
%  'inputcol'
%  'inputsize'
%
% Output image
%  'outputimage','imagerendered' - result from vdisplayCompute in RGB
%  'xyz'   - Output in XYZ coordinates
%
% Pixel geometry
%  'imagePixelSizex'     -
%  'imagePixelSizey'
%  'samplesPerDegree'
%  'pixelsPerDegree'
%  'samplespacing'
%  'degreePerSample'
%
% Display radiance characteristics
%  'imageradiance'  - Output image multiplied by display SPD
%  'maxLuminance'
%  'imageDynamicRange'
%
% Rendered output from the display
%  'outputRow'
%  'outputCol'
%  'outputSize'
%  'renderoversampling'
%
% Dixel properties
%  'dixelStructure','dixel'
%  'numberOfPixelsPerBlockx'
%  'numberOfpixelsPerBlocky'
%  'pixelResolutionx'
%  'pixelResolutiony'
%  'pixelSize'   - What units?  These can be specified, I hope.
%  'pixelSizeinmmx'
%  'pixelSizeinmmy'
%  'dpi' - dots per inch
%  'nSubPixels'
%  'spps'  - sub-pixel pattern structure (defines sub-pixel pattern)
%  'psfStructure'
%  'psfSpan'
%  'psfSamplingrate'
%  'subPixelData'
%
% Dixel color properties
%  'wavelengthSamples'
%  'nameOfPrimaries'
%  'nPrimaries'
%  'displaywhitepoint'
%  'whiteScale'
%  'spectrumOfPrimaries'
%  'colorOfPrimaries'
%  'rgb2lms'
%  'rgb2XYZ'
%
% Dixel gamma properties
%  'gammaStructure'
%  'gammaTable'
%
%
% (C), Stanford VISTA Team 2006

if ieNotDefined('vd'), error('Display Model required.'); end
if isempty(varargin), error('Parameter is required.');   end

param = ieParamFormat(varargin{1});
switch param

    case {'type','displaytype'}
        val=vd.m_strDisplayType;
    case {'name','displayname'}
        val=vd.m_strDisplayName;
        % Why is this here? 
        
    case {'rgblayout'}
        % This is new.  We should have made this explicit a long time ago,
        % sigh. It comes from the dixel structure in the virtual display.
        dixel = vDisplayGet(vd,'dixel');
        val = dixelGet(dixel,'rgbLayout');
        
    case 'verticalrefreshrate'
        val=vd.sPhysicalDisplay.m_fVerticalRefreshRate;

    case {'maxluminance','maximumluminance'}
        % Should be named luminance.  Units are cd/m2.  No longer part
        % of stimulus.  Whole stimulus structure should not be here.
        val = vd.sStimulus.m_fImageMeanIntensity;

    case 'viewingdistance'
        % vDisplayGet(vd,'viewingDistance','mm');
        % This should not be part of the display structure.
        if length(varargin) > 1, unit = varargin{2};
        else unit = 'm';
        end
        val = vd.sViewingContext.m_fViewingDistance;
        val = val*ieUnitScaleFactor(unit);
        return;
    case 'viewingangley'
        val=vd.sViewingContext.m_fViewingAngleY;

    case 'roomambientlighting'
        val=vd.sViewingContext.m_fRoomAmbientLighting;
       
        
    % Input image (not yet rendered) data
    case {'inputimage'}
        % Raw values, before converting from X subpixels to RGB subpixels
        val = vd.sStimulus.m_aImageRawData;
    case {'inputimagexyz'}
        % Return the input image as XYZ values
        im      = vDisplayGet(vd,'inputImage');
        rgb2XYZ = vDisplayGet(vd,'rgb2XYZ');
        val     = imageLinearTransform(im,rgb2XYZ);
    case {'inputimagelms'}
        % Return the image as cone (LMS) values
        im      = vDisplayGet(vd,'inputImage');
        rgb2LMS = vDisplayGet(vd,'rgb2LMS');
        val     = imageLinearTransform(im,rgb2LMS);
        
        
    case {'row','inputrow'}
        if strcmp(param,'row'), evalin('caller',mfilename); disp('Change to inputrow'); end
        val = size(vDisplayGet(vd,'inputImage'),1);
    case {'col','inputcol'}
        if strcmp(param,'col'), evalin('caller',mfilename); disp('Change to inputcol'); end
        val = size(vDisplayGet(vd,'inputImage'),2);
    case {'size','inputimagesize','inputsize'}
        if strcmp(param,'size'), evalin('caller',mfilename); disp('Change to inputsize'); end
        val = size(vDisplayGet(vd,'inputImage'));

        % Rendered image after vdisplayCompute (RGB)
    case {'outputimage','imagerendered','renderedimage','outimage','imagerawdata'}  
        % The output image is rendered by vdisplayCompute
        val = vd.sStimulus.m_aImageRenderedOut;
        
    case {'renderedimagexyz','outimagexyz', 'xyz', 'xyzimage', 'renderedxyz'}
        % Return the rendered image as XYZ values
        rgb     = vDisplayGet(vd,'rendered image');
        rgb2XYZ = vDisplayGet(vd,'rgb2XYZ');
        val     = imageLinearTransform(rgb,rgb2XYZ);
        
    case {'osample','renderoversampling','osampling','samplesperpixel','samplesperpix'}
        % vDisplayGet(vd,'oSample')
        % Return the  oversampling value used for a nice rendering.
        % Deleted the separate row and col oversampling parameters (BW).
        % We should make sure that this number isn't really huge, say
        % bigger than the number of samples in the PSF. Right? (BW)
        % Maybe we need to worry about odd and even
        % This parameter is inverse to the oSpacing.
        val = vd.sStimulus.oSample;

    case {'imageradiance'}
        % imageRadiance = vDisplayGet(vd,'imageRadiance');
        % If the spd is in proper units so that 1 display value of 1
        % produces the spd entry and these have units, then
        renImg = vDisplayGet(vd,'ImageRendered'); % figure; imagesc(renImg)
        spd    = vDisplayGet(vd,'spectrumofprimaries');
        val    = imageLinearTransform(renImg,spd);
    case {'outputrow'}
        % Pixels
        val = size(vDisplayGet(vd,'outputImage'),1);
    case {'outputcol'}
        % Pixels
        val = size(vDisplayGet(vd,'outputImage'),2);
    case {'outputsize'}
        % Pixels
        val = size(vDisplayGet(vd,'outputImage'));
    case {'outputheight'}
        % vDisplayGet(vd,'output height','mm')
        if length(varargin) > 1, unit = varargin{2};
        else unit = 'mm';
        end
        pSize = vDisplayGet(vd,'pixelSizey',unit);
        val = vDisplayGet(vd,'inputRow')*pSize;
    case {'outputwidth'}
        % vDisplayGet(vd,'output width','mm')
        if length(varargin) > 1, unit = varargin{2};
        else unit = 'mm';
        end
        pSize = vDisplayGet(vd,'pixel Sizex',unit);
        val = vDisplayGet(vd,'inputCol')*pSize;
    case {'outputheightandwidth','outputhw'}
        % s = vDisplayGet(vd,'outputSize','mm');
        if length(varargin) > 1, unit = varargin{2};
        else unit = 'mm';
        end
        val = [vDisplayGet(vd,'outputHeight',unit),vDisplayGet(vd,'outputWidth',unit)];

        % I am not sure what these control factors are and I don't know why
        % there.  I wonder if we can delete them - BW
    case 'scalingfactorx'
        val = vd.sStimulus.m_fScalingFactorX;
    case 'scalingfactory'
        val = vd.sStimulus.m_fScalingFactorY;

    case 'imagedynamicrange'
        val = vd.sStimulus.m_fImageDynamicRange;

    % ----   Display pixel (dixel) properties
    case {'dixelstructure','dixel'}
        val=vd.sPhysicalDisplay.m_objCDixelStructure;
        
    case {'pixelsperdegree', 'pixperdeg','pixperdegx','pixperdegy','pixelsperdegreex','pixelsperdegreey'}
        % Pixels are ALWAYS SQUARE.
        % vDisplayGet(vd,'pixels per degree')
        val = 1 / vDisplayGet(vd,'degrees per pixel');
        
    case {'degreesperpixel','degreesperpixelx','degreesperpixely','degreesperdixel','dixelangle','pixelangle'}
        % Pixels are ALWAYS SQUARE.
        % vDisplayGet(vd,'degrees per pixel')
        %
        pixelSize  = vDisplayGet(vd,'pixel size','m');
        viewDist   = vDisplayGet(vd,'viewingDistance','m');
        val = 2 * atan2( (pixelSize/2) , viewDist);
        val = rad2deg(val);
        
    % ** Samples ** refer to the oversampled image.  They have properties, too.
    case {'samplesperdegree','sampperdeg','samplesperdegreex','samplesperdegreey'}
        % vDisplayGet(vd,'sampPerDeg')
        val = 1 / vDisplayGet(vd,'degrees per sample');

    case {'samplespacing', 'ospacing'}
        % vDisplayGet(vd,'sample spacing','um')
        % This is the spacing (distance) of the samples used to represent
        % the pixel
        if length(varargin) < 2, unit='m';
        else unit = varargin{2};
        end
        val = vDisplayGet(vd,'pixel size',unit)/vDisplayGet(vd,'osample');

    case {'degreespersample'}
        % vDisplayGet(vd,'degrees per sample')
        % The returned value is in degrees (not radians)
        pixelSize  = vDisplayGet(vd,'pixelSize','m');
        viewDist   = vDisplayGet(vd,'viewingDistance','m');
        oSample    = vDisplayGet(vd,'osample');
        mPerOversample = pixelSize/oSample;
        val = 2 * atan2( (mPerOversample/2) , viewDist);
        val = rad2deg(val);
        
        % Sub-dixel information
    case {'nsubpixels','nsubdixels','numberofsubdixels'}
        % vDisplayGet(vd,'nSubPixels')
        val = length(dixelGet(vDisplayGet(vd,'dixelStructure'),'psf'));
    case {'spps','subpixelpatternstructure','sppatternstructure'}
        d = vDisplayGet(vd,'dixelStructure');
        val = dixelGet(d,'SPPatternStructure');
    case {'subpixelpositions','sppositions'}
        % pPos = vDisplayGet(vd,'subPixelPositions');
        % pPos = vDisplayGet(vd,'subPixelPositions',sz);
        if length(varargin) > 1, sz = varargin{2};
        else sz = vDisplayGet(vd,'inputImageSize');
        end
        row = sz(1); col = sz(2); sp = sz(3);

        rgbOrder = lower(vDisplayGet(vd,'name'));
        val = subPixPositions([row, col, sp], rgbOrder);

    case 'subpixelcenter'
        % Within a dixel, the individual primaries have various
        % center positions.  The center of each primary within the
        % pixel is specified in relative coordinates (0,1).  These
        % centers are returned here.
        sSPPS = vDisplayGet(vd,'SPPatternStructure');
        nSubPixel = length(sSPPS);
        cx = zeros(1,nSubPixel);
        cy = zeros(1,nSubPixel);
        for jj=1:nSubPixel
            cx(jj) = eval(sSPPS{jj}.strCenterOfPSFX);
            cy(jj) = eval(sSPPS{jj}.strCenterOfPSFY);
        end
        % The return is [X,Y]
        val = [cx',cy'];

        % Dixel point spread function information
    case {'psfstructure','psf'}
        d = vDisplayGet(vd,'dixelStructure');
        val = dixelGet(d,'PSFStructure');

    case 'psfspan'
        % Get an explanation from XD
        % I think this is the size of the pixel image in mm
        psf = vDisplayGet(vd,'PSFStructure');
        sSPPS = vDisplayGet(vd,'SPPatternStructure');
        mminX=1e10; mmaxX=-1e10; mminY=1e10; mmaxY=-1e10;
        nSubPixels=length(psf);
        for jj=1:nSubPixels;
            px=eval(psf{jj}.strFiniteSupportX);
            py=eval(psf{jj}.strFiniteSupportY);

            cx = eval(sSPPS{jj}.strCenterOfPSFX);
            cy = eval(sSPPS{jj}.strCenterOfPSFY);

            mminX = min([mminX, cx-px]);
            mmaxX = max([mmaxX, cx+px]);

            mminY = min([mminY, cy-py]);
            mmaxY = max([mmaxY, cy+py]);
        end;
        % Why is this one-half?
        val   = [(mmaxX-mminX)/2, (mmaxY-mminY)/2];

    case {'subpixeldata','sppsfsampledata'}
        % spData = vDisplayGet(vd,'subPixelData',2);
        spps = vDisplayGet(vd,'spPatternStructure');
        % Check this ... varargin stuff could be the wrong test ...
        if length(varargin) > 1
            n = varargin{2}; val = spps{n}.aSampledPSFData;
        else
            % Return them all
            val = cell(1,length(spps));
            for jj=1:length(spps), val{jj} = spps{jj}.aSampledPSFData; end
        end

        % Dixel primary SPD information
    case {'wavelengthsamples','wavelength','wave'}
        d = vDisplayGet(vd,'dixelStructure');
        val = dixelGet(d,'WaveLengthSamples');
    case {'primarynames','nameofprimaries'}
        d = vDisplayGet(vd,'dixelStructure');
        val = dixelGet(d,'NameOfPrimaries');
    case {'nprimaries','numberofprimaries'}
        d = vDisplayGet(vd,'dixelStructure');
        val=size(dixelGet(d, 'spdMatrix'), 1);        
    case {'spd','spectrumofprimaries'}
        % Return a matrix of columns with the spd values
        % spd = vDisplayGet(d,'spd matrix');
        d = vDisplayGet(vd,'dixelStructure');
        val = dixelGet(d,'SpectrumOfPrimaries');
    case {'spdmatrix'}
        % Get primaries ordered based on primary spps order
        d = vDisplayGet(vd,'dixelStructure');
        val = dixelGet(d, 'spdmatrix');
    case {'colorofprimaries','rgbprimaries'}
        d = vDisplayGet(vd,'dixelStructure');
        val = dixelGet(d,'SpectrumOfPrimaries');
    case {'displaywhitepoint','whitexyz'}
        % whiteXYZ = vDisplayGet(vd,'displayWhitePoint');
        nPrimaries = vDisplayGet(vd,'nprimaries');
        val = imageLinearTransform(ones(1,1,nPrimaries),vDisplayGet(vd,'rgb2XYZ'));
    case {'displaywhitepointsubpixel','whitexyzsubpixel'}
        % whiteXYZ = vDisplayGet(vd,'displayWhitePoint');
        nPrimaries = vDisplayGet(vd,'nprimaries');
        val = imageLinearTransform(ones(1,1,nPrimaries),vDisplayGet(vd,'rgb2XYZ subpixel'));

    case {'whitescale', 'whitepointscaling'}
        % When we render an image on a specific display, we compute the
        % image on the level of sub-samples (see 'renderOverSampling').
        % Since we don't deal with full sub-pixel values, sub-samples of 
        % white pixels do not get a value of one. This causes a problem 
        % when we apply to this image S-CIELAB or other computations that 
        % use the XYZ white point, as this value was calculated using full 
        % sub-pixels with value of one. 
        %
        % 'whitescale' returned here is the scaling factor for specific 
        % virtual display from sub-sampled rendered image to the actual XYZ 
        % white point value. It will be used to set the mean of the
        % sub-samples of a white pixel to one.
        %
        % Example:
        %   vd = vDisplaySet(vd, 'inputimage', img);
        %   renImage = vdisplayCompute(vd, 'inputimage');
        %   whiteXYZ   = vDisplayGet(vd,'displayWhitePoint');
        %   whiteScale = vDisplayGet(vd, 'whiteScale');   
        %   for ii = 1:3
        %       renImage(:,:,ii) = renImage(:,:,ii)*whiteScale(ii);
        %   end
        %   rgb2XYZvd = vDisplayGet(vd,'rgb2XYZ');
        %   imgXYZ = imageLinearTransform(renImage,rgb2XYZvd);
        %   errorImage = scielab(imgXYZ,img2XYZ,whiteXYZ,scParams);
        %
        nPrimaries = vDisplayGet(vd,'n primaries');
        whiteScale = zeros(1,nPrimaries);
        whitePatch = ones(3,3,nPrimaries);
        vd = vDisplaySet(vd, 'inputImage', whitePatch);
        renWhitePatch = vdisplayCompute(vd,'inputImage',0);
        % tmp = vDisplaySet(vd,'rendered image',renWhitePatch);
        % ctShowRenderedImage(tmp);
        
        % This doesn't make sense to anyone.  
        for ii = 1:nPrimaries
            thisPrimary = renWhitePatch(:,:,ii);
            whiteScale(ii) = 1/mean(thisPrimary(:));
        end
        val = whiteScale;

    case 'rgb2lms'
        % WE NEED A SUBPIXEL VERSION OF THIS.
        % Returns val s.t. imLMS = imageLinearTransform(imRGB,val)
        displaySPD   = vDisplayGet(vd,'SpectrumOfPrimaries')';
        waves        = vDisplayGet(vd,'WaveLengthSamples');
        cones        = vcReadSpectra('SmithPokornyCones',waves);
        val          = cones'* displaySPD;
        % Check
        % im(1,1,1) = 1; im(1,1,2) = 1;im(1,1,3) = 1;
        % imageLinearTransform(im,val)

        disp('This is a whole pixel rgb2lms')
        
    case 'rgb2xyz'   % For spatial resolution at the pixel or larger
        % vDisplayGet(vd,'rgb2xyz subpixel')

        % Returns a matrix s.t. imXYZ = imageLinearTransform(imRGB,val)
        % If you have a display row vector, rgb, then rgb*rgb2xyz = xyz
        % xyz is also a row vector.
        displaySPD  =  vDisplayGet(vd,'spdMatrix')';
        wave        =  vDisplayGet(vd,'WaveLengthSamples');
        % vcNewGraphWin; plot(wave,displaySPD); grid on
        val          =  ieXYZFromEnergy(displaySPD', wave);

        % Check
        % im(1,1,1) = 1; im(1,1,2) = 1;im(1,1,3) = 1;
        % imageLinearTransform(im,val)
        disp('This is a whole pixel rgb2xyz')
        
    case 'rgb2xyzsubpixel'   % For spatial resolution below pixel (subpixel)
        % vDisplayGet(vd,'rgb2xyz subpixel')
        
        % We have been using white scale to deal with the high spatial
        % resolution case.  When the samples are smaller than a pixel,
        % the true intensity of the sub-pixel samples is higher than the
        % pixel as a whole, because there is a lot of black space for each
        % subpixel.  So, we stuck in white scale to deal with this.  So, we
        % have to put in the white scale.
        
        % Returns a matrix s.t. imXYZ = imageLinearTransform(imRGB,val)
        % If you have a display row vector, rgb, then rgb*rgb2xyz = xyz
        % xyz is also a row vector.
        displaySPD  =  vDisplayGet(vd,'spdMatrix')';
        wave        =  vDisplayGet(vd,'WaveLengthSamples');
        % vcNewGraphWin; plot(wave,displaySPD); grid on
        val          =  ieXYZFromEnergy(displaySPD', wave);
        
        % We scale the rgb2xyz matrix (3x3) by a diagonal matrix (white
        % scale) that will bring up the XYZ values to a large number. This
        % number accounts for the fact that at sub-pixel spatial scale the
        % intensity of the sub-pixel samples are much higher and there is a
        % lot of black space in the pixel.
        whiteScale = vDisplayGet(vd,'white scale');
        val = diag(whiteScale) * val;
        
        % Check
        % im(1,1,1) = 1; im(1,1,2) = 1;im(1,1,3) = 1;
        % imageLinearTransform(im,val)
        
        % Display gamma information
    case 'gammastructure'
        d   = vDisplayGet(vd,'dixelStructure');
        val = dixelGet(d,'GammaStructure');
    case 'gammatable'
        d = vDisplayGet(vd,'dixelStructure');
        gStruct =dixelGet(d,'GammaStructure');
        for jj=1:length(gStruct);
            displayGamma(:, jj) = gStruct{jj}.vGammaRampLUT; %#ok<AGROW>
        end;
        val = displayGamma;
    otherwise
        dxl = vDisplayGet(vd,'dixel');
        if length(varargin) > 1
            val = dixelGet(dxl,param,varargin{2:end});
        else
            val = dixelGet(dxl,param);
        end
end

return;
