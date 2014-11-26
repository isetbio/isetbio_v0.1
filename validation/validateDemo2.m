function validateDemo2
%
% Validation demo illustrating how to 
% - validate a list of script directories. 
% - override the generatePlots isetbioValidation pref
% - conduct a validationSession in 'FULL' mode. 

    close all
    clc
    
    % Initialize ISETBIO preferences
    UnitTest.initializePrefs();
    % or to reset to the default prefs
    UnitTest.initializePrefs('reset');
    
    % Change any preferences by uncommenting any of the following:
    %UnitTest.setPref('updateValidationHistory', true);
    %UnitTest.setPref('updateValidationHistory', false);
    %UnitTest.setPref('updateGroundTruth', true);
    %UnitTest.setPref('updateGroundTruth', false);
    %UnitTest.setPref('onRunTimeErrorBehavior', 'rethrowExemptionAndAbort');
    UnitTest.setPref('onRunTimeErrorBehavior', 'catchExemptionAndContinue');
    %UnitTest.setPref('generatePlots',  true); 
    %UnitTest.setPref('generatePlots',  false); 
    
    %UnitTest.setPref('verbosity', 'none');
    %UnitTest.setPref('verbosity', 'min');
    %UnitTest.setPref('verbosity', 'low');
    %UnitTest.setPref('verbosity', 'med');
    UnitTest.setPref('verbosity', 'high');
    %UnitTest.setPref('verbosity', 'max'); 
    UnitTest.setPref('numericTolerance', 400*eps);
    %UnitTest.setPref('graphMismatchedData', true);
    %UnitTest.setPref('graphMismatchedData', false);
    
    
    % Print available isetbioValidation prefs and their current values
    UnitTest.listPrefs();
    
    % Pass a list of directories to validate.  Each entry contains a cell array with 
    % with a directory of validation scripts and an optional struct with
    % prefs that override the corresponding isetbioValidation prefs.
    % At the moment only the generatePlots pref can be overriden.
    vScriptsList = {...
        {'validationScripts/PTB_vs_ISETBIO', struct('generatePlots', true) } ...   % override the ISETBIO pref for generatePlots 
        {'validationScripts/Scene'} ...                                            % use ISETBIO prefs
        {'validationScripts/HumanEye'} ...                                         % use ISETBIO prefs
    };
    
    % Run a FULL validation session
    UnitTest.runValidationSession(vScriptsList, 'FULL');
end