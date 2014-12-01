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
            if (obj.useRemoteGroundTruthDataSet)
                dataSetFilename = obj.svnHostedGroundTruthDataSetsFileName();
            else
                dataSetFilename = obj.groundTruthDataSetsFileName;
            end
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
        
        fprintf('Updated %s with current data (''%s'').\n', dataSetFilename, validationDataParamName);
        
        if (strcmp(validationDataSetType, 'Ground truth') && (obj.addResultsToGroundTruthHistory))
            obj.issueSVNCommitCommand(validationDataParamName);
        end
        
    end
end
