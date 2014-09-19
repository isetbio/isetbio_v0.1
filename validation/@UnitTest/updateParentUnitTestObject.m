function updateParentUnitTestObject(validationReport, validationFailedFlag, validationDataToSave, runParams)
    %% Book-keeping ops. All validation scripts should contain the following.
    if (isempty(validationReport))
        validationReport = 'None';
    end
    
    if (isempty(validationFailedFlag))
        validationFailedFlag = true;
    end
    
    if (isempty(validationDataToSave))
        validationDataToSave = struct();
    end
        
    % Pass the validation data to the parent @UnitTest object.
    if (nargin >= 1) && isfield(runParams, 'parentUnitTestObject')
        % Get parent @UnitTest object
        parentUnitTestOBJ = runParams.parentUnitTestObject;
        
        % Return validation results to the parent @UnitTest object
        parentUnitTestOBJ.storeValidationResults(...
            'validationReport',     validationReport, ...
            'validationFailedFlag', validationFailedFlag, ...
            'validationData',       validationDataToSave ...
        );
       
        % Set to empty as we returned the validation results to the parent @UnitTest object
        validationResults = [];
        
        % Publish validation results
        parentUnitTestOBJ.printReport();
    else 
        % return validationResults to the user
        validationResults = struct();
        validationResults.validationReport      = validationReport;
        validationResults.validationFailedFlag  = validationFailedFlag;
        validationResults.validationDataToSave  = validationDataToSave;
    end
    
end