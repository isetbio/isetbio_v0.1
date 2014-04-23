function g = gammaSet(g,param,val,varargin)
% Set values in a gamma structure
%
%  g = gammaSet(g,param,val,varargin)
%
% Variables to set:
%   'table'
%   'levels'
%
% Examples:
%   vd = vdisplayCreate; dixel = vdisplayGet(vd,'dixel');
%   g = dixelGet(dixel,'gammaStructure');
%   g{1} = gammaSet(g{1},'table',[1:256]/256)
%
%   nSamples = gammaGet(g{1},'tableSize');
%   plot(1:nSamples,gammaGet(g{1},'table'))
%
%   g{1} = gammaSet(g{1},'levels',(0:255));
%

if ieNotDefined('g'), error('Gamma structure required'); end
if ieNotDefined('param'), error('Parameter required'); end
if ~exist('val','var'), error('Value required'); end

switch lower(param)
    case 'table'
        g.vGammaRampLUT = val;
    case 'levels'
        g.levels = val;
    otherwise
        error('Unknown parameter %s\n',param);
end

return;
