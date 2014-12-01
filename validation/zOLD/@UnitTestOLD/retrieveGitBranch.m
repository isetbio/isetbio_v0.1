function gitString = retrieveGitBranch(obj)

    [functionDirectory, ~, ~] = fileparts(which(obj.systemData.vScriptFileName));
    currentDir = pwd;
    cd(functionDirectory);
    
    % Execute git command to retrieve the repository name
    status = system('basename `git rev-parse --show-toplevel` > gitRepoName.txt');
    if (status ~= 0)
       error('Could not get git repo name'); 
    end
    % Execute git status command to retrieve the current branch
    status = system('git status -b --porcelain > gitBranch.txt');
    if (status ~= 0)
       error('Could not get git status'); 
    end
    
    % Import gitRepoName.txt
    fp = fopen('gitRepoName.txt');
    a = textscan(fp, '%s');
    fclose(fp);
    
    % Remove gitRepoName.txt
    status = system('rm gitRepoName.txt');
    if (status ~= 0)
       error('Could remove temp file'); 
    end
    
    % Form gitRepoNameString
    gitRepoNameString = '';
    for k = 1:numel(a)
        gitRepoNameString = [gitRepoNameString char(a{k})];
    end
    
    
    % Import gitBranch.txt
    fp = fopen('gitBranch.txt');
    a = textscan(fp, '%s');
    fclose(fp);
    
    % Remove gitReport.txt
    status = system('rm gitBranch.txt');
    if (status ~= 0)
       error('Could remove temp file'); 
    end
    
    % Form gitBranchString
    b = a{1};
    gitBranchString = char(b(2));
    
    % Form gitString
    gitString = sprintf('%s of %s', gitBranchString, gitRepoNameString);
    
    % go back to current dir
    cd(currentDir);
    
end
