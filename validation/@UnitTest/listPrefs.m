% Method to list the current isetbioValidation preferences
function listPrefs

    isetbioValidationPrefs = getpref('isetbioValidation');
    
    preferenceNames = fieldnames(isetbioValidationPrefs );
    fprintf('\n Current isetbioValidation prefs:\n');
    for k = 1:numel(preferenceNames)
        value = isetbioValidationPrefs.(preferenceNames{k});
        if ischar(value)
            fprintf('\t %-25s : ''%s''\n', sprintf('''%s''', preferenceNames{k}), value);
        elseif islogical(value)
            fprintf('\t %-25s : %s\n', sprintf('''%s''', preferenceNames{k}), logicalToString(value));
        else
            fprintf('\t %-25s : %g\n', sprintf('''%s''', preferenceNames{k}), value);
        end
    end
    fprintf('\n');
end

function str = logicalToString(value)
    if value
        str = 'true';
    else
        str = 'false';
    end
end

