function validateDemo
    clc
    
    
    vScriptsList = {...
        'validateSceneReIllumination',          struct('generatePlots', true, 'printValidationReport', true); ...
        'validateSceneReIlluminationAndFail',   []; ...
   };
    
    
    fprintf('Running in  excemption catch and continue mode\n');
    validate('scriptsList', vScriptsList, ...
             'type', 'fast', ...
             'onError', 'catchExcemptionAndContinue');
     
         
         
    fprintf('\nHit enter to continue with publish mode\n');   
    pause;
         
    fprintf('Running in excemption raise and abort mode \n');
    validate('scriptsList', vScriptsList, ...
             'type', 'publish', ...
             'onError', 'catchExcemptionAndContinue');
      
         
    
    fprintf('\nHit enter to continue with excemption raise and abort mode\n');   
    pause;
         
    fprintf('Running in excemption raise and abort mode \n');
    validate('scriptsList', vScriptsList, ...
             'type', 'fast', ...
             'onError', 'rethrowExcemptionAndAbort');
         
         
         
%     validate('scriptsList', vScriptsList, ...
%              'type', 'full');
%          
%     validate('scriptsList', vScriptsList, ...
%              'type', 'publish')

end

function validate(varargin)

    validationParams = parseInput(varargin{:});
    
    for scriptIndex = 1:size(validationParams.scriptsList,1)
        
        % script name
        validationScriptName = validationParams.scriptsList{scriptIndex,1};
        
        % Make sure script exists in the path
        if (exist(validationScriptName, 'file') == 2)
            % File in path. We're good to go
            [functionDirectory, ~, ~] = fileparts(which(sprintf('%s.m',validationScriptName)));
            htmlDirectory = sprintf('%s/%s_HTML', functionDirectory,validationScriptName)
        else
            error('File ''%s'' not found in Matlab''s path.', validationScriptName);
        end
    
        
        % script run params
        scriptRunParams = validationParams.scriptsList{scriptIndex,2}
        
        % Initialize flags and reports, data
        validationReport        = '';
        validationFailedFlag    = true;
        excemptionRaisedFlag    = true;
        validationData          = [];
        
        if strcmp(validationParams.type, 'fast')
            % Run script the regular way
            commandString = sprintf(' [validationReport, validationFailedFlag, validationData] = %s(scriptRunParams);', validationScriptName);
        elseif strcmp(validationParams.type, 'publish')
            % Critical: Assign the params variable to the base workstation
            assignin('base', 'scriptRunParams', scriptRunParams);
            % Form publish options struct
            command = sprintf('%s(scriptRunParams);', validationScriptName);
            options = struct(...
                'codeToEvaluate', ['params;', char(10), sprintf('%s',command), char(10)'], ...
                'evalCode',     true, ...
                'showCode',     true, ...
                'catchError',   strcmp(validationParams.onError,'catchExcemptionAndContinue'), ...
                'outputDir',    htmlDirectory ...
            );
            % Run script via MATLAB's publish method
            commandString = sprintf(' publish(''%s'', options);', validationScriptName);
        end
        
        % Form the try-catch command 
        if (strcmp(validationParams.onError, 'catchExcemptionAndContinue'))
            command = sprintf('try \n\t%s \n\t excemptionRaisedFlag = false;  \ncatch err \n\t excemptionRaisedFlag = true; validationReport = ''FAILED''; \nend', commandString);
        elseif (strcmp(validationParams.onError, 'rethrowExcemptionAndAbort'))
            command = sprintf('try \n\t%s  \n\t  excemptionRaisedFlag = false; \ncatch err \n\t excemptionRaisedFlag = true; validationReport = ''FAILED''; \n\t rethrow(err); \nend', commandString);
        else
            error('''onErrorReaction'':%s is an invalid mode. Choose either ''catchExcemptionAndContinue'' or ''rethrowExcemptionAndAbort''.', validationParams.onError);
        end
        
        % Run the try-catch command
        eval(command);
    
        fprintf('Results for script ''%s''.\n', validationScriptName);
        fprintf('validationReport       = %s\n', validationReport);
        fprintf('validationFailedFlag   = %g\n', validationFailedFlag);
        fprintf('excemptionRaisedFlag   = %g\n', excemptionRaisedFlag);
        
    end % scriptIndex
    
end

function validationParams = parseInput(varargin)
    validationParams.scriptsList    = {};
    validationParams.type           = 'fast';
    validationParams.onError        = 'rethrowExcemptionAndAbort';
    
    % parse inputs
    parser = inputParser;
    parser.addParamValue('scriptsList', validationParams.scriptsList);
    parser.addParamValue('type',        validationParams.type);
    parser.addParamValue('onError',     validationParams.onError);
    
    % Execute the parser to make sure input is good
    parser.parse(varargin{:});
    % Copy the parse parameters to the ExperimentController object
    pNames = fieldnames(parser.Results);
    for k = 1:length(pNames)
       validationParams.(pNames{k}) = parser.Results.(pNames{k}); 
    end
end

