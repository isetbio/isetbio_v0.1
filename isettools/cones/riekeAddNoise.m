function [adaptedCur, params] = riekeAddNoise(curNF, params)
%% Add noise to membrane current in cone adaptataion
%   adaptedCur = riekeAddNoise(curNF, params)
%
%  Noise in cone adaptation is independent of cone signal and follows a
%  ARIMA(3,0,2) model. At each point, the noise follows a Gaussian
%  distribution
%
%  Inputs:
%    curNF  - noise free cone adapted membrane current, see
%             riekeAdaptTemporal
%    params - parameter structure, could include:
%      .seed     - noise seed
%      .sampTime - sample time interval, see sensorGet(s, 'time interval');
%
%  Outputs:
%    adaptedCur - membrance current with noise added
%
%  See also:
%    coneAdapt, riekeAdaptSteadyState, riekeAdaptTemporal
%
%  Note:
%    Instead of using the arima model simulation functions in economics
%    toolbox, we implement a simple version for the simulation. This is for
%    the sake of speed and those without economics toolbox.
%
%  (HJ) ISETBIO, 2014

%% Init
if notDefined('curNF'), error('noise-free adapted current required'); end
if notDefined('params'), params = []; end

if isfield(params, 'seed'), rng(params.seed); else params.seed = rng; end
if isfield(params, 'sampTime'), sampTime = params.sampTime;
else sampTime = 0.001; % 1 ms
end

%% Build model and generate noise
%  Make sure curNF is [row, col, time] 3D matrix
if isvector(curNF), curNF = reshape(curNF, [1 1 length(curNF)]); end

% build arima model
if sampTime == 5e-5
    % This is the noise model fitted for data sampled at 50 micro-seconds
    % In this case, the noise is temporally correlated and we can fit it to
    % a ARIMA(3,0,2) model, see s_riekeNoise for further analysis
    ar = [1.518 -0.969923 0.421612];
    ma = [1.11884 0.498774];
    sigma = 0.3798;
    noise = simulateARMA(ar, ma, sigma, size(curNF)); 
    adaptedCur = curNF + noise;
    
elseif sampTime == 0.001
    % When data sampling interval is 1 ms, the noise is weakly correlated
    % and can be fitted to a ARIMA(1,0,1) model
    ar = 0.716881; ma = -0.272412;
    sigma = 3.8656;
    noise = simulateARMA(ar, ma, sigma, size(curNF));
    adaptedCur = curNF + noise;
    
elseif sampTime > 0.005
    % when data sampling interval is greater than 5 ms, the noise can be
    % viewed as independent additive gaussian noise
    adaptedCur = curNF + randn(size(curNF)) * 4.5144;
else
    % We don't have an approximated model for the noise
    % We just generate the noise according to the noise spectral
    % distribution
    k = ceil((size(curNF, 3)-1)/2);
    freq = (0:k)/ sampTime / size(curNF, 3);
    
    LorentzCoeffs = [0.16 55 4 0.045 190 2.5];
    noiseSPD = lorentzsum_poles(LorentzCoeffs, freq);
    
    % make-up the negative frequency part
    noiseSPD = [noiseSPD noiseSPD(end:-1:1)];
    noiseSPD = noiseSPD(1:size(curNF, 3));
    noiseSPD = reshape(noiseSPD, [1 1 length(noiseSPD)]);
    
    % generate white gaussian noise
    noise = randn(size(curNF));
    noiseFFT = fft(noise, [], 3) / sqrt(size(noise, 3));
    
    % adjust the spectral power distribution of the noise
    noiseFFT = bsxfun(@times, noiseFFT, sqrt(noiseSPD));
    
    % convert back to time domain to recover noise
    noise = real(ifft(noiseFFT, [], 3)); % take real part
    
    % add to noise-free signal
    adaptedCur = curNF + noise;
end

end

%% Aux functions
function armaData = simulateARMA(ar, ma, sigma, sz)
% Generate samples for ARMA model
%  armaData = simulateARMA(ar, ma, sigma, sz)
%
%    This function generate samples for ARMA model
%    It is similar to function simulate in economics toolbox
%    We implement a simple version of that for speed and for those without
%    that toolbox
%
%  Inputs:
%    ar    - vector, containing auto-regressive coefficients
%    ma    - vector, containing moving average coefficients
%    simga - scalar, standard deviation of generation noise
%    sz    - size, could be [rows, cols, nFrames]
%
%  Outputs:
%
%
%  See also:
%    arima, estimate, simulate
%
%  (HJ) ISETBIO TEAM, 2014

%% Check inputs
if ~exist('ar', 'var'), error('ar coefficients required'); end
if ~exist('ma', 'var'), error('ma coefficients required'); end
if ~exist('sigma', 'var'), error('std of noise required'); end
if ~exist('sz', 'var'), error('simulation size (nFrames) required'); end

if ~isscalar(sigma), error('std of noise should be a scalar'); end
sz = padarray(sz(:), [3-numel(sz) 0], 1, 'pre')';

%% Generate noise
% will throw away first 20 more samples to avoid initial problems
sz(3) = sz(3) + 20; 
wt = randn(sz) * sigma;
armaData = wt;

for t = 2 : sz(3)
    % auto-regressive part
    indx = 1 : min(length(ar), t - 1);
    indx = reshape(indx, [1 1 length(indx)]);
    if ~isempty(indx)
        arSum = sum(bsxfun(@times, ar(indx), armaData(:,:,t-indx(:))), 3);
        armaData(:,:,t) = armaData(:,:,t) + arSum;
    end
    
    % moving average part
    indx = 1 : min(length(ma), t - 1);
    indx = reshape(indx, [1 1 length(indx)]);
    if ~isempty(indx)
        maSum = sum(bsxfun(@times, ma(indx), wt(:,:,t-indx(:))), 3);
        armaData(:,:,t) = armaData(:,:,t) + maSum;
    end
end

% throw away the first 20 samples
armaData = armaData(:,:, 21:end);

end

function fit = lorentzsum_poles(beta, x)

fit = abs(beta(1)) ./ (1 + (x ./ abs(beta(2))).^2).^beta(3);
fit = fit + abs(beta(4)) ./ (1 + (x ./ abs(beta(5))).^beta(6));
end