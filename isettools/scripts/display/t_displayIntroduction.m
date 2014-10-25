%% t_displayIntroduction
%
% Introduction to ISETBIO objects and functions:  display
%
%  (HJ) ISETBIO TEAM

%% Initialize ISET
s_initISET;

%% Create a display
%  create a default display
%  Other displays can also be created by specifying the calibration file
%  name
%  Example:
%    d = displayCreate('LCD-Apple');
%    d = displayCreate('OLED-Sony');
%    d = displayCreate('CRT-Dell');
%  Calibration files are stored in 
%       ISETBIO_ROOT_PATH/isettools/data/displays/
d = displayCreate('OLED-Samsung');

%% Show default image and GUI
%  show display structure in a GUI window
vcAddObject(d); displayWindow;

%% Get and Set methods
%  get and set parameters for display
%
%  More parameters can be found in displayGet and displaySet
displayGet(d, 'name');
displayGet(d, 'gamma table');
displayGet(d, 'white xyz');
displayGet(d, 'primaries xyz');
displayGet(d, 'rgb2xyz');

d = displaySet(d, 'name', 'my display');
d = displaySet(d, 'dpi', 150);

%% Plot for display basics
%  plot for display primaries spd, gamma table, etc.
%
%  More plot options can be found in displayPlot
displayPlot(d, 'spd'); % spectral power distribution
displayPlot(d, 'gamma'); % gamma table
displayPlot(d, 'gamut');

%% Create scene from image on display
%  create scene by specifying image on display
%
%  only static image is supported
%  some sample image files are stored in
%    ISETBIO_ROOT_PATH/isettools/data/images/rgb/
I = im2double(imread('eagle.jpg'));
scene = sceneFromFile(I, 'rgb', [], d);

vcAddObject(scene); sceneWindow;

%% Subpixel rendering
%  render with subpixel structure
%  subpixel rendering will up-sample the image. So the input image cannot
%  be too large (no more than 100x100)
I_small = imresize(I, [34 52]);
I_small(I_small < 0) = 0; I_small(I_small > 1) =1;
doSub = true;
waveList = []; meanLum = [];
scene = sceneFromFile(I_small, 'rgb', meanLum, d, waveList, doSub);

vcAddObject(scene); sceneWindow;

%  change sampling rate
il = []; sz = [20 20];
scene = sceneFromFile(I_small, 'rgb', [], d, [], doSub, il, sz);

vcAddObject(scene); sceneWindow;

%% RGBW display
%  This section creates a four primary display
d = displayCreate('LCD-Samsung-RGBW');
vcAddObject(d); displayWindow;
scene = sceneFromFile(I, 'rgb', [], d);
vcAddObject(scene); sceneWindow;