function [scene,I] = sceneFromFile(I, imType, meanLuminance,dispCal,wList, doSub)
% Create a scene structure by reading data from a file
%
%     [scene,fname,comment] = sceneFromFile(imageData,imageType,[meanLuminance],[dispCal],[wList])
%
% imageData:  Usually the filename of an RGB image.  It is allowed to send
%             in RGB data itself, rather than the file name.
% imageType:  'multispectral' or 'rgb' or 'monochrome'
%             When 'rgb', the imageData might be RGB format.
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
%   fullFileName = vcSelectImage;
%   scene = sceneFromFile(fullFileName,imgType,meanLuminance);
%
%   dispCal = 'OLED-Sony.mat';meanLuminance=[];
%   fName = fullfile(isetRootPath,'data','images','rgb','eagle.jpg');
%   scene = sceneFromFile(fName,'rgb',meanLuminance,dispCal);
%
%   wList = [400:50:700];
%   fullFileName = fullfile(isetRootPath,'data','images','multispectral','StuffedAnimals_tungsten-hdrs');
%   scene = sceneFromFile(fullFileName,'multispectral',[],[],wList);
%
%   dispCal = 'OLED-Sony.mat';meanLuminance=[];
%   fName = fullfile(isetRootPath,'data','images','rgb','eagle.jpg');
%   rgb = imread(fName);
%   scene = sceneFromFile(rgb,'rgb',100,dispCal);
%
%   vcAddAndSelectObject(scene); sceneWindow
%
% Copyright ImagEval Consultants, LLC, 2003.

%% Parameter set up
if notDefined('I')
    % If imageData is not sent in, we ask the user for a filename.
    % The user may or may not have set the imageType.  Sigh.
    if notDefined('imType'), [I,imType] = vcSelectImage;
    else I = vcSelectImage(imType);
    end
    if isempty(I), scene = []; return; end
end
if notDefined('doSub'), doSub = false; end

%% Read the photons and illuminant structure
% Remove spaces and force lower case.
imType = ieParamFormat(imType);

switch lower(imType)
    case {'monochrome','rgb'}  % 'unispectral'
        if ieNotDefined('dispCal')
            warning('Default display lcdExample is used to create scene');
            dispCal = fullfile(isetRootPath,'data','displays','lcdExample.mat');
        end
        
        photons = vcReadImage(I,imType,dispCal, doSub);
        
        % Match the display wavelength and the scene wavelength
        scene = sceneCreate('rgb');
        if ischar(dispCal), d = displayCreate(dispCal);
        elseif isstruct(dispCal) && isequal(dispCal.type,'display'), 
            d = dispCal; 
        end
        
        wave  = displayGet(d,'wave');
        scene = sceneSet(scene,'wave',wave);

        % Set the illuminant SPD to the white point of the display. This
        % also forces the peak reflectance to 1, so we could delete
        % illuminant scaling below.
        
        % Initialize
        il    = illuminantCreate('d65',wave); 
        % Replace default with white point
        il    = illuminantSet(il,'energy',sum(d.spd,2)); 
        scene = sceneSet(scene,'illuminant',il);

    case {'multispectral','hyperspectral'}
        
        if ~ischar(I), error('File name required for multispectral'); end
        if ieNotDefined('wList'), wList = []; end

        scene = sceneCreate('multispectral');
        
        % The illuminant structure has photon representation and a
        % standard Create/Get/Set group of functions.
        [photons, il, basis] = vcReadImage(I,imType,wList);
        
        % vcNewGraphWin; imageSPD(photons,basis.wave);
        
        % Override the default spectrum with the basis function
        % wavelength sampling.  We don't call sceneSet because that both
        % sets the wavelength and interpolates the data.
        % scene.spectrum.wave = basis.wave(:);
        scene = sceneSet(scene,'wave',basis.wave);        
        
        % Set the illuminant structure 
        
    otherwise
        error('Unknown image type')
end

%% Put all the parameters in place and return
scene = sceneSet(scene,'filename',I);
scene = sceneSet(scene,'photons',photons);
scene = sceneSet(scene,'illuminant',il);

% The file name or just announce that we received rgb data
if ischar(I), [~, n, ~] = fileparts(I);
else n = 'rgb image';
end
if exist('d', 'var'), n = [n ' - ' displayGet(d, 'name')]; end
scene = sceneSet(scene,'name',n);     

if ieNotDefined('meanLuminance')                         % Do nothing
else  scene = sceneAdjustLuminance(scene,meanLuminance); % Adjust mean
end

return;
