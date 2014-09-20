function validateSkeleton(runParams)
%
% Skeleton script containing the minimally required code. Copy and add your ISETBIO validation code. 
%

    % Call the validation script
    [validationReport, validationFailedFlag, validationDataToSave] = validationScript(runParams);
        
    % Update the parent @UnitTest object
    UnitTest.updateParentUnitTestObject(validationReport, validationFailedFlag, validationDataToSave, runParams);
end

%% Skeleton validation script
function [validationReport, validationFailedFlag, validationDataToSave] = validationScript(runParams)

    %% Initialize return params
    validationReport = 'Nothing to report.'; 
    validationFailedFlag = false; 
    validationDataToSave = struct();
    
    %% Initialize ISETBIO
    s_initISET;
    
    % Your isetbio validation code goes here.  
    
    % Do not forget to update the following params:
    % - validationReport (string),
    % - validationFailedFlag (boolean)
    % - validationDataToSave (struct with fields containing validation data that you want to save for comparison to ground truth data)
    
    % Generate plots, if so specified
    if (nargin >= 1) && (isfield(runParams, 'generatePlots')) && (runParams.generatePlots == true)
        % Your plotting code goes here.
    end
    
end
