%% s_sceneCompress
%
% Read in hyperspectral scene data and compress the data using linear model 
% (svd to get spectral bases)
%
% See also: s_Scene2ImageData; s_Scene2SampledScene, s_renderScene
%
% Copyright ImagEval Consultants, LLC, 2012

%% Read in the scene
cd 'C:\Users\joyce\Desktop\Hyperspectral MCC\Faces\FacesCloseUp'
load('CaucasianMale2.mat');

% Have a look at the image
vcAddAndSelectObject(scene); sceneWindow;

% Plot the illuminant
plotScene(scene,'illuminant photons')

%% compress the hypercube using a smaller set of spectral basis functions

[imgMean, basis, coef] = hcBasis(double(scene.data.photons));

%% save the data 
comment = 'Caucausian Male 1 compressed using svd with imgMean)';
illuminant.wavelength = scene.spectrum.wave;
illuminant.data = scene.illuminant.data;
basis.basis = basis;
basis.wavelength = scene.spectrum.wave;
ieSaveMultiSpectralImage('male_compressed',coef,basis,comment,imgMean,illuminant);
% save illuminant as illuminant.data and illuminant.wavelength
% save filename basis, coef, illuminant, 
% [ coef, basis, comment, illuminant

%% read in the data
wList = [400:10:950];
fullFileName = fullfile('C:\Users\joyce\Desktop\Hyperspectral MCC\Faces\FacesCloseUp\male_compressed.mat');
scene = sceneFromFile(fullFileName ,'multispectral',[],[],wList);

%% End
