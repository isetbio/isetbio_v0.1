function ctdpProcessRefreshEvent(hObject)
% Refresh Display Window. 
%
%  ctdpProcessRedrawEvent(hObject);
%
% Set the main image needs update flag.  This routine is called when the
% Edit | Refresh pulldown is called.  Maybe other times, but I am not sure
% when.
%
% Wandell, 2006

% Get the display window
displayGD = ctGetObject('display');

% Set flag to allow display window refresh
displayGD = ctDisplaySet(displayGD, 'm_bMainImageNeedsUpdate', 1);

% Put it back and call the refresh command
ctSetObject('display', displayGD);

ctdpRefreshGUIWindow(hObject);

return;