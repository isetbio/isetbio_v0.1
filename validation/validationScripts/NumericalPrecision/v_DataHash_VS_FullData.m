function varargout = v_DataHash_VS_FullData(varargin)
%
% Script assessing the effects of different numerical precisions on validation via data hash vs full data. 
%

    %% Initialization
    % Initialize validation run
    runTimeParams = UnitTest.initializeValidationRun(varargin{:});
    % Initialize return params
    if (nargout > 0) varargout = {'', false, []}; end
    
    %% Validation - Call validation script
    ValidationScript(runTimeParams);
    
    %% Reporting and return params
    if (nargout > 0)
        [validationReport, validationFailedFlag] = UnitTest.validationRecord('command', 'return');
        validationData = UnitTest.validationData('command', 'return');
        varargout = {validationReport, validationFailedFlag, validationData};
    else
        if (runTimeParams.printValidationReport)
            [validationReport, ~] = UnitTest.validationRecord('command', 'return');
            UnitTest.printValidationReport(validationReport);
        end 
    end
end

%% Skeleton validation script
function ValidationScript(runTimeParams)

    
    %% Initialize ISETBIO
    s_initISET;
    
    %% Isetbio validation code goes here.  
    
    %% Internal validations
    % The result of a computation: a vector of doubles
    result = eps*2.^([0:11]);
    
    % Conversion to floating-point symbolic form
    resultSymFloat    = sym(result, 'f');
    
    % Conversion to rational symbolic form
    resultSymRational = sym(result, 'r');
    
    % Conversion to decimal symbolic form
    resultSymDecimal = sym(result, 'd');
    
    % Update record
    UnitTest.validationRecord('PASSED', 'All OK');

    % append to validationData
    UnitTest.validationData('resultDouble', result);
    UnitTest.validationData('resultRound10', round(result,10));
    UnitTest.validationData('resultRound15', round(result,15));
    UnitTest.validationData('resultRound20', round(result,20));
    UnitTest.validationData('resultRound25', round(result,25));
    %% Plotting
    if (runTimeParams.generatePlots)
        
    end
    
end
