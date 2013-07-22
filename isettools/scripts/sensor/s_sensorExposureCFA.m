%% s_sensorExposureCFA
%
% Illustrate effects of setting CFA exposure separately for each color
% type.  This is set by creating a matrix of exposure times, matched in
% size to the sensor cfa pattern.  The entires of the array specify the
% sensor exposure time for each of the color pixel types.
%
% Copyright Imageval, LLC, 2013

%%
scene  = sceneCreate;
oi     = oiCreate;
oi     = oiCompute(scene,oi);
sensor = sensorCreate;

%% Pretty blue
% Array is GR/BG.  Each time (in ms) is exposure duration for a color type.

% Relatively blue
T1 = [0.04    0.030;
    0.30    0.02];
sensor = sensorSet(sensor,'exposure duration',T1);
sensor = sensorCompute(sensor,oi);
sensor = sensorSet(sensor,'name','Bluish');
vcAddAndSelectObject(sensor);
sensorWindow('scale',1);

%% Red
T1 = [0.04    0.70;
    0.0300    0.02];
sensor = sensorSet(sensor,'exposure duration',T1);
sensor = sensorCompute(sensor,oi);
sensor = sensorSet(sensor,'name','Reddish');
vcAddAndSelectObject(sensor);
sensorWindow('scale',1);

%% End