function addProbe(obj, varargin)
    % validate input params
    p = inputParser;
    p.addParamValue('name', @ischar);
    p.addParamValue('functionName', @ischar);
    p.addParamValue('functionParams', @isstruct);
    p.addParamValue('publishReport',  @islogical);
    p.addParamValue('showTheCode',  @islogical);
    p.addParamValue('generatePlots',  @islogical);
    p.addParamValue('onErrorReaction', @ischar); 
    p.parse(varargin{:});
    
    % get input params
    newProbe.name = p.Results.name;
    newProbe.functionName   = p.Results.functionName;
    newProbe.functionParams = p.Results.functionParams;
    newProbe.onErrorReactBy = p.Results.onErrorReaction;
    newProbe.publishReport  = p.Results.publishReport;
    newProbe.generatePlots  = p.Results.generatePlots;
    
    if (exist(newProbe.functionName, 'file') == 2)
        % File in path. We're good to go
        [functionDirectory, ~, ~] = fileparts(which(sprintf('%s.m',newProbe.functionName)));
        htmlDirectory = sprintf('%s/%s_HTML', functionDirectory,newProbe.functionName);
    else
        error('File ''%s'' not found in Matlab''s path.', newProbe.functionName);
    end
    
    % input params to function
    % add any passed input params
    params = newProbe.functionParams;
    % add generatePlots flag
    params.generatePlots = newProbe.generatePlots;
    % add parent @UnitTest object
    params.parentUnitTestObject = obj;
    
    % Reset returned validation stuff
    obj.validationData = [];
    obj.validationReport = 'None';
    obj.validationFailedFlag = false;
    
    % form probe command string
    if (newProbe.publishReport)    
        % Critical: Assign the params variable to the base workstation
        assignin('base', 'params', params);
        
        command = sprintf('%s(params);', newProbe.functionName);
        options = struct(...
            'codeToEvaluate', ['params;', char(10), sprintf('%s',command), char(10)'], ...
            'evalCode', true, ...
            'showCode', p.Results.showTheCode, ...
            'catchError', false, ...
            'outputDir', htmlDirectory ...
            );
        
        probeCommandString = sprintf(' publish(''%s'', options);', newProbe.functionName);
    else 
        probeCommandString = sprintf(' %s(params);', newProbe.functionName);
    end
   

    % form try-catch command string 
    if (strcmp(newProbe.onErrorReactBy, 'CatchExcemption'))
        command = sprintf('try \n\t%s \n\t newProbe.result.validationReport = obj.validationReport; \n\t newProbe.result.validationData = obj.validationData; \n\t newProbe.result.validationFailedFlag = obj.validationFailedFlag; \n\t newProbe.result.excemptionRaised = false;  \ncatch err \n\t newProbe.result.excemptionRaised = true; \n\t newProbe.result.message = err.message; \nend', probeCommandString);
    elseif (strcmp(newProbe.onErrorReactBy, 'RethrowExcemption'))
        command = sprintf('try \n\t%s \n\t newProbe.result.validationReport = obj.validationReport; \n\t newProbe.result.validationData = obj.validationData; \n\t newProbe.result.validationFailedFlag = obj.validationFailedFlag; \n\t newProbe.result.excemptionRaised = false;  \ncatch err \n\t newProbe.result.excemptionRaised = true; newProbe.result.message = err.message; \n\t rethrow(err); \nend', probeCommandString);
    else
        error('''onErrorReaction'':%s is an invalid mode. Choose either ''CatchingExcemption'' or ''RethrowingExcemption''.', newProbe.onErrorReactBy);
    end
    
    % Run the try-catch command
    eval(command);
    
    % queue the probe to allProbeData list
    pIndex = numel(obj.allProbeData) + 1;
    obj.allProbeData{pIndex} = newProbe;
    
    if (newProbe.result.excemptionRaised)
        fprintf(2,'\n%2d. \t Name\t\t\t: ''%s'' \n', pIndex, newProbe.name);
        fprintf(2,'\t ValidationScript\t:  %s.m\n', newProbe.functionName);
        fprintf(2,'\t Status\t\t\t:  error (code raised an excemption which we caught). \n');
        fprintf(2,'\t Excemption message\t:  %s\n', newProbe.result.message);
        obj.printReport();
        % Show published report
        web(sprintf('%s/%s.html', htmlDirectory, newProbe.functionName));
        return;
    end
    
    if (newProbe.result.validationFailedFlag)
        fprintf(2,'\n%2d. \t Name\t\t\t: ''%s'' \n', pIndex, newProbe.name);
        fprintf(2,'\t ValidationScript\t:  %s.m\n', newProbe.functionName);
        fprintf(2,'\t Status\t\t\t:  validation failure - %s.\n', newProbe.result.validationReport);
        fprintf(2,'\t Validation data saved \t: ');
        fieldNamesList = fieldnames(newProbe.result.validationData);
        for k = 1:numel(fieldNamesList)-1
            fprintf(2,'''%s'', ', char(fieldNamesList{k}));
        end
        if (numel(fieldNamesList) > 0)
            fprintf(2,'''%s'' \n', char(fieldNamesList{numel(fieldNamesList)}));
        else
            fprintf(2,'None \n');
        end
        obj.printReport();
        % Show published report
        web(sprintf('%s/%s.html', htmlDirectory, newProbe.functionName));
        return;
    end
    
    
    if (~newProbe.result.validationFailedFlag) && (~newProbe.result.excemptionRaised)
        fprintf('\n%2d. \t Name\t\t\t: ''%s'' \n', pIndex, newProbe.name);
        fprintf('\t ValidationScript\t:  %s.m\n', newProbe.functionName);
        fprintf('\t Status\t\t\t:  Success - %s.\n', newProbe.result.validationReport);
        fprintf('\t Validation data saved \t: ');
        fieldNamesList = fieldnames(newProbe.result.validationData);
        for k = 1:numel(fieldNamesList)-1
            fprintf('''%s'', ', char(fieldNamesList{k}));
        end
        if (numel(fieldNamesList) > 0)
            fprintf('''%s'' \n', char(fieldNamesList{numel(fieldNamesList)}));
        else
            fprintf('None \n');
        end
        obj.printReport();
        % Show published report
        web(sprintf('%s/%s.html', htmlDirectory, newProbe.functionName));
    end
        
end

