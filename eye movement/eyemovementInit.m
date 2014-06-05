function sensor = eyemovementInit(sensor, params)
%% Init eye movement parameters in the sensor structure
%
%   sensor = eyemovementInit(sensor, [params])
%
% Inputs:
%   sensor:  human sensor structure (see sensorCreate)
%   params:  eye-movement parameters, optional, for default value see
%            auxilary function emFillParams below
%     .emType   - 3x1 flag vector, indicating whether or not to include
%                 tremor, drift and micro-saccade respectively
%     .sampTime - sampling time in secs, e.g. 0.001 stands for 1ms per
%                 sample
%     .totTime  - total time of eye-movement sequence in secs, will be
%                 rounded to a multiple of sampTime
%     .tremor   - parameters for tremor, could include
%        .interval   = mean of occurring interval in secs
%        .intervalSD = standard deviation of interval
%        .amplitude  = the randomness of tremor in degrees
%        
%     .drift    - parameters for drift, could include
%        .speed     = speed of the slow drifting
%        .speedSD   = standard deviation of speed
%     .msaccade - parameters for microsaccade, could also be named as
%                 .microsaccade, could include fields as
%        .interval   = mean of occurring interval in secs
%        .intervalSD = standard deviation of interval
%        .dirSD      = the randomness of moving direction
%        .speed      = speed of micro-saccade
%        .speedSD    = standard deviation of speed
%
% Output Parameter:
%   sensor       - sensor with eye movement related parameters set, see
%                  sensorGet for how to retrieve these parameters. Note
%                  that his will not generate the eye-movement sequence,
%                  for generating eye-movement sequence, see emGenSequence
%
% Notes:
%   1) For all eye-movements, we assume that the acceleration time is
%      neglectable
%   2) Drift and tremor can be super-imposed. However, during the time of
%      microsaccade, both drift and tremor are suppressed
%   3) We assume that drift works like a 2D brownian motion. This is
%      reasonable when micro-saccade is present. However, when
%      micro-saccade is suppressed, drift will somehow towards the fixation
%      point. The actual pattern is unknown and this return-to-origin
%      feature is not implemented here.
%   4) For micro-saccade, speed and amplitude follows main-squence as
%      saccade and here, we just use speed
%   5) We don't add a field 'duration' to microsaccade and in computation,
%      the duration of microsaccade will be estimated by the speed and
%      distance between current position to the fixation point
%
% Reference:
%   1) Susana Martinez-Conde et. al, The role of fixational eye movements
%      in visual perception, Nature reviews | neuroscience, Vol. 5, 2004,
%      page 229~240
%   2) Susana Martinez-Conde et. al, Microsaccades: a neurophysiological
%      analysis, Trends in Neurosciences, Volume 32, Issue 9, September
%      2009, Pages 463~475
%
% Example:
%   sensor = eyemovementInit;
%   sensor = sensorCreate('human');
%   sensor = eyemovementInit(sensor);
%   p.emType = ones(3,1);
%   p.totTime = 1;
%   sensor = eyemovementInit(sensor, p);
%
% See also:
%   emGenSequence
%
% (HJ) Copyright PDCSOFT TEAM 2014

warning('This function is under development. Please do not use it');

%% Init
if notDefined('sensor'), sensor = sensorCreate('human'); end
if notDefined('params'), params = []; end

%% Generate eye-movement parameters
params = emFillParams(params);

%% Set eye-movement parameters to sensor
sensor = sensorSet(sensor, 'sample time interval', params.sampTime);
sensor = sensorSet(sensor, 'total time', params.totTime);
sensor = sensorSet(sensor, 'em type', params.emType);
sensor = sensorSet(sensor, 'em tremor', params.tremor);
sensor = sensorSet(sensor, 'em drift', params.drift);
sensor = sensorSet(sensor, 'em microsaccade', params.msaccade);

end

%% Aux-function: generate default params
function params = emFillParams(params)
% Fill in default values for missing fields in params
if notDefined('params'), params = []; end

% set params to default values
% set general fields
p.emType   = zeros(3,1); % emType - no eye movement
p.sampTime = 0.001; % sample time interval - 1 ms
p.totTime  = 5;     % total time of eye-movement - 5 secs

% set fields for tremor
p.tremor.interval   = 0.012;   % Tremor mean frequency - 83 Hz
p.tremor.intervalSD = 0.001;   % std of tremor frequency - 60~100 Hz
p.tremor.amplitude  = 18/3600; % Tremor amplitude - around 1 cones width

% set fields for drift
% There's a big difference for drift speed between literatures, we just
% pick a reasonable value among them
p.drift.speed   = 3/60;   % drift speed - drift mean speed
p.drift.speedSD = 2/60;   % std of drift speed

% set fields for micro-saccades
p.msaccade.interval   = 0.6;   % micro-saccade interval - 0.6 secs
p.msaccade.intervalSD = 0.3;   % std for micro-saccade interval
p.msaccade.dirSD      = 5;     % std for direction
p.msaccade.speed      = 15;    % micro saccade speed - 15 deg/s
p.msaccade.speedSD    = 5;     % std for micro saccade speed

% p.msaccade.duration   = 0.015; % duration of microsaccade


% merge params with default values
if ~isfield(params, 'msaccade') && isfield(params, 'microsaccade')
    params.msaccade = params.microsaccade;
    params = rmfield(params, 'microsaccade');
end
params = setstructfields(p, params);
params.totTime = round(params.totTime/params.sampTime)*params.sampTime;

% some checks for params
assert(numel(params.emType)==3, 'emType should be 3x1 logical vector');

end
%% END