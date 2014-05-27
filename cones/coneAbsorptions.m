function sensor = coneAbsorptions(sensor, oi, showBar)
% Compute the cone absorptions accounting for eye movements
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
if notDefined('sensor'),  error('Need sensor'); end
if notDefined('oi'),      error('Need optical image'); end
if notDefined('showBar'), showBar = ieSessionGet('wait bar'); end

% Get and verify eye movement parameters
x = sensorGet(sensor,'positions x');  % In deg of visual angle
y = sensorGet(sensor,'positions y');
framesPerPosition =  sensorGet(sensor,'frames per position');
if ~isequal(length(x), length(y), length(framesPerPosition))
    error('framesPerPosition, x, y positions are not of same lengths');
end

% We could sort the positions to make the computation more efficient.  The
% movie, however, won't match the real eye movements.  Below is the code
% that HJ used to sort.  It isn't quite right in here, but ihas the idea.

% pos = sensorGet(sensor,'movement positions');
% [pos,~,ic]  = unique(pos,'rows');
% %          
% % % Compute frame per position
% framesPerPosition    = hist(ic,unique(ic));      % frames per position
% framesPerPosition(1) = framesPerPosition(1) + size(pos,1) - sum(framesPerPosition);
% x = pos(:,1); y = pos(:,2);

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

% loop across positions, suppress waitbar in sensorCompute
wbarState = ieSessionGet('wait bar'); ieSessionSet('wait bar','off');
nPositions = length(framesPerPosition);
txt = sprintf('Looping over %i eye positions',nPositions);
if showBar, wBar = waitbar(0,txt); end
for p = 1:nPositions
    if showBar, waitbar(p/nPositions,wBar); end

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

if showBar == 1, close(wBar); end
ieSessionSet('wait bar',wbarState);

% Return the sensor with the voltage data from all the eye positions as an
% Row x Col x Position matrix.
sensor = sensorSet(sensor, 'volts', volts);

%% End