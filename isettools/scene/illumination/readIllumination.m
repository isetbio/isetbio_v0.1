function spectralRadiance = readIllumination(lightParameters,lightName)
%Return spectral radiance of a standard illuminants
%
%    spectralRadiance = readIllumination(lightParameters,lightName)
% 
% The illuminant parameters can be controlled by using the structure
% lightParameters. See the example below for how to set the values of this
% structure.  
% 
% If you don't wish to control the parameters, but only to get an
% illuminant by name, the spectral radiance is returned at 400:10:700  
% nm samples and the mean luminance is 100 cd/m2.
%
% The standard illuminant names are:
%
%     {'tungsten'}
%     {'illuminantc'}
%     {'d50'}
%     {'fluorescent'}
%     {'d65','D65'}
%     {'equalenergy'}
%     {'blackbody'}   -- You must specify a color temperature in
%                        lightParameters.temperature
%     {'555nm'}
%
% The lightParameters structure is idiosyncratic and used only here.  
%
% See also: illuminantCreate
%
% Examples:
%   readIllumination([],'d65')
%   readIllumination([],'tungsten')
%
%   lightParameters.name = 'd65';
%   lightParameters.spectrum.wave = 400:10:700;
%   lightParameters.luminance = 100;
%   readIllumination(lightParameters);
%
%   lightParameters.name = 'blackbody';
%   lightParameters.temperature = 3000;
%   lightParameters.spectrum.wave = 400:10:700;
%   lightParameters.luminance = 100;
%   sr = readIllumination(lightParameters);
%
% Copyright ImagEval Consultants, LLC, 2005.

% Programming note: This code is only used with macbethChart routines at
% present.  Perhaps it will disappear with time.  

if ieNotDefined('lightParameters')
    if ieNotDefined('lightName'), name = 'd65';
    else name =  lightName;
    end
    luminance = 100;
    wave = 400:10:700;
else
    name      = lightParameters.name;
    luminance = lightParameters.luminance; 
    wave      = lightParameters.spectrum.wave;
end

if length(wave) > 1
    binwidth  = wave(2)-wave(1);
else
    binwidth = 1;  % One sample, 1 nm bin width
end
photopicLuminosity = vcReadSpectra('data/human/luminosity',wave);

switch lower(name)
    case {'tungsten'}
        SPD = vcReadSpectra('data/lights/Tungsten',wave);
    case {'illuminantc'}
        SPD = vcReadSpectra('data/lights/illuminantC',wave);
    case {'d50'}
        SPD = vcReadSpectra('data/lights/D50',wave);
    case {'fluorescent'}
        SPD = vcReadSpectra('data/lights/Fluorescent',wave);
    case {'d65','D65'}
        SPD = vcReadSpectra('data/lights/D65',wave);
        
    case {'white','uniform','equalenergy'}
        SPD = ones(length(wave),1);
        
    case 'blackbody'
        if ~checkfields(lightParameters,'temperature')
            temperature = 6500;
        else
            temperature = lightParameters.temperature;
        end
        SPD = blackbody(wave,temperature);
        
    case {'555nm','monochrome'}
        SPD = zeros(length(wave),1);
        % Set the wavelength closest to 555 to 1
        [v,idx] = min(abs(wave - 555));
        SPD(idx) = 1;
        
    otherwise   
        error('Illumination:  Unknown light source');
end

% Compute the current light source luminance; scale it to the desired luminance.
% The formula for luminance is 
% currentL = 683 * binwidth*(photopicLuminosity' * SPD);
currentL = ieLuminanceFromEnergy(SPD',wave);
spectralRadiance = (SPD / currentL) * luminance;

% Just check the values
%  ieLuminanceFromEnergy(spectralRadiance',wave)
%  ieXYZFromEnergy(spectralRadiance',wave)

return