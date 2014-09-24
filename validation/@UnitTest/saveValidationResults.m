function saveValidationResults(obj, dataType)
    
    if ((strcmp(dataType, 'Validation')) || (strcmp(dataType, 'Both')))
        exportData('Validation');
    end
    
    if ((strcmp(dataType, 'Ground truth')) || (strcmp(dataType, 'Both')))
        exportData('Ground truth');
    end
    
    % Helper function for serializing the data to the disk
    function exportData(validationDataSetType)
        % select data file name
        if strcmp(validationDataSetType, 'Ground truth')
            dataSetFilename = obj.groundTruthDataSetsFileName;
        else
            dataSetFilename = obj.validationDataSetsFileName;
        end
        
        % create a MAT-file object that supports partial loading and saving.
        matOBJ = matfile(dataSetFilename, 'Writable', true);
        % get current variables
        varList = who(matOBJ);
        % add new variable with new validation data
        validationDataParamName = sprintf('dataRun_%05d', length(varList)+1);
        eval(sprintf('matOBJ.%s = obj.currentValidationRunDataSet;', validationDataParamName)); 
        fprintf('\nSaved current validation data data to ''%s'' as %s.\n', dataSetFilename, validationDataParamName);
    end
end

function temp(obj)
    obj.addResultsToGroundTruthHistory = true;
    
    % System  data to save
    validationRun.executiveScriptName       = obj.systemData.vScriptFileName;
    validationRun.executiveScriptListing    = obj.systemData.vScriptListing;
    validationRun.date                      = obj.systemData.datePerformed; 
    validationRun.matlabVersion             = obj.systemData.matlabVersion;
    validationRun.computerArchitecture      = obj.systemData.computer; 
    validationRun.computerAddress           = obj.systemData.computerAddress;
    validationRun.gitRepoBranch             = obj.systemData.gitRepoBranch; 
    validationRun.sectionData               = obj.sectionData;

    
    % Individual probe data to save
    for pIndex = 1:numel(obj.allProbeData)
        probeData = obj.allProbeData{pIndex};
        
        if (~probeData.result.validationFailedFlag) && (~probeData.result.excemptionRaised)
            
            validationScriptListing = fileread([probeData.functionName '.m']);
            
            % save everything in probeData which is
            % probeData = 
%                    name: 'validation skeleton'
%     functionSectionName: 'z. Skeleton validation scripts'
%            functionName: 'validateSkeleton'
%          functionParams: [1x1 struct]  % input params to the validation script
%          onErrorReactBy: 'CatchExcemption'
%           publishReport: 1
%           generatePlots: 1
%                  result: [1x1 struct]
%                           .validationReport: 'Nothing to report.'
%                           .validationData: [1x1 struct] with whatever variables were added by the validation script 
%                           .validationFailedFlag: 0
%                           .excemptionRaised: 0
    
            
        else
            % Should we save any information for the failed probes ??
        end
    end
end
