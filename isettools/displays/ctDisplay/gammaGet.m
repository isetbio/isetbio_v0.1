function val = gammaGet(g,param,varargin)
% Get values from gamma structure
%
%  val = gammaGet(g,param,varargin)
%
% Examples
%   vd = vdisplayCreate; dixel = vdisplayGet(vd,'dixel');
%   g = dixelGet(dixel,'gammaStructure');
%   val = gammaGet(g{1},'table');
%   val = gammaGet(g{1},'gVal',128);
%   val = gammaGet(g{1},'tableSize')       
%
%   l = gammaGet(g{1},'levels')
%   t = gammaGet(g{1},'table');
%   plot(l,t)

if ieNotDefined('g'), error('Gamma structure required'); end
if ieNotDefined('param'), error('Parameter required'); end

switch lower(param)
    case {'nsamples','tablesize'}
        val = length(g.vGammaRampLUT);
    case 'table'
        if checkfields(g,'vGammaRampLUT'), val = g.vGammaRampLUT; end
    case 'levels'
        if checkfields(g,'levels'), val = g.levels; end
    case 'gval'
        % val = gammaGet(g,'gVal',128);
        if isempty(varargin), error('Table value required'); end
        table = gammaGet(g,'table');
        nSamples = gammaGet(g,'tableSize');
        val = interp1(1:nSamples,table,varargin{1});
    otherwise
        error('Unknown parameter %s\n',param);
end

return;
