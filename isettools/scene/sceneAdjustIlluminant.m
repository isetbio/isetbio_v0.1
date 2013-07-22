function scene = sceneAdjustIlluminant(scene,illEnergy)
%Adjust the current scene illuminant to the value in data
%
%  scene = sceneAdjustIlluminant(scene,illEnergy)
%
% The scene radiance are scaled by dividing the current illuminant and
% multiplying by the illEnergy.
%
% Parameters
%  scene:      A scene structure, or the current scene will be assumed
%  illuminant: Either a file name to spectral data or a vector (same length
%    as scene wave) defining the illuminant in energy units
%
% If the current scene has no defined illuminant, we assume that it has a
% D65 illumination
%
% The scene luminance is preserved by this transformation.
%
% Example:
%    scene = sceneCreate;   % Default is MCC under D65
%    scene = sceneAdjustIlluminant(scene,'Horizon_Gretag.mat');
%    vcReplaceAndSelectObject(scene); sceneWindow;
%
%    bb = blackbody(sceneGet(scene,'wave'),3000);
%    scene = sceneAdjustIlluminant(scene,bb);
%    vcReplaceAndSelectObject(scene); sceneWindow;
%
%    bb = blackbody(sceneGet(scene,'wave'),6500,'energy');
%    figure; plot(wave,bb)
%    scene = sceneAdjustIlluminant(scene,bb);
%    vcReplaceAndSelectObject(scene); sceneWindow;
%
% Copyright ImagEval Consultants, LLC, 2010.

if ieNotDefined('scene'), scene = vcGetObject('scene'); end

% Make sure we have the illuminant data in the form of energy
wave = sceneGet(scene,'wave');
if ieNotDefined('illEnergy')
    % Read from a user-selected file
    fullName = vcSelectDataFile([]);
    illEnergy = ieReadSpectra(fullName,wave);
elseif ischar(illEnergy)
    % Read from the filename sent by the user
    fullName = illEnergy;
    if ~exist(fullName,'file'), error('No file %s\n',fullName);
    else  illEnergy = ieReadSpectra(fullName,wave);
    end
else
    % User sent numbers and we check that the vector is the right length
    fullName = '';
    if length(illEnergy) ~= length(wave)
        error('Mismatch between illuminant data and scene wave');
    end
end

% The units should be in the file, really.  But they aren't always.  So we
% check the value.
if max(illEnergy) > 10^5
    warning('Illuminant energy values are high; may be photons, not energy.')
end

% Start the conversion
curIll = sceneGet(scene,'illuminantPhotons');
if isempty(curIll)
    % We  treat this as an opportunity to create an illuminant, as in
    % sceneFromFile (or vcReadImage). Assume the illuminant is D65.  Lord
    % knows why.  Maybe we should do an illuminant estimation algorithm
    % here.
    wave   = sceneGet(scene,'wave');
    curIll = ieReadSpectra('d65',wave);   % D65 in energy units
    scene  = sceneSet(scene,'illuminant energy',curIll);   
end

% Current mean luminance will be preserved
mLum     = sceneGet(scene,'meanLuminance');

% Convert the illuminant energy to photons and find the multiplier ratio
illPhotons = Energy2Quanta(illEnergy,wave);
illFactor  = illPhotons ./ curIll;

% Adjust both the radiance data and the illuminant by the illFactor
skipIlluminant = 0;  % Don't skip changing the illuminant (do change it!)
scene = sceneSPDScale(scene,illFactor,'*',skipIlluminant);

% Make sure the mean luminance is unchanged
scene = sceneAdjustLuminance(scene,mLum);

scene = sceneSet(scene,'illuminant comment',fullName);
return;

