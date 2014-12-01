% Method to print what validation options are available and their default values
function describeValidationOptions()
    fprintf('\nAvailable validation options and their default values:\n');
    for k = 1:numel(UnitTest.validationOptionNames)
        if ischar(UnitTest.validationOptionDefaultValues{k})
            fprintf('\t %-25s with default value: ''%s''\n', sprintf('''%s''', UnitTest.validationOptionNames{k}), UnitTest.validationOptionDefaultValues{k});
        else
            fprintf('\t %-25s with default value: %g\n', sprintf('''%s''', UnitTest.validationOptionNames{k}), UnitTest.validationOptionDefaultValues{k});
        end
    end
    fprintf('\n');
end