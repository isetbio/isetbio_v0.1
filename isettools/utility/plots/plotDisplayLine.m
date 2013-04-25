function plotDisplayLine(ori, figNum, vci)
%Graph the values across a line in the vcimage window
%
%   plotDisplayLine([ori = 'h'], [figNum = current GraphWin], [vci = current])
%
% Purpose:
%    The line plot must pass through a point xy selected by the user.  The
%    line orientation (h or v) ori, is passed as a calling argument (ORI). 
%    Monochrome and color data are handled in various ways.  
%   
%    The plotted values are attached the graph window and can be obtained
%    using a data = get(figNum,'userdata') call.
%
% Examples:
%    plotDisplayLine('h')
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('ori'), ori = 'h'; end
if ieNotDefined('figNum'), figNum =  vcSelectFigure('GRAPHWIN'); end
if ieNotDefined('vci'), [val,vci] = vcGetSelectedObject('VCIMAGE'); end

vciHandles = ieSessionGet('processorimagehandle');
% Find the line in the sensor window.
switch lower(ori)
    case 'h'
        ieInWindowMessage('Select horizontal line',vciHandles,[]);
    case 'v'
        ieInWindowMessage('Select vertical line',vciHandles,[]);
    otherwise
        error('Unknown orientation')
end

% Make sure the cursor is in the sensor image (call back) window
figure(gcbf);
[x,y,button] = ginput(1); 
ieInWindowMessage('',vciHandles);

xy = [round(x(end)),round(y(end))];

data = imageGet(vci,'result');
if isempty(data), error(sprintf('Results not computed in display window.')); end

plotSetUpWindow(figNum);
plotColorDisplayLines(xy,data,ori,figNum);

return;

%-----------------------------
function plotColorDisplayLines(xy,data,ori,figNum);
%
% Internal routine:  plot color line data from display data
%

switch lower(ori)
    case {'h','horizontal'}
        lData = squeeze(data(xy(2),:,:));
        titleString =sprintf('ISET:  Horizontal line %.0f',xy(2));
        xstr = 'Col number';
    case {'v','vertical'}
        lData = squeeze(data(:,xy(1),:));
        titleString =sprintf('ISET:  Vertical line %.0f',xy(1));
        xstr = 'Row number';
    otherwise
        error('Unknown line orientation');
end


% Extract the data and assign a line color corresponding to the cfa color.
pos = 1:size(lData,1);
colordef = {'r-','g-','b-'};
for ii=1:3
    subplot(1,3,ii)
    plot(pos,lData(:,ii),colordef{ii})
    grid on; set(gca,'xlim',[pos(1), pos(end)]);
    if ii==1, ylabel('Digital value'); end
    if ii==2,  title(titleString); xlabel(xstr); end
end

uData.values = lData;

% Attach data to figure and label.
set(figNum,'userdata',uData);
set(figNum,'NumberTitle','off');
set(figNum,'Name',titleString);

return;
