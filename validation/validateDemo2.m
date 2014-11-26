function validateDemo2
%
% Validation demo illustrating how to 
% - validate a list of script directories. 
% - override the generatePlots isetbioValidation pref
% - conduct a validationSession in 'FULL' mode. 

    close all
    clc
    
    % Initialize ISETBIO preferences
    UnitTest.initializeISETBIOprefs();
    % or to reset to the default prefs
    %UnitTest.initializeISETBIOprefs('reset');
    
    % Change any preferences by uncommenting any of the following:
    %setpref('isetbioValidation', 'updateValidationHistory', true);
    %setpref('isetbioValidation', 'updateValidationHistory', false);
    %setpref('isetbioValidation', 'updateGroundTruth', true);
    %setpref('isetbioValidation', 'updateGroundTruth', false);
    
    %setpref('isetbioValidation', 'onRunTimeErrorBehavior', 'rethrowExemptionAndAbort');
    setpref('isetbioValidation', 'onRunTimeErrorBehavior', 'catchExemptionAndContinue');
    %setpref('isetbioValidation', 'generatePlots',  true); 
    %setpref('isetbioValidation', 'generatePlots',  false); 
    
    %setpref('isetbioValidation', 'verbosity', 'min');
    setpref('isetbioValidation', 'verbosity', 'low');
    %setpref('isetbioValidation', 'verbosity', 'med');
    %setpref('isetbioValidation', 'verbosity', 'high');
    %setpref('isetbioValidation', 'verbosity', 'max'); 
    
    
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