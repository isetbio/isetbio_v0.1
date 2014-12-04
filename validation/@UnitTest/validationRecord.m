% Method to append messages to the validationReport
function [report, validationFailedFlag, validationFundametalFailureFlag] = validationRecord(varargin)
    
    report = {};
    validationFailedFlag = false;
    
    persistent validationReport
    persistent validationFailedFlagVector
    persistent validationFundametalFailureVector
    
    % Parse inputs
    self.message                    = '';
    self.FUNDAMENTAL_CHECK_FAILED   = '';
    self.FAILED                     = '';
    self.PASSED                     = '';
    self.command                    = '';
    
    parser = inputParser;
    parser.addParamValue('command', self.command,     @ischar);
    parser.addParamValue('message', self.message,     @ischar);
    parser.addParamValue('FUNDAMENTAL_CHECK_FAILED',  self.FUNDAMENTAL_CHECK_FAILED, @ischar);
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
       validationFundametalFailureVector = [];
       return;
    end
    
    if  (strcmp(self.command, 'return'))
        for k = 1:numel(validationReport)
            report{k} = {validationReport{k}, validationFailedFlagVector(k), validationFundametalFailureVector(k)};
        end
        validationFailedFlag = any(validationFailedFlagVector);
        validationFundametalFailureFlag = any(validationFundametalFailureVector);
        return;
    end
    
    % Add a simple message (no flag attached)
    if  (~isempty(self.message))
        index = numel(validationReport)+1;
        validationReport{index}                  = self.message;
        validationFailedFlagVector(index)        = false;
        validationFundametalFailureVector(index) = false;
        return;
    end
    
    % Add new PASS message
    if (~isempty(self.PASSED))
        index = numel(validationReport)+1;
        validationReport{index}                  = self.PASSED;
        validationFailedFlagVector(index)        = false;
        validationFundametalFailureVector(index) = false;
        return;
    end
    
    % Add new FAIL message
    if (~isempty(self.FAILED))
        index = numel(validationReport)+1;
        validationReport{index}                  = self.FAILED;
        validationFailedFlagVector(index)        = true;
        validationFundametalFailureVector(index) = false;
        return;
    end
    
    % Add new FUNDAMENTAL FAIL message
    if (~isempty(self.FUNDAMENTAL_CHECK_FAILED))
        index = numel(validationReport)+1;
        validationReport{index}                  = self.FUNDAMENTAL_CHECK_FAILED;
        validationFailedFlagVector(index)        = true;
        validationFundametalFailureVector(index) = true;
        return;
    end
    
end

