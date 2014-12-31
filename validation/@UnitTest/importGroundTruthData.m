% Method to import a ground truth data entry
function [validationData, extraData, validationTime, hostInfo] = importGroundTruthData(obj, dataFileName)
    
    if (obj.useMatfile)
        % create a MAT-file object for read access
        matOBJ = matfile(dataFileName);

        % get current variables
        varList = who(matOBJ);
    else
        varList = who('-file', dataFileName);
    end
    
    if (obj.validationParams.verbosity > 3) 
        if (length(varList) == 1)
            fprintf('\tFull validation file : contains %d instance of historical data.\n', length(varList));
        else
            fprintf('\tFull validation file : contains %d instances of historical data. Retrieving latest one.\n', length(varList));
        end
    end
    
    % get latest validation data entry
    validationDataParamName = sprintf('run%05d', length(varList));
    
    if (obj.useMatfile)
        eval(sprintf('runData = matOBJ.%s;', validationDataParamName));
    else
        eval(sprintf('load(''%s'', ''%s'');',dataFileName, validationDataParamName));
        eval(sprintf('runData = %s;', validationDataParamName));
    end
    % return the validationData and time
    hostInfo        = runData.hostInfo;
    validationTime  = runData.validationTime;
    validationData  = runData.validationData;
    extraData       = runData.extraData;
end