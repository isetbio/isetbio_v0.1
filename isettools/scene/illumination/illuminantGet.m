function val = illuminantGet(il,param,varargin)
% Get parameter value for illuminant structure
%
%  val = illuminantGet(il,param,varargin)
%
%
% See also:  illuminantCreate, illuminantSet
%
% Examples
%
% (c) Imageval Consulting, LLC, 2012

if ~exist('il','var') || isempty(il), error('illuminant structure required'); end
if ~exist('param','var') || isempty(param), error('param required'); end

%%
param = ieParamFormat(param);
switch param
    case 'name'
        val = il.name;
    case 'type'
        val = il.type;
    case 'photons'
        % illuminantGet(il,'photons')
        % Check if the data are compressed.  If so, uncompress.
        if ~checkfields(il,'data','photons'), val = []; return; end
        if isa(il.data.photons,'uint32')
            bitDepth = 32;
            mn  = illuminantGet(il,'datamin');
            mx  = illuminantGet(il,'datamax');
            val = ieUncompressData(il.data.photons,mn,mx,bitDepth);
        end
    case {'datamin'}
        val = il.data.min;
    case {'datamax'}
        val = il.data.max;
    case 'energy'
        % Get the photons and convert to energy
        p =  illuminantGet(il,'photons');
        % We will have to deal with the spatial spectral issue here.  See
        % sceneGet for the switch format.
        if ndims(p) == 3,
            [p,r,c] = RGB2XWFormat(p);
            val = Quanta2Energy(illuminantGet(il,'wave'),p);
            val = XW2RGBFormat(val,r,c);
        else
            val = Quanta2Energy(illuminantGet(il,'wave'),p(:)')';
        end
    case 'wave'
        % illuminantGet(il,'wave');
        if isfield(il,'spectrum'), val = il.spectrum.wave;
        elseif ~isempty(varargin), val = sceneGet(varargin{1},'wave');
        end
    case 'comment'
        val = il.comment;
    otherwise
        error('Unknown illuminant parameter %s\n',param)
end

end
