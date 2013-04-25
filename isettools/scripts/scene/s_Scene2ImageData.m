% s_Scene2ImageData
%
% Read in a scene.mat file
%
% Create a scene image file (stores photons, illuminant, wavelength,
% comment)
fullFileName = fullfile(isetRootPath,'data','scenes','eye.mat');
load(fullFileName);
photons = double(scene.data.photons);
wave = scene.spectrum.wave;
illuminant.data = scene.illuminant.data;
illuminant.wavelength = wave;
cd 'C:\Users\joyce\Documents\Matlab\SVN\iset-4.0\data\images\multispectral';
comment = 'small image to test vcReadImage with hyperspectral data with no linear model';
save noLinearModel photons illuminant wave comment
clx

% Read in a scene image file and subsample along wavelength dimension

wList = [400:50:700];
fullFileName = fullfile(isetRootPath,'data','images','multispectral','noLinearModel.mat');
scene = sceneFromFile(fullFileName,'multispectral',[],[],wList);
vcAddAndSelectObject(scene); sceneWindow

%
% Or create a compressed scene image file (stores basis coefficients illuminant, wavelength
%