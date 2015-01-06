function DAC = ieLUTLinear(RGB, invGammaTable)
%% Convert linear RGB values through a gamma table to DAC values
%
%   DAC = ieLUTLinear(RGB, invGammaTable)
%
% The RGB values are assumed to be in the range of [0,1]. They are assumed
% to be linear with respect to radiance (intensity). The input RGB should
% be an M x N x nPrimaries 3D matrix. In general, if RGB is a vector or 2D
% matrix, only the gamma table for the first primary will be used. However,
% if the input is Nx3 or 3x1, we help reshape it to Nx1x3 or 1x1x3.
%
% The returned DAC values are digital values with a bit depth that is
% determined by the entries in the gTable. The size of returned DAC will
% always be the same as input RGB.
%
% We define
%  * The gamma table maps the digital values to the display intensity.
%  * The inverse gamma table maps the display intensity to the digital
%    values.
%
%  We expect a gTable to have size 2^nBits x nPrimaires.  If the gTable has
%  size 2^nBits x 1, we assume gamma table for all channels are the same.
%  In this application, we expect that gTable to be the inverse gamma
%  table.
%
%  The gamma table is directly stored in display calibration files. And the
%  invert gamma table can be computed via ieLUTInvert.
%
%  If the invGammaTable is a single number, we raise the data to the power
%  invGammaTable.
%  
% See also:
%   ieLUTDigital, ieLUTInvert
%
% Example:
%   d = displayCreate('LCD-Apple');
%   rgb = rand(10,10,3);
%   foo = ieLUTLinear(rgb, displayGet(d, 'inverse gamma');
%   vcNewGraphWin; plot(foo(:),rgb(:),'.')
%
% (c) Imageval Consulting, LLC 2013

%% Init Check inputs
%  check input parameters
if notDefined('RGB'), error('RGB value required'); end
if notDefined('invGammaTable'), invGammaTable = 2.2; end

%  check RGB size
s = size(RGB);
nprimaries = size(invGammaTable, 2);
if numel(RGB) == 3 || numel(RGB) == nprimaries 
    % RGB is passed in as 3 element vector
    RGB = reshape(RGB, [1 1 length(RGB)]);
elseif ismatrix(RGB) && (size(RGB, 2) == 3 || size(RGB, 2) == nprimaries)
    % RGB is passed in as Nx3 matrix
    RGB = reshape(RGB, [size(RGB, 1) 1 size(RGB, 2)]);
elseif ndims(RGB) > 3
    error('Unknown RGB input format');
end

%% Lookup with invert gamma table
if (numel(invGammaTable) == 1)
    % When gamma is a scalar, raise to a power
    DAC = RGB.^invGammaTable;
else
    if size(invGammaTable, 2) == 1
        % If only one column, replicate to number of display primaries
        invGammaTable = repmat(invGammaTable,1,size(RGB,3));
    end
    
    % Scale the linear RGB values so that that largest value, 1 maps to the
    % row size of the gTable.
    RGB = floor(RGB*size(invGammaTable,1)) + 1;
    RGB(RGB > size(invGammaTable, 1)) = size(invGammaTable, 1); % crop 

    % Convert through the gamma table.
    DAC = zeros(size(RGB));
    for ii=1:size(RGB,3)
        thisTable = invGammaTable(:,ii);
        DAC(:,:,ii) = thisTable(RGB(:,:,ii));
    end 
end

%% Reshape DAC to have same size as input RGB
DAC = reshape(DAC, s);

end