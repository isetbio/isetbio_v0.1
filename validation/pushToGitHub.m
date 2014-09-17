function pushToGithub

    % This is work in progress. Not ready to be tested yet.
    disp('This is work in progress. Not ready to be tested yet.');
    
    % Publish to github
    % Web site target
    webTargetDir = '/Users/Shared/GitWebSites/ISETBIO/ISETBIO_ValidationDocs';
    wikiBaseURL  = 'http://npcottaris.github.io/ISETBIO_ValidationDocs/';

    % Wiki target
    wikiTargetDir = '/Users/Shared/GitWebSites/ISETBIO/ISETBIO_ValidationDocs.wiki'
    wikiValidationResultsFile = 'ValidationResults.md';
    
    wikiValidationResultsURL = 'https://github.com/npcottaris/ISETBIO_ValidationDocs/wiki/ValidationResults';
    
    % Remove previous wikiAddedFile
    system(['rm -rf ' fullfile(wikiTargetDir, wikiValidationResultsFile)]);
    
    % Open wikiAddedFile
    wikiFID = fopen(fullfile(wikiTargetDir, wikiValidationResultsFile),'w');
    
    % Counters and accumulators
    sections = [];

    % Add the PTB vs ISETBIO section
    sectionsNum = numel(sections) + 1;
    sections(sectionsNum).label   = 'PTB vs ISETBIO';
    sections(sectionsNum).subDir = 'PTB_vs_ISETBIO';
    
    % Add all validation scripts in this section
    sections(sectionsNum).validationScriptNames = {...
        'PTB_vs_ISETBIO_Irradiance' ...
    };

    % Determine name of validation root directory from the location of this script 
    [validationRootDirectory, ~, ~] = fileparts(mfilename('fullpath'));
    

    % Go through all sections and update webTargetDir
    for sectionIndex = 1:numel(sections)
        subDir                  = sections(sectionIndex).subDir;
        sectionLabel            = sections(sectionIndex).label;
        validationScriptNames   = sections(sectionIndex).validationScriptNames;
        
        % Write section name
        fprintf(wikiFID,['\n## ' sectionLabel '\n']);
        
        % make subdir in local webTargetDir
        sectionWebDir = fullfile(webTargetDir, subDir,'');
        if (~exist(sectionWebDir,'dir'))
            mkdir(sectionWebDir);
        end
    
        % Cd to validationRootDirectory/sectionSubDir
        cd(sprintf('%s/validationScripts/%s', validationRootDirectory, subDir));
        
        % Go through all validation script _HTML directories and move them
        % to the webTargetDir
        for k = 1:numel(validationScriptNames)
            
            validationScriptName = validationScriptNames{k};
            
            % synthesize the source HTML directory name
            sourceHTMLdir = sprintf('%s_HTML', validationScriptName);
            
            % synthesize the target HTML directory name
            targetHTMLdir = fullfile(webTargetDir, subDir, sourceHTMLdir, '');
            
            % remove any existing target HTML directory
            system(sprintf('rm -rf %s', targetHTMLdir));
            
            % copy source to target directory
            system(sprintf('cp -r -f %s %s',  sourceHTMLdir, targetHTMLdir));

            % Add to wiki validation results file
            summaryText = 'Blah blah';
            fprintf(wikiFID,['* [' validationScriptName '](' wikiBaseURL subDir '/' sourceHTMLdir '/' validationScriptName '.html) - ' summaryText '\n']);
             
        end
        
    end
    
    % Close wikiAddedFile
    fclose(wikiFID);

    % Now push to git
    % First the wiki stuff
    cd(wikiTargetDir);
    system('git commit -a -m "Autopublish";');
    system('git push');
    
    cd(webTargetDir);
    system('git commit -a -m "Autopublish";');
    system('git push');

    cd(validationRootDirectory);
    
    % Open git web page with validation results
    web(wikiValidationResultsURL);
   
end
