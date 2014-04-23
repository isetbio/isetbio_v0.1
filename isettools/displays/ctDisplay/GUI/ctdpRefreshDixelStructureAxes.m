function ctdpRefreshDixelStructureAxes(ctDisplayW)
% Refresh small dixel structure image in the display window
%
%   ctdpRefreshDixelStructureAxes(ctDisplayW);
%
% The ctDisplay window contains a small image on the right that shows a
% zoomed view of a single display pixel (dixel).  This sub-routine renders
% that image
%
% Wandell, 2006

if ieNotDefined('ctDisplayW'), ctDisplayW = ctGetObject('displayW'); end
displayGD = guidata(ctDisplayW);

%  Not sure about this iptgetpref ... why is it here?
hAxes        = ctDisplayGet(displayGD, 'iconAxes'); axes(hAxes); cla;
strOldPref   = iptgetpref('ImshowAxesVisible');
vd = ctDisplayGet(displayGD,'vd');

% over sampling for single pixel image display
pixelImg = vdisplayCompute(vd,'singlePixel',0);
pixelImg = ctdpRendered2RGB(vd,pixelImg);
% imtool(pixelImg)
%pixelImg     = vdisplayCompute(displayGet(displayGD, 'vDisplay'), 'singlePixel');

%TODO: this function might need be changed later...
iptsetpref('ImshowAxesVisible', 'on');

pSize = vDisplayGet(vd,'pixelSize','mm');

% The single pixel image is embedded in a 3x3 image (pixel in the center is
% turned on).  So the size of the image is 3x the pixel size.
pSize = 3*pSize;

if isequal(ieFindMatlabVer, '7.0.0')
    imshow([0 pSize], [0 pSize], pixelImg/max(pixelImg(:)));
else
    imshow(pixelImg/max(pixelImg(:)), ...
        'XData', [0 pSize], 'YData', [0 pSize]);
end;
iptsetpref('ImshowAxesVisible', strOldPref);

% Set up tick marks
nTick = 4;
d = pSize/(nTick-1);
xTick = (0:d:pSize); xTick = round(xTick*100)/100;
yTick = (0:d:pSize); yTick = round(yTick*100)/100;
set(hAxes, ...
    'XTick', xTick, ...
    'XLim', [0 pSize], ...
    'XAxisLocation', 'top', ...
    'YTick', yTick, ...
    'YLim', [0 pSize], ...
    'YDir', 'reverse' ...
);

return;
