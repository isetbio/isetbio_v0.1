function sceneShowImage(scene,displayFlag,gam)
%Render an image of the scene data
%
%    sceneShowImage(scene,displayFlag,gam)
%
% The rendering can be either of photons or energy values. This is called
% from the sceneWindow, so that axes are in that window.  If you call this
% from the command line, a new figure is displayed.
%
% Examples:
%   sceneShowImage(scene,'photons')
%   sceneShowImage(scene,'energy')
%   sceneShowImage(scene,'luminance')
%
% Copyright ImagEval Consultants, LLC, 2003.

% TODO:  Shouldn't we select the axes for rendering here?  There is
% only one axis in the scene and oi window.  If we ever go to more, this
% routine should definitely say where the data are to be rendered.
%
% Maybe we should determine the input type and then rename it?  Or there
% should be a separate routine, oiShowImage().

if isempty(scene), cla; return;  end

if ieNotDefined('gam'), gam = 1; end
if ieNotDefined('displayFlag'), displayFlag = 1; end

% Force to lower case and no spaces

switch lower(scene.type)
    case 'scene'
        wList = sceneGet(scene,'wavelength');
        img = sceneGet(scene,'photons');     
    case 'opticalimage'
        % Now call the appropriate imaging routine.
        wList = oiGet(scene,'wavelength');
        img = oiGet(scene,'photons');
    otherwise
        error('Unknown object - not scene or oi');
end

if isempty(img)
    cla
    sprintf('ISET Warning:  Data are not available');
    return;
end
    
% This displays the image in the GUI.  The displayFlag flag determines how
% imageSPD converts the data into a displayed image.  It is set from the
% GUI in the function sceneShowImage.
imageSPD(img,wList,gam,[],[],displayFlag);
axis image; axis off

return;

