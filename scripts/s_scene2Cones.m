% s_rgcScene2ConesEyeMovements
%
% The calculation from a scene to the quantum absorptions in a cone array,
% allowing for small, fixational eye movements
%
% See also: s_rgcScene2Cones (without eye movments) and s_rgcCones2RGC for
% the next steps.
%
% (c) Stanford VISTA Team

%%
s_initISET;


%% User-adjustable parameters
% The script is getting long. Let's list all adjudtable parameters at the
% top. The rest of the script will do the computations and display the
% resutls.

% ---- Scene ----------
im          = 'eagle.jpg';
% fov         = 2;               % deg. Make sure we have plenty of scene samples per cone sample. By making the FOV small, we get plenty.
% im          = 'edge.jpg';
fov         =  0.4;            % shrink the fov to speed up calculations? 
dCal        = 'lcdExample.mat'; % Which display?
illuminant  = 'D65.mat';        % Change illuminant? Leave empty to stick with display parameters
meanL       = 500;              % Make bright for faster run time. Set empty to derive mean luminance from calibration file
vd          = 2;                % Viewing distance- Two meters

% ---- Sensor ----------
coneAperture   = 2e-6;          % um
voltageSwing   = 0.1;           % 100 mV to saturation
readNoise      = 0.0005;        % Noise sd on a read 1 mV

% ---- Eye movements -----
% We assume the eye makes small movements around fixation. We encode the
% dwell time (frames) and position (degrees) of each fixation.  Perhaps
% these should be added to the sensor structure?
% Eye movement structure
n = 10;
emove.pos               = randn(n,2)*.05;    % x-pos, in deg (Gaussian sd = .05 deg)
emove.framesPerPosition = ceil(abs(randn(1,n))* 10); % dwell time. must be pos integers. 

% --- Cone Adapation ---
% Now that we simulate eye movmements, perhaps we shoud do adaptation by
% individual cone. If there there are no eye movements, then we would like
% image to fade (cone image becomes uniform, other than noise). 
typeAdapt      = 2;             % 0 = none; 1 = mean; 2 = mean per cone class; 3 = individual cones

%% SCENE

% Create scene from image
fName = fullfile(isetbioRootPath,'data', 'images','RGB',im);
if ~exist(fName, 'file'), fName = which(im); end
if ~exist(fName, 'file'), error('Can''t find image file %s', im); end

scene = sceneFromFile(fName,'rgb',meanL,dCal);  % todo: use gamma table in calibration file
scene = sceneSet(scene,'fov',fov);       %
scene = sceneSet(scene,'distance',vd);  % Two meters
if ~isempty(illuminant), scene = sceneAdjustIlluminant(scene, illuminant); end

vcAddAndSelectObject(scene); sceneWindow;

%% Human Optics

% Create human optics
oi = oiCreate('human');
oi = oiCompute(scene,oi);
vcAddAndSelectObject(oi); oiWindow;


%% Human Sensor

% Figure out the number of cones required to preserve the scene field of
% view and the cone sampling mosaic. There are 330 um per degree in the
% human retina, but our optics are not in precise agreement with this value:
% To cover the scene FOV we need
%   nCones = fov/degPerCone
% and we make it a bit larger

%Initialize default cones  (or should we use sensorCreateConeMosaic.m?)
params              = coneParams(coneAperture,scene);
% Set cone aperture size for simulation
% params.coneAperture = umConeAperture*1e-6;  % In meters

% Create sensor array 10% smaller than the scene so that small eye
% movemements do not move the sensor off the optical image
% vFov = sceneGet(scene,'vfov');
% hFov = sceneGet(scene,'hfov');
% Suppose there are 300 um/deg then there are
% degPerCone = params.coneAperture/300e-6;
% params.sz = floor([(vFov/degPerCone) (hFov/degPerCone)]);
% params.sz = round(params.sz * .9);

% Create the sensor
sensor = sensorCreate('human',[],params);
sensor = sensorSet(sensor,'sensor movement',emove);

% Set the sample (exposure) time for the sensor in the time series
expTs  = 0.001; % seconds - For development we are using 1 ms
sensor = sensorSet(sensor,'expTime',expTs);

% Experimenting with this and RGC thresholds ...
pixel  = sensorGet(sensor,'pixel');

% These parameters determine essentially the intensity resolution of a
% cone. Do we want it to have 8 bits? 10 bits? 4 bits?
pixel  = pixelSet(pixel,'voltageSwing',voltageSwing);
pixel  = pixelSet(pixel,'read noise volts',readNoise); % Noise sd on a read 1 mV
sensor = sensorSet(sensor,'pixel',pixel);

% The conversion gain should be set based on adaptation. Conversion gain is
% like the gain (speed) of the sensor. The adaptation code should interact
% with conversion gain routinely, and change the conversion gain based on
% the time history.
%
% In the future, we could monitor the time history of the absorptions and
% adjust the CG over time. Here, we need to get a quick read of the scene
% and initialize the conversion gain parameter. This is like setting the
% exposure or speed  of a camera
%
% To get started, we put the conversion gain so that the receptor in the
% bright part of the image is at 0.95 saturation capacity with a 50 ms
% exposure.
expTime = autoExposure(oi,sensor,0.95);  % Exposure time to get bright to 0.95 saturation
cg      = pixelGet(pixel,'conversion gain');
cgScale = (expTime/0.050);
pixel   = pixelSet(pixel,'conversion gain',cg*cgScale);
sensor  = sensorSet(sensor,'pixel',pixel);

% pixelGet(pixel,'well capacity')  % number of photons up to saturation

% Alert user to number of sensor samples
fprintf('Sensor row/col: (%.0f, %.0f)\n',sensorGet(sensor,'row'),sensorGet(sensor,'col'));
fprintf('Pixel size: %.2f um\n',pixelGet(sensorGet(sensor,'pixel'),'height','um'));
fprintf('Sensor fov: %f\n',sensorGet(sensor,'fov'));
fprintf('Scene fov: %f\n',sceneGet(scene,'fov'));

% vcAddAndSelectObject(sensor); sensorImageWindow;

% Adjust pixel properties for human (mouse is already adjusted)
%         pixel = sensorGet(sensor,'pixel');
%         pixel = pixelSet(pixel,'darkVoltage',0);
%         pixel = pixelSet(pixel,'readNoiseVolts',0.0005);
%         pixel = pixelSet(pixel,'voltageSwing',0.02);
%         sensor = sensorSet(sensor,'pixel',pixel);
% Source for these values?? Empirical? -EC

% Deactivate noise sources :
%  - dark current : already off
%  - drnu and prnu
%  - fpn column noise : already off
%  - read Noise
% You can turn off shot noise for debugging with
%     sensor = sensorSet(sensor,'shotNoiseFlag', 0);
% if noNoise
%     pixel = sensorGet(sensor,'pixel');
%     pixel = pixelSet(pixel,'readNoiseVolts',0);
%     sensorSet(sensor,'prnuLevel',0);
%     sensorSet(sensor,'dsnuLevel',0);
%     sensor = sensorSet(sensor,'pixel',pixel);
% end


%% Cone Absorptions

% The coneAbsorptions routine handles eye movements also.  If there are
% fields 'frames per position' and 'movement positions' then the returned
% sensor will be a row x col x size(movement positions,1) volume.  Each
% frame corresponds to the absorptions in one movement position.  We should
% probably make a function to play that as a video.
sensor = coneAbsorptions(sensor, oi);
volts  = sensorGet(sensor,'volts');

% Padd the end of the image with a constant
p = oiGet(oi,'photons');
[p,r,c] = RGB2XWFormat(p);
meanP = mean(p,1);
for ii=1:size(p,2)
    p(:,ii) = meanP(ii);
end
p = XW2RGBFormat(p,r,c);
oiPad = oiSet(oi,'photons',p);
% vcAddAndSelectObject(oiPad); oiWindow;

% Turn off eye movements
sensorPad = sensor;
% sensorPad = sensorSet(sensorPad,'frames per position',20);
% sensorPad = sensorSet(sensorPad,'movement positions',[0 0]);
sensorPad = coneAbsorptions(sensorPad, oiPad);
voltsPad = sensorGet(sensorPad,'volts');
volts = cat(3,volts,voltsPad);


%%  Adaptation

% The cone output voltages normally operate in a specific range specified
% by the voltage swing of the receptor.  Suppose we set the voltage range
% for a cone to 0-1V.  Then as the scene illumination level swings across
% many orders of magnitude, we still need the cones to be operating with
% some contrast inside of their 0-1V range.  Otherwise the RGC won't see
% the signals.
%
% In general, we need a model of the cone voltage output that is better
% than the linear model followed by a gain control (adpatation) that we use
% here.  It could be a log-model, for example.
%
% The current cone adaptation model does not have a time-varying element to
% it.  We take the total output from this stimulus and apply the gain to
% it.  We should impose a light and dark adaptation time constants as well.
%
%  typeAdapt = 0 just copy the data into the absorptions structure.
%  typeAdapt = 1 set the average voltage across all cones to 80% of the voltage swing
%  typeAdapt = 2 set the mean voltage within each individual cone type to 80% of the voltage swing
%  typeAdapt = 3 individual cone adaptation model (could be written)


cones       = coneAdaptation(typeAdapt,volts,sensor);
cones.oi    = oi;
cones.scene = scene;

clear oi
clear scene
clear volts;   % Transformed and stored in cones.volts

% After accounting for adaptation, this factor converts from adapted cone
% volts to cone absorptions.  We should store it in the rgcP data
% structure.
%   e = sensorGet(sensor,'electrons');
%   cgV2E = mean(e(:))/mean(cones.data(:))

% figure; hist(cones.data(:),50)
% figure; hist(cones.unadapted(:),50)
% Should we write a coneGet/coneSet and so forth suite?  Or should the cone
% mosaic always be a sensor, really?
%

[p,n,e] = fileparts(im);
cName = sprintf('%sEyeMvmnts.mat',n);
save(fullfile(isetbioRootPath,'tmp',cName),'cones');

%% End here

% Debugging below

%%  Examine the data using s_rgcCones2RGC

% We should create cone visualization routines that don't require going to
% the rgc structure.
% Make a coneVisualize() routine and separate stuff out?

% creating the RGC parameter object
rgcP = rgcParameters;

% The absorptions structure is also the RGC parameter data
rgcP.set('cone voltages',cones.data);
rgcP.set('sensor',cones.sensor);
rgcP.set('oi',cones.oi);

% What is the default?  RGC spacing the same as cone spacing (I think).
rgcP.addLayer('on parasol', 20);  

rgcComputeSpikes(rgcP);

%% Visualize 

rgcVisualize('Cone Voltages',rgcP); 
rgcVisualize('Linear Timeseries',rgcP); 

%% End