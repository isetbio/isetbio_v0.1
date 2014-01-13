function val = macularGet(m,param,varargin)
% Get parameters of the macular pigment structure
%
%     val = macularGet(m,param,varargin)
%
% Parameters
%
%   name           - 'default macular' or your name
%   type           - 'macular'
%   unit density   - Read in from macularPigment.mat file, based on Sharp
%   density        - single value of density
%
%   spectral density - density for all wavelengths (absorbance)
%   transmittance    - fraction of photons transmitted
%   absorptance (absorption) - fraction of photons absorbed
%
%   Absorptance spectra are the proportion of quanta actually absorbed.
%
%     absorptance = 1 - 10.^(-density * unitDensity)
%
% See macularCreate for notes about the macular pigment in general and the
% formulae relating absorbance and absorptance and transmittance.
%
% There are problems relating to Psychtoolbox-3 at the moment because of
% spelling issues (absorbtance doesn't really exist).  We are working this
% through with DHB.
%
% See the definitions of terms at http://en.wikipedia.org/wiki/Absorbance,
% and these link back to the Stockman site.  We believe the terminology
% here is consistence.
%
% Examples:
%   m = macularCreate; w= macularGet(m,'wave');
%   vcNewGraphWin; plot(w,macularGet(m,'absorptance'))
%   hold on; plot(w,macularGet(m,'transmittance'))
%
% Should sum to one
%
%   macularGet(m,'absorptance') + macularGet(m,'transmittance')
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
        
        

    case {'unitdensity','unitspectraldensity','unitspectralabsorbance'}
        % This is the spectral density, set to a unit density at peak.
        %
        % The spectral density curve is defined by Sharp, 1999.  To load
        % use ieReadSpectra('macularPigment.mat',wave) and then scale. 
        % See macularCreate.
        val = m.unitDensity;
    case 'density'
        % Assumed density for this instance.  This is a single number.
        val = m.density;

    case {'spectraldensity','spectralabsorbance'}
        % The spectral density combines the spectral density with a unit
        % peak and the assumed density of this instance.
        
        % Unit density times the density for this structure
        u = macularGet(m,'unit density');
        d = macularGet(m,'density');
        val = u*d;
        
    case 'transmittance'
        % Proportion of quanta transmitted through the pigment
        val = 10.^(-macularGet(m,'spectral density'));
        
    case {'absorptance'}
        % Proportion of quanta absorbed by the pigment
        val = 1 - 10.^(-macularGet(m,'spectral density'));
        
    otherwise
        error('Unknown parameter %s\n',param);
end

return


