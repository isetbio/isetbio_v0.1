function energy = Quanta2Energy(wavelength,photons)
%Convert quanta (photons) to energy (watts)
%
%  energy = Quanta2Energy(WAVELENGTH,PHOTONS)
%
% Convert PHOTONS represented at the sampled WAVELENGTH positions to
% energy (watts or joules).
%
% WAVELENGTH is a column vector describing the wavelength samples [nm]
% PHOTONS can be a matrix in either RGB or XW (space-wavelength) format.
% In the XW format each spatial position is in a row and the wavelength
% varies across columsn.  The output, ENERGY, [watts or Joules] is
% returned in  same format as input (RGB or XW).
%
% CAUTION: The input form differs from the Energy2Quanta() call, which has
% the energy spectra in the columns.
%
% Examples:
%   wave = 400:10:700;  
%   p = blackbody(wave,3000:1000:8000,'photons');
%   e = Quanta2Energy(wave,p'); e = diag(1./e(:,11))*e;
%   figure; plot(wave,e')
%
%   p1 = blackbody(wave,5000,'photons');
%   e = Quanta2Energy(wave,p1);              % e is a row vector, space-wavelength (XW) format
%   p2 = Energy2Quanta(wave,transpose(e));   % Notice the TRANSPOSE
%   figure; plot(wave,p1,'ro',wave,p2,'k-')
%
% Copyright ImagEval Consultants, LLC, 2003.

% TODO
%   We should regularize the calls to Energy2Quanta() and this routine,
%   probably by making the other routine take RGB or XW format as well.
%   Old legacy issues, sigh.

if isempty(photons), energy = []; return; end

% Make sure wavelength is a column vector
s = size(wavelength); n = length(wavelength);
if prod(s) ~= n, error('Wavelength must be a vector')
else
    % In this routine, we need wavelength to be a row vector.  If photons
    % is a vector, it must be a row vector, too.
    wavelength = wavelength(:)';
end

% Fundamental constants.  These should probably be in vcConstants
%
h = vcConstants('h');		% Planck's constant [J sec]
c = vcConstants('c');		% speed of light [m/sec]

% Main routine handles RGB or XW formats
iFormat = vcGetImageFormat(photons,wavelength);

switch iFormat
    case 'RGB'
        [n,m,w] = size(photons);
        if w ~= length(wavelength)
            error('Quanta2Energy:  photons third dimension must be numWave');
        end
        photons = RGB2XWFormat(photons);
        energy = (h*c/(1e-9))*(photons ./ repmat(wavelength,n*m,1) );
        energy = XW2RGBFormat(energy,n,m);

    case 'XW'

        [n,m] = size(photons);

        % If photons is a vector, it must be a row
        if (n == 1 || m == 1), photons = photons(:)'; [n,m] = size(photons);end
        if m ~= length(wavelength)
            errordlg('Quanta2Energy:  quanta must have col length equal to numWave');
        end

        energy = (h*c/(1e-9))*(photons ./ repmat(wavelength,n,1));


    otherwise
        error('Unknown image format');

end

return;
