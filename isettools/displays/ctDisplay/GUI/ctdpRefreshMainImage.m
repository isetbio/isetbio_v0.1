function ctdpRefreshMainImage(ctDisplayW,forceUpdate)
% Refresh the main image in the display window.
%
%  ctdpRefreshMainImage(ctDisplayW,[forceUpdate = 0]);
%
% Example
%   ctdpRefreshMainImage
%
% Wandell, 2006

if ieNotDefined('ctDisplayW'), ctDisplayW = ctGetObject('displayW'); end
displayGD = guidata(ctDisplayW);

if ieNotDefined('forceUpdate'), forceUpdate = 0; end
if ~(forceUpdate || displayGet(displayGD, 'm_bMainImageNeedsUpdate'))
    return;
end;

% Make sure the proper window/axes are selected
figure(displayGD.figure1);
hAxes= ctDisplayGet(displayGD, 'axes1');  axes(hAxes); cla;

vd   = ctDisplayGet(displayGD,'vd');

% The rendered data are multiple primary rendering of the display created
% by vdisplayCompute
imgRendered = vDisplayGet(vd,  'ImageRendered');

% Convert from X primaries to 3 RGB primaries
imgRendered = ctdpRendered2RGB(vd, imgRendered);
% imtool(imgRendered)

inputImage = vDisplayGet(vd, 'ImageRawData');
if isempty(imgRendered),
    % Check whether there are raw data to use for computing the rendered
    % image
    if isempty(inputImage),   set(hAxes, 'Visible', 'off');
        % Nothing to show.  Go back
        xlabel(''); return;
    else
        imgRendered = vdisplayCompute(vd);

        % Tweaked to handle displaying an image which has more than 3
        % primaries
        imgRendered = ctdpRendered2RGB(vd,imgRendered);
        vd = vDisplaySet(vd,'outputImage',imgRendered);
    end
end

% Adjust the axes.  Do we need to get the vd again after this?  Probably
% not, but be alert.
set(hAxes, 'Visible', 'on');
strOldPref = iptgetpref('ImshowAxesVisible');
iptsetpref('ImshowAxesVisible', 'on');

% These are the units around the main image window.  Each input pixel has a
% size and we figure the total image size from the number of pixels in the
% input image and the pixel size
imgSizemmY = vDisplayGet(vd,'output height','mm');
imgSizemmX = vDisplayGet(vd,'output width','mm');
[imgSizeY imgSizeX z] = size(imgRendered);

% This can happen if there is no input image, i guess?  I don't think it
% happens much - or ever
if imgSizeX==0, imgSizeX=1; end;
if imgSizeY==0, imgSizeY=1; end;
% imtool(imgRendered/max(imgRendered(:)))

% Put up the image with the axes labeled in mm
hRenderedImage = ...
    imshow(imgRendered/max(imgRendered(:)), ...
    'XData', [0 imgSizeX], ...
    'YData', [0 imgSizeY]);

% Old XD stuff.  Not sure what this does.
iptsetpref('ImshowAxesVisible', strOldPref);
set(hRenderedImage, 'Hittest', 'on');
set(hRenderedImage, 'ButtonDownFcn', 'ctDisplay(''imgRenderedImage_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
xlabel('Position (mm)');

% Set ticks on the image.
nTicks = 5;
dX = imgSizemmX/(nTicks-1);
dY = imgSizemmY/(nTicks-1);
% Good to 1 micron
xTick = (0:dX:imgSizemmX);
yTick = (0:dY:imgSizemmY);
xTick = round(xTick*100)/100;
yTick = round(yTick*100)/100;

set(hAxes, 'XTickLabel', xTick, ...
    'XTick', [0:imgSizeX/(nTicks-1):imgSizeX], ...
    'YDir', 'reverse', ...
    'YTickLabel', yTick, ...
    'YTick', [0:imgSizeY/(nTicks-1):imgSizeY]);

% Put everything back in the display object
displayGD = ctDisplaySet(displayGD,'vd',vd);
displayGD = ctDisplaySet(displayGD, 'm_bIsMainImageDirty', 0);
displayGD = ctDisplaySet(displayGD, 'm_bMainImageNeedsUpdate', 0);
ctSetObject('display', displayGD);

return;
