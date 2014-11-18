function runParams = initializeRunParams(varargin)
    
    if (nargin == 0)
        runParams.generatePlots = true;
        runParams.printValidationReport = true;
    else
        assert(nargin == 1);
        runParams = varargin{1};
        if (isstruct(runParams))
            if (~isfield(runParams, 'generatePlots'))
                runParams.generatePlots = true;
            end
            if (~isfield(runParams, 'printValidationReport'))
                runParams.printValidationReport = true;
            end
        end
        if (isempty(runParams))
           runParams.generatePlots = true; 
           runParams.printValidationReport = true;
        end
    end
end