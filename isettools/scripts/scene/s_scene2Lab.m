%%s_scene2Lab
%
% read in a hyperspectral scene
% change illuminant to be daylight (color balancing)
% convert to xyz
% convert xyz to lab
% convert lab to xyz
% convert xyz to rg

cd 'J:\SmallHyperspectralScenes\Paintings'
load('SellaioFace1');
vcAddAndSelectObject(scene); sceneWindow;

%% change illuminant to be daylight (~ color balancing)
scene = sceneAdjustIlluminant(scene,'D65.mat');
vcAddAndSelectObject(scene); sceneWindow;

%% I must be off in the radiance values ... by a huge factor
% this is probably a mistake in interpreting the data I get from Torbjorn
% we can fix this later, but for now, let's set the light level to be something reasonable
% sceneGet(scene,'mean luminance')
scene = sceneAdjustLuminance(scene,100);   % In cd/m2

%% Convert the scene to XYZ
xyz = sceneGet(scene,'xyz');
whiteXYZ = sceneGet(scene,'illuminant xyz');
lab = xyz2lab(xyz,whiteXYZ);
% tmp = RGB2XWFormat(lab);
% vcNewGraphWin; plot3(tmp(:,1),tmp(:,2),tmp(:,3),'.'); grid on
% xlabel('L'), ylabel('a*'), zlabel('b*')

%% Make lab adjustments
% see Saunders and Kirby 
% can selectively move pixels in ab space
%% Go back to XYZ
xyz2 = lab2xyz(lab,whiteXYZ);
rgb = xyz2srgb(xyz2);
vcNewGraphWin; imagesc(rgb); axis image;





