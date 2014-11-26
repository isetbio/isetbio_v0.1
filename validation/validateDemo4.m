function validateDemo4
%
% Validation demo illustrating how to 
% - validate a list of script directories. 
% - conduct a validationSession in 'RUN_TIME_ERRORS_ONLY' mode. 

    % Initialize ISETBIO preferences
    UnitTest.initializePrefs();
    % or to reset to the default prefs
    %UnitTest.initializePrefs('reset');
    
    % Change any preferences by uncommenting any of the following:
    %UnitTest.setPref('updateValidationHistory', true);
    %UnitTest.setPref('updateValidationHistory', false);
    %UnitTest.setPref('updateGroundTruth', true);
    %UnitTest.setPref('updateGroundTruth', false);
    
    %UnitTest.setPref('onRunTimeErrorBehavior', 'rethrowExemptionAndAbort');
    %UnitTest.setPref('onRunTimeErrorBehavior', 'catchExemptionAndContinue');
    %UnitTest.setPref('generatePlots',  true); 
    %UnitTest.setPref('generatePlots',  false); 
    
    %UnitTest.setPref('verbosity', 'none');
    UnitTest.setPref('verbosity', 'min');
    %UnitTest.setPref('verbosity', 'low');
    %UnitTest.setPref('verbosity', 'med');
    %UnitTest.setPref('verbosity', 'high');
    %UnitTest.setPref('verbosity', 'max');
    
    % Print available isetbioValidation prefs and their current values
    UnitTest.listPrefs();
    
    % Pass a list of directories to validate.  Each entry contains a cell array with 
    % with a directory of validation scripts and an optional struct with
    % prefs that override the corresponding isetbioValidation prefs.
    % At the moment only the generatePlots pref can be overriden.
    vScriptsList = {...
        {'validationScripts/PTB_vs_ISETBIO'} ...                % use ISETBIO prefs
        {'validationScripts/Scene'} ...                         % use ISETBIO prefs
        {'validationScripts/HumanEye'} ...                      % use ISETBIO prefs
    };
    
    % Run a RUN_TIME_ERRORS_ONLY validation session
    UnitTest.runValidationSession(vScriptsList, 'RUN_TIME_ERRORS_ONLY');
end