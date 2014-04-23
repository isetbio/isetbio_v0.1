function ctRefreshDisplayInformationPanel(ctDisplayW)
% Refresh the Summary and Edit panel in Display Window
%
%    ctRefreshDisplayInformationPanel(ctDisplayW);
%
% Make edit boxes and summary box data consistent with current variables.
% These might have been changed by scripting, or by setting values in
% the edit boxes.

if ieNotDefined('ctDisplayW'), ctDisplayW = ctGetObject('displayFigure'); end
displayGD = guidata(ctDisplayW);

% Update edit boxes
vd = ctDisplayGet(displayGD,'vDisplay');

% Fill in the max luminance box
maxLum = vDisplayGet(vd,'maxLuminance');
set(displayGD.editMaxLum,'String',num2str(maxLum));

% Update summary box at the top
pSize = vDisplayGet(vd,'pixelSize','um');
dpi = mperdot2dpi(pSize,'um');
txt = sprintf('Pixel spacing: %.0f (dpi) = %.1f (um)\n',dpi,pSize);

set(ctDisplayGet(displayGD, 'txtSummary'),'string',txt);

return;
