%% t_opticsDiffraction
%
% Calculate images using diffraction limited optics and a few simple
% examples.
%
% (c) Imageval Consulting, LLC, 2012

%%
s_initISET

%%
scene = sceneCreate('point array');
scene = sceneSet(scene,'h fov',2);
vcAddAndSelectObject(scene); sceneWindow;

oi = oiCreate;
optics = oiGet(oi,'optics');

oi = oiCompute(oi,scene);
oi = oiSet(oi,'name','Default f/#');
vcAddAndSelectObject(oi);
oiWindow;
opticsGet(optics,'f number')

%% Now, create diffraction limited optics with f/# of 12
% The larger f/# blurs the image more 
% It has larger depth of field, however, because the aperture is smaller.

optics = opticsSet(optics,'f number',12);
oi = oiSet(oi,'optics',optics);
oi = oiSet(oi,'name','Large f/#');
oi = oiCompute(oi,scene);

vcAddAndSelectObject(oi);
oiWindow;

% Check the inter-related parameters
p = opticsGet(optics,'pupil diameter','mm')
f = opticsGet(optics,'focal length','mm')
f/p


%%  How the diffraction-limited blur depends on wavelength

vcNewGraphWin;
uData = plotOI(oi,'ls wavelength');
title(sprintf('F/# = %.0d',opticsGet(optics,'f number')))

% Look at the returned data structure
uData

