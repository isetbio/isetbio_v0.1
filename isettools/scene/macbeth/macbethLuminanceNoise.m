function [yNoise,mRGB] = macbethLuminanceNoise(vci,pointLoc)
% Analyze luminance noise in gray series of MCC fromimage processor window
%
%   [yNoise,mRGB] = macbethLuminanceNoise(vci)s
%
% 
% Copyright ImagEval Consultants, LLC, 2003.

% Programming notes:  Could add display gamut to chromaticity plot

if ieNotDefined('vci'),vci = vcGetObject('vcimage'); end
if ieNotDefined('pointLoc'), pointLoc=[]; end

% Return the full data from all the patches
mRGB = macbethSelect(vci,0,1,pointLoc);

% Compute the std dev and mean for each patch.  The ratio is the contrast
% noise.
jj = 1;
for ii=1:4:24
    rgb = mRGB{ii};
    macbethXYZ = imageRGB2XYZ(vci,rgb);
    Y = macbethXYZ(:,2);
    yNoise(jj) = 100*(std(Y)/mean(Y));
    jj = jj+1;
end

figNum = vcSelectFigure('GRAPHWIN');
figure(figNum); clf;
str = sprintf('%s: MCC luminance noise',imageGet(vci,'name'));
set(gcf,'name',str);

plot(yNoise);
line([1 6],[3 3],'Linestyle','--')
grid on
xlabel('Gray patch (white to black)')
ylabel('Percent luminance noise (std(Y)/mean(Y))x100');

return;

