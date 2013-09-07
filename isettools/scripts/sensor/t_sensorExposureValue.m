%% s_ExposureValue
% Tutorial on setting the exposure value and bracketing
%%
%
% Setting the exposure value is an extremely important control decision for
% the camera controller:  image quality depends strongly on this algorithm.
% One of the great values of high-dynamic range sensors is that they are
% robust to exposure value algorithm errors.
%
% The term 'exposure value' refers to the joint setting of exposure time
% and the size of the aperture (f/#).  Longer times and larger apertures
% increase the number of photons incident at the sensor surface.  The
% formula for exposure value and the computation are described in the
% ISET function exposureValue.m.
%
% The goal of the Exposure Value algorithm is to put enough photons into
% the sensor pixels so that the pixels are operating in a high
% signal-to-noise range and are not saturated.  When there is a high
% dynamic range image, it may be impossible for this condition to be
% satisfied for the entire image, so compromises may be made.
%
% Since the exposure value algorithms must operate quickly, and since some
% parts of the image are more important than others, it is common to sample
% only regions near the center of the image.
%
% This script illustrates the effect of different exposure times and f/#
% choices on sample images.
%
% Copyright ImagEval Consultants, LLC, 2010.

%% Initialize ISET, if you like
% ISET; ieMainW('visible','off')

%% Choose an HDR scene
fName = fullfile(isetRootPath,'data','images','multispectral','Feng_Office-hdrs.mat');
scene = sceneFromFile(fName,'multispectral');

fov   = 15; % Set the field of view to 15 deg
scene = sceneSet(scene,'fov',fov);

oi = oiCreate;
oi = oiCompute(scene,oi);

% Notice that this is a very high dynamic range scene.  The window is very
% bright and the region under the desk is very dark.  Set the display Gamma
% value (text at the lower left) to 0.3 to be able to see all the parts of
% the image.
vcAddAndSelectObject(oi); oiWindow;

%% Create a sensor and capture the image

% Here is a VGA sensor
sensor = sensorCreate;
sensor = sensorSetSizeToFOV(sensor,fov,scene,oi);

% Let's use the exposure bracketing feature of ISET sensorCOmpute to
% calculate a series of images at different exposure durations. We can 
% do this with the bracketing method in sensorCompute.
expTimes = [0.005 0.010 0.050 0.100 0.2];
sensor   = sensorSet(sensor,'Exposure Time',expTimes);
sensor   = sensorCompute(sensor,oi);
sensor   = sensorSet(sensor,'ExposurePlane',3);

% Look through the exposure durations in the window
vcAddAndSelectObject(sensor); sensorImageWindow;

%% Convert the images to the display window
vci = vcimageCreate;

% Experimental methods for combining bracketed exposures
vci = imageSet(vci,'Combination Method','longest'); % Longest, unsaturated
vci = vcimageCompute(vci,sensor);

vcAddAndSelectObject(vci); vcimageWindow;

%% END

%% ieMainW
