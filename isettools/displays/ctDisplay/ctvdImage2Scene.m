function [scene, sWin] = ctvdImage2Scene(displayGD,show)
% Convert the virtual display image to an ISET scene
%
%    [scene, sceneWindow]  = ctvdImage2Scene([displayGD],[show]);
%
% To measure display images, we transform the data into an ISET scene and
% use the ISET Scene Window.  This routine does the transformation and, if
% show = 1, brings the scene up in a Scene Window.
%
% Examples:
%   scene = ctvdImage2Scene;
%   scene = ctvdImage2Scene([],1);
%   scene = ctvdImage2Scene(ctGetObject('display'),1);
%
% Wandell, 2006

if ieNotDefined('displayGD'), displayGD = ctGetObject('display'); end
vdImage= displayGet(displayGD, 'ImageRendered');
if isempty(vdImage), return; end;
if ieNotDefined('show'), show = 0; end  % Display in scene window

% Build the scene structure using ISET
scene = sceneCreate;
scene = sceneSet(scene,'name',displayGet(displayGD,'name'));

% Re-write this to assume afield of view assumes a 100 dpi display at 1 m
% spans 40 deg 
vd = displayGet(displayGD,'vd');
row = vDisplayGet(vd,'inputRow');
pixAngle = vDisplayGet(vd,'pixelanglex');
scene = sceneSet(scene,'fov',row*pixAngle);

% Get the display spectral power distribution for the primaries
spd = displayGet(displayGD, 'spdMatrix');
wave = displayGet(displayGD,'wave');

% Now works with X primaries
[XW,r,c,w] = RGB2XWFormat(vdImage);
photons = Energy2Quanta(wave,imageLinearTransform(vdImage,spd));

scene = sceneSet(scene,'photons',photons);
scene = sceneSet(scene,'wave',wave);
[luminance, meanLuminance] = sceneCalculateLuminance(scene);
scene = sceneSet(scene,'luminance',luminance);
scene = sceneSet(scene,'meanLuminance',meanLuminance);

if show
    sWin = guihandles(sceneWindow);
    vcAddAndSelectObject(scene);
    sceneWindow('sceneRefresh',sWin.figure1,[],sWin)
end

return;

