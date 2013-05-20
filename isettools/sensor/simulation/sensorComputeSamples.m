function voltImages = sensorComputeSamples(sensorNF,nSamp,noiseType,showBar)
%Computing multiple noise samples of the sensor voltage image
%
%  voltImages = sensorComputeSamples(sensorNF,oi,[nSamp = 10],[noiseType=2],[showBar = 1])
%
% Compute multiple noisy samples of the sensor voltage image.  The noise
% free voltages are stored in the input sensor volts. 
%
% The number of noise samples is specified by nSamp.
% The waitbar is shown by default
%
% The voltImages returned is (row,col,nSamp).
%
% Example:
%  Compute Noise Free and then multiple samples
%    sensorNF   = sensorComputeNoiseFree(sensor,oi);
%    voltImages = sensorComputeSamples(sensorNF,100);
%    imagesc(std(voltImages,0,3)); colorbar
%
% Copyright ImagEval Consultants, LLC, 2011.

%% Define parameters
if ieNotDefined('sensorNF'), errordlg('Noise free image sensor array required.'); end
if ieNotDefined('nSamp'),  nSamp = 10; end
if ieNotDefined('noiseType'), noiseType = 2; end  % Photon and electrical
if ieNotDefined('showBar'), showBar = ieSessionGet('waitbar'); end  % Wait bar on by default

%%  Get noise free values
sz = sensorGet(sensorNF,'size');

%% Loop on number of samples to compute only the noise (no reuse)
sensorNF  = sensorSet(sensorNF,'noise flag',noiseType);  % 1 = photon, 2 = all
sensorNF  = sensorSet(sensorNF,'reuse noise',0); % Don't want to reuse

voltImages = zeros(sz(1),sz(2),nSamp);
str = sprintf('Computing %d samples',nSamp);
if showBar, h = waitbar(0,str); end
for kk=1:nSamp
    sensorN = sensorComputeNoise(sensorNF,[]);
    voltImages(:,:,kk) = sensorGet(sensorN,'volts');
    % v2 = voltImages(:,:,kk); v1 = sensorGet(sensorNF,'volts'); 
    % vcNewGraphWin; hist(v1(:)-v2(:),100)
    if ~mod(kk,10) && showBar, waitbar(kk/nSamp); end
end
if showBar, close(h); end

return;


