%% v_ptbIsetIsomerizations
%
% Confirm that when we start with the same irradiance function we get
% the same number of estimated isomerizations in PTB and ISET.
%
%
% DHB/BW/HJ Copyright ISETBIO Team, 2013


%%
s_initISET

%% Create an radiance image
scene = sceneCreate('uniform ee');    % Equal energy
scene = sceneSet(scene,'fov',20);     % Big field required
wave  = sceneGet(scene,'wave');

sz = sceneGet(scene,'size');
rect = [sz(2)/2,sz(1)/2,5,5];
roiLocs = ieRoi2Locs(rect);
radiance = vcGetROIData(scene,roiLocs,'energy');
radiance = mean(radiance);

vcNewGraphWin; 
plot(wave,radiance); 
xlabel('Wavelength'); ylabel('Radiance (energy)')
set(gca,'ylim',[min(radiance(:))/2 max(radiance(:))*1.5]); grid on

%% Compute the irradiance in ISETBIO
oi     = oiCreate('human');
optics = oiGet(oi,'optics');

% Turn off relative illumination (cos4th)
optics = opticsSet(optics,'off axis method','skip');

% Turn off the OTF
optics = opticsSet(optics,'otf method','skipotf');
oi     = oiSet(oi,'optics',optics);
oi     = oiCompute(oi,scene);
vcAddAndSelectObject(oi); oiWindow;


%% Extract ISETBIO irradiance
sz   = oiGet(oi,'size');
rect = [sz(2)/2,sz(1)/2,2,2];
roiLocs    = ieRoi2Locs(rect);
irradiance = vcGetROIData(oi,roiLocs,'energy');
irradiance = mean(irradiance);
vcNewGraphWin; plot(wave,irradiance); grid on

%% Ratio between ISETBIO radiance and irradiance
vcNewGraphWin; plot(radiance./irradiance)

%% PTB Calculation

optics = oiGet(oi,'optics');
pupilDiameterMm    = opticsGet(optics,'pupil diameter','mm');
focalLengthMm      = opticsGet(optics,'focal length','mm');
integrationTimeSec = 0.05;
m = opticsGet(optics,'magnification',sceneGet(scene,'distance'));

% The v_ptbIsetIrradiance and this differ by about 1 part in 100.  Figure
% out the problem some day.
% [isoPerCone,pupilDiamMm,photoreceptors,irradianceWattsPerM2]
[isoPerCone, ~, ptbPhotoreceptors, ptbIrradiance] = ...
    ptbConeIsomerizationsFromRadiance(radiance(:), wave(:),...
    pupilDiameterMm, focalLengthMm, integrationTimeSec,0);

% ptb effective absorbtance
ptbCones = ptbPhotoreceptors.isomerizationAbsorptance'; % Appropriate for quanta
%ptbCones = [zeros(size(ptbCones,1),1),ptbCones];

%% Compare the irradiances 

% They differ - this time more than I would like.
vcNewGraphWin; plot(wave,ptbIrradiance(:),'ro',wave,irradiance(:),'ko');
set(gca,'ylim',[0 max(ptbIrradiance(:))*1.5]);
legend('PTB','ISETBIO')

% This one accounts for the magnification difference, so they should be
% really close.  But still, they differ by about 1/100.  This may be
% because of some spatial interpolation and blurring that we haven't
% accounted for in the oiCompute/optics.
vcNewGraphWin; 
plot(wave,ptbIrradiance(:)/(1+abs(m))^2,'ro',wave,irradiance(:),'ko');

%%  ISETBIO sensor absorptions
% cone = coneCreate;
% isetCones = coneGet(cone, 'absorptance');

sensor    = sensorCreate('human');
sensor    = sensorCompute(sensor,oi);
isetCones = sensorGet(sensor,'human effective absorptance');

%% Compare PTB sensor spectral responses with ISETBIO
isetCones = isetCones(:,2:4);
vcNewGraphWin; plot(wave, isetCones);
hold on; plot(wave, ptbCones, '--');

vcNewGraphWin; 
plot(ptbCones(:),isetCones(:),'o');
hold on; plot([0 1],[0 1], '--');

%% End
