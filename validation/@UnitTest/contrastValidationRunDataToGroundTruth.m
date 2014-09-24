function diff = contrastValidationRunDataToGroundTruth(obj)
    % assemble current data into a validation run struct for comparison and
    % storage
    obj.currentValidationRunDataSet = obj.assembleResultsIntoValidationRunStuct();
    
    % Retrieve ground truth data
    obj.groundTruthDataSet = retrieveHistoricalGroundTruthDataToValidateAgaist(obj);
    
    % an empty indicates perfect agreement of currentValidationRunData with ground truth
    diff = nan;
    
    if (isempty(obj.groundTruthDataSet))
        ans = input('Ground truth data set does not exist. Save current run as ground truth [1=yes]? ');
        if (ans == 1)
            obj.saveValidationResults('Ground truth');
            diff = [];
        else
            diff = nan;
        end
    else
        % compare structs now
        diff = obj.compareDataSets();
    end
    
    if isempty(diff) 
        fprintf('Current validation run agrees prefectly with ground truth data.\n');
        
        if (obj.addResultsToValidationResultsHistory) && (obj.addResultsToGroundTruthHistory)
            % Append current validation to both validation and ground truth history files
            obj.saveValidationResults('Both');
        elseif (obj.addResultsToValidationResultsHistory)
            % Save current validation to validation history file only
            obj.saveValidationResults('Validation');
        elseif (obj.addResultsToGroundTruthHistory)
            % Save current validation to ground truth history file only
            obj.saveValidationResults('Ground truth');
        end
        
        % Push results to github, i.e.:  https://github.com/isetbio/isetbio/wiki/ValidationResults
        obj.pushToGitHub(); 
        
    elseif (isnan(diff))
        fprintf(2, 'Current validation run does not agree with ground truth data.\n');
        fprintf(2, 'Will not save data, nor push to github.\n');
    else 
        fprintf('Current validation agrees partially with ground truth data.\n');  
    end
    
end
