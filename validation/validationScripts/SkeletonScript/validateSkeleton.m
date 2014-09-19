function validateResults = validateSkeleton(runParams)
%
% Skeleton validation script with the minimal amount of code required. Copy and adapt to your needs. 
%

    % Call the validation script
    [validationReport, validationFailedFlag, validationDataToSave] = validationScript(runParams);
        
    % Update the parent @UnitTest object
    UnitTest.updateParentUnitTestObject(validationReport, validationFailedFlag, validationDataToSave, runParams);
end

%% Validation script for PTB_vs_ISETBIO_Irradiance test
function [validationReport, validationFailedFlag, validationDataToSave] = validationScript(runParams)

    %% Initialize return params
    validationReport = 'None'; 
    validationFailedFlag = true; 
    validationDataToSave = struct();
    
    %% Initialize ISETBIO
    s_initISET;
    
    % Your isetbio computation code goes here.  
    
    % Do not forget to update the following params:
    % - validationReport (string),
    % - validationFailedFlag (boolean)
    % - validationDataToSave (struct with fields containing validation data that you want to save for comparison to ground truth data)
    
    % Generate plots, if so specified
    if (nargin >= 1) && (isfield(runParams, 'generatePlots')) && (runParams.generatePlots == true)
        % Your plotting code goes here.
    end
    
end
