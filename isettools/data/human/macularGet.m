function val = macularGet(m,param,varargin)
% Get parameters of the macular pigment structure
%
%     val = macularGet(m,param,varargin)
%
% See macularCreate for notes about the macular pigment in general and the
% formulae relating absorbance and absorptance and transmittance.
%
% Parameters
%
%   name
%   type          - 'macular'
%   unitDensity   - Read in from macularPigment.mat file, based on Sharp
%   density       - single value
%   transmittance
%   absorbance
%   absorptance (absorption)
%
%
% Examples:
%   m = macularCreate; w= macularGet(m,'wave');
%   vcNewGraphWin; plot(w,macularGet(m,'absorbance'))
%   hold on; plot(w,macularGet(m,'transmittance'))
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('m'), error('Macular structure required'); end
if ieNotDefined('param'), error('param required'); end

%
param = ieParamFormat(param);

switch param
    case 'name'
        val = m.name;
    case 'type'
        val = m.type;
    case 'wave'
        val = m.wave;
        
        
        %   Absorbance spectra are normalized to a peak value of 1.
        %   Absorbtance spectra are the proportion of quanta actually absorbed.
        %   Equation: absorbtanceSpectra = 1 - 10.^(-OD * absorbanceSpectra)
    case {'absorbance','unitdensity'}
        % This is defined by Sharp, 1999.  To load use
        % ieReadSpectra('macularPigment.mat',wave);
        % See macularCreate.
        val = m.unitDensity;
    case 'density'
        % Assumed density for this instance
        val = m.density;

    case {'spectraldensity'}
        % Unit density times the density for this structure
        u = macularGet(m,'unit density');
        d = macularGet(m,'density');
        val = u*d;
        
    case 'transmittance'
        % Proportion of quanta transmitted
        val = 10.^(-macularGet(m,'spectral density'));
        
    case {'absorbtance','absorption'}
        % Proportion of quanta absorbed
        val = 1 - 10.^(-macularGet(m,'spectral density'));
        
    otherwise
        error('Unknown parameter %s\n',param);
end

return


