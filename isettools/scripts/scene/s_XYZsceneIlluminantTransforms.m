% s_XYZsceneIlluminantTransforms
%
%  This script illustrates a method for calculating diagonal and 3x3
%  transforms that map the XYZ values for surfaces under on light into the
%  XYZ values under another light
%
% In s_XYZilluminantTransforms.m we used reflectance data to create an
% artificial scene. This allows us to choose from a wide variety of
% surfaces.
% In this script, we use the hyperspectral scene data and find illuminant
% tranforms for that scene. Note that this will do well for the scene, but
% not for other scenes that have different surfaces.
% 
% Copyright ImagEval Consultants, LLC, 2012.

cd 'J:\SmallHyperspectralScenes\Paintings'
load('SellaioFace1');
vcAddAndSelectObject(scene); sceneWindow;

%% I must be off in the radiance values ... by a huge factor
% this is probably a mistake in interpreting the data I get from Torbjorn
% we can fix this later, but for now, let's set the light level to be something reasonable
% sceneGet(scene,'mean luminance')
scene = sceneAdjustLuminance(scene,100);   % In cd/m2
% these are the xyz values under the original scene light
xyzS = sceneGet(scene,'xyz');
% This is a nSample x 3 representation of the surfaces under Tungsten
xyzS = RGB2XWFormat(xyzS);
%% change illuminant to be daylight (~ color balancing)
scene = sceneAdjustIlluminant(scene,'D65.mat');
vcAddAndSelectObject(scene); sceneWindow;
% This are the surfaces under a D65 light
xyzD65 = sceneGet(scene,'xyz');
% This is a nSample x 3 representation of the surfaces under D65
xyzD65 = RGB2XWFormat(xyzD65);

%%
%%  Solve for matrix relating the chart under two different lights
% We are looking for a 3x3 matrix, L, that maps
%
%    xyzD65 = xyzS * L
%    L = inv(xyzS'*xyzS)*xyzS'*xyzD65 = pinv(xyzS)*xyzD65
%
% Or, we just use the \ operator from Matlab for which inv(A)*B is A\B
L = xyzS \ xyzD65;

% To solve with just a diagonal, do it one column at a time
D = zeros(3,3);
for ii=1:3
    D(ii,ii) = xyzS(:,ii) \ xyzD65(:,ii);
end

%% Plot predicted versus actual
% vcNewGraphWin; pred2 = xyzS*L; plot(xyzD65(:),pred2(:),'.')
% vcNewGraphWin; pred2 = xyzS*D; plot(xyzD65(:),pred2(:),'.')