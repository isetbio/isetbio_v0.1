% Method to initalize prefs for isetbioValidation
function setPref(preference, value)

    if ~(ispref('isetbioValidation', preference))
        error('''%s is not a valid preference name', preference);
    end
    
    if ( (strcmp(preference, 'updateValidationHistory')) || ...
         (strcmp(preference, 'updateGroundTruth')) || ...
         (strcmp(preference, 'generatePlots')) || ...
         (strcmp(preference, 'graphMismatchedData')) || ...
         (strcmp(preference, 'compareStrings')) )
            if (~islogical(value))
                error('''%s'' preference value must be set to true or false (logical)', preference);
            end
    end
    
    if (strcmp(preference, 'onRunTimeErrorBehavior'))
        if (~ischar(value))
            error('''onRunTimeErrorBehavior'' preference must be a character string');
        end
        if ~ismember(value, UnitTest.validOnRunTimeErrorValues)
            eval('validOnRunTimeErrorValues = UnitTest.validOnRunTimeErrorValues');
            error('Cannot set ''%s'' to ''%s''. Invalid option.', preference, value);
        end
    end
    
    if (strcmp(preference, 'verbosity'))
        if (~ischar(value))
            error('''verbosity'' preference must be a character string');
        end
        if ~ismember(value, UnitTest.validVerbosityLevels)
            eval('validVerbosityValues = UnitTest.validVerbosityLevels');
            error('Cannot set ''%s'' to ''%s''. Invalid option.', preference, value);
        end
    end
    
    
    setpref('isetbioValidation', preference, value);
end
