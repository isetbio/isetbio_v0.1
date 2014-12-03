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
    result = eps*(2.^([0:20]));
    
    % Doubles are represented by 64 bits with
    % 
    % Conversion to N- digit precision
    for index = 1:numel(result)
        for nDigits = 25:31
            resultRepresentations(index, nDigits) = round(result(index),nDigits);
            if (abs(resultRepresentations(index, nDigits) - result(index)) == 0)
                UnitTest.validationRecord('PASSED', sprintf('eps*%d is represented accurately with %d decimal digits.', 2^(index-1), nDigits));
            else
                UnitTest.validationRecord('FAILED', sprintf('eps*%d is not represented accurately with %d decimal digits.', 2^(index-1), nDigits));
            end
             
        end
    end

    % append to validationData
    UnitTest.validationData('resultDouble', result);
    UnitTest.validationData('resultRepresentations', resultRepresentations);
    
    %% Plotting
    if (runTimeParams.generatePlots)
        
    end
    
end
