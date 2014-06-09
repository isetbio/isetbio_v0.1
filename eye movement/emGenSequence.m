function sensor = emGenSequence(sensor)
%% Generate eye movement sensor sequence
%    sensor = emGenSequence([sensor]);
%
%  Inputs:
%    sensor - human sensor structure, see sensorCreate('human') for detail
%             Here, we require that all the eye-movement related parameters
%             set. For details about the parameters, see eyemovementInit
%             for detail
%
%  Outputs:
%    sensor - human sensor structure with eye movement position sequence
%             set. Position sequence could be retrievedy be
%             sensorGet(sensor, 'sensor positions');
%
%  Example:
%    sensor = sensorCreate('human');
%    sensor = eyemovementInit(sensor);
%    sensor = emGenSequence(sensor);
%
%  See also:
%    eyemovementInit
%
%  (HJ) Copyright PDCSOFT TEAM 2014

%% Init
if notDefined('sensor'), error('human sensor required'); end
rSeed = sensorGet(sensor, 'human rseed');
if isempty(rSeed)
    rSeed = rng;
    sensor = sensorSet(sensor, 'human rseed', rSeed);
else
    rng(rSeed);
end
emType = sensorGet(sensor, 'em type');
if isempty(emType), error('eye movement type not defined'); end

% Init positions
pos = sensorGet(sensor, 'sensor positions');
if isempty(pos), error('sensor positions length unknown'); end
pos = zeros(size(pos));

% Load general parameters
sampTime  = sensorGet(sensor, 'sample time interval');
seqLen    = size(pos, 1);
mperdeg   = vcConstants('mmperdeg') / 1000;
coneWidth = pixelGet(sensorGet(sensor, 'pixel'), 'width');

%% Generate eye movement for tremor
if emType(1)
    % Load parameters
    tremor    = sensorGet(sensor, 'em tremor');
    amplitude = tremor.amplitude * mperdeg / coneWidth; 
    
    % Compute time of tremor occurs
    t = tremor.interval + randn(seqLen, 1) * tremor.intervalSD;
    t(t < 0.001) = 0.001; % get rid of negative values
    t = cumsum(t);
    tPos = round(t / sampTime);
    tPos = tPos(1:find(tPos <= seqLen, 1, 'last'));
    
    % Generate random move on the selected time
    direction = rand(length(tPos),1);
    pos(tPos, :) = amplitude * [direction sqrt(1-direction.^2)];
    pos = pos .* (2*(randn(size(pos))>0)-1); % shuffle the sign
end

%% Generate eye movement for drift
if emType(2)
    % Load Parameters
    params    = sensorGet(sensor, 'em drift');
    speed     = params.speed * sampTime * mperdeg / coneWidth;
    speedSD   = params.speedSD * sampTime * mperdeg / coneWidth;
    
    % Generate random move at each sample time
    direction = rand(seqLen, 1);
    direction = [direction sqrt(1-direction.^2)];
    direction = direction .* (2*randn(size(direction))>0-1);
    pos = pos + (speed + speedSD * randn(seqLen,2)/sqrt(2)) .* direction;
end

%% Generate eye movement for micro-saccade
if emType(3)
end

%% Set sensor position back to sensor
pos = round(cumsum(pos, 1));
sensor = sensorSet(sensor, 'sensor positions', pos);
end