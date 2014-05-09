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

if ieNotDefined('parm'), error('Parameter not found.');  end

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
        % Force column
        d.wave = val(:);
    case {'spd','spdprimaries'}
        % d = displaySet(d,'spd primaries',val);
        if ~ismatrix(val), error('unknonwn spd structure'); end
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
    otherwise
        error('Unknown parameter %s\n',parm);
end

return;
