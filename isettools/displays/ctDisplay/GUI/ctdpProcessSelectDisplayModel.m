function ctdpProcessSelectDisplayModel(ctDisplayW,popString)
%Process Selected Display popup menu choice in Display window
%
%   ctdpProcessSelectDisplayModel(ctDisplayW,popString)
%
% When the user selects 'New' and default new monitor is displayed
% When the user selects a current display, that one is shown.
% Inadvertently selecting the ---- line defaults to selecting the last
% real display in the list
%
% Example
%    ctdpProcessSelectDisplayModel;     % Process current state
%    ctdpProcessSelectDisplayModel

% Which line and string did the user select?  This can be forced by the
% call, or it can be selected from the window.
if ieNotDefined('popString')
    cellContents = get(gcbo, 'String');
    popSelected  = get(gcbo,'Value');
    popString    = cellContents{popSelected};
end

% Get ready for action with the display information
if ieNotDefined('ctDisplayW'), ctDisplayW = ctGetObject('displayW'); end
displayGD = guidata(ctDisplayW);

nDisplays = displayGet(displayGD,'nmodels');
nSelected = displayGet(displayGD,'currentdisplay');

switch popString
    case 'New ...'
        displayGD = ctDisplayNew(ctDisplayW);

    case '-----------------------------'
        % User probably meant to set the last string or New.  Let's guess
        % the last one.
        displayGD =displaySet(displayGD, 'nSelectedDisplay', nSelected);

    otherwise
        % User selected a model.  Set the model and then let refresh do the rest.
        % I don't know why we have both a virtual display list, and a
        % virtual display, and a number pointing into the list.  We should
        % only have a list and a number pointing to the selected one.  This
        % can be changed by re-writing inset of the displayGet() calls.
        displayGD = displaySet(displayGD,'nSelectedDisplay', popSelected);
        vDisplay  = displayGet(displayGD,'modelList',popSelected);
        displayGD = displaySet(displayGD,'vDisplay',vDisplay);
end;

ctSetObject('display',displayGD);

return;
