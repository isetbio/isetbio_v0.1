function cleanUp(obj)
    % remove the SVN directory
    if (isdir(obj.ISETBIO_DataSets_Local_SVN_DIR))
        system(sprintf('rm -r -f %s', obj.ISETBIO_DataSets_Local_SVN_DIR));
    end
    
    % Directory for ISETBIO - gh-pages branch 
    ISETBIO_gh_pages_CloneDir = obj.ISETBIO_gh_pages_CloneDir;
    
    % Directory where all validation HTML docs will be moved to
    validationDocsDir  = sprintf('%s/validationdocs', ISETBIO_gh_pages_CloneDir);
    
    % Local dir where the ISTEBIO wiki is cloned to. This is where we store the ValidationResults.md file
    % with contains a the catalog of the validation runs and pointers to
    % the html files containing the code and results
    % wikiCloneDir = '/Users/Shared/GitWebSites/ISETBIO/ISETBIO_ValidationDocs.wiki';
    wikiCloneDir = obj.ISETBIO_wikiCloneDir;
    
    % Name of the markup file containing the catalog of validation runs and
    % pointers to the corresponding html files.
    validationResultsCatalogFile = 'ValidationResults.md';
    
    % Remove previous validationResultsCatalogFile
    
    resultsCatalogFile = fullfile(wikiCloneDir, validationResultsCatalogFile);
    if (exist(resultsCatalogFile) == 2)
        system(['rm -rf ' fullfile(wikiCloneDir, validationResultsCatalogFile)]);
    end
    

    sectionNames = keys(obj.sectionData);
    for sectionIndex = 1:numel(sectionNames)
        
        % write sectionName
        sectionName = sectionNames{sectionIndex};
     
        % Write section info text
        functionNames = obj.sectionData(sectionName);
        if (isempty(functionNames))
             continue;
        end
        
        [validationScriptDirectory, ~, ~] = fileparts(which(sprintf('%s.m', char(functionNames{1}))));
        cd(validationScriptDirectory);
        
        for functionIndex = 1:numel(functionNames)
            validationScriptName = sprintf('%s', char(functionNames{functionIndex}));
            [validationScriptDirectory, ~, ~] = fileparts(which(validationScriptName));
            seps = strfind(validationScriptDirectory, '/');
            validationScriptSubDir = validationScriptDirectory(seps(end)+1:end);
            
            % make subdir in local validationDocsDir 
            sectionWebDir = fullfile(validationDocsDir , validationScriptSubDir,'');
            if (exist(sectionWebDir,'dir'))
                system(sprintf('rm -r -f %s', sectionWebDir));
            end
        
            % cd to validationScriptDirectory
            cd(sprintf('%s', validationScriptDirectory));
        
            % synthesize the source HTML directory name
            sourceHTMLdir = sprintf('%s_HTML', validationScriptName);
        
            % synthesize the target HTML directory name
            targetHTMLdir = fullfile(validationDocsDir , validationScriptSubDir, sourceHTMLdir, '');
        
            if (isdir(targetHTMLdir))
                % remove any existing target HTML directory
                system(sprintf('rm -rf %s', targetHTMLdir));
            end
            
            if (isdir(sourceHTMLdir))
                % rm source to target directory
                system(sprintf('rm -rf %s',  sourceHTMLdir));
            end
        end
    end % sectionIndex
    
    cd(validationDocsDir);
end