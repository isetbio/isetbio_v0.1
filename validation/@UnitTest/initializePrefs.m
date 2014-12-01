% Method to initalize prefs for ISETBIO
function initializePrefs(initMode)

    if (nargin == 0)
        initMode = 'none';
    end
    
    if ~(ispref('isetbioValidation', 'updateGroundTruth')) || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.validationOptionNames, 'updateGroundTruth'));
        value = UnitTest.validationOptionDefaultValues{index};
        setpref('isetbioValidation', 'updateGroundTruth', value);
    end
    
    if ~(ispref('isetbioValidation', 'updateValidationHistory'))  || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.validationOptionNames, 'updateValidationHistory'));
        value = UnitTest.validationOptionDefaultValues{index};
        setpref('isetbioValidation', 'updateValidationHistory', value);
    end
    
    if (~ispref('isetbioValidation', 'onRunTimeErrorBehavior'))  || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.validationOptionNames, 'onRunTimeErrorBehavior'));
        value = UnitTest.validationOptionDefaultValues{index};
        setpref('isetbioValidation', 'onRunTimeErrorBehavior',  value); 
    end
    
    if (~ispref('isetbioValidation', 'generatePlots'))  || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.runTimeOptionNames, 'generatePlots'));
        value = UnitTest.runTimeOptionDefaultValues{index};
        setpref('isetbioValidation', 'generatePlots',  value); 
    end
    
    if (~ispref('isetbioValidation', 'verbosity'))  || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.validationOptionNames, 'verbosity'));
        value = UnitTest.validationOptionDefaultValues{index};
        setpref('isetbioValidation', 'verbosity',  value); 
    end
    
    if (~ispref('isetbioValidation', 'numericTolerance'))  || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.validationOptionNames, 'numericTolerance'));
        value = UnitTest.validationOptionDefaultValues{index};
        setpref('isetbioValidation', 'numericTolerance',  value); 
    end
   
    if (~ispref('isetbioValidation', 'graphMismatchedData'))  || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.validationOptionNames, 'graphMismatchedData'));
        value = UnitTest.validationOptionDefaultValues{index};
        setpref('isetbioValidation', 'graphMismatchedData',  value); 
    end
    
end
