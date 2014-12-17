% Method to import a ground truth data entry
function [validationData, extraData, validationTime, hostInfo] = importGroundTruthData(obj, dataFileName)
    % create a MAT-file object for read access
    matOBJ = matfile(dataFileName);
    
    % get current variables
    varList = who(matOBJ);
    
    if (obj.validationParams.verbosity > 2) 
        if (length(varList) == 1)
            fprintf('\tFull validation file : contains %d instant of historical data.\n', length(varList));
        else
            fprintf('\tFull validation file : contains %d instants of historical data. Retrieving latest one.\n', length(varList));
            matOBJ
            matOBJ.run00001
        end
    end
    
    % get latest validation data entry
    validationDataParamName = sprintf('run%05d', length(varList));
    eval(sprintf('runData = matOBJ.%s;', validationDataParamName));
    
    % return the validationData and time
    hostInfo        = runData.hostInfo;
    validationTime  = runData.validationTime;
    validationData  = runData.validationData;
    extraData       = runData.extraData;
end