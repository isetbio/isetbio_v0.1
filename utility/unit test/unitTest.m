function unitTest
%% Run unit test
%    result = unitTest
%
%
%  (HJ) ISETBIO TEAM, 2014

try
    % add path
    % This file should be in isetbio_root_path/utility/unit test
    cd ../../
    addpath(genpath(isetbioRootPath));
    s_sceneUnitTest;
    exit(0);
catch err
    setenv('error_message', err.message);
    system('echo $error_message');
    exit(-1);
end

end