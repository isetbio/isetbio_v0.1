% Method ensuring that directories exist, and generates them if they do not
function checkDirectories(obj)

    % Check if HTML directory exists and create it, if it does not exist
    if (strcmp(obj.validationParams.type, 'PUBLISH'))
        if (~exist(obj.htmlDir, 'dir'))
            mkdir(obj.htmlDir); 
        end
        addpath(obj.htmlDir);
    end
    
    % Check if validationData directory exists and create it, if it does not exist
    if ~(strcmp(obj.validationParams.type, 'RUNTIME_ERRORS_ONLY'))
        if (~exist(obj.validationDataDir, 'dir'))
            mkdir(obj.validationDataDir);
        end
        addpath(obj.validationDataDir);
    end
end

    