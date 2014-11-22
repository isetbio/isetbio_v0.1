function printValidationReport(validationReport)
    fprintf('\tValidation report    : ');
 
    if (numel(validationReport) == 1)
        reportEntry = validationReport{1};
        fprintf('%s\n', reportEntry);
    else
        for k = 1:numel(validationReport)
            reportEntry = validationReport{k};
            fprintf('\n\t\t%s', reportEntry);
        end
    end
    fprintf('\n\n');
end
