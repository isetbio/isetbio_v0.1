function ctdpMeasureGamma(ctDisplayW);
%Obsolete:  Measure gamma calibration data
%
%    ctdpMeasureGamma(ctDisplayW);
%
%Replaced by cmToolBox routines
%

disp('Obsolete')
evalin('caller','mfilename');
return;

displayGD=ctGetObject('display');

% Open up the PR-650 device
hPhotoMeter = ieInitializePhotoMeter(displayGet(displayGD, 'm_nDefaultCommPort'));
if isempty(hPhotoMeter), return; end;    

% Which device are we measuring from?
switch displayGet(displayGD, 'm_bDefaultWorkingMonitor')
    case 1 %Measure the primary monitor
        screenSize=[0 0];
    case 2 %Measure the secondary monitor
        screenSize=adGetTrueScreenSize;
end;
    
[filename, imageFilePath]=uiputfile(str, 'Please specify a file name');
if isequal(filename,0) && isequal(imageFilePath, 0)
    return;
end;

strFileName=[imageFilePath filename];

% Set up measurement parameters, and then measure
strBatchMode='BatchMode';
nNumberOfGrayLevels=displayGet(displayGD, 'm_nDefaultNumberOfGrayLevels');
gammaStructure = ...
    ieMeasureGammaData(displayGet(displayGD, 'm_nDefaultCommPort'), ...
    strBatchMode, nNumberOfGrayLevels, ...
    displayGet(displayGD, 'm_nDefaultNumberOfSamples'), ...
    screenSize);

% Store the data
%displayGD = displaySet(displayGD, 'calibrationGamma', gammaStructure);
displayGD = displaySet(displayGD, 'gammastructure', gammaStructure);

% Make a plot
iePlotDisplayGamma(ctDisplayW, 'Virtual');

clear gammaMatrix rawData;

gammaMatrix(:, 1)=gammaStructure{1}.vGammaRampLUT;
gammaMatrix(:, 2)=gammaStructure{2}.vGammaRampLUT;
gammaMatrix(:, 3)=gammaStructure{3}.vGammaRampLUT;

rawData={};
rawData{1}=gammaStructure{1}.vRawData;
rawData{2}=gammaStructure{2}.vRawData;
rawData{3}=gammaStructure{3}.vRawData;

feval('save', strFileName, 'gammaMatrix', 'rawData');

ctSetObject('display', displayGD);

return;
