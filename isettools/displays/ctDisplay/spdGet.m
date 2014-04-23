function val = spdGet(spd,param,varargin)
%Create a spectral power distribution (spd) structure
%
%   val = spdGet(spd,param,varargin)
%
% Examples
%   e = spdGet(spd,'energy');
%   w = spdGet(spd,'wave');

if ieNotDefined('spd'), error('spd structure required'); end
if ieNotDefined('param'), error('param  required'); end

val = [];

switch lower(param)
    case {'wave','wavelength'} % nm
        if checkfields(spd,'wave'), val = spd.wave; end
    case {'nwave'}
        val = length(spd.wave);
    case 'energy'  % watts/sr/nm/m^2
        if checkfields(spd,'energy'), val = spd.energy; end
    otherwise
        error('Unknown parameter %s\n',param);
end


return;
