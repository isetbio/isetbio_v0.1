function validateDemoN
    
    % Set default ISETBIO preferences
    UnitTest.InitializeISETBIOprefs();
    getpref('isetbioValidation')
    
    % change any preferences you would like to.
    % Uncomment one of the following options

    %setpref('isetbioValidation', 'updateValidationHistory', true);
    %setpref('isetbioValidation', 'updateValidationHistory', false);
    %setpref('isetbioValidation', 'updateGroundTruth', true);
    %setpref('isetbioValidation', 'updateGroundTruth', false);
    
    %setpref('isetbioValidation', 'onRunTimeErrorBehavior', 'rethrowExemptionAndAbort');
    setpref('isetbioValidation', 'onRunTimeErrorBehavior', 'catchExemptionAndContinue');
    %setpref('isetbioValidation', 'generatePlots',  true); 
    %setpref('isetbioValidation', 'generatePlots',  false); 
    
    
    % Example1. Here we pass a list of scripts to validate. Each entry contains a cell array with a
    % script name and an optional struct with runtime options.
    vScriptsList = {...
        {'validateSceneReIllumination'} ...                                             % use ISETBIO prefs 
        {'validateSceneReIllumination',  struct('generatePlots', true) } ...            % override the generatePlots preference
    };

    % runValidationSession without specifying a mode: we will be prompted
    % to specify one
    UnitTest.runValidationSession(vScriptsList);
    disp('Hit enter to continue with a different validation session');
    pause;
    
    % Example 2. Here we pass a list of script directories to validate. Each entry contains a cell
    % array with a directory containing validation scripts and an optional stuct with
    % runtime options
    vScriptsList = {...
        {'validationScripts/PTB_vs_ISETBIO', struct('generatePlots', true) } ...  
        {'validationScripts/Scene',  struct('generatePlots', true) } ...
    };
    
    % Available validation modes:
    % RUN_TIME_ERRORS_ONLY  - runtime errors only
    % FAST                  - runtime errors + data hash comparison
    % FULL                  - runtime errors + full data comparison
    % PUBLISH               - runtime errors + github wiki update
    % If a second argument (validation mode) is not passed, the code will prompt you for one.
    
    UnitTest.runValidationSession(vScriptsList, 'RUN_TIME_ERRORS_ONLY');
    disp('Hit enter to continue with a different validation session');
    pause;
    
    
    
    vScriptsList = {...
        {'validationScripts/PTB_vs_ISETBIO', struct('generatePlots', true) } ...  
        {'validationScripts/Scene',  struct('generatePlots', true) } ...
    };
    UnitTest.runValidationSession(vScriptsList, 'FULL');
    
    vScriptsList = {...
        {'validationScripts/PTB_vs_ISETBIO', struct('generatePlots', true)  } ...    % specify the generatePlots runtime option
        {'validationScripts/Scene'} ...   % use getPref for runtime params
    };

    UnitTest.runValidationSession(vScriptsList, 'PUBLISH');
    
end