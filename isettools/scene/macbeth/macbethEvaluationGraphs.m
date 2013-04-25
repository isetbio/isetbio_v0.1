function figNum = macbethEvaluationGraphs(L,sensorRGB,idealRGB,sName)
% Evaluate linear fit L from sensor rgb to the ideal rgb of an MCC
%
%   figNum = macbethEvaluationGraphs(L,sensorRGB,idealRGB,sName)
%
% The linear transform L maps the sensor rgb into the linear rgb
% representation. We then convert to sRGB and do the evaluations of the
% observed and predicted RGB, various CIELAB error terms and chromaticity
% values.
%
% Key data in the graph are stored in the figure and can be acquired u sing
% get(gcf,'userData')
%
% See also: sensorCCM, macbethSensorValues
%
% Copyright ImagEval Consultants, LLC, 2010.

% Dump the linear transformation into the user-space
disp(L);

% Convert the sensor rgb to linear RGB representation
rgbL = sensorRGB*L;

% Prepare the figure
figNum =  vcSelectFigure('GRAPHWIN');
figure(figNum); clf
set(figNum,'name',sName);

% Observed and predicted linear RGB
subplot(1,2,1), plot(rgbL(:),idealRGB(:),'o');
xlabel('Observed (r,g,b)'); ylabel('Desired (r,g,b)');
grid on

% Figure out the XYZ of the ideal MCC under D65
idealSRGB = lrgb2srgb(idealRGB);
idealSRGB = XW2RGBFormat(idealSRGB,1,24);

% In this calculation, the (1,1,1) value of the display has unit luminance.
% That is the default.  If we want the real display luminance, we need to
% pass it in.  This applies to both the ideal and the estimated, so there
% is no problem in failing to scale.  I confirmed this by running the
% routine with XYZ values scaled by 100 - there was no difference. BW.
idealXYZ  = srgb2xyz(idealSRGB);

% Figure out XYZ of the transformed sensor RGB
rgbLSRGB = lrgb2srgb(ieClip(rgbL,0,1));
rgbLSRGB = XW2RGBFormat(rgbLSRGB,1,24);
rgbLXYZ = srgb2xyz(rgbLSRGB);

% Which white point to use?  Ideal or Sensor?
whiteXYZ = squeeze(idealXYZ(1,1,:));
% whiteXYZ = squeeze(rgbLXYZ(1,1,:));
dE = deltaEab(rgbLXYZ,idealXYZ,whiteXYZ);

% CIELAB error histogram
subplot(1,2,2)
hist(dE,15);
title('Color error');
xlabel('Delta E_{ab}'); ylabel('Count');
str = sprintf('Mean dE_{ab} %.02f',mean(dE(:)));
plotTextString(str,'ur');
grid on

% Stuff the data into userData
userData.idealXYZ = RGB2XWFormat(idealXYZ);
userData.rgbLXYZ  = RGB2XWFormat(rgbLXYZ);
userData.idealRGB = idealRGB;
userData.rgbL     = rgbL;
userData.dE = dE(:);
set(gcf,'userdata',userData);

return;