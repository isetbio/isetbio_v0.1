function bgCur = riekeAdaptSteadyState(bgR,p)
% Steady-state background current calculated from the background rates.
%
%    bgCur = riekeAdaptSteadyState(bgR,p)
%
% bgR:  Vector of background isomerization rates
% p:    Parameter list (from riekeInit)
%
% bgCur: Current for each steady-state background rate in bgR
%
% This calculation is complicated enough that we thought we should put it
% here for now, and maybe pull it out as its own function in the future.
%
% Example:
%   riekeAdaptSteadyState(1000:1000:5000)
%
% HJ got the formula from Fred's slide.
% HJ/VISTASOFT Team, 2014

% Notice that this is a search over a bounded variable.  The upper and
% lower bounds are huge for current and thus good enough to always find
% something, we think.

if notDefined('p'),  p = riekeInit; end

bgCur = zeros(size(bgR));
for ii=1:length(bgR)
    v = bgR(ii);
    bgCur(ii) = fminbnd(@(x) abs(x - (p.k*p.beta*p.cdark) * (p.smax*p.phi)^p.h / ...
        (v/p.sigma + p.eta)^p.h / (p.beta*p.cdark + p.q*x) / ...
        (1 + (p.q*x/p.beta/p.kGc)^p.n)^p.h), 0, 1000);
end

% Can we check the solution somehow?

end