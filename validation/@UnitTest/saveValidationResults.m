function saveValidationResults(obj)

    % System  data to save
    validationRun.executiveScriptName       = obj.systemData.vScriptFileName;
    validationRun.executiveScriptListing    = obj.systemData.vScriptListing;
    validationRun.date                      = obj.systemData.datePerformed; 
    validationRun.matlabVersion             = obj.systemData.matlabVersion;
    validationRun.computerArchitecture      = obj.systemData.computer; 
    validationRun.computerAddress           = obj.systemData.computerAddress;
    validationRun.gitRepoBranch             = obj.systemData.gitRepoBranch; 
    validationRun.sectionData               = obj.sectionData;

    
    % Individual probe data to save
    for pIndex = 1:numel(obj.allProbeData)
        probeData = obj.allProbeData{pIndex};
        
        if (~probeData.result.validationFailedFlag) && (~probeData.result.excemptionRaised)
            
            validationScriptListing = fileread([probeData.functionName '.m']);
            
            % save everything in probeData which is
            % probeData = 
%                    name: 'validation skeleton'
%     functionSectionName: 'z. Skeleton validation scripts'
%            functionName: 'validateSkeleton'
%          functionParams: [1x1 struct]  % input params to the validation script
%          onErrorReactBy: 'CatchExcemption'
%           publishReport: 1
%           generatePlots: 1
%                  result: [1x1 struct]
%                           .validationReport: 'Nothing to report.'
%                           .validationData: [1x1 struct] with whatever variables were added by the validation script 
%                           .validationFailedFlag: 0
%                           .excemptionRaised: 0
    
            
        else
            % Should we save any information for the failed probes ??
        end
    end
end
