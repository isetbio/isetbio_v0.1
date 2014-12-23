function rgc = rgcCreate(species, varargin)
%% function rgc = rgcCreate(species, [varargin])
%    Creates a structure definition of retina gangalion cell
%    To create rgc class, please refer to rgcParameters.m
%
%  The parameter includes:
%    name     - name of the rgc structure
%    type     - 'rgc'
%    species  - 'human'
%    trDur    - temporal response duration
%    layers   - rgc layers
%    distFunc - distance function handle
%    noise    - noise type
%
%  Inputs:
%    species   - can only be 'human'
%    varargin  - name value pairs to set initial values
%
%  Outputs:
%    rgc       - rgc structure
%
%  Notes:
%    Compared to rgcParameters, we do not store sensor, oi, scene or cVolts
%    information in rgc structure. Instead, we will ask user to provide
%    these information in rgc spikes computation routine
%
%  HJ/BW (c) ISETBIO Team, 2014

%% Check inputs and init
if notDefined('species'), species = 'human'; end
assert(mod(length(varargin),2)==0, 'varargin should be name-value pairs');

%% Init rgc structure
switch species
    case 'human'
        % Init basic parameters
        rgc.name = sprintf('rgc-%s',date);  % rgc name
        rgc.type = 'rgc'; % type
        rgc.species = species; % human
        rgc.trDur = 0.15; % temporal response is slow, set to 150 ms
        rgc.layers = {};
        
        % Init noise structure
        rgc.noise = 0;
    otherwise
        error('unknown species');
end

%% Set user defined parameter values
for ii = 1 : length(varargin)
    rgc.(varargin{ii}) = varargin{ii+1};
end