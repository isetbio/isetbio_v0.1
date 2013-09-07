%% s_oiDemo
%
% Test optical image functions

% Diffraction limited simulation properties
oi = oiCreate;
plotOI(oi,'otf',[],550);
plotOI(oi,'otf',[],450);

% Human optics
oi = oiCreate('human');
plotOI(oi,'psf',[],420);
plotOI(oi,'psf',[],550);

% Make a scene and show some oiGets and oiCompute work
scene = sceneCreate;
oi = oiCompute(oi,scene);
plotOI(oi,'illuminance mesh linear');


%% Check GUI control
oiWindow;
oiSet([],'gamma',1);
oiSet([],'gamma',0.4);
oiSet([],'gamma',1);

