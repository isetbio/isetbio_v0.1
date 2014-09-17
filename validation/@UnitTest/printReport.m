function printReport(obj)

    fprintf('\n\tDetailed validation results:');
    % Compose validationReportString
    validationReportString = sprintf('validation report      : %s', obj.validationReport);
    
    % Compose savedVarString
    savedVarsString = sprintf('validation data saved  : ');
    fieldNamesList = fieldnames(obj.validationData);
    for k = 1:numel(fieldNamesList)-1
        savedVarsString = [savedVarsString sprintf('''%s'', ', char(fieldNamesList{k}))];
    end
    savedVarsString = [savedVarsString sprintf('''%s''', char(fieldNamesList{numel(fieldNamesList)}))];
        
    % Compose sysInfoStrings
    sysInfoString1 = sprintf('date last run          : %s', obj.systemData.datePerformed);
    sysInfoString2 = sprintf('matlabVersion          : %s', obj.systemData.matlabVersion);
    sysInfoString3 = sprintf('computer architecture  : %s', obj.systemData.computer);
    sysInfoString4 = sprintf('git branch...tracking  : %s', obj.systemData.gitRepoBranch);
    
    charsLength = max([numel(validationReportString) numel(savedVarsString) numel(sysInfoString1) numel(sysInfoString2) numel(sysInfoString3) numel(sysInfoString4)])+2;
    
    fprintf('\n\t');
    for k = 1:charsLength
        fprintf('-');
    end
    
    fprintf('\n\t %s', validationReportString);
    fprintf('\n\t %s', savedVarsString);
    fprintf('\n\t');
    for k = 1:charsLength
        fprintf('-');
    end
    fprintf('\n\t %s', sysInfoString1);
    fprintf('\n\t %s', sysInfoString2);
    fprintf('\n\t %s', sysInfoString3);
    fprintf('\n\t %s', sysInfoString4);
    fprintf('\n\t');
    for k = 1:charsLength
        fprintf('-');
    end
    fprintf('\n');
        
 end