function ctdpInitializeSession
% Initialize a ctToolBox display window
%
%   ctdpInitializeSession
%
% Sets the guidata in the Display window to default values.
%

% Get the guidata for the display and main windows 
% mainGD = ctGetObject('main'); 
ctDisplayW = ctGetObject('displayFigure');
if isempty(ctDisplayW)
    % warning('No current display window'); 
    return; 
end
% dispGD  = guidata(ctDisplayW); 

% The default display starts with the theoretical LCD-RGB
dpi = 64; 
dSpacing = 0.001; %mm
vDisplay = vDisplayCreate('lcd',dpi,dSpacing,'v','rgb');

dispGD   = ctDisplayAdd(ctDisplayW,vDisplay);

% Maybe this should be a separate initialization function
dispGD = ctDisplaySet(dispGD, 'm_bIsAlwaysRefreshOnTheFly', 1);
dispGD = ctDisplaySet(dispGD, 'm_bIsMainImageDirty', 0);
dispGD = ctDisplaySet(dispGD, 'm_bMainImageNeedsUpdate', 0);

dispGD = ctDisplaySet(dispGD, 'm_nDefaultCommPort', 5);
dispGD = ctDisplaySet(dispGD, 'm_nDefaultNumberOfGrayLevels', 256);
dispGD = ctDisplaySet(dispGD, 'm_nDefaultNumberOfSamples', 3);

% Use working monitor value of 2 to measure the other monitor.
dispGD = ctDisplaySet(dispGD, 'm_bDefaultWorkingMonitor', 1); 
dispGD = ctDisplaySet(dispGD, 'm_n2ndMonitorSizeX', 1600);
dispGD = ctDisplaySet(dispGD, 'm_n2ndMonitorSizeY', 1200);
dispGD = ctDisplaySet(dispGD, 'm_nPauseTimeInSeconds', 60);

% Place the guidata back into the window
ctSetObject('display', dispGD);

ctFontChangeSize(ctDisplayW, 0);
ctdpLoadWhiteboard(ctDisplayW, 6, 4);

% Load the initial display for the window.
% dispName = fullfile(ctRootPath,'ctData','Display Models','Nec2080ux');
% ctdpProcessExistingDisplayModels(ctDisplayW, dispName);

% Refresh and end
ctdpRefreshGUIWindow(ctDisplayW);

return;
