% Main validation engine
function validate(obj, vScriptsToRunList)
    
    fprintf('\n----------------------------------------------------------------------------------\n');
    fprintf('Running in ''%s'' validation mode with ''%s'' runtime hehavior.', obj.validationParams.type, obj.validationParams.onRunTimeError);
    fprintf('\n----------------------------------------------------------------------------------\n');
    
    obj.vScriptsList = vScriptsToRunList;
    validationParams = obj.validationParams;
    
    % Go through each entry
    for scriptIndex = 1:numel(obj.vScriptsList) 
        scriptListEntry = obj.vScriptsList{scriptIndex};
        
        % scriptName
        scriptName = scriptListEntry{1};
        urlToScript =  sprintf('<a href="matlab: matlab.desktop.editor.openAndGoToFunction(which(''%s.m''),'''')">''%s.m''</a>', scriptName, scriptName);
        fprintf('\n[%3d] %s\n ', scriptIndex, urlToScript);
        
        % scripRunParams
        if (numel(scriptListEntry) == 2)
            scriptRunParams = scriptListEntry{2};
        else
            scriptRunParams = [];
        end
        
        % Make sure script exists in the path
        if (exist(scriptName, 'file') == 2)
            % File in path. We're good to go
            [functionDirectory, ~, ~] = fileparts(which(sprintf('%s.m',scriptName)));
            htmlDirectory = sprintf('%s/%s_HTML', functionDirectory,scriptName);
            fullLocalValidationHistoryDataFile = sprintf('%s/%s_FullValidationDataHistory.mat', functionDirectory,scriptName);
            fastLocalValidationHistoryDataFile = sprintf('%s/%s_FastValidationDataHistory.mat', functionDirectory,scriptName);
            fullLocalGroundTruthHistoryDataFile = sprintf('%s/%s_FullGroundTruthDataHistory.mat', functionDirectory,scriptName);
            fastLocalGroundTruthHistoryDataFile = sprintf('%s/%s_FastGroundTruthDataHistory.mat', functionDirectory,scriptName);
        else
            error('File ''%s'' not found in Matlab''s path.', scriptName);
        end
    
        % Initialize flags and reports, data
        validationReport        = '';
        validationFailedFlag    = true;
        exemptionRaisedFlag     = true;
        validationData          = [];
        
        if strcmp(validationParams.type, 'FAST')
            % Run script the regular way
            commandString = sprintf(' [validationReport, validationFailedFlag, validationData] = %s(scriptRunParams);', scriptName);
        elseif strcmp(validationParams.type, 'FULL')
            % Run script the regular way
            commandString = sprintf(' [validationReport, validationFailedFlag, validationData] = %s(scriptRunParams);', scriptName);
        elseif strcmp(validationParams.type, 'PUBLISH')
            % Critical: Assign the params variable to the base workstation
            assignin('base', 'scriptRunParams', scriptRunParams);
            % Form publish options struct
            command = sprintf('[validationReport, validationFailedFlag, validationData] = %s(scriptRunParams);', scriptName);
            options = struct(...
                'codeToEvaluate', ['scriptRunParams;', char(10), sprintf('%s',command), char(10)'], ...
                'evalCode',     true, ...
                'showCode',     true, ...
                'catchError',   strcmp(validationParams.onRunTimeError,'catchExemptionAndContinue'), ...
                'outputDir',    htmlDirectory ...
            );
            % Run script via MATLAB's publish method
            commandString = sprintf(' publish(''%s'', options);', scriptName);
        end
        
        % Form the try-catch command 
        if (strcmp(validationParams.onRunTimeError, 'catchExemptionAndContinue'))
            command = sprintf('try \n\t%s \n\t exemptionRaisedFlag = false;  \ncatch err \n\t exemptionRaisedFlag = true; validationReport = sprintf(''FAILED - exemption raised (and caught): %%s'', err.message); \nend', commandString);
        else
            command = sprintf('try \n\t%s  \n\t  exemptionRaisedFlag = false; \ncatch err \n\t exemptionRaisedFlag = true; validationReport = sprintf(''FAILED - exemption raised: %%s'', err.message); \n\t rethrow(err); \nend', commandString);
        end
        
        % Run the try-catch command
        eval(command);
    
        if strcmp(validationParams.type, 'PUBLISH')
            % Extract the value of the variables 'validationReport' in the MATLAB's base workspace and captures them in the corresponding local variable 'validationReport'
            validationReport     = evalin('base', 'validationReport');
            validationFailedFlag = evalin('base', 'validationFailedFlag');
            validationData       = evalin('base', 'validationData');
        end
            
        % Update the command line output
        if (validationFailedFlag)
           fprintf(2, '\tInternal validation  : FAILED\n');
        else
           fprintf('\tInternal validation  : PASSED\n'); 
        end
        if (exemptionRaisedFlag)
           fprintf(2, '\tRun-time status      : exemption raised\n');
        else
           fprintf('\tRun-time status      : no exemption raised\n'); 
        end
        
        
        % Now begin validation against ground truth
        
        groundTruthFastValidationFailed = false;
        groundTruthFullValidationFailed = false;
        
        % 'FAST' mode validation
        if ( (strcmp(validationParams.type, 'FAST'))  && ...
             (~validationFailedFlag) && (~exemptionRaisedFlag) )
            
            % Generate SHA256 hash from the validationData
            hashSHA25 = obj.generateSHA256Hash(validationData);
            
            % Load and check value stored in LocalGroundTruthHistoryDataFile 
            dataFileName = fastLocalGroundTruthHistoryDataFile;
            forceUpdateGroundTruth = false;
            
            if (exist(dataFileName, 'file') == 2)
                [groundTruthData, groundTruthTime] = obj.importGroundTruthData(dataFileName);
                if (strcmp(groundTruthData, hashSHA25))
                    fprintf('\tFast validation      : PASSED against ground truth data of %s\n', groundTruthTime);
                    groundTruthFastValidationFailed = false;
                else
                    fprintf(2,'\tFast validation      : FAILED against ground truth data of %s\n', groundTruthTime);
                    groundTruthFastValidationFailed = true;
                end
            else
                forceUpdateGroundTruth = true;
                fprintf('\tFast validation      : no ground truth dataset exists. Generating one. \n');
            end
            
            if (~groundTruthFastValidationFailed)
                % save/append to LocalValidationHistoryDataFile
                dataFileName = fastLocalValidationHistoryDataFile;
                if (exist(dataFileName, 'file') == 2)
                    fprintf('\tSHA-256 hash key     : %s, appended to ''%s''\n', hashSHA25, dataFileName);
                else
                    fprintf('\tSHA-256 hash key     : %s, written to ''%s''\n', hashSHA25, dataFileName);
                end
                obj.exportData(dataFileName, hashSHA25);

                % save/append to LocalGroundTruthHistoryDataFile 
                if (validationParams.updateGroundTruth) || (forceUpdateGroundTruth)
                    dataFileName = fastLocalGroundTruthHistoryDataFile;
                    if (exist(dataFileName, 'file') == 2)
                        fprintf('\tSHA-256 hash key     : %s, appended to ''%s''\n', hashSHA25, dataFileName);
                    else
                        fprintf('\tSHA-256 hash key     : %s, written to ''%s''\n', hashSHA25, dataFileName);
                    end
                    obj.exportData(dataFileName, hashSHA25);
                end
            end
        end
        
        
        
       % 'FULL' mode validation
        if ( (strcmp(validationParams.type, 'FULL'))  && ...
             (~validationFailedFlag) && (~exemptionRaisedFlag) )
            
            % Load and check value stored in LocalGroundTruthHistoryDataFile 
            dataFileName = fullLocalGroundTruthHistoryDataFile;
            forceUpdateGroundTruth = false;
            
            if (exist(dataFileName, 'file') == 2)
                [groundTruthData, groundTruthTime] = obj.importGroundTruthData(dataFileName);
                if (obj.structsAreSimilar(groundTruthData, validationData))
                    fprintf('\tFull validation      : PASSED against ground truth data of %s\n', groundTruthTime);
                    groundTruthFullValidationFailed = false;
                else
                    fprintf(2,'\tFull validation      : FAILED against ground truth data of %s\n', groundTruthTime);
                    groundTruthFullValidationFailed = true;
                end
            else
                forceUpdateGroundTruth = true;
                fprintf('\tFull validation      : no ground truth dataset exists. Generating one. \n');
            end
            
    
            
            if (~groundTruthFullValidationFailed)
                % save/append to LocalValidationHistoryDataFile
                dataFileName = fullLocalValidationHistoryDataFile;
                if (exist(dataFileName, 'file') == 2)
                    fprintf('\tFull validation data : appended to ''%s''\n', dataFileName);
                else
                    fprintf('\tFull validation data : written to ''%s''\n', dataFileName);
                end
                obj.exportData(dataFileName, validationData);

                % save/append to LocalGroundTruthHistoryDataFile
                if (validationParams.updateGroundTruth) || (forceUpdateGroundTruth)
                    dataFileName = fullLocalGroundTruthHistoryDataFile;
                    if (exist(dataFileName, 'file') == 2)
                        fprintf('\tFull validation data : appended to ''%s''\n', dataFileName);
                    else
                        fprintf('\tFull validation data : written to ''%s''\n', dataFileName);
                    end
                    obj.exportData(dataFileName, validationData);
                end
            end
            
        end
        
        
        fprintf('\tValidation report    : ''%s''\n', validationReport);
        
    end % scriptIndex
    
end