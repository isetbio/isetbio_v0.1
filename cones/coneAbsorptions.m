function sensor = coneAbsorptions(sensor, oi, varargin)
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

% Get and verify eye movement parameters
xpos = sensorGet(sensor,'positions x');
ypos = sensorGet(sensor,'positions y');

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
% convert (x,y) from degrees to (columns, rows). we multiply the number of
% rows and columns by 2 because we will add rows or colums to only one side
% of the sensor (e.g, top or right), which will shift the center of the
% sensor by 1/2 the number of rows or columns added.
% fov = sensorGet(sensor, 'fov', [], oi);
% sz  = sensorGet(sensor, 'size');

% xpos = round(2* x * sz(2) / fov);
% ypos = round(2* y * sz(1) / fov);

% With the noise flag set to 0, we compute only the mean.  No photon noise
% or sensor noise.
% sensor = sensorSet(sensor,'noise flag',0);

% loop across positions, suppress waitbar in sensorCompute
% wbarState = ieSessionGet('wait bar'); ieSessionSet('wait bar','off');
nPos = length(xpos);

% OLD CODE STARTS HERE
% volts = [];
% txt = sprintf('Looping over %i eye positions',nPositions);
%
%     if showBar, wBar = waitbar(0,txt); end
%     for p = 1:nPositions
%         if showBar, waitbar(p/nPositions,wBar); end
%
%         % if xpos (ypos) is positive, we add columns (rows) to the left
%         % (bottom), shifting the image  rightward (upward). verify this. it
%         % could easily be wrong.
%         if ypos(p) > 0,  rows = [0 ypos(p)]; else rows = [-ypos(p) 0]; end
%         if xpos(p) > 0,  cols = [xpos(p) 0]; else cols = [0 -xpos(p)]; end
%
%         % create a new, resized sensor. Should we worry about exposure time
%         % each time we move (resize) the sensor?
%         sensor2 = sensorHumanResize(sensor,rows, cols);
%
%         % compute the noiseless mean
%         sensor2 = sensorCompute(sensor2,oi);
%
%         % compute the noisy frame-by-frame samples
%         noiseType = 1;  % Only photon noise
%         tmp = sensorComputeSamples(sensor2,framesPerPosition(p),noiseType);
%
%         % remove the added rows/columns
%         tmp = tmp(1+rows(1):end-rows(2), 1+cols(1):end-cols(2), :);
%
%         % concatenate the voltage image
%         volts = cat(3, volts, single(tmp));
%
%     end
%     if showBar == 1, close(wBar); end
%     ieSessionSet('wait bar',wbarState);
%
%     % Return the sensor with the voltage data from all the eye positions as
%     % an Row x Col x Position matrix.
%     sensor = sensorSet(sensor, 'volts', volts);

% Pad to the sensor to max size
rows = [-min([ypos(:); 0]) max([ypos(:); 0])];
cols = [max([xpos(:); 0]) -min([xpos(:); 0])];
coneType = sensorGet(sensor, 'cone type');
sensor2 = sensorHumanResize(sensor, rows, cols);

% Compute all-L/M/S absorptions
sz = sensorGet(sensor2, 'size');
LMS = zeros([sz 3]);
msk = zeros([size(coneType) 3]);
for ii = 2 : 4 % L, M, S
    pattern = ii * ones(sz);
    sensor2 = sensorSet(sensor2, 'pattern', pattern);
    sensor2 = sensorSet(sensor2, 'cone type', pattern);
    
    sensor2 = sensorComputeNoiseFree(sensor2, oi);
    LMS(:,:,ii-1) = sensorGet(sensor2, 'volts');
    msk(:,:,ii-1) = double(coneType == ii);
end

sz = sensorGet(sensor, 'size');
volts = zeros([sz nPos]);

for p = 1:nPos
    % cropping
    tmp = LMS(1+rows(1)+ypos(p):end-rows(2)+ypos(p), ...
        1+cols(1)-xpos(p):end-cols(2)-xpos(p),:);
    % select cone type
    volts(:,:,p) = sum(tmp .* msk, 3);
end

% Add photon noise
% We don't use sensorAddNoise or sensorComputeSamples because in here,
% our noise-free sensor contains more than one volts images. For
% simplicity, we just add some photon noise to the noise-free cone
% absorption data.
% noiseShot might be a good function to use, but we need to get rid of
% the bunky for-loop there
%     cg      = pixelGet(sensorGet(sensor,'pixel'), 'conversion gain');
%     photons = round(volts / cg);
%
%     volts   = (photons + sqrt(photons).*randn(size(photons))) * cg;
%     indx    = find(photons < 15);
%     volts(indx) = iePoisson(photons(indx)) * cg;
%     sensor  = sensorSet(sensor, 'volts', volts);
sensor = sensorSet(sensor, 'volts', volts);
sensor = sensorSet(sensor, 'volts', noiseShot(sensor));

%% End
end