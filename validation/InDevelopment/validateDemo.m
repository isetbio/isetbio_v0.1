function validateDemo
    clc
    
    % Print the available runtime options and their default values
    UnitTest.describeRunTimeOptions();
    
    % List of scripts to validate. Each entry contains a cell array with a
    % script name and an optional struct with runtime options.
    vScriptsList = {...
        {'validateSceneReIllumination'} ...                                                 % use default run-time options
        {'validateSceneReIllumination',        struct('generatePlots', true)} ...           % specify the generatePlots runtime option
        {'validateSceneReIlluminationAndFail', struct('printValidationReport', true)} ...   % specify the printValidationReport runtime option
    };

    selectValidationRun(vScriptsList);
end


function selectValidationRun(vScriptsList)
    fprintf('\nAvailable validation run types:');
    fprintf('\n\t 1. FAST');
    fprintf('\n\t 2. FULL');
    fprintf('\n\t 3. PUBLISH');
    typeID = input('\nEnter type of validation run [default = 1(FAST)] : ', 's');

    if (str2double(typeID) == 1) || (strcmp(typeID,''))
        validateFast(vScriptsList);
    elseif (str2double(typeID) == 2)
        validateFull(vScriptsList);
    elseif (str2double(typeID) == 3)
        validatePublish(vScriptsList);
    else
        fprintf('Invalid selection. Run again.\n');
        return;
    end
end

function validateFast(vScriptsList)
    
    % Instantiate a @UnitTest object
    UnitTestOBJ = UnitTest();
    
    % Print the available validation options and their default values
    UnitTest.describeValidationOptions();
    
    % Choose runtime error behavior
    onRunTimeErrorBehavior= 'catchExemptionAndContinue';       % do not abort validation run if one script fails
    % onRunTimeErrorBehavior = 'rethrowExemptionAndAbort';        % abort validation run if one script fails
    
    % Set options for fast validation
    UnitTestOBJ.setValidationOptions(...
                'type',             'FAST', ...
                'onRunTimeError',    onRunTimeErrorBehavior, ...
                'updateGroundTruth', true);
       
    % ... and Go ! 
    UnitTestOBJ.validate(vScriptsList);
end

function validateFull(vScriptsList)
    
    % Instantiate a @UnitTest object
    UnitTestOBJ = UnitTest();
    
    % Print the available validation options and their default values
    UnitTest.describeValidationOptions();
    
    % Choose runtime error behavior
    onRunTimeErrorBehavior = 'catchExemptionAndContinue';        % do not abort validation run if one script fails
    %onRunTimeErrorBehavior = 'rethrowExemptionAndAbort';        % abort validation run if one script fails
    
    % Set validation options
    UnitTestOBJ.setValidationOptions(...
                'type',             'FULL', ...
                'onRunTimeError',    onRunTimeErrorBehavior , ...
                'updateGroundTruth', true);
       
    % ... and Go ! 
    UnitTestOBJ.validate(vScriptsList);    
end


function validatePublish(vScriptsList)

    % Instantiate a @UnitTest object
    UnitTestOBJ = UnitTest();
    
    % Print the available validation options and their default values
    UnitTest.describeValidationOptions();
    
    % Choose runtime error behavior
    % In publish mode we want to abort if an exemption is raised
    %onRunTimeErrorBehavior= 'catchExemptionAndContinue';       % do not abort validation run if one script fails
    onRunTimeErrorBehavior = 'rethrowExemptionAndAbort';        % abort validation run if one script fails
    
    
    % Set validation options: 
    UnitTestOBJ.setValidationOptions(...
                'type',             'PUBLISH', ...
                'onRunTimeError',    onRunTimeErrorBehavior, ...
                'updateGroundTruth', false);
       
    % ... and Go ! 
    UnitTestOBJ.validate(vScriptsList);       
end
