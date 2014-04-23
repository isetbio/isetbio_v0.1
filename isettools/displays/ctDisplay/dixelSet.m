function dxl = dixelSet(dxl, param, val)
% Dixel (display pixel) set command
%
%   dxl = dixelSet(dxl, param, val)
%
% The dixel structure is attached to the virtual display, which is attached
% to the guidata of the Display window.
%
% Examples:
%   vd = vDisplayCreate('lcd'); dxl = vDisplayGet(vd,'dixel');
%   dixelGet(dxl,'dixelSize','mm')
%   psf = dixelGet(dxl,'psf');
%   spps = dixelGet(dxl,'spps');
%
%--------------------
% Settable dixel parameters
%
%  'NameOfPrimaries'
%  'WaveLengthSamples'
%  'SpectrumOfPrimaries'
%  'ColorOfPrimaries'
%  'GammaStructure'
%  'PSFStructure'
%  'pixelSizeInMM'
%  'NumberOfSubPixelsPerBlock'
%  'SPPatternStructure'
%  'NumberOfPixelsPerBlockX'
%  'NumberOfPixelsPerBlockY'
%  'BoundedDixel'    - Recorded whether the dixel is bounded, or does it overlay for tiling? E.g
%                   crt uses overlaying for tiling the dixels
%   'DixelType'              - What type of dixel is this, i.e. 3x3rgbdiag
%                           (used by psgGroupCreate.m)
%   'DixelSubpixelHalfWidth'    - What is the half width of the subpixel, in terms of dixel width
%   'DixelSubpixelHalfHeight'   - What is the half height of the subpixel, in terms of dixel height
%   'DixelOrientation'  -  What orientation are subpixels drawn, v = vertical, h = horizontal
%
 
% Programming TODO
%  Wavelength samples should be a vector, not cell array
%  Should we set the gamma table as well?
%

if ieNotDefined('dxl'),   error('First argument must be a dixel structure'); end
if ieNotDefined('param'), error('Parameter required'); end
if ieNotDefined('val'),   error('Parameter value required'); end

% Find and set the parameter
param = ieParamFormat(param);
switch param
    % Power consumption by subpixels (values are
    case {'powerconsumptionpersubpixel'}
        % Return the matrix with the power consumption per subpixel, where
        %  power consumption is record in microWatts per subpixel
        dxl.m_powerConsumptionPerSubpixel = val;

    case {'pixelsizeinmm','pixelsize'}  %
        % dixelSet(dxl,'pixelSize',0.400)
        % dixelSet(dxl,'pixel size in mm',[height,width]); %(y,x)
        currentSize = dixelGet(dxl,'pixelSize','mm');
        
        if length(val) < 2, val(2) = val(1); end
        dxl.m_fPixelSizeInMmY = val(1);
        dxl.m_fPixelSizeInMmX = val(2);
        
        % When we set the pixel size, we must also scale the corresponding
        % sub-pixel point spread functions.  Though in the early stage,
        % they may not be set up.  So, check if they are set up and if so,
        % scale them.
        psf = dixelGet(dxl,'psf');
        psfSamples = psfGet(psf{1},'psf samples','mm');
        %  d = psfGet(psf{1},'psf image');figure; mesh(d)
        
        % Calculate the new size.  We are not handling both dimensions, and
        % we probably should.  But mostly we are thinking of pixels as
        % sampled the same in both dimensions.
        samp = (val(1)/currentSize)*psfSamples;

        for ii=1:length(psf)
            psf{ii} = psfSet(psf{ii},'psfSamples',samp);
        end
        dxl  = dixelSet(dxl,'psf',psf);
        
    case {'pixelsizeinmmonly','pixelsizeonly','pixelsizenopsfscaling'}  
        % dixelSet(dxl,'pixelSize',0.400)
        % Why is this here, without any psf scaling? BW
        %
        % When we set the pixel size, we must also scale the corresponding
        % sub-pixel point spread functions (unless PSF already scaled appropriately, i.e. first entry).
        % This must be in error ...
        % currentSize = dixelGet(dxl,'pixelSize','mm');
        dxl.m_fPixelSizeInMmX = val;
        dxl.m_fPixelSizeInMmY = val;
        
    case 'subpixeloverscalex'
        % Font overscale X value, needed drawing and rendering fonts
        dxl.m_nSubpixelOverscaleX = val;

    case 'subpixeloverscaley'
        % Font overscale Y value, needed drawing and rendering fonts
        dxl.m_nSubpixelOverscaleY = val; 
 
    case {'nameofprimaries','primarynames'}
        dxl.m_cellNameOfPrimaries = val;
    case {'wavelengthsamples','wave'}
        dxl.m_aWaveLengthSamples=val;
    case {'spd','spectrumofprimaries'}
        % The spd is stored as a matrix with columns containing the image
        % radiance of the different primaries at peak intensity.  Usually
        % the red primary is in the first column, and so forth.  The image
        % radiance units are watts/sr/nm/m^2.
        dxl.m_aSpectrumOfPrimaries = val;
    case 'colorofprimaries'
        % These colors are nominal colors for drawing
        % markers/colored lines in plots, they are not accurate. So here
        % we check if they are between [0, 1]. Should be 2D matrix, the
        % row represents primaries...
        dxl.m_aColorOfPrimaries = val;
    case {'gam','gammastructure'}
        %Should be an m x 1 cell array, where m is the number of
        %primaries. Each element is a structure Maybe I should do more
        %robust error check?
        dxl.m_cellGammaStructure = val;

    case {'psf','psfstructure'}
        %Should be an m x 1 cell array, where m is the number of
        %primaries. Each element is a structure Maybe I should do more
        %robust error check?
        dxl.m_cellPSFStructure = val;

    case {'nsubpixels','numberofsubpixelsperblock'}
        % MNOTES: This is not a setable value, as it is calculated in
        % dixelGet() by dixelGet(dxl,'pixPerBlock') * dixelGet(dxl,'npsf')
        error('numberofsubpixelsperblock cannot be directly set. As it is calculated in dixelGet() by pixPerBlock * npsf'); 
        % dxl.m_nNumberOfSubPixelsPerBlock = val;
        
    case {'subpixelpattern','sppatternstructure','spps'}
        %Should be an m x 1 cell array, where m is the number of
        %primaries. Each element is a structure Maybe I should do more
        %robust error check?
        dxl.m_cellSPPatternStructure = val;

    case {'npixelsperblockx','numberofpixelsperblockx'}
        dxl.m_nNumberOfPixelsPerBlockX = val;

    case 'numberofpixelsperblocky'
        dxl.m_nNumberOfPixelsPerBlockY = val;
        
    case 'boundeddixel'
        dxl.m_boundeddixel = val;

    case 'dixeltype'
        dxl.m_ditype = val;

    % What is the half width of the subpixel, in terms of dixel width
    case {'dixelsubpixelhalfwidth'}
        dxl.m_disubhalfwidth = val;

    % What is the half height of the subpixel, in terms of dixel height
    case {'dixelsubpixelhalfheight'}
        dxl.m_disubhalfheight = val;

    % What orientation are subpixels drawn, v = vertical, h = horizontal
    case {'dixelorientation'}
        dxl.m_diorientation = val;

    otherwise
        error('Unknown Display, CDisplay or dixel property: %s',param);
end;

return;

