classdef UnitTest < handle
    % Class to handle ISETBIO unit tests
    
    % Public properties
    properties
        
    end
    
    properties (SetAccess = private) 
        
        data;
        
        % a cell array of structs describing all the probes performed
        probesPerformed = {};
        
    end
    
    % Public methods
    methods
        % Constructor
        function obj = UnitTest(validationScriptFileName)
            obj.data.vScriptFileName = sprintf('%s',validationScriptFileName);
            obj.data.vScriptListing  = fileread([validationScriptFileName '.m']);
            obj.data.datePerformed   = datestr(now);
            obj.data.matlabVersion   = version;
            obj.data.computer        = computer;
            obj.data.gitBranch       = '?';
        end
        
        % Method to add and execute a new probe
        addProbe(obj, varargin);
         
    end
    
    methods (Access = private)    
        
    end
    
end
