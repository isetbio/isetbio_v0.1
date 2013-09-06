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
disp1File = 'OLED-Sony.mat';
disp2File = 'LCD-Apple.mat';

%  Check existence
if ~exist(imgFileName,'file'), error('Image file not found'); end
if ~exist(disp1File,'file'), error('Display file %s not found.',disp1File); end
if ~exist(disp2File,'file'), error('Display file not found.',disp2File); end

%%  Create scene from files
% The illuminant is set to be the white point of the monitor
sceneB = sceneFromFile(imgFileName,'rgb',[],disp1File);
sceneB = sceneSet(sceneB,'name',disp1File);
vcAddAndSelectObject(sceneB); sceneWindow;

%%  Scene 
sceneP = sceneFromFile(imgFileName,'rgb',[],disp2File);
sceneP = sceneSet(sceneP,'name',disp2File);
vcAddAndSelectObject('scene',sceneP); sceneWindow;

%%  Scene on CRT
sceneC = sceneFromFile(imgFileName,'rgb',[],'CRT-Dell');
sceneC = sceneSet(sceneC,'name','CRT-Dell');
vcAddAndSelectObject('scene',sceneC); sceneWindow;

%%  Scene on other CRT
sceneC = sceneFromFile(imgFileName,'rgb',[],'crt');
sceneC = sceneSet(sceneC,'name','crt');
vcAddAndSelectObject('scene',sceneC); sceneWindow;

%% Compare the three images
imageMultiview('scene', 1:4, true);

%% Compare the gamuts of the three monitors
d = displayCreate('CRT-Dell');
displayPlot(d,'gamut');
title('Dell CRT')

d = displayCreate(disp1File);
displayPlot(d,'gamut');
title(disp1File)

d = displayCreate(disp2File);
displayPlot(d,'gamut');
title(disp2File)


%% End