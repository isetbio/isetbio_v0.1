% Method to initalize prefs for ISETBIO
function initializeISETBIOprefs()

    if ~(ispref('isetbioValidation', 'updateGroundTruth'))
        setpref('isetbioValidation', 'updateGroundTruth', false);
    end
    
    if ~(ispref('isetbioValidation', 'updateValidationHistory'))
        setpref('isetbioValidation', 'updateValidationHistory', false);
    end
    
    if (~ispref('isetbioValidation', 'onRunTimeErrorBehavior'))
        setpref('isetbioValidation', 'onRunTimeErrorBehavior',  'rethrowExemptionAndAbort'); 
    end
    
    if (~ispref('isetbioValidation', 'generatePlots'))
        setpref('isetbioValidation', 'generatePlots',  false); 
    end
    
    if (~ispref('isetbioValidation', 'verbosity'))
        setpref('isetbioValidation', 'verbosity',  'low'); 
    end
end
