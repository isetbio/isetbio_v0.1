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
%  (HJ) ISETBIO, 2014

%% Programming Notes:
%    For arima model simulation, matlab function is very slow. And also, it
%    requires economics toolbox.
%    HJ will write a function to handle this problem
%

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

%  compute size
[c, r, nFrames] = size(curNF);

% build arima model
if sampTime == 5e-5
    % This is the noise model fitted for data sampled at 50 micro-seconds
    % In this case, the noise is temporally correlated and we can fit it to
    % a ARIMA(3,0,2) model, see s_riekeNoise for further analysis
    mdl = arima('AR', [1.518 -0.969923 0.421612], ...
        'D', 0, ...
        'MA', [1.11884 0.498774], ...
        'Variance', 0.144268, ...
        'Constant', 7.18207e-5);
    noise = simulate(mdl, nFrames * c * r);
    noise = permute(reshape(noise, [nFrames c r]), [2 3 1]);
    adaptedCur = curNF + noise;
    
elseif sampTime == 0.001
    % When data sampling interval is 1 ms, the noise is weakly correlated
    % and can be fitted to a ARIMA(1,0,1) model
    mdl = arima('AR', 0.716881, ...
        'D', 0, ...
        'MA', -0.272412, ...
        'Variance', 14.9429, ...
        'Constant', 0.00108364);
    noise = simulate(mdl, nFrames * c * r);
    noise = permute(reshape(noise, [nFrames c r]), [2 3 1]);
    adaptedCur = curNF + noise;
    
elseif sampTime > 0.005
    % when data sampling interval is greater than 5 ms, the noise can be
    % viewed as independent additive gaussian noise
    adaptedCur = curNF + randn(size(curNF)) * 4.5144;
end

end

