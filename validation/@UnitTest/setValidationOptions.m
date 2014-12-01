% Method to set certain validation options
function setValidationOptions(obj,varargin)
    
    % parse inputs
    parser = inputParser;
    parser.addParamValue('type',                    obj.validationParams.type,                    @ischar);
    parser.addParamValue('onRunTimeError',          obj.validationParams.onRunTimeErrorBehavior,  @ischar);
    parser.addParamValue('updateGroundTruth',       obj.validationParams.updateGroundTruth,       @islogical);
    parser.addParamValue('updateValidationHistory', obj.validationParams.updateValidationHistory, @islogical);

    % Execute the parser to make sure input is good
    parser.parse(varargin{:});
    % Copy the parse parameters to the ExperimentController object
    pNames = fieldnames(parser.Results);
    for k = 1:length(pNames)
       obj.validationParams.(pNames{k}) = parser.Results.(pNames{k}); 
    end
    
    % Ensure params have valid values
    checkValidationParams(obj.validationParams);
    
    % Ensure directories exist, and generate them if they do not
    obj.checkDirectories();    
end

function checkValidationParams(validationParams)
    if (~ismember(validationParams.onRunTimeError, UnitTest.validOnRunTimeErrorValues))
        fprintf(2,'\nValid ''onRunTimeError'' values are:\n');
        for k = 1:numel(UnitTest.validOnRunTimeErrorValues)
            fprintf(2,'''%s''\n', UnitTest.validOnRunTimeErrorValues{k})
        end
        fprintf('\n');
        error('''%s'' is an invalid ''onRunTimeError'' value', validationParams.onRunTimeError);
    end    
    
    if (~ismember(validationParams.type, UnitTest.validValidationTypes))
        fprintf(2,'\nValid validation ''types'' are:\n');
        for k = 1:numel(UnitTest.validValidationTypes)
            fprintf(2,'''%s''\n', UnitTest.validValidationTypes{k})
        end
        fprintf('\n');
        error('''%s'' is an invalid validation type', validationParams.type);
    end
end
