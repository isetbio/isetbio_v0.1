classdef UnitTest < handle
    % Class to handle ISETBIO unit tests
    
    % Public properties (Read/write by all)
    properties
    end
    
    % Read-only public properties
    properties (SetAccess = private) 
        % Path to directory containing the @UnitTest class
        rootDir;
        
        % Path to directory where all HTML 'published' output will be
        % directed
        htmlDir;
        
        % Path to directory where all validation data will be stored
        validationDataDir;
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
        runTimeOptionNames              = {'generatePlots', 'printValidationReport', 'unitTestOBJ' };
        runTimeOptionDefaultValues      = {false false []};
        
        validationOptionNames           = {'type', 'onRunTimeError', 'updateGroundTruth', 'updateValidationHistory'}
        validationOptionDefaultValues   = {'RUNTIME_ERRORS_ONLY', 'rethrowExemptionAndAbort', false, false};
        
        validValidationTypes            = {'RUNTIME_ERRORS_ONLY', 'FAST', 'FULL', 'PUBLISH'};
        validOnRunTimeErrorValues       = {'rethrowExemptionAndAbort', 'catchExemptionAndContinue'};
    end
    
    % Public methods (This is the API)
    methods
        % Constructor
        function obj = UnitTest()           
            % Initialize the instantiated @UnitTest object
            obj.initializeUnitTest();
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
        
        % Method to generate the directory path/subDir, if this directory does not exist
        generateDirectory(obj, path, subDir);

        % Method ensuring that directories exist, and generates them if they do not
        checkDirectories(obj);
        
        % Method to remove the root validationData directory
        removeValidationDataDir(obj);
        
        % Method to remove the root HTML directory
        removeHTMLDir(obj);
        
        % Method to parse the scripts list to ensure it is valid
        vScriptsList = parseScriptsList(obj, vScriptsToRunList);
    
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
        % Method to remove all generated directories and files
        cleanUp();
        
        % Executive method to run a validation session
        runValidationSession(vScriptsList, desiredMode)
        
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
        
        % Method to append messages to the validationReport
        report = validationRecord(varargin);
        
        data = validationData(varargin);
        
        % Method to print the validationReport
        printValidationReport(validationReport);
    end
end
