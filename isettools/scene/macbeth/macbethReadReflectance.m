function macbethChart = macbethReadReflectance(wave,patchList)
% Read the macbeth surface reflectances into the standard vimage ordering
%
%   macbethChart = macbethReadReflectance(wave,patchList);
%
% The returned variable has the reflectances in the columns but according
% to the ordering used in vcimage
%
% Example:
%   wave = 400:10:700;
%   macbethReflectance = macbethReadReflectance(wave);
%   plot(wave,macbethReflectance), xlabel('Wavelength (nm)')
%   ylabel('Reflectance'); grid on
%
% See also: s_SurfaceModels for examples of calculating images with the MCC
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('wave'), wave = (400:700); end
if ieNotDefined('patchList'), patchList = 1:24; end

fName = fullfile(isetRootPath,'data','surfaces','macbethChart.mat');
macbethChart = ieReadSpectra(fName,wave);

macbethChart = macbethChart(:,patchList);
list = [4 3 2 1 8 7 6 5 12 11 10 9 16 15 14 13 20 19 18 17 24 23 22 21];
macbethChart(:,list) = macbethChart;

return;
