function validateAndPublishAll
%
% Validation and publish our full list of validation programs

    close all
    clc
    
    %% We will use preferences for the 'isetbio' project - this is project specific
    UnitTest.usePreferencesForProject('isetbioValidation');

    %% Initialize @UnitTest preferences
    UnitTest.initializePrefs();
    
    %% Optionally, reset prefs to the default values
    UnitTest.initializePrefs('reset');
    
    %% Set path for the validation root directory - this is project specific
    UnitTest.setPref('validationRootDir',     fullfile(isetbioRootPath, 'validation'));

    %% Set paths for the directories where the wiki, and the ghPages are cloned - these are project specific
    UnitTest.setPref('clonedWikiLocation',    fullfile(filesep,'Users', 'Shared', 'Matlab', 'Toolboxes', 'ISETBIO_Wiki', 'isetbio.wiki'));
    UnitTest.setPref('clonedGhPagesLocation', fullfile(filesep,'Users', 'Shared', 'Matlab', 'Toolboxes', 'ISETBIO_GhPages', 'isetbio'));

    %% Set the URL for the project - this is project specific
    UnitTest.setPref('githubRepoURL', 'http://isetbio.github.io/isetbio');


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
    
    %% Verbosity Level
    %UnitTest.setPref('verbosity', 'none');
    %UnitTest.setPref('verbosity', 'min');
    %UnitTest.setPref('verbosity', 'low');
    UnitTest.setPref('verbosity', 'med');
    %UnitTest.setPref('verbosity', 'high');
    %UnitTest.setPref('verbosity', 'max');
    
    %% Numeric tolerance for comparison to ground truth data
    UnitTest.setPref('numericTolerance', 500*eps);
    
    %% Whether to plot data that do not agree with the ground truth
    UnitTest.setPref('graphMismatchedData', false);
    
    %% Print current values of isetbioValidation prefs
    UnitTest.listPrefs();
    
    %% What to validate
    vScriptsList = validateListAllValidationDirs;
        
    %% How to validate
    % Run a RUN_TIME_ERRORS_ONLY validation session
    % UnitTest.runValidationSession(vScriptsList, 'RUN_TIME_ERRORS_ONLY')
    
    % Run a FAST validation session (comparing SHA-256 hash keys of the data)
    % UnitTest.runValidationSession(vScriptsList, 'FAST');
    
    % Run a FULL validation session (comparing actual data)
    % UnitTest.runValidationSession(vScriptsList, 'FULL');
    
    % Run a PUBLISH validation session (comparing actual data and update github wiki)
    UnitTest.runValidationSession(vScriptsList, 'PUBLISH');
    
    % Run a validation session without a specified mode. You will be
    % promped to select one of the available modes.
    %UnitTest.runValidationSession(vScriptsList);

end