function validateDemo4
    
    % Initialize ISETBIO preferences
    UnitTest.initializeISETBIOprefs();
    % or to reset to the default prefs
    %UnitTest.initializeISETBIOprefs('reset');
    
    % Change any preferences by uncommenting any of the following:
    %setpref('isetbioValidation', 'updateValidationHistory', true);
    %setpref('isetbioValidation', 'updateValidationHistory', false);
    %setpref('isetbioValidation', 'updateGroundTruth', true);
    %setpref('isetbioValidation', 'updateGroundTruth', false);
    
    %setpref('isetbioValidation', 'onRunTimeErrorBehavior', 'rethrowExemptionAndAbort');
    %setpref('isetbioValidation', 'onRunTimeErrorBehavior', 'catchExemptionAndContinue');
    %setpref('isetbioValidation', 'generatePlots',  true); 
    %setpref('isetbioValidation', 'generatePlots',  false); 
    
    setpref('isetbioValidation', 'verbosity', 'min');
    %setpref('isetbioValidation', 'verbosity', 'low');
    %setpref('isetbioValidation', 'verbosity', 'med');
    %setpref('isetbioValidation', 'verbosity', 'high');
    %setpref('isetbioValidation', 'verbosity', 'max');
    
    % Example2. Here we pass a list of directories to validate. Each entry contains a cell array with a
    % script name and an optional struct with runtime options.
    vScriptsList = {...
        {'validationScripts/PTB_vs_ISETBIO'} ...                % use ISETBIO prefs
        {'validationScripts/Scene'} ...                         % use ISETBIO prefs
    };
    
    % Run a RUN_TIME_ERRORS_ONLY validation session
    UnitTest.runValidationSession(vScriptsList, 'RUN_TIME_ERRORS_ONLY');
end