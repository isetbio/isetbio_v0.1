function validateDependencies

  
    % list of scripts to run for dependency checking
    % just a few
    vScriptsList = {...
           {'v_IrradianceIsomerizations'} ...
           };
    % or all of them
    %vScriptsList = validateListAllValidationDirs;
       
    % List of non-native toolboxes to test dependency on
    nonNativeToolboxesToTest = { ...
        'Users/Shared/Matlab/Toolboxes/Psychtoolbox-3/' ...
    };

    % save original path
    originalPath = addpath('');
    
    
    % determine the required (native) matlab toolboxes
    requiredToolboxNames = testDependencies(vScriptsList, nonNativeToolboxesToTest);
    
    % print results
    if (numel(requiredToolboxNames) > 1)
        fprintf('\n The following %d toolboxes are required.', numel(requiredToolboxNames));
    elseif (numel(requiredToolboxNames) == 1)
        fprintf('\n The following %d toolbox is required.', numel(requiredToolboxNames));
    else
        fprintf('\n There are %d required toolboxes.', numel(requiredToolboxNames));
    end
    for k = 1:numel(requiredToolboxNames)
        fprintf('\n [%d] %s', k, requiredToolboxNames{k});
    end
    fprintf('\n');
    
    % restore original path
    path(originalPath);
end

function names = testDependencies(vScriptsList, nonNativeToolboxesToTest)

    UnitTest.setPref('verbosity', 'absolute zero');

    requiredToolboxesList = struct();
    requiredToolboxesList.toolboxNames = {};
    requiredToolboxesList.tooboxLocalDirs = {};
    
    % First, the non-native toolboxes
    for k = 1:numel(nonNativeToolboxesToTest)
        fprintf('\n [%2d] Running scripts without the %s toolbox. Please wait ... ', k, nonNativeToolboxesToTest{k});
        rmpath(genpath(nonNativeToolboxesToTest{k}));
        
        exeptionsRaised = checkForRunTimeErrors(vScriptsList);
        if (exeptionsRaised)
           message = sprintf(' %s is required.', nonNativeToolboxesToTest{k});
           fprintf(2, '%60s', message);
           ix = numel(requiredToolboxesList.toolboxNames)+1;
           requiredToolboxesList.toolboxNames{ix} = nonNativeToolboxesToTest{k};
           requiredToolboxesList.tooboxLocalDirs{ix} = nonNativeToolboxesToTest{k};
           addpath(genpath(requiredToolboxesList.tooboxLocalDirs{ix}));
        else
           message = sprintf(' %s is not required.', nonNativeToolboxesToTest{k});
           fprintf('%60s', message);
        end
       
    end
    
    
    % Then, the native toolboxes
    s = getListOfInstalledToolboxes(0);
    
    % turn off warnings for dirs not found
    warning off MATLAB:rmpath:DirNotFound
    
    fprintf('\n There are %d native toolboxes installed. Checking dependency on each one of them.\n', numel(s.tooboxLocalDirs));
    % Remove paths to all installed native toolboxes
    for k = 1:numel(s.tooboxLocalDirs)
       fprintf('\n [%2d] Running scripts without the %s. Please wait ... ', k, s.toolboxNames{k});
       rmpath(genpath(s.tooboxLocalDirs{k}));
        
       exeptionsRaised = checkForRunTimeErrors(vScriptsList);
       if (exeptionsRaised)
           message = sprintf(' %s is required.', s.toolboxNames{k});
           fprintf(2, '%60s', message);
           ix = numel(requiredToolboxesList.toolboxNames)+1;
           requiredToolboxesList.toolboxNames{ix} = s.toolboxNames{k};
           requiredToolboxesList.tooboxLocalDirs{ix} = s.tooboxLocalDirs{k};
           addpath(genpath(requiredToolboxesList.tooboxLocalDirs{ix}));
       else
           message = sprintf(' %s is not required.', s.toolboxNames{k});
           fprintf('%60s', message);
       end
    end
    
    fprintf('\n');
    % turn back on warnings for dirs not found
    warning on MATLAB:rmpath:DirNotFound
    
    names = requiredToolboxesList.toolboxNames;
end


function exeptionsRaised = checkForRunTimeErrors(vScriptsList)
    % Instantiate a @UnitTest object
    UnitTestOBJ = UnitTest();
        
    % Print the available validation options and their default values
    % UnitTest.describeValidationOptions();
    
    % Set options for RUNTIME_ERRORS_ONLY validation
    UnitTestOBJ.setValidationOptions(...
                'type',                     'RUNTIME_ERRORS_ONLY', ...
                'onRunTimeError',           getpref('isetbioValidation', 'onRunTimeErrorBehavior'), ...
                'updateGroundTruth',        false, ...
                'updateValidationHistory',  false ...
                );
            
    % ... and Go ! 
    UnitTestOBJ.validate(vScriptsList);
    
    exeptionsRaised = any(UnitTestOBJ.validationSessionRunTimeExceptions);
end



% Method that returns a cell array with the directories of a user-selected list of native toolboxes
function nativeToolboxesDirList = getSelectNativeToolboxesDirList()

    rehashAll();
    s = getListOfInstalledToolboxes(0);

    fprintf('\nInstalled native toolboxes:');
    for k = 1:numel(s.toolboxNames)
       fprintf('\n\t [%2d]. %s', k, s.toolboxNames{k});
    end
    
    indicesForRemoval = input('\nEnter toolboxes to remove as an array (e.g., [1 4 23]) : ');
    
    nativeToolboxesDirList = {};
    for k = 1:numel(indicesForRemoval)
        nativeToolboxesDirList{k} = s.tooboxLocalDirs{indicesForRemoval(k)};
    end
    
end

% Method to refresh caches etc.
function rehashAll
    rehash toolbox
    rehash pathreset 
    rehash toolboxreset
    rehash toolboxcache 
end



% Methof that returns a cell array with the directories corresponding to the installed native Matlab toolboxes
function s = getListOfInstalledToolboxes(beVerbose)
    %v = ver;
    %installedNativeToolboxNames = setdiff({v.Name}, {'MATLAB'})';

    % get names of all subdirs in $matlabroot/toolbox
    toolboxLocalDirs = dir(toolboxdir('') );
    
    notRelevantToolboxDirs = {'.', '..', 'matlab', 'local', 'shared', 'hdlcoder'};
    
    s.toolboxNames = {};
    s.tooboxLocalDirs = {};
    includedToolboxes = 0;
    
    if (nargin == 1) && (~isempty(beVerbose)) && (beVerbose == 1)
        fprintf('\nInstalled toolboxes and respective directories:');
    end
    for k = 1:numel(toolboxLocalDirs)
        if isempty(toolboxLocalDirs(k)) || ismember(toolboxLocalDirs(k).name, notRelevantToolboxDirs)
            continue;
        end
        if isfield(toolboxLocalDirs(k), 'name')
            toolboxInfo = ver(toolboxLocalDirs(k).name);
            if isempty(toolboxInfo)
               continue; 
            end
            includedToolboxes = includedToolboxes + 1;
            s.toolboxNames{includedToolboxes} = toolboxInfo.Name;
            s.tooboxLocalDirs{includedToolboxes} = sprintf('%s/%s', toolboxdir(''), toolboxLocalDirs(k).name);
            if (nargin == 1) && (~isempty(beVerbose)) && (beVerbose == 1)
                fprintf('\n[%2d]. %-40s %s', includedToolboxes, s.toolboxNames{includedToolboxes}, s.tooboxLocalDirs{includedToolboxes})
            end
        end
    end
    
    if (nargin == 1) && (~isempty(beVerbose)) && (beVerbose == 1)
        fprintf('\n');
    end
    
end

% Method to remove all non-native Matlab toolboxes from the current path
function removeNonNativeToolboxes(toolboxPath)
    fprintf('\nRemoving non-native toolboxes (%s). Be patient ...', toolboxPath);
    
    % turn off warnings for dirs not found
    warning off MATLAB:rmpath:DirNotFound
    
    % remove paths
    rmpath(genpath(toolboxPath));
    
%     pathAsCellArray = strread(genpath(toolboxPath),'%s','delimiter', pathsep);
%     for k = 1:numel(pathAsCellArray)
%             rmpath(pathAsCellArray{k});
%     end
    
    addpath('/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/PathUtilities');
    
    % turn on warnings for dirs not found
    warning on MATLAB:rmpath:DirNotFound
    fprintf(' Done.\n');
end


