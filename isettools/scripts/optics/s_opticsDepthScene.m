%Script:  s_opticsDepthScene
%
% Render depth image.
%  Illustrates how to set depth planes by diopter step size and various
%  rendering options.
%
% TODO:
%   Think about better edge handling algorithms for more accurate physical
%   stuff rendering (AL).
%   Integrate demonstration with with Maya and RenderToolBox examples
%
% Copyright ImagEval Consultants, LLC, 2011

%%
s_initISET


%% Make a script/function to load the scene
% fName = fullfile(s3dProjectRootPath,'piano_shelf','ISETSceneSmall.mat');
fName = fullfile(isetRootPath,'data','scenes','piano3d.mat');

% If you have the goblet image, it is more fun
% fName = fullfile(isetRootPath,'data','scenes','goblet.mat');

load(fName);
scene = sceneSet(scene,'fov',3);

%%  Make optics with a little bigger pupil
oi = oiCreate;
optics = oiGet(oi,'optics');
optics = opticsSet(optics,'offaxis','cos4th');
optics = opticsSet(optics, 'otfmethod', 'custom');
optics = opticsSet(optics, 'model', 'ShiftInvariant');

fNumber = 4;
optics = opticsSet(optics,'fnumber',fNumber);

% Set the focal length large so the pupil will be large.
pupilFactor = 3;  % When set to 1, this becomes diffraction limited.
f = opticsGet(optics,'focal length');
optics = opticsSet(optics,'focal length',pupilFactor*f);

% Attach the optics to the oi and move on.
oi = oiSet(oi,'optics',optics);


%% These are the object distances for different defocus levels.

% We track depth edges over this defocus range
defocus = linspace(-1.2,0,7);
inFocusDepth = [1.5,100];
for ii=1:length(inFocusDepth)
    
    % This is the depth we would like to be in focus (m)
    thisFocusDepth = inFocusDepth(ii);
    
    % Find the depth edges so that the range of defocus is as above, though
    % it is centered around a depth of inFocusDepth.  To achieve this the
    % imageDist will not be in the focal plane.
    [depthEdges, imageDist, oDefocus] = oiDepthEdges(oi,defocus,thisFocusDepth);
    
    oMap  = sceneGet(scene,'depth map');
    sceneDepthRange = [depthEdges(1),10];
    oMap  = ieScale(oMap,sceneDepthRange(1),sceneDepthRange(2));
    blurSize = 2;
    supportSize = [5 5];
    g = fspecial('gaussian',supportSize,blurSize); oMap = conv2(oMap,g,'same');
    % imagesc(oMap)
    
    scene = sceneSet(scene,'depth map',oMap);
    % vcAddAndSelectObject(scene); sceneWindow;
    
    cAberration = [];
    displayFlag = 0;
    [oiD, D] = oiDepthCompute(oi,scene,imageDist,depthEdges,cAberration,displayFlag);
    % for ii=1:length(oiD), vcAddAndSelectObject(oiD{ii}); end; oiWindow
    
    % Combine them and show them in the window.
    oi = oiDepthCombine(oiD,scene,depthEdges);
    pupil = opticsGet(optics,'pupil radius','mm');
    oi = oiSet(oi,'name',sprintf('Focus-%.1fm',thisFocusDepth));
    
    vcAddAndSelectObject(oi);  oiWindow
    
end

%%
vcSaveObject(oi);

