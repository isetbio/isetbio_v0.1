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
    
    %% Isetbio validation code goes here.  
    
    %% Update validation params:
    % - validationReport (string) This should contain a useful message about the result of the script. 
    %
    % - validationFailedFlag (boolean) This should be set to true if the results are not what you expect 
    %   (indicating a failed validation). Otherwise, if everything went OK, set it to false.
    %
    % - validationDataToSave (struct) Use this struct to add data which you  would like to save and
    %    which will be contrasted against a ground truth data set.
    
    %% Generate plots, if so specified
    if (nargin >= 1) && (isfield(runParams, 'generatePlots')) && (runParams.generatePlots == true)
        % Plotting code goes here.
    end
    
end
