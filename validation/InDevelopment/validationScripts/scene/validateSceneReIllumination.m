function [validationReport, validationFailedFlag, validationData] = validateSceneReIllumination(varargin)
%
% Skeleton validation script containing the minimally required code. Copy and add your ISETBIO validation code. 
%

    % Initialize return variables
    [validationReport, validationFailedFlag, validationData] = UnitTest.initializeReturnParams();
    
    % Initialize run params
    runTimeParams = UnitTest.initializeRunTimeParams(varargin{:});
    
    % ---------------------------------------------------------------------
    % Validation code
    % ...
    % End of validation code
    % ---------------------------------------------------------------------
    
    % Update return parameters
    validationReport     = 'Nothing to report';
    validationFailedFlag = false;
    validationData.dummyMatrix = ones(100,100);
    
    % Plotting
    if (runTimeParams.generatePlots)
       figure(1);
       plot(1:10, 1:10, 'r-');
       axis 'square'
       drawnow;
    end
    
    % Validation report printing
    if (runTimeParams.printValidationReport)
        fprintf('Validation Report:\n\t%s\n\n', validationReport);
    end
end
