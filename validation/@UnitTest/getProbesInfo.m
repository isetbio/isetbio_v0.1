function [sectionNames, functionNames] = getProbesInfo(obj)
    probesNum = numel(obj.allProbeData);
    sectionNames = {};
    functionNames = {};
    for pIndex = 1:probesNum
        probeStruct = obj.allProbeData{pIndex};
        sectionNames{pIndex} = probeStruct.functionSectionName;
        functionNames{pIndex} = probeStruct.functionName;
    end
end

