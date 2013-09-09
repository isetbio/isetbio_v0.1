function lut = ieLUTInvert(inLUT,resolution)
% Invert a lookup table (lut) at a specified sampling resolution
%
%    lut = ieLUTInvert(inLUT,resolution)
%
% inLUT:      A gamma table that converts DAC values to linear RGB.
% resolution: The display bit depth is log2(size(DAC,1)).  We are going to
%   make an inverse table with finer resolution.  
%
% lut:  The returned lookup table converts linear RGB to DAC values
%   If resolution = 2, then we have twice the number of levels in the
%    returned table.
%
% Example:
%   d = displayCreate;
%   inLUT = d.gamma.^0.6;
%   lut = ieLUTInvert(inLUT,3);
%   vcNewGraphWin; plot(lut)
%
% See also:  ieLUTDigital, ieLUTLinear
%
% (c) Imageval Consulting, LLC 2013

if ieNotDefined('inLUT'), error('input lut required'); end
if ieNotDefined('resolution'), resolution = 0.5; end

x     = 1:size(inLUT,1);
nbits = log2(size(inLUT,1));
m     = 2^nbits - 1;
iY    = (0:(1/resolution):m)/(2^nbits);

lut = zeros(length(iY),size(inLUT,2));
for ii = 1:size(inLUT,2)
    y = inLUT(:,ii);   
    lut(:,ii) = interp1(y,x,iY,'cubic',m);
end

end
