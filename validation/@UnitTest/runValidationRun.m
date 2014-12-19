function returnItems = runValidationRun(functionHandle, varargin)
    
    % Initialization
    % Initialize validation run
    runTimeParams = UnitTest.initializeValidationRun(varargin);

    % Initialize return params
    if (nargout > 0) returnItems = {'', false, [], [], []}; end
    
    %% Call the validation function
    functionHandle(runTimeParams);

    
    %% Reporting and return params
    if (nargout > 0)
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
    end
end
