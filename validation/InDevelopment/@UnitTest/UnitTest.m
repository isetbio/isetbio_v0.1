classdef UnitTest < handle
    % Class to handle ISETBIO unit tests
    
    % Public properties
    properties
        
    end
    
    properties (SetAccess = private) 
        
    end
    
    properties (Access = private)  
        
    end
    
    properties (Constant)
        
    end
    
    % Public methods
    methods
        % Constructor
        function obj = UnitTest(validationScriptFileName)
            
        end
    end % public methods
    
    methods (Access = private)    
        
    end
    
    
    methods (Static)
        validationResults = updateParentUnitTestObject(validationReport, validationFailedFlag, validationDataToSave, runParams);
    end
    
end
