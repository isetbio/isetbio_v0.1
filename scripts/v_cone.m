%% v_cone
%
% Test cone, lens and macular function calls
%
% BW/HJ ISETBIO Team 2013

%%
sensor = sensorCreate('human');
wave   = sensorGet(sensor,'wave');
human  = sensorGet(sensor,'human');

%%
vcNewGraphWin([],'tall');
subplot(4,1,1)
plot(wave,coneGet(human.cone,'cone spectral absorptance'));
title('Cone spectral absorptance')

subplot(4,1,2)
plot(wave,lensGet(human.lens,'transmittance'))
title('Lens transmittance')

subplot(4,1,3)
plot(wave,macularGet(human.macular,'transmittance'))
title('Macular transmittance')

subplot(4,1,4)
plot(wave,coneGet(human.cone,'absorbance'))
title('Cone-ocular absorbance')

%%
vcNewGraphWin;
s = sensorGet(sensor,'spectral qe');
plot(wave,s)

%% Plot again, but change the macular pigment density to 0

human.macular = macularSet(human.macular,'density',0);

%%

vcNewGraphWin([],'tall');
subplot(4,1,1)
plot(wave,coneGet(human.cone,'cone spectral absorptance'));
title('Cone spectral absorptance')

subplot(4,1,2)
plot(wave,lensGet(human.lens,'transmittance'))
title('Lens transmittance')

subplot(4,1,3)
plot(wave,macularGet(human.macular,'transmittance'))
title('Macular transmittance')

subplot(4,1,4)
plot(wave,coneGet(human.cone,'absorbance'))
title('Cone-ocular absorbance')

%%
vcNewGraphWin;
sensor = sensorSet(sensor,'human',human);

s = sensorGet(sensor,'spectral qe');
plot(wave,s)
title('Spectral QE')

%% End