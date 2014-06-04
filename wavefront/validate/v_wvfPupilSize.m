%% v_wvfPupilFunction
%
% Explore the effect of pupil size.
%
%
% (BW) (c) Wavefront Toolbox Team, 2014

%% 
s_initISET

%% Set values in millimeters
pupilMM = 7.5; wave = (400:10:700)';
zCoefs = wvfLoadThibosVirtualEyes(pupilMM);
wvfP = wvfCreate('wave',wave,'zcoeffs',zCoefs,'name',sprintf('human-%d',pupilMM));
wvfP = wvfSet(wvfP,'measured pupil',6);

%%
cPupil = [2,3,4,5,6,];
for ii=1:length(cPupil);
    wvfP = wvfSet(wvfP,'calculated pupil',cPupil(ii));
    wvfP = wvfComputePSF(wvfP);
    wvfPlot(wvfP,'2d psf space','um',550,20)
    title(sprintf('Calculated pupil %.1f',cPupil(ii)));
end

%% End