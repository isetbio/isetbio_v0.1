% Method to export a validation entry to a validation file
function exportData(obj, dataFileName, validationData, extraData)
    runData.validationData        = validationData;
    runData.extraData             = extraData;
    runData.validationTime        = datestr(now);
    runData.hostInfo              = obj.hostInfo;
    
    if (obj.useMatfile)
        % create a MAT-file object for write access
        matOBJ = matfile(dataFileName, 'Writable', true);

        % get current variables
        varList = who(matOBJ);

        % add new variable with new validation data
        validationDataParamName = sprintf('run%05d', length(varList)+1);
        eval(sprintf('matOBJ.%s = runData;', validationDataParamName));
    else
        if (exist(dataFileName, 'file'))
            varList = who('-file', dataFileName);
        else
            varList = [];
        end
        validationDataParamName = sprintf('run%05d', length(varList)+1);
        eval(sprintf('%s = runData;', validationDataParamName));
        if (length(varList) == 0)
            eval(sprintf('save(''%s'', ''%s'');',dataFileName, validationDataParamName));
        else
            eval(sprintf('save(''%s'', ''%s'', ''-append'');',dataFileName, validationDataParamName));
            %save(dataFileName, validationDataParamName, '-append');
        end
    end
    
    if (obj.validationParams.verbosity > 3) 
        if (length(varList)+1 == 1)
            fprintf('\tFull validation file : now contains %d instance of historical data.\n', length(varList)+1);
        else
            fprintf('\tFull validation file : now contains %d instances of historical data.\n', length(varList)+1);
        end
    end

end