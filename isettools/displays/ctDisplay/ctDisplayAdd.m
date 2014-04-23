function displayGD = ctDisplayAdd(ctDisplayW,newModel)
%Add a new display name and CDisplay to the window model list
%
%   displayGD = ctDisplayAdd(ctDisplayW,displayModel)
%
% The newModel is a struct with fields newModel.Name and newModel.DispModel
% fields.
%
% Normally, the newly added display is also selected.  If you do not wish
% to change the selection, the selectFlag = 0;
%
% Examples:
%   ctDisplayAdd([],newModel,1);
%   ctDisplayAdd(ctGetObject('displayW'), newModel, 0);
%
% (c) Stanford Vistalab

if ieNotDefined('ctDisplayW'), ctDisplayW = ctGetObject('displayW'); end
displayGD = guidata(ctDisplayW);

% A cell array of model.Name and model.DispModel structure
displayModels= ctDisplayGet(displayGD, 'displayModels');

% We create the default here and add it to the end of the list
displayModels{end+1} = newModel;
nSelected = length(displayModels);

% Reset the whole list and select the one we just added
displayGD=  ctDisplaySet(displayGD, 'modelList', displayModels);
displayGD = ctDisplaySet(displayGD, 'nSelectedDisplay', nSelected);

ctSetObject('display',displayGD);

return;