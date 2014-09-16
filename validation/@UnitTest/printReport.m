function printReport(obj)
    if (obj.validationFailedFlag)
        fprintf(2,'\n');
        for k = 1:numel(obj.validationReport)
            fprintf(2,'-');
        end
        fprintf(2,'\n');
        fprintf(2, '%s', obj.validationReport);
        fprintf(2,'\n');
        for k = 1:numel(obj.validationReport)
            fprintf(2,'-');
        end
        fprintf(2,'\n');
    else
        fprintf('\n');
        for k = 1:numel(obj.validationReport)
            fprintf('-');
        end
        fprintf('\n');
        fprintf('%s', obj.validationReport);
        fprintf('\n');
        for k = 1:numel(obj.validationReport)
            fprintf('-');
        end
        fprintf('\n');
    end
 end