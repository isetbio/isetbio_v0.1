function runParams = initializeRunTimeParams(varargin)

    for k = 1:numel(UnitTest.runTimeOptionNames)
       eval(sprintf('defaultParams.%s = UnitTest.runTimeOptionDefaultValues{k};', UnitTest.runTimeOptionNames{k}));
    end
    
    if (nargin > 0)
        assert(nargin == 1);
        
        runParamsPassed = varargin{1};
        
        if (isempty(runParamsPassed))
            runParams = defaultParams;
            return;
        end
        
        % Make sure passed argument is a struct
        assert(isstruct(runParamsPassed));
        
        % start with default params
        runParams = defaultParams;
        
        % Make sure the struct field names are what we expect, and modify
        % the runParams accordingly
        runParamStructFields = fieldnames(runParamsPassed);
        if ~isempty(runParamStructFields)
            for k = 1:numel(runParamStructFields)
                if (~ismember(runParamStructFields{k}, UnitTest.runTimeOptionNames))
                    error('Unknown runParams fieldname: ''%s''', runParamStructFields{k});
                else
                    eval(sprintf('runParams.%s = runParamsPassed.%s;', runParamStructFields{k}, runParamStructFields{k}));
                end
            end
        end
        
    else
       % This is the case where the script is called directly, not from a
       % UnitTest validation
       runParams = defaultParams; 
       runParams.printValidationReport = true;
       runParams.generatePlots = true;
    end
    
end