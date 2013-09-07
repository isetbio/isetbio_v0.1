%% s_DemoMicrolens
%
%  Do some calculations with the microlens module
%
% This only runs if you have the microlens license.
%
% Copyright ImagEval Consultants, LLC, 2006

OK = ieKeyVerify('microlens');
if OK{1} == '0'
    disp('You do not have the microlens license.')
    return;
end

% Create a simple sensor and test scene
scene = sceneCreate('slantedBar');
scene = sceneSet(scene,'fov',10);

oi = oiCreate;
oi = oiCompute(scene,oi);
sensor = sensorCreate;
sensor = sensorSet(sensor,'size',[256 256]);
sensor = sensorCompute(sensor,oi);

vcAddAndSelectObject('sensor',sensor); sensorImageWindow;


% Bring up the microlens window
microLensWindow;
mlCompute;
