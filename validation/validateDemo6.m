function validateDemo6
    
    % Initialize ISETBIO preferences
    UnitTest.initializeISETBIOprefs();
    
    % Change any preferences by uncommenting any of the following:
    %setpref('isetbioValidation', 'updateValidationHistory', true);
    %setpref('isetbioValidation', 'updateValidationHistory', false);
    %setpref('isetbioValidation', 'updateGroundTruth', true);
    %setpref('isetbioValidation', 'updateGroundTruth', false);
    
    %setpref('isetbioValidation', 'onRunTimeErrorBehavior', 'rethrowExemptionAndAbort');
    %setpref('isetbioValidation', 'onRunTimeErrorBehavior', 'catchExemptionAndContinue');
    setpref('isetbioValidation', 'generatePlots',  true); 
    %setpref('isetbioValidation', 'generatePlots',  false); 
    
    %setpref('isetbioValidation', 'verbosity', 'min');
    setpref('isetbioValidation', 'verbosity', 'low');
    %setpref('isetbioValidation', 'verbosity', 'med');
    %setpref('isetbioValidation', 'verbosity', 'high');
    %setpref('isetbioValidation', 'verbosity', 'max');
    
    % Example6. Here we pass a list of script directories to validate and PUBLISH.
    vScriptsList = {...
        {'validationScripts/PTB_vs_ISETBIO'} ...                % use ISETBIO prefs
        {'validationScripts/Scene'} ...                         % use ISETBIO prefs
    };
    
    % Run a PUBLISH validation session
    UnitTest.runValidationSession(vScriptsList, 'PUBLISH');
end