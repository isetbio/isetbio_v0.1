function varargout = v_fundamentalValidationFailure(varargin)
%
% Example validation script that demonstrates usage of the fundemantal failure feature. 
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

function ValidationFunction(runTimeParams)
      
    % Simulate fundamental failure here
    if (true)
        UnitTest.validationRecord('FUNDAMENTAL_CHECK_FAILED', 'Fundamental failure message goes here.');
        return;
    end
    
    UnitTest.validationRecord('PASSED',  'all right to here');
    UnitTest.validationData('dummyData', ones(100,10));
    
    % Plotting
    if (runTimeParams.generatePlots)
       figure(1);
       clf;
       plot(1:10, 1:10, 'r-');
       axis 'square'
       drawnow;
    end
    
end