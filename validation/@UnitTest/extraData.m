% Method to add new data to the extra data struct
function data = extraData(varargin)
    
    data = [];
    persistent extraData
    
    if ischar(varargin{1}) && ischar(varargin{2}) && (strcmp(varargin{1}, 'command')) && (strcmp(varargin{2}, 'init'))
        extraData = struct();
        return;
    end
    
    if ischar(varargin{1}) && ischar(varargin{2}) && (strcmp(varargin{1}, 'command')) && (strcmp(varargin{2}, 'return'))
        data = extraData;
        return;
    end
    
    % Parse inputs
    for k = 1:2:numel(varargin)
        fieldName = varargin{k};
        fieldValue = varargin{k+1};
        % make sure field does not already exist
        if ismember(fieldName, fieldnames(extraData))
            fprintf(2,'\tField ''%s'' already exists in the extraData struct. Its value will be overriden.\n', fieldName);
        end
        
        % add data to the struct
        extraData.(fieldName) = fieldValue;
    end 
end