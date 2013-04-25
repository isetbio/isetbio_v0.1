function [res,wave,comment,partialName] = ieReadSpectra(fname,wave,extrapVal)
% Read in spectral data and interpolate to the specified wavelengths
%
%      [res,wave,comment,fName] = ieReadSpectra(fname,wave,extrapVal)
%
% Most spectral data are stored in files that include both the sampled data
% and the wavelength values.  This routine reads the stored values and
% returns them interpolated or extrapolated to the values in parameter
% WAVE.
%
% Typically, the data are a matrix in which the columns are spectral
% functions (say light sources).  We also store spectral image data for
% some purposes (e.g., the hyperspectral photons in the face database).  In
% that case the data are compressed photons.
%
% The spectral files are created by ieSaveSpectralFile, and the format is
% determined by that function.
%
% IMPORTANT: Color filters are handled a differently because we
%   also store the filter names. See the functions ieReadColorFilter and
%   ieSaveColorFilter
%
% Inputs:
%  If the FNAME file does not exist, the variable, res, is empty on return.
%  If wave is specified, the returned data are interpolated to those
%    wavelengths.
%  If wave is not specified, the data are returned at native resolution of
%    the data file and the values of wavelength can be returned.
%
% Example:
%    fullName = vcSelectDataFile([]);
%    wave = 400:10:700;
%    data = ieReadSpectra(fullName,wave)
%    [data,wave] = ieReadSpectra(fullName)
%
% See also:  ieSaveSpectralFile
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('fname'), fname = ''; end

% Create a partialpath for this file name.  For this to work, we need to
% keep all of the spectral data in a single directory, I am afraid.
if isempty(fname)
    partialName = vcSelectDataFile('');
    if isempty(partialName), return; end
else
    partialName = fname;
end

test = exist(partialName,'file');
% If partialName is a directory or doesn't exist, we have a problem.
if ~test || test == 7
    partialName = sprintf('%s.mat',partialName);
    if ~exist(partialName,'file')
        res        = []; wavelength = []; comment    = []; 
        warning('ieReadSpectra:File','Cannot find file %s. Returning empty data.',partialName);
        return;
    end
end

% Load in spectral data
% We should probably trap this condition so that if it fails the user is sent into
% a GUI to find the data file.
% Also, we should use
% foo = load(partialName)
% if isfield(foo,'comment') ... approach in case the file is missing a
% comment.  Then we should return an empty comment.
tmp = load(partialName);
if isfield(tmp,'data'), data = tmp.data; else data = []; end
if isfield(tmp,'wavelength'), wavelength = tmp.wavelength; else wavelength = []; end
if isfield(tmp,'comment'), comment = tmp.comment; else comment = []; end
if isfield(tmp,'dFormat'), dFormat = tmp.dFormat; else dFormat = 'double'; end

% RGB format data were stored and compressed.  We read and return without
% interpolation of wavelength.
if isstruct(data)
    switch dFormat
        case 'compressed32'
            res = ieUncompressData(data.s,data.mn,data.mx,32);
        case 'compressed16'
            res = ieUncompressData(data.s,data.mn,data.mx,16);
        otherwise
            error('Unknown dFormat %s\n',dFormat);
    end
    % No wavelength interpolation in this case
    return;
end

% In this case the data were columns of a matrix.
if length(wavelength) ~= size(data,1)
    error('Mis-match between wavelength and data in %s',partialName);
end

% If wave was not sent in, return the native resolution in the file.  No
% interpolation will occur.
if ieNotDefined('wave'),  wave = wavelength; end
if ieNotDefined('extrapVal'),  extrapVal = 0;  end

% Interpolate to requested wavelength
res = interp1(wavelength(:), data, wave(:),'linear',extrapVal);
    
return;
