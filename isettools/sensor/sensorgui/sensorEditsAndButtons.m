function sensorEditsAndButtons(handles,ISA)
%Update the sensor image window interface
%
%   sensorEditsAndButtons(handles,[ISA])
%
% Update the sensor image window contents with data using data in the
% currently selected ISA (image sensor array) or another one that is passed
% in. Called regularly by sensorImageWindow.
%
% Copyright ImagEval Consultants, LLC, 2003.
if ieNotDefined('ISA'), [val,ISA] = vcGetSelectedObject('ISA'); end
figure(vcSelectFigure('ISA'));
ieInWindowMessage('',ieSessionGet('sensorwindowhandles'));
  
% Sensor (ISA) properties
str = sprintf('%.0f',sensorGet(ISA,'rows')); set(handles.editISARows,'string',str);
str = sprintf('%.0f',sensorGet(ISA,'cols')); set(handles.editISAcols,'string',str);

t = sensorGet(ISA,'geometricMeanExposureTime');  % In seconds
u = log10(t);
if u >= 0, 
    str = sprintf('%.2f',sensorGet(ISA,'geometricMeanExposureTime')); 
    set(handles.txtExposureUnits,'string','(sec)');
elseif u >= -3, 
    str = sprintf('%.2f',sensorGet(ISA,'geometricMeanExposureTime')*10^3); 
    set(handles.txtExposureUnits,'string','(ms)');
else 
    str = sprintf('%.2f',sensorGet(ISA,'geometricMeanExposureTime')*10^6); 
    set(handles.txtExposureUnits,'string','(us)');
end
set(handles.editExpTime,'string',str);

% Set the slider in the case of bracketed exposures.
nExposures = sensorGet(ISA,'nExposures');
if nExposures > 1
    set(handles.sliderSelectBracketedExposure,'max',nExposures);
    set(handles.sliderSelectBracketedExposure,'value',sensorGet(ISA,'Exposure Plane'));
    if nExposures > 1, ss = 1/(nExposures-1);
    else               ss = 0; end
    set(handles.sliderSelectBracketedExposure,'sliderStep',[ss ss]);
end


str = sprintf('%3.1f',sensorGet(ISA,'gain'));    
set(handles.editGainFPN,'string',str);

% The offset is stored in volts.  It is displayed in millivolts.
str = sprintf('%3.1f',sensorGet(ISA,'offset')*1000);  
set(handles.editOffsetFPN,'string',str);

% Pixel properties
PIXEL = sensorGet(ISA,'pixel');

%  Dark Voltage displayed in millivolts
str = sprintf('%2.1f',pixelGet(PIXEL,'darkvolt')*10^3);   %
set(handles.editDarkCurrent,'string',str);

str = sprintf('%.01f',pixelGet(PIXEL,'conversiongain')*(10^6)); 
set(handles.editConvGain,'string',str);
str = sprintf('%4.1f',pixelGet(PIXEL,'readnoisemillivolts'));   % Read noise displayed in mV
set(handles.editReadNoise,'string',str);
str = sprintf('%2.2f',pixelGet(PIXEL,'voltageswing')); 
set(handles.editVoltageSwing,'string',str);

% Header strings
set(handles.txtISADescription,'string',sensorDescription(ISA));
set(handles.txtPixelDescription,'string',pixelDescription(PIXEL));

% Decide whether or not to display the popup menu for custom sensorCompute.
if get(handles.btnCustomCompute,'Value')
    set(handles.popCustomCompute,'Visible','on');

    % Make sure the popup points to the currently selected method
    contents = get(handles.popCustomCompute,'String');
    method = sensorGet(ISA,'sensorCompute');
    if isempty(method), method = 'sensorCompute'; end
    for ii=1:length(contents)
        if strcmp(method,contents{ii})
            set(handles.popCustomCompute,'Value',ii);
            break;
        end
    end
    
    % Write a routine that hides all of the unwanted (irrelevant) pulldowns
    % in the sensor window.  The inverse of this routine should be in the
    % else part, turning them all back on.
else
    set(handles.popCustomCompute,'Visible','off');
    % Turn on all the popups and so forth
end


% If the incoming call set consistency true, then we eliminate the red
% square on the window.  Otherwise, consistency is false.  We always set it
% to false on the way out.
%
% This is now a problem.  THere are some buttons and sliders on the sensor
% window that change the display (e.g., Exposure plane slider, gamma and
% scale) but leave the data accurate.  When those are touched we turn on
% the red spot.  It shouldn't get turned on.  So we need to indicate that.
%
% We could shift the code so that we don't always turn consistency false
% here by re-writing all the calls and have them decide.  That puts a lot
% of code into the callbacks in the sensorImageWndow.  Another is to put a
% special value, say -1, into the consistency field and when we see we know
% that the callback is through a mechanism that didn't hurt the sensor
% data.
c = sensorGet(ISA,'consistency');
if isequal(c,1)
    % We know the data are consistent.  Get rid of the red spot.
    %
    % We think this is the monitor default gray or white or whatever.  We
    % could use a different default as in the ISET main window and keep
    % this consistent with that.
    defaultBackground = get(0,'defaultUicontrolBackgroundColor');
    set(handles.txtConsistency,'BackgroundColor',defaultBackground)
    
    % Assume any change will make it inconsistent going forward.
    ISA = sensorSet(ISA,'consistency',0);
    vcReplaceObject(ISA);
elseif isequal(c,0)
    % The data are inconsistent.  Put on the red spot.
    set(handles.txtConsistency,'BackgroundColor',[1,0,0]);
else
    % In the case when we have a slider or something that doesn't influence
    % the data and we don't want to influence the red spot because we just
    % don't know, well, just don't do anything.  But when we are done, put
    % it back to inconsistent, as above.
    ISA = sensorSet(ISA,'consistency',0);
    vcReplaceObject(ISA);
end

% Button states
set(handles.btnAutoExp,'Value',sensorGet(ISA,'autoexposure'));

%% mp, Nov., 2009
% Exposure mode settings. Placing these lines here is somewhat redundant.
% We want to do these things only when we draw the sensor window for the
% first time. Any changes made to exposure mode later (from the drop down
% menu) will be accounted for by the drop down menu's callback
% (popupExpMode_Callback)

sensor = vcGetObject('sensor');
exposureMethod = sensorGet(sensor,'exposureMethod');
switch exposureMethod(1:3)
    case 'sin'  % singleExposure
        
        set(handles.popupExpMode,'value',1);
        set(handles.btnAutoExp,'visible','on');
        set(handles.editExpTime,'visible','on');
        set(handles.btnShowCFAExpDurations,'visible','off');
        set(handles.editNExposures,'visible','off');
        set(handles.editExpFactor,'visible','off');
        set(handles.sliderSelectBracketedExposure,'visible','off');
        set(handles.txtBracketExposure,'visible','off');

    case 'bra'  % bracketedExposure
        
        set(handles.popupExpMode,'value',2);
        set(handles.editExpTime,'visible','on');
        set(handles.sliderSelectBracketedExposure,'visible','on');
        set(handles.editNExposures,'visible','on');
        set(handles.editExpFactor,'visible','on');
        set(handles.btnShowCFAExpDurations,'visible','off');

        set(handles.btnAutoExp,'visible','off');
        set(handles.txtBracketExposure,'visible','on');

    case 'cfa'  % cfaExposure
        set(handles.popupExpMode,'value',3);
        set(handles.btnAutoExp,'visible','on');
        set(handles.btnShowCFAExpDurations,'visible','on');
        set(handles.editExpTime,'visible','off');
        set(handles.editNExposures,'visible','off');
        set(handles.editExpFactor,'visible','off');
        set(handles.sliderSelectBracketedExposure,'visible','off');
        set(handles.txtBracketExposure,'visible','off');               
        
    otherwise
        error('Unknown exposure method %s\n',exposureMethod);
end

%%

% Select popup contents
nameList = vcGetObjectNames('ISA');
selectList = {'New'};
for ii=1:length(nameList); selectList{ii+1} = char(nameList{ii}); end
set(handles.popupSelect,...
    'String',selectList,...
    'Value',vcGetSelectedObject('ISA')+1);

% Ugh, the pop up selections must match the list sensorCFAName, and so
% should the list in Standard CFA.  Then we just do a match and we keep
% everything consistent through the sensorCFAName routine.  This code must
% go.
switch lower(sensorGet(ISA,'cfaname'))
    case 'bayer-grbg'
        set(handles.popISA,'Value',1);
    case 'bayer-rggb'
        set(handles.popISA,'Value',2);
    case 'bayer-bggr'
        set(handles.popISA,'Value',3);
    case 'bayer-gbrg'
        set(handles.popISA,'Value',4);
    case 'bayer-ycmy'
        set(handles.popISA,'Value',5);
    case 'monochrome'
        set(handles.popISA,'Value',6);
    case 'four color'
        set(handles.popISA,'Value',7);
    otherwise
        set(handles.popISA,'Value',7);
end

% Display the quantization method
switch lower(sensorGet(ISA,'quantizationmethod'))
    case 'analog'
        set(handles.popQuantization,'Value',1);
    case 'linear'
        switch sensorGet(ISA,'nbits')
            case 4
                set(handles.popQuantization,'Value',2);
            case 8
                set(handles.popQuantization,'Value',3);
            case 10
                set(handles.popQuantization,'Value',4);
            case 12
                set(handles.popQuantization,'Value',5);
            otherwise
                warning('Unknown quantization'); %#ok<WNTAG>
                set(handles.popQuantization,'Value',1);
        end
    otherwise
        set(handles.popISA,'Value',1);
end

% Display the image.
gam = str2double(get(handles.editGam,'String'));
scaleMax = get(handles.btnDisplayScale,'Value');

if isempty(sensorGet(ISA,'dv')), sensorShowImage(ISA,'volts',gam,scaleMax);
else                             sensorShowImage(ISA,'dv',gam,scaleMax);
end

return;


