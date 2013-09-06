%% s_sceneRender
% 
% Read in a hyperspectral data of faces and render it under
% different lights.
%
% D50.mat, D55.mat, D65.mat, D75.mat
% In the first part of this script, we use an arbitrary method for
% displaying the spectral data (map different wavelength bands into r, g
% and b)
%
% Another way to think of rendering is to calculate the xyz values for the
% spectral data. We do this by first calculating the radiance signal for
% the surfaces under daylight (think of this as color balancing) Then we
% calculate the xyz values and use an xyz to linear srgb final step should
% be to pass the linear rgb into a display gamma lut
% 
% See also: s_Scene2SampledScene and s_sceneCompress
%
% Copyright ImagEval Consultants, LLC, 2012

%% Read in the scene
wList = [420:10:950];
fullFileName = fullfile('I:\ISET SceneDataFiles\Hyperspectral\Faces\ISET Faces\Asian\Joyce.mat');
% fullFileName = fullfile('I:\ISET SceneDataFiles\Hyperspectral\Faces\ISET Faces\Caucausian\Conny.mat');
scene = sceneFromFile(fullFileName ,'multispectral',[],[],wList);

% Have a look at the image (just mapping different spectral bands into rgb)
vcAddAndSelectObject(scene); sceneWindow;

% Plot the illuminant
plotScene(scene,'illuminant photons roi')


%% Transform the current illuminant to daylight
% notice that daylight is defined only out to ~700 nm
% try to find a spectral power distribution for daylight out to 950 nm

% Read illuminant energy.
wave  = sceneGet(scene,'wave');
daylight = ieReadSpectra('D75.mat',wave);

% Adjust function.  In this case daylight is a vector of illuminant
% energies at each wavelength.
scene = sceneAdjustIlluminant(scene,daylight);
scene = sceneSet(scene,'illuminantComment','Daylight (D75) illuminant');

% Have a look
vcAddAndSelectObject(scene); sceneWindow;
plotScene(scene,'illuminant photons roi')

%%
row = sceneGet(scene,'rows');
col = sceneGet(scene,'cols');

%% To convert the scene to XYZ
e = Quanta2Energy(wave,double(scene.data.photons));
xyz = ieXYZFromEnergy(e,wave);
xyz = XW2RGBFormat(xyz,row,col);

%% To convert xyz to srgb

% We find the max Y and normalize xyz when we call the function.  This is
% expected in the standard (see Wikipedia page)
Y = xyz(:,:,2); maxY = max(Y(:))
sRGB = xyz2srgb(xyz/maxY);

% Visualize the result
vcNewGraphWin; image(sRGB);
axis image;

%%
vDist = 0.38;          % 15 inches
dispCal = 'crt.mat';   % Calibrated display

%%

% file2 = sRGB *10;
% [eImage,s1,s2] = scielabRGB(sRGB, file2, dispCal, vDist);
% 
% % This is the mean delta E
% mean(eImage(:))
%% End
