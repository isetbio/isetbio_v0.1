function saveValidationResults(obj, dataType)
    
    if ((strcmp(dataType, 'Validation')) || (strcmp(dataType, 'Both')))
        exportData('Validation');
    end
    
    if ((strcmp(dataType, 'Ground truth')) || (strcmp(dataType, 'Both')))
        exportData('Ground truth');
    end
    
    if  (strcmp(dataType, 'Ground truth - NEW'))
        exportData('Ground truth - NEW');
    end
    
    % Helper function for serializing the data to the disk
    function exportData(validationDataSetType)
        % select data file name
        if (strcmp(validationDataSetType, 'Ground truth') || strcmp(validationDataSetType, 'Ground truth - NEW'))
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
        
        if (obj.addResultsToGroundTruthHistory)
            if (strcmp(validationDataSetType, 'Ground truth'))
                obj.issueSVNCommitCommand(validationDataParamName, false);
            elseif (strcmp(validationDataSetType, 'Ground truth - NEW'))
                obj.issueSVNCommitCommand(validationDataParamName, true);
            end  
        end
    end
end
