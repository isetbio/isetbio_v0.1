function scene = sceneInterpolateW(scene,newWave,preserveLuminance)
%Wavelength interpolation for scene image data
%
%    scene = sceneInterpolateW(scene,[newWave],[preserveLuminance=1])
%
% Interpolate the wavelength dimension of a scene. By default, the
% resampled scene has the same mean luminance as the original scene.
%
% Examples:
%   scene = sceneCreate;
%   scene = sceneInterpolateW(scene,[400:10:700]);
%
% Monochromatic scene
%   scene = sceneInterpolateW(scene,550);
%   vcAddAndSelectObject(scene); sceneWindow;
%
% Do not preserve luminance
%   scene = sceneInterpolateW(scene,[400:2:700],0);
%   vcAddAndSelectObject(scene); sceneWindow;
%
% Copyright ImagEval Consultants, LLC, 2003.

%%
if ieNotDefined('preserveLuminance'), preserveLuminance = 1; end
if ieNotDefined('scene'), scene = vcGetSelectedObject('scene');
elseif ~strcmp(sceneGet(scene,'type'),'scene')
    errordlg('sceneInterpolationW structure not a scene!');
end

handles = ieSessionGet('sceneimagehandle');

%% Note the current scene properties
row   = sceneGet(scene,'row');
col   = sceneGet(scene,'col');
curWave = sceneGet(scene,'wave');

% If the user didn't send in new wavelengths, we ask.  This is used in the
% GUI.
if ieNotDefined('newWave')
    prompt={'Start (nm)','Stop (nm)','Spacing (nm)'};
    def={num2str(curWave(1)),num2str(curWave(end)),num2str(sceneGet(scene,'binwidth'))};
    dlgTitle='Wavelength resampling';
    lineNo=1;
    val =inputdlg(prompt,dlgTitle,lineNo,def);
    if isempty(val), return; end
    
    low = str2double(val{1}); high = str2double(val{2}); skip = str2double(val{3});
    if high > low,       waveSpectrum.wave = low:skip:high;
    elseif high == low,  waveSpectrum.wave = low;     % User made monochrome, so onlyl 1 sample
    else
        ieInWindowMessage('Bad wavelength ordering:  high < low. Data unchanged.',handles,5);
        return;
    end
else
    waveSpectrum.wave = newWave;
end


%% Start by getting current data and parameters
photons = sceneGet(scene,'photons');
if ~isempty(photons), 
    meanL   = sceneGet(scene,'meanluminance'); 
end
il = sceneGet(scene,'illuminant');
if ~isempty(il)
    illuminantPhotons = sceneGet(scene,'illuminantPhotons');
end

% Clear the current data before replacing.  This saves memory.
scene = sceneSet(scene,'spectrum',waveSpectrum);
scene = sceneClearData(scene);

% ****
% There is extrapolation below that can be a problem.  Not sure what we
% should do.  We set an extrapval that is very small compared to the true
% data, but not zero.  Zero causes problems with divisions that are hard to
% deal with.
% ****
% We do this to be able to do a 1D interpolation. It is fast ... 2d is
% slow.  The RGB2XW format puts the photons in columns by wavelength. The
% interp1 interpolates across wavelength

%% Interpolate the photons to the new wavelength sampling
if ~isempty(photons)
    photons    = RGB2XWFormat(photons)';
    
    % Here is the extrapval problem
    newPhotons = interp1(curWave,photons,waveSpectrum.wave,...
        'linear',min(photons(:))*1e-3)';
    newPhotons = XW2RGBFormat(newPhotons,row,col);
    scene = sceneSet(scene,'compressedphotons',newPhotons);
    
    % Calculate and store the scene luminance
    scene = sceneSet(scene,'luminance',sceneCalculateLuminance(scene));

end

%% Now create the new illuminant.  This over-writes the earlier one.
if ~isempty(il)
    
    % Interpolate the illuminant data
    newIlluminant = interp1(curWave,illuminantPhotons,...
        waveSpectrum.wave,...
        'linear',min(illuminantPhotons(:)*1e-3)');
    % vcNewGraphWin; plot(waveSpectrum.wave,newIlluminant);
    
    % Update the scene and illuminant spectrum.
    scene = sceneSet(scene,'spectrum',waveSpectrum);
    scene = sceneSet(scene,'illuminant spectrum',waveSpectrum);
    
    % Put in the new illuminant photons
    scene = sceneSet(scene,'illuminantPhotons',newIlluminant');
end

%% Set and then adjust the luminance level

% For broadband scenes, we generally want to preserve the original mean
% luminance (stored in meanL) despite the resampling. In some cases, such
% as extracting a monochrome scene, we might not want to preserve the mean
% luminance.
if preserveLuminance && ~isempty(photons)
    %Lansel added the following if statement.  This was giving an error
    %when doing the following basic call.
    %   thisScene = sceneFromFile('StuffedAnimals_tungsten-hdrs','multispectral');
%     if exist('meanL','var')
        scene = sceneAdjustLuminance(scene,meanL);
%     end
end


return;

