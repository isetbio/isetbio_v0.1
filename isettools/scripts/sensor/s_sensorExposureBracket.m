%% s_sensorExposureCFA
%
% Illustrate effects of setting exposure bracketing
%
% Copyright Imageval, LLC, 2013

%%
scene  = sceneCreate;
oi     = oiCreate;
oi     = oiCompute(scene,oi);
sensor = sensorCreate;

%% Set a range of exposure times

T1 = [0.02 0.04 0.08 0.16 0.32];
sensor     = sensorSet(sensor,'Exp Time',T1);
nExposures = length(T1);

exposurePlane = floor(nExposures/2) + 1;
sensor = sensorSet(sensor,'Exposure Plane',exposurePlane);
sensor = sensorCompute(sensor,oi);

handle = ieSessionGet('sensor window handle');

cTime = prod(T1)^(1/nExposures);
set(handle.editExpFactor,'val',cTime);

set(handle.editNExposures,'String',num2str(nExposures));
vcAddAndSelectObject(sensor);
sensorWindow('scale',1);

%% End