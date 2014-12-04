% Main validation engine
function validate(obj, vScriptsToRunList)
    
    fprintf('\n------------------------------------------------------------------------------------------------------------\n');
    fprintf('Running in ''%s'' mode with ''%s'' runtime hehavior (verbosity = ''%s'').', obj.validationParams.type, obj.validationParams.onRunTimeError, UnitTest.validVerbosityLevels{obj.validationParams.verbosity+1});
    
    % Parse the scripts list to ensure it is valid
    obj.vScriptsList = obj.parseScriptsList(vScriptsToRunList);
    
    if (obj.validationParams.verbosity > 1) 
        fprintf('\nWill validate %d scripts.', numel(obj.vScriptsList)); 
    end
    fprintf('\n------------------------------------------------------------------------------------------------------------\n');
    
    % get validation params
    validationParams = obj.validationParams;
    
    %Ensure that needed directories exist, and generates them if they do not
    obj.checkDirectories();
    

    % Go through each entry
    for scriptIndex = 1:numel(obj.vScriptsList) 
        
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
            indices              = strfind(functionDirectory, '/');
            functionSubDirectory = functionDirectory(indices(end)+1:end);
            % Construct path strings
            htmlDirectory                       = sprintf('%s/%s/%s_HTML',                           obj.htmlDir,           functionSubDirectory, scriptName);
            fullLocalValidationHistoryDataFile  = sprintf('%s/%s/%s_FullValidationDataHistory.mat',  obj.validationDataDir, functionSubDirectory, scriptName);
            fastLocalValidationHistoryDataFile  = sprintf('%s/%s/%s_FastValidationDataHistory.mat',  obj.validationDataDir, functionSubDirectory, scriptName);
            fullLocalGroundTruthHistoryDataFile = sprintf('%s/%s/%s_FullGroundTruthDataHistory.mat', obj.validationDataDir, functionSubDirectory, scriptName);
            fastLocalGroundTruthHistoryDataFile = sprintf('%s/%s/%s_FastGroundTruthDataHistory.mat', obj.validationDataDir, functionSubDirectory, scriptName);
        else
            error('A file named ''%s'' does not exist in the path.', scriptName);
        end
   
        
        % Initialize flags, reports, and validation data
        validationReport        = '';
        validationFailedFlag    = true;
        exemptionRaisedFlag     = true;
        validationData          = [];
        
        if strcmp(validationParams.type, 'RUNTIME_ERRORS_ONLY')
            % Run script the regular way
            commandString = sprintf(' [validationReport, validationFailedFlag, validationData] = %s(scriptRunParams);', scriptName);
            
        elseif strcmp(validationParams.type, 'FAST')
            % Create validationData sub directory if it does not exist;
            obj.generateDirectory(obj.validationDataDir, functionSubDirectory);
            % Run script the regular way
            commandString = sprintf(' [validationReport, validationFailedFlag, validationData] = %s(scriptRunParams);', scriptName);
            
        elseif strcmp(validationParams.type, 'FULL')
            % Create validationData sub directory if it does not exist;
            obj.generateDirectory(obj.validationDataDir, functionSubDirectory);
            % Run script the regular way
            commandString = sprintf(' [validationReport, validationFailedFlag, validationData] = %s(scriptRunParams);', scriptName);
            
        elseif strcmp(validationParams.type, 'PUBLISH')
            % Create HTML sub directory if it does not exist;
            obj.generateDirectory(obj.htmlDir, functionSubDirectory)
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
            command = sprintf('try \n\t%s \n\t exemptionRaisedFlag = false;  \ncatch err \n\t exemptionRaisedFlag = true;\n\t validationReport{1} = {sprintf(''Exemption raised (and caught). Exemption Message: %%s'', err.message), true}; \nend', commandString);
        else
            command = sprintf('try \n\t%s  \n\t exemptionRaisedFlag = false; \ncatch err \n\t exemptionRaisedFlag = true;\n\t validationReport{1} = {sprintf(''Exemption raised. Exemption Message: %%s'', err.message), true}; \n\t rethrow(err);  \nend', commandString);
        end
        
        if (obj.validationParams.verbosity > 3)
            fprintf('\nRunning with ');
            eval('scriptRunParams');
        end
        
        if (obj.validationParams.verbosity == 5)
           fprintf('\nExecuting:\n%s\n', command); 
        end
        
        % Run the try-catch command
        eval(command);
    
        if strcmp(validationParams.type, 'PUBLISH')
            % Extract the value of the variables 'validationReport' in the MATLAB's base workspace and captures them in the corresponding local variable 'validationReport'
            validationReport     = evalin('base', 'validationReport');
            validationFailedFlag = evalin('base', 'validationFailedFlag');
            validationData       = evalin('base', 'validationData');
        end
            
        if (obj.validationParams.verbosity > 0) 
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
        end
        
        
        if (~strcmp(validationParams.type, 'RUNTIME_ERRORS_ONLY'))
            
            % Begin validation against ground truth
            groundTruthFastValidationFailed = false;
            groundTruthFullValidationFailed = false;
        
            % 'FAST' mode validation
            if ( (strcmp(validationParams.type, 'FAST'))  && ...
                 (~validationFailedFlag) && (~exemptionRaisedFlag) )

                % Generate SHA256 hash from the validationData.hashData
                % substruct, which is a truncated copy of the data to 12-decimal digits
                hashSHA25 = obj.generateSHA256Hash(validationData.hashData);

                % hashData not needed after hash key-generation, so delete it
                validationData = rmfield(validationData, 'hashData');
                
                % Load and check value stored in LocalGroundTruthHistoryDataFile 
                dataFileName = fastLocalGroundTruthHistoryDataFile;
                forceUpdateGroundTruth = false;

                if (exist(dataFileName, 'file') == 2)
                    [groundTruthData, groundTruthTime] = obj.importGroundTruthData(dataFileName);
                    if (strcmp(groundTruthData, hashSHA25))
                        if (obj.validationParams.verbosity > 0) 
                            fprintf('\tFast validation      : PASSED against ground truth data of %s\n', groundTruthTime);
                        end
                        if (obj.validationParams.verbosity > 2) 
                            fprintf('\tData hash key        : %s\n', hashSHA25);
                        end
                        
                        groundTruthFastValidationFailed = false;
                    else
                        if (obj.validationParams.verbosity > 0) 
                            fprintf(2,'\tFast validation      : FAILED against ground truth data of %s.\n', groundTruthTime);
                            fprintf(2,'\tDataHash-this run    : %s\n', hashSHA25);
                            fprintf(2,'\tDataHash-ground truth: %s\n', groundTruthData);
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
                        obj.exportData(dataFileName, hashSHA25);
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
                        obj.exportData(dataFileName, hashSHA25);
                    end
                    
                end % (~groundTruthFastValidationFailed)  
            end  % FAST validation mode
        

            % 'FULL' mode validation
            if ( (strcmp(validationParams.type, 'FULL'))  && ...
                 (~validationFailedFlag) && (~exemptionRaisedFlag) )

                % Load and check value stored in LocalGroundTruthHistoryDataFile 
                dataFileName = fullLocalGroundTruthHistoryDataFile;
                forceUpdateGroundTruth = false;

                if (exist(dataFileName, 'file') == 2)
                    [groundTruthData, groundTruthTime] = obj.importGroundTruthData(dataFileName);
                    if (obj.structsAreSimilar(groundTruthData, validationData))
                        if (obj.validationParams.verbosity > 0) 
                            fprintf('\tFull validation      : PASSED against ground truth data of %s\n', groundTruthTime);
                        end
                        groundTruthFullValidationFailed = false;
                    else
                        if (obj.validationParams.verbosity > 0) 
                            fprintf(2,'\tFull validation      : FAILED against ground truth data of %s\n', groundTruthTime);
                        end
                        groundTruthFullValidationFailed = true;
                    end
                else
                    forceUpdateGroundTruth = true;
                    if (obj.validationParams.verbosity > 0) 
                        fprintf('\tFull validation      : no ground truth dataset exists. Generating one. \n');
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
                        obj.exportData(dataFileName, validationData);
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
                        obj.exportData(dataFileName, validationData);
                    end
                    
                end % (~groundTruthFullValidationFailed)

            end  % FULL validation mode
            
            
            if (strcmp(validationParams.type, 'PUBLISH'))
                if (obj.validationParams.verbosity > 1) 
                    fprintf('\tReport published in  : ''%s''\n', htmlDirectory);
                end
            end  % PUBLISH MODE
            
        end  % validationParams.type, 'RUNTIME_ERRORS_ONLY'      
        
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



