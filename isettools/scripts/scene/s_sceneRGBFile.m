% s_sceneRGBFile.m
%
% Calculate the radiance image generated by a displayed image
% Save the radiance image as an ISET scene

% to initialize ISET
%ISET; ieMainW('visible','off')

%%  Read an rgb image

fName = fullfile(isetRootPath,'data','images','rgb','hats.jpg');
dispFile = 'LCD-Dell.mat'; 
meanL = 50; % cd/m2
scene = sceneFromFile(fName,'rgb',meanL);
vcAddAndSelectObject(scene); sceneWindow;

%% Display characteristics

d = displayCreate(dispFile);
whtSPD = displayGet(d,'white spd');
wave   = displayGet(d,'wave');
vcNewGraphWin; plot(wave,whtSPD);
whiteXYZ = ieXYZFromEnergy(whtSPD',wave);
whitexy = chromaticity(whiteXYZ);

% chromaticityPlot(whitexy,'white',200); 

%%
d.spd = d.spd*diag([1.2 0.7 1]);
fName = fullfile(isetRootPath,'data','displays','CNI2.mat');
save(fName,'d');

fName = fullfile(isetRootPath,'data','images','rgb','hats.jpg');
dispFile = 'CNI2.mat';

scene = sceneFromFile(fName,'rgb',[],dispFile);
scene = sceneSet(scene,'fov',5);
vcAddAndSelectObject(scene); sceneWindow;

% Run the oi window and show human


%% The whole calculation from RGB to cone array

fName = fullfile(isetRootPath,'data','images','rgb','hats.jpg');
dispFile = 'CNI.mat'; meanL = 50;
scene = sceneFromFile(fName,'rgb',meanL,dispFile);
scene = sceneSet(scene,'fov',4);       % 5 deg
scene = sceneSet(scene,'distance',2);  % Two meters

% vcAddAndSelectObject(scene); sceneWindow;

%%
oi = oiCreate('human'); oi = oiCompute(scene,oi);
% vcAddAndSelectObject(oi); oiWindow;
%%
sz           = [384,384];       % Array size
densities    = [0 .6 .4 .1];   % Empty, L, M, S
coneAperture = [3 3]*10^-6;     % 3 microns
rSeed = 19;
[sensor, xy, coneType,rSeed] = ...
    sensorCreateConeMosaic(sensorCreate,sz,densities,coneAperture,rSeed);

sensor = sensorSet(sensor,'exp time',0.020);  % 20 Hz ...
sensor = sensorCompute(sensor,oi);

% vcAddAndSelectObject(sensor); sensorImageWindow;
% vcNewGraphWin; conePlot(xy,coneType);
% For computing multiple samples see sensorComputeMean and sensorComputeSamples

%%
v = sensorGet(sensor,'electrons');
vcNewGraphWin; imagesc(v)
colormap(gray(256)); axis image
