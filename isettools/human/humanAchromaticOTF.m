function MTF = humanAchromaticOTF(sampleSF, model, pupilD)
% OTF fall off at optimal wavelength (no chromatic aberration)
%
%    MTF = humanAchromaticOTF(sampleSF, model, [pupilD])
%
% Inputs:
%  sampleSF  - spatial frequency vector (cyc/deg)
%  model     - string of model selected, see comments below for detail
%  pupilD    - requied for some model
%
% Output:
%  w         - MTF at sampleSF
%
% Example:
%   sampleSF = 0:60;
%   w = humanAchromaticOTF(sampleSF);
%   plot(sampleSF,w)
%
% NOTE:
%   Here, we implemented different methods, including:
%   'dl'     - diffraction limited
%   'exp'    - exponential family
%   'watson' - watson model
%
% For exponential model, a typical human OTF scaling is used from the work
% at Dave Williams' lab. And this is a smooth fit to their data, which was
% provided by Dave Brainard.
%
% For watson model, it is described in 'A formula for the mean  human
% optical modulation transfer function as a function of pupil size', Andrew
% B. Watson, JOV, 2013. The general fomula is
%   M(u,d) = (1 + (u/u1(d))^2)^(-0.62)*sqrt(M_dl(u,d,555))
%   u1 = 21.95 - 5.512d + 0.3922d^2
%
% Copyright ImagEval Consultants, LLC, 2011

if notDefined('sampleSF'), sampleSF = 0:50; end
if notDefined('model'), model = 'exp'; end
model = ieParamFormat(model);

switch model
    case {'exp', 'exponential'}
        a =  0.1212;		%Parameters of the fit
        w1 = 0.3481;		%Exponential term weights
        w2 = 0.6519;
        MTF =  w1*ones(size(sampleSF)) + w2*exp( - a*sampleSF );
    case {'dl', 'diffractionlimited'}
        if notDefined('pupilD'), error('pupil diameter required'); end
        lambda = 555;
        u0 = pupilD * pi * 1e6 / lambda / 180;
        uHat = sampleSF / u0;
        MTF = 2/pi * (acos(uHat) - uHat * sqrt(1 - uHat^2));
        MTF(uHat >= 1) = 0;
    case {'watson'}
        if notDefined('pupilD'), error('pupil diameter required'); end
        if pupilD > 6 || pupilD < 2
            warning('pupil size out of bound given in paper (2 ~ 6)');
        end
        u1 = 21.95 - 5.512 * pupilD + 0.3922 * pupilD^2;
        MTFdl = humanAchromaticOTF(sampleSF, 'dl', pupilD);
        MTF = (1 + (sampleSF / u1)^2)^(-0.62) * sqrt(MTFdl);
        
        % Apply scatter effects here
        % Not sure if it's the right place to apply the scatter effect
        % Maybe we should make it into some individual functions, HJ
        
        % adjusted pigment factor, see IJspeert (1993). It could take some
        % other values as small as 0.056 etc.
        p = 0.16;
        age = 30; % should be an input parameter, HJ will update it later
        MTF = MTF * (1 - p) / (1 + p * (age / 70)^4);
end

% END
