function oi = opticsSICompute(scene,oi)
%Calculate OI irradiance using a custom shift-invariant PSF
%
%    oi = opticsSICompute(scene,oi)
%
% See also: opticsRayTrace, oiCompute, opticsOTF
%
% Example
%    scene = vcGetObject('scene');
%    oi    = vcGetObject('oi');
%    
% Copyright ImagEval Consultants, LLC, 2005

if ieNotDefined('scene'), error('Scene required.'); end
if ieNotDefined('oi'), error('Opticalimage required.'); end

% This is the default compute path
optics = oiGet(oi,'optics');

% Compute the basic parameters of the oi from the scene parameters.
oi = oiSet(oi,'wangular',sceneGet(scene,'wangular'));
oi = oiSet(oi,'spectrum',sceneGet(scene,'spectrum'));

if isempty(opticsGet(optics,'otfdata')), error('No psf data'); end

% We use the custom data.
optics = opticsSet(optics,'spectrum',oiGet(oi,'spectrum'));
oi     = oiSet(oi,'optics',optics);

% Convert radiance units to optical image irradiance (photons/(s m^2 nm))
%wBar = waitbar(0,'OI-SI: Calculating irradiance...');
% wStr = 'OI-SI: ';
% wBar = waitbar(0,[wStr,' Calculating irradiance...']);
oi = oiSet(oi,'cphotons',oiCalculateIrradiance(scene,optics));

%-------------------------------
% Distortion would go here. If we included it.
%-------------------------------

% waitbar(0.3,wBar,[wStr,' Calculating off-axis falloff']);

% Now apply the relative illumination (offaxis) fall-off
% We either apply a standard cos4th calculation, or we skip.
%waitbar(0.3,wBar,'OI-SI: Calculating off-axis falloff');
offaxismethod = opticsGet(optics,'offaxismethod');
switch lower(offaxismethod)
    case {'skip','none',''}
    case 'cos4th'
        oi = opticsCos4th(oi);
    otherwise
        fprintf('\n-----\nUnknown offaxis method: %s.\nUsing cos4th.',optics.offaxis);
        oi = opticsCos4th(oi);
end

% waitbar(0.6,wBar,'OI-SI: Applying OTF');
% This section applys the OTF to the scene radiance data to create the
% irradiance data.
%
% If there is a depth plane in the scene, we also blur that and put the
% 'blurred' depth plane in the oi structure.
%  waitbar(0.6,wBar,[wStr,' Applying OTF-SI']);
oi = opticsOTF(oi,scene);

switch lower(oiGet(oi,'diffuserMethod'))
    case 'blur'
       % waitbar(0.75,wBar,'OI-SI: Diffuser');
        blur = oiGet(oi,'diffuserBlur','um');
        if ~isempty(blur), oi = oiDiffuser(oi,blur); end
    case 'birefringent'
       % waitbar(0.75,wBar,'OI-SI: Birefringent Diffuser');
        oi = oiBirefringentDiffuser(oi);
    case 'skip'
        
end

% Compute image illuminance (in lux)
% oi.data.illuminance = oiCalculateIlluminance(oi);
%waitbar(0.9,wBar,'OI: Calculating illuminance');
%  waitbar(0.9,wBar,[wStr,' Calculating illuminance']);
oi = oiSet(oi,'illuminance',oiCalculateIlluminance(oi));

%  delete(wBar);

return;

