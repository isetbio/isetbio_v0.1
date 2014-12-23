% Method to append messages to the validationReport
function [report, validationFailedFlag, validationFundamentalFailureFlag] = validationRecord(varargin)
    
    report = {};
    validationFailedFlag = false;
    
    persistent validationReport
    persistent validationFailedFlagVector
    persistent validationFundamentalFailureVector
    
    % Parse inputs
    self.SIMPLE_MESSAGE             = '';
    self.FUNDAMENTAL_CHECK_FAILED   = '';
    self.FAILED                     = '';
    self.PASSED                     = '';
    self.command                    = '';
    
    parser = inputParser;
    parser.addParamValue('command', self.command, @ischar);
    parser.addParamValue('SIMPLE_MESSAGE', self.SIMPLE_MESSAGE, @ischar);
    parser.addParamValue('FUNDAMENTAL_CHECK_FAILED', self.FUNDAMENTAL_CHECK_FAILED, @ischar);
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
       validationFundamentalFailureVector = [];
       return;
    end
    
    if  (strcmp(self.command, 'return'))
        for k = 1:numel(validationReport)
            report{k} = {validationReport{k}, validationFailedFlagVector(k), validationFundamentalFailureVector(k)};
        end
        validationFailedFlag = any(validationFailedFlagVector);
        validationFundamentalFailureFlag = any(validationFundamentalFailureVector);
        return;
    end
    
    % Add a simple message (no flag attached)
    if  (~isempty(self.SIMPLE_MESSAGE))
        index = numel(validationReport)+1;
        validationReport{index}                  = self.SIMPLE_MESSAGE;
        validationFailedFlagVector(index)        = false;
        validationFundamentalFailureVector(index) = false;
        return;
    end
    
    % Add new PASS message
    if (~isempty(self.PASSED))
        index = numel(validationReport)+1;
        validationReport{index}                  = self.PASSED;
        validationFailedFlagVector(index)        = false;
        validationFundamentalFailureVector(index) = false;
        return;
    end
    
    % Add new FAIL message
    if (~isempty(self.FAILED))
        index = numel(validationReport)+1;
        validationReport{index}                  = self.FAILED;
        validationFailedFlagVector(index)        = true;
        validationFundamentalFailureVector(index) = false;
        return;
    end
    
    % Add new FUNDAMENTAL FAIL message
    if (~isempty(self.FUNDAMENTAL_CHECK_FAILED))
        index = numel(validationReport)+1;
        validationReport{index}                  = self.FUNDAMENTAL_CHECK_FAILED;
        validationFailedFlagVector(index)        = true;
        validationFundamentalFailureVector(index) = true;
        return;
    end
    
end

