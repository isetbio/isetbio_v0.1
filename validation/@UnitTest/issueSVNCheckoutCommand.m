function issueSVNCheckoutCommand(obj)
    
    % where the svn binary is located
    svnBinDirectory = '/usr/bin/svn';
    
    % SVN name and password for read/only access
    ISETBIO_SVN_Username = sprintf('isetbio');
    ISETBIO_SVN_password = sprintf('isetbio');
    
    % compose SVN checkout command
    resultsFile = 'svn_results.tmp';
    errorFile   = 'svn_errors.tmp';
    svnCheckOutCommand  = sprintf('(echo p | %s checkout  %s %s --username %s --password %s --trust-server-cert  --non-interactive  > %s) >& %s', svnBinDirectory, obj.ISETBIO_DataSets_SVN_URL, obj.ISETBIO_DataSets_Local_SVN_DIR, ISETBIO_SVN_Username, ISETBIO_SVN_password, resultsFile, errorFile);
    
    % Issue SVN export command. 
    fprintf('Issuing SVN checkout command for user: %s\n%s\n', ISETBIO_SVN_Username, svnCheckOutCommand);
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
        fprintf('\nSVN checkout results:\n');
        for k = 1:numel(results)
            fprintf('%s\n', char(results{k}));
        end
    end
    
    % remove temporary svn files
    system('rm svn_results.tmp');
    system('rm svn_errors.tmp');
end