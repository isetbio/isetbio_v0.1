% Method to initalize prefs for ISETBIO
function initializePrefs(initMode)

    if (nargin == 0)
        initMode = 'none';
    end
    
    if ~(ispref('isetbioValidation', 'updateGroundTruth')) || (strcmp(initMode, 'reset'))
        setpref('isetbioValidation', 'updateGroundTruth', false);
    end
    
    if ~(ispref('isetbioValidation', 'updateValidationHistory'))  || (strcmp(initMode, 'reset'))
        setpref('isetbioValidation', 'updateValidationHistory', false);
    end
    
    if (~ispref('isetbioValidation', 'onRunTimeErrorBehavior'))  || (strcmp(initMode, 'reset'))
        setpref('isetbioValidation', 'onRunTimeErrorBehavior',  'rethrowExemptionAndAbort'); 
    end
    
    if (~ispref('isetbioValidation', 'generatePlots'))  || (strcmp(initMode, 'reset'))
        setpref('isetbioValidation', 'generatePlots',  false); 
    end
    
    if (~ispref('isetbioValidation', 'verbosity'))  || (strcmp(initMode, 'reset'))
        setpref('isetbioValidation', 'verbosity',  'low'); 
    end
end
