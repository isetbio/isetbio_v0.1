function macbethChartObject = macbethChartCreate(patchSize,patchList,spectrum)
% Create a data structure of the Gretag/Macbeth Color Chart reflectances
%
%    macbethChartObject = macbethChartCreate([patchSize=12],[patchList=1:24],[spectrum={400:10:700});
%
% Create a scene of spectral reflectance functions of the Macbeth chart.
% The chart is coded as if you are looking at it with four rows and six
% columns.  The white surface is on the left, and the black surface is on
% the right.
% 
% The numbering of the surfaces starts at the upper left and counts down
% the first column.  The white patch, therefore, is number 4.  The
% achromatic series is 4:4:24.
%
% To read the surfaces in the standard ordering used in image processing
% routines, like vcimageMCCXYZ, use 
%   list = [4 3 2 1 8 7 6 5 12 11 10 9 16 15 14 13 20 19 18 17 24 23 22 21]
%   macbethChartOther(:,list) = macbethChart;
%   
%   macbethChart = macbethChartOther
%   
% The surface reflectance function information are contained in the slot
% macbethChartObject.data. It is possible to have spectral information
% between 370 to 730 nm.  That is the limit of the Macbeth calibration
% range.
%
% The default patch size is 16 pixels
% The default patch list is all 24 macbeth surfaces, though you may create
% a partial image.
%
% Examples:
%    patchSize = 16;
%    patchList = 1:24;
%    macbethChartObject = macbethChartCreate(patchSize,patchList);
%
%    spectrum.wave      = (370:10:730);
%    macbethChartObject = macbethChartCreate([],[],spectrum);
%
%    spectrum.wave      = (380:4:1068);
%    macbethChartObject = macbethChartCreate([],[],spectrum);
%
%    spectrum.wave      = (400:5:900);
%    macbethChartObject = macbethChartCreate([],[],spectrum);
%
% Copyright ImagEval Consultants, LLC, 2003.
% To be returned

% The object here is basically a scene
macbethChartObject.name = 'Macbeth Chart';
macbethChartObject.type = 'scene';

% This is the size in pixels of each Macbeth patch
if ieNotDefined('patchSize'), patchSize = 16;   end

% These are the patches we are trying to get
% If we want just the gray series we can set patchList = 19:24;
if ieNotDefined('patchList'), patchList = 1:24; end

% Surface reflectance spectrum
if ieNotDefined('spectrum'), 
    macbethChartObject = initDefaultSpectrum(macbethChartObject,'hyperspectral');
else
    macbethChartObject = sceneSet(macbethChartObject,'spectrum',spectrum);
end

% Read wavelength information from the macbeth chart data
wave =   sceneGet(macbethChartObject,'wave');
nWaves = sceneGet(macbethChartObject,'nwave');

% Read the MCC reflectance data
fName = fullfile(isetRootPath,'data','surfaces','macbethChart.mat');
macbethChart = ieReadSpectra(fName,wave);

%patchList = [4 3 2 1 8 7 6 5 12 11 10 9 16 15 14 13 20 19 18 17 24 23 22 21];
%macbethChartOther(:,list) = macbethChart;
%   
%macbethChart = macbethChartOther;
%patchList = [1 7 13 19 2 8 14 20 3 9 15 21 4 10 16 22 5 11 17 23 6 12 18 24];  


% Sort out whether we have the right set of patches
macbethChart = macbethChart(:,patchList);
if length(patchList) == 24
    macbethChart = reshape(transpose(macbethChart),4,6,nWaves);
else
    macbethChart = reshape(transpose(macbethChart),1,length(patchSize),nWaves);
end

% Make it the right patch size
macbethChartObject.data = imageIncreaseImageRGBSize(macbethChart,patchSize);

return;
