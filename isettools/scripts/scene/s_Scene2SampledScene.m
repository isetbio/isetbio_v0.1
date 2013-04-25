% s_Scene2SampledScene
%
% Scene data are stored in a Matlab file that contains several specific
% variables. The scene data are stored in a compact format (basis
% functions). sceneFromFile calls a routine that interprets those data
% (vcReadImage) and interprets the data: photons, illuminant,
% wavelength,comment
%
% So we need to load a scene data file and save the scene in a way that
% vcReadImage expects.
%
% See also: s_sceneCompress.m and s_sceneRender.m
%
% JEF: In the future, convert all the Hyspex scenes to the hyperspectral
% format that vcReadImage expects.
%
%      photons, illuminant, wavelength, and comment 
%  (or)
%      mcCOEF, basis, illuminant, and comment 
%
% Copyright ImagEval Consultants, LLC, 2012
%%
% Read in the old scene file
% fullFileName= fullfile(isetRootPath,'data','scenes','eye.mat');
% fullFileName= fullfile('C:\Users\joyce\Desktop\Hyperspectral MCC\Faces\FacesCloseUp\Caucasian.mat');
painting = fullfile('J:\SmallHyperspectralScenes\Paintings\SellaioFace1.mat');
load(painting);
% vcAddAndSelectObject(scene); sceneWindow

%% I must be off in the radiance values ... by a huge factor
% this is probably a mistake in interpreting the data I get from Torbjorn
% we can fix this later, but for now, let's set the light level to be something reasonable
% sceneGet(scene,'mean luminance')
scene = sceneAdjustLuminance(scene,100);   % In cd/m2

%% Create a file that can be interpeted by scenFromFile/vcReadImage

% For Matlab running 64 bit, if you have a data that is greater than 2GB
% you have to save it using the '-v7.3' switch
% this messes up the data when I read it using sceneFromFile

photons    = sceneGet(scene,'photons');
wave       = sceneGet(scene,'wave');
illuminant = sceneGet(scene,'illuminant');
comment = 'format that vcReadImage can read -- hyperspectral data with no linear model';
newFileName = fullfile('J:\SmallHyperspectralScenes\Paintings\SellaioFace1vc.mat');

% Save the scene data in a format that can be read by vcReadImage
save(newFileName,'photons','wave','comment','illuminant');


%% Test
% Now, clear the variable space and test whether everything works.
clx;

% Read in a scene image file and subsample along wavelength dimension
wList = [410:10:950];
% fullFileName = fullfile('C:\Users\joyce\Desktop\Hyperspectral MCC\Faces\FacesCloseUp\CaucasianVC.mat');
fullFileName = fullfile('J:\SmallHyperspectralScenes\Paintings\SellaioFace1vc.mat');
scene = sceneFromFile(fullFileName,'hyperspectral');

% scene = sceneFromFile(fullFileName ,'multispectral',[],[],wList);
vcAddAndSelectObject(scene); sceneWindow

% Or create a compressed scene image file (stores basis coefficients illuminant, wavelength
% see s_CompressScene.m

%% Adjust the illuminant so the reflectance values fall in a good range

[scene, peakR] = sceneAdjustReflectance(scene,90);
vcAddAndSelectObject(scene); sceneWindow;

%% Not yet implemented here ...
reflectance = sceneGet(scene,'reflectance');
[imgMean, basis, coef] = hcBasis(reflectance);


