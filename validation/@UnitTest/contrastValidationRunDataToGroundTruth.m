function [diffs, criticalDiffs]= contrastValidationRunDataToGroundTruth(obj)
    % assemble current data into a validation run struct for comparison and storage
    obj.currentValidationRunDataSet = obj.assembleResultsIntoValidationRunStuct();
    
    % Retrieve ground truth data
    obj.groundTruthDataSet = retrieveHistoricalGroundTruthDataToValidateAgaist(obj);
    
    % empty diffs indicates perfect agreement of currentValidationRunData with ground truth
    diffs = {};
    crificalDiffs = {};
    
    if (isempty(obj.groundTruthDataSet))
        ans = input('Ground truth data set does not exist. Save current run as ground truth [1=yes]? ');
        if (ans == 1)
            obj.saveValidationResults('Ground truth');
        else
            diffs{1} = 'Ground truth data set does not exist.';
        end
    else
        % compare structs now
        [diffs, criticalDiffs] = obj.compareDataSets();
    end
    
    if (isempty(diffs) && isempty(crificalDiffs))
        fprintf('Current validation run agrees prefectly with ground truth data set.\n');
        
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
    else
        if (numel(criticalDiffs) > 0)
            fprintf('\n\n(A) There are critical differences between the current validation run and the ground truth data set.\n');
            fprintf('\nCritical differences found (%d):\n', numel(criticalDiffs));
            for k = 1:numel(criticalDiffs)
                fprintf(2, '\t[%03d] %s\n', k, char(criticalDiffs{k}));
            end
        else
            fprintf('\n\n(A) There are NO critical differences between the current validation run and the ground truth data set.\n');
        end
        
        if (numel(diffs) > 0)
            fprintf('\n\n(B) There are some non-critical differences between the current validation run and the ground truth data set.\n');
            fprintf('Non-critical differences found (%d):\n', numel(diffs));
            for k = 1:numel(diffs)
                fprintf('\t[%03d] %s\n', k, char(diffs{k}));
            end
        else
             fprintf('\n\n(B) There are NO non-critical differences between the current validation run and the ground truth data set.\n');
        end
    end
    
end
