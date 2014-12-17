function vScriptsList = validateListAllValidationDirs
%
% This encapsulates a vull list of our validation directories, so we only
% need to update it in one place.\
% 
% Doesn't list the example scripts, and doesn't override any default prefs.
%
% ISETBIO Team (c) 2014

% List of script directories to validate. Each entry contains a cell array with 
% with a validation script directory and an optional struct with
% prefs that override the corresponding isetbioValidation prefs.
% At the moment only the 'generatePlots' pref can be overriden.
%        
vScriptsList = {...
            {'validationScripts/color' } ...
            {'validationScripts/cones'} ...
            {'validationScripts/human'} ...
            {'validationScripts/optics'} ...
            {'validationScripts/radiometry', } ...    
            {'validationScripts/scene' } ...    
        };
    
end