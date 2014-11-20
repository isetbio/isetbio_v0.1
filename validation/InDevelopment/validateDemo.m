function validateDemo
    clc
    
    % List of scripts to validate. Each entry contains a cell array with a
    % script name and an optional params struct.
    vScriptsList = {...
        {'validateSceneReIllumination'} ...                                 % use default params
        {'validateSceneReIllumination', struct('generatePlots', true)} ...     % specify some params
        {'validateSceneReIlluminationAndFail'} ...                                                                                          % use default params
    };
    
     

    validate('scriptsList',     vScriptsList, ...
             'type',            'FAST', ...
             'onRunTimeError',  'catchExemptionAndContinue', ...
             'updateGroundTruth', true);
         
         
    fprintf('\n\nHit enter to continue with ''FULL'' mode\n');   
    pause;
    validate('scriptsList',     vScriptsList, ...
             'type',            'FULL', ...
             'onRunTimeError',  'catchExemptionAndContinue');
         
         
             
    fprintf('\n\nHit enter to continue with ''PUBLISH'' mode\n');   
    pause;  
    % In publish mode we want to abort if an exemption is raised
    validate('scriptsList',     vScriptsList, ...
             'type',            'PUBLISH', ...
             'onRunTimeError',  'rethrowExemptionAndAbort');
         
         
         
    fprintf('\n\nHit enter to continue with exemption raise and abort mode\n');   
    pause;  
    validate('scriptsList',     vScriptsList, ...
             'type',            'FAST', ...
             'onRunTimeError',  'rethrowExemptionAndAbort');
         
         
end

% Main validation engine
function validate(varargin)

    % parse the input params to make sure they are valid
    validationParams = parseInput(varargin{:});
    
    if (~strcmp(validationParams.onRunTimeError, 'catchExemptionAndContinue')) && (~strcmp(validationParams.onRunTimeError, 'rethrowExemptionAndAbort'))
        error('''onRunTimeError'':%s is an invalid mode. Choose either ''catchExemptionAndContinue'' or ''rethrowExemptionAndAbort''.', validationParams.onError);
    end
    fprintf('\n----------------------------------------------------------------------------------\n');
    fprintf('Running in ''%s'' validation mode with ''%s'' runtime hehavior.', validationParams.type, validationParams.onRunTimeError);
    fprintf('\n----------------------------------------------------------------------------------\n');
    
    % Go through each entry
    for scriptIndex = 1:numel(validationParams.scriptsList) 
        scriptListEntry = validationParams.scriptsList{scriptIndex};
        
        % scriptName
        scriptName = scriptListEntry{1};
        urlToScript =  sprintf('<a href="matlab: matlab.desktop.editor.openAndGoToFunction(which(''%s.m''),'''')">''%s.m''</a>', scriptName, scriptName);
        fprintf('\n[%3d] %s\n ', scriptIndex, urlToScript);
        
        % scripRunParams
        if (numel(scriptListEntry) == 2)
            scriptRunParams = scriptListEntry{2};
        else
            scriptRunParams = struct();
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
        exemptionRaisedFlag    = true;
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
    
        if strcmp(validationParams.type, 'publish')
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
            hashSHA25 = GenerateSHA256Hash(validationData);
            
            % Load and check value stored in LocalGroundTruthHistoryDataFile 
            dataFileName = fastLocalGroundTruthHistoryDataFile;
            forceUpdateGroundTruth = false;
            
            if (exist(dataFileName, 'file') == 2)
                [groundTruthData, groundTruthTime] = ImportGroundTruthData(dataFileName);
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
                ExportData(dataFileName, hashSHA25);

                % save/append to LocalGroundTruthHistoryDataFile 
                if (validationParams.updateGroundTruth) || (forceUpdateGroundTruth)
                    dataFileName = fastLocalGroundTruthHistoryDataFile;
                    if (exist(dataFileName, 'file') == 2)
                        fprintf('\tSHA-256 hash key     : %s, appended to ''%s''\n', hashSHA25, dataFileName);
                    else
                        fprintf('\tSHA-256 hash key     : %s, written to ''%s''\n', hashSHA25, dataFileName);
                    end
                    ExportData(dataFileName, hashSHA25);
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
                [groundTruthData, groundTruthTime] = ImportGroundTruthData(dataFileName);
                if (StructsAreSimilar(groundTruthData, validationData))
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
                ExportData(dataFileName, validationData);

                % save/append to LocalGroundTruthHistoryDataFile
                if (validationParams.updateGroundTruth) || (forceUpdateGroundTruth)
                    dataFileName = fullLocalGroundTruthHistoryDataFile;
                    if (exist(dataFileName, 'file') == 2)
                        fprintf('\tFull validation data : appended to ''%s''\n', dataFileName);
                    else
                        fprintf('\tFull validation data : written to ''%s''\n', dataFileName);
                    end
                    ExportData(dataFileName, validationData);

                end
            end
            
        end
        
        
        fprintf('\tValidation report    : ''%s''\n', validationReport);
        
    end % scriptIndex
    
end

function result = StructsAreSimilar(groundTruthData, validationData)
        disp('Need to implement ''StructsAreSimilar(groundTruthData, validationData)'' ');
        result = true;
end


function [validationData, validationTime] = ImportGroundTruthData(dataFileName)
    % create a MAT-file object for read access
    matOBJ = matfile(dataFileName);
    
    % get current variables
    varList = who(matOBJ);
    
    % get latest validation data entry
    validationDataParamName = sprintf('run%05d', length(varList));
    eval(sprintf('runData = matOBJ.%s;', validationDataParamName));
    
    % return the validationData and time
    validationData = runData.validationData;
    validationTime = runData.validationTime;
end


function ExportData(dataFileName, validationData)
    runData.validationData = validationData;
    runData.validationTime = datestr(now);
    
    % create a MAT-file object for write access
    matOBJ = matfile(dataFileName, 'Writable', true);
    
    % get current variables
    varList = who(matOBJ);
    
    % add new variable with new validation data
    validationDataParamName = sprintf('run%05d', length(varList)+1);
    eval(sprintf('matOBJ.%s = runData;', validationDataParamName));     
end



function validationParams = parseInput(varargin)

    % default params
    validationParams.scriptsList        = {};
    validationParams.type               = 'fast';
    validationParams.onRunTimeError     = 'rethrowExemptionAndAbort';
    validationParams.updateGroundTruth  = false;
    
    % parse inputs
    parser = inputParser;
    parser.addParamValue('scriptsList',         validationParams.scriptsList);
    parser.addParamValue('type',                validationParams.type);
    parser.addParamValue('onRunTimeError',      validationParams.onRunTimeError);
    parser.addParamValue('updateGroundTruth',   validationParams.updateGroundTruth);
    
    % Execute the parser to make sure input is good
    parser.parse(varargin{:});
    % Copy the parse parameters to the ExperimentController object
    pNames = fieldnames(parser.Results);
    for k = 1:length(pNames)
       validationParams.(pNames{k}) = parser.Results.(pNames{k}); 
    end
end

function hashSHA25 = GenerateSHA256Hash(validationData)

    Opt.Method = 'SHA-256';
    Opt.Input = 'array';
    hashSHA25 = DataHash(validationData, Opt);
end
