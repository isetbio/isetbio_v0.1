function [img, comment,displayGD] = ctdpLoadImage(ctDisplayW)
%Load image input data into the current window
%
%    ctdpLoadImage(ctDisplayW)
%
% Example:
%     dW = ctGetObject('displayW'); [img, comment,displayGD] = ctdpLoadImage(dW);
%     vd = displayGet(displayGD,'vd'); vd = vDisplaySet(vd,'inputImage',img);
%     displayGD = displaySet(displayGD,'vd',vd);
%     ctSetObject('display', displayGD); ctdpRefreshGUIWindow;
%
%     dW = ctGetObject('displayW');
%     vd = displayGet(displayGD,'vd');
%     outImage = vDisplayGet(vd,'outImage');
%     img = ctdpRendered2RGB(vd,outImage);
%     imtool(img)
%
% Wandell, 2006

img = []; comment = []; displayGD = [];

if ieNotDefined('ctDisplayW'), ctDisplayW=ctGetObject('displayFigure'); end
displayGD = guidata(ctDisplayW); 

vd = displayGet(displayGD,'vd');
vDisplayGet(vd,'nPrimaries')

% Read the Matlab file containing the same number of primary dimensions as
% the current display
fullName = vcSelectDataFile('stayPut','r');
if isempty(fullName), disp('User canceled'); return; end

tmp = load(fullName);
if isfield(tmp,'data'), img = double(tmp.data); end
if isfield(tmp,'comment'), comment = tmp.comment; end

return;
