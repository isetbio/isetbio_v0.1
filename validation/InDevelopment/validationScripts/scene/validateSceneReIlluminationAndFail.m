function [validationReport, validationFailedFlag, validationData] = validateSceneReIlluminationAndFail(varargin)
%
% Skeleton validation script that raises a run-time excemption for testing. 
%

    %% Initialization
    % Initialize return variables
    validationReport = ''; validationFailedFlag = false; validationData = [];
    % Initialize validation run
    runTimeParams = UnitTest.initializeValidationRun(varargin{:});
    
    % ---------------------------------------------------------------------
    % Validation code
    % ...
    error('Simulating runtime error');
     
    UnitTest.validationRecord('appendMessage', 'all right to here');
    UnitTest.validationData('dummyMatrix', ones(100,10));
    validationFailedFlag = false;
    
    % End of validation code
    % ---------------------------------------------------------------------
    
    %% Gather data on record
    validationReport = UnitTest.validationRecord('command', 'return');
    validationData   = UnitTest.validationData('command', 'return');
    
    
    % Plotting
    if (runTimeParams.generatePlots)
       figure(1);
       plot(1:10, 1:10, 'r-');
       axis 'square'
       drawnow;
    end
    
    % Validation report printing
    if (runTimeParams.printValidationReport)
         UnitTest.printValidationReport(validationReport); 
    end
   
end