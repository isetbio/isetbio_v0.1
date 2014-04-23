function spd = spdSet(spd,param,val,varargin)
% Create a spectral power distribution (spd) structure
%
%  spd = spdSet(spd,param,val,varargin)
%
% Examples
%
%

if ieNotDefined('spd'), error('spd structure required'); end
if ieNotDefined('param'), error('param  required'); end
if ~exist('val','var'), error('value required'); end

switch lower(param)
    case 'wave'
        spd.wave   = val;
    case 'energy'
        spd.energy = val;
    otherwise
        error('Unknown parameter %s\n',param);
end


return;
