function varargout = v_skeleton(varargin)
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

%% Skeleton validation script
function ValidationScript(runTimeParams)

    
    %% Initialize ISETBIO
    s_initISET;
    
    %% Isetbio validation code goes here.  
    
    
    %% Some informative text
    UnitTest.validationRecord('message', 'Skeleton script. Copy and adapt to your needs.');
    
    %% Internal validations
    quantityOfInterest = randn(100,1)*0.0000001;
    tolerance = 0.000001;
    if (max(abs(quantityOfInterest) > tolerance))
        message = sprintf('Result exceeds specified tolerance (%0.1g). !!!', tolerance);
        UnitTest.validationRecord('FAILED', message);
    else
        message = sprintf('Result is within the specified tolerance (%0.1g).', tolerance);
        UnitTest.validationRecord('PASSED', message);
    end
    
    % Simulate fundamental failure here
    funamentalCheckPassed = true;
    if (~funamentalCheckPassed)
        UnitTest.validationRecord('FUNDAMENTAL_CHECK_FAILED', 'An informative fundamental failure message goes here.');
        % You can optionally abort the script at this point using a 'return' command:
        % return;
    end
    
    %% Data for external validations
    dataA = ones(10,20);
    
    % Add validation data - these will be contrasted against the
    % ground truth data with respect to a specified tolerance level
    % and the result will determine whether the validation passes or fails.
    UnitTest.validationData('variableNameForDataA', dataA);
    
    %% Data to keep just because it would be nice to have
    dataB = rand(10,30);
     
    % Add extra data - these will be contrasted against their stored
    % counterpants only when the verbosity level is set to 'med' or higher,
    % and only when running in 'FULL' validation mode.
    % The validation status does not depend on the status of these comparisons.
    % This can be useful for storing variables that have a stochastic component.
    UnitTest.extraData('variableNameForDataB', dataB);
    
    %% Plotting
    if (runTimeParams.generatePlots)
        figure(7);
        clf;
        plot(1:numel(quantityOfInterest ), quantityOfInterest , 'k-');
        hold on;
        plot([1 numel(quantityOfInterest )], tolerance*[1 1], 'r-');
        set(gca, 'YLim', [min(quantityOfInterest ) max([max(quantityOfInterest ) tolerance])*1.1]);
        drawnow;
    end
end
