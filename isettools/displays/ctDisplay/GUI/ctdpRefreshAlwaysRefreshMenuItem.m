function ctdpRefreshAlwaysRefreshMenuItem
%Set a check on menu item in display window
%
%   ctRefreshAlwaysRedrawMenuItem(ctDisplayW); Obsolete
%
% Is this really needed?

disp('Obsolete');
evalin('caller','mfilename')
return;

if ieNotDefined('ctDisplayW'), ctDisplayW = ctGetObject('display'); end
displayGD = guidata(ctDisplayW);

bIsAlwaysRefresh = displayGet(displayGD, 'm_bIsAlwaysRefreshOnTheFly');
% hMenuItem        = displayGet(displayGD, 'menuAlwaysRefreshOnTheFly');
% 
% if ~bIsAlwaysRefresh   set(hMenuItem, 'Checked', 'off');
% else                   set(hMenuItem, 'Checked', 'on');
% end;

return;