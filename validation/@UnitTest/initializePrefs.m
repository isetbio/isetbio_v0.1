% Method to initalize prefs for ISETBIO
function initializePrefs(initMode)

    if (nargin == 0)
        initMode = 'none';
    end
    
    if (strcmp(initMode, 'reset'))
        rmpref('isetbioValidation');
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
    
    if (~ispref('isetbioValidation', 'closeFigsOnInit'))  || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.runTimeOptionNames, 'closeFigsOnInit'));
        value = UnitTest.runTimeOptionDefaultValues{index};
        setpref('isetbioValidation', 'closeFigsOnInit',  value); 
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
    
    if (~ispref('isetbioValidation', 'compareStringFields'))  || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.validationOptionNames, 'compareStringFields'));
        value = UnitTest.validationOptionDefaultValues{index};
        setpref('isetbioValidation', 'compareStringFields',  value); 
    end
    
    
    if (~ispref('isetbioValidation', 'validationRootDir'))  || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.validationOptionNames, 'validationRootDir'));
        value = UnitTest.validationOptionDefaultValues{index};
        % automatically set RootDir
        currDir = pwd; 
        cd ..
        rootDir = pwd;
        cd(currDir);
        value = fullfile(rootDir, 'validation');
        setpref('isetbioValidation', 'validationRootDir',  value); 
    end
    
    if (~ispref('isetbioValidation', 'clonedWikiLocation'))  || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.validationOptionNames, 'clonedWikiLocation'));
        value = UnitTest.validationOptionDefaultValues{index};
        setpref('isetbioValidation', 'clonedWikiLocation',  value); 
    end
    
    if (~ispref('isetbioValidation', 'clonedGhPagesLocation'))  || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.validationOptionNames, 'clonedGhPagesLocation'));
        value = UnitTest.validationOptionDefaultValues{index};
        setpref('isetbioValidation', 'clonedGhPagesLocation',  value); 
    end
    
    if (~ispref('isetbioValidation', 'githubRepoURL'))  || (strcmp(initMode, 'reset'))
        index = find(strcmp(UnitTest.validationOptionNames, 'githubRepoURL'));
        value = UnitTest.validationOptionDefaultValues{index};
        setpref('isetbioValidation', 'githubRepoURL',  value); 
    end
    
end
