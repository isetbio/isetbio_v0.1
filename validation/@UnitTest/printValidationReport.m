function printValidationReport(validationReport)
    fprintf('\tValidation report    : ');
 
    if (numel(validationReport) == 1)
        reportEntry = validationReport{1};
        message = reportEntry{1};
        vFailedFlag = reportEntry{2};
        if (vFailedFlag)
            fprintf(2,'%s\n', message);
        else
            fprintf('%s\n', message);
        end
    else
        for k = 1:numel(validationReport)
            reportEntry = validationReport{k};
            message = reportEntry{1};
            vFailedFlag = reportEntry{2};
            if (vFailedFlag)
                fprintf(2,'\n\t\t%s', message);
            else
                fprintf('\n\t\t%s', message);
            end
        end
    end
    
    fprintf('\n\n');
end
