% Method to issue a git command with output capture
function issueGitCommand(obj, commandString)

    [status,cmdout] = system(commandString,'-echo');
    
    if (obj.validationParams.verbosity > 2)
        disp(cmdout)
    end
end
