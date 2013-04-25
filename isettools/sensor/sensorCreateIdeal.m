function sensor = sensorCreateIdeal(sensorType,pixelSizeInMeters,varargin)
%Create an ideal image sensor array (DSNU and PRNU zero). 
%
%  sensor = sensorCreateIdeal(sensorType,pixelSizeInMeters,[cfapattern])
%
%   Create an ideal image sensor array (DSNU and PRNU zero).  The array
%   contains ideal monochrome pixels (no read noise, dark voltage, 100%
%   fill-factor).  Such an array an be used, for example, to calculate 
%   photon noise under some conditions.
%
%   The sensorType can be monochrome,rgb,or human.
%
% Example
%     pixSize = 3*1e-6;
%     sensor = sensorCreateIdeal('monochrome',pixSize);       % 3 micron, ideal monochrome
%     sensor = sensorCreateIdeal('monochrome',pixSize,'rgb'); % 3 micron, ideal rgb pixel
%
%  Or, 3 micron, ideal, stockman, regular grid
%     pixSize = 2*1e-6;
%     sensor = sensorCreateIdeal('human',pixSize,'bayer'); 
%
% Copyright ImagEval Consultants, LLC, 2005

if ieNotDefined('pixelSizeInMeters'), pixelSizeInMeters = 1.5e-6; end
if ieNotDefined('sensorType'), sensorType = 'monochrome'; end

switch lower(sensorType)
    case 'monochrome'
        sensor = sensorCreate('monochrome');
        sensor = sensorSet(sensor,'name','Monochrome');
        
        pixel = sensorGet(sensor,'pixel');
        sensor = sensorSet(sensor,'pixel',idealPixel(pixel,pixelSizeInMeters));
        
    case {'rgb','color'}
        sensor = sensorCreate('bayer');
        sensor = sensorSet(sensor,'name','Bayer-3um');
        
        % Make the ideal pixel.
        pixel = sensorGet(sensor,'pixel');
        sensor = sensorSet(sensor,'pixel',idealPixel(pixel,pixelSizeInMeters));

        % These are standard RGB filters
        fname = fullfile(isetRootPath,'data','sensor','RGB.mat');
        sensor = sensorReadFilter('colorfilter',sensor,fname);
        cf = sensorGet(sensor,'filterspectra');
        cf = sensorEquateTransmittances(cf);
        sensor = sensorSet(sensor,'filterspectra',cf);
        
        % Put in an infrared color filter
        fname = fullfile(isetRootPath,'data','sensor','infrared2.mat');
        sensor = sensorReadFilter('infrared',sensor,fname);

    case {'human'}
        % Stockman fundamentals, 0.3 peak absorption, either a regular or
        % random mosaic.
        if isempty(varargin), sensorType = 'bayer'; 
        else sensorType = varargin{1};
        end
        
        sensor = sensorCreate(sensorType);
        sensor = sensorSet(sensor,'name','human-ideal');
        
        % Make the ideal pixel.
        pixel  = sensorGet(sensor,'pixel');
        sensor = sensorSet(sensor,'pixel',idealPixel(pixel,pixelSizeInMeters));

        % These are standard RGB filters
        fname = fullfile(isetRootPath,'data','human','stockman.mat');
        sensor = sensorReadFilter('colorfilter',sensor,fname);
        cf = sensorGet(sensor,'filterspectra');
        cf = cf/3;  % Human LMS peak is about 0.35 absorptions
        sensor = sensorSet(sensor,'filterspectra',cf);
                
    otherwise
        error('Unknown sensor type.');
end

return;

function pixel = idealPixel(pixel,pixelSizeInMeters)
%
% Ideal (noise-free) pixel 

pixel = pixelSet(pixel,'readNoiseVolts',0);
pixel = pixelSet(pixel,'darkVoltage',0);
pixel = pixelSet(pixel,'height',pixelSizeInMeters);
pixel = pixelSet(pixel,'width',pixelSizeInMeters);
pixel = pixelSet(pixel,'pdwidth',pixelSizeInMeters);
pixel = pixelSet(pixel,'pdheight',pixelSizeInMeters);
pixel = pixelPositionPD(pixel,'center');
pixel = pixelSet(pixel,'darkVoltage',0);
pixel = pixelSet(pixel,'voltage swing',1e6);

return;
        