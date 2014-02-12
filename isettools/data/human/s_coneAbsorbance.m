%% cone absorbance data
%
%   spectral density - density for all wavelengths (absorbance)
%   transmittance    - fraction of photons transmitted
%   absorptance (absorption) - fraction of photons absorbed
%
%   Absorptance spectra are the proportion of quanta actually absorbed.
%
%     absorptance = 1 - 10.^(-density * unitDensity)
%
% These are originally from Stockman's page.
%
% PUT SOURCE HERE
%
%
% The file in PTB is called log10ConeAbsorbance or something ...
%
% We should probably give it the same name here rather than this name.
%
% Then, we make the file coneAbsorbance as follows
%
% The linear fundamentals (energy units) are called
%   absorbance
%
%

%% Data from Stockman and PTB

% I think these are the unit density (peak value is 0)
foo = load('coneAbsorbanceLog10.mat');

conePigmentDensity - % Normalized to max of 0
absorptance = 1 - 10.-unitDensity

data = 10.^foo.data;
comment = '10^value that is in the PTB cone absorbance';

vcNewGraphWin;
plot(foo.wavelength,foo.data);
grid on

%% These are the absorptance, which is the fraction absorbed
ieSaveSpectralFile(foo.wavelength,data,comment,'coneAbsorptance.mat');

%% Convert the density 
wave = 400:5:700;
a = vcReadSpectra('coneAbsorbance',wave);
vcNewGraphWin;
plot(wave,a);
grid on
