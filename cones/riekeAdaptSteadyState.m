function p = riekeAdaptSteadyState(bgR,p,sz)
% Steady-state background current calculated from the background rates.
%
%    initialState = riekeAdaptSteadyState(bgR,p,sz)
%
% Inputs
%  bgR:  Vector of background isomerization rates
%  p:    Parameter list (from riekeInit)
%  sz:   Sensor array size, (e.g., sensorGet(sensor,'size'))
%
% Returns
%  initialState:  The parameters in p augmented by additional terms needed
%                 for the dynamic calculation in riekeAdaptTemporal
%
% Example:
%   riekeAdaptSteadyState(1000,[],[1 1])
%
% HJ got the formula from Fred's slide.
% HJ/VISTASOFT Team, 2014

%% Programming note
%
% Notice that the computation is a search over a bounded variable.  The
% upper and lower bounds are huge for current and thus good enough to
% always find something, we think.

%% Parameters
if notDefined('bgR'), error('Background isomerization rate required.'); end
if notDefined('sz'), sz = [1 1]; warning('Assuming 1,1 array size'); end
if notDefined('p'),  p = riekeInit; end


%% Calculation
bgCur = zeros(size(bgR));
for ii=1:length(bgR)
    v = bgR(ii);
    bgCur(ii) = fminbnd(@(x) abs(x - (p.k*p.beta*p.cdark) * (p.smax*p.phi)^p.h / ...
        (v/p.sigma + p.eta)^p.h / (p.beta*p.cdark + p.q*x) / ...
        (1 + (p.q*x/p.beta/p.kGc)^p.n)^p.h), 0, 1000);
end

% Compute additional initial values
p.opsin   = ones(sz) * bgR / p.sigma;
p.PDE     = (p.opsin + p.eta) / p.phi;
p.Ca      = ones(sz) * bgCur * p.q / p.beta;
p.Ca_slow = p.Ca;
p.st      = p.smax ./ (1 + (p.Ca / p.kGc).^p.n);
p.cGMP    = p.st * p.phi ./ (p.opsin + p.eta);

p.bgCur = bgCur;

end