function validateDemo0
%
% Validation demo testing the effects of different numerical precision on
% validation via data hash vs full data. The speed of the two validation
% methods is also compared.

    close all
    clc
    
    % Initialize ISETBIO preferences
    UnitTest.initializePrefs();
    % or reset to the default prefs
    UnitTest.initializePrefs('reset');
    
    
    % Change any preferences by uncommenting any of the following:
    UnitTest.setPref('updateValidationHistory', false);
    UnitTest.setPref('updateGroundTruth', false);
    %UnitTest.setPref('onRunTimeErrorBehavior', 'rethrowExemptionAndAbort');
    UnitTest.setPref('onRunTimeErrorBehavior', 'catchExemptionAndContinue');
    %UnitTest.setPref('generatePlots',  true); 
    UnitTest.setPref('generatePlots',  true); 
    UnitTest.setPref('closeFigsOnInit', true);
    
    %UnitTest.setPref('verbosity', 'none');
    %UnitTest.setPref('verbosity', 'min');
    UnitTest.setPref('verbosity', 'low');
    %UnitTest.setPref('verbosity', 'med');
    %UnitTest.setPref('verbosity', 'high');
    %UnitTest.setPref('verbosity', 'max');
    
    UnitTest.setPref('numericTolerance', 2*eps);
    UnitTest.setPref('graphMismatchedData', true);
    
    % Print available isetbioValidation prefs and their current values
    UnitTest.listPrefs();
    pause(1);
    
    % List of scripts to validate. Each entry contains a cell array with 
    % with a script name and an optional struct with
    % prefs that override the corresponding isetbioValidation prefs.
    % At the moment only the generatePlots pref can be overriden.
    vScriptsList = {...
        {'v_DataHash_VS_FullData'} ... 
        {'v_PTB_vs_ISETBIO_IrradianceIsomerizations'}
    };

    % Run a validation session without specifying a mode: we will be prompted to specify one
    UnitTest.runValidationSession(vScriptsList);
end