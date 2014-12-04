function validateDemo1
%
% Validation demo illustrating how to 
% - validate a list of scripts. 
% - override the generatePlots isetbioValidation pref
% - conduct a validationSession with different modes

    close all
    clc
    
    %% Initialize ISETBIO preferences
    UnitTest.initializePrefs();
    
    % Optionally, reset prefs to the default values
    UnitTest.initializePrefs('reset');
    
    
    % Change any preferences by uncommenting any of the following:
    
    %% Whether to update history
    UnitTest.setPref('updateValidationHistory', false);
    UnitTest.setPref('updateGroundTruth', false);
    
    %% Run time behavior
    %UnitTest.setPref('onRunTimeErrorBehavior', 'rethrowExemptionAndAbort');
    UnitTest.setPref('onRunTimeErrorBehavior', 'catchExemptionAndContinue');
    
    %% Plot generation
    UnitTest.setPref('generatePlots',  true); 
    UnitTest.setPref('closeFigsOnInit', true);
    
    %% Verbosity
    %UnitTest.setPref('verbosity', 'none');
    %UnitTest.setPref('verbosity', 'min');
    %UnitTest.setPref('verbosity', 'low');
    UnitTest.setPref('verbosity', 'med');
    %UnitTest.setPref('verbosity', 'high');
    %UnitTest.setPref('verbosity', 'max');
    
    %% Numeric tolerance for comparison to ground truth data
    UnitTest.setPref('numericTolerance', 300*eps);
    
    %% Whether to plot data that do not agree with the ground truth
    UnitTest.setPref('graphMismatchedData', false);
    
    % Print  isetbioValidation prefs and their current values
    UnitTest.listPrefs();
    
    
    % List of scripts to validate. Each entry contains a cell array with 
    % with a script name and an optional struct with
    % prefs that override the corresponding isetbioValidation prefs.
    % At the moment only the generatePlots pref can be overriden.
    vScriptsList = {...
        {'validationScripts/PTB_vs_ISETBIO', } ...    % override the ISETBIO pref for 'generatePlots'
        {'validationScripts/Scene',          } ...    
        {'validationScripts/HumanEye',       } ...
        {'validationScripts/ExampleScripts', struct('generatePlots', true) } ...
    };

    % Run a FAST validation session (comparing SHA-256 hash keys of the data)
    %UnitTest.runValidationSession(vScriptsList, 'FAST');
    
    % Run a FULL validation session (comparing actual data)
    %UnitTest.runValidationSession(vScriptsList, 'FULL');
    
    % Run a FULL validation session without a specified mode. You will be
    % promped to select one of the available modes
    UnitTest.runValidationSession(vScriptsList);

end