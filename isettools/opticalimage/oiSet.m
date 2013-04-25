function oi = oiSet(oi,parm,val,varargin)
% Set ISET optical image parameter values
%
%    oi = oiSet(oi,parm,val,varargin)
%
% All of the parameters of an optical iamge are set through the calls to
% this routine.
%
% The oi is the object; parm is the name of the parameter; val is the
% value of the parameter; varargin allows some additional parameters in
% certain cases.
%
% There is a corresponding oiGet routine.  Many fewer parameters are
% available for 'oiSet' than 'oiGet'. This is because many of the
% parameters derived from oiGet are derived from the few parameters
% that can be set, and sometimes the derived quantities require some
% knowledge of the optics as well.
%
%  Examples:
%    oi = oiSet(oi,'optics',optics);
%    oi = oiSet(oi,'name','myName')
%    oi = oiSet(oi,'filename','test')
%
% User-settable oi parameters
%
%      {'name'}
%      {'type'}
%      {'distance' }
%      {'horizontal field of view'}
%      {'magnification'}
%
%      {'data'}  - Irradiance information
%        {'cphotons'}   - Compressed photons; can be set one waveband at a
%                         time: oi = oiSet(oi,'cphotons',data,wavelength);
%
% N.B.: Because of the large size of the photon data (row,col,wavelength)
% and the high dynamic range, they are stored in a special compressed
% format.  They also permit the user to read and write individual
% wavelength planes. Data sent in and returned are always in double()
% format.
%
% When you write to 'photons', the compression fields used by cphotons are
% cleared. When reading and writing a waveband in compressed mode, it is
% assumed that the compression fields already exist.  We do not compress
% each individual waveband, though this would be possible (i.e., to have an
% array of min/max values for each waveband).
%
% After writing to the photons field, the illuminance and mean illuminance
% fields are set to empty.
%
% Wavelength information
%      {'spectrum'}            - Spectrum structure
%        {'wavelength'}        - Wavelength samples
%
% Optics
%      {'optics'}  - Main optics structure
%      {'opticsmodel'} - Optics computation
%         One of raytrace, diffractionlimited, or shiftinvariant 
%         Spaces and case variation is allowed, i.e.
%         oiSet(oi,'optics model','diffraction limited');
%         The proper data must be loaded to run oiCompute.
%
%      {'diffuser Method'} - 'blur', 'birefringent' or 'skip'
%      {'diffuser Blur'}   - FWHM blur amount (meters)
%
%      {'psfstruct'}        - Entire PSF structure (shift-variant)
%       {'sampledRTpsf'}     - Precomputed shift-variant psfs
%       {'psfSample Angles'}  - Vector of sample angle
%       {'psfImage Heights'}  - Vector of sampled image heights
%       {'rayTrace Optics Name'}  - Optics used to derive shift-variant psf
%
%      {'depth Map'}         - Distance of original scene pixel (meters)
%
% Auxiliary
%      {'consistency'}
%
% Private variables used by ISET but not normally set by the user
%
%   Used for management of compressed photons
%      {'datamin'}
%      {'datamax'}
%      {'bitdepth'}
%
%   Used to cache optical image illuminance
%      {'illuminance'}
%      {'mean illuminance'}
%
% Copyright ImagEval Consultants, LLC, 2003.

if ~exist('parm','var') || isempty(parm), error('Param must be defined.'); end
if ~exist('val','var'), error('Value field required.'); end

parm = ieParamFormat(parm);

switch parm

    case {'name','oiname'}
        oi.name = val;
    case 'type'
        oi.type = val;
    case {'filename'}
        % When the data are ready from a file, we save the file name.
        % Happens, perhaps, when reading multispectral image data.
        oi.filename = val;
    case {'consistency','computationalconsistency'}
        % When parameters are changed, the consistency flag on the optical
        % image changes.  This is irrelevant for the scene case.
        oi.consistency = val;

    case {'distance' }
        % Positive for scenes, negative for optical images
        oi.distance = val;

    case {'wangular','widthangular','hfov','horizontalfieldofview','fov'}
        oi.wAngular = val;

    case 'magnification'
        % Optical images have other mags calculated from the optics.
        evalin('caller','mfilename')
        warndlg('Setting oi magnification.  Bad idea.')
        oi.magnification = val;

    case {'optics','opticsstructure'}
        oi.optics = val;

    case {'data','datastructure'}
        oi.data = val;

    case {'cphotons','compressedphotons','photons'}
        if ~(isa(val,'double') || isa(val,'single')),
            error('Photons must be type double or single.');
        end
        
        bitDepth = oiGet(oi,'bitDepth');
        if isempty(bitDepth), error('Compression parameters not set up.'); end

        if isempty(varargin)
            % Insert the whole photon data set
            % oi = oiSet(oi,'cphotons',data);
            [oi.data.photons,mn,mx] = ieCompressData(val,bitDepth);
            oi = oiSet(oi,'datamin',mn);
            oi = oiSet(oi,'datamax',mx);
        elseif length(varargin) == 1
            % Insert a wavelength plane.
            % oi = oiSet(oi,'cphotons',data,wavelength);

            % When we put in a single waveband, it is possible (and
            % happens) that the min or max of these new data are below or
            % above the previously stored datamin/datamax values.  This can
            % create a problem and warning, of course.  We probably only do
            % this inside of oiCompute, and the place where we have had a
            % problem is with the oiApplyOTF code.  So, think about this.

            % When we put in the data at a single wavelength, we must use
            % the fixed datamax and datamin.
            % If we are changing just one wavelength, we might be violating
            % the mn,mx range.  Warn the user.  After this error, they
            % should set the photons using all wavelengths, which will
            % reset the mn and mx.
            mx = oiGet(oi,'datamax');
            mn = oiGet(oi,'datamin');
            if min(val(:)) < mn 
                error('Min data out of range.  Insert full set.')
            elseif max(val(:)) > mx  
                error('Max data out of range.  Insert full set.')
            end
            idx = ieFindWaveIndex(oiGet(oi,'wave'),varargin{1});
            % There have been cases with min(val) < mn.  Shouldn't happen,
            % right?
            oi.data.photons(:,:,idx) = ieCompressData(val,bitDepth,mn,mx);
        end

        % Clear out derivative luminance/illuminance computations
        oi = oiSet(oi,'illuminance',[]);
        oi = oiSet(oi,'meanilluminance',[]);

    case {'datamin','dmin'}
        % Only used by compressed photons.  Not by user.
        oi.data.dmin = val;
    case {'datamax','dmax'}
        % Only used by compressed photons.  Not by user.
        oi.data.dmax = val;
    case 'bitdepth'
        % Only used by compressed photons.  Not by user.
        oi.data.bitDepth = val;
        % oi = oiClearData(oi);

    case {'illuminance','illum'}
        % The value is stored for efficiency.
        oi.data.illuminance = val;

    case {'meanillum','meanilluminance'}
        oi.data.meanIll = val;

    case {'spectrum','wavespectrum','wavelengthspectrumstructure'}
        oi.spectrum  = val;
        %     case {'binwidth','wavelengthspacing'}
        %         oi.spectrum.binwidth = val;
    case {'wave','wavelength','wavelengthnanometers'}
        % We should probably check that val is a proper set of wavelength
        % values that make sense ... unique, evenly spaced, stuff like
        % that.
        oi.spectrum.wave = val;

        % Optical methods
    case {'opticsmodel'}
        % oi = oiSet(oi,'optics model', 'ray trace');
        % The optics model should be one of
        % raytrace, diffractionlimited, or shiftinvariant
        % Spacing and case variation is allowed.
        val = ieParamFormat(val);
        oi.optics.model = val;

        % Glass diffuser properties
    case {'diffusermethod'}
        % This determines calculation 
        % 0 - skip, 1 - gaussian blur, 2 - birefringent
        % We haven't set up the interface yet (12/2009)
        oi.diffuser.method = val;
    case {'diffuserblur'}
        % Should be in meters.  The value is set for shift invariant blur.
        % The value for birefringent could come from here, too.
        oi.diffuser.blur = val;

        % Precomputed shift-variant (sv) psf and related parameters          
    case {'psfstruct','shiftvariantstructure'}
        % This structure
        oi.psf = val;
    case {'svpsf','sampledrtpsf','shiftvariantpsf'}
        % The precomputed shift-variant psfs
        oi.psf.psf = val;
    case {'psfanglestep','psfsampleangles'}
        % Vector of sample angles  
        oi.psf.sampAngles= val;
    case {'psfopticsname','raytraceopticsname'}
        % Name of the optics data are derived from
        oi.psf.opticsName =val;
    case 'psfimageheights'
        % Vector of sample image heights
        oi.psf.imgHeight = val;
    case 'psfwavelength'
        % Wavelengths for this calculation. Should match the optics, I
        % think.  Not sure why it is duplicated.
        oi.psf.wavelength = val;

    case 'depthmap'
        % Depth map, usuaully inherited from scene, in meters
        % oiSet(oi,'depth map',dMap);
        oi.depthMap = val;
        
    otherwise
        error('Unknown oiSet parameter: %s',parm);
end

return;
