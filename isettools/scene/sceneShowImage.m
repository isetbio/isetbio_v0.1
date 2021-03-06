function rgb = sceneShowImage(scene,displayFlag,gam)
%Render an image of the scene data
%
%    rgb = sceneShowImage(scene,displayFlag,gam)
%
% The rendering can be either of photons or energy values. This is called
% from the sceneWindow, so that axes are in that window.  If you call this
% from the command line, a new figure is displayed.
%
% Examples:
%   rgb = sceneShowImage(scene,'photons')
%   sceneShowImage(scene,'energy')
%   sceneShowImage(scene,'luminance')
%
% Copyright ImagEval Consultants, LLC, 2003.

% TODO:  Shouldn't we select the axes for rendering here?  There is only
% one axis in the scene and oi window. But if we ever go to more, this
% routine should  say which axis should be used for rendering.

if isempty(scene), cla; return;  end

if ieNotDefined('gam'), gam = 1; end
if ieNotDefined('displayFlag'), displayFlag = 1; end

% Force to lower case and no spaces
wList = sceneGet(scene,'wavelength');
img   = sceneGet(scene,'photons');
row   = sceneGet(scene,'row'); 
col = sceneGet(scene,'col');

if isempty(img)
    cla
    sprintf('ISET Warning:  Data are not available');
    return;
end
    
% This displays the image in the GUI.  The displayFlag flag determines how
% imageSPD converts the data into a displayed image.  It is set from the
% GUI in the function sceneShowImage.
rgb = imageSPD(img,wList,gam,row,col,displayFlag);
axis image; axis off

return;

