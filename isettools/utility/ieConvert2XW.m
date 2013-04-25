function xwData = ieConvert2XW(data,wave)
% OBSOLETE.
% Convert data to XW (space-wavelength) format, when you are unsure of
% input format
%
%   xwData = ieConvert2XW(data,wave)
%
% In a few cases the data can be either XW or RGB.  We don't want to
% figure out which format it is.  So, we force RGB or XW data into XW
% format.  Thus, if the input are XW data they are left unchanged. If the
% input are RGB data, they are converted. 
%
% Examples:   
%   xwData = ieConvert2XW(scene.data.energy,scene.spectrum.wave)
%
% See also:  RGB2XWFormat, ieLuminanceFromEnergy,
%            ieScotopicLuminanceFromEnergy, ieXYZFromEnergy
%
% Copyright ImagEval Consultants, LLC, 2003.

error('Obsolete');

% 
% iFormat = vcGetImageFormat(data,wave);
% switch iFormat
%     case 'RGB'
%         % [rows,cols,w] = size(data);
%         xwData = RGB2XWFormat(data);
%     case 'XW'
%         xwData = data;
%     otherwise
%         error('Unknown image format.');
% end
% 
% return;
