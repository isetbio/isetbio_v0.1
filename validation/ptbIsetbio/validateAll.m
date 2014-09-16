function validateAll()

    % Initialize a @UnitTest object to handle the results
    unitTestOBJ = UnitTest(mfilename('fullpath'));

    unitTestOBJ.addProbe(...
        'name',           'PTB vs. ISETBIO irradiance comparison', ...  % name to identify this probe
        'functionName',   'PTB_vs_ISETBIO_Irradiance', ...              % name of the validation script
        'functionParams',  struct(...                                   % struct with input arguments expected by the validation script
                            'fov',            20, ...   % Big field required
                            'roiSize',         5, ...
                            'generatePlots',   true...
                            ), ...
        'onErrorReaction', 'CatchExcemption', ...                      % how to react on errors in the validation script. Options are 'CatchExcemption' or 'RethrowExcemption'
        'publishReport',   true, ...                                     % if set to true, generate HTML of validation script and any figures produced by i
        'showTheCode',  true ...                                        % If set to true, the published report will include the MATLAB code that was run
    );
                     
end





