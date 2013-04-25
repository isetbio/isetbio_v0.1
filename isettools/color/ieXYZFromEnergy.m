function XYZ = ieXYZFromEnergy(energy,wave)
% CIE XYZ values from spectral radiance (watts/nm/sr/m2) or irradiance (watts/nm/m2)
%
%    XYZ = ieXYZFromEnergy(energy,wave)
%
% Calculate the XYZ values of the spectral radiance or irradiance functions
% in the variable ENERGY.  The input format of energy can be either XW
% (space-wavelength) or RGB. The wavelength samples of energy are stored in
% the variable WAVE.
%
% Notice, that XW is AN UNUSUAL FORMAT for energy.  Often, we put the SPDs
% into the columns of the matrix.  But in the XW format, the SPDs are in
% the rows. Sorry. 
%
% The returned values, XYZ, are X,Y,Z in the columns of the matrix. Each
% row of energy has a corresponding XYZ value in the corresponding row of
% XYZ. 
%
% The units of Y are candelas/meter-squared if energy is radiance and lux
% if energy is irradiance.
%
% See also: ieXYZFromPhotons()
%
% Examples:
%    wave = 400:10:700;
%    tmp = load('CRT-Dell'); dsp = tmp.d;
%    energy = displayGet(dsp,'spd',wave);
%    energy = energy';
%    displayXYZ = ieXYZFromEnergy(energy,wave)
%
%    patchSize = 1;
%    macbethChart = sceneCreate('macbeth',patchSize); 
%    p = sceneGet(macbethChart,'photons'); wave = sceneGet(macbethChart,'wave'); e = Quanta2Energy(wave,p);
%    XYZ = ieXYZFromEnergy(e,wave);  
%
% Copyright ImagEval Consultants, LLC, 2003.


% Force the data into XW format.
if ndims(energy) == 3
    if length(wave) ~= size(energy,3)
        error('Bad format for input variable energy.');
    end
end

switch vcGetImageFormat(energy,wave)
    case 'RGB'
        % [rows,cols,w] = size(data);
        xwData = RGB2XWFormat(energy);
    otherwise
        % XW format
        xwData = energy;
end

% xwData = ieConvert2XW(energy,wave);
if size(xwData,2) ~= length(wave)
    error('Problem converting input variable energy into XW format.');
end

% IF we are OK to here, then the spectra of the energy points are in the
% rows of xwData.  We ready the XYZ color matching functions into the
% columns of S.
S = ieReadSpectra('XYZ',wave);
if numel(wave) > 1,  dWave = wave(2) - wave(1);
else                 dWave = 10;   disp('10 nm band assumed');
end

% The return value has three columns, [X,Y,Z].
XYZ = 683*(xwData*S) * dWave;

return;