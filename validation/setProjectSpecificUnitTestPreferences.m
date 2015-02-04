% Method to set ISETBIO-specific preferences. Generally, this script should be run once only.
function setProjectSpecificUnitTestPreferences
    % set the project name
    projectName = 'isetbioValidation';
    
    % remove any existing preferences for this project
    if ispref(projectName)
        rmpref(projectName);
    end
    
    % generate and save the project-specific preferences
    setpref(projectName, 'projectSpecificOptions', generateISETbioSpecificPreferences);
    fprintf('Generated and saved preferences specific to the ''%s'' project.\n', projectName);
end

function p = generateISETbioSpecificPreferences
    % The root directory that contains the 'scripts' directory.
    p.validationRootDir = fullfile(isetbioRootPath, 'validation');
    
    % Alternate FAST (hash) data directory location. Specify '' to use the default location, i.e., $validationRootDir/data/fast
    p.alternateFastDataDir = '';
    
    % Alternate FULL data directory location. Specify '' to use the default location, i.e., $validationRootDir/data/full
    p.alternateFullDataDir = fullfile(filesep,'Users1', 'Shared', 'Dropbox', 'ISETBIOFullValidationData');
    
    % The local path to the directory where the wiki is cloned. This is only used for publishing tutorials.
    p.clonedWikiLocation = fullfile(filesep,'Users', 'Shared', 'Matlab', 'Toolboxes', 'ISETBIO_Wiki', 'isetbio.wiki');
    
    % The local path to the directory where the pages is cloned. This is only used for publishing tutorials.
    p.clonedGhPagesLocation = fullfile(filesep,'Users', 'Shared', 'Matlab', 'Toolboxes', 'ISETBIO_GhPages', 'isetbio');
    
    % The github URL for the project. This is only used for publishing tutorials.
    p.githubRepoURL = 'http://isetbio.github.io/isetbio';
end