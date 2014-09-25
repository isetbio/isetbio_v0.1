function result  = compareStructs(struct1Name, struct1, struct2Name, struct2, probeName, tolerance)

    result = {};
    result = recursivelyCompareStructs(struct1Name, struct1, struct2Name, struct2, probeName, tolerance, result);
end

function result = recursivelyCompareStructs(struct1Name, struct1, struct2Name, struct2, probeName, tolerance, oldResult)

    result = oldResult;
    
    if (isempty(struct1)) && (isempty(struct2))
        return;
    elseif (isempty(struct1)) && (~isempty(struct2))
        resultIndex = numel(result)+1;
        result{resultIndex} = sprintf('Probe ''%ss'':\n\t\t''%s'' is empty whereas ''%s'' is not. Will not compare further.\n', probeName, struct1Name, struct2Name);
        return;
    elseif (~isempty(struct1)) && (isempty(struct2))
        resultIndex = numel(result)+1;
        result{resultIndex} = sprintf('Probe ''%s'':\n\t\t''%s'' is not empty whereas ''%s'' is empty. Will not compare further.\n', probeName, struct1Name, struct2Name);
        return;
    end
    
    % Check for non-struct inputs
    if (~isstruct(struct1)) 
        resultIndex = numel(result)+1;
        result{resultIndex} = sprintf('Probe ''%s'':\n\t\t''%s'' is not a struct. Will not compare further. \n', probeName, struct1Name);
        return;
    end
    
    if (~isstruct(struct1)) 
        resultIndex = numel(result)+1;
        result{resultIndex} = sprintf('Probe ''%s'':\n\t\t''%s'' is not a struct. Will not compare further.\n', probeName, struct2Name);
        return;
    end
    
    % OK, inputs are good structs so lets continue with their fields
    struct1FieldNames = sort(fieldnames(struct1));
    struct2FieldNames = sort(fieldnames(struct2));
    
    % Check that the two structs have same number of fields
    if numel(struct1FieldNames) ~= numel(struct2FieldNames)
        resultIndex = numel(result)+1;
        result{resultIndex} = sprintf('Probe ''%s'':\n\t\t''%s'' has %d fields, whereas ''%s'' has %d fields. Will not compare further.\n', probeName, struct1Name, numel(struct1FieldNames), struct2Name, numel(struct2FieldNames));
        return;
    end
    
    
    for k = 1:numel(struct1FieldNames)
        
        % Check that the two structs have the same field names
       if (strcmp(struct1FieldNames{k}, struct2FieldNames{k}) == 0)
            resultIndex = numel(result)+1;
            result{resultIndex} = sprintf('Probe ''%s'':\n\t\t''%s'' and ''%s'' have different field names: %s vs %s. Will not compare further.\n', probeName, struct1Name, struct2Name, field1Name{k}, field2Name{k});
            return;
       end
    
       field1Name = sprintf('%s.%s', struct1Name, struct1FieldNames{k});
       field2Name = sprintf('%s.%s', struct2Name, struct2FieldNames{k});
       
       field1 = [];
       field2 = [];
       eval(sprintf('field1 = struct1.%s;', struct1FieldNames{k}));
       eval(sprintf('field2 = struct2.%s;', struct2FieldNames{k}));
       
       % compare structs
       if isstruct(field1)
           if isstruct(field2)
                result = recursivelyCompareStructs(field1Name, field1, field2Name, field2, probeName, tolerance, result);
           else
                resultIndex = numel(result)+1;
                result{resultIndex} = sprintf('Probe ''%s'':\n\t\t''%s'' is a struct but ''%s'' is not.\n', probeName, field1Name, field2Name);
           end
          
       % compare strings
       elseif ischar(field1)
           if ischar(field2)
               if (~strcmp(field1, field2))
                    resultIndex = numel(result)+1;
                    result{resultIndex} = sprintf('Probe ''%s'':\n\t\t''%s'' and ''%s'' are different: ''%s'' vs. ''%s''.\n', probeName, field1Name, field2Name, field1, field2);
               end
           else
                resultIndex = numel(result)+1;
                result{resultIndex} = sprintf('Probe ''%s'':\n\t\t''%s'' is a char string but ''%s'' is not.\n', probeName, field1Name, field2Name);
           end
           
       % compare  numerics   
       elseif isnumeric(field1)
           if isnumeric(field2)
               if (ndims(field1) ~= ndims(field2))
                   resultIndex = numel(result)+1;
                   result{resultIndex} = sprintf('Probe ''%s'':\n\t\t''%s'' is a %d-D numeric whereas ''%s'' is a %d-D numeric.\n', probeName, field1Name, ndims(field1), field2Name, ndims(field2));
               else 
                   if (any(size(field1)-size(field2)))
                        resultIndex = numel(result)+1;
                        result{resultIndex} = sprintf('Probe ''%s'':\n\t\t''%s'' is a %4g matrix whereas ''%s'' is a %4g matrix.\n', probeName, field1Name, size(field1), field2Name, size(field2));
                   else
                       % equal size numerics
                       if (any(abs(field1(:)-field2(:)) > tolerance))
                            resultIndex = numel(result)+1;
                            result{resultIndex} = sprintf('Probe ''%s'':\n\t\t''%s'' and ''%s'' difference exceeds the set tolerance (%g).\n', probeName, field1Name, field2Name, tolerance);
                       end
                   end
               end
           else
               resultIndex = numel(result)+1;
               result{resultIndex} = sprintf('Probe ''%s'':\n\t\t''%s'' is a numeric but ''%s'' is not.\n', probeName, field1Name, field2Name);
           end
           
       % compare cells
       elseif iscell(field1)
           if iscell(field2)
               resultIndex = numel(result)+1;
               result{resultIndex} = sprintf('Probe ''%s'':\n\t\t''%s'' is a cell but ''%s'' is not.\n', probeName, field1Name, field2Name);
           else
               fprintf(2, '\n cells comparison not implemented yet \n');
           end
       end
       
    end  % for k
       
end

