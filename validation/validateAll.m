function validateAll()  
    
    % Initialize a @UnitTest object to handle the results
    unitTestOBJ = UnitTest(mfilename('fullpath'));
    
    % Set optional parameters.
    %
    % 1. Information displayed in command window.
    % If set to false, only information regarding failed validation runs is displayed.
    % Otherwise, information about all validation runs is displayed.
    % Defaults to false
    unitTestOBJ.displayAllValidationResults = true;
    
    % 2. Whether to append the validation results to the history of validation runs.
    % Defaults to false.
    unitTestOBJ.addResultsToValidationResultsHistory = true;
    
    % 3. Whether to append the validation results to the history of ground truth data sets.
    % Defaults to false.
    unitTestOBJ.addResultsToGroundTruthHistory = false;
    
    % 4. Whether to push results to github upon a sucessful validation
    % outcome. Defaults to true;
    unitTestOBJ.pushToGitHubOnSuccessfulValidation = false;
    
    % 5. Whether @UnitTest will ask the user which ground truth data set to use 
    % if more than one are found in the history of saved ground truth data sets.
    % If set to false, the last ground truth data set will be used.
    unitTestOBJ.queryUserIfMoreThanOneGroundTruthDataSetsExist = true;
    
    % 6. Locations of directories where ISETBIO gh-Pages and wiki are cloned
    % Defaults are '/Users/Shared/Matlab/Toolboxes/ISETBIO_GhPages/isetbio'
    % and '/Users/Shared/Matlab/Toolboxes/ISETBIO_Wiki/isetbio.wiki'
    % If these locations are not desired, enter new ones here:
    % unitTestOBJ.ISETBIO_gh_pages_CloneDir = ...
    % unitTestOBJ.ISETBIO_wikiCloneDir = ...
    
    % 7. Set numeric tolerance below which two numeric values are to be
    % considered equal. Defaults to 10*eps.
    unitTestOBJ.numericTolerance = 10*eps;
    
    
    % If you want execution to continue on error use the following setting:
    onErrorReaction = 'CatchExcemption'; 

    % Specify how to react if an excemption is raised
    % If you want execution to stop on error (so you can fix it) use the following setting:
    onErrorReaction = 'RethrowExcemption';
    
     
    
    % Add probes
    unitTestOBJ.addProbe(...
        'name',           'comparison of PTB- vs. ISETBIO-computed irradiance', ... % name to identify this probe
        'functionSectionName', '1. PTB vs. ISETBIO validations', ...                   % section to which validation script belong to
        'functionName',   'PTB_vs_ISETBIO_Irradiance', ...                          % name of the validation script
        'functionParams',  struct(), ...                                            % struct with input arguments expected by the validation script
        'onErrorReaction', onErrorReaction, ...                                     % how to react on errors in the validation script. Options are 'CatchExcemption' or 'RethrowExcemption'
        'publishReport',   true, ...                                                % if set to true, generate HTML of validation script and of any figures produced and push it to gitHub
        'showTheCode',     true, ...                                                % If set to true, the published report will include the MATLAB code that was run
        'generatePlots',   true ...
    );
    

    unitTestOBJ.addProbe(...
        'name',           'comparison of PTB- vs. ISETBIO-computed colorimetry', ... % name to identify this probe
        'functionSectionName', '1. PTB vs. ISETBIO validations', ...                   % section to which validation script belong to
        'functionName',   'PTB_vs_ISETBIO_Colorimetry', ...                          % name of the validation script
        'functionParams',  struct(), ...                                            % struct with input arguments expected by the validation script
        'onErrorReaction', onErrorReaction, ...                                     % how to react on errors in the validation script. Options are 'CatchExcemption' or 'RethrowExcemption'
        'publishReport',   true, ...                                                % if set to true, generate HTML of validation script and of any figures produced
        'showTheCode',     true, ...                                                % If set to true, the published report will include the MATLAB code that was run
        'generatePlots',   true ...
    );


    unitTestOBJ.addProbe(...
        'name',           'validation of human retinal illuminance at 580 nm', ...  % name to identify this probe
        'functionSectionName', '2. Human eye computation validations', ...                 % section to which validation script belong to
        'functionName',   'validateHumanRetinalIlluminance580nm', ...               % name of the validation script to run
        'functionParams',  struct(), ...                                            % struct with input arguments expected by the validation script
        'onErrorReaction', onErrorReaction, ...                                     % how to react on errors in the validation script. Options are 'CatchExcemption' or 'RethrowExcemption'
        'publishReport',   true, ...                                                % if set to true, generate HTML of validation script and of any figures produced
        'showTheCode',     true, ...                                                % If set to true, the published report will include the MATLAB code that was run
        'generatePlots',   true ...
    );

    unitTestOBJ.addProbe(...
        'name',           'validation skeleton', ...                                % name to identify this probe
        'functionSectionName', 'z. Skeleton validation scripts', ...                   % section to which validation script belong to
        'functionName',   'validateSkeleton', ...                                   % name of the validation script to run
        'functionParams',  struct(), ...                                            % struct with input arguments expected by the validation script
        'onErrorReaction', onErrorReaction, ...                                     % how to react on errors in the validation script. Options are 'CatchExcemption' or 'RethrowExcemption'
        'publishReport',   true, ...                                                % if set to true, generate HTML of validation script and of any figures produced
        'showTheCode',     true, ...                                                % If set to true, the published report will include the MATLAB code that was run
        'generatePlots',   true ...
    );

   
    % Contrast validation run data to ground truth data set
    diff = unitTestOBJ.contrastValidationRunDataToGroundTruth(); 
end





