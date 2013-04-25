function [luminance,meanLuminance] = sceneCalculateLuminance(scene)
% Calculate scene luminance (cd/m^2) 
%
%  [luminance,meanLuminance] = sceneCalculateLuminance(scene)  
%
% Calculate the luminance (cd/m^2) at each point in a scene.
%
% Calculations of the scene luminance usually begin with
% photons/sec/nm/sr/m^2 (radiance).  These are converted to energy, and
% then transformed with the luminosity function and wavelength sampling
% scale factor. 
% 
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('scene'), error('Scene variable required.'); end

nCols    = sceneGet(scene,'cols');
nRows    = sceneGet(scene,'rows');
nWaves   = sceneGet(scene,'nwave');
sWavelength = sceneGet(scene,'wave');
binWidth = sceneGet(scene,'binwidth');

% Read the V-lambda curve based from the photopic luminosity data at the
% relevant wavelengths for these data
fName = fullfile(isetRootPath,'data','human','luminosity.mat');
V = ieReadSpectra(fName,sWavelength);

%h = waitbar(0,'Calculating luminance from photons');

% Calculate the luminance from energy
try
    % If the image is small enough, we calculate luminance using a single
    % matrix multiplication.  We don't set a particular criterion size
    % because that may differ depending on memory in that user's computer.
    energy = sceneGet(scene,'energy');
    if isempty(energy)
       % waitbar(0.3,h);
        wave = sceneGet(scene,'wave');
        photons = sceneGet(scene,'photons');
        energy = Quanta2Energy(wave(:),photons);
    end

   % waitbar(0.7,h);

    [xwData rows,cols,w] = RGB2XWFormat(energy);

    % Convert into luminance using the photopic luminosity curve in V.
    luminance = 683*(xwData*V) * binWidth;
    luminance = XW2RGBFormat(luminance,rows, cols);

catch ME
    % We think we are in this condition because the image is big.  So we
    % convert to energy one waveband at a time and sum  the wavelengths
    % weighted by the luminance efficiency function.  When the photon image
    % is really big, should we figure that there is no stored energy?
    energy = sceneGet(scene,'energy');
    if isempty(energy)
       % waitbar(0.3,h);
        wave = sceneGet(scene,'wave');
        luminance = zeros(nRows,nCols);
        for ii=1:nWaves
            photons = sceneGet(scene,'photons',wave(ii));
            luminance = ...
                luminance + 683*Quanta2Energy(wave(ii),photons)*V(ii)*binWidth;
        end
    else
        ME.identifier
        fprintf('ISET: Surprised to find such a big image with energy stored')
    end

end


% Close the waitbar
%close(h);

if nargout == 2,  meanLuminance = mean(luminance(:)); end

return;
