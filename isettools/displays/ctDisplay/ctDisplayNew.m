function displayGD = ctDisplayNew(ctDisplayW)
% Create a new Display model and add it to the window
%
%   displayGD = ctDisplayNew(ctDisplayW);
%
% Adds a new default display model to the GUI.  This model must then be
% edited to create a specific model you desire.
%
% (c) Stanford Vistalab

if ieNotDefined('ctDisplayW'), ctDisplayW = ctGetObject('displayW'); end
displayGD = guidata(ctDisplayW);

defString = displayGet(displayGD, 'newModelName');
dName = ieReadString('New name',defString);

if isempty(dName)
    % User canceled.  Set to previous selection and return
    set(gcbo, 'Value', nSelected);
    return;
end;

% A cell array of model.Name and model.DispModel structure
displayModels=displayGet(displayGD, 'displayModels');

% We create the default here and add it to the end of the list
displayModels{end+1}=vDisplayCreate;
nSelected = length(displayModels);

% Reset the whole list and select the one we just added
displayGD= displaySet(displayGD, 'modelList', displayModels);
displayGD =displaySet(displayGD, 'nSelectedDisplay', nSelected);

return;