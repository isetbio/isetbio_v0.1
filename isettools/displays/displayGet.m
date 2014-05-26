function val = displayGet(d,parm,varargin)
%Get display parameters and derived properties
%
%     val = displayGet(d,parm,varargin)
%
% Basic parameters
%     {'type'} - Always 'display'
%     {'name'} - Which specific display
%
% Transduction
%     {'gamma table'}  - Nlevels x Nprimaries
%     {'dacsize'}      - Number of bits (log2(nSamples))
%     {'nlevels'}      - Number of levels
%     {'levels'}       - List of levels
%
% SPD calculations
%     {'wave'}                % Nanometers
%     {'nwave'}               % Number of wave samples
%     {'spd primaries'}       % Energy units, always nWave by nPrimaries
%     {'white spd'}           % White point spectral power distribution
%     {'nprimaries'} 
%
% Color conversion and metric
%     {'rgb2xyz'}
%     {'rgb2lms'}
%     {'white xyz'}
%     {'white xy'}
%     {'white lms'}
%     {'primaries xyz'}
%     {'primaries xy'}
%
% Spatial parameters
%     {'dpi', 'ppi'}                  % Dots per inch
%     {'meters per dot'}
%     {'dots per meter'}
%     {'dots per deg'}         % Dots per degree visual angle
%     {'viewing distance'}     % Meters
%
% Examples
%   d = displayCreate;
%   w = displayGet(d,'wave');
%   p = displayGet(d,'spd');
%   vcNewGraphWin; plot(w,p); set(gca,'ylim',[-.1 1.1])
%
%   chromaticityPlot(displayGet(d,'white xy'))
%
%   vci = vcimageCreate('test',[],d);
%   plotDisplayGamut(vci)
%
% Copyright ImagEval 2011

%% Check parameters
if ieNotDefined('parm'), error('Parameter not found.');  end

% Default is empty when the parameter is not yet defined.
val = [];

parm = ieParamFormat(parm);

%% Do the analysis
switch parm
    case {'name'}
        val = d.name;
    case {'type'}
        % Type should always be 'display'
        val = d.type;
    case {'gtable','dv2intensity','gamma','gammatable'}
        if checkfields(d,'gamma'), val = d.gamma; end
    case {'bits','dacsize'}
        % color bit depths, e.g. 8 bit / 10 bit
        % This is computed from size of gamma table
        gTable = displayGet(d, 'gTable');
        assert(ismatrix(gTable), 'Bit depth of display unkown');
        val = round(log2(size(gTable, 1)));
    case {'nlevels'}
        % Number of levels
        val = 2^displayGet(d,'bits');
    case {'levels'}
        % List of the levels, e.g. 0~255
        val = 1:displayGet(d,'nlevels') - 1;
        
        % SPD calculations
    case {'wave','wavelength'}  %nanometers
        % For compatibility with PTB.  We might change .wave to
        % .wavelengths.
        if checkfields(d,'wave'), val = d.wave(:);
        elseif checkfields(d,'wavelengths'), val = d.wavelengths(:);
        end
    case {'binwidth'}
        wave = displayGet(d, 'wave');
        if length(wave) > 1
            val = wave(2) - wave(1);
        end
        
    case {'nwave'}
        val = length(displayGet(d,'wave'));
    case {'nprimaries'}
        % SPD is always nWave by nPrimaries
        spd = displayGet(d,'spd');
        val = size(spd,2);
    case {'spd','spdprimaries'}
        % Units are energy (watts/....)
        % displayGet(dsp,'spd');
        % displayGet(d,'spd',wave);
        %
        % The issue of scaling the units of the SPD is worth thinking
        % about. When we calibrate a display we are at a distance and we
        % obtain the SPD of each channel maximum averaging over a lot of
        % pixels. 
        %
        % When we want to represent the data at high spatial
        % resolution, it should always be the case that the peak luminance
        % of each channel, averaged over a large region of image, equals
        % that peak.  But at high spatial resolution, the channel may be
        % zero over large portions of the image.  For example, the red
        % channel doesn't span the green/blue or black lines.  So, when we
        % create a spatially resolved subpixel image we need to know how to
        % scale the spd for that image so that the mean luminance is
        % preserved.
        
        
        % Always make sure the spd has rows equal to number of wavelength
        % samples.  The PTB uses spectra rather than spd.  This hack makes
        % it compatible.  Or, we could convert displayCreate from spd to
        % spectra some day.
        if checkfields(d,'spd'),         val = d.spd;
        elseif checkfields(d,'spectra'), val = d.spectra;
        end
        
        % Sometimes users put the data in transposed, sigh.  I am one of
        % those users.
        nWave = displayGet(d,'nwave');
        if size(val,1) ~= nWave,  val = val'; end

        % Interpolate for alternate wavelength, if requested
        if ~isempty(varargin)
            % Wave interpolation
            wavelength = displayGet(d,'wave');
            wave = varargin{1};
            val = interp1(wavelength(:), val, wave(:),'linear',0);
        end
    case {'whitespd'}
        % SPD when all the primaries are at peak, this is the energy
        if ~isempty(varargin), wave = varargin{1};
        else                   wave = displayGet(d,'wave');
        end
        e = displayGet(d,'spd',wave);
        val = e*ones(3,1);
        
        % Color conversion
    case {'rgb2xyz'}
        % rgb2xyz = displayGet(dsp,'rgb2xyz',wave)
        % RGB as a column vector mapped to XYZ column
        %  x(:)' = r(:)' * rgb2xyz
        % Hence, imageLinearTransform(img,rgb2xyz)
        % should work
        wave = displayGet(d,'wave');
        spd  = displayGet(d,'spd',wave);        % spd in energy
        val  = ieXYZFromEnergy(spd',wave);  %         
    case {'rgb2lms'}
        % rgb2lms = displayGet(dsp,'rgb2lms')
        % rgb2lms = displayGet(dsp,'rgb2lms',wave)
        %
        % The matrix is scaled so that L+M of white equals Y of white.
        %
        % RGB as a column vector mapped to LMS column
        % c(:)' = r(:)' * rgb2lms
        % Hence:  imageLinearTransform(img,rgb2lms)  should work.
        wave = displayGet(d,'wave');
        coneFile = fullfile(isetRootPath,'data','human','SmithPokornyCones');
        cones = ieReadSpectra(coneFile,wave);   % plot(wave,spCones)
        spd = displayGet(d,'spd',wave);     % plot(wave,displaySPD)
        val = cones'* spd;                  
        val = val';
        
        % Scaled so that sum L and M values sum to Y-value of white
        e = displayGet(d,'white spd',wave);
        whiteXYZ = ieXYZFromEnergy(e',wave);
        whiteLMS = ones(1,3)*val;
        val = val*(whiteXYZ(2)/(whiteLMS(1)+whiteLMS(2)));
        
     case {'whitexyz','whitepoint'}
        % displayGet(dsp,'white xyz',wave)
        e = displayGet(d,'white spd');
        if isempty(varargin), wave = displayGet(d,'wave');
        else wave = varargin{1};
        end
        % Energy needs to be XW format, so a row vector
        val = ieXYZFromEnergy(e',wave);
    case {'peakluminance'}
        % Luminance of the white point in cd/m2
        % displayGet(dsp,'peak luminance')
        whiteXYZ = displayGet(d,'white xyz');
        val = whiteXYZ(2);
    case {'whitexy'}
        val = chromaticity(displayGet(d,'white xyz'));
    case {'primariesxyz'}
        spd  = displayGet(d,'spd primaries');
        wave = displayGet(d,'wave');
        val  = ieXYZFromEnergy(spd',wave);
    case {'primariesxy'}
        xyz = displayGet(d,'primaries xyz');
        val = chromaticity(xyz);
        
    case {'whitelms'}
        % displayGet(dsp,'white lms')
        rgb2lms = displayGet(d,'rgb2lms');        
        % Sent back in XW format, so a row vector
        val = ones(1,3)*rgb2lms;

        % Spatial parameters
    case {'dpi', 'ppi'}
        if checkfields(d,'dpi'), val = d.dpi;
        else val = 96;
        end
    case {'metersperdot'}
        % displayGet(dsp,'meters per dot','m')
        % displayGet(dsp,'meters per dot','mm')
        % Useful for calculating image size in meters
        dpi = displayGet(d,'dpi');
        ipm = 1/.0254;   % Inch per meter
        dpm = dpi*ipm;   % Dots per meter
        val = 1/dpm;     % meters per dot
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'dotspermeter'}
        % displayGet(dsp,'dots per meter','m')
        mpd = displayGet(d,'meters per dot');
        val = 1/mpd;
        if ~isempty(varargin), val = val*ieUnitScaleFactor(varargin{1}); end
        
    case {'dotsperdeg','sampperdeg'}
        % Samples per deg
        % displayGet(d,'dots per deg')
        mpd = displayGet(d,'meters per dot');                      
        dist = displayGet(d,'Viewing Distance');  % Meters
        degPerPixel = ieRad2deg(tan( mpd / dist));
        val = round(1/degPerPixel);
        
    case {'viewingdistance', 'distance'}
        % Viewing distance in meters
        if checkfields(d,'dist'), val = d.dist;
        else val = 0.5;   % Default viewing distance in meters, 19 inches
        end
        
    case {'refreshrate'}
        % display refresh rate
        if isfield(d, 'refreshRate'), val = d.refreshRate; end
        
    % PSF information
    case {'psfs', 'pointspread', 'psf'}
        % The whole psf data set
        if isfield(d, 'psfs'), val = d.psfs; end
        
    case {'psfsamples','oversample', 'osample'}
        % Number of psf samples per pixel
        if isfield(d, 'psfs'), val = size(d.psfs, 1); end
        
    case {'psfsamplespacing'}
        % spacing between psf samples
        % displayGet(d,'psf sample sampling',units)
        if isempty(displayGet(d, 'psfs')), return; end
        val = displayGet(d, 'metersperdot') / displayGet(d, 'psfsamples');
        if ~isempty(varargin)
            val = val*ieUnitScaleFactor(varargin{1});
        end
    case {'fillfactor','fillingfactor','subpixelfilling'}
        % Fill factor of subpixel
        psfs = displayGet(d, 'psfs');
        if isempty(psfs), return; end
        [r,c,~] = size(psfs);
        psfs = psfs ./ repmat(max(max(psfs)), [r c]);
        psfs = psfs > 0.2;
        val = sum(sum(psfs))/r/c;
        val = val(:);
    case {'subpixelspd'}
        % spectral power distribution for subpixels
        % see comments in spd
        % This is the real subpixel spd, not the spatial averaged one
        % To get the spd for the whole pixel, use displayGet(d, 'spd')
        % instead
        spd = displayGet(d, 'spd');
        ff  = displayGet(d, 'filling factor');
        val = spd ./ repmat(ff(:)', [size(spd, 1) 1]);
    otherwise
        error('Unknown parameter %s\n',parm);
end

return;