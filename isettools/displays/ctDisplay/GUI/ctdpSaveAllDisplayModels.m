function res=ctdpSaveAllDisplayModels(hObject);
% Export all current display settings; 
% 
% Here since it is for vdisplay window, so it only exports vDisplay
% settings.
% 
% The contents of display properties include:
%                             s.sPhysicalDisplay
%                             s.sViewingContext
%
%  However, for simplicity, at 'export' time we don't concern about this;
%  we will distinguish the above at 'import' time. 
%  
% Programming TODO:
%    This routine should simple save the display model structure (CDisplay).
%    It should not pick and choose what gets saved.  Similarly, the
%    ctdpImport/Export
%

disp('ctdpSaveAllDisplayModels: Probably obsolete')

[filename, pathname] = uiputfile('display.dsp', 'Save all display models to ...');
if isequal(filename,0) || isequal(pathname,0)
    res=-1;
    return;
end;

displayGD=ctGetObject('display');

cellSelectedDisplayModels=diplayGet(displayGD, 'm_cellSelectedDisplayModels');
objVirtualDisplay        =diplayGet(displayGD, 'm_objVirtualDisplay');
nCurrentSelectedModel=diplayGet(displayGD, 'm_nCurrentSelectedModel');
nDefaultNewModelName=diplayGet(displayGD, 'm_nDefaultNewModelName');
try
   feval('save', fullfile(pathname, filename), 'cellSelectedDisplayModels', 'objVirtualDisplay', 'nCurrentSelectedModel', 'nDefaultNewModelName');
catch
   uiwait(errordlg('Writing to the file failed! Please check your system and try again...', 'Error'));
   res=0;
   return;
end;
res=1;

return;

