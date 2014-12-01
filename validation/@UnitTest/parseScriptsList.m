% Method to parse the scripts list to ensure it is valid
function vScriptsList = parseScriptsList(obj, vScriptsToRunList)

    scriptListEntry = vScriptsToRunList{1};
    
    if (exist(scriptListEntry{1}, 'file')==2)
       % List of files, each with an optional runtime option
       vScriptsList = vScriptsToRunList;
    else 
        % Assume list of directories, each with an optional runtime option
        vScriptsList ={};
        totalScriptIndex = 0;
        
        for scriptDirectoryIndex = 1:numel(vScriptsToRunList) 
            
            % get the current entry
            scriptListEntry = vScriptsToRunList{scriptDirectoryIndex};
        
            % get the directory name
            scriptDirectoryName = scriptListEntry{1};
            
            % get the runtime options
            if (numel(scriptListEntry) == 2)
                scriptRunParams = scriptListEntry{2}; 
            else
                scriptRunParams = [];
            end
            
            % get the contents of the directory
            dirToList = sprintf('%s/%s/*.m',obj.rootDir,scriptDirectoryName);
            scriptsListInCurrentDirectory = dir(dirToList);
            
            % add all the scripts to the vScriptsList
            for scriptIndex = 1:numel(scriptsListInCurrentDirectory)
                totalScriptIndex = totalScriptIndex + 1;
                scriptName = scriptsListInCurrentDirectory(scriptIndex).name;
                vScriptsList{totalScriptIndex} = { scriptName(1:end-2), scriptRunParams};
            end
            
        end  % script directory index
    end
end
