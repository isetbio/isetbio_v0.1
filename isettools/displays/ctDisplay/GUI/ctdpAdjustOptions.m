function ctdpAdjustOptions(hObject)
% Configure the options for display measurement
%
%  ctdpAdjustOptions(hObject);
%
% Purpose:
%
%
% Example:
%

cellPrompts={'The default comm port of your PR650', ...
    'The default number of gray level of your dipslay', ...
    'The default number of samples taken in order to smooth data', ...
    'Which monitor are you measuring?', ...
    'The horizontal size of the 2nd monitor (pixels)',...
    'The vertical size of the 2nd monitor (pixels)',...
    'The pause time before measurement starts'...
    };

displayGD=ctGetObject('display');

strTemp1=sprintf('%d', displayGet(displayGD, 'm_nDefaultCommPort'));
strTemp2=sprintf('%d', displayGet(displayGD, 'm_nDefaultNumberOfGrayLevels'));
strTemp3=sprintf('%d', displayGet(displayGD, 'm_nDefaultNumberOfSamples'));
strTemp4=sprintf('%d', displayGet(displayGD, 'm_bDefaultWorkingMonitor'));
strTemp5=sprintf('%d', displayGet(displayGD, 'm_n2ndMonitorSizeX'));
strTemp6=sprintf('%d', displayGet(displayGD, 'm_n2ndMonitorSizeY'));
strTemp7=sprintf('%d', displayGet(displayGD, 'm_nPauseTimeInSeconds'));

cellDefaultAnswers={strTemp1, strTemp2, strTemp3, strTemp4, strTemp5, strTemp6, strTemp7};
strDlgTitle='Input for the display measurement options ... ';
cellInputs=ieInputDlgNumericWithBounds(cellPrompts, cellDefaultAnswers, strDlgTitle, {'(round(x)>0)', '(round(x)>0)', '(round(x)>0)', '(round(x)>0 && round(x)<3)', '(round(x)>0)', '(round(x)>0)', '(round(x)>0)'});
if ~(length(cellInputs)==0)
    if ~isequal(displayGet(displayGD, 'm_nDefaultCommPort'), cellInputs{1}) || ...
            ~isequal(displayGet(displayGD, 'm_nDefaultNumberOfGrayLevels'), cellInputs{2}) || ...
            ~isequal(displayGet(displayGD, 'm_nDefaultNumberOfSamples'), cellInputs{3}) || ...
            ~isequal(displayGet(displayGD, 'm_bDefaultWorkingMonitor'), cellInputs{4}) || ...
            ~isequal(displayGet(displayGD, 'm_n2ndMonitorSizeX'), cellInputs{5}) || ...
            ~isequal(displayGet(displayGD, 'm_n2ndMonitorSizeY'), cellInputs{6}) || ...
            ~isequal(displayGet(displayGD, 'm_nPauseTimeInSeconds'), cellInputs{7})
        
        displayGD=displaySet(displayGD, 'm_nDefaultCommPort', round(cellInputs{1}));
        displayGD=displaySet(displayGD, 'm_nDefaultNumberOfGrayLevels',round(cellInputs{2}));
        displayGD=displaySet(displayGD, 'm_nDefaultNumberOfSamples',round(cellInputs{3}));
        displayGD=displaySet(displayGD, 'm_bDefaultWorkingMonitor',round(cellInputs{4}));
        displayGD=displaySet(displayGD, 'm_n2ndMonitorSizeX',round(cellInputs{5}));
        displayGD=displaySet(displayGD, 'm_n2ndMonitorSizeY',round(cellInputs{6}));
        displayGD=displaySet(displayGD, 'm_nPauseTimeInSeconds',round(cellInputs{7}));
       
        ctSetObject('display', displayGD);
        
        ctdpRefreshGUIWindow(hObject);
        
    end;
end;
