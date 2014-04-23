function ctdpProcessAlwaysRedrawOnTheFlyEvent(hObject);
% --- Helper function for processing always-redraw-on-the-fly menuitem event.
disp('Obsolete')
evalin('caller','mfilename')

displayGD=ctGetObject('display');
b=displayGet(displayGD, 'm_bIsAlwaysRefreshOnTheFly');
displayGD=displaySet(displayGD, 'm_bIsAlwaysRefreshOnTheFly', 1-b);
ctSetObject('display', displayGD);
ctdpRefreshGUIWindow(hObject);

return;