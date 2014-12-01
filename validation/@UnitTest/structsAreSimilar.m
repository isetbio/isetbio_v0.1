function structsAreSimilarWithinSpecifiedTolerance = structsAreSimilar(obj, groundTruthData, validationData)

    tolerance           = obj.validationParams.numericTolerance;
    graphMismatchedData = obj.validationParams.graphMismatchedData;

    result = {};
    result = recursivelyCompareStructs('groundTruthData', groundTruthData, ...
                                       'validationData', validationData, ...
                                       tolerance, graphMismatchedData, result);
                                   
    if (isempty(result))
        structsAreSimilarWithinSpecifiedTolerance = true;
    else
       for k = 1:numel(result)
          fprintf(2,'\t[data mismatch %2d]   : %s\n ', k, char(result{k}));
       end
       structsAreSimilarWithinSpecifiedTolerance = false;
    end
    
    
end

function result = recursivelyCompareStructs(struct1Name, struct1, struct2Name, struct2, tolerance, graphMismatchedData, oldResult)

    result = oldResult;
    
    if (isempty(struct1)) && (isempty(struct2))
        return;
    elseif (isempty(struct1)) && (~isempty(struct2))
        resultIndex = numel(result)+1;
        result{resultIndex} = sprintf('''%s'' is empty whereas ''%s'' is not. Will not compare further.', struct1Name, struct2Name);
        return;
    elseif (~isempty(struct1)) && (isempty(struct2))
        resultIndex = numel(result)+1;
        result{resultIndex} = sprintf('''%s'' is not empty whereas ''%s'' is empty. Will not compare further.', struct1Name, struct2Name);
        return;
    end
    
    % Check for non-struct inputs
    if (~isstruct(struct1)) 
        resultIndex = numel(result)+1;
        result{resultIndex} = sprintf('''%s'' is not a struct. Will not compare further.', struct1Name);
        return;
    end
    
    if (~isstruct(struct1)) 
        resultIndex = numel(result)+1;
        result{resultIndex} = sprintf('''%s'' is not a struct. Will not compare further.', struct2Name);
        return;
    end
    
    % OK, inputs are good structs so lets continue with their fields
    struct1FieldNames = sort(fieldnames(struct1));
    struct2FieldNames = sort(fieldnames(struct2));
    
    % Check that the two structs have same number of fields
    if numel(struct1FieldNames) ~= numel(struct2FieldNames)
        resultIndex = numel(result)+1;
        result{resultIndex} = sprintf('''%s'' has %d fields, whereas ''%s'' has %d fields. Will not compare further.', struct1Name, numel(struct1FieldNames), struct2Name, numel(struct2FieldNames));
        return;
    end
    
    
    for k = 1:numel(struct1FieldNames)
        
        % Check that the two structs have the same field names
       if (strcmp(struct1FieldNames{k}, struct2FieldNames{k}) == 0)
            resultIndex = numel(result)+1;
            result{resultIndex} = sprintf('''%s'' and ''%s'' have different field names: %s vs %s. Will not compare further.', struct1Name, struct2Name, field1Name{k}, field2Name{k});
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
                result = recursivelyCompareStructs(field1Name, field1, field2Name, field2, tolerance, graphMismatchedData, result);
           else
                resultIndex = numel(result)+1;
                result{resultIndex} = sprintf('''%s'' is a struct but ''%s'' is not.', field1Name, field2Name);
           end
          
       % compare strings
       elseif ischar(field1)
           if ischar(field2)
               if (~strcmp(field1, field2))
                    resultIndex = numel(result)+1;
                    result{resultIndex} = sprintf('''%s'' and ''%s'' are different: ''%s'' vs. ''%s''.', field1Name, field2Name, field1, field2);
               end
           else
                resultIndex = numel(result)+1;
                result{resultIndex} = sprintf('''%s'' is a char string but ''%s'' is not.\n', field1Name, field2Name);
           end
           
       % compare  numerics   
       elseif isnumeric(field1)
           if isnumeric(field2)
               if (ndims(field1) ~= ndims(field2))
                   resultIndex = numel(result)+1;
                   result{resultIndex} = sprintf('''%s'' is a %d-D numeric whereas ''%s'' is a %d-D numeric.', field1Name, ndims(field1), field2Name, ndims(field2));
               else 
                   if (any(size(field1)-size(field2)))
                        resultIndex = numel(result)+1;
                        result{resultIndex} = sprintf('''%s'' is a %4g matrix whereas ''%s'' is a %4g matrix.', field1Name, size(field1), field2Name, size(field2));
                   else
                       % equal size numerics
                       if (any(abs(field1(:)-field2(:)) > tolerance))
                            figureName = '';
                            if (graphMismatchedData)
                                figureName = plotDataAndTheirDifference(field1, field2, field1Name, field2Name);
                            end
                            resultIndex = numel(result)+1;
                            maxDiff = max(abs(field1(:)-field2(:)));
                            if (isempty(figureName))
                                result{resultIndex} = sprintf('Max difference between ''%s'' and ''%s'' (%g) is greater than the set tolerance (%g).', field1Name, field2Name, maxDiff, tolerance);
                            else
                                result{resultIndex} = sprintf('Max difference between ''%s'' and ''%s'' (%g) is greater than the set tolerance (%g). See figure named: ''%s''', field1Name, field2Name, maxDiff, tolerance, figureName);
                            end
                       end
                   end
               end
           else
               resultIndex = numel(result)+1;
               result{resultIndex} = sprintf('''%s'' is a numeric but ''%s'' is not.', field1Name, field2Name);
           end
           
       % compare cells
       elseif iscell(field1)
           if iscell(field2)
               if (numel(field1) ~= numel(field2))
                   resultIndex = numel(result)+1;
                   result{resultIndex} = sprintf('''%s'' has %d elements whereas ''%s'' has %d elements.', field1Name, numel(field1), field2Name, numel(field2));
               else
                   result = CompareCellArrays(field1, field2, result);
               end
           else
               resultIndex = numel(result)+1;
               result{resultIndex} = sprintf('''%s'' is a cell but ''%s'' is not.', field1Name, field2Name);
           end
       end
       
    end  % for k
       
end


function result = CompareCellArrays(field1, field2, result)

   for k = 1:numel(field1) 
       
       % Char values
       if (ischar(field1{k}))
           if (ischar(field2{k}))
               if (~strcmp(field1{k}, field2{k}))
                   resultIndex = numel(result)+1;
                   result{resultIndex} = sprintf('Corresponding cell fields have different string values: ''%s'' vs. ''%s''.', field1{k}, field2{k});
               end
           else
              resultIndex = numel(result)+1;
              result{resultIndex} = sprintf('Corresponding cell fields have different types');
           end
       % numeric values
       elseif (isnumeric(field1{k}))
           if (isnumeric(field2{k}))
               if (any(field1 ~= field2))
                   resultIndex = numel(result)+1;
                   result{resultIndex} = sprintf('Corresponding cell fields have different numeric values: ''%g'' vs. ''%g''.', field1{k}, field2{k});
               end
          else
              resultIndex = numel(result)+1;
              result{resultIndex} = sprintf('Corresponding cell fields have different types');
           end
       else
          fprintf(2,'UnitTest.structsAreSimilar.CompareCellArrays. non-char, non-numeric comparison not implemented\n');
       end
   end
    
end
     

function figureName = plotDataAndTheirDifference(field1, field2, field1Name, field2Name)
    h = figure();
    figureName = sprintf('''%s'' vs. ''%s''', field1Name, field2Name);
    set(h, 'Name', figureName);
    clf;
    
    if (ndims(field1) == 2)
        set(h, 'Position', [100 100 1400 380]);
        subplot(1,3,1);
        imagesc(field1);
        title(sprintf('''%s''', field1Name));

        subplot(1,3,2);
        imagesc(field2);
        title(sprintf('''%s''', field2Name));

        subplot(1,3,3);
        imagesc(field1-field2);
        title(sprintf('''%s'' - \n''%s''', field1Name, field2Name));
        colormap(gray(256));
        
    elseif (ndims(field1) == 1)   
        set(h, 'Position', [100 100 600 600]);
        plot(field1, field2, 'ks');
        xlabel(field1Name);
        ylabel(field2Name);
        
    elseif (ndims(field1) == 3)
        fprintf(2, '\nUnitTest.structsAreSimilar: 3D data comparison plot not implemented yet\n');
        figureName = '';
    end
    
end