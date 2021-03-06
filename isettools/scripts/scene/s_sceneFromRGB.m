%% s_sceneFromRGB
%
% This script illustrates how ISET can create a scene from an rgb data file
% using the sceneFromFile function. The user can then change the scene
% illuminant.
%
% sceneFromFile uses 1) the rgb data and the spectral power distributions
% (spds) of the display color primaries to calculate the spectral radiance
% of the displayed image, and 2) the spectral power distribution of
% the display white point as an estimate of the scene illuminant
%
% For this example, the gamma function of the display is not used.
%
% Copyright ImagEval, 2011

%%
s_initISET

%% Load display calibration data
%
displayCalFile = 'LCD-Apple.mat';
load(displayCalFile,'d'); dsp = d;
wave = displayGet(dsp,'wave');
spd = displayGet(dsp,'spd'); 
vcNewGraphWin; plot(wave,spd); 
xlabel('Wave (nm)'); ylabel('Energy'); grid on
title('Spectral Power Distribution of Display Color Primaries');

%% Analyze the display properties: Chromaticity

d = displayCreate(displayCalFile);
whtSPD = displayGet(d,'white spd');
wave   = displayGet(d,'wave');
whiteXYZ = ieXYZFromEnergy(whtSPD',wave);
% Includes its own vcNewGraphWin
fig = chromaticityPlot(chromaticity(whiteXYZ));

%% Read in an rgb file and create calibrated display values
rgbFile = fullfile(isetRootPath,'data','images','rgb','eagle.jpg');
scene = sceneFromFile(rgbFile,'rgb',[],displayCalFile);
vcAddAndSelectObject(scene); sceneWindow % Show the scene.

%% Change the illuminant to 6500 K
bb = blackbody(sceneGet(scene,'wave'),6500,'energy');
scene = sceneAdjustIlluminant(scene,bb);
vcAddAndSelectObject(scene); sceneWindow % Show the scene.

%% Notes about the method
%
% If we have display calibration data, we can accurately predict the
% radiance emitted when an image is rendered on the display. But we need a
% scene illuminant to estimate scene reflectances. We use the spectral
% power of the display whitepoint (max r, max g, max b) as an estimate of
% the scene illuminant. We then calculate reflectances of surfaces in the
% scene by dividing the scene radiance by the illuminant spd. The surface
% reflectances will not be accurate, but they will be feasible. And, more
% importantly, calculating scene reflectances makes it possible to render
% the scene under a different illuminant.
%
%% End