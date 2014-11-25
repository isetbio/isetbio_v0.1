function validateDemo6
    
    % Set default ISETBIO preferences
    UnitTest.InitializeISETBIOprefs();
    
    % change any preferences you would like to.
    % by uncommenting one of the following:

    %setpref('isetbioValidation', 'updateValidationHistory', true);
    %setpref('isetbioValidation', 'updateValidationHistory', false);
    %setpref('isetbioValidation', 'updateGroundTruth', true);
    %setpref('isetbioValidation', 'updateGroundTruth', false);
    
    %setpref('isetbioValidation', 'onRunTimeErrorBehavior', 'rethrowExemptionAndAbort');
    %setpref('isetbioValidation', 'onRunTimeErrorBehavior', 'catchExemptionAndContinue');
    %setpref('isetbioValidation', 'generatePlots',  true); 
    %setpref('isetbioValidation', 'generatePlots',  false); 
    
    
    % Example2. Here we pass a list of directories to validate. Each entry contains a cell array with a
    % script name and an optional struct with runtime options.
    vScriptsList = {...
        {'validationScripts/PTB_vs_ISETBIO'} ...                % use ISETBIO prefs
        {'validationScripts/Scene'} ...                         % use ISETBIO prefs
    };
    
    % Run a PUBLISH validation session
    UnitTest.runValidationSession(vScriptsList, 'PUBLISH');
end