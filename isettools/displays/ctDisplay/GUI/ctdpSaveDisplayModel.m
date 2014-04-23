function fname = ctdpSaveDisplayModel(objVirtualDisplay)
% Save the vDisplay
%
%    fname = ctdpSaveDisplayModel([vDisplay])
%
% If the display is not sent in, then the current one is in the display
% window.
%
% Example:
%   ctdpSaveDisplayModel;
%   
%   dispGD = ctGetObject('display');
%   vd = displayGet(dispGD,'vDisplay');
%   ctdpSaveDisplayModel(vd);
%

if ieNotDefined('objVirtualDisplay')
    objVirtualDisplay = displayGet(ctGetObject('display'), 'vDisplay');
end

fname = vcSelectDataFile('stayput','w');
if isempty(fname), disp('User canceled'); return; end

save(fname,'objVirtualDisplay');


return;
