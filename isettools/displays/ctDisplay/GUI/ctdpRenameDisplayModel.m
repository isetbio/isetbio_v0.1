function newName = ctdpRenameDisplayModel(ctDisplayW);
% Rename current display
%
%   ctdpRenameDisplayModel(ctDisplayW);
%
% Examples:
%

if ieNotDefined('ctDisplayW'), ctDisplayW = ctGetObject('displayW'); end
displayGD = guidata(ctDisplayW); 

defName = displayGet(displayGD,'currentmodelname');
newName = ieReadString('Enter new display name:: ',defName);
if isempty(newName), return; end

% prompt={'Enter a new name:'};
% name='Change thcurrent display model name:';
% numlines=1;
% defaultanswer={'Default'};
%  
% answer=inputdlg(prompt,name,numlines,defaultanswer);
% if isempty(answer), return; end;

cellSelectedDisplayModels=displayGet(displayGD, 'm_cellSelectedDisplayModels');
for ii=1:length(cellSelectedDisplayModels)
    if isequal(vDisplayGet(cellSelectedDisplayModels{ii}, 'DisplayName'), newName)
        uiwait(errordlg('A display model with this name already exists... Please choose a new name...'));
        return;
    end;
end;

nCurrentSelectedModel=displayGet(displayGD, 'm_nCurrentSelectedModel');
cellSelectedDisplayModels{nCurrentSelectedModel}=vDisplaySet(cellSelectedDisplayModels{nCurrentSelectedModel}, 'DisplayName', newName);

displayGD=displaySet(displayGD, 'm_cellSelectedDisplayModels', cellSelectedDisplayModels);

ctSetObject('display', displayGD);

ctdpRefreshGUIWindow(ctDisplayW);
return;