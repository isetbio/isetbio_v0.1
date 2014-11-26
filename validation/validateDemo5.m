function validateDemo5
%
% Validation demo illustrating how to 
% - validate a list of script directories. 
% - conduct a validationSession in 'FAST' mode. 
% - update the ground truth data history

    % Initialize ISETBIO preferences
    UnitTest.initializePrefs();
    % or to reset to the default prefs
    %UnitTest.initializePrefs('reset');
    
    % Change any preferences by uncommenting any of the following:
    %UnitTest.setPref('updateValidationHistory', true);
    %UnitTest.setPref('updateValidationHistory', false);
    UnitTest.setPref('updateGroundTruth', true);
    %UnitTest.setPref('updateGroundTruth', false);
    
    %UnitTest.setPref('onRunTimeErrorBehavior', 'rethrowExemptionAndAbort');
    %UnitTest.setPref('onRunTimeErrorBehavior', 'catchExemptionAndContinue');
    %UnitTest.setPref('generatePlots',  true); 
    %UnitTest.setPref('generatePlots',  false); 
    
    %UnitTest.setPref('verbosity', 'min');
    UnitTest.setPref('verbosity', 'low');
    %UnitTest.setPref('verbosity', 'med');
    %UnitTest.setPref('verbosity', 'high');
    %UnitTest.setPref('verbosity', 'max');
    
    
    % Pass a list of directories to validate.  Each entry contains a cell array with 
    % with a directory of validation scripts and an optional struct with
    % prefs that override the corresponding isetbioValidation prefs.
    % At the moment only the generatePlots pref can be overriden.
    vScriptsList = {...
        {'validationScripts/PTB_vs_ISETBIO'} ...                % use ISETBIO prefs
        {'validationScripts/Scene'} ...                         % use ISETBIO prefs
        {'validationScripts/HumanEye'} ...                      % use ISETBIO prefs
    };
    
    % Run a PUBLISH validation session
    UnitTest.runValidationSession(vScriptsList, 'FAST');
end