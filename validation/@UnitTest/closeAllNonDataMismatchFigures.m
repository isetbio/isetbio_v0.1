 % Method to close all non-data mismatch figures
function closeAllNonDataMismatchFigures()

    % Deal with this 2014b issue ? later.
    if (1==2)
        % Get all open figure objects
        fh = findall(0,'type','figure');

        % Go through each open figure and if it is NOT a data mismatch
        % figure, close it.
        for figIndex = 1:numel(fh)
           if (fh(figIndex).Number < UnitTest.minFigureNoForMistmatchedData)
               close(fh(figIndex));
           end
        end
    end
    
end