function [validationReport, validationFailedFlag, validationData] = validateSceneReIlluminationAndFail(varargin)
    
    % Initialize return variables to failed status
    [validationReport, validationFailedFlag, validationData] = initializeReturnParams();
    
    % Initialize run params
    runParams = initializeRunParams(varargin{:});
    
    
    % Validation code
    % ...
    %
    % simulate code crash
    error('Simulating error in validation code');
    
    
    % Update return parameters
    validationReport     = 'All OK';
    validationFailedFlag = false;
    validationData.dummyMatrix = randn(100,100);
    
    % Plotting
    if (runParams.generatePlots)
       figure(1);
       plot(1:10, 1:10, 'r-');
       axis 'square'
       drawnow;
    end
    
    % Validation report printing
    if (runParams.printValidationReport)
        fprintf('Validation Report:\n\t%s\n\n', validationReport);
    end
     
end