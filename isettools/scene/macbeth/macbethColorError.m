function [macbethLAB, macbethXYZ, dE, vci] = macbethColorError(vci,illName,cornerPoints,method)
% Analyze color error of a MCC in the image processor window
%
%  [macbethLAB, macbethXYZ, deltaE, vci] = ...
%        macbethColorError(vci,illName,cornerPoints,method)
%
% The user interactively identifies the position of the MCC in the image
% processor window. This routine performs several analyses of the RGB MCC
% data and plots the results.  These are 
%
%  - Comparison of the data and ideal chart CIELAB values
%  - Comparions of the chromaticity (xy) values
%  - Comparison of the gray series L* values
%  - A histogram of delta E values between the data and ideal
%
% vci:     A virtual camera image from ISET containing the processed MCC.
%          ON the return, the corner points of the MCC are stored in the structure.
% illName:      The illuminant assumed for the MCC
% cornerPoints: A rect defining the outer points of the MCC.  The order of
%               the outer corners is white, gray, blue, brown
% method:   This defines the color space of the vci image data in the
%           result field. Default 'sRGB'.  You can set method = 'custom'
%           to use the monitor model stored in the vci.
%
% Example:
%   vci = vcGetObject('vcimage');
%   [macbethXYZ, whiteXYZ] = vcimageMCCXYZ(vci);
%
% Copyright ImagEval Consultants, LLC, 2003.

% Programming notes:  Could add display gamut to chromaticity plot

%% Check variables
if ieNotDefined('vci'),     vci = vcGetObject('vcimage'); end
if ieNotDefined('illName'), illName = 'd65'; end

% cornerPoints has the coordinates of the corners of the MCC. 
if ieNotDefined('cornerPoints'), cornerPoints = []; end
% Either custom or sRGB calculation styles
if ieNotDefined('method'), method = 'sRGB'; end

%% Retrieve ideal and image MCCdata LAB and XYZ values

% These are the XYZ values from the Processor window.  They are computed
% using a model monitor with unit luminance at max (Y = 1 cd/m2).
[macbethXYZ, whiteXYZ, cornerPoints] = vcimageMCCXYZ(vci,cornerPoints,method);
vci = imageSet(vci,'mcc corner points',cornerPoints);

% These are the computed values of the Ideal color checker in an sRGB
% monitor.  The idealXYZ values are computed under the assumption that the
% peak luminance of the display is 100 cd/m2.  Perhaps that should be
% changed to unit luminance.
idealXYZ = macbethIdealColor(illName,'xyz');
whiteXYZ = idealXYZ(1,:);

% The max ideal luminance is whiteXYZ(2), so we scale by this quantity to
% put idealXYZ and macbethXYZ in the same range.
macbethXYZ = (macbethXYZ/macbethXYZ(1,2))*whiteXYZ(2);
% vcNewGraphWin; plot(macbethXYZ(:),idealXYZ(:),'.')
% axis equal, grid on


%% Initialize figure
vcNewGraphWin([],'tall'); clf;
set(gcf,'name',sprintf('VCIMAGE: %s',imageGet(vci,'name')))

% p = get(gcf,'Position');
%set(gcf,'Units','normalized','Position',[.1 .5 .4 .4]);

%% Compare LAB positions of the patches
subplot(3,1,1), 

% We always use the Ideal white XYZ, even for the data
idealLAB = macbethIdealColor(illName,'lab');
macbethLAB = xyz2lab(macbethXYZ,whiteXYZ);

plot(macbethLAB(:,2),macbethLAB(:,3),'o')
line([idealLAB(:,2),macbethLAB(:,2)]',...
    [idealLAB(:,3),macbethLAB(:,3)]'); 

xlabel('a (red-green)'); ylabel('b (blue-yellow)')
grid on; axis square
title('CIELAB color plane')

%% Show histogram of delta E errors
subplot(3,1,2)

% We compute the delta E difference between the data and the ideal
dE = deltaEab(macbethXYZ,idealXYZ,whiteXYZ);   
hist(dE); grid on; axis square
title(sprintf('Mean deltaE = %.2f',mean(dE)));

%% Show the gray series
subplot(3,1,3)

plot(1:6,macbethLAB(1:4:24,1),'-o',1:6,idealLAB(1:4:24,1),'x'); 
xlabel('Gray patch'); ylabel('L*');  axis square; grid on; 
title('Achromatic series')

%% Compare the chromaticities of the ideal and current Processor data

% Exclude very black surfaces from chromaticity plot.
list = find(macbethXYZ(:,2) > 0.01);
xy = chromaticity(macbethXYZ(list,:)); 
idealxy = chromaticity(idealXYZ(list,:));

chromaticityPlot(xy,'gray',256,1);
hold on;
line([idealxy(:,1),xy(:,1)]',[idealxy(:,2),xy(:,2)]'); 


%% Store the data in the figure
uData.macbethXYZ =  macbethXYZ;
uData.macbethLAB = macbethLAB;
uData.idealLAB   = idealLAB;
uData.deltaE     = dE;

set(gcf,'userdata',uData);

return;