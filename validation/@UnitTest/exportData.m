% Method to export a validation entry to a validation file
function exportData(obj, dataFileName, validationData, extraData)
    runData.validationData        = validationData;
    runData.extraData             = extraData;
    runData.validationTime        = datestr(now);
    runData.hostInfo              = obj.hostInfo;
    
    % create a MAT-file object for write access
    matOBJ = matfile(dataFileName, 'Writable', true);
    
    % get current variables
    varList = who(matOBJ);
    
    % add new variable with new validation data
    validationDataParamName = sprintf('run%05d', length(varList)+1);
    eval(sprintf('matOBJ.%s = runData;', validationDataParamName));
    if (obj.validationParams.verbosity > 3) 
        if (length(varList)+1 == 1)
            fprintf('\tFull validation file : now contains %d instant of historical data.\n', length(varList)+1);
        else
            fprintf('\tFull validation file : now contains %d instants of historical data.\n', length(varList)+1);
        end
    end

end