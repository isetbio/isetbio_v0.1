function [scene,fname,comment] = sceneFromFile(filename,imageType,meanLuminance,dispCal,wList)
% Create a scene structure by reading data from a file
%
%     [scene,fname,comment] = sceneFromFile(filename,imageType,[meanLuminance],[dispCal],[wList])
%
% The data in the image file are converted into spectral format and placed
% in an ISET scene data structure. The allowable imageTypes are monochrome,
% rgb, multispectral and hyperspectral. If you do not specify, and we
% cannot infer, then you may be asked.
%
% If the image is RGB format, you may specify a display calibration file
% (dispCal). This file contains display calibration data that are used to
% convert the RGB values into a spectral radiance image. If you do not
% define the dispCal, the default display file 'lcdExample' will be used.
%
% You may specify the wavelength sampling (wList) for the returned scene.
%
% The default illuminant for an RGB file is the display white point.
% The mean luminance can be set to over-ride this value.
%
%
% Examples:
%   scene = sceneFromFile; 
%   [scene,fname] = sceneFromFile;
%
%   fullFileName = vcSelectImage;
%   imgType = ieImageType(fullFileName);
%   scene = sceneFromFile(fullFileName,imgType);
%
%   imgType = 'multispectral';
%   scene = sceneFromFile(fullFileName,imgType);
%
%   imgType = 'rgb'; meanLuminance = 10;
%   scene = sceneFromFile(fullFileName,imgType,meanLuminance);
%
%   dispCal = 'OLED-SonyBVM.mat';meanLuminance=[];
%   fName = fullfile(isetRootPath,'data','images','rgb','eagle.jpg');
%   scene = sceneFromFile(fName,'rgb',meanLuminance,dispCal);
%
%   wList = [400:50:700];
%   fullFileName = fullfile(isetRootPath,'data','images','multispectral','StuffedAnimals_tungsten-hdrs');
%   scene = sceneFromFile(fullFileName,'multispectral',[],[],wList);
%
%   vcAddAndSelectObject(scene); sceneWindow
%
% Copyright ImagEval Consultants, LLC, 2003.

% TODO
% When imageType is not sent in, we should have a better solution

if ieNotDefined('filename')
    if ieNotDefined('imageType'), [fname,imageType] = vcSelectImage;
    else fname = vcSelectImage(imageType);
    end
    if isempty(fname), scene = []; return; end
else  fname = filename;
end
comment = '';

% Remove spaces and force lower case.
imageType = ieParamFormat(imageType);

switch lower(imageType)
    case {'monochrome','rgb'}  % 'unispectral'
        
        if ieNotDefined('dispCal')
            dispCal = fullfile(isetRootPath,'data','displays','lcdExample.mat');
        end
        photons = vcReadImage(fname,imageType,dispCal);

        % Match the display wavelength and the scene wavelength
        scene = sceneCreate('rgb');
        d     = displayCreate(dispCal);
        wave  = displayGet(d,'wave');
        scene = sceneSet(scene,'wave',wave);

        % Set the illuminant SPD to the white point of the display. This
        % also forces the peak reflectance to 1, so we could delete
        % illuminant scaling below.
        il    = illuminantCreate('d65',wave);
        il    = illuminantSet(il,'energy',sum(d.spd,2));
        scene = sceneSet(scene,'illuminant',il);

    case {'multispectral','hyperspectral'}
        if ieNotDefined('wList'), wList = []; end

        scene = sceneCreate('multispectral');
        
        % The illuminant structure has photon representation and a
        % standard Create/Get/Set group of functions.
        [photons, coef, basis, comment, illuminant] = vcReadImage(fname,imageType,wList);
        
        % Override the default spectrum with the basis function
        % wavelength sampling.
        scene = sceneSet(scene,'wave',basis.wave);        
        
        % Set the illuminant structure 
        scene = sceneSet(scene,'illuminant',illuminant);
        
    otherwise
        error('Unknown image type')
end

% Put all the parameters in place and return
scene = sceneSet(scene,'filename',fname);
scene = sceneSet(scene,'photons',photons);

% No longer needed because the display calibration scales the illuminant
% appropriately (I think, BW).  Delete this in December 2013 if no longer
% needed.
% if ~(strcmpi(imageType,'multispectral') || strcmpi(imageType,'hyperspectral'))
%     % Illuminant scaling must be done after photons are set. The
%     % multispectral data all have an illuminant structure that is set, so
%     % they do not pass through this step.
%     % disp('Scaling illuminant level to make reflectances plausible.')
%     % scene = sceneIlluminantScale(scene);
% end

[p,n] = fileparts(fname);
scene = sceneSet(scene,'name',n);     

if ieNotDefined('meanLuminance')
else scene = sceneAdjustLuminance(scene,meanLuminance);
end

return;
