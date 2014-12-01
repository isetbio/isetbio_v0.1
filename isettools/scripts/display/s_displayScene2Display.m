%% s_displayScene2Display
%
%  This script illustrates how to convert data in a scene into a set of RGB
%  values for a particular display.
%
% (BW) Stanford Vista Group, 2014

%% Programming:  See TODO below

%% 
s_initISET

%% Make a MCC scene, the default

scene = sceneCreate;
% vcAddObject(scene); sceneWindow;

XYZ = sceneGet(scene,'xyz');
vcNewGraphWin;  image(xyz2srgb(XYZ));
title('Original scene')

%% Create a display

d = displayCreate('LCD-Apple');

% Transforms to linear rgb values (no gamma accounted for)
rgb2xyz = displayGet(d,'rgb2xyz');
xyz2rgb = inv(rgb2xyz);
lrgb = imageLinearTransform(XYZ,xyz2rgb);
% vcNewGraphWin; imagescRGB(lrgb);

% The values can be out of gamut.  So we adjust by clipping and scaling
lrgb = ieClip(lrgb,0,[]);
lrgb = ieScale(lrgb,0,1);

srgb = lrgb2srgb(lrgb);
% vcNewGraphWin; imagescRGB(srgb);

%%
dImage = displayCompute(d,srgb);
vcNewGraphWin; imagescRGB(dImage); title('Display showing subpixel')

%% Now move the dImage back to a scene, as per the script s_display2Scene

% TO DO

%%