function runParams = initializeRunParams(varargin)
    
    if (nargin == 0)
        runParams.generatePlots = true;
        runParams.printValidationReport = true;
    else
        assert(nargin == 1);
        runParams = varargin{1};
        assert(isstruct(runParams));
        if (~isfield(runParams, 'generatePlots'))
            runParams.generatePlots = true;
        end
        if (~isfield(runParams, 'printValidationReport'))
            runParams.printValidationReport = true;
        end
    end
end