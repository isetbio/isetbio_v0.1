function validateAll()
    
    % Specify how to react if an excemption is raised
    % If you want execution to stop on error use the following setting:
    onErrorReaction = 'RethrowExcemption';
    
    % If you want execution to continue on error use the following setting:
    % onErrorReaction = 'CatchExcemption';    
    
    
    % Initialize a @UnitTest object to handle the results
    unitTestOBJ = UnitTest(mfilename('fullpath'));

    unitTestOBJ.addProbe(...
        'name',           'comparison of PTB- vs. ISETBIO-computed irradiance', ... % name to identify this probe
        'functionSectionName', '1. PTB vs. ISETBIO validations', ...                   % section to which validation script belong to
        'functionName',   'PTB_vs_ISETBIO_Irradiance', ...                          % name of the validation script
        'functionParams',  struct(), ...                                            % struct with input arguments expected by the validation script
        'onErrorReaction', onErrorReaction, ...                                     % how to react on errors in the validation script. Options are 'CatchExcemption' or 'RethrowExcemption'
        'publishReport',   true, ...                                                % if set to true, generate HTML of validation script and of any figures produced
        'showTheCode',     true, ...                                                % If set to true, the published report will include the MATLAB code that was run
        'generatePlots',   true ...
    );

    unitTestOBJ.addProbe(...
        'name',           'comparison of PTB- vs. ISETBIO-computed colorimetery', ... % name to identify this probe
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
        'functionSectionName', '2. Human Eye Compute validations', ...                 % section to which validation script belong to
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

    % Push results to gitHub, i.e.:  https://github.com/isetbio/isetbio/wiki/ValidationResults
    unitTestOBJ.pushToGitHub(); 
end





