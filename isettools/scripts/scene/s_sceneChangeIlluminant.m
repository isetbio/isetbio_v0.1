%% s_changeIlluminant
%
% Illustrate how to  adjust the illuminant of the current scene, simulating
% a change in the spectral power distribution.
%
% You can set the illuminant to one of the standard SPDs in the directory
% data/lights using the GUI pulldown
%
%   Edit | Adjust SPD | Change illuminant
%
% See also: s_Exercise, sceneAdjustIlluminant,s_illuminantCorrection
%
% Copyright ImagEval Consultants, LLC, 2010.

%%
s_initISET

%% Create the default Macbeth Color Checker (MCC) image and plot the
% simulated illuminant
scene = sceneCreate;

% Have a look at the image
vcAddAndSelectObject(scene); sceneWindow;

% Plot the illuminant
plotScene(scene,'illuminant photons')


%% Transform the current illuminant to Tungsten illuminant

% Read illuminant energy.
wave  = sceneGet(scene,'wave');
TungstenEnergy = ieReadSpectra('Tungsten.mat',wave);

% Adjust function.  In this case TungstenEnergy is a vector of illuminant
% energies at each wavelength.
scene = sceneAdjustIlluminant(scene,TungstenEnergy);
scene = sceneSet(scene,'illuminantComment','Tungsten illuminant');

% Have a look
vcAddAndSelectObject(scene); sceneWindow;
plotScene(scene,'illuminant photons')

%% Read in a more interesting scene and perform some transformations
sceneFile = fullfile(isetRootPath,'data','images','multispectral','StuffedAnimals_tungsten-hdrs.mat');
scene = sceneFromFile(sceneFile,'multispectral');
scene = sceneAdjustLuminance(scene,61); % This sets the mean scene luminance
scene = sceneSet(scene,'fov',26.5); % match the scene field of view (fov) with the sensor fov

vcAddAndSelectObject('scene',scene); sceneWindow; % display sceneWindow
plotScene(scene,'illuminant energy')

%% Set illuminant to equal energy

% Notice that in this case 'Horizon_Gretag.mat' is a file name, not a
% data vector. 
scene = sceneAdjustIlluminant(scene,'equalEnergy.mat');

vcAddAndSelectObject('scene',scene); sceneWindow; % display sceneWindow

%% Convert the scene to the sunset color, Horizon_Gretag

scene = sceneAdjustIlluminant(scene,'Horizon_Gretag.mat');
vcAddAndSelectObject('scene',scene); sceneWindow; 

%% Test imageMultiview
imageMultiview('scene',[3 4 5]);
imageMultiview('scene',1);

%% End
