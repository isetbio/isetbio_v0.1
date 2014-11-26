function varargout = validateSkeleton(varargin)
%
% Skeleton script containing the minimally required code. Copy and add your ISETBIO validation code. 
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
    result = randn(100,1)*0.0001;
    tolerance = 0.001;
    if (max(abs(result) > tolerance))
        message = sprintf('Result exceeds specified tolerance (%0.1g). !!!', tolerance);
        UnitTest.validationRecord('FAILED', message);
    else
        message = sprintf('Result is within the specified tolerance (%0.1g).', tolerance);
        UnitTest.validationRecord('PASSED', message);
    end
    
    % append to validationData
    UnitTest.validationData('dummyData', ones(100,10));
    
    %% Plotting
    if (runTimeParams.generatePlots)
        figure(1);
        clf;
        plot(1:numel(result), result, 'k-');
        hold on;
        plot([1 numel(result)], tolerance*[1 1], 'r-');
        set(gca, 'YLim', [min(result) max([max(result) tolerance])*1.1]);
        drawnow;
    end
    
end
