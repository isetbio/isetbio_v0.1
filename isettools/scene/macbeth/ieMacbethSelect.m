function [mRGB, mLocs, pSize, cornerPoints, mccRectHandles] = ...
    ieMacbethSelect(obj,showSelection,fullData,cornerPoints)
%Identify Macbeth color checker RGB values and positions from window image
%
%  [mRGB mLocs, pSize, cornerPoints, mccRectHandles] = 
%            ieMacbethSelect(obj,showSelection,fullData,cornerPoints)
%
% This routine normally works within an ISET window.  The first set of
% comments explain how the routine works within ISET.  It is also possible
% to use this routine with a conventional Matlab window.  In that case the
% returns differ - see below.
%
% The user selects four points on the MCC (white, black, blue, brown).
% This algorithm estimates the (row, column) centers of the 24 MCC patches.
% The mean RGB values in a region around these locations are returned in
% mRGB. 
% 
% The locations for the mean calculation are returned in the mLocs variable.
% The size of the square region is returned in pSize.
%
% By default, the obj is a vcimage.  The function also works on sensor
% data, too. If obj is not sent in, the current default obj is used.  I
%
% If fullData = 1, then the entire rgb set from each patch is returned.
% Always use fullData case for sensor images and calculate the means,
% accounting for the NaNs that are returned.  For a vcimage, you can use
% the fullData = 0 case.
%
% Sometimes, you already know the point locations (cornerPoints).  You can send
% them in if they were previously determined and the routine will skiip the
% graphical interaction.
%
% When the mean is returned (obj case), mRGB is Nx3 RGB values.  Each row
% is computed as the mean RGB in a square region around the center third of
% the Macbeth target. 
%
% When fullData is set to 1 (always used for sensor case, so far), then
% mRGB is a cell array containg the rgb values in each selected patch.
%
% The ordering of the Macbeth patches is assumed to be:
%
%   Achromatic series at the bottom, with white at the left 
%   The white patch is 1 (one).  
%   We count up the column, i.e., blue (2), gold (3), and brown (4).  
%   Then we start at the bottom of the second column (light gray). 
%   The achromatic series numbers are 1:4:24.
%   The blue, green, red patches are 2,6,10.
%
% Examples:
%  [mRGB,locs,pSize,cornerPoints] = ieMacbethSelect;   %Defaults to vcimage
%  [mRGB,locs,pSize] = ieMacbethSelect(vcGetObject('vcimage'));
%  
% See macbethSensorValues() for this functionality.
%  sensor = vcGetObject('sensor');
%  [fullRGB,locs,pSize] = ieMacbethSelect(sensor,0,1);
%  [fullRGB,locs,pSize] = ieMacbethSelect(sensor);
%
%  obj = vcGetObject('vcimage'); [rgb,locs] = ieMacbethSelect(obj); 
%  dataXYZ = imageRGB2xyz(obj,rgb); whiteXYZ = dataXYZ(1,:);
%  lab = xyz2lab(dataXYZ,whiteXYZ);
%  plot3(lab(:,1),lab(:,2),lab(:,3),'o')
%
% This method is used to get the raw data of the gray series
%   mRGB = ieMacbethSelect(obj,0,1);
%   graySeries = mRGB(1:4:24,:);
%
% See also:  macbethSensorValues
%
%  Example:
%     showSelection = 1;
%     obj = vcGetObject('vcimage');
%     [mRGB mLocs, pSize, cornerPoints]= ieMacbethSelect(obj,showSelection);
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('obj'), obj = vcGetObject('vcimage'); end
if ieNotDefined('showSelection'), showSelection = 1; mccRectHandles = []; end
if ieNotDefined('fullData'), fullData = 0; end
if ieNotDefined('cornerPoints'), queryUser = true; else queryUser = false;end

% obj is either a vcimage or a sensor image
switch lower(obj.type)
    case 'vcimage'
        handles = ieSessionGet('vcimagehandles');
        dataType = 'result';
        obj = imageSet(obj,'mccRectHandles',[]);
        vcReplaceObject(obj);
        if ieNotDefined('cornerPoints')
            cornerPoints = imageGet(obj,'mcc corner points');
        end
        
    case {'isa','sensor'}
        handles = ieSessionGet('sensorWindowHandles');
        dataType = 'dvorvolts';
        obj = sensorSet(obj,'mccRectHandles',[]);
        vcReplaceObject(obj);
        if ieNotDefined('cornerPoints')
            cornerPoints = sensorGet(obj,'mcc corner points');
        end
        
    otherwise
        error('Unknown object type');
end

% If the user didn't send in any corner points, and there aren't in the
% structure, go get them from the user in the window.
if isempty(cornerPoints)
    cornerPoints = vcPointSelect(obj,4,...
        'Select (1) white, (2) black, (3) blue, (4)brown');
end

% We have cornerpoints for sure now.  Set them and draw the Rects.
switch vcEquivalentObjtype(obj.type)
    case 'VCIMAGE'
        obj = imageSet(obj,'mcc corner points',cornerPoints);
    case 'ISA'
        obj = sensorSet(obj,'mcc corner points',cornerPoints);
end
%

% Ask the user if a change is desired.  The olds one from the structure may
% not be satisfactory.
if queryUser, 
     macbethDrawRects(obj);
     b = ieReadBoolean('Are these rects OK?');
else          b = true; 
end

if isempty(b)
    fprintf('%s: user canceled\n',mfilename);
    mRGB=[]; mLocs=[]; pSize=[]; cornerPoints=[]; mccRectHandles =[];
    return;
elseif ~b  % False, a change is desired
    switch vcEquivalentObjtype(obj.type)
        case {'VCIMAGE'}
            vcimageWindow;
        case {'ISA'};
            sensorImageWindow;
        otherwise
            error('Unknown type %s\n',obj.type);
    end
    
    % These appear to come back as (x,y),(col,row).  The upper left of the
    % image is (1,1).
    cornerPoints = vcPointSelect(obj,4,...
        'Select (1) white, (2) black, (3) blue, (4)brown');
    % should be an imageSet
    obj = imageSet(obj,'mcc corner points',cornerPoints);
end

ieInWindowMessage('',handles);

% Find rect midpoints and patch size
[mLocs,delta,pSize] = macbethRectangles(cornerPoints);

% Get the mean RGB data or the full data from the patches in a cell array
mRGB = macbethPatchData(obj,mLocs,delta,fullData,dataType);

% Plot the rectangle that encloses these points.
if showSelection, macbethDrawRects(obj); end

ieInWindowMessage('',handles);

return;

