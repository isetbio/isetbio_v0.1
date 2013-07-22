function dataXYZ = imageDataXYZ(vci,roiLocs)
%Return the XYZ values of  display data 
%
%    dataXYZ = imageDataXYZ(vci,[roiLocs])
%
% The data are contained in the result field.  If roiLocs are passed in,
% the data are returned in XW format.  If roiLocs are not passed in, the
% data are returned in RGB (r,c,w)-format .
%
% Example:
%   [val,vci] = vcGetSelectedObject('VCIMAGE');
%   xyzRGB = imageDataXYZ(vci);
%      
%   roiLocs = vcROISelect(vci);
%   xyzXW = imageDataXYZ(vci,roiLocs);
%
% Copyright ImagEval Consultants, LLC, 2005.

g = imageGet(vci,'display gamma');
if ieNotDefined('roiLocs')
    % Get the rgb data (sRGB or other nonlinear format)
    data = imageGet(vci,'result');
    % Apply gamma correction
    data = dac2rgb(data,g);
    
    % Transform
    [data,r,c] = RGB2XWFormat(data);
    dataXYZ = imageRGB2XYZ(vci,data);
    dataXYZ = XW2RGBFormat(dataXYZ,r,c);
else
    % The data are returned in XW format
    data = vcGetROIData(vci,roiLocs,'result');
    dataXYZ = imageRGB2XYZ(vci,data);
end

return;
