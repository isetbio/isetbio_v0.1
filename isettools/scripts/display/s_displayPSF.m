%% s_displayPSF
%
% HJ is updating the display structure calls to account for display point
% spread functions.  The purpose of the updated structures is to allow us
% to have more spatially accurate descriptions of the display spectral
% radiance.
%
% This script is a includes material about the PSF calculations in the new
% display structure.
%
% (BW) May 2014

%%
s_initISET

%% Make a harmonic image for a display with a psf

I = 0.5*(sin(2*pi*(1:32)/32)+1); I = repmat(I,32,1);
[outImage, d] = displayCompute('LCD-Apple', I);
vcNewGraphWin; imagescRGB(outImage);

%%  Show the display psfs
psf = displayGet(d,'psf');
vcNewGraphWin([],'tall');
for ii=1:3, subplot(3,1,ii), mesh(psf(:,:,ii)); end

%%  Now, replace the psfs with a different shape

for ii=1:3
    psf(:,:,ii) = psf(:,:,ii)';
end
d2 = displaySet(d,'psf',psf);

psf = displayGet(d2,'psf');
vcNewGraphWin([],'tall');
for ii=1:3, subplot(3,1,ii), mesh(psf(:,:,ii)); end

%%  Recompute the same scene, but with a different psf for the display

outImage = displayCompute(d2, I);
vcNewGraphWin; imagescRGB(outImage);


%% Now do a similar calculation using some of the ISET tools
imSize = [32 32];
scene = sceneCreate('slanted bar',imSize);
I = sceneGet(scene,'rgb');
vcNewGraphWin; imagescRGB(I);

vcNewGraphWin; imagescRGB(displayCompute(d, I));
vcNewGraphWin; imagescRGB(displayCompute(d2, I));

%% Convert the display image into a scene data set
d = displaySet(d,'wave',sceneGet(scene,'wave'));

% Compute the high resolution display image
dRGB = displayCompute(d, I);
[dRGB,r,c] = RGB2XWFormat(dRGB);
spd  = displayGet(d,'spd');
wave = displayGet(d,'wave');

energy = dRGB*spd';
energy = XW2RGBFormat(energy,r,c);
p = Energy2Quanta(wave,energy);
scene = sceneSet(scene,'cphotons',p);

% Adjust luminance to maximum Y value of display, but divided by 2 because
% half the scene is black
wp = displayGet(d,'white point');
scene = sceneAdjustLuminance(scene,wp(2)/2);

%% Adjust the spatial parameters of the scene to match the display resolution

dist = 0.5;
scene = sceneSet(scene,'distance',dist);
dpi   = displayGet(d,'dpi');
% Scene width in meters
sceneWidth = dpi2mperdot(dpi,'meters')*imSize(2);
fov = rad2deg(atan2(sceneWidth,dist));
scene = sceneSet(scene,'fov',fov);

vcAddObject(scene);
sceneWindow;


%%
oi = oiCreate('human');
oi = oiCompute(oi,scene); 
vcAddObject(oi); oiWindow;

sensor = sensorCreate('human');
sensor = sensorSet(sensor,'exp time',0.1);
sensor = sensorCompute(sensor,oi);
vcAddObject(sensor); sensorWindow('scale',1);

%% End