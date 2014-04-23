function displayGD = ctDisplayDelete(ctDisplayW,nDisplay)
%Delete displays from display model list
%
%   displayGD = ctDisplayDelete(ctDisplayW,[nDisplay])
%
% nDisplay is an integer list of displays to delete.
% The default behavior is to have the user select the displays from a list
% box.   
%
%Examples:
%   ctDisplayW = ctGetObject('displayW');
%   displayGD  = ctDeleteDisplay(ctDisplayW,2);
%   ctDisplay;
%
%   ctDisplayW = ctGetObject('displayW');
%   displayGD  = ctDeleteDisplay(ctDisplayW,[1:3]);
%   ctDisplay;
%

if ieNotDefined('ctDisplayW'), ctDisplayW = ctGetObject('displayW'); end
displayGD = guidata(ctDisplayW);

if ieNotDefined('nDisplay'),
    dNames = displayGet(displayGD,'modelNames');
    nDisplay = listdlg(...
        'PromptString','Select a file:',...
        'ListString',dNames);
    if isempty(nDisplay), return; end
end

displays = displayGet(displayGD,'modelList');
if length(displays)-length(nDisplay)<=0
    return;
end;
displays = cellDelete(displays,nDisplay);
displayGD = displaySet(displayGD,'modelList',displays);

% Set current display to one just have the lowest deleted one
currentDisplay = max(1,min(nDisplay)-1);
displayGD = displaySet(displayGD,'nSelectedDisplay',currentDisplay);

ctSetObject('display',displayGD);

return;