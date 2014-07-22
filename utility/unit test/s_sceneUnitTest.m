%% s_sceneUnitTest
%
% Test scene related functions
%
% See also: 
%   sceneCreate, sceneGet, sceneSet, sceneFromFile, sceneFromFont
%
% (HJ) ISETBIO TEAM, 2014

%% Initialize ISET
% This clears the workspace and hides the main ISET window
s_initISET

%% Scene create
fprintf('Start testing scene creation...\n');

% Creat default scene
sceneCreate;

% Macbeth
patchSizePixels = 16; spectrum.wave = 400:10:700;
sceneCreate('macbeth tungsten', patchSizePixels, spectrum);
sceneCreate('macbeth tungsten', patchSizePixels, spectrum, 'bitdepth', 32);

% Reflectance chart
sceneCreate('reflectance chart');

% l-star
sceneCreate('lstar');

% Rings and Rays
radF = 24; imSize = 128;
sceneCreate('mackay', radF, imSize);
sceneCreate('rings rays');

% Frequency orientation
parms.angles = linspace(0, pi/2, 5);
parms.freqs  =  [1, 2, 4, 8, 16];
parms.blockSize = 64;
parms.contrast  = .8;
sceneCreate('frequency orientation', parms);

% Harmonic
parms.freq = 1; parms.contrast = 1; parms.ph = 0;
parms.ang= 0; parms.row = 64; parms.col = 64; parms.GaborFlag=0;
sceneCreate('harmonic', parms);

% Checkerboard
period = 16; spacing = 8; spectralType = 'ep';
sceneCreate('checkerboard',period,spacing,spectralType);

% Single line
imageSize = 64; 
sceneCreate('lined65', imageSize);

% Slanted Bar
imageSize = 64; edgeSlope = 1.3;
sceneCreate('slantedBar', imageSize, edgeSlope);

% Grid Lines
imageSize = 64; pixelsBetweenLines = 16;
sceneCreate('grid lines',imageSize,pixelsBetweenLines);

% Point Array
imageSize = 64; pixelsBetweenPoints = 8;
sceneCreate('point array', imageSize, pixelsBetweenPoints);

% Uniform Field
sz = 64; wavelength = 380:10:720;
sceneCreate('uniformEESpecify', sz, wavelength);

% vernier
sceneCreate('vernier');

% noise
sz = [64 64]; contrast = 10;
sceneCreate('noise');
sceneCreate('noise', sz, contrast);

% sceneFromFile
I = rand(64); d = displayCreate('LCD-Apple'); wave = 400:50:700;
sceneFromFile(I, 'rgb', [], d);
sceneFromFile(I, 'rgb', 50, d, wave);
fullFileName = fullfile(isetRootPath, 'data', 'images', ...
                        'multispectral', 'StuffedAnimals_tungsten-hdrs');
sceneFromFile(fullFileName,'multispectral',[],[],wave);

% sceneFromFont
font = fontCreate;
sceneFromFont(font, d);

% moireorient
% This will break, sadly. Should fix it.
parms.angles = linspace(0,pi/2,5); parms.freqs =  [1,2,4,8,16];
parms.blockSize = 64; parms.contrast = .8;
% sceneCreate('moire orient',parms);

%% Scene Set
%  Here, we just set the parameters, but not set it back to scene
scene = sceneCreate;

% name
sceneSet(scene, 'name', 'new name');

% distance
dist = 2;
sceneSet(scene, 'distance', dist);

% bit-depth
sceneSet(scene, 'bitdepth', 64);

% wave
sceneSet(scene, 'wave', 400:20:700);


%% Scene Get
scene = sceneCreate;
sceneGet(scene, 'name');
sceneGet(scene, 'type');
sceneGet(scene, 'energy');
sceneGet(scene, 'photons');
sceneGet(scene, 'wave');
sceneGet(scene, 'n wave');
sceneGet(scene, 'distance');
sceneGet(scene, 'size');
sceneGet(scene, 'h fov');
sceneGet(scene, 'luminance');
sceneGet(scene, 'rows');
sceneGet(scene, 'cols');
sceneGet(scene, 'frequency resolution');
sceneGet(scene, 'frequency support');

fprintf('Success...\n');