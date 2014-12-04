function varargout = v_numericalPrecision(varargin)
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
        [validationReport, validationFailedFlag, validationFundametalFailureFlag] = UnitTest.validationRecord('command', 'return');
        validationData = UnitTest.validationData('command', 'return');
        varargout = {validationReport, validationFailedFlag, validationFundametalFailureFlag, validationData};
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
    gain = 10E18;
    largeResult = gain*eps*rand(1,100*1000);
    largeResult = largeResult - mean(largeResult);
    
    gain = 200;
    smallResult = gain*eps*rand(1,100*1000);
    smallResult = smallResult - mean(smallResult);
    
    decimalDigits = [11 12 13 14 15 16];
    tolerance = 1E-12;
    
    % 
    % Conversion to N- digit precision
    for k = 1:numel(decimalDigits)
        nDigits = decimalDigits(k);
        largeResultRepresentations(k,:) = round(largeResult,nDigits);
        diff = abs(largeResult-squeeze(largeResultRepresentations(k,:)));
        if (any(diff >= tolerance ))
            UnitTest.validationRecord('FAILED', sprintf('large result is not represented accurately with %d decimal digits.', nDigits));
        else
            UnitTest.validationRecord('PASS', sprintf('large result is represented accurately with %d decimal digits.', nDigits));
        end
    end
    
    for k = 1:numel(decimalDigits)
        nDigits = decimalDigits(k);
        smallResultRepresentations(k,:) = round(smallResult,nDigits);
        diff = abs(smallResult-squeeze(smallResultRepresentations(k,:)));
        if (any(diff >= tolerance ))
            UnitTest.validationRecord('FAILED', sprintf('small result is not represented accurately with %d decimal digits.', nDigits));
        else
            UnitTest.validationRecord('PASS', sprintf('small result is represented accurately with %d decimal digits.', nDigits));
        end
    end
    
    % append to validationData
    UnitTest.validationData('largeResult', largeResult);
    UnitTest.validationData('resultRepresentations', largeResultRepresentations);
    UnitTest.validationData('smallResult', smallResult);
    UnitTest.validationData('smallRepresentations', smallResultRepresentations);
    
    %% Plotting
    if (runTimeParams.generatePlots)
        plotResults(1, decimalDigits, largeResult, largeResultRepresentations, 'Large Values');
        plotResults(2, decimalDigits, smallResult, smallResultRepresentations, 'Small Values');  
    end
    
end


%% Helper plotting function
function plotResults(figNum, decimalDigits, result, resultRepresentations, figName)
    h = figure(figNum);
    set(h, 'Position', [100 100  1310 1060], 'Name', figName);
    clf;
    subplotWidth = 0.66/6;
    margin = 0.05;
    for k = 1:numel(decimalDigits)
        nDigits = decimalDigits(k);
        subplot('Position', [0.06+(k-1)*(subplotWidth+margin), 0.05, subplotWidth 0.90]);
        diff = abs(result-squeeze(resultRepresentations(k,:)));
        plot(result, diff, 'b.');
        hold on; 
        plot([min(result) max(result)], [eps eps], 'r-');
        
        hold off
        set(gca, 'XLim', [min(result) max(result)], 'YLim', [0 10000*eps], 'YScale', 'log', ...
             'YTick', eps*[1 10 100 300 1000 3000 10000], ...
             'YTickLabel', {'EPS', '10EPS', '100EPS', '300EPS', '1kEPS',  '3kEPS', '10kEPS'});
        set(gca, 'FontSize', 12, 'FontName', 'Helvetica');

        xlabel('value', 'FontSize', 14, 'FontName', 'Helvetica', 'FontWeight', 'b');
        if (mod(k-1,6) == 0)
            ylabel('| value - round(value,nDigits) |', 'FontSize', 14, 'FontName', 'Helvetica', 'FontWeight', 'b');
        end
        %   set(gca, 'YTick', []) 
        
        title(sprintf('nDigits = %d', nDigits), 'FontSize', 14, 'FontName', 'Helvetica');
    end
end
        