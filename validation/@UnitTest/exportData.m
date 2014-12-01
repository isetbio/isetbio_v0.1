% Method to export a validation entry to a validation file
function exportData(obj, dataFileName, validationData)
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