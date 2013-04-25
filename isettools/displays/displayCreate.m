function d = displayCreate(displayName,varargin)
% Create a display structure.
%
%  d = displayCreate(displayName,varargin)
%
% Display (d) calibration data are stored in a display structure. These are
% the spectral radiance distribution of its primaries and a gamma function.
% The calibrated display file is read in by routines, such as
% sceneFromFile.
%
% See also:  sceneFromFile (RGB read in particular)
%
% Example:
%   d = displayCreate;
%   d = displayCreate('lcdExample');
%   wave = 400:5:700; d = displayCreate('lcdExample',wave);
%
% Copyright ImagEval Consultants, LLC, 2011.

if ieNotDefined('displayName'), displayName = 'default'; end

% Identify the object type
d.type = 'display';

% This will change the filename to lower case which can cause problems.
% displayName = ieParamFormat(displayName);

d = displaySet(d,'name',displayName);

% We can create some displays, or if it is not on the list perhaps it is a
% file name that we load.
switch displayName
    case 'default'
        d = displayDefault(d);
 
    otherwise
        % Is it a file with calibrated display data?
        if exist(displayName,'file') || exist([displayName,'.mat'],'file') 
            tmp = load(displayName);
            if ~isfield(tmp,'d')
                error('No display struct in the file');
            else  d = tmp.d;
            end
        else error('Unknown display %s.',displayName);
        end

end

if length(varargin) >= 1
    newWave = varargin{1};
    oldWave = displayGet(d,'wave');
    oldSpd = displayGet(d,'spd');
    newSpd = interp1(oldWave(:),oldSpd,newWave(:));
    % plot(newWave,newSpd,'k-',oldWave,oldSpd,'y-')
    d = displaySet(d,'wave',newWave);
    d = displaySet(d,'spd',newSpd);
end

return;

% Create a default display structure
function d = displayDefault(d)
%
% Create a default display that works well with the imageSPD rendering
% routine.  See vcReadImage for more notes.  Or move those notes here.
wave = 400:10:700;
spd = pinv(colorBlockMatrix(length(wave)));
d = displaySet(d,'wave',wave);
d = displaySet(d,'spd',spd);

% Linear gamma function - do we need an inverse?  Should default be sRGB?
d = displaySet(d,'dacsize',8);
N = displayGet(d,'nLevels'); 
g = repmat((0:(N-1))'/N,1,3);
d = displaySet(d,'gamma',g);  % From digital value to linear intensity

% Spatial matters
d.dpi = 96;    % Typical display density?  This might be a little low
d.dist = 0.5;  % Typical viewing distance, 19 inches

return;






