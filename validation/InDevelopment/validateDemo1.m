function validateDemo1
    
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
    
    
    % Example1. Here we pass a list of scripts to validate. Each entry contains a cell array with a
    % script name and an optional struct with runtime options.
    vScriptsList = {...
        {'validateSceneReIllumination'} ...                                               % use ISETBIO prefs
        {'PTB_vs_ISETBIO_Irradiance',  struct('generatePlots', true) } ...                % override the ISETBIO pref for generatePlots 
    };

    % Run a validation session without specifying a mode: we will be prompted to specify one
    UnitTest.runValidationSession(vScriptsList);
end