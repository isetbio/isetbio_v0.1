function ctdpLoadCRTDefaultSettings(hObject);
% Load a default CRT default display settings.
%
%   ctdpLoadCRTDefaultSettings(hObject);
%
% Create a CRT display model and attach it to the specified display window.
% If no display window is specified, then attach it to the current display
% window.
%
%

disp('Obsolete')
evalin('caller','mfilename');
return;

if ieNotDefined('displayW'), displayGD=ctGetObject('display');
else displayGD = guidata(displayW); 
end

% Why aren't we creating a new display here?  Shouldn't we do that instead
% of taking the currently selected dislay?

displayCRT = vDisplayCreate('crt');
displayGD  = displaySet(displayGD,'vDisplay',displayCRT);

displayGD = displaySet(displayGD, 'm_bIsMainImageDirty', 1);
displayGD = displaySet(displayGD, 'm_bMainImageNeedsUpdate', 1);

ctSetObject('display', displayGD);

ctdpRefreshGUIWindow(hObject);

return;
