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
%      .seed  - noise seed
%
%  Outputs:
%    adaptedCur - membrance current with noise added
%
%  See also:
%    coneAdapt, riekeAdaptSteadyState, riekeAdaptTemporal
%
%  Notes:
%    This function assumes a time interval of 5e-5 secs. HJ should update
%    this function to be more flexible.
%
%  (HJ) ISETBIO, 2014

%% Init
if notDefined('curNF'), error('noise-free adapted current required'); end
if notDefined('params'), params = []; end

if isfield(params, 'seed'), rng(params.seed); else params.seed = rng; end

%% Build model
%  Make sure curNF is [row, col, time] 3D matrix
if isvector(curNF), curNF = reshape(curNF, [1 1 length(curNF)]); end

%  compute size
[c, r, nFrames] = size(curNF);

% build arima model
mdl = arima('AR', [1.518 -0.969923 0.421612], ...
            'D', 0, ...
            'MA', [1.11884 0.498774]);

%% Generate noise
adaptedCur = zeros(r,c,nFrames);
for ii = 1 : c
    for jj = 1 : r
        noise = simulate(mdl, nFrames);
        adaptedCur(ii, jj, :) = curNF(ii, jj, :) + noise;
    end
end

end

