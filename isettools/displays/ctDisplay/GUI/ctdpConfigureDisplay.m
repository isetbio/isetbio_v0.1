function ctdpConfigureDisplay(displayW);
% Obsolete .... Configure ... something
%
%   ctdpConfigureDisplay(displayW);
%
%

disp('Obsolete')
evalin('caller','mfilename');
return;

if ieNotDefined('displayW'), displayW = ctGetObject('displayW'); end
displayGD=ctGetObject('display');

% ctdpInitializeSession;
vDisp = displayGet(displayGD, 'vDisplay');
nGray = displayGet(displayGD, 'm_nDefaultNumberOfGrayLevels');

newDisp = ctConfigureDisplay(displayW,vDisp, nGray);

if ~isempty(newDisp),
    displayGD=displaySet(displayGD, 'vDisplay', newDisp);
    displayGD=displaySet(displayGD, 'm_bIsMainImageDirty', 1);
    ctSetObject('display', displayGD);
else
    disp('User canceled');
end;

ctdpRefreshGUIWindow(displayW);

return;
