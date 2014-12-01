function validationRunData = assembleResultsIntoValidationRunStuct(obj)

    validationRunData = struct();
    validationRunData.executiveScriptName       = obj.systemData.vScriptFileName;
    validationRunData.executiveScriptListing    = obj.systemData.vScriptListing;
    validationRunData.date                      = obj.systemData.datePerformed; 
    validationRunData.matlabVersion             = obj.systemData.matlabVersion;
    validationRunData.computerArchitecture      = obj.systemData.computer; 
    validationRunData.computerAddress           = obj.systemData.computerAddress;
    validationRunData.userName                  = obj.systemData.userName; 
    validationRunData.gitRepoBranch             = obj.systemData.gitRepoBranch; 
    validationRunData.sectionData               = obj.sectionData;
    
    for probeIndex = 1:numel(obj.allProbeData)
        % get data for each probe
        probeData = obj.allProbeData{probeIndex};
        
        % add validation script listing
        probeData.codeExecuted = fileread([probeData.functionName '.m']);
        
        % insert entry in validationRunData
        validationRunData.probeData{probeIndex} = probeData;
    end % for probeIndex
end
