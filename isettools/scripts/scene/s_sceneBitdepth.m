%% s_sceneBitdepth
%
% We illustrate using a bit depth of 16 bits, rather than the default of 32
% bits.
%
% (c) Imageval Consulting, LLC 2012

%%
s_initISET

%%
scene   = sceneCreate('default','bit depth',16);
scene.data

vcAddAndSelectObject(scene);
sceneWindow;

%%
oi = oiCreate;
oi = oiSet(oi,'bit depth', 16);
oi = oiCompute(oi,scene);
oi.data

vcAddAndSelectObject(oi);
oiWindow;

%% 
sensor = sensorCreate;
sensor = sensorCompute(sensor,oi);
vcAddAndSelectObject(sensor);
sensorWindow;
%% End