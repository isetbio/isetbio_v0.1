function fullName = ieSaveMultiSpectralImage(fullName,mcCOEF,basis,comment,imgMean,illuminant)
%
%  fullName = ieSaveMultiSpectralImage(fullName,coef,basis,comment,imgMean,illuminant)
%
% Save a Matlab data file containing a multi-spectral image. The image is
% created using routines in the pdcsoft multicapture directory.
% 
% Input arguments
%   mcCOEF  - coefficients (RGB format)
%   basis   - basis functions functions
%   comment
%   imgMean - in some cases we remove the mean before creating the coeffs
%   illuminant structure
%     .wave  are wavelengths in nanometers
%     .data  are illuminant as a function of wavelength in energy units
%
% %%% TODO:  The illuminant format should be changed to the new standard
%     ISET illuminant format.  If we send in the old format as per here, we
%     should allow it. But going forward we should check for the standard
%     illuminantCreate format and write this code with that expectation.
%
% The full path to the data is returned in fullname.
%
% The SPD of the data can be derived from the coefficients and basis
% functions using: 
%
%    spd = rgbLinearTransform(mcCOEF,basis');
%
% See also: mcCreateMultispectralBases, CombineExposureColor
%
%EXAMPLE:
%  ieSaveMultiSpectralImage('c:\user\Matlab\data\Tungsten','MacbethChart-hdrs',mcCOEF,basis,basisLights,illuminant,comment)
%
% Copyright ImagEval Consultants, LLC, 2005.


if ieNotDefined('mcCOEF'),     error('Coefficients required');     end
if ieNotDefined('basis'),      error('Basis function required.');  end
if ieNotDefined('comment'),    comment = sprintf('Date: %s\n',date); end %#ok<NASGU>

% See Programming TODO above.
if ieNotDefined('illuminant'), error('Illuminant in energy units required'); end
% If the illuminant is not in the modern illuminant format, we should
% convert it to that format here.

if ieNotDefined('fullName')
    fullName = vcSelectDataFile('stayput','w','mat','Save multispectral data file.');
end
 
% Write out the matlab data file with all of the key information needed.
% Sometimes we save out data approximated using only the SVD
% Other times, we use a principal component method and have an image mean
%
if ieNotDefined('imgMean'), 
    save(fullName,'mcCOEF','basis','comment','illuminant');
else
    save(fullName,'mcCOEF','basis','imgMean','comment','illuminant');
end

return;


