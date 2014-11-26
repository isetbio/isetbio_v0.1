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
    UnitTest.initializeISETBIOprefs();
    % or to reset to the default prefs
    UnitTest.initializeISETBIOprefs('reset');
    
    % Change any preferences by uncommenting any of the following:
    %setpref('isetbioValidation', 'updateValidationHistory', true);
    %setpref('isetbioValidation', 'updateValidationHistory', false);
    %setpref('isetbioValidation', 'updateGroundTruth', true);
    %setpref('isetbioValidation', 'updateGroundTruth', false);
    
    %setpref('isetbioValidation', 'onRunTimeErrorBehavior', 'rethrowExemptionAndAbort');
    %setpref('isetbioValidation', 'onRunTimeErrorBehavior', 'catchExemptionAndContinue');
    %setpref('isetbioValidation', 'generatePlots',  true); 
    setpref('isetbioValidation', 'generatePlots',  false); 
    
    %setpref('isetbioValidation', 'verbosity', 'min');
    setpref('isetbioValidation', 'verbosity', 'low');
    %setpref('isetbioValidation', 'verbosity', 'med');
    %setpref('isetbioValidation', 'verbosity', 'high');
    %setpref('isetbioValidation', 'verbosity', 'max');
    
    
    % List of scripts to validate. Each entry contains a cell array with 
    % with a script name and an optional struct with
    % prefs that override the corresponding isetbioValidation prefs.
    % At the moment only the generatePlots pref can be overriden.
    vScriptsList = {...
        {'validateSceneReIllumination'} ...                                  % use ISETBIO prefs
        {'validateOTFandPupilSize',  struct('generatePlots', true) } ...   % override the ISETBIO pref for generatePlots
        {'PTB_vs_ISETBIO_Irradiance',  struct('generatePlots', true) } ...   % override the ISETBIO pref for generatePlots 
    };

    % Run a validation session without specifying a mode: we will be prompted to specify one
    UnitTest.runValidationSession(vScriptsList);
end