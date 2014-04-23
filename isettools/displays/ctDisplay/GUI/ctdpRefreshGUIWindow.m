function ctdpRefreshGUIWindow(ctDisplayW)
% Refresh all parts of the Display Window.
%
%   ctdpRefreshGUIWindow(ctDisplayW);
%
% The ctToolBox commands store data in the window (guidata). The processing
% routines pass the window handle and extract the data from the window.
%
% (c) Stanford VISTA Team 2006

if ieNotDefined('ctDisplayW'), ctDisplayW = ctGetObject('displayW'); end
displayGD = guidata(ctDisplayW);

vd  = ctDisplayGet(displayGD,'vd');
imgData = vDisplayGet(vd, 'InputImage');

if isempty(imgData)
    displayGD = ctdpLoadWhiteboard(ctDisplayW,4,4);
else
    % over sampling for display window
    renderedImage = vdisplayCompute(vd);
    vd = vDisplaySet(vd, 'ImageRawData', renderedImage);
    % imtool(renderedImage)
    vd        = vDisplaySet(vd, 'ImageRendered', renderedImage);
    displayGD = ctDisplaySet(displayGD, 'm_bMainImageNeedsUpdate', 1);
end

displayGD = ctDisplaySet(displayGD,'vd',vd);
ctSetObject('display',displayGD);

ctdpRefreshDisplayModelPopupMenu(ctDisplayW);
ctdpRefreshDisplayInformationPanel(ctDisplayW);

% This takes some time
ctdpRefreshMainImage(ctDisplayW,1);
ctdpRefreshDixelStructureAxes(ctDisplayW);

return;
