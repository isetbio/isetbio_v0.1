function m = macularSet(m,param,val,varargin)
% Set parameters of the macular pigment structure
%
%     m = macularSet(m,param,val,varargin)
%
% See macularCreate for notes about the macular pigment in general and the
% formulae relating absorbance and absorptance and transmittance.
%
% Parameters
%
%   name
%   wave
%   unitDensity
%   density
%
% Examples:
%   m = macularCreate;
%   t = macularGet(m,'transmittance');
%   w = macularGet(m,'wave');
%   vcNewGraphWin; plot(w,t)
%
% Copyright ImagEval Consultants, LLC, 2013.

if ieNotDefined('m'), error('Macular structure required'); end
if ieNotDefined('param'), error('param required'); end
if ieNotDefined('val'), error('val required'); end

%
param = ieParamFormat(param);

switch param
    case 'name'
        m.name = val;
    case 'wave'
        m.wave = val;
    case 'unitdensity'
        % Spectral density
        m.unitDensity = val;
    case 'density'
        % Density for this case
        m.density = val;
    otherwise
        error('Unknown parameter %s\n',param);
end


return


