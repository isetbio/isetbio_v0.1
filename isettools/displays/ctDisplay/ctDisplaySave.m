function fullName = ctDisplaySave(vDisp,fullName) %#ok<INUSL>
% Save a virtual display structure (CDisplay) to a file
%
%  fullName = ctDisplaySave(vDisplay,fullName)
%
% See also ctDisplayLoad
%
% Example:
%  fullName = ctDisplaySave;
%  fullName = ctDisplaySave(vDisplay,fullName)
%

if ieNotDefined('vDisp'),
    vDisp = displayGet(ctGetObject('display'),'vdisplay'); %#ok<NASGU>
end

if ieNotDefined('fullName'),
    fullName = vcSelectDataFile('session','w');
    if isempty(fullName), return; end
end

save(fullName,'vDisp');

return;