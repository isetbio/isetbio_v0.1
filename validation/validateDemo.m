function validateDemo
%
% Validation demo illustrating how to 
% - set various validation preferences
% - validate a list of scripts or a list of script directories. 
% - conduct a validationSession with different modes

    close all
    clc
    
    %% Initialize @UnitTest preferences
    UnitTest.initializePrefs();
    
    %% Optionally, reset prefs to the default values
    UnitTest.initializePrefs('reset');
    
    %% Change some preferences:
    %% Whether to update the histories of validation and ground truth data sets
    UnitTest.setPref('updateValidationHistory', false);
    UnitTest.setPref('updateGroundTruth', false);
    
    %% Run time error behavior
    %UnitTest.setPref('onRunTimeErrorBehavior', 'rethrowExceptionAndAbort');
    UnitTest.setPref('onRunTimeErrorBehavior', 'catchExceptionAndContinue');
    
    %% Plot generation
    UnitTest.setPref('generatePlots',  true); 
    UnitTest.setPref('closeFigsOnInit', true);
    
    %% Verbosity Level3
    
    %UnitTest.setPref('verbosity', 'none');
    %UnitTest.setPref('verbosity', 'min');
    %UnitTest.setPref('verbosity', 'low');
    UnitTest.setPref('verbosity', 'med');
    %UnitTest.setPref('verbosity', 'high');
    %UnitTest.setPref('verbosity', 'max');
    
    %% Numeric tolerance for comparison to ground truth data
    UnitTest.setPref('numericTolerance', 500*eps);
    
    %% Whether to plot data that do not agree with the ground truth
    UnitTest.setPref('graphMismatchedData', true);
    
    %% Path preferences (these are only relevant to github integration)
    % Change to match configuration on the host machine
    %UnitTest.setPref('validationRootDir',       fullfile(filesep,'Users', 'Shared', 'Matlab', 'Toolboxes', 'isetbio', 'validation'));
    %UnitTest.setPref('clonedWikiLocation',      fullfile(filesep,'Users', 'Shared', 'Matlab', 'Toolboxes', 'ISETBIO_Wiki', 'isetbio.wiki'));
    %UnitTest.setPref('clonedGhPagesLocation',   fullfile(filesep,'Users', 'Shared', 'Matlab', 'Toolboxes', 'ISETBIO_GhPages', 'isetbio'));

    %% Print current values of isetbioValidation prefs
    UnitTest.listPrefs();
    
    %% What to validate
    validateAllDirs = true;
    if (validateAllDirs)
        % List of script directories to validate. Each entry contains a cell array with 
        % with a validation script directory and an optional struct with
        % prefs that override the corresponding isetbioValidation prefs.
        % At the moment only the 'generatePlots' pref can be overriden.
        %
        % We have functions that generate various stock vScriptsList, but
        % here we do it out explicitly.
        % 
        % Note that the exampleScripts directory contains some scripts that
        % intentionally fail in various ways.
        vScriptsList = {...
            {fullfile('scripts', 'color')} ... 
            {fullfile('scripts', 'cones')} ... 
            {fullfile('scripts', 'human')} ... 
            {fullfile('scripts', 'optics')} ... 
            {fullfile('scripts', 'radiometry')} ... 
            {fullfile('scripts', 'scene')} ... 
            {fullfile('scripts', 'codedevscripts'), struct('generatePlots', true) } ...
        };
    else
        % Alternatively, you can provide a list of scripts to validate. 
        % In this case each entry contains a cell array with 
        % with a script name and an optional struct with
        % prefs that override the corresponding isetbioValidation prefs.
        % At the moment only the generatePlots pref can be overriden.
        vScriptsList = {...
           % {'v_stockman2xyz'} ...
           % {'v_IrradianceIsomerizations', struct('generatePlots', true)}  ...
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