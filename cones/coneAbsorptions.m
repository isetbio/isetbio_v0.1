function [volts sensor] = coneAbsorptions(sensor, oi)
% Compute sensor voltage image for a given sensor and scene assuming that
% the sensor moves relative to the scene.
% 
%   volts = coneAbsorptions(sensor, oi);
%
% Loop through a number of fixations and calculate the voltage image at
% each position, concatenating the voltage images to (row,col,total nSamp).
% 
% The computational strategy is for each fixation, first calculate
% the mean (noiseless) voltage and then add frame-by-frame noise. To move
% the sensor, we expand it using sensorHumanResize, and then remove
% unneeded rows/columns from the outputted volatge image.
%
% Example: A horizontal eye movement, 2% of the scene FOV
%   scene = sceneCreate;
%   oi = oiCreate;
%   oi = oiCompute(scene,oi);
%   sensor = sensorCreate('human'); 
%   framesPerPosition = [50 50];            % number of frames at each (x,y) position
%   x = [0 .02] * sensorGet(sensor, 'fov'); % x position in degrees
%   y = [0 0];
%   volts = coneAbsorptions(sensor, oi, framesPerPosition, x, y);
%
% See also:  s_rgcScene2Cones, sensorHumanResize, sensorComputeSamples
%
% (c) Stanford VISTA Team


%% check inputs
if notDefined('sensor'), error('Need sensor'); end
if notDefined('oi'), error('Need optical image'); end

% Get and verify eye movement parameters
x = sensorGet(sensor,'sensor positions x');  % In deg of visual angle
y = sensorGet(sensor,'sensor positions y');
framesPerPosition =  sensorGet(sensor,'frames per position');
if ~isequal(length(x), length(y), length(framesPerPosition))
    error('framesPerPosition, x positions, and y positions are not the same lengths');
end

%% Calculate

volts = [];

% convert (x,y) from degrees to (columns, rows). we multiply the number of
% rows and columns by 2 because we will add rows or colums to only one side
% of the sensor (e.g, top or right), which will shift the center of the
% sensor by 1/2 the number of rows or columns added.
fov = sensorGet(sensor, 'fov'); 
sz = sensorGet(sensor, 'size');

xpos = round(2* x * sz(2) / fov); 
ypos = round(2* y * sz(2) / fov); 

% With the noise flag set to 0, we compute only the mean.  No photon noise
% or sensor noise.
sensor = sensorSet(sensor,'noise flag',0);

% loop across positions
for p = 1:length(framesPerPosition)
    
    % if xpos (ypos) is positive, we add columns (rows) to the left 
    % (bottom), shifting the image  rightward (upward). verify this. it
    % could easily be wrong.
    if ypos(p) > 0,  rows = [0 ypos(p)]; else rows = [-ypos(p) 0]; end
    if xpos(p) > 0,  cols = [xpos(p) 0]; else cols = [0 -xpos(p)]; end
    
    % create a new, resized sensor. should we worry about exposure time
    % each time we move (resize) the sensor? 
    sensor2 = sensorHumanResize(sensor,rows, cols);
    
    % compute the noiseless mean
    sensor2 = sensorCompute(sensor2,oi);
    
    % compute the noisy frame-by-frame samples
    noiseType = 1;  % Only photon noise
    tmp = sensorComputeSamples(sensor2,framesPerPosition(p),noiseType);
    
    % remove the added rows/columns
    tmp = tmp(1+rows(1):end-rows(2), 1+cols(1):end-cols(2), :);
   
    % concatenate the voltage image
    volts = cat(3, volts, single(tmp));
    
end

% return the sensor with the voltage data
sensor = sensorSet(sensor, 'volts', volts);

%% End