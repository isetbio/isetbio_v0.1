function [validationReport, validationFailedFlag, validationData] = validateSceneReIlluminationAndFail(varargin)
%
% Skeleton validation script that raises a run-time excemption for testing. 
%

    % Initialize return variables
    [validationReport, validationFailedFlag, validationData] = initializeReturnParams();
    
    % Initialize run params
    runParams = initializeRunParams(varargin{:});
    
    % ---------------------------------------------------------------------
    % Validation code
    % ...
    error('Simulating runtime error');
    % ...
    % End of validation code
    % ---------------------------------------------------------------------
    
    % Update return parameters
    validationReport     = 'Nothing to report';
    validationFailedFlag = false;
    validationData.dummyMatrix = ones(100,100);
    
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