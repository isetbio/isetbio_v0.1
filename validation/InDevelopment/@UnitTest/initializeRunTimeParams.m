function runParams = initializeRunTimeParams(varargin)

    for k = 1:numel(UnitTest.runTimeOptionNames)
       eval(sprintf('defaultParams.%s = UnitTest.runTimeOptionDefaultValues{k};', UnitTest.runTimeOptionNames{k}));
    end
    
    if (nargin > 0)
        assert(nargin == 1);
        if (isempty(varargin{1}))
            runParams = defaultParams;
            return;
        end
        runParams = defaultParams;
        runParamsPassed = varargin{1};
        assert(isstruct(runParamsPassed));
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
       error('Expected one input argument. There were 0.'); 
    end
    
end