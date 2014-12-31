%% s_display2Scene
%
% Convert a display image into an ISET scene
%
% HJ is updating the display structure calls to account for display point
% spread functions.  The purpose of the updated structures is to allow us
% to have more spatially accurate descriptions of the display spectral
% radiance.
%
% (BW) May 2014

%% 
s_initISET

%% Create a scene
imSize = [32,32]; scene = sceneCreate('slanted bar',imSize);

%% Initialize a display
d  = displayCreate('LCD-Apple');
d = displaySet(d,'wave',sceneGet(scene,'wave'));

%% Compute the high resolution display image
dRGB       = displayCompute(d, sceneGet(scene,'rgb'));
[dRGB,r,c] = RGB2XWFormat(dRGB);
spd  = displayGet(d,'spd');
wave = displayGet(d,'wave');

% Convert the display radiance (energy) to photons
energy = dRGB*spd';
energy = XW2RGBFormat(energy,r,c);
p = Energy2Quanta(wave,energy);
scene = sceneSet(scene,'cphotons',p);   % Compressed photons
% vcAddObject(scene); sceneWindow;

%% Adjust the scene to match the display resolution

% Adjust luminance to maximum Y value of display, but divided by 2 because
% half the scene is black
wp = displayGet(d,'white point');
scene = sceneAdjustLuminance(scene,wp(2)/2);

dist = 0.5;
scene = sceneSet(scene,'distance',dist);
dpi   = displayGet(d,'dpi');

% Calculate scene width in meters
sceneWidth = dpi2mperdot(dpi,'meters')*imSize(2);
fov = rad2deg(atan2(sceneWidth,dist));
scene = sceneSet(scene,'fov',fov);

% Show it
vcAddObject(scene);
sceneWindow;


%%  Render the display on the cone photoreceptor mosaic

% Human optics
oi = oiCreate('human');
oi = oiCompute(oi,scene); 
vcAddObject(oi); oiWindow;

% Human retina
sensor = sensorCreate('human');
sensor = sensorSet(sensor,'exp time',0.1);
sensor = sensorSetSizeToFOV(sensor,sceneGet(scene,'fov'),scene,oi);
sensor = sensorCompute(sensor,oi);
vcAddObject(sensor); sensorWindow('scale',1);

%% End