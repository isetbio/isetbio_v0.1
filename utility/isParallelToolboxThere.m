function yesorno = isParallelToolboxThere()
% Checks wheter the parallel computing toolbox is installed
% 
%   yesorno = isParallelToolboxThere()
%
% (c) Stanford Synapse Team 2010

% Returns all of the toolbox names
vv = ver;

yesorno = 0;
for ii = 1:length(vv)
    yesorno = yesorno || isequal('Parallel Computing Toolbox',vv(ii).Name);
end

return