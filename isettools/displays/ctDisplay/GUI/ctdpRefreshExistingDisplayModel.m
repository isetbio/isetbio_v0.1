function ctdpRefreshExistingDisplayModel(ctDisplayW);
%Update display model pulldown menu
%
%  ctdpRefreshExistingDisplayModel(ctDisplayW);
%
%Example:
%

% Obsolete

if ieNotDefined('ctDisplayW'), ctDisplayW = ctGetObject('displayW'); end
displayGD = guidata(ctDisplayW);

menuRoot=displayGet(displayGD, 'menuExistingModels');

cellDispModelNameList=ieFindDisplayModels;
delete(get(menuRoot, 'Children'));

for ii=1:length(cellDispModelNameList);
    cBack = 'ctDisplay(''menuProcessExistingDisplayModels_Callback'',gcbo,[],guidata(gcbo))';
    uimenu(menuRoot, ...
        'Label', cellDispModelNameList{ii} , ...
        'Callback',cBack);
end;

% displayGD is not changed, so eliminated
% ctSetObject('display', displayGD);

return;


