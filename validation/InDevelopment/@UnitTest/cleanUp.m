 % Method to cleanup all generated directories
 function cleanUp()
    
    % Instantiate an object just for cleaning up
    UnitTestOBJ = UnitTest();
    
    % remove HTML dir
    UnitTestOBJ.removeHTMLDir();

    clear 'UnitTestOBJ';
 end