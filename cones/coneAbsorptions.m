function sensor = coneAbsorptions(sensor, oi, showBar)
% Compute the sensor including eye movements
% 
%   sensor = coneAbsorptions(sensor, oi, [showBar]);
%
% Loop through a number of eye position fixations and calculate the voltage
% image at each position, concatenating the voltage images to
% (row,col,total nSamp).
% 
% The computational strategy is for each fixation, first calculate
% the mean (noiseless) voltage and then add frame-by-frame noise. To move
% the sensor, we expand it using sensorHumanResize, and then remove
% unneeded rows/columns from the outputted volatge image.
%
% The last parameter showBar indicates whether or not to show the progress
% bar. 0 or false for hiding all. true is for displaying the waitBar. Any
% value larger than 2 is for printing progress information into command
% window
%
% Example: A horizontal eye movement, 2% of the scene FOV
%   scene = sceneCreate;
%   oi = oiCreate;
%   oi = oiCompute(scene,oi);
%   sensor = sensorCreate('human'); 
%   xy = [0 0.02; 0 0]* sensorGet(sensor, 'fov'); %(x,y) positions
%   framesPerPosition = [25 25];  % N frames at each (x,y) position
%   sensor = sensorSet(sensor,'frames per position',framesPerPosition);
%   sensor = sensorSet(sensor,'movement positions',xy);
%   sensor = coneAbsorptions(sensor, oi);
%
% See also:  s_rgcScene2Cones, sensorHumanResize, sensorComputeSamples
%
% (c) Stanford VISTA Team


%% check inputs
if notDefined('sensor'), error('Need sensor'); end
if notDefined('oi'), error('Need optical image'); end
if notDefined('showBar'), showBar = true; end

% Get and verify eye movement parameters
x = sensorGet(sensor,'sensor positions x');  % In deg of visual angle
y = sensorGet(sensor,'sensor positions y');
framesPerPosition =  sensorGet(sensor,'frames per position');
if ~isequal(length(x), length(y), length(framesPerPosition))
    error('framesPerPosition, x, y positions are not of same lengths');
end

%% Calculate volts.
volts = [];

% convert (x,y) from degrees to (columns, rows). we multiply the number of
% rows and columns by 2 because we will add rows or colums to only one side
% of the sensor (e.g, top or right), which will shift the center of the
% sensor by 1/2 the number of rows or columns added.
fov = sensorGet(sensor, 'fov', [], oi); 
sz  = sensorGet(sensor, 'size');

xpos = round(2* x * sz(2) / fov); 
ypos = round(2* y * sz(1) / fov); 

% With the noise flag set to 0, we compute only the mean.  No photon noise
% or sensor noise.
sensor = sensorSet(sensor,'noise flag',0);

% loop across positions
if showBar == 1
    wBar = waitbar(0,'Looping over frames');
elseif showBar >= 2
    fprintf('Start computing cone absorption samples:0%%');
    preLength = 3;
end
for p = 1:length(framesPerPosition)
    if showBar == 1
        waitbar(p/length(framesPerPosition),wBar);
    elseif showBar >= 2
        if p < length(framesPerPosition)
            progressStr = sprintf('%d%%%%', ...
                round(100*p/length(framesPerPosition)));
            fprintf([repmat('\b',1,preLength-1) progressStr]);
            preLength = length(progressStr);
        end
    end
    
    % if xpos (ypos) is positive, we add columns (rows) to the left 
    % (bottom), shifting the image  rightward (upward). verify this. it
    % could easily be wrong.
    if ypos(p) > 0,  rows = [0 ypos(p)]; else rows = [-ypos(p) 0]; end
    if xpos(p) > 0,  cols = [xpos(p) 0]; else cols = [0 -xpos(p)]; end
    
    % create a new, resized sensor. Should we worry about exposure time
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

if showBar == 1
    close(wBar);
elseif showBar >= 2
    fprintf([repmat('\b',1,preLength-1) 'Completed...\n']);
end

% Return the sensor with the voltage data from all the eye positions.
sensor = sensorSet(sensor, 'volts', volts);

%% End