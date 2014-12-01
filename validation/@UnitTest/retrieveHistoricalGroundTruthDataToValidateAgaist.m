function groundTruthDataSet = retrieveHistoricalGroundTruthDataToValidateAgaist(obj)

    % ground truth data file
    dataSetFilename = obj.groundTruthDataSetsFileName;
    
    if (obj.useRemoteGroundTruthDataSet)
        dataSetFilename = obj.svnHostedGroundTruthDataSetsFileName();
        obj.issueSVNCheckoutCommand();
    end
    
    % create a MAT-file object that supports partial loading and saving.
    matOBJ = matfile(dataSetFilename, 'Writable', false);
    
    % get current variables
    varList = who(matOBJ);
        
    if isempty(varList)
        if (exist(dataSetFilename, 'file'))
            fprintf(2,'No ground truth data found in ''%s''.\n', dataSetFilename);
        else
            fprintf(2,'''%s'' does not exist.\n', dataSetFilename);
        end
        groundTruthDataSet = [];
        return;        
    end
    
    fprintf('\n\nFound %d ground truth data sets in the saved history.', numel(varList));
    
    if (obj.queryUserIfMoreThanOneGroundTruthDataSetsExist)
        % Display a list of ground truth data set and their dates
        for k = 1:numel(varList)
            eval(sprintf('v = matOBJ.%s;',varList{k}));
            fprintf('\n\t[%3d]. Performed on %s.', k, v.date);
        end
        % ask the user to select one
        defaultDataSetNo = numel(varList);
        dataSetIndex = input(sprintf('\nSelect a data set (1-%d) [%d]: ', defaultDataSetNo, defaultDataSetNo));
        if isempty(dataSetIndex) || (dataSetIndex < 1) || (dataSetIndex > defaultDataSetNo)
            dataSetIndex = defaultDataSetNo;
        end
    else
        dataSetIndex = numel(varList);
    end
    
    % return the selected ground truth data set
    eval(sprintf('groundTruthDataSet = matOBJ.%s;',varList{dataSetIndex}));
    fprintf('Using the ground truth data set from the %s validation run.\n', groundTruthDataSet.date);
end