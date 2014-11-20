function printReport(obj, verbosity)

    if obj.validationFailedFlag
        port = 2;
    else
        port = 1;
    end
    
    if (strcmp(verbosity, 'SummaryOnly'))
        if (obj.validationFailedFlag)
            fprintf(port, '\n[%2d.] Results for ''%s'' probe: FAILED', obj.validationProbeIndex, obj.validationFunctionName);
            validationSummary = sprintf('`[Validation *FAILED*] %s.m (%s)`\n', obj.validationFunctionName, obj.validationReport);
        else
            fprintf(port, '\n[%2d.] Results for ''%s'' probe: PASSED', obj.validationProbeIndex, obj.validationFunctionName);
            validationSummary = sprintf('`[Validation passed] %s.m `\n', obj.validationFunctionName);
        end
        
        % Update validation summary
        obj.validationSummary{obj.validationProbeIndex} = validationSummary;
    
        return;
    end
        
    fprintf(port, '\n[%2d.] Results for ''%s'' probe:', obj.validationProbeIndex, obj.validationFunctionName);
    
    % Compose validationStatusString
    if (obj.validationFailedFlag)
        validationStatusString = sprintf('validation status      : FAILED');
        validationSummary = sprintf('`[Validation *FAILED* %s.m (%s)`\n',  obj.validationFunctionName, obj.validationReport);
    else
        validationStatusString = sprintf('validation status      : PASSED');
        validationSummary = sprintf('`[Validation passed] %s.m `\n', obj.validationFunctionName);
    end
    
    dashedLine(port, numel(validationStatusString)+10);    
    fprintf(port, '\n\t %s', validationStatusString);
    dashedLine(port, numel(validationStatusString)+10);
    
    % Update validation summary
    obj.validationSummary{obj.validationProbeIndex} = validationSummary;
    
    
    if obj.validationFailedFlag
        return;
    end
    
    port = 1;
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
    sysInfoString4 = sprintf('computer IP address    : %s', obj.systemData.computerAddress);
    sysInfoString5 = sprintf('username               : %s', obj.systemData.userName);
    sysInfoString6 = sprintf('git branch...tracking  : %s', obj.systemData.gitRepoBranch);
    
    charsLength = max([numel(validationReportString) numel(savedVarsString) numel(sysInfoString1) numel(sysInfoString2) numel(sysInfoString3) numel(sysInfoString4) numel(sysInfoString5) numel(sysInfoString6)])+2;
    
    
    fprintf(port, '\n\t %s', validationReportString);
    
    dashedLine(port, charsLength);
    fprintf(port, '\n\t %s', savedVarsString);
    
    dashedLine(port, charsLength);
    fprintf(port, '\n\t %s', sysInfoString1);
    fprintf(port, '\n\t %s', sysInfoString2);
    fprintf(port, '\n\t %s', sysInfoString3);
    fprintf(port, '\n\t %s', sysInfoString4);
    fprintf(port, '\n\t %s', sysInfoString5);
    fprintf(port, '\n\t %s', sysInfoString6);
    
    dashedLine(port, charsLength);
    fprintf(port, '\n');    
end
 
function dashedLine(port, charsLength)
    fprintf(port, '\n\t');
    for k = 1:charsLength
        fprintf(port, '-');
    end
end
