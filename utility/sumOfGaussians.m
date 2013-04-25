function gaussianDistribution =  getGaussian(xySize, dXY, s, m)
%
%
%
%
%

%% Set parameters
defaultdXY = .1;
defaultS = [1 1];
defaultM = [0 0];

gaussFunc = @(X, Y, s)exp(-((X.^2)/(2*(s(1)^2)) + (Y.^2)/(2*(s(2)^2))));

%% Check input
if notDefined('xySize'), error('Undefined variable: xySize'); end;
if notDefined('dXY'), dXY = defaultdXY; end;
if notDefined('s'), s = defaultS; end;
if notDefined('m'), m = defaultM; end;



%% Perform calculation

% Calculate the grid-line locations for sampling the gaussian distribution.
xPoints = (0 : dXY(1) : xySize(1)); xPoints = xPoints - (xPoints(end) / 2) + m(1);
yPoints = (0 : dXY(2) : xySize(2)); yPoints = yPoints - (yPoints(end) / 2) + m(2);

% Create the X and Y value grids
[X Y] = meshgrid(xPoints, yPoints);

% Apply the gaussian functions
gaussianDistribution = gaussFunc(X, Y, s);

% Normalize the volume of the curve to 1
gaussianDistribution = gaussianDistribution ./ sum(gaussianDistribution(:));
