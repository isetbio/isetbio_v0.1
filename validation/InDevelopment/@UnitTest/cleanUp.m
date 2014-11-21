 % Method to cleanup all generated directories
 function cleanUp()
    
    % Instantiate an object just for cleaning up
    UnitTestOBJ = UnitTest();
    
    % remove HTML dir
    UnitTestOBJ.removeHTMLDir();
    
    % Remove validation data dir
    UnitTestOBJ.removeValidationDataDir();
    
    clear 'UnitTestOBJ';
 end