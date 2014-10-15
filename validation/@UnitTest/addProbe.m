function addProbe(obj, varargin)
    
    % validate input params
    p = inputParser;
    p.addParamValue('name', @ischar);
    p.addParamValue('functionSectionName', @ischar);
    p.addParamValue('functionName', @ischar);
    p.addParamValue('functionParams', @isstruct);
    p.addParamValue('showTheCode',  @islogical);
    p.addParamValue('generatePlots',  @islogical);
    p.addParamValue('onErrorReaction', @ischar); 
    p.parse(varargin{:});
    
    % get input params
    newProbe.name = p.Results.name;
    newProbe.functionSectionName   = p.Results.functionSectionName;
    newProbe.functionName   = p.Results.functionName;
    newProbe.functionParams = p.Results.functionParams;
    newProbe.onErrorReactBy = p.Results.onErrorReaction;
    newProbe.generatePlots  = p.Results.generatePlots;
    
    if (exist(newProbe.functionName, 'file') == 2)
        % File in path. We're good to go
        [functionDirectory, ~, ~] = fileparts(which(sprintf('%s.m',newProbe.functionName)));
        htmlDirectory = sprintf('%s/%s_HTML', functionDirectory,newProbe.functionName);
    else
        error('File ''%s'' not found in Matlab''s path.', newProbe.functionName);
    end
    
    
    if (obj.pushToGitHubOnSuccessfulValidation)
        % update sectionData map
        s = {};
        if (isKey(obj.sectionData,newProbe.functionSectionName))
            s = obj.sectionData(newProbe.functionSectionName);
            s{numel(s)+1} = newProbe.functionName;
        else
            s{1} = newProbe.functionName; 
        end
        obj.sectionData(newProbe.functionSectionName) = s;
    end
    
    
    % input params to function
    % add any passed input params
    params = newProbe.functionParams;
    % add generatePlots flag
    params.generatePlots = newProbe.generatePlots;
    % add parent @UnitTest object
    params.parentUnitTestObject = obj;
    
    % Reset returned validation stuff
    obj.validationFunctionName = newProbe.functionName;
    obj.validationData = [];
    obj.validationReport = 'None';
    obj.validationFailedFlag = false;
    
    % update probeIndex
    obj.validationProbeIndex = obj.validationProbeIndex + 1;
    
    % form probe command string
    if (obj.pushToGitHubOnSuccessfulValidation)    
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
        % Run validation script via MATLAB's publish method
        probeCommandString = sprintf(' publish(''%s'', options);', newProbe.functionName);
    else 
        % Run validation script the regular way
        probeCommandString = sprintf(' %s(params);', newProbe.functionName);
    end
        
    % form try-catch command string 
    if (strcmp(newProbe.onErrorReactBy, 'CatchExcemption'))
        command = sprintf('try \n\t%s \n\t newProbe.result.validationReport = obj.validationReport; \n\t newProbe.result.validationData = obj.validationData; \n\t newProbe.result.validationFailedFlag = obj.validationFailedFlag; \n\t newProbe.result.excemptionRaised = false;  \ncatch err \n\t newProbe.result.excemptionRaised = true; \n\t obj.validationFailedFlag = true; \n\t newProbe.result.message = err.message; \nend', probeCommandString);
    elseif (strcmp(newProbe.onErrorReactBy, 'RethrowExcemption'))
        command = sprintf('try \n\t%s \n\t newProbe.result.validationReport = obj.validationReport; \n\t newProbe.result.validationData = obj.validationData; \n\t newProbe.result.validationFailedFlag = obj.validationFailedFlag; \n\t newProbe.result.excemptionRaised = false;  \ncatch err \n\t newProbe.result.excemptionRaised = true; \n\t obj.validationFailedFlag = true; \n\t newProbe.result.message = err.message; \n\t rethrow(err); \nend', probeCommandString);
    else
        error('''onErrorReaction'':%s is an invalid mode. Choose either ''CatchingExcemption'' or ''RethrowingExcemption''.', newProbe.onErrorReactBy);
    end
    
    % Run the try-catch command
    eval(command);

    % queue the probe to allProbeData list
    pIndex = obj.validationProbeIndex;
    obj.allProbeData{pIndex} = newProbe;
    
    
    if (newProbe.result.excemptionRaised)
        % remove generated htmlDirectory so that it is not published to gitHub
        system(sprintf('rm -r -f %s',htmlDirectory));
        % also remove entry in sectionData
        if (obj.pushToGitHubOnSuccessfulValidation)
            % update sectionData map
            s = obj.sectionData(newProbe.functionSectionName);
            if (numel(s) == 1)
                s = {};
            else
                s = {s{1:end-1}};
            end
            obj.sectionData(newProbe.functionSectionName) = s;
        end
        
        obj.printReport();
        fprintf(2,'\n\t ValidationReport\t:  Error (code raised an excemption which we caught). \n');
        fprintf(2,'\t Excemption message\t:  %s\n', newProbe.result.message);
        return;
    end
    
    if (newProbe.result.validationFailedFlag)
        % remove generated htmlDirectory so that it is not published to gitHub
        system(sprintf('rm -r -f %s', htmlDirectory));
        % also remove entry in sectionData
        if (obj.pushToGitHubOnSuccessfulValidation)
            % update sectionData map
            s = obj.sectionData(newProbe.functionSectionName);
            if (numel(s) == 1)
                s = {};
            else
                s = {s{1:end-1}};
            end
            obj.sectionData(newProbe.functionSectionName) = s;
        end
        
        obj.printReport('All');
        fprintf(2,'\n\t ValidationReport\t: %s\n', newProbe.result.validationReport);
        return;
    end
    
    % 
    if (~newProbe.result.validationFailedFlag) && (~newProbe.result.excemptionRaised)
        
        if (1==2)
        if (obj.displayAllValidationResults)
            obj.printReport('All');
        else
            obj.printReport('SummaryOnly');
        end
        end
        
    end
        
end

