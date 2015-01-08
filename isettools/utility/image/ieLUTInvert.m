function lut = ieLUTInvert(inLUT, resolution)
%% Calculate inverse lookup table (lut) at a specified sampling resolution
%
%    lut = ieLUTInvert(inLUT,resolution)
%
% Inputs:
%   inLUT:      gamma table that converts linear DAC values to linear RGB.
%   resolution: sampling resolution, the returned gamma table is sampled at
%               the number of points specified by resolution.  If resolution
%               is not passed, then default is the number of samples in 
%               inLUT.
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
%
% 1/7/15  dhb  Changed convention for passed resolution to be the number of
%              samples in the returned table.

%% Get input size
nSteps = size(inLUT, 1);

%% Check inputs
if notDefined('inLUT'), error('input lut required'); end
if notDefined('resolution'), resolution = nSteps; end

%% Computes inverse gamma table
%  Loop over primaries
y  = 1 : nSteps;
iY = linspace(0,(nSteps-1)/nSteps,nSteps);
lut = zeros(length(iY), size(inLUT, 2));
for ii = 1 : size(inLUT, 2)
    % sort inLUT, theoretically, inLUT should be monochrome increasing, but
    % sometimes, the intensity at very low light levels cannot be measured
    % and we just set all of them to 0
    [x, indx] = unique(inLUT(:, ii));
    lut(:, ii) = interp1(x, y(indx), iY(:), 'pchip', nSteps-1);
end

end