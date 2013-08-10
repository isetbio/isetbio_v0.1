function RGB = ieLUTDigital(DAC, gTable)
% Convert DAC values to linear RGB values through a gamma table
%
%   RGB = ieLUTDigital(DAC, gTable)
%
% The DAC values are digital values with a bit depth that is determined by
% the device.
%
% Definitions:
%  * The gamma table maps the digital values to the display intensity.
%  * The inverse gamma table maps the display intensity to the digital
%  values.
%
%  We expect a gTable to have size 2^nBits x 3.  If it has size 2^nBits x
%  1, we assume the three channels are the same.  In this application, we
%  expect that the gTable is the gamma table.
%
%  If the gTable is a single number, we raise the data to the power gTable.
%
%  We store the gamma table in display calibration files.  We invert a
%  typical gTable using ieLUTinvert.
%
% The returned RGB values are in the range of [0,1].  They are supposed to
% be linear with respect to radiance (intensity).
%
% See also:  ieLUTLinear, ieLUTInvert
%
% Example:
%   d = displayCreate; n = size(d.gamma,1);
%   dac = floor(n*rand(10,10,3)) + 1;
%   foo = ieLUTDigital(dac, d.gamma);
%   vcNewGraphWin; plot(foo(:),dac(:),'.')
%
% (c) Imageval Consulting, LLC 2013

if (nargin==1), gTable = 2.2; end

if (numel(gTable) == 1)
    % Single number.  Raise to a power.
    RGB = DAC.^(gTable);
    return;
end

if max(DAC(:)) > size(gTable,1)
    error('Max DAC value (%d) exceeds the row dimension (%d) of the gTable',...
        max(DAC(:)),size(gTable,1));
end
if max(gTable(:)) > 1 || min(gTable(:)) < 0
    error('gTable entries should be between 0 and 1.');
end

% Convert through the table
RGB = zeros(size(DAC));
gTable = repmat(gTable,1,size(DAC,3));
for ii=1:size(DAC,3)
    thisTable = gTable(:,ii);
    % DAC values are usually 0 to 255.  We need them to be 1,256
    RGB(:,:,ii) = thisTable(DAC(:,:,ii)+1);
end

end

