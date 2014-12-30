% Main validation engine
function validate(obj, vScriptsToRunList)
    
    if (obj.validationParams.verbosity > -1)
        fprintf('\n------------------------------------------------------------------------------------------------------------\n');
        fprintf('Running in ''%s'' mode with ''%s'' runtime hehavior and verbosity level = ''%s''.', obj.validationParams.type, obj.validationParams.onRunTimeError, UnitTest.validVerbosityLevels{obj.validationParams.verbosity+1});
    end
    
    % Parse the scripts list to ensure it is valid
    obj.vScriptsList = obj.parseScriptsList(vScriptsToRunList);
    
    if (obj.validationParams.verbosity > 1) 
        fprintf('\nWill validate %d scripts.', numel(obj.vScriptsList)); 
    end
    
    if (obj.validationParams.verbosity > -1)
        fprintf('\n------------------------------------------------------------------------------------------------------------\n');
    end
    
    % get validation params
    validationParams = obj.validationParams;
    
    %Ensure that needed directories exist, and generates them if they do not
    obj.checkDirectories();
    
    % reset currentValidationSessionResults
    obj.validationSessionRunTimeExceptions = [];
    
    % Go through each entry
    scriptIndex = 0;
    abortValidationSession = false;
    
    
    while (scriptIndex < numel(obj.vScriptsList)) && (~abortValidationSession)
        
        scriptIndex = scriptIndex + 1;
        
        % get the current entry
        scriptListEntry = obj.vScriptsList{scriptIndex};
        
        % get the scriptName
        scriptName = scriptListEntry{1};
        
        % form a URL for it
        urlToScript =  sprintf('<a href="matlab: matlab.desktop.editor.openAndGoToFunction(which(''%s.m''),'''')">''%s.m''</a>', scriptName, scriptName);
        
        if (obj.validationParams.verbosity > 0) 
            % print it in the command line
            fprintf('\n[%3d] %s\n', scriptIndex, urlToScript);
        end
        
        % get the scripRunParams
        if (numel(scriptListEntry) == 2)
            scriptRunParams = scriptListEntry{2};
            % make sure we do not generate plots in RUNTIME_ERRORS_ONLY mode
            if (strcmp(obj.validationParams.type, 'RUNTIME_ERRORS_ONLY'))
                scriptRunParams.generatePlots = false;
            end
        else % Use IOSETBIO prefs
            scriptRunParams = [];
            
            if (strcmp(obj.validationParams.type, 'RUNTIME_ERRORS_ONLY'))
                scriptRunParams.generatePlots = false;
            end
        end
               
        % Make sure script exists in the path
        if (exist(scriptName, 'file') == 2)
            % Determine function sub-directory
            [functionDirectory, ~, ~] = fileparts(which(sprintf('%s.m',scriptName)));
            indices              = strfind(functionDirectory, filesep);
            functionSubDirectory = functionDirectory(indices(end)+1:end);
            % Construct path strings
            htmlDirectory                       = fullfile(obj.htmlDir, functionSubDirectory, sprintf('%s_HTML', scriptName), filesep);  % sprintf('%s/%s/%s_HTML',                           obj.htmlDir,           functionSubDirectory, scriptName);
            fullLocalValidationHistoryDataFile  = fullfile(obj.validationDataDir, functionSubDirectory, sprintf('%s_FullValidationDataHistory.mat', scriptName)); %sprintf('%s/%s/%s_FullValidationDataHistory.mat',  obj.validationDataDir, functionSubDirectory, scriptName);
            fastLocalValidationHistoryDataFile  = fullfile(obj.validationDataDir, functionSubDirectory, sprintf('%s_FastValidationDataHistory.mat', scriptName)); % ) sprintf('%s/%s/%s_FastValidationDataHistory.mat',  obj.validationDataDir, functionSubDirectory, scriptName);
            fullLocalGroundTruthHistoryDataFile = fullfile(obj.validationDataDir, functionSubDirectory, sprintf('%s_FullGroundTruthDataHistory.mat', scriptName)); % sprintf('%s/%s/%s_FullGroundTruthDataHistory.mat', obj.validationDataDir, obj.validationDataDir, scriptName);
            fastLocalGroundTruthHistoryDataFile = fullfile(obj.validationDataDir, functionSubDirectory, sprintf('%s_FastGroundTruthDataHistory.mat', scriptName)); % sprintf('%s/%s/%s_FastGroundTruthDataHistory.mat', obj.validationDataDir, functionSubDirectory, scriptName);
        else
            error('A file named ''%s'' does not exist in the path.', scriptName);
        end
   
        
        % Initialize flags, reports, and validation data
        validationReport        = '';
        validationFailedFlag    = true;
        validationFundamentalFailureFlag = true;
        exceptionRaisedFlag     = true;
        validationData          = [];
        extraData               = [];
        
        if strcmp(validationParams.type, 'RUNTIME_ERRORS_ONLY')
            % Run script the regular way
            commandString = sprintf(' [validationReport, validationFailedFlag, validationFundamentalFailureFlag, validationData, extraData] = %s(scriptRunParams);', scriptName);
            
        elseif strcmp(validationParams.type, 'FAST')
            % Create validationData sub directory if it does not exist;
            obj.generateDirectory(obj.validationDataDir, functionSubDirectory);
            % Run script the regular way
            commandString = sprintf(' [validationReport, validationFailedFlag, validationFundamentalFailureFlag, validationData, extraData] = %s(scriptRunParams);', scriptName);
            
        elseif strcmp(validationParams.type, 'FULL')
            % Create validationData sub directory if it does not exist;
            obj.generateDirectory(obj.validationDataDir, functionSubDirectory);
            % Run script the regular way
            commandString = sprintf(' [validationReport, validationFailedFlag, validationFundamentalFailureFlag, validationData, extraData] = %s(scriptRunParams);', scriptName);
            
        elseif strcmp(validationParams.type, 'PUBLISH')
            % Create validationData sub directory if it does not exist;
            obj.generateDirectory(obj.validationDataDir, functionSubDirectory);
            % Create HTML sub directory if it does not exist;
            obj.generateDirectory(obj.htmlDir, functionSubDirectory)
            % Critical: Assign the params variable to the base workstation
            assignin('base', 'scriptRunParams', scriptRunParams);
            % Form publish options struct
            command = sprintf('[validationReport, validationFailedFlag, validationFundamentalFailureFlag, validationData, extraData] = %s(scriptRunParams);', scriptName);
            options = struct(...
                'codeToEvaluate', ['scriptRunParams;', char(10), sprintf('%s',command), char(10)'], ...
                'evalCode',     true, ...
                'showCode',     true, ...
                'catchError',   false, ...
                'outputDir',    htmlDirectory ...
            );
            % Run script via MATLAB's publish method
            commandString = sprintf(' publish(''%s'', options);', scriptName);
        end
        
        % Form the try-catch command 
        if (strcmp(validationParams.onRunTimeError, 'catchExceptionAndContinue'))
            command = sprintf('try \n\t%s \n\t exceptionRaisedFlag = false;  \ncatch err \n\t exceptionRaisedFlag = true;\n\t validationReport{1} = {sprintf(''exception raised (and caught) with message: %%s'', err.message), true, false};  \nend', commandString);
        else
            command = sprintf('try \n\t%s  \n\t exceptionRaisedFlag = false; \ncatch err \n\t exceptionRaisedFlag = true;\n\t validationReport{1} = {sprintf(''exception raised with message: %%s'', err.message), true, false};  \n\t rethrow(err);  \nend', commandString);
        end
        
        if (obj.validationParams.verbosity > 5)
            fprintf('\nRunning with ');
            eval('scriptRunParams');
        end
        
        if (obj.validationParams.verbosity > 4)
           fprintf('\nExecuting:\n%s\n', command); 
        end
        
        % Run the try-catch command and capture the output in T
        T = evalc(command); 
        
        % Update currentValidationSeesionResults
        obj.validationSessionRunTimeExceptions(scriptIndex) = exceptionRaisedFlag;
        
        if (strcmp(validationParams.type, 'PUBLISH'))
            if (exceptionRaisedFlag)
                validationFailedFlag = true;
                validationFundamentalFailureFlag = false;
                validationReport = '';
                if (strcmp(validationParams.onRunTimeError,'rethrowExceptionAndAbort'))
                    abortValidationSession = true;
                    break;
                end
            else
                % Extract the value of the variables 'validationReport' in the MATLAB's base workspace and capture them in the corresponding local variable 'validationReport'
                validationReport                 = evalin('base', 'validationReport');
                validationFailedFlag             = evalin('base', 'validationFailedFlag');
                validationFundamentalFailureFlag = evalin('base', 'validationFundamentalFailureFlag');
                validationData                   = evalin('base', 'validationData');
                extraData                        = evalin('base', 'extraData');
            end
        else
            if (exceptionRaisedFlag)
                validationFailedFlag             = validationReport{1}{2};
                validationFundamentalFailureFlag = validationReport{1}{3};
            end
        end
        
        
        if (obj.validationParams.verbosity > 0) 
            % Update the command line output
            if (validationFailedFlag)
                if (validationFundamentalFailureFlag)
                    fprintf(2, '\tInternal validation  : FUNDAMENTAL FAILURE !!\n');
                else
                    fprintf(2, '\tInternal validation  : FAILED\n');
                end
            else
               fprintf('\tInternal validation  : PASSED\n'); 
            end
            
            if (exceptionRaisedFlag)
               fprintf(2, '\tRun-time status      : exception raised\n');
            else
               fprintf('\tRun-time status      : no exception raised\n'); 
            end
        end
        
        
        if (~strcmp(validationParams.type, 'RUNTIME_ERRORS_ONLY')) 
            if ( (strcmp(validationParams.type, 'FAST'))  && (~validationFailedFlag) && (~exceptionRaisedFlag) )
                % 'FAST' mode validation
                doFastValidation(obj, fastLocalGroundTruthHistoryDataFile, fastLocalValidationHistoryDataFile, validationParams, validationData);
            end
        
            if ( (strcmp(validationParams.type, 'FULL')) && (~validationFailedFlag) && (~exceptionRaisedFlag) )
                % 'FULL' mode validation
                doFullValidation(obj, fullLocalGroundTruthHistoryDataFile, fullLocalValidationHistoryDataFile, validationParams, validationData, extraData);
            end
            
            if ( (strcmp(validationParams.type, 'PUBLISH')) && (~validationFailedFlag) && (~exceptionRaisedFlag) )
                % 'FULL' mode validation
                doFullValidation(obj, fullLocalGroundTruthHistoryDataFile, fullLocalValidationHistoryDataFile, validationParams, validationData, extraData); 
                
                % Construct sectionData for github wiki
                sectionName = functionSubDirectory;
                % update sectionData map
                s = {};
                if (isKey(obj.sectionData,sectionName ))
                    s = obj.sectionData(sectionName);
                    s{numel(s)+1} = scriptName;
                else
                    s{1} = scriptName; 
                end
                obj.sectionData(sectionName) = s;
                
                if (obj.validationParams.verbosity > 1) 
                    fprintf('\tReport published in  : ''%s''\n', htmlDirectory);
                end
            end    
        end  % validationParams.type != 'RUNTIME_ERRORS_ONLY'      
        
        
        if (obj.validationParams.verbosity > 1) && (~strcmp(validationParams.type, 'RUNTIME_ERRORS_ONLY'))
            UnitTest.printValidationReport(validationReport); 
        end
        
        % Make sure figs are rendered at the conclusion of the script validation
        drawnow;
        pause(0.01);
        
    end % scriptIndex
    
    % Close any remaining non-data mismatch figures
    if (~isempty(scriptRunParams)) && (isfield(scriptRunParams, 'closeFigsOnInit'))
        closeFigsOnExit = scriptRunParams.closeFigsOnInit;
    else
        closeFigsOnExit = getpref('isetbioValidation', 'closeFigsOnInit');
    end

    if (closeFigsOnExit)
       UnitTest.closeAllNonDataMismatchFigures(); 
    end
end



function doFastValidation(obj, fastLocalGroundTruthHistoryDataFile, fastLocalValidationHistoryDataFile, validationParams, validationData)

    groundTruthFastValidationFailed = false;
    
    if (~isfield(validationData, 'hashData'))
        if (obj.validationParams.verbosity > 1) 
            fprintf('\tNote (*)             : script does not store any validation data.\n');
        end
        validationData.hashData = struct();
    end
    
    
    
    % Generate SHA256 hash from the validationData.hashData
    % substruct, which is a truncated copy of the data to 12-decimal digits
    hashSHA25 = obj.generateSHA256Hash(validationData.hashData);

    % Load and check value stored in LocalGroundTruthHistoryDataFile 
    dataFileName = fastLocalGroundTruthHistoryDataFile;
    forceUpdateGroundTruth = false;
            
    if (exist(dataFileName, 'file') == 2)
        [groundTruthValidationData, ~, groundTruthTime, hostInfo] = obj.importGroundTruthData(dataFileName);
        if (obj.validationParams.verbosity > 3)
           fprintf('\tGround truth  file   : %s\n', dataFileName); 
        end
        if (strcmp(groundTruthValidationData, hashSHA25))
            if (obj.validationParams.verbosity > 0) 
                fprintf('\tFast validation      : PASSED against ground truth data of %s.\n', groundTruthTime);
                if (obj.validationParams.verbosity > 2) 
                    fprintf('\t > Ground truth info : %30s / %s, MATLAB %s by ''%s''\n', hostInfo.computerAddress, hostInfo.computer, hostInfo.matlabVersion, hostInfo.userName);
                    fprintf('\t > Local host info   : %30s / %s, MATLAB %s by ''%s''\n', obj.hostInfo.computerAddress, obj.hostInfo.computer, obj.hostInfo.matlabVersion, obj.hostInfo.userName);
                end
            end
            if (obj.validationParams.verbosity > 2) 
                fprintf('\tData hash key        : %s\n', hashSHA25);
            end

            groundTruthFastValidationFailed = false;
        else
            if (obj.validationParams.verbosity > 0) 
                fprintf(2,'\tFast validation      : FAILED against ground truth data of %s.\n', groundTruthTime);
                if (obj.validationParams.verbosity > 2) 
                    fprintf(2,'\t > Ground truth info : %30s / %s, MATLAB %s by ''%s''\n', hostInfo.computerAddress, hostInfo.computer, hostInfo.matlabVersion, hostInfo.userName);
                    fprintf(2,'\t > Local host info   : %30s / %s, MATLAB %s by ''%s''\n', obj.hostInfo.computerAddress, obj.hostInfo.computer, obj.hostInfo.matlabVersion, obj.hostInfo.userName);
                end
                fprintf(2,'\tDataHash-this run    : %s\n', hashSHA25);
                fprintf(2,'\tDataHash-groundTruth : %s\n', groundTruthValidationData);
            end
            groundTruthFastValidationFailed = true;
        end
    else
        forceUpdateGroundTruth = true;
        if (obj.validationParams.verbosity > 1) 
            fprintf('\tFast validation      : no ground truth dataset exists. Generating one. \n');
        end
    end
           

    if (~groundTruthFastValidationFailed)
        if (validationParams.updateValidationHistory)
            % save/append to LocalValidationHistoryDataFile
            dataFileName = fastLocalValidationHistoryDataFile;
            if (exist(dataFileName, 'file') == 2)
                if (obj.validationParams.verbosity > 1) 
                    fprintf('\tSHA-256 hash key     : %s, appended to ''%s''\n', hashSHA25, dataFileName);
                end
            else
                if (obj.validationParams.verbosity > 1) 
                    fprintf('\tSHA-256 hash key     : %s, written to ''%s''\n', hashSHA25, dataFileName);
                end
            end
            obj.exportData(dataFileName, hashSHA25, struct());
        end

        % save/append to LocalGroundTruthHistoryDataFile 
        if (validationParams.updateGroundTruth) || (forceUpdateGroundTruth)
            dataFileName = fastLocalGroundTruthHistoryDataFile;
            if (exist(dataFileName, 'file') == 2)
                if (obj.validationParams.verbosity > 1) 
                    fprintf('\tSHA-256 hash key     : %s, appended to ''%s''\n', hashSHA25, dataFileName);
                end
            else
                if (obj.validationParams.verbosity > 1) 
                    fprintf('\tSHA-256 hash key     : %s, written to ''%s''\n', hashSHA25, dataFileName);
                end
            end
            obj.exportData(dataFileName, hashSHA25, struct());
        end
    end % (~groundTruthFastValidationFailed)  
                
end


function doFullValidation(obj, fullLocalGroundTruthHistoryDataFile, fullLocalValidationHistoryDataFile, validationParams, validationData, extraData)

    groundTruthFullValidationFailed = false;
    
    % Load and check value stored in LocalGroundTruthHistoryDataFile 
    dataFileName = fullLocalGroundTruthHistoryDataFile;
    forceUpdateGroundTruth = false;

    if (isempty(fieldnames(validationData)))
        if (obj.validationParams.verbosity > 1) 
            fprintf('\tNote (*)             : script does not store any validation data.\n');
        end
    end

    % hashData not needed for FULL validation, so remove it so we do not compare its data
    if (isfield(validationData, 'hashData'))
        validationData = rmfield(validationData, 'hashData');
    end
                
    if (exist(dataFileName, 'file') == 2)
        [groundTruthValidationData, groundTruthExtraData, groundTruthTime, hostInfo] = obj.importGroundTruthData(dataFileName);
        if (obj.validationParams.verbosity > 3)
           fprintf('\tGround truth  file   : %s\n', dataFileName); 
        end
        % Compare validation data
        [structsAreSimilarWithinSpecifiedTolerance, mismatchReport] = ...
            obj.structsAreSimilar(groundTruthValidationData, validationData);

        if (structsAreSimilarWithinSpecifiedTolerance)
            if (obj.validationParams.verbosity > 0) 
                fprintf('\tFull validation      : PASSED against ground truth data of %s.\n', groundTruthTime);
                if (obj.validationParams.verbosity > 2) 
                    fprintf('\t > Ground truth info : %30s / %s, MATLAB %s by ''%s''\n', hostInfo.computerAddress, hostInfo.computer, hostInfo.matlabVersion, hostInfo.userName);
                    fprintf('\t > Local host info   : %30s / %s, MATLAB %s by ''%s''\n', obj.hostInfo.computerAddress, obj.hostInfo.computer, obj.hostInfo.matlabVersion, obj.hostInfo.userName);
                end
            end
            groundTruthFullValidationFailed = false;
        else
            if (obj.validationParams.verbosity > 0) 
                fprintf(2,'\tFull validation      : FAILED against ground truth data of %s.\n', groundTruthTime);
                if (obj.validationParams.verbosity > 2) 
                    fprintf(2,'\t > Ground truth info : %-30s / %s, MATLAB %s by ''%s''\n', hostInfo.computerAddress, hostInfo.computer, hostInfo.matlabVersion, hostInfo.userName);
                    fprintf(2,'\t > Local host info   : %-30s / %s, MATLAB %s by ''%s''\n', obj.hostInfo.computerAddress, obj.hostInfo.computer, obj.hostInfo.matlabVersion, obj.hostInfo.userName);
                end
            end
            groundTruthFullValidationFailed = true;

            % print info about mismatched fields
            if (obj.validationParams.verbosity > 0) 
                for k = 1:numel(mismatchReport)
                    fprintf(2,'\t[data mismatch %2d]   : %s\n ', k, char(mismatchReport{k}));
                end
            end
        end

        % extra data
        if (obj.validationParams.verbosity > 3) 
            if (isempty(fieldnames(extraData)))
                fprintf('\tNote (*)             : script does not store any extra data.\n');
            end

            % Do not check extra data here
            if (1==2)
                [structsAreSimilarWithinSpecifiedTolerance, mismatchReport] = ...
                    obj.structsAreSimilar(groundTruthExtraData, extraData);

                if (structsAreSimilarWithinSpecifiedTolerance) 
                    fprintf('\tExtra data           : MATCH with extra data of %s.\n', groundTruthTime);
                else
                    fprintf('\tExtra data           : NO MATCH with extra data of %s.\n', groundTruthTime);
                    % print info about mismatched fields
                    for k = 1:numel(mismatchReport)
                        fprintf('\t[extra data mismatch]: %s\n ', char(mismatchReport{k}));
                    end
                end
            end
            
        end

    else
        forceUpdateGroundTruth = true;
        if (obj.validationParams.verbosity > 0) 
            fprintf('\tFull validation      : no ground truth dataset exists. Generating one. \n');
        end

        if (obj.validationParams.verbosity > 3) 
            if (isempty(fieldnames(extraData)))
                fprintf('\tNote (*)             : script does not store any extra data.\n');
            end
        end
    end

    if (~groundTruthFullValidationFailed) 
         if (validationParams.updateValidationHistory)
            % save/append to LocalValidationHistoryDataFile
            dataFileName = fullLocalValidationHistoryDataFile;
            if (exist(dataFileName, 'file') == 2)
                if (obj.validationParams.verbosity > 1) 
                    fprintf('\tFull validation data : appended to ''%s''\n', dataFileName);
                end
            else
                if (obj.validationParams.verbosity > 1) 
                    fprintf('\tFull validation data : written to ''%s''\n', dataFileName);
                end
            end
            obj.exportData(dataFileName, validationData, extraData);
         end

        % save/append to LocalGroundTruthHistoryDataFile
        if (validationParams.updateGroundTruth) || (forceUpdateGroundTruth)
            dataFileName = fullLocalGroundTruthHistoryDataFile;
            if (exist(dataFileName, 'file') == 2)
                if (obj.validationParams.verbosity > 1) 
                    fprintf('\tFull validation data : appended to ''%s''\n', dataFileName);
                end
            else
                if (obj.validationParams.verbosity > 1) 
                    fprintf('\tFull validation data : written to ''%s''\n', dataFileName);
                end
            end
            obj.exportData(dataFileName, validationData, extraData);
        end
    end % (~groundTruthFullValidationFailed)        
end



