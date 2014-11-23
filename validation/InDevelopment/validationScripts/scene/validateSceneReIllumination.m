function [validationReport, validationFailedFlag, validationData] = validateSceneReIllumination(varargin)
%
% Skeleton validation script containing the minimally required code. Copy and add your ISETBIO validation code. 
%

    %% Initialization
    % Initialize return variables
    validationReport = ''; validationFailedFlag = false; validationData = [];
    % Initialize validation run
    runTimeParams = UnitTest.initializeValidationRun(varargin{:});
    
    % ---------------------------------------------------------------------
    % Validation code
    % ...
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
