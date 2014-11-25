function validateDemo3
    
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
        {'validationScripts/PTB_vs_ISETBIO', struct('generatePlots', true) } ...   % override the ISETBIO pref for generatePlots 
        {'validationScripts/Scene'} ...                                            % use ISETBIO prefs
    };

    % Employ the 'catchExemptionAndContinue' runtime behavior
    setpref('isetbioValidation', 'onRunTimeErrorBehavior', 'catchExemptionAndContinue');
    
    % Append validation data to the ground truth data set
    setpref('isetbioValidation', 'updateGroundTruth', true);
    
     % Append validation data to the validation history data set
    setpref('isetbioValidation', 'updateValidationHistory', true);
    
    % Run a FULL validation session
    UnitTest.runValidationSession(vScriptsList, 'FULL');
end