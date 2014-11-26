function validateDemo2
    
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
    setpref('isetbioValidation', 'onRunTimeErrorBehavior', 'catchExemptionAndContinue');
    %setpref('isetbioValidation', 'generatePlots',  true); 
    %setpref('isetbioValidation', 'generatePlots',  false); 
    
    %setpref('isetbioValidation', 'verbosity', 'min');
    setpref('isetbioValidation', 'verbosity', 'low');
    %setpref('isetbioValidation', 'verbosity', 'med');
    %setpref('isetbioValidation', 'verbosity', 'high');
    %setpref('isetbioValidation', 'verbosity', 'max'); 
    
    
    % Example2. Here we pass a list of directories to validate. Each entry contains a cell array with a
    % script name and an optional struct with runtime options.
    vScriptsList = {...
        {'validationScripts/PTB_vs_ISETBIO', struct('generatePlots', true) } ...   % override the ISETBIO pref for generatePlots 
        {'validationScripts/Scene'} ...                                            % use ISETBIO prefs
    };
    
    % Run a FULL validation session
    UnitTest.runValidationSession(vScriptsList, 'FULL');
end