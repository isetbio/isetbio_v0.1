function varargout = v_testDataHash(varargin)
%
% Script to test the SHA-256 data hash.
%

    %% Initialization
    % Initialize validation run
    runTimeParams = UnitTest.initializeValidationRun(varargin{:});
    % Initialize return params
    if (nargout > 0) varargout = {'', false, []}; end
    
    %% Call the validation function
    ValidationFunction(runTimeParams);
    
    %% Reporting and return params
    if (nargout > 0)
        [validationReport, validationFailedFlag, validationFundametalFailureFlag] = ...
                          UnitTest.validationRecord('command', 'return');
        validationData  = UnitTest.validationData('command', 'return');
        extraData       = UnitTest.extraData('command', 'return');
        varargout       = {validationReport, validationFailedFlag, validationFundametalFailureFlag, validationData, extraData};
    else
        if (runTimeParams.printValidationReport)
            [validationReport, ~] = UnitTest.validationRecord('command', 'return');
            UnitTest.printValidationReport(validationReport);
        end 
    end
end

%% Function implementing the isetbio validation code
function ValidationFunction(runTimeParams)

    
    %% Some informative text
    UnitTest.validationRecord('SIMPLE_MESSAGE', 'Testing data hash.');
    
    %% External validations
    aNumber = 23.2374234628364872364832644357;
    probe1 = aNumber *[-1 1];
    UnitTest.validationData('probe1', probe1);
    
    probe2 = aNumber * ones(101,64,64);
    % introduce difference
    for k = 30:50
        probe2(k,4:30,30:50) = aNumber + randn(1,27, 21);
    end
    UnitTest.validationData('probe2', probe2);
    
    
    probe3 = aNumber * ones(30,64,64);
    % introduce difference
    for k = 10:20
        probe3(k,4:30,30:50) = aNumber + randn(1,27, 21);
    end
    UnitTest.validationData('probe3', probe3);
    
    
    
end
