%% t_coneAdapt
%     This script demonstrates the physiological differential equations
%     based cone adaptation
%
%  (HJ) ISETBIO TEAM, 2014

%% Init
s_initISET;
ieSessionSet('gpu', 0);

%% Compute cone isomerizations
%  The stimulus used here is a step Gabor patch, at 1~500 ms, the stimulus
%  is of mean luminance 50 and at 501 ~1000 ms, the stimulus is of mean
%  luminance 200

% set up parameters for Gabor patch
% There is no temporal drifting now. But we could have that by changing
% phase with time
fov = 2;
params.freq = 6; params.contrast = 1;
params.ph  = 0;  params.ang = 0;
params.row = 256; params.col = 256;
params.GaborFlag = 0.2; % standard deviation of the Gaussian window

% set up scene, oi and sensor
scene = sceneCreate('harmonic', params);
scene = sceneSet(scene, 'h fov', fov);
oi  = oiCreate('wvf human');
sensor = sensorCreate('human');
sensor = sensorSetSizeToFOV(sensor, fov, scene, oi);
sensor = sensorSet(sensor, 'exp time', 0.001); % 1 ms
sensor = sensorSet(sensor, 'time interval', 0.001); % 1 ms

nSteps = 1000;
volts = zeros([sensorGet(sensor, 'size') nSteps]);
stimulus = zeros(1, nSteps);

% compute cone absorptions for each ms
fprintf('Computing cone isomerization:   ');
for t = 1 : nSteps
     fprintf('\b\b\b%02d%%', round(100*t/nSteps));
    if t < nSteps / 2
        % Adjust scene according to time dependence
        % params.ph = t / 666 * pi;
        % scene = sceneCreate('harmonic', params);
        % scene = sceneSet(scene, 'h fov', fov);
        scene = sceneAdjustLuminance(scene, 50);
    else
        scene = sceneAdjustLuminance(scene, 200);
    end
    
    % compute optical image
    oi = oiCompute(scene, oi);
    
    % compute absorptions
    sensor = sensorCompute(sensor, oi);
    volts(:,:,t) = sensorGet(sensor, 'volts');
    stimulus(t)  = median(median(volts(:,:,t)));
end
fprintf('\n');

sensor = sensorSet(sensor, 'volts', volts);
stimulus = stimulus / sensorGet(sensor, 'conversion gain') /...
                sensorGet(sensor, 'exp time');

%% Compute adapated current
[~, cur] = coneAdapt(sensor, 4);

%% Plot
figure; grid on;
t = 1 : nSteps;

%  plot mean input stimulus
subplot(2, 1, 1);
plot(t, stimulus, 'lineWidth', 2);
xlabel('time (ms)'); ylabel('stimulus intensity (P*/s)');

%  plot mean cone current
subplot(2, 1, 2);
meanCur = median(median(cur));
plot(t, meanCur(:), 'lineWidth', 2);
xlabel('time (ms)'), ylabel('adapted repsonse current (pA)');