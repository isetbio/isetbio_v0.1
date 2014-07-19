% s_sceneExamples
%
% Illustrate the types of synthetic scenes. These synthetic scenes are
% useful for testing different features of the optics and sensors.
%
% See also:  s_sceneDemo, sceneCreate, s_sceneFromMultispectral, s_sceneFromRGB
%
% Copyright ImagEval Consultants, LLC, 2003.

%% Initialize ISET
%
% This clears the workspace and hides the main ISET window
s_initISET
disp('Testing scene creation.  Some scenes are not displayed ...');

%% Rings and Rays
radF = 24; imSize = 512;
scene = sceneCreate('mackay',radF,imSize);
scene = sceneCreate('rings rays');
vcAddAndSelectObject(scene); sceneWindow;

%% Frequency orientation - useful for analyzing demosaicking

parms.angles = linspace(0,pi/2,5);
parms.freqs  =  [1,2,4,8,16];
parms.blockSize = 64;
parms.contrast  = .8;
scene = sceneCreate('frequency orientation',parms);
vcAddAndSelectObject(scene); sceneWindow;

%% Harmonic
parms.freq = 1; parms.contrast = 1; parms.ph = 0;
parms.ang= 0; parms.row = 64; parms.col = 64; parms.GaborFlag=0;
[scene,parms] = sceneCreate('harmonic',parms);
vcAddAndSelectObject(scene); sceneWindow;

%% Checkerboard
period = 16; spacing = 8; spectralType = 'ep';
scene = sceneCreate('checkerboard',period,spacing,spectralType);
vcAddAndSelectObject(scene); sceneWindow;

%% Single line
imageSize = 128; 
scene = sceneCreate('lined65',imageSize);
vcAddAndSelectObject(scene); sceneWindow;

%% Slanted Bar
imageSize = 128;
edgeSlope = 1.3;
scene = sceneCreate('slantedBar',imageSize,edgeSlope);
vcAddAndSelectObject(scene); sceneWindow;

%% Grid Lines
imageSize = 128;
pixelsBetweenLines = 16;
scene = sceneCreate('grid lines',imageSize,pixelsBetweenLines);
% vcAddAndSelectObject(scene); sceneWindow;

%% Point Array
imageSize = 256;
pixelsBetweenPoints = 32;
scene = sceneCreate('point array',imageSize,pixelsBetweenPoints);
vcAddAndSelectObject(scene); sceneWindow;

%% Macbeth
patchSizePixels = 16;
spectrum.wave = 380:5:720;
scene = sceneCreate('macbeth tungsten',patchSizePixels,spectrum);
scene.data;
scene = sceneCreate('macbeth tungsten',patchSizePixels,spectrum,'bitdepth',32);
scene.data;
vcAddAndSelectObject(scene); sceneWindow;

%% Uniform Field
sz = 128;
wavelength = 380:10:720;
scene = sceneCreate('uniformEESpecify',sz,wavelength);
vcAddAndSelectObject(scene); sceneWindow;

%% End
