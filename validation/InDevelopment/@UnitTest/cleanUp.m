 % Method to cleanup all generated directories
 function cleanUp()
    
    % Instantiate an object just for cleaning up
    UnitTestOBJ = UnitTest();
    
    % remove HTML dir
    UnitTestOBJ.removeHTMLDir();
    
    removeValidationData = input('Remove validation data directory as well ? [1=yes] : ', 's');
    if (str2double(removeValidationData ) == 1)
        % Remove validation data dir
        UnitTestOBJ.removeValidationDataDir();
    end

    clear 'UnitTestOBJ';
 end