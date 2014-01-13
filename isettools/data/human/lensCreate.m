function lens = lensCreate(wave)
% Returns a human lens structure
%
%     lens = lensCreate(wave)
%
% This function reads lens density and stores it in a default structure.
%
% The original lens densities values were taken from PTB and/or the
% Stockman site. Go to http://cvision.ucsd.edu, then click on Prereceptoral
% filters.  At this point in time, I think the Psychtoolbox and the new
% Stockman site are authoritative and in agreement.
%
%  lens.name  -  'Convenient name'
%  lens.type  - 'lens'
%  lens.wave  -  wavelength samples (nm) 
%  lens.unitDensity:   The spectral density function (max =  1.0)
%  lens.density:       The density for this instance
%
% For a discussion of the terms absorptance and absorbance and density see
% macularGet.
%
% Examples:
%   lens = lensCreate;
%   
%
% HJ/BW ISETBIO Team 2013.

%% 
if ieNotDefined('wave'),        wave = (400:700)'; end

lens.name = 'default human';
lens.type = 'lens';
lens.wave = wave;

% It appears that the stored file is the true density, not the unit
% density.  We use 
density          = ieReadSpectra('lensDensity.mat',wave);
lens.unitDensity = density/max(density);

lens.density     = max(density);

return


