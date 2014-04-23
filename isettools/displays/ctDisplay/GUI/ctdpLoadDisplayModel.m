function ctdpLoadDisplayModel(ctDisplayW)
% Imports a vDisplay 
%
%  ctdpLoadDisplayModel(ctDisplayW)
%
% Is this obsolete?

[filename, pathname] = uigetfile('display.mat', 'Load display model from ...');
if isequal(filename,0) || isequal(pathname,0)
    return;
end;


%eval(['load ''' fullfile(pathname, filename) ''' -MAT']);
dispObj=load(fullfile(pathname, filename), '-MAT');
name=fieldnames(dispObj);
newModel=dispObj.(cell2mat(name));
displayGD = ctDisplayAdd(ctDisplayW,newModel,1);
displayGD=displaySet(displayGD, 'm_bIsMainImageDirty', 1);
ctSetObject('display', displayGD);
ctdpRefreshGUIWindow(ctDisplayW);

return;