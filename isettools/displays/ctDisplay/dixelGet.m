function val = dixelGet(dxl, param, varargin)
% Get display pixel structure properties.
%
%   val = dixelGet(dxl, param, varargin)
%
% N.B.  Dixel properties should be accessed through vDisplayGet using a
% vDisplayGet(vd,'parameter') call. There may be exceptions but that is the
% general rule. We use dixelGet within this routine only.
%
%   1st Parameter - Dixel structure
%   2nd Parameter - Property name
%
% A pixel refers to a collection of the smallest number of primaries, for
% example r,g,b.  
%
% A block refers to the repeating configuration of pixels necessary to
% define the whole screen.  For example, in an LCD we usually have the same
% RGB pattern repeated so that a pixel and block are the same. But in a CRT
% we can have the pixels offset between even and odd rows. Thus, we need to
% define a 2 x 2 set of pixels to build a repeating block.
%
% Examples:
% Note - do not use this routine normally.  Determine dixel values using
% vDisplayGet.
%
%   dxl   = dixelCreate;
%
%   pSize = dixelGet(dxl,'pixelSize','um')
%   dpi = dixelGet(dxl,'pixelresolutionx')   % dpi
%   dpi2mperdot(dpi,'mm')
%
%   dixelGet(dxl,'NumberOfPrimaries')
%   dixelGet(dxl,'primaryColors')
%   dixelGet(dxl,'primaryNames')
%
%   spd = dixelGet(dxl,'spd'); wave = dixelGet(dxl,'wave'); figure; plot(wave,spd)
%
% List of dixel parameters and aliases - Needs editing!
%
%  'NumberOfPrimaries'    - Number of display primaries
%
%  'PixelHeight'
%  'PixelWidth'
%  'PixelSize'
%  'PixelResolutionX'    - col Spacing in dpi
%  'PixelResolutionY'    - row spacing in dpi
%  'PixelResolution'     - [PixelResolutionX,PixelResolutionY]
%
%  'NameOfPrimaries'      - Label?
%  'rgbLayout'            - String array, e.g. s = char(2,2);
%  'WaveLengthSamples'    - Wavelengths
%  'SpectrumOfPrimaries'  - Primary SPD in units of(quanta/???)
%                           This is a unique list of SPDs
%  'ColorOfPrimaries'     - 
%  'GammaStructure'       - Gamma information (DV to intensity)
%  'spdMatrix'            - Rows contain primary SPDs of each sub-pixel.
%                           This is derived from sub-pixel pattern and spd
%
%  'PSFStructure'         - Sub-pixel point spread functions
%  'SPPatternStructure'   - Sub-pixel spatial arrangement
%  'sppsPrimaryList'      - The primary of each subpixel is returned in a
%                           vector.
%
%  'nPixelsPerBlock'      -
%  'NumberOfPixelsPerBlockX' -
%  'NumberOfPixelsPerBlockY' -
%  'BoundedDixel'   - Recorded whether the dixel is bounded, or does it overlay for tiling? E.g
%                   crt uses overlaying for tiling the dixels
%   'DixelType'     - What type of dixel is this, i.e. 3x3rgbdiag (used by psgGroupCreate.m)
%
%   'DixelSubpixelHalfWidth'    - What is the half width of the subpixel, in terms of dixel width
%   'DixelSubpixelHalfHeight'   - What is the half height of the subpixel, in terms of dixel height
%   'DixelOrientation'  -  What orientation are subpixels drawn, v = vertical, h = horizontal
%
% (C), PDCSOFT, Stanford, 2006

if ieNotDefined('dxl'), error('First argument must be a dixel structure'); end
if ieNotDefined('param'), error('No parameter specified'); end

val = [];

param = ieParamFormat(param);
switch param  
    % Power consumption by subpixels
    case {'powerconsumptionpersubpixel'}
        % Return the matrix with the power consumption per subpixel, where
        %  power consumption is record in microWatts per subpixel
        if isfield(dxl, 'm_powerConsumptionPerSubpixel')
            val = dxl.m_powerConsumptionPerSubpixel;
        else
            % If subpixel power consumption is unset, then set default power consumption
            %  so each subpixel consumes 10 microwatts
            disp(sprintf('ERROR: This display does not have microWatt power consumption values per subpixel. Please set the subpixel power consumption values.'));
            val(1:length(dixelGet(dxl, 'psf'))) = 10;
        end

    % Pixel information
    case {'subpixeloverscalex'}
        % Font overscale X value, needed for drawing and rendering fonts
        % Horrible (says MIKE): Defaults required when reading in older
        % calibrated displays
        if isfield(dxl, 'm_nSubpixelOverscaleX')
            val = dxl.m_nSubpixelOverscaleX;
        else
            val = 3;
        end
    case {'subpixeloverscaley'}
        % Font overscale Y value, needed drawing and rendering fonts
        % Horrible (MIKE): Defaults required when reading in older
        % calibrated displays
        if isfield(dxl, 'm_nSubpixelOverscaleY')
            val = dxl.m_nSubpixelOverscaleY;
        else
            val = 1;
        end
    case {'pixperblock','npixperblock','npixelsperblock'}
        val = dixelGet(dxl,'numberofpixelsperblockx')*dixelGet(dxl,'numberofpixelsperblocky');
    case 'numberofpixelsperblockx'
        val = dxl.m_nNumberOfPixelsPerBlockX;
    case 'numberofpixelsperblocky'
        val = dxl.m_nNumberOfPixelsPerBlockY;

        % We think we only have square pixels and sizex/sizey should go
        % away.  - MB, BW.
    case {'pixelsize','dixelsize'}   % Default is mm
        % dixelGet(dxl,'dixelSize','mm')
        % dixelGet(dxl,'dixelSize','um')
        % We return only a single value, assuming a square pixel.
        % But, really, shouldn't we return
        % val = [dxl.m_fPixelSizeInMmX, m_fPixelSizeInMmY];
        val = dxl.m_fPixelSizeInMmX;
        if isempty(varargin), return;
        else unit = varargin{1};
        end
        val = val*(ieUnitScaleFactor(unit)/1000);

    case {'pixelsizex','pixelwidth','dixelwidth','dixelsizex'}  % mm by default
        % dixelGet(dxl,'pixel size','mm')
        % The pixel size represents the center to center spacing used to
        % calculate a rendered image from the pixel point spread functions.
        % If the psf functions are non-overlapping, then this value is the
        % same as the support of the psf.  But if the psf spreads beyond a
        % pixel, the value here is smaller than the psf support.  For a CRT,
        % the psf spreads into neighboring pixels and this value is smaller
        % than the support. For an LCD, the psf support is equal to one
        % pixel normally. But in the case of the Dell Chevron, the psf
        % support is larger.
        if isempty(varargin), return;
        else unit = varargin{1};
        end
        
        tmp = dixelGet(dxl,'dixel size',unit);
        if length(tmp) > 1, val = tmp(2); 
        else val = tmp;
        end

    case {'pixelsizey','pixelheight','dixelheight','dixelsizey'}
        % dixelGet(dxl,'pixel size','mm')
        if isempty(varargin), return;
        else unit = varargin{1};
        end
        tmp = dixelGet(dxl,'dixel size',unit);
        val = tmp(1);
        
    case 'dpi'
        pixSize = dixelGet(dxl,'Pixel Size','mm');
        val = mperdot2dpi(pixSize,'mm');
     case {'pixelresolution','pixel resolution dpi'}  % dpi
        val = [dixelGet(dxl,'pixelResolutionX'),dixelGet(dxl,'pixel Resolution Y')];
    case {'pixelresolutionx'}  % DPI
        resX = dixelGet(dxl,'pixel width','mm');% Meters to inches 39.37007874015748
        val = mperdot2dpi(resX,'mm');
    case {'pixelresolutiony'} % DPI
        resY = dixelGet(dxl,'pixel height','mm');
        val = mperdot2dpi(resY,'mm');
        
        % Sub-pixel information
        % This should be obtained by looking at the PSFs, not using
        % these parameters.  I think they are obsolete.
    case {'numberofsubpixelsperblock','nsubpixelsperblock','subpixperblock'}
        val = dixelGet(dxl,'pixPerBlock')*dixelGet(dxl,'npsf');
    case {'sppatternstructure','spps','subpixelpattern'}
        val = dxl.m_cellSPPatternStructure;
    case {'sppsprimarylist'}
        % The primary spd associated with each pixel in a vector.
         spps = dixelGet(dxl,'spps');
%         tmp = zeros(size(spps));
%         for jj=1:length(tmp), tmp(jj) = spps{jj}.nPrimary; end
%         val = tmp;
          if checkfields(spps,'primaries'), val = spps.primaries;
          else error('spps missing a primaries slot');
          end

        % Point spread function information
    case {'psfstructure','psf'}
        % dixelGet(dxl,'psf',1);
        if isempty(varargin), val = dxl.m_cellPSFStructure;
        else                  val = dxl.m_cellPSFStructure{1};
        end
    case {'npsf','numberofsubpixels'}
        val = length(dxl.m_cellPSFStructure');

        % Primary  information
    case {'wavelengthsamples','wave'}
        val = dxl.m_aWaveLengthSamples;
    case {'nameofprimaries','primarynames'}
        val = dxl.m_cellNameOfPrimaries;
    case {'tagofprimaries','primarytags'}
        % The first character (lower case) is the tag
        % That way Red is 'r' and so forth
        % dixelGet(dxl,'primaryTags')
        pNames = dixelGet(dxl,'primaryNames');
        val = char(length(pNames));
        for ii=1:length(pNames)
            val(ii) = lower(pNames{ii}(1));
        end
    case {'numberofprimaries','nprimaries'}
        val =length(dxl.m_cellNameOfPrimaries);
    case {'colorofprimaries','primarycolors'}
        % Are the colors in the rows or columns?
        val = dxl.m_aColorOfPrimaries;
%     case {'spdmatrix','uniquespd'}
%   We have a single spd matrix whose columns are the spd.
%   We indicate which primary is at which sub-pixel by an index into the
%   columns of that matrix. This is now obsolete (I think).
%         % This SPD matrix accounts for the fact that multiple sub-pixels
%         % have the same spd.  The main spd contains only the unique spd's,
%         % not the duplicates.
%         % Really?  
%         spd   = dixelGet(dxl,'spd');
%         pList = dixelGet(dxl,'sppsPrimaryList');
%         val   = spd(pList,:);
    case{'spd','spectrumofprimaries'}
        val  = dxl.m_aSpectrumOfPrimaries;
    case {'spdmatrix', 'uniquespd'}
        % This is required to generate an spd matrix where the spd order is determined by the primary
        % locations
        spps = dixelGet(dxl ,'spps');
        p    = spps.primaries;
        spd  = dxl.m_aSpectrumOfPrimaries;
%        spd  = dixelGet(dxl, 'SpectrumOfPrimaries');
        val = spd(p, :);
    case {'primarylayout','rgblayout'}
        % Return a string with the tags in the shape of the primary layout
        % dixelGet(dxl,'primaryLayout')
        spps = dixelGet(dxl,'spps');
        p    = spps.primaries;
        tags = dixelGet(dxl,'primarytags');
        val = tags(p);
        
        % Display gamma information
    case {'gam','gammastructure'}
        val = dxl.m_cellGammaStructure;
     
    % Record how this dixel is used for tiling, is the tiling end to end of
    % do the tiles overlay (e.g. overlay for crt and end to end for RGB).
    % By default 0 = end to end tiling, 1 = overlaid tiles
    case {'boundeddixel'}
        if isfield(dxl, 'm_boundeddixel')
            val = dxl.m_boundeddixel;
        else
            val = 1;
        end
    
    % What type of dixel is this? This is param used by psfGroupCreate,
    % e.g. '3x3rgbdiag'
    case {'dixeltype'}
        if isfield(dxl, 'm_ditype')
            val = dxl.m_ditype;
        else
            val = 'unknown';
        end

    % What is the half width of the subpixel, in terms of dixel width
    case {'dixelsubpixelhalfwidth'}
        if isfield(dxl, 'm_disubhalfwidth')
            val = dxl.m_disubhalfwidth;
        else
            val = -1;
        end

    % What is the half height of the subpixel, in terms of dixel height
    case {'dixelsubpixelhalfheight'}
        if isfield(dxl, 'm_disubhalfheight')
            val = dxl.m_disubhalfheight;
        else
            val = -1;
        end

    % What orientation are subpixels drawn, v = vertical, h = horizontal
    case {'dixelorientation'}
        if isfield(dxl, 'm_diorientation')
            val = dxl.m_diorientation;
        else
            val = 'v';
        end

    otherwise
        % This could come from vDisplay or Dixel calls.
        error('Unknown parameter %s',param);
end;

return;

