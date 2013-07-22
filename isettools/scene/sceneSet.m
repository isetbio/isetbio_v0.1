function scene = sceneSet(scene,parm,val,varargin)
%Set ISET scene parameter values
%
%   scene = sceneSet(scene,parm,val,varargin)
%
%  All of the parameters of a scene structure are set through the calls to
%  this routine.
%
%  The scene is the object; parm is the name of the parameter; val is the
%  value of the parameter; varargin allows some additional parameters in
%  certain cases.
%
%  There is a corresponding sceneGet routine.  Many fewer parameters are
%  available for 'sceneSet' than 'sceneGet'. This is because many of the
%  parameters derived from sceneGet are derived from the few parameters
%  that can be set, and sometimes the derived quantities require some
%  knowledge of the optics as well.
%
%  Examples:
%    scene = sceneSet(scene,'name','myScene');      % Set the scene name
%    scene = sceneSet(scene,'fov',3);               % Set scene field of view to 3 deg
%    oi = sceneSet(oi,'optics',optics);
%    oi = sceneSet(oi,'oicomputemethod','myOIcompute');
%
% Scene description
%      {'name'}          - An informative name describing the scene
%      {'type'}          - The string 'scene'
%      {'distance'}      - Object distance from the optics (meters)
%      {'wangular'}      - Width (horizontal) field of view
%      {'magnification'} - Always 1 for scenes.
%
% Scene radiance
%      {data}   - structure containing the data
%        {'cphotons','compressedphotons'}
%         row x col x nwave array representing the radiance photons.
%           Data are compressed to 16 bits over a range determined by the
%           min and max levels of the data. Normally, we use this field to
%           save space.
%        {'photons','uncompressedphotons'}
%         row x col x nwave array representing the radiance photons
%        {'peak photon radiance'} - Used for monochromatic scenes mainly; not a
%            variable, but a function
%
%         N.B. After writing to the 'photons' or 'cphotons' field, you
%         should probably adjust the luminance and mean luminance fields
%         are set to empty. To fill them properly, you can call 
%            [lum, meanL] = sceneCalculateLuminance(scene);
%            scene = sceneSet(scene,'luminance',lum);
%            note that you cannot set meanL using sceneSet
%               use sceneAdjustLuminance
%  Depth
%
%      {'depthMap'} - Stored in meters.  Used with RenderToolbox
%      synthetic scenes.  (See scene3D pdcproject directory).
%
% Scene color information
%      {'spectrum'}   - structure that contains wavelength information
%        {'wavelength'} - Wavelength sample values (nm)
%
% Some multispectral scenes have information about the illuminant
%     {'illuminant'}  - Scene illumination structure
%      {'illuminant Energy'}  - Illuminant spd in energy is stored W/sr/nm/sec
%      {'illuminant Photons'} - Photons are converted to energy and stored 
%      {'illuminant Comment'} - Comment
%      {'illuminant Name'}    - Identifier for illuminant.
%         See sceneIlluminantScale() for setting the illuminant level in
%         certain cases of unknown reflectance and illuminant conditions.
%         Though, this is being deprecated.
%
% Private variables used by ISET but not set by the user
%
%    Used for management of compressed photons
%      {'datamin'}
%      {'datamax'}
%      {'bitdepth'}
%      {'knownReflectance'} - For scenes when a reflectance is known
%                             (reflectance,i,j,w)
%
%    Used to store the scene luminance rather than recompute (i.e., cache)
%      {'luminance'}
%      {'meanluminance'}
%
%      {'consistency'} - Display consistent with window data
%
% (The list of scene parameters includes aliases for the same parameter.)
%
% Copyright ImagEval Consultants, LLC, 2003.

if ~exist('parm','var') || isempty(parm), error('Param must be defined.'); end
if ~exist('val','var'), error('Value field required.'); end  % empty is OK

parm = ieParamFormat(parm);

switch parm 
    case {'name','scenename'}
        scene.name = val;
    case 'type'
        scene.type = val;
    case {'filename'}
        % When the data are ready from a file, we may save the file name.
        % Happens, perhaps, when reading multispectral image data.
        % Infrequently used.
        scene.filename = val;
    case {'consistency','computationalconsistency'}
        % When parameters are changed, the consistency flag on the optical
        % image changes.  This is irrelevant for the scene case.
        scene.consistency = val;
        
    case {'distance' }
        % Positive for scenes, negative for optical images
        scene.distance = val;

    case {'wangular','widthangular','hfov','horizontalfieldofview','fov'}
        if val > 180, val = 180 - eps; warndlg('Warning: fov > 180');
        elseif val < 0, val = eps; warndlg('Warning fov < 0');
        end
        scene.wAngular = val;

    case 'magnification'
        % Scenes should always have a magnification of 1.
        if val ~= 1, warndlg('Scene must have magnification 1'); end
        scene.magnification = 1;

    case {'data','datastructure'}
        scene.data = val;
        
    case {'photons','cphotons','compressedphotons'}
        % sceneSet(scene,'photons',val,[which wave])
        % val is typically a 3D (row,col,wave) matrix.
        bitDepth = sceneGet(scene,'bitDepth');
        if isempty(bitDepth), error('Compression parameters not set up.'); end
        if isempty(varargin)
            % Insert the whole photon data set
            % scene = sceneSet(scene,'cphotons',data);
            [scene.data.photons,mn,mx] = ieCompressData(val,bitDepth);
            scene = sceneSet(scene,'datamin',mn);
            scene = sceneSet(scene,'datamax',mx);
            % scene = sceneSet(scene,'bitDepth',bitDepth);
        elseif length(varargin) == 1
            % Insert data from one wavelength plane.
            % scene = sceneSet(scene,'cphotons',data,wavelength);

            % When we put in the data at a single wavelength, we must use
            % the fixed datamax and datamin.
            mx = sceneGet(scene,'datamax');
            mn = sceneGet(scene,'datamin');

            idx = ieFindWaveIndex(sceneGet(scene,'wave'),varargin{1});
            % If we are changing just one wavelength, we might be violating
            % the mn,mx range.  Warn the user.  After this error, they
            % should set the photons using all wavelengths, which will
            % reset the mn and mx.
            if min(val(:)) < mn 
                error('Min data out of range.  Insert full set.')
            elseif max(val(:)) > mx  
                error('Max data out of range.  Insert full set.')
            end
            scene.data.photons(:,:,idx) = ieCompressData(val,bitDepth,mn,mx);
        end

        % Clear out derivative luminance/illuminance computations
        scene = sceneSet(scene,'luminance',[]);

    case 'energy'
        % scene = sceneSet(scene,'energy',energy,wave);
        % 
        % The user specified the scene in units of energy.  We convert to
        % photons and set the data as compressed photons for them.
        %
        wave = sceneGet(scene,'wave');
        photons = zeros(size(val));
        [r,c,w] = size(photons);
        if w ~= length(wave), error('Data mismatch'); end
        
        % h = waitbar(0,'Energy to photons');
        for ii=1:w
            % waitbar(ii/w,h);           
            % Get the first image plane from the energy hypercube.
            % Make it a row vector
            tmp = val(:,:,ii); tmp = tmp(:)';
            % Convert the rwo vector from energy to photons
            tmp = Energy2Quanta(wave(w),tmp);
            % Reshape it and place it in the photon hypercube
            photons(:,:,ii) = reshape(tmp,r,c);
        end
        % close(h);
        scene = sceneSet(scene,'cphotons',photons);

    case {'peakradiance','peakphotonradiance'}
        % Used with monochromatic scenes to set the radiance in photons.
        % scene = sceneSet(scene,'peak radiance',1e17);
        oldPeak = sceneGet(scene,'peak radiance');
        p  = sceneGet(scene,'photons');
        scene = sceneSet(scene,'cphotons',val*(p/oldPeak));
    case {'peakenergyradiance'}
        % As above, but for energy.  Useful for equating energy in a series
        % of monochromatic images.
        error('Peak energy radiance not yet implemented');
    case {'depthmap'}
        % Depth map is always in meters
        scene.depthMap = val;
        
    case {'datamin','dmin'}
        % These are photons (radiance)
        scene.data.dmin = val;
    case {'datamax','dmax'}
        % These are photon (radiance)
        scene.data.dmax = val;
    case 'bitdepth'
        scene.data.bitDepth = val;
        % scene = sceneClearData(scene);
        
        % Not sure this is used much or at all any more.  It is in
        % sceneIlluminantScale alone, as far as I can tell. - BW
    case 'knownreflectance'
        % We  store a known reflectance at location (i,j) for wavelength
        % w. This information is used to set the illuminant level properly
        % and to keep track of reflectances.
        if length(val) ~= 4 || val(1) > 1 || val(1) < 0
            error('known reflectance is [reflectance,row,col,wave]'); 
        end
        scene.data.knownReflectance = val;

    case {'luminance','lum'}
        % The value here is stored to make computation efficient.  But it
        % is dangerous because this value could be inconsistent with the
        % photons if we are not careful.
        if strcmp(sceneGet(scene,'type'),'scene'), scene.data.luminance = val;
        else error('Cannot set luminance of a non-scene structure.');
        end
    case {'meanluminance','meanl'}
        % This leaves open the possibility that the mean differs from the
        % mean calculated from the real luminance data.  We should probably
        % have this set by a sceneAdjustLuminance() call.
        scene = sceneAdjustLuminance(scene,val);
        scene.data.meanL = val;
        % Get this working
    case {'spectrum','wavespectrum','wavelengthspectrumstructure'}
        scene.spectrum  = val;
        %     case {'binwidth','wavelengthspacing'}
        %         scene.spectrum.binwidth = val;
    case {'wave','wavelength','wavelengthnanometers'}
        % We should probably check that val is a proper set of wavelength
        % values that make sense ... unique, evenly spaced, stuff like
        % that.

        % We need to deal with data, spectrum, and illuminant
        scene = sceneInterpolateW(scene,val);
        
        % Scene illumination information
    case {'illuminant'}
        % The whole structure
        scene.illuminant = val;
    case {'illuminantdata','illuminantenergy'}
        % This set changes the illuminant, but it does not change the
        % radiance SPD.  Hence, changing the illuminant (implicitly)
        % changes the reflectance. This might not be what you want.  If you
        % want to change the scene as if it is illuminanted differently,
        % use the function: sceneAdjustIlluminant()
        
        % The data are stored in energy  units, unfortunately The data can
        % be a vector (one SPD for the whole image) or they can be a RGB
        % format SPD with a different illuminant at each position.
        illuminant = sceneGet(scene,'illuminant');
        illuminant = illuminantSet(illuminant,'energy',val);
        scene = sceneSet(scene,'illuminant',illuminant);
        % scene.illuminant = illuminantSet(scene.illuminant,'energy',val(:));
    case {'illuminantphotons'}
        % See comment above about sceneAdjustIlluminant.
        %
        % sceneSet(scene,'illuminant photons',data)
        %
        % We have to handle the spectral and the spatial spectral cases
        % within the illuminantSet.  At this point, val can be a vector or
        % an RGB format matrix.
        if checkfields(scene,'illuminant')
            scene.illuminant = illuminantSet(scene.illuminant,'photons',val);
        else
            % We use a default d65.  The user must change to be consistent
            wave = sceneGet(scene,'wave');
            scene.illuminant = illuminantCreate('d65',wave);
            scene.illuminant = illuminantSet(scene.illuminant,'photons',val);
        end
    case {'illuminantname'}
        scene.illuminant = illuminantSet(scene.illuminant,'name',val);
    case {'illuminantwave'}
        error('Call scene set wave, not illuminant wave');
    case {'illuminantcomment'}
        scene.illuminant.comment = val;
    case {'illuminantspectrum'}
        scene.illuminant.spectrum = val;
        
    otherwise
        disp(['Unknown sceneSet parameter: ',parm]);
end

return;
