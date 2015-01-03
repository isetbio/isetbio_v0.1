function varargout = v_xLoadMatfile(varargin)
%
% Loads a matfile to mimic data produced by v_tempHCCompression
%
% Copyright ImagEval Consultants, LLC, 2012

    varargout = UnitTest.runValidationRun(@ValidationFunction, nargout, varargin);
end


%% Here is the actual code
function ValidationFunction(runTimeParams)

%% Init
ieInit;

%% Load
curdir = pwd;
cd(fileparts(mfilename('fullpath')));
load
cd(curdir);

%% Save it in the UnitTest object
UnitTest.validationData('sceneA', scene);

%% End
end
