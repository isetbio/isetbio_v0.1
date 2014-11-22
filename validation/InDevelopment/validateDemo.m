function validateDemo
    
    % Uncomment to see the available runtime options and their default values
    % UnitTest.describeRunTimeOptions();
    
    % Uncomment to cleanup generated HTML and validationData directories
    UnitTest.cleanUp();
    
    % Example1. Here we pass a list of scripts to validate. Each entry contains a cell array with a
    % script name and an optional struct with runtime options.
    vScriptsList = {...
        {'validateSceneReIllumination'} ...          % use default run-time options
        {'validateSceneReIllumination',  struct('generatePlots', true) } ...          % specify the generatePlots runtime option
        {'validateSceneReIlluminationAndFail'} ...   
    };

%    UnitTest.runValidationSession(vScriptsList);

    
    % Example 2. Here we pass a list of script directories to validate. Each entry contains a cell
    % array with a directory containing validation scripts and an optional stuct with
    % runtime options
    vScriptsList = {...
        {'validationScripts/PTB_vs_ISETBIO' } ...           % specify the generatePlots runtime option
   %     {'validationScripts/Scene', []} ...
    };

    % Available validation modes:
    % RUN_TIME_ERRORS_ONLY  - runtime errors only
    % FAST                  - runtime errors + data hash comparison
    % FULL                  - runtime errors + full data comparison
    % PUBLISH               - runtime errors + github wiki update
    % If a second argument (validation mode) is not passed, the code will prompt you for one.
    
    UnitTest.runValidationSession(vScriptsList, 'RUN_TIME_ERRORS_ONLY');
    UnitTest.runValidationSession(vScriptsList, 'FULL');
    
    vScriptsList = {...
        {'validationScripts/PTB_vs_ISETBIO', struct('generatePlots', true)  } ...           % specify the generatePlots runtime option
   %     {'validationScripts/Scene', []} ...
    };

    UnitTest.runValidationSession(vScriptsList, 'PUBLISH');
    
end