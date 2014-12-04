function validateDemo2
%
% Validation demo illustrating how to 
% - validate and PUBLISH a list of individual script. 

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
    UnitTest.setPref('onRunTimeErrorBehavior', 'rethrowExemptionAndAbort');
    %UnitTest.setPref('onRunTimeErrorBehavior', 'catchExemptionAndContinue');
    
    %% Plot generation
    UnitTest.setPref('generatePlots',  true); 
    UnitTest.setPref('closeFigsOnInit', true);
    
    %% Verbosity
    %UnitTest.setPref('verbosity', 'none');
    UnitTest.setPref('verbosity', 'min');
    %UnitTest.setPref('verbosity', 'low');
    %UnitTest.setPref('verbosity', 'med');
    %UnitTest.setPref('verbosity', 'high');
    %UnitTest.setPref('verbosity', 'max');
    
    %% Numeric tolerance for comparison to ground truth data
    UnitTest.setPref('numericTolerance', 1E-12);
    
    %% Whether to plot data that do not agree with the ground truth
    UnitTest.setPref('graphMismatchedData', false);
    
    % Print  isetbioValidation prefs and their current values
    UnitTest.listPrefs();
    
    % Pass a list of directories to validate.  Each entry contains a cell array with 
    % with a directory of validation scripts and an optional struct with
    % prefs that override the corresponding isetbioValidation prefs.
    % At the moment only the generatePlots pref can be overriden.
    vScriptsList = {...
        {'v_PTB_vs_ISETBIO_Colorimetry'} ...
        {'v_PTB_vs_ISETBIO_IrradianceIsomerizations'} ...
        {'v_OTFandPupilSize'} ...
        {'v_HumanRetinalIlluminance580nm'} ...
        {'v_fundamentalValidationFailure'} ...
        {'v_runTimeError'} ...
    };
    
    % Run a FULL validation session
    UnitTest.runValidationSession(vScriptsList, 'PUBLISH');
end