% Method to initialize the instantiated @UnitTest object
function initializeUnitTest(obj)
    % setup default validation params
    for k = 1:numel(UnitTest.validationOptionNames)
        eval(sprintf('obj.defaultValidationParams.%s = UnitTest.validationOptionDefaultValues{k};', UnitTest.validationOptionNames{k}));
    end

    % setup default directories
    pathToUnitTestDir = fileparts(which('UnitTest'));
    indices     = strfind(pathToUnitTestDir, '/');
    obj.rootDir = pathToUnitTestDir(1:indices(end)-1);
    obj.htmlDir = sprintf('%s/HTMLpublishedData', obj.rootDir);
    obj.validationDataDir = sprintf('%s/validationData', obj.rootDir);
    
    % initialize validation params to default params
    obj.validationParams = obj.defaultValidationParams;
    
    % initialize verbosity based on isetbioValidation prefs
    verbosity = getpref('isetbioValidation', 'verbosity');
    if (ismember(verbosity, UnitTest.validVerbosityLevels))
       obj.validationParams.verbosity = find(strcmp(verbosity,UnitTest.validVerbosityLevels)==1)-1;
    else
       error('Verbosity level ''%s'', not recognized', verbosity); 
    end
        
    % initialize numeric tolerance based on isetbioValidation prefs
    obj.validationParams.numericTolerance = getpref('isetbioValidation', 'numericTolerance');
    
    % initialize mismatch data graphing
    obj.validationParams.graphMismatchedData = getpref('isetbioValidation', 'graphMismatchedData');
    
    obj.dataMismatchFigNumber = UnitTest.minFigureNoForMistmatchedData;
end
