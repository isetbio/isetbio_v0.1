function saveProbesInfo(obj)

    % save current directory
    currentDir = pwd;
    
    % go to root directory
    [functionDirectory, ~, ~] = fileparts(which(obj.systemData.vScriptFileName));
    cd(functionDirectory);
    
    % get names
    [sectionNames, validationScriptFileNames] = obj.getProbesInfo();
    
    % save names
    save('ValidationProbesRun.mat', 'sectionNames', 'validationScriptFileNames');
    
    % go back to current directory
    cd(currentDir);
end

