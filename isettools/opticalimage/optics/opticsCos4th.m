function oi = opticsCos4th(oi)
% Compute relative illumination for cos4th model
%
%    oi = opticsCos4th(oi)
%
% This routine is used for shift-invariant optics, when full ray trace
% information is unavailable.
%
% Copyright ImagEval Consultants, LLC, 2003.

% Setting up local variables
wavelength = oiGet(oi,'wavelength');
nWaves = oiGet(oi,'nWaves');
sz = oiGet(oi,'size');
photons = zeros(sz(1),sz(2),nWaves);

optics = oiGet(oi,'optics');

method = opticsGet(optics,'cos4thfunction');
if isempty(method), method = 'cos4th'; end

% Calculating the cos4th scaling factors
% We might check whether it exists already and only do this if
% the cos4th slot is empty.
optics = feval(method, optics, oi);
% figure; mesh(optics.cos4th.value)
oi = oiSet(oi,'optics',optics);

% Applying cos4th scaling.
% This loops on the stored compressed data, saving a little memory space.
sFactor = opticsGet(optics,'cos4thData');  % figure(3); mesh(sFactor)
for ii=1:nWaves
    % Get one waveband of the irradiance image and calculate.
    irradianceImage = oiGet(oi,'photons',wavelength(ii));
    photons(:,:,ii) = irradianceImage .* sFactor;
end

% Compress the calculated image and put it back in the structure.
oi = oiSet(oi,'cphotons',photons); 

return;

