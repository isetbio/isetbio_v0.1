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
        
    case {'dpi'}
        % displaySet(d, 'dpi', val);
        % Dots per inch of the pixels (full pixel center-to-center)
        d.dpi = val;
    case {'viewingdistance'}
        % viewing distance in meters
        d.dist = val;
    case {'refreshrate'}
        % refresh rate of the display in Hz
        d.refreshRate = val;
    case {'psfs', 'point spread', 'psf'}
        % subpixel image of the display (point spread)
        assert(size(val,3)==displayGet(d, 'n primaries'), 'size mismatch');
        d.psfs = val;
    case {'comment'}
        % comment for the display
        d.comment = val;
    case {'pixelsperpsfs'}
        % number of pixels in one subpixel image
        d.pixelsPerPSFs = val;
    case {'renderfunction'}
        % rendering function that converts input image to subpixel level
        d.renderFunc = val;
    case {'blackradiance', 'blackspectrum'}
        % black radiance
        nWave = displayGet(d, 'n wave');
        if isscalar(val)
            d.blackRadiance = val * ones(nWave, 1);
        else
            assert(length(val(:)) == nWave, 'bad black radiance length');
            d.blackRadiance = val(:);
        end
    case {'blackmaskreflectance', 'maskreflectance', 'blackreflectance'}
        % black mask reflectance
        assert(all(val(:) >= 0 & val(:) <= 1), 'bad reflectance val');
        nWave = displayGet(d, 'n wave');
        if isscalar(val)
            d.blackReflectance = val * ones(nWave, 1);
        else
            assert(length(val) == nWave, 'bad black reflectance length');
            d.blackReflectance = val(:);
        end
    otherwise
        error('Unknown parameter %s\n',parm);
end

end