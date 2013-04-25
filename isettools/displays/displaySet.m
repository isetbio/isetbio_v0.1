function d = displaySet(d,parm,val,varargin)
%Set display parameter values
%
%
%
% Copyright ImagEval 2011

if ieNotDefined('parm'), error('Parameter not found.');  end

% Convert parameter format
parm = ieParamFormat(parm);

switch parm
    case {'name'}
        d.name = val;
    case {'type'}
        d.type = val;
    case {'dv2intensity','gamma'}
        % From digital values to primary intensity
        % Should be same number of columns as primaries
        d.gamma = val;
    case {'bits','dacsize'}
        % 8 bit, 10 bit, and so forth
        d.bits = val;
    case {'wave','wavelength'}  %nanometers
        % d = displaySet(d,'wave',val);
        % Force column
        d.wave = val(:);
    case {'spd','spdprimaries'}
        % d = displaySet(d,'spd primaries',val);
        % Should check the length(wave) matches rows of spd.
        d.spd = val;
        
        % Spatial matters
    case {'dpi'}
        % Dots per inch of the pixels (full pixel center-to-center)
        d.dpi = val;
    case {'viewingdistance'}
        d.dist = val;
    otherwise
        error('Unknown parameter %s\n',parm);
end

return;
