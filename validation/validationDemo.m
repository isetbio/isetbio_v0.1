function validateDemo
%
% Validation demo illustrating how to 
% - set various validation preferences
% - validate a list of scripts or a list of script directories. 
% - conduct a validationSession with different modes

    close all
    clc
    
    %% Initialize ISETBIO preferences
    UnitTest.initializePrefs();
    
    %% Optionally, reset prefs to the default values
    UnitTest.initializePrefs('reset');
    
    %% Change some preferences:
    %% Whether to update the histories of validation and ground truth data sets
    UnitTest.setPref('updateValidationHistory', false);
    UnitTest.setPref('updateGroundTruth', false);
    
    %% Run time error behavior
    %UnitTest.setPref('onRunTimeErrorBehavior', 'rethrowExemptionAndAbort');
    UnitTest.setPref('onRunTimeErrorBehavior', 'catchExemptionAndContinue');
    
    %% Plot generation
    UnitTest.setPref('generatePlots',  true); 
    UnitTest.setPref('closeFigsOnInit', true);
    
    %% Verbosity Level
    %UnitTest.setPref('verbosity', 'none');
    UnitTest.setPref('verbosity', 'min');
    %UnitTest.setPref('verbosity', 'low');
    %UnitTest.setPref('verbosity', 'med');
    %UnitTest.setPref('verbosity', 'high');
    %UnitTest.setPref('verbosity', 'max');
    
    %% Numeric tolerance for comparison to ground truth data
    UnitTest.setPref('numericTolerance', 500*eps);
    
    %% Whether to plot data that do not agree with the ground truth
    UnitTest.setPref('graphMismatchedData', false);
    
    %% Print current values of isetbioValidation prefs
    UnitTest.listPrefs();
    
    %% What to validate
    validateAllDirs = false;
    if (validateAllDirs)
        % List of script directories to validate. Each entry contains a cell array with 
        % with a validation script directory and an optional struct with
        % prefs that override the corresponding isetbioValidation prefs.
        % At the moment only the 'generatePlots' pref can be overriden.
        vScriptsList = {...
            {'validationScripts/Color', struct('generatePlots', true) } ...
            {'validationScripts/Cones', struct('generatePlots', true) } ...
            {'validationScripts/HumanEye',       } ...
            {'validationScripts/Radiometry', } ...    
            {'validationScripts/Scene',          } ...    
            {'validationScripts/ExampleScripts', struct('generatePlots', true) } ...
        };
    else
        % Alternatively, you can provide a list of scripts to validate. 
        % In this case each entry contains a cell array with 
        % with a script name and an optional struct with
        % prefs that override the corresponding isetbioValidation prefs.
        % At the moment only the generatePlots pref can be overriden.
        vScriptsList = {...
            {'v_Colorimetry'} ...
            {'v_IrradianceIsomerizations', struct('generatePlots', true)}  ...
            {'v_skeleton'}
        };
    end
    
    %% How to validate
    % Run a RUN_TIME_ERRORS_ONLY validation session
    % UnitTest.runValidationSession(vScriptsList, 'RUN_TIME_ERRORS_ONLY')
    
    % Run a FAST validation session (comparing SHA-256 hash keys of the data)
    % UnitTest.runValidationSession(vScriptsList, 'FAST');
    
    % Run a FULL validation session (comparing actual data)
    % UnitTest.runValidationSession(vScriptsList, 'FULL');
    
    % Run a PUBLISH validation session (comparing actual data and update github wiki)
    % UnitTest.runValidationSession(vScriptsList, 'PUBLISH);
    
    % Run a validation session without a specified mode. You will be
    % promped to select one of the available modes.
    UnitTest.runValidationSession(vScriptsList);

end