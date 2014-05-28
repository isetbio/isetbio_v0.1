function scene = sceneFromFont(font,display)
% Create a scene from a font and display
%
%  scene = sceneFromFont(font,display)
%
% (BW) Vistasoft group, 2014

%% Input arguments
if ieNotDefined('font'), font = fontCreate; end
if ieNotDefined('display'), display = displayCreate('LCD-Apple'); end

%%

bitMap = fontGet(font,'bit map');

% Now convert the bitmap to the black/white rendering on the display

% Now convert the display, using the psf and so forth to the spectral
% radiance in photons

% Shove it all into the scene structure whose wave matches the display.



% Adjust fov of scene.  Maybe adjust the luminance, too, depending on the
% number of black pixels or something.
sz = max(size(fontBitmap));
vDist = sceneGet(scene, 'distance');

fov = atand(dpi2mperdot(displayGet(display, 'dpi'), 'meters') * sz/vDist);

scene = sceneSet(scene, 'h fov', fov);
        
end


% cd '/Users/wandell/Github/ctToolbox/FontCache'

