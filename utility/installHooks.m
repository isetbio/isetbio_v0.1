function installHooks(gitFolder, varargin)
%% Install pre-commit hooks for isetbio
%    function installHooks([gitFolder = isetbioRootPath])
%
%  Inputs:
%    gitFolder - root path for isetbio. If isetbio is already on Matlab
%                path, this input argument is optional
%    varargin  - not used now, might accept more parameters in the future
%
%  Outputs:
%    None
%
%  Notes:
%    1) Before running this command, please make sure git (version 1.8.2 or
%       later) has been installed. Git could be downloaded from:
%            http://git-scm.com/downloads
%    2) This script has only been tested on mac. It should be fine on Linux
%       machine. For windows, we might need to do more hacks
%
%  Examples:
%    installHooks()
%
%  (HJ) ISETBIO TEAM, 2014

%% Init Git
if ~exist('gitFolder', 'var'), gitFolder = isetbioRootPath; end
if ispc, warning('This function might not work on pc'); end

curPath = cd(gitFolder); % save current working directory
system('git init');

%% Create pre-commit hooks
hookPath = fullfile(gitFolder, '.git', 'hooks');

% write shell command to pre-commit
fp = fopen(fullfile(hookPath, 'pre-commit'), 'w'); % create pre-commit

fprintf(fp, '# pre-commit.sh\n');
fprintf(fp, 'echo Start pre-commit testing...\n');
fprintf(fp, 'git stash -q --keep-index\n');
fprintf(fp, './.git/hooks/run_tests.sh\n');
fprintf(fp, 'RESULT=$?\n');
fprintf(fp, 'git stash pop -q\n');
fprintf(fp, '[ $RESULT -ne 0 ] && exit 1\n');
fprintf(fp, 'exit 0\n');

fclose(fp); % finish writing

%% Create unit-test shell command
%  Get matlab executable path
matlab_exe_path = fullfile(matlabroot, 'bin', 'matlab');
fp = fopen(fullfile(hookPath, 'run_tests.sh'), 'w'); % create run_tests.sh

fprintf(fp, '# Setup alias\n');
fprintf(fp, 'matlab="%s"\n\n', matlab_exe_path);
fprintf(fp, '# Run unit test in matlab\n');
fprintf(fp, 'cmd="cd ''%s''; unitTest;"\n', ...
                    fullfile(gitFolder, 'utility', 'unit test'));
fprintf(fp, '"$matlab" -nodesktop -nosplash -nodisplay -r "$cmd"\n');
fprintf(fp, 'if [ "$?" == "0" ];\nthen\n');
fprintf(fp, 'echo Unit test passed!\nexit 0\n');
fprintf(fp, 'else\n');
fprintf(fp, 'echo Unit Test Failed\nexit 1\n');
fprintf(fp, 'fi\n');

fclose(fp); % finish writing

%  make this shell executable
system(sprintf('chmod u+x %s', fullfile(hookPath, 'run_tests.sh')));

%% Clean up and restore
cd(curPath);