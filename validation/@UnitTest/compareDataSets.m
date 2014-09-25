% Method to compare the structs: obj.currentValidationRunDataSet and obj.groundTruthDataSet
function [diffs, criticalDiffs] = compareDataSets(obj)

    % Initialize diffs
    diffs = [];
    criticalDiffs = [];
     
    % Get field names
    currentRunFieldNames = fieldnames(obj.currentValidationRunDataSet);
    
    % First compare general run info (all fields except for probeData, sectionData)
    for fIndex = 1:numel(currentRunFieldNames)
       % get field name
       fieldName = currentRunFieldNames{fIndex};
       % Do not compare these fields
       if (strcmp(fieldName, 'probeData')) || (strcmp(fieldName, 'sectionData')) || (strcmp(fieldName, 'date'))
           continue;
       end
       
       % check if this field's value agrees with that of the corresponding
       % field in the groundTruthDataSet
       if (isfield(obj.groundTruthDataSet, fieldName))
           currentRunValue  = getfield(obj.currentValidationRunDataSet, fieldName);
           groundTruthValue = getfield(obj.groundTruthDataSet, fieldName);
           if ischar(currentRunValue)
               quotedFieldName = sprintf('''%s''', fieldName);
               if ~strcmp(currentRunValue, groundTruthValue)
                   mismatchesNum = numel(diffs) + 1;
                   if strcmp(fieldName, 'executiveScriptListing')
                       diffs{mismatchesNum} = sprintf('Variable %s is different in Ground Truth Data Set. Code not shown.', quotedFieldName);
                   else
                       diffs{mismatchesNum} = sprintf('Variable %s = ''%s'' vs. ''%s'' in Ground Truth Data Set.', quotedFieldName, currentRunValue, groundTruthValue);
                   end
               end
           else
               fprintf('Variable %30s is not a string. Need to implement code for handling this. \n', quotedFieldName);
           end
       else
           mismatchesNum = numel(diffs) + 1;
           diffs{mismatchesNum} = sprintf('Variable %s does not exist in the ground truth data set.', quotedFieldName);
       end    
    end
   
    % Now compare probeData
    currentRunProbesNum     = numel(obj.currentValidationRunDataSet.probeData);
    groundTruthProbesNum    = numel(obj.groundTruthDataSet.probeData);
   
    % Get all the probe names in the groundTruth data set
    for qIndex = 1:groundTruthProbesNum
        groundTruthProbeNames{qIndex} = obj.groundTruthDataSet.probeData{qIndex}.name;
    end
    
    % Examine each probe in the current validation run
    for pIndex = 1:currentRunProbesNum
        
        % Get the probe name
        currentProbeName = obj.currentValidationRunDataSet.probeData{pIndex}.name;
        
        % Check if this probe exists in the ground truth data set
        correspondingProbeIndexInGroundTruthDataSet = find(strcmp(groundTruthProbeNames,currentProbeName));
        if (isempty(correspondingProbeIndexInGroundTruthDataSet))
            mismatchesNum = numel(diffs) + 1;
            diffs{mismatchesNum} = sprintf('A probe named ''%s'' does not exist in the ground truth data set.\n', currentProbeName);
            continue
        end
        
        % OK, a probe with the same name exists in the ground truth data set.
        currentProbe = obj.currentValidationRunDataSet.probeData{pIndex};
        groundTruthProbe = obj.groundTruthDataSet.probeData{correspondingProbeIndexInGroundTruthDataSet};
  
        % Check whether the names of the called validation functions  match
        if (~strcmp(currentProbe.functionName, groundTruthProbe.functionName))
            % Critical difference: calling different validation functions. 
            mismatchesNum = numel(criticalDiffs) + 1;
            criticalDiffs{mismatchesNum} = sprintf('Probe ''%s'':\n\t\tThe validation function called by the current probe (''%s.m'') is different than the function called by the ground truth probe (''%s.m'').\n', currentProbeName, currentProbe.functionName, groundTruthProbe.functionName);
        end
        
        % Check whether the input params to the validation functions match
        result = UnitTest.compareStructs('currentProbe.functionParams', currentProbe.functionParams, ...
                                         'groundTruthProbe.functionParams', groundTruthProbe.functionParams, ...
                                          currentProbeName, obj.numericTolerance);
        
        if ~isempty(result)
            % Critical difference: validation functions called with different input params
            for k = 1:numel(result)
                mismatchesNum = numel(criticalDiffs) + 1;
                criticalDiffs{mismatchesNum} = sprintf('%s', result{k});
            end
        end
        
        % Now on to currentProbe.result vs. groundTruthProbe.result
        % This contains the following fields:
        % currentProbe.result.validationReport:      a string, e.g., 'Validation PASSED. PTB and isetbio agree about irradiance to 1.00000 %'
        % currentProbe.result.validationData:        a [1x1 struct] - saved data
        % currentProbe.result.validationFailedFlag:  a boolean, e.g. true or false
        % currentProbe.result.excemptionRaised:      a boolean, e.g. true or false

        % Check whether the validationReports match
        if (~strcmp(currentProbe.result.validationReport, groundTruthProbe.result.validationReport))
            mismatchesNum = numel(diffs) + 1;
            diffs{mismatchesNum} = sprintf('Probe ''%s'':\n\t\t''currentProbe.result.validationReport'' and ''groundTruthProbe.result.validationReport'' are different:\n\t\t''%s'' \n\t\t   vs. \n\t\t''%s''\n', currentProbeName, currentProbe.result.validationReport, groundTruthProbe.result.validationReport);
        end
        
        % Check whether the validationFailedFlags match
        if (currentProbe.result.validationFailedFlag ~= groundTruthProbe.result.validationFailedFlag)
            mismatchesNum = numel(criticalDiffs) + 1;
            criticalDiffs{mismatchesNum} = sprintf('Probe ''%s'':\n\t\t''currentProbe.result.validationFailedFlag'' = %d whereas ''groundTruthProbe.result.validationFailedFlag'' = %d.\n', currentProbeName, currentProbe.result.validationFailedFlag, groundTruthProbe.result.validationFailedFlag);
        end
        
         % Check whether the excemptionRaisedFlags match
        if (currentProbe.result.excemptionRaised ~= groundTruthProbe.result.excemptionRaised)
            mismatchesNum = numel(criticalDiffs) + 1;
            criticalDiffs{mismatchesNum} = sprintf('Probe ''%s'':\n\t\t''currentProbe.result.excemptionRaised'' = %d whereas ''groundTruthProbe.result.excemptionRaised'' = %d.\n', currentProbeName, currentProbe.result.excemptionRaised, groundTruthProbe.result.excemptionRaised);
        end
        
        
        % Finally, check whether the saved validation data match
        result = UnitTest.compareStructs('currentProbe.result.validationData', currentProbe.result.validationData, ...
                                         'groundTruthProbe.result.validationData', groundTruthProbe.result.validationData, ...
                                          currentProbeName, obj.numericTolerance);
        
        if ~isempty(result)
            % Critical difference: validation functions called with different input params
            for k = 1:numel(result)
                mismatchesNum = numel(criticalDiffs) + 1;
                criticalDiffs{mismatchesNum} = sprintf('%s', result{k});
            end
        end
        
    end % pIndex
    

    
end

