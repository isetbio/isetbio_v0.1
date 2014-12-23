%% t_displayResolution
%
% Introduction to ISETBIO objects and functions:  
%   Controlling the display spatial resolution and examining effects of the
%   subpixel
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
vcAddObject(d); displayWindow;

%% Create scene from image and display
%  create scene by specifying image on display
%
%  only static image is supported
%  some sample image files are stored in
%    ISETBIO_ROOT_PATH/isettools/data/images/rgb/
% I = im2double(imread('eagle.jpg'));
% scene = sceneFromFile(I, 'rgb', [], d);  % The display is included here
% vcAddObject(scene); sceneWindow;


% Create a low resolution colorful scene
scene = sceneCreate;
scene = sceneInterpolate(scene,[0.25 0.25]);
vcAddObject(scene); sceneWindow;


%% Subpixel rendering
%  render with subpixel structure
%  subpixel rendering will up-sample the image. So the input image cannot
%  be too large (no more than 100x100)
% I_small = imresize(I, [34 52]);
% I_small(I_small < 0) = 0; I_small(I_small > 1) =1;

I_small = sceneGet(scene,'rgb');
meanLum = sceneGet(scene,'mean luminance');

%
waveList = []; 
% meanLum = [];
il = [];      % The default is the sum of the primaries at max

% The default size is given by the pixel intensity map.
% This can take a minute for the highest spatial sampling rate
% sz = displayGet(d,'dixel size');
doSub = true;   % Turn subpixel rendering on
scene = sceneFromFile(I_small, 'rgb', meanLum, d, waveList, doSub, il);
scene = sceneSet(scene,'Name','Full sampling');
vcAddObject(scene); sceneWindow;

%%  Reduce the sampling rate

% This will take less time
sz = displayGet(d,'dixel size')/4;
scene = sceneFromFile(I_small, 'rgb', meanLum, d, waveList, doSub, il, sz);
scene = sceneSet(scene,'Name','Quarter sampling');
vcAddObject(scene); sceneWindow;

%% RGBW display
%  This section creates a four primary display
d = displayCreate('LCD-Samsung-RGBW');
vcAddObject(d); displayWindow;
scene = sceneFromFile(I, 'rgb', [], d);
vcAddObject(scene); sceneWindow;

%% End