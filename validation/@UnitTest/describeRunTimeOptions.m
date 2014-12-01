% Method to print what runtime options are available and their default values
function describeRunTimeOptions()
    fprintf('\nAvailable runTime options and their default values:\n');
    for k = 1:numel(UnitTest.runTimeOptionNames)
        if ischar(UnitTest.runTimeOptionDefaultValues{k})
            fprintf('\t %-25s with default value: ''%s''\n', sprintf('''%s''',UnitTest.runTimeOptionNames{k}), UnitTest.runTimeOptionDefaultValues{k});
        else
            fprintf('\t %-25s with default value: %g\n', sprintf('''%s''',UnitTest.runTimeOptionNames{k}), UnitTest.runTimeOptionDefaultValues{k});
        end
    end
    fprintf('\n');
end