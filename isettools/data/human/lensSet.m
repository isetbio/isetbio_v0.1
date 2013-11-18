function lens = lensSet(lens,param,val,varargin)
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
%
%   Absorbance spectra are normalized to a peak value of 1.
%   Absorbtance spectra are the proportion of quanta actually absorbed.
%   Equation: absorbtanceSpectra = 1 - 10.^(-OD * absorbanceSpectra)
%
% Examples:
%  lens = lensCreate; w = lensGet(lens,'wave');
%  vcNewGraphWin; plot(w,lensGet(lens,'absorbtance'))
%  hold on; plot(w,lensGet(lens,'transmittance'))
%  lens = lensSet(lens,'density',0.5);
%  vcNewGraphWin; plot(w,lensGet(lens,'absorbtance'))
%  hold on; plot(w,lensGet(lens,'transmittance'))
%
% Copyright ImagEval Consultants, LLC, 2005.

if      ieNotDefined('lens'), error('Lens structure required');
elseif ~isequal(lens.type,'lens'), error('Not a lens structure');
end

if ieNotDefined('param'), error('param required'); end
if ieNotDefined('val'), error('val required'); end


param = ieParamFormat(param);

switch param
    case 'name'
        lens.name = val;
    case 'wave'
        lens.wave = val;
        
        
    case {'absorbance','unitdensity'}
        % This might not be the unit density, which has me bummed.  We
        % should deal with this in lensCreate.
        %
        % ieReadSpectra('lensDensity.mat',wave);
        % See macularCreate.
        lens.unitDensity = val;
    case 'density'
        % Assumed density for this instance
        lens.density = val;

        
    otherwise
        error('Unknown parameter %s\n',param);
end

return


