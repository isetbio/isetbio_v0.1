function varargout = v_NumericalPrecision(varargin)
%
% Script assessing the effects of rounding at different numerical precisions.
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
    result = 0 + eps*rand(1,10000);

    decimalDigits = [3:20]+5;
    % 
    % Conversion to N- digit precision
    for k = 1:numel(decimalDigits)
        nDigits = decimalDigits(k);
        resultRepresentations(k,:) = round(result,nDigits);
        if (any(abs(result-squeeze(resultRepresentations(k,:)))>=eps/2))
            UnitTest.validationRecord('FAILED', sprintf('result is not represented accurately with %d decimal digits.', nDigits));
        else
            UnitTest.validationRecord('PASS', sprintf('result is represented accurately with %d decimal digits.', nDigits));
        end
    end

    % append to validationData
    UnitTest.validationData('resultDouble', result);
    UnitTest.validationData('resultRepresentations', resultRepresentations);
    
    %% Plotting
    if (runTimeParams.generatePlots)
        h = figure(1);
        set(h, 'Position', [100 100  1430 780]);
        clf;
        for k = 1:numel(decimalDigits)
            nDigits = decimalDigits(k);
            subplot(3,6,k);
            plot(result, abs(result-squeeze(resultRepresentations(k,:))), 'b.');
            hold on;
            plot(min(result)+[0 eps], 0.5*[eps eps], 'r-');
 
            hold off
            set(gca, 'XLim', min(result)+[0 eps], 'YLim', [0 eps], ...
                 'YTick', [0 eps/2 eps], 'YTickLabel', {'0', 'eps/2', 'eps'});
            set(gca, 'FontSize', 12, 'FontName', 'Helvetica');
            axis 'square'
            if (k > 12)
                xlabel('value', 'FontSize', 14, 'FontName', 'Helvetica', 'FontWeight', 'b');
            end
            if (mod(k-1,6) == 0)
                ylabel('value- round(value, nDigits)', 'FontSize', 14, 'FontName', 'Helvetica', 'FontWeight', 'b');
            end
            title(sprintf('nDigits = %d', nDigits), 'FontSize', 14, 'FontName', 'Helvetica');
        end
        
    end
    
end
