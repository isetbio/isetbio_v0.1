function scene = sceneAdjustLuminance(scene,meanL)
% Scale scene mean luminance to meanL
%
%   scene = sceneAdjustLuminance(scene,meanL)
%
% The photon level in the scene structure is multiplied so that the  mean
% luminance level is meanL, rather than the current level. The illuminant
% is also scaled to preserve the reflectance.
% 
%Example:
%   scene = vcGetObject('scene');
%   scene = sceneAdjustLuminance(scene,100);  % Set to 100 cd/m2.
%
% Copyright ImagEval Consultants, LLC, 2003.

% Verify that current luminance exists, or calculate it
currentMeanL  = sceneGet(scene,'mean luminance');
photons       = sceneGet(scene,'photons');

try
    photons   = photons*(meanL/currentMeanL);
catch err
    % Probably the data are too big for memory.  So scale the photons
    % one waveband at a time.
    nWave = sceneGet(scene,'wave');
    for ii=1:nWave
        photons(:,:,ii) = photons(:,:,ii)*(meanL/currentMeanL);
    end
end

% We scale the photons and the illuminant data by the same amount to keep
% the reflectances in 0,1 range.
scene      = sceneSet(scene,'photons',photons);
illuminant = sceneGet(scene,'illuminant photons');
illuminant = illuminant*(meanL/currentMeanL);
scene      = sceneSet(scene,'illuminant photons',illuminant);

return;