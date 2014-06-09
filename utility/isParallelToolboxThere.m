function ret = isParallelToolboxThere()
% Checks wheter the parallel computing toolbox is installed
% 
%   ret = isParallelToolboxThere()
%
% (c) Stanford Synapse Team 2010

% Returns all of the toolbox names
vv  = ver;
ret = any(strcmp({vv.Name}, 'Parallel Computing Toolbox'));

end