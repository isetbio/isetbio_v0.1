% Method to import a ground truth data entry
function [validationData, extraData, validationTime] = importGroundTruthData(obj, dataFileName)
    % create a MAT-file object for read access
    matOBJ = matfile(dataFileName);
    
    % get current variables
    varList = who(matOBJ);
    
    % get latest validation data entry
    validationDataParamName = sprintf('run%05d', length(varList));
    eval(sprintf('runData = matOBJ.%s;', validationDataParamName));
    
    % return the validationData and time
    validationData  = runData.validationData;
    extraData       = runData.extraData;
    validationTime  = runData.validationTime;
end