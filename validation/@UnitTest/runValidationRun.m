function returnItems = runValidationRun(functionHandle, originalNargout, varargin)
    
    % Initialization
    % Initialize validation run
    runTimeParams = UnitTest.initializeValidationRun(varargin);
    
    % Initialize return params
    if (originalNargout > 0) returnItems = {'', false, [], [], []}; end
    
    if (originalNargout == 0)
        runTimeParams.printValidationReport = true;
    end
    
    %% Call the validation function
    functionHandle(runTimeParams);

    
    %% Reporting and return params
    if (originalNargout > 0)
        [validationReport, validationFailedFlag, validationFundametalFailureFlag] = ...
                          UnitTest.validationRecord('command', 'return');
        validationData  = UnitTest.validationData('command', 'return');
        extraData       = UnitTest.extraData('command', 'return');
        returnItems     = {validationReport, validationFailedFlag, validationFundametalFailureFlag, validationData, extraData};
    else
        if (runTimeParams.printValidationReport)
            [validationReport, ~] = UnitTest.validationRecord('command', 'return');
            UnitTest.printValidationReport(validationReport);
        end 
        returnItems = {};
    end
end
