function scene = sceneCreateMacbeth(surface,lightSource,scene)
% Create a hyperspectral scene of the Macbeth chart.
%   
%   scene = sceneCreateMacbeth(surface,lightSource,[scene])
%
% The surface reflectances and light source are specified as arguments.
% The color signal is computed (in photons); these values are then
% attached to the scene structure.
%
% Used by the sceneWindow callbacks to create the Macbeth images.
%
% Copyright ImagEval Consultants, LLC, 2005.

% Starting to fix in 2012.  lightSource will beccome a standard illuminant
% structure.
% The only place this function is called from is sceneCreate.
%
% Programming notes:
%   This code is prior to the modern ISET development.  
%   As it stands, it requires some fields that are not present elsewhere in
%   the code:
%     lightSource.spectrum and surface.spectrum
%     lightSource.data.photons
%     surface.data
%   This routine should be re-written to conform to more modern structures
%   in ISET.

if ~checkfields(lightSource,'spectrum'), error('Bad light source description.');
elseif ~checkfields(surface,'spectrum'), error('Bad surface description.');
elseif ~isequal(lightSource.spectrum.wave(:),surface.spectrum.wave(:))
    error('Mis-match between light source and object spectral fields')
end

% This is particularly unclear code because of the way the Macbeth surfaces
% are stored on disk.  That should change.  I believe what is happening is
% we take the light source in photons and we make it the same size and
% shape as the surface data.  Then we multiply point by point.
% photons = lightSource.data.photons(:,ones(1,r*c));
% photons = reshape(photons,[size(surface.data,3) c r]);
% photons = permute(photons,[3 2 1]);
% [photons/(s sr m^2 nm)]
iPhotons = illuminantGet(lightSource,'photons');
[surface,r,c] = RGB2XWFormat(surface.data);
sPhotons = surface*diag(iPhotons);
sPhotons = XW2RGBFormat(sPhotons,r,c);

% We compute the product of the surface reflectance and illuminant photons
% here
% scene = sceneSet(scene,'cphotons',surface.data .* photons);
scene = sceneSet(scene,'photons',sPhotons);

% Store the light source
scene = sceneSet(scene,'illuminant',lightSource);

return;
