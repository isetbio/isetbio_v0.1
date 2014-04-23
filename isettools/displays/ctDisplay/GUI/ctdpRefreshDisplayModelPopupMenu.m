function ctdpRefreshDisplayModelPopupMenu(ctDisplayW)
%Refresh the list in the display window popup menu
%
%  ctdpRefreshDisplayModelPopupMenu([ctDisplayW]);
%
%
% (c) Stanford VISTA Team 2006

if ieNotDefined('ctDisplayW'), ctDisplayW = ctGetObject('displayW'); end
displayGD = guidata(ctDisplayW);

curModel     = ctDisplayGet(displayGD, 'm_nCurrentSelectedModel');
displayModels= ctDisplayGet(displayGD, 'm_cellSelectedDisplayModels');
nModels = length(displayModels);

for ii=1:nModels
    modelNames{ii}=vDisplayGet(displayModels{ii}, 'DisplayName');
end

modelNames{ii+1}='-----------------------------';
modelNames{ii+2}='New ...';

% Adjusts the display names in the popup menu of the window
set(ctDisplayGet(displayGD, 'popupmenuDisplayModels'), 'String', modelNames);
set(ctDisplayGet(displayGD, 'popupmenuDisplayModels'), 'Value', curModel);

ctSetObject('display',displayGD);

return;
