function xyz = srgb2xyz(srgb)
% Transform srgb to CIE XYZ
%
%    xyz = srgb2xyz(srgb)
% 
% Convert sRGB image into CIE XYZ values. The input (srgb) and output (xyz)
% are NxMx3 RGB Format.
%
% The input range for srgb values is (0,1).
%
% Reference: http://en.wikipedia.org/wiki/SRGB
%
% Copyright ImagEval Consultants, LLC, 2003.

% Data format should be in RGB format
if ndims(srgb) ~= 3
    error('srgb2xyz:  srgb must be a NxMx3 color image.  Use XW2RGBFormat if needed.');
end

% Convert the srgb values to the linear form in the range (0,1)
lrgb = srgb2lrgb(srgb);  %imtool(lrgb/max(lrgb(:)))

% convert lrgb to xyz 
matrix = colorTransformMatrix('lrgb2xyz');
xyz = imageLinearTransform(lrgb, matrix);  

return;

