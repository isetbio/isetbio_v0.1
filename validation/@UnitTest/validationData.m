% Method to add new data to the validation data struct
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
        
        % save the full data
        validationData.(fieldName) = fieldValue;
        
        % save truncated data in hashData.(fieldName)
        if (isnumeric(fieldValue))
            validationData.hashData.(fieldName) = UnitTest.roundToNdigits(fieldValue, UnitTest.decimalDigitNumRoundingForHashComputation);
        elseif (isstruct(fieldValue))
            validationData.hashData.(fieldName) = roundStruct(fieldValue);
        elseif (iscell(fieldValue))
            validationData.hashData.(fieldName) = roundCellArray(fieldValue);
        else
            validationData.hashData.(fieldName) = fieldValue;
        end
 
    end
         
end

% Method to recursive round a struct
function s = roundStruct(oldStruct)

    s = oldStruct;
    
    if (isempty(s))
        return;
    end
    
    structFieldNames = fieldnames(s);
    for k = 1:numel(structFieldNames)
        
        % get field
        fieldValue = s.(structFieldNames{k});
        
        if isstruct(fieldValue)
            s.(structFieldNames{k}) = roundStruct(fieldValue);
        elseif ischar(fieldValue)
            s.(structFieldNames{k}) = fieldValue;
        elseif isnumeric(fieldValue)
            s.(structFieldNames{k}) = UnitTest.roundToNdigits(fieldValue, UnitTest.decimalDigitNumRoundingForHashComputation);
        elseif iscell(fieldValue)
            s.(structFieldNames{k}) = roundCellArray(fieldValue);
        else
            class(fieldValue)
            error('Do not know how to round this class type');
        end
    end
    
end


% Method to recursive round a cellArray
function cellArray = roundCellArray(oldCellArray)
    cellArray = oldCellArray;
    for k = 1:numel(cellArray)
        fieldValue = cellArray{k};
        
        % Char values
        if ischar(fieldValue )
             % do nothing
             
        % Numeric values
        elseif (isnumeric(fieldValue))
            cellArray{k} = UnitTest.roundToNdigits(fieldValue, UnitTest.decimalDigitNumRoundingForHashComputation);
        
        % Cells
        elseif (iscell(fieldValue))
            cellArray{k} = roundCellArray(fieldValue);
        else
            fprintf(2,'UnitTest.validatioData.roundCellArray: non-char, non-numeric cell array rounding not implemented\n');
        end
    end
end

    