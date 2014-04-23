function displayGD = ctdpLoadWhiteboard(ctDisplayW, width, height)
% Set display raw data to white (like a white patch of screen)
%
%   displayGD = ctdpLoadWhiteboard(ctDisplayW, width, height);
%
% This function is creates a white image used to illustrates the
% pixel pattern in the main Display GUI window. 
%
%   ctDisplayW is the Display window handle.
%   width and height are the number of pixels rendered
%  
% Example
%    ctDisplayW = ctGetObject('displayFigure');
%    ctdpLoadWhiteboard(ctDisplayW);
%

if ieNotDefined('ctDisplayW'), ctDisplayW=ctGetObject('displayFigure'); end
displayGD = guidata(ctDisplayW); 
vd = ctDisplayGet(displayGD,'vd');

if ieNotDefined('width') || ieNotDefined('height')
    sz = ieReadMatrix([ 4 4 ],'    %.0f   ','Width and height');
    sz = round(sz);
    if isempty(sz), return; end
    if min(sz) < 1, errordlg('Size must be positive'); return; end
    height = sz(1); width = sz(2);
end;

% This is the white board image.
whiteBoard =ones(height,width,3);
vd = vDisplaySet(vd,'Input image', whiteBoard);

% Attach it to the GUI
displayGD= ctDisplaySet(displayGD, 'vd',vd);
displayGD= ctDisplaySet(displayGD, 'm_bIsMainImageDirty', 1);
displayGD= ctDisplaySet(displayGD, 'm_bMainImageNeedsUpdate', 1);

% Store the changed object.
ctSetObject('display', displayGD);

return;