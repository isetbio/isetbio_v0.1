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
        fprintf('\n-------------------------------------------------------------------\n');
        fprintf(  'Current validation run agrees prefectly with ground truth data set.\n');
        fprintf('\n-------------------------------------------------------------------\n');
        
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
        
        if (obj.pushToGitHubOnSuccessfulValidation)
            % Push results to github
            obj.pushToGitHub();
        end
    else
        if (numel(criticalDiffs) > 0)
            fprintf(  '\n----------------------------------------------------------------------------------------------------\n');
            fprintf('\n\n(A) There are critical differences between the current validation run and the ground truth data set.\n');
            fprintf('\nCritical differences found (%d):\n', numel(criticalDiffs));
            for k = 1:numel(criticalDiffs)
                fprintf(2, '\t[%03d] %s\n', k, char(criticalDiffs{k}));
            end
            fprintf('\nWill not push to github nor update the ground truth data set in the SVN server.\n');
            fprintf(  '\n----------------------------------------------------------------------------------------------------\n');
        else
            fprintf(  '\n-------------------------------------------------------------------------------------------------------\n');
            fprintf('\n\n(A) There are NO critical differences between the current validation run and the ground truth data set.\n');
            fprintf(  '\n-------------------------------------------------------------------------------------------------------\n');
        end
        
        if (numel(diffs) > 0)
            fprintf(  '\n-------------------------------------------------------------------------------------------------------------\n');
            fprintf('\n\n(B) There are some non-critical differences between the current validation run and the ground truth data set.\n');
            fprintf('Non-critical differences found (%d):\n', numel(diffs));
            for k = 1:numel(diffs)
                fprintf('\t[%03d] %s\n', k, char(diffs{k}));
            end
            fprintf(  '\n-------------------------------------------------------------------------------------------------------------\n');
        else
            fprintf(  '\n-----------------------------------------------------------------------------------------------------------\n');
            fprintf('\n\n(B) There are NO non-critical differences between the current validation run and the ground truth data set.\n');
            fprintf(  '\n-----------------------------------------------------------------------------------------------------------\n');
        end
        
        % Query user whether to push to gitHub and to SVN server
        if (numel(criticalDiffs) == 0)
            % Query regarding GroundTruth history update
            if (obj.addResultsToGroundTruthHistory)
                if  (obj.useRemoteGroundTruthDataSet)
                    updateGroundTruthDataSet = input('You have requested to update the *REMOTELY* kept Ground Truth Data Set history. Do you still want to do this despite the non-critical differences found ? (1=YES): ');
                else
                    updateGroundTruthDataSet = input('You have requested to update the *LOCALLY* kept Ground Truth Data Set history. Do you still want to do this despite the non-critical differences found ? (1=YES): ');
                end
                if (~isempty(updateGroundTruthDataSet)) && (updateGroundTruthDataSet == 1)
                    obj.saveValidationResults('Ground truth');
                else
                    fprintf('\n----> Will not update the Ground Truth Data Set history.\n');
                end
            end
            
            % Query regarding Validation history update
            if (obj.addResultsToValidationResultsHistory)
                updateValidationDataSet = input('You have requested to update the *LOCALLY* kept Validation Data Set history. Do you still want to do this despite the non-critical differences found ? (1=YES): ');
                if (~isempty(updateValidationDataSet)) &&  (updateValidationDataSet == 1)
                    obj.saveValidationResults('Validation');
                else
                   fprintf('\n---->  Will not update the Validation Data Set history. \n'); 
                end
            end
            
            % Query regarding git hub update
            if (obj.pushToGitHubOnSuccessfulValidation)
                updateGithub = input('You have requested to update github. Do you still want to do this despite the non-critical differences found ? (1=YES): ');
                if (~isempty(updateGithub)) &&  (updateGithub == 1)
                    obj.pushToGitHub();
                else
                   fprintf('\n---->  Will not push to github. \n');  
                end
            end
        end
    end
end
