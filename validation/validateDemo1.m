function validateDemo1
%
% Validation demo illustrating how to 
% - validate a list of scripts. 
% - override the generatePlots isetbioValidation pref
% - conduct a validationSession with unspecified mode, which results in
%   a listing of all available modes.

    close all
    clc
    
    % Initialize ISETBIO preferences
    UnitTest.initializePrefs();
    % or reset to the default prefs
    UnitTest.initializePrefs('reset');
    
    
    % Change any preferences by uncommenting any of the following:
    %UnitTest.setPref('updateValidationHistory', true);
    %UnitTest.setPref('updateValidationHistory', false);
    %UnitTest.setPref('updateGroundTruth', true);
    %UnitTest.setPref('updateGroundTruth', false);
    %UnitTest.setPref('onRunTimeErrorBehavior', 'rethrowExemptionAndAbort');
    %UnitTest.setPref('onRunTimeErrorBehavior', 'catchExemptionAndContinue');
    %UnitTest.setPref('generatePlots',  true); 
    UnitTest.setPref('generatePlots',  false); 
    
    %UnitTest.setPref('verbosity', 'none');
    UnitTest.setPref('verbosity', 'min');
    %UnitTest.setPref('verbosity', 'low');
    %UnitTest.setPref('verbosity', 'med');
    %UnitTest.setPref('verbosity', 'high');
    %UnitTest.setPref('verbosity', 'max');
    UnitTest.setPref('numericTolerance', 400*eps);
    %UnitTest.setPref('graphMismatchedData', true);
    %UnitTest.setPref('graphMismatchedData', false);
    
    % Print available isetbioValidation prefs and their current values
    UnitTest.listPrefs();
    
    
    % List of scripts to validate. Each entry contains a cell array with 
    % with a script name and an optional struct with
    % prefs that override the corresponding isetbioValidation prefs.
    % At the moment only the generatePlots pref can be overriden.
    vScriptsList = {...
        {'validateSceneReIllumination'} ...                                  % use ISETBIO prefs
        {'validateOTFandPupilSize',    struct('generatePlots', true) } ...   % override the ISETBIO pref for generatePlots
        {'PTB_vs_ISETBIO_Irradiance',  struct('generatePlots', true) } ...   % override the ISETBIO pref for generatePlots 
        {'validateSkeleton'} 
    };

    % Run a validation session without specifying a mode: we will be prompted to specify one
    UnitTest.runValidationSession(vScriptsList);
end