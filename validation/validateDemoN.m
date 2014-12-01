function validateDemoN
    
    % Initialize ISETBIO preferences
    UnitTest.initializePrefs();
    % or to reset to the default prefs
    %UnitTest.initializePrefs('reset');
    
    % change any preferences you would like to.
    % Uncomment one of the following options

    %UnitTest.setPref('isetbioValidation', 'updateValidationHistory', true);
    %UnitTest.setPref('isetbioValidation', 'updateValidationHistory', false);
    %UnitTest.setPref('isetbioValidation', 'updateGroundTruth', true);
    %UnitTest.setPref('isetbioValidation', 'updateGroundTruth', false);
    
    %UnitTest.setPref('isetbioValidation', 'onRunTimeErrorBehavior', 'rethrowExemptionAndAbort');
    UnitTest.setPref('isetbioValidation', 'onRunTimeErrorBehavior', 'catchExemptionAndContinue');
    %UnitTest.setPref('isetbioValidation', 'generatePlots',  true); 
    %sUnitTest.setPref('isetbioValidation', 'generatePlots',  false); 
    
     %UnitTest.setPref('verbosity', 'min');
    UnitTest.setPref('verbosity', 'low');
    %UnitTest.setPref('verbosity', 'med');
    %UnitTest.setPref('verbosity', 'high');
    %UnitTest.setPref(verbosity', 'max');
    UnitTest.setPref('numericTolerance', 400*eps);
    %UnitTest.setPref('graphMismatchedData', true);
    %UnitTest.setPref('graphMismatchedData', false);
    
    % Pass a list of scripts to validate. Each entry contains a cell array with 
    % with a validation script and an optional struct with
    % prefs that override the corresponding isetbioValidation prefs.
    % At the moment only the generatePlots pref can be overriden.
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