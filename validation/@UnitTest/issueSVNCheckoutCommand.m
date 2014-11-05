function issueSVNCheckoutCommand(obj)
    
    % where the svn binary is located
    svnBinDirectory = obj.SVN_BIN_DIRECTORY;
    
    % SVN name and password for read/only access
    ISETBIO_SVN_Username = sprintf('isetbio');
    ISETBIO_SVN_password = sprintf('isetbio');
    
    % compose SVN checkout command
    resultsFile = 'svn_results.tmp';
    errorFile   = 'svn_errors.tmp';
    svnCheckOutCommand  = sprintf('(echo p | %s checkout  %s %s --username %s --password %s --trust-server-cert  --non-interactive  > %s) >& %s', svnBinDirectory, obj.ISETBIO_DataSets_SVN_URL, obj.ISETBIO_DataSets_Local_SVN_DIR, ISETBIO_SVN_Username, ISETBIO_SVN_password, resultsFile, errorFile);
    
    % Issue SVN export command. 
    feedbackMessage = sprintf('Issuing SVN checkout command for user: %s\n%s\n', ISETBIO_SVN_Username, svnCheckOutCommand);
    obj.emitMessage(feedbackMessage, UnitTest.MINIMUM_IMPORTANCE);
    system(svnCheckOutCommand);
    
    results = textread(resultsFile, '%s', 'whitespace', '');
    errors  = textread(errorFile, '%s', 'whitespace', '');
    
    if (numel(errors) > 0)
        fprintf('\nSVN checkout raised error(s) during checking out (see below).\n');
        for k = 1:numel(errors)
            fprintf('%s\n', char(errors{k}));
        end
    end
    
    if (numel(results) > 0)
        feedbackMessage = '';
        feedbackMessage = sprintf('%s\nSVN checkout results:\n', feedbackMessage);
        for k = 1:numel(results)
            feedbackMessage = sprintf('%s%s\n', feedbackMessage, char(results{k}));
        end
        obj.emitMessage(feedbackMessage, UnitTest.MINIMUM_IMPORTANCE);
    end
    
    % remove temporary svn files
    system('rm svn_results.tmp');
    system('rm svn_errors.tmp');
end