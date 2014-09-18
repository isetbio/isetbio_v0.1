function pushToGithub


    % Local dir where validation docs live
    validationDocsCloneDir = '/Users/Shared/GitWebSites/ISETBIO/ISETBIO_ValidationDocs';
    % URL on remote where validation docs live
    validationDocsURL      = 'http://npcottaris.github.io/ISETBIO_ValidationDocs';

    % Local dir where the wiki is cloned to. This is where we store the ValidationResults.md file
    % with contains a the catalog of the validation runs and pointers to
    % the html files containing the code and results
    wikiCloneDir = '/Users/Shared/GitWebSites/ISETBIO/ISETBIO_ValidationDocs.wiki';
    
    % Name of the markup file containing the catalog of validation runs and
    % pointers to the corresponding html files.
    validationResultsCatalogFile = 'ValidationResults.md';
    
    % URL on remote where the validationResultsCatalogFile lives
    validationResultsCatalogFileURL = 'https://github.com/npcottaris/ISETBIO_ValidationDocs/wiki/ValidationResults';
    
    % Remove previous validationResultsCatalogFile
    system(['rm -rf ' fullfile(wikiCloneDir, validationResultsCatalogFile)]);
    
    % Open new validationResultsCatalogFile
    validationResultsCatalogFID = fopen(fullfile(wikiCloneDir, validationResultsCatalogFile),'w');
    
    
    % Empty all entries
    allEntries = [];
    
    % Add an entry
    entry.sectionLabelAndSubDirName = {'PTB vs ISETBIO', 'PTB_vs_ISETBIO'};
    entry.validationScriptFileName  = 'PTB_vs_ISETBIO_Irradiance';
    allEntries = [allEntries entry];
    
    % Determine name of validation root directory from the location of this script 
    [validationRootDirectory, ~, ~] = fileparts(mfilename('fullpath'));

    % Go through all entries
    for entryIndex = 1:numel(allEntries)
        % unload entry data
        sectionLabel            = allEntries(entryIndex).sectionLabelAndSubDirName{1};
        subDir                  = allEntries(entryIndex).sectionLabelAndSubDirName{2};
        validationScriptName    = allEntries(entryIndex).validationScriptFileName;
        
        % write section name
        fprintf(validationResultsCatalogFID,'\n##  %s \n', sectionLabel);
        
        % make subdir in local validationDocsCloneDir
        sectionWebDir = fullfile(validationDocsCloneDir, subDir,'');
        if (~exist(sectionWebDir,'dir'))
            mkdir(sectionWebDir);
        end
    
        % cd to validationRootDirectory/sectionSubDir
        cd(sprintf('%s/validationScripts/%s', validationRootDirectory, subDir));
           
        % synthesize the source HTML directory name
        sourceHTMLdir = sprintf('%s_HTML', validationScriptName);

        % synthesize the target HTML directory name
        targetHTMLdir = fullfile(validationDocsCloneDir, subDir, sourceHTMLdir, '');

        % remove any existing target HTML directory
        system(sprintf('rm -rf %s', targetHTMLdir));

        % copy source to target directory
        system(sprintf('cp -r -f %s %s',  sourceHTMLdir, targetHTMLdir));

        % get summary text from validation script.
        summaryText = getSummaryText(validationScriptName);

        % Add entry to validationResultsCatalogFile
        fprintf(validationResultsCatalogFID, '* [ %s ]( %s/%s/%s/%s.html) - %s\n',  validationScriptName, validationDocsURL, subDir, sourceHTMLdir, validationScriptName, summaryText);  
    end
    
    % Close the validationResultsCatalogFile
    fclose(validationResultsCatalogFID);

    % Now push stuff to git
    % ----------------- IMPORTANT NOTE FOR GIT PUSH TO WORK FROM MATLAB -----------------
    % Note: to make push work from withing MATLAB I had to change the
    % libcurl library found in /Applications/MATLAB_R2014a.app/bin/maci64
    % This is because MATLAB's libcurl does not have support for https
    % as evidenced by system('curl -V') which gives:
    % curl 7.30.0 (x86_64-apple-darwin13.0) libcurl/7.21.6
    % Protocols: dict file ftp gopher http imap pop3 smtp telnet tftp 
    % Features: IPv6 Largefile 
    % In contrast curl -V in a terminal window gives:
    % curl 7.30.0 (x86_64-apple-darwin13.0) libcurl/7.30.0 SecureTransport zlib/1.2.5
    % Protocols: dict file ftp ftps gopher http https imap imaps ldap ldaps pop3 pop3s rtsp smtp smtps telnet tftp 
    % Features: AsynchDNS GSS-Negotiate IPv6 Largefile NTLM NTLM_WB SSL libz 

    % To fix this, first backup the existing libcurl library:
    %   cd /Applications/MATLAB_R2014a.app/bin/maci64
    %   ls -al libcur*
    % This gives me:
    %   libcurl.4.dylib
    %   libcurl.dylib -> libcurl.4.dylib
    % so do the following:
    %   rm libcurl.dylib
    %   mv libcurl.4.dylib existing_libcurl.4.dylib
    % Then make soft links to the system's libcurl as follows:
    %   ln -s /usr/lib/libcurl.4.dylib libcurl.4.dylib
    %   ln -s /usr/lib/libcurl.4.dylib libcurl.dylib
    % After this, system('curl -V') shows support for https and 
    % system('git push') works fine.
    % ----------------- IMPORTANT NOTE FOR GIT PUSH TO WORK FROM MATLAB -----------------
    
    % First push the HTML validation datafiles
    fprintf('\n\n1. Pushing validation reports (HTML) to github ...\n');
    cd(validationDocsCloneDir);
    
    system('git config --global push.default matching');
    %system('git config --global push.default simple');
    
    % Pull first in case there are changes
    system('git pull');
    
    % Commit everything
    system('git commit -a -m "Validation results docs update";');
    
    % Push to remote
    system('git push');
    
    
    
    % Next update the wiki catalog of validation runs
    fprintf('\n\n2. Pushing catalog of validation reports to github ...\n');
    cd(wikiCloneDir);
    
    system('git config --global push.default matching');
    %system('git config --global push.default simple');
    
    % Pull first in case there are changes
    system('git pull');
    
    % Commit everything
    system('git commit -a -m "Validation results catalog update";');
    
    % Push to remote
    system('git push');
    
    % Open git web page with validation results for visualization. 
    % This may take a while to update.
    web(validationResultsCatalogFileURL);
   
    % Back to the root directory
    cd(validationRootDirectory);
   
end


function summaryText = getSummaryText(validationScriptName)

    % Open file
    fid = fopen(which(sprintf('%s.m',validationScriptName)),'r');

    % Throw away first two lines
    lineString = fgetl(fid);
    lineString = fgetl(fid);

    % Get line with function description (3rd lone)
    lineString = fgetl(fid);
    % Remove any comment characters (%)
    summaryText  = regexprep(lineString ,'[%]','');
    
end

