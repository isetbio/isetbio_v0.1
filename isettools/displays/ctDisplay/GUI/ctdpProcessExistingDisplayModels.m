function [displayGD, vDisplay] = ctdpProcessExistingDisplayModels(ctDisplayW, fullFileName)
% Read a display model and place it the Display Window 
%
%   [displayGD, vDisplay] = ctdpProcessExistingDisplayModels(ctDisplayW, [fullFileName]);
%
% ctDisplayW   - a ctDisplay window handle.  
% fullFileName - Name of the file containing the model, normally
%                located in:  ctRootPath/ctData/Display Models/.  
%
% displayGD    - GUI data from the display window
% vDisp        - The processed virtual display.  Same as
%                vDisplay = ctDisplayGet(displayGD,'vdisplay')
%
%Example:
%   mainW = ctMainWindow; displayW = ctDisplay(mainW);
%   fName = fullfile(ctRootPath,'ctData','Display Models','Dell Chevron Pixel');
%   ctdpProcessExistingDisplayModels(displayW, fName);
%   ctDisplay;
%
% PDCSOFT TEAM (c) 2006??

if ieNotDefined('ctDisplayW'), ctDisplayW = ctGetObject('displayW'); end
displayGD = guidata(ctDisplayW);

if ieNotDefined('fullFileName'), 
    fullFileName = vcSelectDataFile('stayput','r'); 
    if isempty(fullFileName), disp('User canceled'); return; end
end

vDisplay  = ctDisplayLoad(fullFileName);

% Attach the psf to the display.  Then attach the display to the ctDisplay
% window guidata. Then attach the guidata to the window.
displayGD  = ctGetObject('display');
displayGD  = ctDisplaySet(displayGD,'vdisplay', vDisplay);
ctSetObject('display', displayGD);

% Should we show the window, say by setting a flag?

return
