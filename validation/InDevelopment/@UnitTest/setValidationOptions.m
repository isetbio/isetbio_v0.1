% Method to set certain validation options
function setValidationOptions(obj,varargin)
    
    % parse inputs
    parser = inputParser;
    parser.addParamValue('type',                obj.validationParams.type);
    parser.addParamValue('onRunTimeError',      obj.validationParams.onRunTimeError);
    parser.addParamValue('updateGroundTruth',   obj.validationParams.updateGroundTruth);

    % Execute the parser to make sure input is good
    parser.parse(varargin{:});
    % Copy the parse parameters to the ExperimentController object
    pNames = fieldnames(parser.Results);
    for k = 1:length(pNames)
       obj.validationParams.(pNames{k}) = parser.Results.(pNames{k}); 
    end
    
    if (~ismember(obj.validationParams.onRunTimeError, UnitTest.validOnRunTimeErrorValues))
        fprintf(2,'\nValid ''onRunTimeError'' values are:\n');
        for k = 1:numel(UnitTest.validOnRunTimeErrorValues)
            fprintf(2,'''%s''\n', UnitTest.validOnRunTimeErrorValues{k})
        end
        fprintf('\n');
        error('''%s'' is an invalid ''onRunTimeError'' value', obj.validationParams.onRunTimeError);
    end    
    
    if (~ismember(obj.validationParams.type, UnitTest.validValidationTypes))
        fprintf(2,'\nValid validation ''types'' are:\n');
        for k = 1:numel(UnitTest.validValidationTypes)
            fprintf(2,'''%s''\n', UnitTest.validValidationTypes{k})
        end
        fprintf('\n');
        error('''%s'' is an invalid validation type', obj.validationParams.type);
    end
    
end
