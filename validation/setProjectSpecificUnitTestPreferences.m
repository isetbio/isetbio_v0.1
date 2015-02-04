% Method to set ISETBIO-specific preferences. Generally, this script should be run once only.
function setProjectSpecificUnitTestPreferences

    p = struct(...
            'projectName',           'isetbioValidation', ...                                                                         % The project's name (also the preferences group name)
            'validationRootDir',     fullfile(isetbioRootPath, 'validation'), ...                                                     % The directory that contains the 'scripts' directory.
            'alternateFastDataDir',  '',  ...                                                                                         % Alternate FAST (hash) data directory location. Specify '' to use the default location, i.e., $validationRootDir/data/fast
            'alternateFullDataDir',  fullfile(filesep,'Users1', 'Shared', 'Dropbox', 'ISETBIOFullValidationData'), ...                % Alternate FULL data directory location. Specify '' to use the default location, i.e., $validationRootDir/data/full
            'clonedWikiLocation',    fullfile(filesep,'Users',  'Shared', 'Matlab', 'Toolboxes', 'ISETBIO_Wiki', 'isetbio.wiki'), ... % The local path to the directory where the wiki is cloned. This is only used for publishing tutorials.
            'clonedGhPagesLocation', fullfile(filesep,'Users',  'Shared', 'Matlab', 'Toolboxes', 'ISETBIO_GhPages', 'isetbio'), ...   % The local path to the directory where the gh-pages repository is cloned. This is only used for publishing tutorials.
            'githubRepoURL',         'http://isetbio.github.io/isetbio' ...                                                           % The github URL for the project. This is only used for publishing tutorials.
        );

    % remove any existing preferences for this project
    if ispref(p.projectName)
        rmpref(p.projectName);
    end
    
    % generate and save the project-specific preferences
    setpref(p.projectName, 'projectSpecificOptions', p);
    fprintf('Generated and saved preferences specific to the ''%s'' project.\n', p.projectName);
end