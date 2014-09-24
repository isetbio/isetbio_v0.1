function d = displaySet(d,parm,val,varargin)
%Set display parameter values
%
%   d = displaySet(d,parm,val,varargin)
%
% Parameters
%   name
%   gTable
%   wave
%   spd
%   dpi
%   psf
%   viewing distance
%   comment
%
% Examples:
%
%  d = displayCreate;
%  d = displaySet(d,'gTable',val)
%  d = displaySet(d,'gTable','linear');
%  d = displaySet(d,'name','My Display Type');
%
% See also: displayGet, displayCreate, ieLUTDigital, ieLUTLinear
%
% Copyright ImagEval 2011

if notDefined('parm'), error('Parameter not found.');  end

% Convert parameter format
parm = ieParamFormat(parm);

switch parm
    case {'name'}
        d.name = val;
    case {'type'}
        d.type = val;
    case {'gtable','dv2intensity','gamma'}
        % d = displaySet(d,'gamma',val)
        % d = displaySet(d,'gamma','linear');
        % From digital values to primary intensity
        % Should be same number of columns as primaries
        if ischar(val) && strcmp(val,'linear')
            % User just wants a linear gamma table
            val = linspace(0,1,size(d.gamma,1));
            val = repmat(val(:),1,3);
        end
        d.gamma = val;
    case {'wave','wavelength'}  %nanometers
        % d = displaySet(d,'wave',val);
        % Force column, interpolate SPD, and don't do anything if it turns
        % out that the value was already as sent in.
        if ~isfield(d, 'wave')
            d.wave = val(:);
        elseif ~isequal(val(:),d.wave)
            disp('Changing wave and interpolating SPD also, for consistency')
            spd = displayGet(d,'spd');
            wave = displayGet(d,'wave');
            newSPD = interp1(wave, spd, val(:), 'linear');
            d.wave = val(:);
            d = displaySet(d,'spd',newSPD);
        end

    case {'spd','spdprimaries'}
        % d = displaySet(d,'spd primaries',val);
        if ~ismatrix(val), error('unknown spd structure'); end
        if size(val,1) < size(val, 2), val = val'; end
        d.spd = val;
        
        % Spatial matters
    case {'dpi'}
        % Dots per inch of the pixels (full pixel center-to-center)
        d.dpi = val;
    case {'viewingdistance'}
        d.dist = val;
    case {'refreshrate'}
        d.refreshRate = val;
    case {'psfs', 'point spread', 'psf'}
        assert(size(val,3)==displayGet(d, 'n primaries'), 'size mismatch');
        d.psfs = val;
    case {'comment'}
        d.comment = val;
    case {'pixelsperpsfs'}
        d.pixelsPerPSFs = val;
    case {'renderfunction'}
        d.renderFunc = val;
    otherwise
        error('Unknown parameter %s\n',parm);
end

return;
