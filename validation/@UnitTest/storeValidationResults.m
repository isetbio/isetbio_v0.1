function storeValidationResults(obj, varargin)
    % validate input params
    p = inputParser;
    p.addParamValue('validationReport',       @ischar);
    p.addParamValue('validationFailedFlag',   @islogical);
    p.addParamValue('validationData',        @isstruct);
    p.parse(varargin{:});
    
    % update object with new validation results
    obj.validationReport        = p.Results.validationReport;
    obj.validationFailedFlag    = p.Results.validationFailedFlag;
    obj.validationData          = p.Results.validationData;
end
