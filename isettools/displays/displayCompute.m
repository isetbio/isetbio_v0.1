function outImage = displayCompute(display, I, varargin)
%% function displayCompute(display, I, varargin)
%    This function computes the upsampling subpixel level image
%
%  Inputs:
%    display  - could be either display name or display structure, see 
%               displayCreate for detail
%    I        - input image, should be M*N*k matrix. k should be equal to
%               the number of primaries of display
%    varargin - parameters to be used, could contain
%       varargin{1} - scaler, upsampling scale
%
%  Output:
%    outImage - upsampled image, should be in Ms * Ns * k matrix. Default
%               value for upscaling factor s is equal to size(d.psfs, 1)
%
%  Example:
%    display  = displayCreate('LCD-Apple');
%    outImage = displayCompute(display, ones(128));
%    outImage = displayCompute('LCD-Apple', ones(128));
%    outImage = displayCompute('LCD-Apple', ones(128), 10);
%
%  (HJ) April, 2014

%% Init
%  check inputs and init parameters
if notDefined('display'), error('display required'); end
if notDefined('I'), error('Input image required'); end
if nargin > 2, s = varargin{1}; end

if ischar(display), display = displayCreate(display); end
if ischar(I), I = im2double(imread(I)); else I = double(I); end


%% Upsampling
nPrimary = displayGet(display, 'n primaries');
psfs = displayGet(display, 'psfs');
if isempty(psfs), error('psf not defined for display'); end
if ~exist('s', 'var'), s = size(psfs, 1); end
psfs = imresize(psfs, [s s]);

if ismatrix(I), I = repmat(I, [1 1 nPrimary]); end
[M,N,~] = size(I);
outImage = imresize(I, s, 'nearest');
outImage = outImage .* repmat(psfs, [M N 1]);

%% END