classdef UnitTest < handle
    % Class to handle ISETBIO unit tests
    
    % Public properties (Read/write by all)
    properties
        
    end
    
    % Read-only public properties
    properties (SetAccess = private) 
        
    end
    
    % Private properties
    properties (Access = private)  
        % Struct with validation params
        defaultValidationParams;
        
        % Struct with validation params
        validationParams;
        
        % List of scripts to validate. Each entry contains a cell array with a
        % script name and an optional params struct.
        vScriptsList = {};
    end
    
    % Constant properties. These are the only properties that can be
    % accessed by the Static mehtods below
    properties (Constant) 
        runTimeOptionNames              = {'generatePlots', 'printValidationReport'};
        runTimeOptionDefaultValues      = {false false};
        
        validationOptionNames           = {'type', 'onRunTimeError', 'updateGroundTruth'}
        validationOptionDefaultValues   = {'FAST', 'rethrowExemptionAndAbort', false};
        
        validValidationTypes            = {'FAST', 'FULL', 'PUBLISH'};
        validOnRunTimeErrorValues       = {'rethrowExemptionAndAbort', 'catchExemptionAndContinue'};
    end
    
    % Public methods (This is the API)
    methods
        % Constructor
        function obj = UnitTest()      
            % setup default validation params
            for k = 1:numel(UnitTest.validationOptionNames)
                eval(sprintf('obj.defaultValidationParams.%s = UnitTest.validationOptionDefaultValues{k};', UnitTest.validationOptionNames{k}));
            end
            
            % initialize validation params to default params
            obj.validationParams = obj.defaultValidationParams;
        end
        
        % Method to set certain validation options
        setValidationOptions(obj,varargin);
        
        % Method to reset all validation options to default
        resetValidationOptions(obj);
 
        % Main validation engine
        validate(obj,vScriptsList);
    end % public methods
    
    % On the object itself can call these methods
    methods (Access = private)    
        % Method to recursively compare two struct for equality
        result = structsAreSimilar(obj, groundTruthData, validationData);
        
        % Method to import a ground truth data entry
        [validationData, validationTime] = importGroundTruthData(obj, dataFileName);
        
        % Method to export a validation entry to a validation file
        exportData(obj, dataFileName, validationData);
        
        % Method to generate a hash0256 key based on the passed validationData
        hashSHA25 = generateSHA256Hash(obj,validationData);
    end
    
    
    % These methods can be called without instantiating an object first,
    % like so: UnitTest.methodName()
    methods (Static)
        % Method to initialize the return params. Every validation script
        % mustcall this method first thing.
        [validationReport, validationFailedFlag, validationData] = initializeReturnParams();
        
        % Method to initialize the runtimeParams. Every validation script
        % must call this method right after the method above
        runParams = initializeRunTimeParams(varargin);
        
        % Method to print what runtime options are available and their default values
        describeRunTimeOptions();
        
        % Method to print what validation options are available and their default values
        describeValidationOptions();
    end
end
