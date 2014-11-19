function runParams = initializeRunParams(varargin)
    
    knownRunParamNames = { 'generatePlots', ...
                           'printValidationReport', ...
                        };

    defaultParams.generatePlots         = false;
    defaultParams.printValidationReport = false;
        
    if (nargin == 0)
        % default runParams
        runParams = defaultParams;
    else
        assert(nargin == 1);
        runParams = varargin{1};
        assert(isstruct(runParams));
        runParamStructFields = fieldnames(runParams);
        if ~isempty(runParamStructFields)
            for k = 1:numel(runParamStructFields)
                if (~ismember(runParamStructFields{k}, knownRunParamNames))
                    error('Unknown runParams fieldname: ''%s''', runParamStructFields{k});
                end
            end
        end
        
        if (~isfield(runParams, 'generatePlots'))
            runParams.generatePlots = defaultParams.generatePlots;
        end
        if (~isfield(runParams, 'printValidationReport'))
            runParams.printValidationReport = defaultParams.printValidationReport;
        end
    end
end