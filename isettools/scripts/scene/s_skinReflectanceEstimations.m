% s_skinReflectanceEstimations
%
% Goal: 
%
% The original data is skinMatrix created by sampling the cheek in hyperspectral data for 71 faces 
% see s_CreateSkinReflectanceMatrix
% this is a  71 x 148 matrix (148 wavelength samples)
%
% Step 1: Original Scene
%       Create a reflectance chart from the skin reflectance data
%
% Step 2: Compressed Scene
%       Get a set of basis functions and coefficients that describe the spectral reflectances 
%       save the coefficients and basis functions for use later
%
% Step 3: Sensor output
%       Use the Original Scene in a simulation of an image sensor.  
%       The output of the simulation is Nvalues from the N different color channels in the image sensor
%
% Step 4: Estimated Scene
%       here we find a Nsensors x Nbases matrix to predict the coefficients of the skin reflectances
% 
% We will use a wavelength range of 490:4:650
% From Yudovsky and Pilon, 2010: 
% "Diffuse reflectance was predicted at K = 40 evenly space wavelengths between 490 and 650 nm.
% This wavelength range was chosen such that melanin, oxyhemoglobin, and deoxyhemoglobin exhibit
% distinct and significant absorption [Figs. 2(a)and 2(b)].

%% Step 1: Original Scene
%   Create a reflectance chart from the skin reflectance data
%   see s_sceneReflectanceCharts
%  this will be input to the sensor simulations

sFiles = cell(1,1);
sFiles{1} = fullfile(isetRootPath,'data','surfaces','reflectances','HyspexSkinReflectance.mat');
sSamples = 64;

% How many row/col spatial samples in each patch (they are square)
pSize = 10;    % Patch size
load(fullfile(isetRootPath,'data','surfaces','reflectances','HyspexSkinReflectance.mat'));
% wave = wavelength;      % Whatever is in the file
wave = [490:4:650]; % this is the range over which we will evaluate the data given Yudovsky and Pilon, 2010
grayFlag = 0;  % No gray strip
sampling = 'no replacement';
[scene, ~, reflectance] = sceneReflectanceChart(sFiles,sSamples,pSize,wave,grayFlag,sampling);
%vcNewGraphWin; plot(wave,reflectances)

% Show it on the screen
vcAddAndSelectObject(scene); sceneWindow;
%% Step 2: Compressed Scene
% Get a set of basis functions and coefficients that describe the spectral
% reflectances - save the coefficients and basis functions for use later
% [imgMean, basis, coef] = hcBasis(double(scene.data.photons));
%  Compare the original reflectance chart with the chart
%   reconstructed using the small basis functions
% The compressed scene will be a row x col x nBases matrix

% Compute the svd on the reflectance data
% Compute the svd.  reflectance = U * S * basis'
[basis, S, wgts] = svd(reflectance,'econ');
% vcNewGraphWin; plot(wave,basis(:,1:4))

nBasis = 4;  % See how estimations change with different number of basis functions
estS = diag(S);
estS((nBasis+1):end) = 0;
estS = diag(estS);
estR = basis*estS*wgts';
vcNewGraphWin; plot(wave,basis(:,1:nBasis))
% figure; plot(estR(:),reflectance(:),'.')

% Remove the mean
meanR = mean(reflectance,2);
reflectance0 = reflectance - repmat(meanR,[1 size(reflectance,2)]);
[basis0, S0, wgts0] = svd(reflectance0,'econ');
vcNewGraphWin; plot(wave,basis0(:,1:nBasis))
hold on;
plot(wave,meanR,'k-')
hold off

%% Another way to do this
% reflectance = sceneGet(scene,'reflectance');
% % 
% % % How many bases to return.  If < 1, then it refers to variance explained.  
% % nBasis = .95; 
% nBasis = 10;
% [~, basis, coef] = hcBasis(reflectance,'canonical',nBasis); 
% [imgMean, basis2, coef2] = hcBasis(reflectance,'mean svd',nBasis); 
% NumberOfBasis = length(basis(1,:));
% vcNewGraphWin;
% plot(wave,basis(:,1:NumberOfBasis)); title('Canonical svd');
% %
% vcNewGraphWin;
% plot(wave,imgMean,'k');
% hold on;
% plot(wave,basis0(:,1:NumberOfBasis)); title('Mean removed');


%% Step 3: Sensor output
%  Use the Original Scene in a simulation of an image sensor.  
%  The output of the simulation is Nvalues from the N different color channels in the image sensor
%  Make this a function that accepts the scene data and returns the sensor data 
%       The data in the variable 'im' are the voltages that one would obtain from
%       the sensor with stacked pixels.  The experiments that could be run
%       involve adjusting the filters and other optics and sensor properties. 
%   Note that the light will be incorporated into the definition of the imaging sensor
%   The sensor output will be a row x col x nSensors matrix
%
%   set sensor parameters
%   adjust wave here to be in a particular range (e.g. 450:5:600)
horizontalFOV = 10; % a good value is approximately linearly related to the size of the images.
meanLuminance = 100;  % specify the scene mean luminance 
scene = sceneAdjustLuminance(scene,meanLuminance);
scene = sceneSet(scene,'hfov',horizontalFOV);
% wave = sceneGet(scene,'wave');
% vcAddAndSelectObject(scene); sceneWindow;

% Build the OI
oi = oiCreate;
optics = oiGet(oi,'optics');
optics = opticsSet(optics,'f number',4);
optics = opticsSet(optics,'focal length',3e-3);   % units are meters

% Compute optical image
oi = oiCompute(scene,oi);

% Create a monochrome sensor.  We will reuse this structure to compute each
% of the complete color filters.
sensor = sensorCreate('monochrome');
sensor = sensorSet(sensor,'wave',wave); 

% Set sensor parameters
sensor = sensorSet(sensor,'filter spectra',ones(length(wave),1));
sensor = sensorSet(sensor,'irfilter',ones(length(wave),1));
sensor = sensorSet(sensor,'quantizationMethod','analog');

% Set pixel parameters - could pull these parameters out as variables.
% These are just examples.
pixel = sensorGet(sensor,'pixel');
pixel = pixelSet(pixel,'spectralQE',ones(length(wave),1));
pixel = pixelSet(pixel,'size',[2.2e-6 2.2e-6]);                % Pixel Size in meters
pixel = pixelSet(pixel,'conversion gain', 2.0000e-004);        % Volts/e-
pixel = pixelSet(pixel,'voltage swing', 1.8);                  % Volts/e-
pixel = pixelSet(pixel,'dark voltage', 1e-005);                % units are volts/sec
pixel = pixelSet(pixel,'read noise volts', 1.34e-003);         % units are volts

sensor = pixelCenterFillPD(sensor, 0.45);
sensor = sensorSet(sensor,'pixel',pixel);
sensor = sensorSet(sensor,'dsnu level',14.1e-004); % units are volts
sensor = sensorSet(sensor,'prnu level',0.002218);  % units are percent

%Following sets horizontal field of view to desired value
% Maybe we should put in a flag to allow for vertical and horizontal.
% sceneGet(scene,'vfov')
% sceneGet(scene,'hfov')
sensor = sensorSetSizeToFOV(sensor,horizontalFOV,scene,oi);   % deg of visual angle
sensorsize = sensorGet(sensor,'size');
rows = sensorsize(1);
cols = sensorsize(2);
if isodd(rows), rows = rows+1; end
if isodd(cols), cols = cols+1; end
sensor = sensorSet(sensor,'size',[rows cols]);

%% Set filters here

cfType = 'gaussian';
cPos = [540,560,575];  % center position of the filter (nm)
width = [30,30,30];
fSpectra = sensorColorFilter(cfType,wave, cPos, width);
plot(wave,fSpectra);
filterNames = {'540','560','575'};
nChannels = size(fSpectra,2);
% vcNewGraphWin; plot(wave,fSpectra)

%% Loop on the number of filters and calculate full sensor plane values

% For each of the filter transmissivities, compute the monoSensor photons.
sz = sensorGet(sensor,'size');

% We will store the image values here
im = zeros(sz(1),sz(2),nChannels);

for kk=1:nChannels
    s = sensorSet(sensor,'filterspectra',fSpectra(:,kk));
    s = sensorSet(s,'Name',sprintf('Channel-%.0f',kk));
    s = sensorCompute(s,oi,0);
    im(:,:,kk) = sensorGet(s,'volts');
end


% The multiple channel data (in volts) are stored in the variable im().
% You can visualize the data summed across the channels using:
% hcimage(im,'movie');
% hcimage(im);
% hcimage(im,'montage')

%% Step 4: Estimated Scene
%       here we find a Nsensors x Nbases matrix to predict the coefficients of the skin reflectances
%   
%
%% Step 5: We can calculate the rmse between
% Original Scene and Compressed Scene
%   how much information do we lose when we use a linear model
% Compressed Scene and Estimated Scene
%   how much further information loss is there due to the sensor
%