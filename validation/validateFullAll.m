function validateFullAll(varargin)
% Full data check (no figures, no publish) of all validation functions
%
%    validateFullAll(param,val, ...)
%
% Possible parameters are (need full list of options from somewhere ...
% please indicate here at least with a pointer)
%
%    'verbosity' -    high, med, low ...
%    'numeric tolerance'
%    'graph mismatched data'
%    'update ground truth'
%    'generate plots'
%
% Examples:
%   validateFullAll('verbosity','high');
%   validateFullAll('Numeric Tolerance',1000*eps);
%   validateFullAll('generate plots',true);
%
% NC, ISETBIO Team, Copyright 2015

close all;  % Is this necessary?
% clc - I prefer controlling my command line. I leave stuff in there
% sometimes.

%% We will use preferences for the 'isetbio' project - this is project specific
UnitTest.usePreferencesForProject('isetbioValidation');
    
%% Initialize @UnitTest preferences
UnitTest.initializePrefs();

%% Reset prefs to the default values
UnitTest.initializePrefs('reset');

%% Set path for the validation root directory - this is project specific
UnitTest.setPref('validationRootDir',     fullfile(isetbioRootPath, 'validation'));

%% Set paths for the directories where the wiki, and the ghPages are cloned - these are project specific
UnitTest.setPref('clonedWikiLocation',    fullfile(filesep,'Users', 'Shared', 'Matlab', 'Toolboxes', 'ISETBIO_Wiki', 'isetbio.wiki'));
UnitTest.setPref('clonedGhPagesLocation', fullfile(filesep,'Users', 'Shared', 'Matlab', 'Toolboxes', 'ISETBIO_GhPages', 'isetbio'));

%% Set the URL for the project - this is project specific
UnitTest.setPref('githubRepoURL', 'http://isetbio.github.io/isetbio');
    

%% Set default preferences for this function

% Whether to update the histories of validation and ground truth data sets
UnitTest.setPref('updateValidationHistory', false);
UnitTest.setPref('updateGroundTruth', false);

% Run time error behavior
UnitTest.setPref('onRunTimeErrorBehavior', 'catchExceptionAndContinue');

% Plot generation
UnitTest.setPref('generatePlots',  false);
UnitTest.setPref('closeFigsOnInit', true);

%% Verbosity Level
UnitTest.setPref('verbosity', 'high');

%% Numeric tolerance for comparison to ground truth data
UnitTest.setPref('numericTolerance', 500*eps);

%% Whether to plot data that do not agree with the ground truth
UnitTest.setPref('graphMismatchedData', true);

%% Adjust parameters based on input arguments
if ~isempty(varargin)
elseif ~isodd(length(varargin))
    for ii=1:2:length(varargin)
        param = ieParamFormat(varargin{ii});
        val   = varargin{ii+1};
        switch(param)
            case 'verbosity'
                UnitTest.setPref('verbosity',val );
            case 'numerictolerance'
                UnitTest.setPref('numericTolerance', val);
            case 'graphMismatchedData'
                UnitTest.setPref('graphMismatchedData', val);
            case 'updateGroundTruth'
                UnitTest.setPref('updateGroundTruth', val);
            case 'generatePlots'
                UnitTest.setPref('generatePlots',  val);
            otherwise
                error('Unknown validation string %s\n',varargin{ii+1});
        end
    end
else
    error('Odd number of arguments, must be param/val pairs');
end

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
UnitTest.runValidationSession(vScriptsList, 'FULL');

% Run a PUBLISH validation session (comparing actual data and update github wiki)
%UnitTest.runValidationSession(vScriptsList, 'PUBLISH');

% Run a validation session without a specified mode. You will be
% promped to select one of the available modes.
%UnitTest.runValidationSession(vScriptsList);

end