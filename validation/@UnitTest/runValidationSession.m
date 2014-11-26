function runValidationSession(vScriptsList, desiredMode)

    if (nargin == 1)
        fprintf('\nAvailable validation run types:');
        fprintf('\n\t 1. FASTEST (runtime errors only)');
        fprintf('\n\t 2. FAST    (runtime errors + data hash comparison)');
        fprintf('\n\t 3. FULL    (runtime errors + full data comparison)');
        fprintf('\n\t 4. PUBLISH (runtime errors +  github wiki update)');
        typeID = input('\nEnter type of validation run [default = 1]: ', 's');
        if (str2double(typeID) == 1)
            desiredMode = 'RUN_TIME_ERRORS_ONLY';
        elseif (str2double(typeID) == 2)
            desiredMode = 'FAST';
        elseif (str2double(typeID) == 3)
            desiredMode = 'FULL';
        elseif (str2double(typeID) == 4)
            desiredMode = 'PUBLISH';
        else
            desiredMode = 'RUN_TIME_ERRORS_ONLY';
        end
    end
    
    if (strcmp(desiredMode, 'RUN_TIME_ERRORS_ONLY'))
        validateRunTimeErrors(vScriptsList);
        
    elseif (strcmp(desiredMode, 'FAST'))
        validateFast(vScriptsList);
        
    elseif (strcmp(desiredMode, 'FULL'))
        validateFull(vScriptsList);
        
    elseif (strcmp(desiredMode, 'PUBLISH'))
        validatePublish(vScriptsList);
        
    else
        fprintf('Invalid selection. Run again.\n');
        return;
    end
end

function validateRunTimeErrors(vScriptsList)
     % Instantiate a @UnitTest object
    UnitTestOBJ = UnitTest();
        
    % Print the available validation options and their default values
    % UnitTest.describeValidationOptions();
    
    % Set options for RUNTIME_ERRORS_ONLY validation
    UnitTestOBJ.setValidationOptions(...
                'type',                     'RUNTIME_ERRORS_ONLY', ...
                'onRunTimeError',           getpref('isetbioValidation', 'onRunTimeErrorBehavior'), ...
                'updateGroundTruth',        false, ...
                'updateValidationHistory',  false ...
                );
            
    % ... and Go ! 
    UnitTestOBJ.validate(vScriptsList);
    
end


function validateFast(vScriptsList)
    
    % Instantiate a @UnitTest object
    UnitTestOBJ = UnitTest();   
    
    % Print the available validation options and their default values
    % UnitTest.describeValidationOptions();
    
    % Set options for FAST validation
    UnitTestOBJ.setValidationOptions(...
                'type',                     'FAST', ...
                'onRunTimeError',           getpref('isetbioValidation', 'onRunTimeErrorBehavior'), ...
                'updateGroundTruth',        false, ...
                'updateValidationHistory',  false ...
                );
            
    % ... and Go ! 
    UnitTestOBJ.validate(vScriptsList);
end

function validateFull(vScriptsList)
    
    % Instantiate a @UnitTest object
    UnitTestOBJ = UnitTest();
    
    % Print the available validation options and their default values
    % UnitTest.describeValidationOptions();
    
    % Set options for FULL validation
    UnitTestOBJ.setValidationOptions(...
                'type',                     'FULL', ...
                'onRunTimeError',           getpref('isetbioValidation', 'onRunTimeErrorBehavior'), ...
                'updateGroundTruth',        getpref('isetbioValidation', 'updateGroundTruth'), ...
                'updateValidationHistory',  getpref('isetbioValidation', 'updateValidationHistory') ...
                );
    
    % ... and Go ! 
    UnitTestOBJ.validate(vScriptsList);    
end


function validatePublish(vScriptsList)

    % Instantiate a @UnitTest object
    UnitTestOBJ = UnitTest();
    
    % Cleanup HTML directory if it exists
    UnitTestOBJ.removeHTMLDir();
    
    % Print the available validation options and their default values
    % UnitTest.describeValidationOptions();
    
    % Set options for PUBLISH validation
    UnitTestOBJ.setValidationOptions(...
                'type',                     'PUBLISH', ...
                'onRunTimeError',           getpref('isetbioValidation', 'onRunTimeErrorBehavior'), ...
                'updateGroundTruth',        getpref('isetbioValidation', 'updateGroundTruth'), ...
                'updateValidationHistory',  getpref('isetbioValidation', 'updateValidationHistory') ...
                );
            
    % ... and Go ! 
    UnitTestOBJ.validate(vScriptsList);       
end
