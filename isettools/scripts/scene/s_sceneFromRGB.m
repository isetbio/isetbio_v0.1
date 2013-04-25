% s_sceneFromRGB
%
% We can read an RGB file and a display calibration file to produce the
% display scene accurately.
%
%  The gamma function of the display is not included.
%  The mean luminance isn't handled properly in the presence of a cal file.
%
% Copyright ImagEval, 2011

%%
s_initISET

%% An example RGB file with calibration
% rgbFile = fullfile(isetRootPath,'data','images','rgb','hats.jpg');
rgbFile = fullfile(isetRootPath,'data','images','rgb','eagle.jpg');

displayCalFile = 'LCD-Apple.mat';
% load(displayCalFile,'d'); dsp = d;
% wave = displayGet(dsp,'wave');
% spd = displayGet(dsp,'spd'); 
% vcNewGraphWin; plot(wave,spd); 
% xlabel('Wave (nm)'); ylabel('Energy'); grid on
scene = sceneFromFile(rgbFile,'rgb',[],displayCalFile);

% Show the scene.
vcAddAndSelectObject(scene); sceneWindow

%% Investigate the display properties: Chromaticity

d = displayCreate(displayCalFile);
whtSPD = displayGet(d,'white spd');
wave   = displayGet(d,'wave');
whiteXYZ = ieXYZFromEnergy(whtSPD',wave);
% Includes its own vcNewGraphWin
fig = chromaticityPlot(chromaticity(whiteXYZ));

%% SPD graph
spd = displayGet(d,'spd');
vcNewGraphWin;
plot(wave,spd(:,1),'-r',...
    wave,spd(:,2),'-g',...
    wave,spd(:,3),'-b')
grid on;
xlabel('Wavelength (nm)')
ylabel('Energy (watts/sr/nm/sec)')
title('Display primaries')

%% Change the illuminant to 6500 K
bb = blackbody(sceneGet(scene,'wave'),6500,'energy');
scene = sceneAdjustIlluminant(scene,bb);

% Show the scene.
vcAddAndSelectObject(scene); sceneWindow

%% End