%% s_sceneCompress
%
% Read in hyperspectral scene data and compress the data using linear model 
% (svd to get spectral bases)
%
% See also: s_Scene2ImageData; s_Scene2SampledScene, s_renderScene
%
% Copyright ImagEval Consultants, LLC, 2012

%% Read in the scene
fname = fullfile(isetRootPath,'data','images','multispectral','Feng_Office-hdrs');
scene = sceneFromFile(fname,'multispectral');
wave = sceneGet(scene,'wave');

% Have a look at the image
vcAddAndSelectObject(scene); sceneWindow;

% Plot the illuminant
plotScene(scene,'illuminant photons roi')

%% compress the hypercube using a smaller set of spectral basis functions
photons = sceneGet(scene,'photons');
[imgMean, basis, coef] = hcBasis(photons);

%% save the data 
comment = 'Test scene from ISET';
illuminant.wavelength = wave;
illuminant.data = scene.illuminant.data;
basis.basis = basis;
basis.wavelength = scene.spectrum.wave;
ieSaveMultiSpectralImage('male_compressed',coef,basis,comment,imgMean,illuminant);
% save illuminant as illuminant.data and illuminant.wavelength
% save filename basis, coef, illuminant, 
% [ coef, basis, comment, illuminant

%% read in the data
wList = [400:10:950];
fullFileName = fullfile(pwd,'male_compressed.mat');
scene = sceneFromFile(fullFileName ,'multispectral',[],[],wList);

%% End
