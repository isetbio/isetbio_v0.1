% Method to append messages to the validationReport
function report = validationRecord(varargin)
    
    report = [];
    persistent validationReport
    
    % Parse inputs
    self.appendMessage  = '';
    self.command  = '';
    
    parser = inputParser;
    parser.addParamValue('command',         self.command,     @ischar);
    parser.addParamValue('appendMessage',   self.appendMessage,  @ischar);

    % Execute the parser to make sure input is good
    parser.parse(varargin{:});
    % Copy the parse parameters to the ExperimentController object
    pNames = fieldnames(parser.Results);
    for k = 1:length(pNames)
       self.(pNames{k}) = parser.Results.(pNames{k}); 
    end
    
    if (strcmp(self.command, 'init'))
       validationReport = {};
       return;
    end
    
    if (strcmp(self.command, 'return'))
        report = validationReport;
        return;
    end
    
    % Add new message
    if (~isempty(self.appendMessage))
        index = numel(validationReport)+1;
        validationReport{index} = self.appendMessage;
    end
    
end

