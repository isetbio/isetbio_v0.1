function il = illuminantSet(il,param,val,varargin)
% Get parameter value for illuminant structure
%
%  il = illuminantSet(il,param,val,varargin)
%
%
% See also:  illuminantCreate, illuminantGet
%
% Examples
%
% (c) Imageval Consulting, LLC, 2012

if ~exist('il','var') || isempty(il), error('illuminant structure required'); end
if ~exist('param','var') || isempty(param), error('param required'); end
if ~exist('val','var') , error('val is required'); end

%%
param = ieParamFormat(param);

switch param
    case 'name'
        il.name = val;
    case 'type'
        if ~strcmpi(val,'illuminant'), error('Type must be illuminant'); end
        il.type = val;
    case 'photons'
        % il = illuminantSet(il,'photons',data);
        % Compress the data because we may have an illuminant that is
        % spectral spatial.  Don't do the whole wavelength at a time bit as
        % in sceneSet because, well, it is just too soon.  But maybe some
        % day.  Don't worry if the illuminant is a vector or a 3D matrix.
        % These are treated the same here.
        bitDepth = 32;
        [il.data.photons,mn,mx] = ieCompressData(val,bitDepth);
        il = illuminantSet(il,'datamin',mn);
        il = illuminantSet(il,'datamax',mx);
    case {'datamin'}
        il.data.min = val;
    case {'datamax'}
        il.data.max = val;
    case 'energy'
        % User sent in energy.  We convert to photons and set.
        wave = illuminantGet(il,'wave');
        if ndims(val) > 2 %#ok<ISMAT>
            [val,r,c] = RGB2XWFormat(val);
            val = Energy2Quanta(wave,val')';
            val = XW2RGBFormat(val,r,c);
            il =illuminantSet(il,'photons',val);
        else
            il =illuminantSet(il,'photons',Energy2Quanta(wave,val(:)));
        end
    case {'wave','wavelength'}
        % il = illuminantSet(il,'wave',wave)
        % Need to interpolate data sets and reset when wave is adjusted.
        oldW = illuminantGet(il,'wave');
        newW = val(:);
        il.spectrum.wave = newW;

        % Now decide what to do with photons
        p = illuminantGet(il,'photons');
        if ~isempty(p)
            % If p has the same length as newW, let's assume it was already
            % changed.  Otherwise, if it has the length of oldW, we should
            % try to interpolate it.
            if length(p) == length(newW)
                % Sample length of photons already equal to newW.  No
                % problem.
            elseif length(p) == length(oldW)
                % Adjust the sampling.
                newP = interp1(oldW,p,newW,'linear',min(p(:)*1e-3)');
                il = illuminantSet(il,'photons',newP);
            else 
                error('Photons and wavelength sample points not interpretable');
            end
            % vcNewGraphWin; plot(newW,newP);
        end
    case 'comment'
        il.comment = val;
    otherwise
        error('Unknown illuminant parameter %s\n',param)
end

end
