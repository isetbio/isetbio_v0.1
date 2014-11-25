% Method to append messages to the validationReport
function [report, validationFailedFlag] = validationRecord(varargin)
    
    report = {};
    validationFailedFlag = false;
    
    persistent validationReport
    persistent validationFailedFlagVector
    
    % Parse inputs
    self.message      = '';
    self.FAILED       = '';
    self.PASSED       = '';
    self.command      = '';
    
    parser = inputParser;
    parser.addParamValue('command', self.command,     @ischar);
    parser.addParamValue('message', self.message,     @ischar);
    parser.addParamValue('FAILED',  self.FAILED, @ischar);
    parser.addParamValue('PASSED',  self.PASSED, @ischar);
    
    
    % Execute the parser to make sure input is good
    parser.parse(varargin{:});
    % Copy the parse parameters to the ExperimentController object
    pNames = fieldnames(parser.Results);
    for k = 1:length(pNames)
       self.(pNames{k}) = parser.Results.(pNames{k}); 
    end
    
    
    if (strcmp(self.command, 'init'))
       validationReport = {};
       validationFailedFlagVector = [];
       return;
    end
    
    if  (strcmp(self.command, 'return'))
        for k = 1:numel(validationReport)
            report{k} = {validationReport{k}, validationFailedFlagVector(k)};
        end
        validationFailedFlag = any(validationFailedFlagVector);
        return;
    end
    
    % Add a simple message (no flag attached)
    if  (~isempty(self.message))
        index = numel(validationReport)+1;
        validationReport{index} = self.message;
        validationFailedFlagVector(index) = false;
        return;
    end
    
    % Add new PASS message
    if (~isempty(self.PASSED))
        index = numel(validationReport)+1;
        validationReport{index} = self.PASSED;
        validationFailedFlagVector(index) = false;
        return;
    end
    
    % Add new FAIL message
    if (~isempty(self.FAILED))
        index = numel(validationReport)+1;
        validationReport{index} = self.FAILED;
        validationFailedFlagVector(index) = true;
        return;
    end
end

