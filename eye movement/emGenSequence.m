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
pos = sensorGet(sensor, 'sensorpositions');
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
    pos = cumsum(pos, 1);
end

%% Generate eye movement for drift
if emType(2)
    % Load Parameters
    params    = sensorGet(sensor, 'em drift');
    speed     = params.speed * sampTime * mperdeg / coneWidth;
    speedSD   = params.speedSD * sampTime * mperdeg / coneWidth;
    
    % Generate random move at each sample time
    theta = 360 * randn + 0.1 * (1 : seqLen)';
    direction = [cosd(theta) sind(theta)];
    s = speed + speedSD * randn(seqLen, 1);
    pos = filter(1, [1 -1], bsxfun(@times, direction, s)) + pos;
end

%% Generate eye movement for micro-saccade
if emType(3)
    % Load parameters
    params     = sensorGet(sensor, 'em msaccade');
    interval   = params.interval;
    intervalSD = params.intervalSD;
    dirSD      = params.dirSD;
    speed      = params.speed * sampTime * mperdeg / coneWidth;
    speedSD    = params.speedSD * sampTime * mperdeg / coneWidth;
    
    % compute time of occurance
    t = interval + randn(seqLen, 1) * intervalSD;
    t(t < 0.3) = 0.3 + 0.1*rand; % get rid of negative values
    t = cumsum(t);
    tPos = round(t / sampTime);
    tPos = tPos(1:find(tPos <= seqLen, 1, 'last'));
    
    % Compute positions
    for ii = 1 : length(tPos)
        curPos = pos(tPos(ii), :);
        duration = round(sqrt(curPos(1)^2 + curPos(2)^2)/speed);
        direction = atand(curPos(2) / curPos(1)) + dirSD * randn;
        direction = [cosd(direction) sind(direction)];
        direction = abs(direction) .* (2*(curPos < 0) - 1);
        
        offset = zeros(seqLen, 2);
        indx = tPos(ii):min(tPos(ii) + duration - 1, seqLen);
        curSpeed = speed + speedSD * randn;
        if curSpeed < 0, curSpeed = speed; end
        offset(indx, 1) = curSpeed*direction(1);
        offset(indx, 2) = curSpeed*direction(2);
        
        pos = pos + cumsum(offset);
    end
end

%% Set sensor position back to sensor
%  pos = round(cumsum(pos, 1));
pos = round(pos);
sensor = sensorSet(sensor, 'sensorpositions', pos);
end