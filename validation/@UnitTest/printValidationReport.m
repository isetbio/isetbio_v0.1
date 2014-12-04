function printValidationReport(validationReport)
    fprintf('\tValidation report    : ');
 
    if (numel(validationReport) == 1)
        reportEntry = validationReport{1};
        message                 = reportEntry{1};
        vFailedFlag             = reportEntry{2};
        vFundemantelFailureFlag = reportEntry{3};
        if (vFailedFlag)
            if (vFundemantelFailureFlag)
                fprintf(2,'\n\t\t-------------- F U N D A M E N T A L    F A I L U R E -----------------');
                fprintf(2,'\n\t\t%s', message);
                fprintf(2,'\n\t\t-----------------------------------------------------------------------');
            else
                fprintf(2,'%s\n', message);
            end
        else
            fprintf('%s\n', message);
        end
    else
        for k = 1:numel(validationReport)
            reportEntry             = validationReport{k};
            message                 = reportEntry{1};
            vFailedFlag             = reportEntry{2};
            vFundemantelFailureFlag = reportEntry{3};
            if (vFailedFlag)
                if (vFundemantelFailureFlag)
                    fprintf(2,'\n\t\t-------------- F U N D A M E N T A L    F A I L U R E -----------------');
                    fprintf(2,'\n\t\t%s', message);
                    fprintf(2,'\n\t\t-----------------------------------------------------------------------');
                else
                    fprintf(2,'\n\t\t%s', message);
                end
            else
                fprintf('\n\t\t%s', message);
            end
        end
    end
    
    fprintf('\n\n');
end
