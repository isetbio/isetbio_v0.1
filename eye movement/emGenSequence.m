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

%% Generate eye movement for tremor
if emType(1)
    tremorP = 
end

end