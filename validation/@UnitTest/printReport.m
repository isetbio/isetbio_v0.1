function printReport(obj)

    lastProbe = obj.allProbeData{numel(obj.allProbeData)};
    fprintf('\n Results for ''%s'' probe:', lastProbe.functionName);
    
    % Compose validationStatusString
    if (obj.validationFailedFlag)
        validationStatusString = sprintf('validation status      : FAILED');
    else
        validationStatusString = sprintf('validation status      : PASSED');
    end
    
    % Compose validationReportString
    validationReportString = sprintf('validation report      : %s', obj.validationReport);
    
    % Compose savedVarString
    savedVarsString = sprintf('validation data saved  : ');
    if (~isempty(obj.validationData))
        fieldNamesList = fieldnames(obj.validationData);
        for k = 1:numel(fieldNamesList)-1
            savedVarsString = [savedVarsString sprintf('''%s'', ', char(fieldNamesList{k}))];
        end
        if (numel(fieldNamesList) > 0)
            savedVarsString = [savedVarsString sprintf('''%s''', char(fieldNamesList{numel(fieldNamesList)}))];
        else
            savedVarsString = [savedVarsString 'None'];
        end
    else
        savedVarsString = [savedVarsString 'None'];
    end
    
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
    
    fprintf('\n\t %s', validationStatusString);
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