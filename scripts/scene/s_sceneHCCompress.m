%% s_sceneCompress
%
% Read in hyperspectral scene data and compress the data using linear model 
% (svd to get spectral bases)
%
% See also: s_Scene2ImageData; s_Scene2SampledScene, s_renderScene
%
% Copyright ImagEval Consultants, LLC, 2012


%%
s_initISET

%% Read in the scene
fName = fullfile(isetRootPath,'data','images','multispectral','StuffedAnimals_tungsten-hdrs');
scene = sceneFromFile(fName,'multispectral');

% Have a look at the image
vcAddAndSelectObject(scene); sceneWindow;

% Plot the illuminant
plotScene(scene,'illuminant photons');

%% Compress the hypercube requiring only 95% of the var explained
vExplained = 0.95;
[imgMean, imgBasis, coef] = hcBasis(sceneGet(scene,'photons'),vExplained);

%% Save the data 
wave        = sceneGet(scene,'wave');
basis.basis = imgBasis;
basis.wave  = wave;

comment = 'Compressed using hcBasis with imgMean)';

illuminant = sceneGet(scene,'illuminant');
% illuminant.wavelength = scene.spectrum.wave;
% illuminant.data = scene.illuminant.data;
oFile = fullfile(isetRootPath,'deleteMe.mat');
ieSaveMultiSpectralImage(oFile,coef,basis,comment,imgMean,illuminant);

%% read in the data
wList = 400:5:700;
scene2 = sceneFromFile(oFile ,'multispectral',[],[],wList);

% It is very desaturated
vcAddAndSelectObject(scene2); sceneWindow;

%% Now require that most of the variance be plained
vExplained = 0.99;
[imgMean, imgBasis, coef] = hcBasis(sceneGet(scene,'photons'),vExplained);
fprintf('Number of basis functions %.0f\n',size(imgBasis,2));

%% Save the data 
wave        = sceneGet(scene,'wave');
basis.basis = imgBasis;
basis.wave  = wave;

comment = 'Compressed using hcBasis with imgMean)';

illuminant = sceneGet(scene,'illuminant');
% illuminant.wavelength = scene.spectrum.wave;
% illuminant.data = scene.illuminant.data;
ieSaveMultiSpectralImage(oFile,coef,basis,comment,imgMean,illuminant);

%% read in the data
wList = 400:5:700;
scene2 = sceneFromFile(oFile ,'multispectral',[],[],wList);
vcAddAndSelectObject(scene2); sceneWindow;

%% Clean up the temporary file.
delete(oFile);

%% End
