function [roiLocs,rect] = vcROISelect(obj,objFig)
% Select a region of interest (ROI) from an image and calculate locations  
%
%   [roiLocs,rect] = vcROISelect(obj,[objFig])
%
%  The row and col locations of the region of interest (ROI) are returned
%  in the Nx2 matrix, roiLocs.
%
%  If requested, the selected rectangle (rect) determining the region of
%  interest, [colmin,rowmin,width,height], is also returned.  
%
% Example:
%  vci             = vcGetObject('VCIMAGE');
%  [roiLocs, rect] = vcROISelect(vci);
%  iData   = vcGetROIData(vci,roiLocs,'results');
%
% See also: vcRect2Locs
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('obj'), error('You must define an object (isa,oi,scene ...)'); end
if ieNotDefined('objFig'), objFig = vcGetFigure(obj); end

% Select points.  
hndl = guihandles(objFig);
msg = sprintf('Drag to select a region.');
ieInWindowMessage(msg,hndl);

% Select an ROI graphically.  Calculate the row and col locations.
% figure(objFig);
rect = round(getrect(objFig));
ieInWindowMessage('',hndl);

% If the user double clicks without selecting a rectangle, we treat the
% response as a single point.  We do this by making the size 1,1.
if rect(3) == 0 && rect(4) == 0
    rect(3) = 1;
    rect(4) = 1;
end

% Transform the rectangle into ROI locations
roiLocs = ieRoi2Locs(rect);

return;

