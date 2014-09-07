%% TODO
%
% Make v_ptbIsetbioIrradiance a function within this file,
% and then have a top level function that uses the validation
% object to call/validate it.
%
% Probably validation scripts should not make plots unless a flag
% is set.  That's because plotting is slow and we want validations
% to be quick.  So there should be some sort of DO_PLOTS flag.  The
% plots are useful when writing the validation scripts, and will also
% be useful if the validations ever fail.
%
% Default for running a validation script should be for it not to
% ask anything.  But there needs to be some standard way to have it
% be told to save its data out for future validation.
%
% When a script tests multiple things, probably it should run them
% all and then give a full report at the end.  So we want a clean
% convention about what the subfunction will return (a results structure?)
% and then have the calling function at the top print out a helpful table
% of what happened.
%
% We want a nice system to generate documentation of what validation scripts
% there are, somewhat like the color book example.


%% v_ptbIsetbioIrradiance
%
% Compare radiance to irradiance in PTB and Isetbio.
%
% DHB/BW/HJ Copyright ISETBIO Team, 2013

%% Standard initialize
s_initISET

%% Parameters
DO_PLOTS = false;
roiSize = 5;

%% Create a radiance image in isetbio
scene = sceneCreate('uniform ee');    % Equal energy
scene = sceneSet(scene,'name','Equal energy uniform field');
scene = sceneSet(scene,'fov',20);     % Big field required

% Plot of the spectral radiance function averaged within an roi
sz = sceneGet(scene,'size');
rect = [sz(2)/2,sz(1)/2,roiSize,roiSize];
roiLocs = ieRoi2Locs(rect);
radianceData = plotScene(scene,'radiance energy roi',roiLocs);
title(sprintf(sceneGet(scene,'name')));

% Get wavelength and spectral radiance.  
wave  = sceneGet(scene,'wave');
radiance = mean(radianceData.energy(:));

%% Compute the irradiance in isetbio
%
% To make comparison to PTB work, we turn off
% off axis correction as well as optical blurring
% in the optics.
oi     = oiCreate('human');
optics = oiGet(oi,'optics');
optics = opticsSet(optics,'off axis method','skip');
optics = opticsSet(optics,'otf method','skip otf');
oi     = oiSet(oi,'optics',optics);
oi     = oiCompute(oi,scene);

% Show the optical image
if (DO_PLOTS)
    vcAddAndSelectObject(oi); oiWindow;
end

%% Extract isetbio spectral irradiance from the roi
%
% Need to recenter roi because the optical image is
% padded to deal with optical blurring at its edge.
sz         = oiGet(oi,'size');
rect       = [sz(2)/2,sz(1)/2,roiSize,roiSize];
roiLocs    = ieRoi2Locs(rect);
irData = plotOI(oi,'irradiance energy roi',roiLocs);
title(sprintf(oiGet(oi,'name')));

% Get spectral irradiance
irradiance = mean(irData.y(:));

%% PTB calculation
%
% Get the underlying parameters that are needed from the
% isetbio structures.
%
% The integration time doesn't affect the irradiance, but we
% need to pass it 
optics = oiGet(oi,'optics');
pupilDiameterMm    = opticsGet(optics,'pupil diameter','mm');
focalLengthMm      = opticsGet(optics,'focal length','mm');

% The PTB calculation is encapsulated in ptb.ConeIsomerizationsFromRadiance.
% This routine also returns cone isomerizations, which we are not validating
% here.
%
% The macular pigment and integration time parameters affect the isomerizations,
% but don't affect the irradiance returned by the PTB routine.
macularPigmentOffset = 0;
integrationTimeSec   = 0.05;
[isoPerCone, ~, ptbPhotoreceptors, ptbIrradiance] = ...
    ptb.ConeIsomerizationsFromRadiance(radiance(:), wave(:),...
    pupilDiameterMm, focalLengthMm, integrationTimeSec,macularPigmentOffset);

%% Compare the irradiances as computed directly. 
%
% They are similar, but differ by more than it would seem they ought to. 
vcNewGraphWin; plot(wave,ptbIrradiance(:),'ro',wave,irradiance(:),'ko');
set(gca,'ylim',[0 max(ptbIrradiance(:))*1.5]);
legend('PTB','ISETBIO')
xlabel('Wave (nm)'); ylabel('Irradiance (q/s/nm/m^2)')
title('Without magnification correction');

%% Aaccounts for the magnification difference
%
% The magnification difference results from how Peter Catrysse implemented the radiance to irradiance
% calculation in isetbio versus the simple trig formula used in PTB. Correctig for this reduces the difference
% to about 1%.
m = opticsGet(optics,'magnification',sceneGet(scene,'distance'));
ptbMagCorrectIrradiance = ptbIrradiance(:)/(1+abs(m))^2;
vcNewGraphWin;
plot(wave,ptbMagCorrectIrradiance,'ro',wave,irradiance(:),'ko');
set(gca,'ylim',[0 max(ptbIrradiance(:))*1.5]);
xlabel('Wave (nm)'); ylabel('Irradiance (q/s/nm/m^2)')
legend('PTB','ISETBIO')
title('Magnification corrected comparison');

%% Numerical check to decide whether we passed.
tolerance = 0.01;
difference = ptbMagCorrectIrradiance-irradiance;
if (max(abs(difference./irradiance)) > tolerance)
    error('Difference between PTB and isetbio irradiance exceeds tolerance');
else
    fprintf('Validation PASSED: PTB and isetbio agree about irradiance to %0.0f%%\n',round(100*tolerance));
end

% % ptb effective absorbtance
% ptbCones = ptbPhotoreceptors.isomerizationAbsorptance'; % Appropriate for quanta
% 
% %%  ISETBIO sensor absorptions
% %
% sensor    = sensorCreate('human');
% sensor    = sensorSet(sensor,'macular density',0.35);
% isetCones = sensorGet(sensor,'spectral qe');
% isetCones = isetCones(:,2:4);
% 
% %% Compare PTB sensor spectral responses with ISETBIO
% vcNewGraphWin; plot(wave, isetCones);
% hold on; plot(wave, ptbCones, '--');
% 
% vcNewGraphWin; plot(wave,ptbCones);
% plot(ptbCones(:),isetCones(:),'o');
% hold on; plot([0 1],[0 1], '--');
% xlabel('PTB cones');
% ylabel('ISET cones');
% 
% 
% %% End
