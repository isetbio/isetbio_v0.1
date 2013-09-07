% s_ReflectanceChartBasisFunctions
%
% This script creates a color chart from a set of reflectances. The color
% chart is a scene. We find the spectral basis functions that describe 99.9%
% of the variance in the scene reflectances.

%%
% Randomly select reflectances

% The files containing the reflectances are in ISET format, readable by 
% s = ieReadSpectra(sFiles{1});
sFiles = cell(1,6);
sFiles{1} = fullfile(isetRootPath,'data','surfaces','reflectances','MunsellSamples_Vhrel.mat');
sFiles{2} = fullfile(isetRootPath,'data','surfaces','reflectances','Food_Vhrel.mat');
sFiles{3} = fullfile(isetRootPath,'data','surfaces','reflectances','DupontPaintChip_Vhrel.mat');
sFiles{4} = fullfile(isetRootPath,'data','surfaces','reflectances','HyspexSkinReflectance.mat');
sFiles{5} = fullfile(isetRootPath,'data','surfaces','reflectances','Nature_Vhrel.mat');
sFiles{6} = fullfile(isetRootPath,'data','surfaces','reflectances','Objects_Vhrel.mat');

% The number of samples from each of the data sets, respectively
sSamples = [12,12,24,5,24,12];    % 

% How many row/col spatial samples in each patch (they are square)
pSize = 24;    % Patch size
wave =[];      % Whatever is in the file
grayFlag = 0;  % No gray strip
sampling = 'no replacement';
scene = sceneReflectanceChart(sFiles,sSamples,pSize,wave,grayFlag,sampling);

% Show it on the screen
vcAddAndSelectObject(scene); sceneWindow;

wave = sceneGet(scene,'wave');

 reflectance = sceneGet(scene,'reflectance');
  reflectance =  reflectance(1:3:end,1:3:end,:);
%  [~, basisData] = hcBasis( reflectance,'meansvd',0.999);
  [~, basisData] = hcBasis( reflectance,'canonical',0.999);
 tmp = size(basisData);
 figure;
 for ii = 1:tmp(2)
     plot(wave, basisData(:,ii));
     hold on;
 end
 comment = 'see s_ReflectanceChartBasisFunctions: Surfaces were munsell samples, food, paint, skin, nature and objects';
 
 save surfaceSpectralBasis wave basisData comment;
 
 
       