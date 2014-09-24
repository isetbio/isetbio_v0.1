% Method to compare the structs: obj.currentValidationRunDataSet and obj.groundTruthDataSet
function diff = compareDataSets(obj)

    fprintf('\nThe validation struct has the following fields:\n');
    fieldnames(obj.currentValidationRunDataSet)
    
    fprintf('\nThe ground truth struct has the following fields:\n');
    fieldnames(obj.groundTruthDataSet)
 
    fprintf('\nNeed to add the comparison code here\n');
    diff = [];
end

