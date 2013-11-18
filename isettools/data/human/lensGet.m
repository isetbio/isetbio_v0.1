function val = lensGet(lens,param,varargin)
% Get parameters of the lens structure
%
%     val = lensGet(lens,param,varargin)
%
% See lensCreate for notes about the properties in general and the
% formulae relating absorbance and absorptance and transmittance.
%
% Parameters
%
%   name
%   type          - 'lens'
%   unitDensity   - Read in from lensDensity.mat file, based on Sharp
%   density       - single value
%   transmittance
%   absorbance
%   absorptance (absorption)
%
%   Absorbance spectra are normalized to a peak value of 1.
%   Absorbtance spectra are the proportion of quanta actually absorbed.
%   Equation: absorbtanceSpectra = 1 - 10.^(-OD * absorbanceSpectra)
%
% Examples:
%  lens = lensCreate; w = lensGet(lens,'wave');
%  vcNewGraphWin; plot(w,lensGet(lens,'absorbtance'))
%  hold on; plot(w,lensGet(lens,'transmittance'))
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('lens'), error('Lens structure required'); end
if ieNotDefined('param'), error('param required'); end

%
param = ieParamFormat(param);

switch param
    case 'name'
        val = lens.name;
    case 'type'
        val = lens.type;
    case 'wave'
        val = lens.wave;
        
        
    case {'absorbance','unitdensity'}
        % This is defined by Sharp, 1999.  To load use
        % ieReadSpectra('macularPigment.mat',wave);
        % See macularCreate.
        val = lens.unitDensity;
    case 'density'
        % Assumed density for this instance
        val = lens.density;

    case {'spectraldensity'}
        % Unit density times the density for this structure
        u = lensGet(lens,'unit density');
        d = lensGet(lens,'density');
        val = u*d;
        
    case 'transmittance'
        % Proportion of quanta transmitted
        val = 10.^(-lensGet(lens,'spectral density'));
        
    case {'absorbtance','absorption'}
        % Proportion of quanta absorbed
        val = 1 - 10.^(-lensGet(lens,'spectral density'));
        
    otherwise
        error('Unknown parameter %s\n',param);
end

return


