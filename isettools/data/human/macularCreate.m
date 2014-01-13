function m = macularCreate(macDensity,wave)
% Returns a structure containing several measures of the macular pigment
%
%     m = macularCreate(macDensity,wave)
%
% The human retina contains a pigment that covers the central (macular)
% region. This macular pigment passes certain wavelengths of light more
% than others.  The pigment varies in density from central vision, where it
% is highest, to increasingly peripheral vision.
%  
% This function returns a template for the macular pigment.  It contains
% the unit density representation.  
%
% Note that the density varies across the retina:  it is high in the fovea,
% lower in the near fovea, and then zero in the periphery.  Hiroshi tells
% me that it is also near zero in smokers.
%
% The default density in this structure is set to 0.28, a value preferred
% by Sharpe and Stockman for the fovea. This value is the estimated
% (average) peak density of the pigment across a variety of observers.
% They estimate the average (across observers) peak density to be 0.28,
% with a range of 0.17 to 0.48.
%
%   m.name    'Convenient name'
%   m.type    'macular'
%   m.wave    
%   m.unitDensity:   The spectral density function with a maximum value of 1.0
%   m.density:       The density for this instance
%
% The original macular densities values were taken from the Stockman site.
% Go to http://cvision.ucsd.edu, then click on Prereceptoral filters.  At
% this point in time, I think the Psychtoolbox and the new Stockman site
% are authoritative.
%
% The densities were derived by Sharpe and Stockman based on some data from
% Bone. The paper describing why they like these is in Vision Research,
% 1999; A. Stockman et al. / Vision Research 39 (1999) 2901?2927.  See
% section around p. 2908.
%
% For a discussion of the terms absorbance and absorptance, see macularGet.
%
% See also:  macularGet/Set
%
% Examples:
%   m = macularCreate;
%
% Copyright ImagEval Consultants, LLC, 2005.

%% 
if ieNotDefined('macDensity'), macDensity = 0.28; end
if ieNotDefined('wave'), wave = (400:700)'; end

m.name = 'default macular';
m.type = 'macular';
m.wave = wave;

% Read in the Sharpe macular pigment curve.
density  = ieReadSpectra('macularPigment.mat',wave);

% Typical peak macular density, Estimated by Sharpe in VR paper, 1999 is
% 0.28.  Yet, the data provided at the site have a peak of 0.3521.  We
% normalize their data to unit density by dividing all the densities by the
% peak.
m.unitDensity = density / 0.3521;

% And we set the density to 0.28 by default, or whatever the user prefers.
m.density = macDensity;

return


