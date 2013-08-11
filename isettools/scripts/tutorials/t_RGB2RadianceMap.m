%% t_RGB2RadianceMap
%    
% Tutorial for how to generate ISET scene for any given bitmap
%
%  This tutorial will including following part
%    1. Generate ISET scene from RGB file
%    2. Adjust the illumimant from the scene
%    3. Do it for a second OLED.
%
% (HJ) VISTASOFT Team 2013

%% Init
s_initISET;

%% Create scene from file
%  Init data file path
imgFileName = 'macbeth.tif';
dispBVMFile = 'OLED-SonyBVM.mat';
dispPVMFile = 'OLED-SonyPVM.mat';

%  Check existence
if ~exist(imgFileName,'file'), error('Image file not found'); end
if ~exist(dispBVMFile,'file'), error('BVM Display file not found.'); end
if ~exist(dispPVMFile,'file'), error('PVM Display file not found.'); end

%%  Create scene from file
% Scene on BVM.
% The illuminant is set to be the white point of the monitor
sceneB = sceneFromFile(imgFileName,'rgb',[],dispBVMFile);
sceneB = sceneSet(sceneB,'name','Scene on BVM');
vcAddAndSelectObject(sceneB); sceneWindow;

%%  Scene on PVM
sceneP = sceneFromFile(imgFileName,'rgb',[],dispBVMFile);
sceneP = sceneSet(sceneP,'name','Scene on PVM');
vcAddAndSelectObject('scene',sceneP); sceneWindow;

%%  Scene on CRT
sceneC = sceneFromFile(imgFileName,'rgb',[],'CRT-Dell');
sceneC = sceneSet(sceneC,'name','Scene on CRT-Dell');
vcAddAndSelectObject('scene',sceneC); sceneWindow;

%%  Scene on other CRT
sceneC = sceneFromFile(imgFileName,'rgb',[],'crt');
sceneC = sceneSet(sceneC,'name','Scene on crt');
vcAddAndSelectObject('scene',sceneC); sceneWindow;

%% Compare the three images
imageMultiview('scene', 1:4, true);

%% Compare the gamuts of the three monitors
d = displayCreate('CRT-Dell');
displayPlot(d,'gamut');
title('Dell CRT')

d = displayCreate('OLED-SonyBVM');
displayPlot(d,'gamut');
title('Sony OLED (BVM)')


%% End