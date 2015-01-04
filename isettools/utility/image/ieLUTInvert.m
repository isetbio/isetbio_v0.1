function lut = ieLUTInvert(inLUT, resolution)
%% Calculate inverse lookup table (lut) at a specified sampling resolution
%
%    lut = ieLUTInvert(inLUT,resolution)
%
% Inputs:
%   inLUT:      gamma table that converts linear DAC values to linear RGB.
%   resolution: sampling resolution, the returned gamma table is sampled at
%               points 0:1/resolution:2^nbits. If resolution = 2, then we
%               have twice the number of levels in the returned table
%
% Outputs:
%   lut:  The returned lookup table.
%   
% Example:
%   d = displayCreate('OLED-Sony');
%   inLUT = displayGet(d, 'gamma');
%   lut = ieLUTInvert(inLUT, 2);
%   vcNewGraphWin; plot(lut)
%
% See also:
%   ieLUTDigital, ieLUTLinear
%
% (c) Imageval Consulting, LLC 2013

%% Check inputs
if notDefined('inLUT'), error('input lut required'); end
if notDefined('resolution'), resolution = 1; end

%% Computes invert gamma table
%  Loop over primaries
nSteps = size(inLUT, 1);
y  = 1 : nSteps;
iY = (0 : (1/resolution): nSteps - 1)/nSteps;
lut = zeros(length(iY), size(inLUT, 2));
for ii = 1 : size(inLUT, 2)
    % sort inLUT, theoretically, inLUT should be monochrome increasing, but
    % sometimes, the intensity at very low light levels cannot be measured
    % and we just set all of them to 0
    [x, indx] = unique(inLUT(:, ii));
    lut(:, ii) = interp1(x, y(indx), iY(:), 'pchip', nSteps-1);
end

end