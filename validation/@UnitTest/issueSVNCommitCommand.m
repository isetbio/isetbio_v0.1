% Method to commit the SVN_hosted ground truth data set
function issueSVNCommitCommand(obj, validationDataParamName)
  
    % where the svn binary is located
    svnBinDirectory = '/usr/bin/svn';
    
    % SVN name and password for users with read/write access
    ISETBIO_SVN_Username = sprintf('nicolas');
    ISETBIO_SVN_password = sprintf('mgl37psycho');
    
    % compose SVN checkout command
    resultsFile = 'svn_results.tmp';
    errorFile   = 'svn_errors.tmp';
    svnCommitCommand  = sprintf('(echo p | %s commit  -m "Auto commit by @UnitTest. Appended new ground truth data set (''%s'')." %s --username %s --password %s --trust-server-cert  --non-interactive  > %s) >& %s', svnBinDirectory, validationDataParamName, obj.ISETBIO_DataSets_Local_SVN_DIR, ISETBIO_SVN_Username, ISETBIO_SVN_password, resultsFile, errorFile);
    
    feedbackMessage = sprintf('Issuing SVN commit command for user: %s\n%s\n', ISETBIO_SVN_Username, svnCommitCommand);
    obj.emitMessage(feedbackMessage, UnitTest.MINIMUM_IMPORTANCE);
    system(svnCommitCommand);
    
    results = textread(resultsFile, '%s', 'whitespace', '');
    errors  = textread(errorFile, '%s', 'whitespace', '');
    
    if (numel(errors) > 0)
        fprintf('\nSVN commit raised error(s) during checking out (see below).\n');
        for k = 1:numel(errors)
            fprintf('%s\n', char(errors{k}));
        end
        fprintf(2, '\n Ground Truth Data Set History not updated on the remote SVN server\n');
    end
    
    if (numel(results) > 0)
        feedbackMessage = '';
        feedbackMessage = sprintf('%s\nSVN commit results:\n', feedbackMessage);
        for k = 1:numel(results)
            feedbackMessage = sprintf('%s%s\n', feedbackMessage, char(results{k}));
        end
        obj.emitMessage(feedbackMessage, UnitTest.MINIMUM_IMPORTANCE);
    end
    
    % remove temporary svn files
    system('rm svn_results.tmp');
    system('rm svn_errors.tmp');
    
    % finally remove the SVN directory
    system(sprintf('rm -r -f %s', obj.ISETBIO_DataSets_Local_SVN_DIR));
end
