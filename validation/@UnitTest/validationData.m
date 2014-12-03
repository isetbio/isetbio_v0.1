function data = validationData(varargin)
    
    data = [];
    persistent validationData
    
    if ischar(varargin{1}) && ischar(varargin{2}) && (strcmp(varargin{1}, 'command')) && (strcmp(varargin{2}, 'init'))
        validationData = struct();
        return;
    end
    
    if ischar(varargin{1}) && ischar(varargin{2}) && (strcmp(varargin{1}, 'command')) && (strcmp(varargin{2}, 'return'))
        data = validationData;
        return;
    end
    
    % Parse inputs
    for k = 1:2:numel(varargin)
        fieldName = varargin{k};
        fieldValue = varargin{k+1};
        % make sure field does not already exist
        if ismember(fieldName, fieldnames(validationData))
            fprintf(2,'\tField ''%s'' already exists in the validationData struct. Its value will be overriden.\n', fieldName);
        end
        if (isnumeric(fieldValue))
            validationData.(fieldName) = round(fieldValue, UnitTest.decimalDigitNumRoundingForHashComputation);
        else
            validationData.(fieldName) = fieldValue;
        end
    end
         
end


    