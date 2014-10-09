classdef UnitTest < handle
    % Class to handle ISETBIO unit tests
    
    % Public properties
    properties
        % Flag indicating whether info for all validation runs is
        % displayed in the command window. If set to false, only
        % information regarding failed validation runs is displayed.
        displayAllValidationResults = false;
        
        % Flag indicating whether to add the validation results to the
        % history of validation runs.
        addResultsToValidationResultsHistory = false;
        
        % Flag indicating whether to append the validation results to the 
        % history of ground truth data sets.
        addResultsToGroundTruthHistory = false;
    
        % Flag indicating whether to push results to github upon a sucessful validation
        % outcome.
        pushToGitHubOnSuccessfulValidation = true;
        
        % Tolernace below which two numeric values are to be considered equal
        numericTolerance = 10*eps;
        
        % Flag indicating whether @UnitTest should ask the user which
        % ground truth data set to use if more than one are found in the
        % history of saved ground truth data sets.
        % If set to false, the last ground truth data set will be used.
        queryUserIfMoreThanOneGroundTruthDataSetsExist = false;
        
        % Local directory where ISETBIO ghPages branch is cloned
        ISETBIO_gh_pages_CloneDir = '/Users/Shared/Matlab/Toolboxes/ISETBIO_GhPages/isetbio';
        
        % Local directory where ISETBIO wiki is cloned
        ISETBIO_wikiCloneDir = '/Users/Shared/Matlab/Toolboxes/ISETBIO_Wiki/isetbio.wiki';
        
        % SVN URL where ground truth data sets are kept
        ISETBIO_DataSets_SVN_URL  = 'https://platypus.psych.upenn.edu/repos/ISETBIO_DataSets';
        
        % Flag indicating whether to use the ground truth table kept on
        % platypus.psych.upenn.edu SVN server
        useRemoteGroundTruthDataSet = true;
        
        % Minimum level at which messages will be emitted to the user via the command window.
        messageEmissionStrategy = UnitTest.MEDIUM_IMPORTANCE; 
    end
    
    properties (SetAccess = private) 
        % a collection of various system information
        systemData = struct();

        % validation root directory: same as dir of the executive script
        validationRootDirectory;
        
        % cell array with data for all examined probes
        allProbeData;
        
        % cell array with info about all probes
        validationSummary;
        
        % full path to the file containing the history of validation data runs 
        validationDataSetsFileName;
        
        % full path to the file containing the ground truth data sets
        groundTruthDataSetsFileName;
    end
    
    properties (Access = private)  
        % validation results for current probe
        validationFunctionName = '';
        validationFailedFlag   = true;
        validationData         = struct();
        validationReport       = 'None';
        validationProbeIndex   = 0;
        
        % map describing section organization
        sectionData;
        
        % struct with data from current validation run. 
        % this is compared to ground truth data set
        currentValidationRunDataSet;
        
        % struct with data from selected ground truth history. 
        % this is compared to the current validation run
        groundTruthDataSet;
        
        % Temporary directory to sync ground truth data set with remote SVN
        ISETBIO_DataSets_Local_SVN_DIR;
    end
    
    properties (Constant)
        MAXIMUM_IMPORTANCE = 99;
        MEDIUM_IMPORTANCE  = 10;
        MINIMUM_IMPORTANCE = 0;
    end
    
    % Public methods
    methods
        % Constructor
        function obj = UnitTest(validationScriptFileName)
            [obj.validationRootDirectory, ~, ~] = fileparts(which(validationScriptFileName));
            obj.systemData.vScriptFileName      = sprintf('%s',validationScriptFileName);
            obj.systemData.vScriptListing       = fileread([validationScriptFileName '.m']);
            obj.systemData.datePerformed        = datestr(now);
            obj.systemData.matlabVersion        = version;
            obj.systemData.computer             = computer;
            obj.systemData.computerAddress      = char(java.net.InetAddress.getLocalHost.getHostName);
            obj.systemData.userName             = char(java.lang.System.getProperty('user.name'));
            obj.systemData.gitRepoBranch        = obj.retrieveGitBranch();
            obj.sectionData                     = containers.Map();
            obj.allProbeData                    = {};
            obj.currentValidationRunDataSet     = {};
            obj.groundTruthDataSet              = {};
            
            % full path to the file containing the history of validation data runs 
            obj.validationDataSetsFileName = fullfile(fileparts(which('validateAll')), 'ISETBIO_LocalValidationDataSetHistory.mat');
            % full path to the file containing the ground truth data sets
            obj.groundTruthDataSetsFileName = fullfile(fileparts(which('validateAll')), 'ISETBIO_GroundTruthDataSetHistory.mat');
            
        end
        
        % Method to add and execute a new probe
        addProbe(obj, varargin);
         
        % Method to print the validation report
        printReport(obj, versbosity);
    
        % Method to return feedback messages via the command window.
        % Whether a message is printed or not will depend on its importance
        % and the set 'minMessageEmissionLevel' property.
        emitMessage(obj, message, importanceLevel);
        
        % Method to contrast current validation run data to that loaded
        % from a ground truth data set
        [diffs, criticalDiffs] = contrastValidationRunDataToGroundTruth(obj); 
    end
    
    methods (Access = private)    
        % Method to retrieve the git branch string
        gitBranchString = retrieveGitBranch(obj);
        
        % Method to generate a grand struct with all results for a single probe
        validationRunData = assembleResultsIntoValidationRunStuct(obj);
        
        % Method to retrieve ground truth data set against which we will
        % validate the current run
        groundTruthData = retrieveHistoricalGroundTruthDataToValidateAgaist(obj);
        
        % Method to compare the structs: obj.currentValidationRunDataSet and obj.groundTruthDataSet
        diff = obj.compareDataSets();
        
        % Method to update the validation results
        saveValidationResults(obj, dataType);
   
        % Method that pushes results to github
        pushToGitHub(obj);
        
        % Method to return the filename of the SVN-hosted ground truth data set
        dataSetFilename = svnHostedGroundTruthDataSetsFileName(obj); 
        
        % Method to checkout the SVN_hosted ground truth data set
        issueSVNCheckoutCommand(obj);
        
        % Method to commit the SVN_hosted ground truth data set
        issueSVNCommitCommand(obj, validationDataParamName);
    end
    
    methods (Static)
        validationResults = updateParentUnitTestObject(validationReport, validationFailedFlag, validationDataToSave, runParams);
        
        % Method to recursively compare 2 structs
        result = compareStructs(struct1Name, struct1, struct2Name, struct2, probeName, tolerance);
    end
    
end
