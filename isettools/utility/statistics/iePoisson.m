function val = iePoisson(lambda,nSamp)
% Create a matrix of Poisson samples using rate parameters in lambda
%
%   val = iePoisson(lambda,nSamp)
%
% The rate parameter can be a scalar, requesting multiple samples, or it
% can be a matrix of rate parameters.
%
% This algorithm is from Knuth.
%
% This script replaces the Matlab poissonrnd function because that function
% is only in the stats toolbox.
%
% The function is used in ISET when we find the pixels with a mean of less
% than, say 10, in which case the normal approximation doesn't work well.
% In that case we over-write the Gaussian shot noise at those locations
% with  Poisson random values. We could use this for all of the values if
% it turns out this routine runs fast enough.
%
% See also: noiseShot
%
% Examples (see Run Configuration in Debug):
% % Matrix form
%   nSamp = 128;
%   lambda = round(rand(nSamp,nSamp)*10);
%   tic, val = iePoisson(lambda); toc
%   figure(1); clf
%   subplot(2,1,1), imagesc(lambda); colormap(gray);colorbar; axis image
%   subplot(2,1,2), imagesc(val); colormap(gray); colorbar; axis image
%
% % Multiple samples form
%   lambda = 4; nSamp = 1000;
%   val = iePoisson(lambda,nSamp);
%   figure(1); clf, hist(val,50)
%
% Reference: Knuth routine - found on a web-page reference and also at
%   http://en.wikipedia.org/wiki/Poisson_distribution
%   http://www.columbia.edu/~mh2078/MCS04/MCS_generate_rv.pdf
%
% Copyright ImagEval, LLC, 2010

if ieNotDefined('lambda'), error('rate parameter lambda required'); end

% Check for stats toolbox
lic = license('inuse');
nFeatures = length(lic);
for ii=1:nFeatures
    if strmatch('stats',lic(ii).feature)
        % Matlab toolbox version is present.  Use it.
        val = poissrnd(lambda);
        return
    end
end


% Use the local ISET methods
if ~isempty(which('iePoissrnd'))
    % Plans for Imageval mex-files to speed this up.
    val = iePoissrnd(lambda);
else
    % Matlab implementation
    if isscalar(lambda)
        % Scalar version of the routine
        % Probably we want multiple samples for a single lambda
        if ieNotDefined('nSamp'), nSamp = 1; end
        
        L =  exp(-lambda);
        val = zeros(1,nSamp);
        for nn=1:nSamp
            kk = 0;
            p = 1;
            while(p>L)
                kk = kk+1;
                u = rand(1,1);
                p = p*u;
            end
            val(nn) = kk-1;
        end
        % figure(1); hist(val,50)
    else
        % A matrix or vector of lambdas and we return samples for each
        [r,c] = size(lambda);
        val = -1*ones(size(lambda));
        
        % There is a challenge with the routine because we have to search through a
        % number of iterations, and the number depends on the largest value.  This
        % is why the routine is probably too slow for practical use and large
        % numbers.
        mx = max(lambda(:))*7;
        
        L   = exp(-lambda);
        for ii=1:numel(L)
            prodU = cumprod(rand(1,ceil(mx)));
            val(ii) = length(find(L(ii) < prodU));
        end
        val = reshape(val,r,c);
    end
end

return
