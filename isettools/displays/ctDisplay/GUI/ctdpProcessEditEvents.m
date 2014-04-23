function ctdpProcessEditEvents(hObject, strLabel);
% Adjust display parameters after an edit
%
%   ctdpProcessEditEvents(hObject, strLabel);
%
% Parameters are 
%    NumberOfPrimaries, PixelSize, NumberOfSubPixelsPerBlock,
%    NumberOfVirtualPixelsPerBlockX, NumberOfVirtualPixelsPerBlockY,
%    ViewingDistasnce
%
%

disp('Obsolete?')
evalin('caller','mfilename')

% Programming TODO:
% The parameter adjustments should all be adjusted using set() calls.
% The SizeInUmX should become SizeInUm at some point.  It currently is X
% because there used to be a Y.

displayGD= ctGetObject('display');
vdisplay = displayGet(displayGD,'vdisplay');

% All of the values are doubles?  Always?
nValue=str2double(get(gcbo,'String'));

switch strLabel
    case 'NumberOfPrimaries'
        nValue=round(nValue);
        if isnan(nValue) || nValue<=0
            ctdpRefreshGUIWindow(hObject);
            return;
        end;

        vdisplay=vDisplaySet(vdisplay, 'NumberOfPrimaries', nValue);

    case {'PixelSizeInUmX','PixelSizeInUmY','PixelSizeInUm'}
        % We only treat square pixel case for now.  Probably forever.
        if isnan(nValue) || nValue<=0
            ctdpRefreshGUIWindow(hObject);
            return;
        end;

        vdisplay=vDisplaySet(vdisplay, 'PixelResolutionX', iePixelSizeInMm2PixelResolutionInPPI(nValue/1000));
        vdisplay=vDisplaySet(vdisplay, 'PixelResolutionY', iePixelSizeInMm2PixelResolutionInPPI(nValue/1000));
        vdisplay=vDisplaySet(vdisplay, 'PixelSizeInMmX', nValue/1000);
        vdisplay=vDisplaySet(vdisplay, 'PixelSizeInMmY', nValue/1000);

    case 'NumberOfSubPixelsPerBlock'
        nValue=round(nValue);
        if isnan(nValue) || nValue<=0
            ctdpRefreshGUIWindow(hObject);
            return;
        end;
        vdisplay = vDisplaySet(vdisplay,'NumberOfSubPixelsPerBlock', nValue);
        
    case 'NumberOfVirtualPixelsPerBlockX'
        nValue=round(nValue);
        if isnan(nValue) || nValue<=0
            ctdpRefreshGUIWindow(hObject);
            return;
        end;
        vdisplay = vDisplaySet(vdisplay,  'NumberOfPixelsPerBlockX', nValue);
        
    case 'NumberOfVirtualPixelsPerBlockY'
        nValue=round(nValue);
        if isnan(nValue) || nValue<=0
            ctdpRefreshGUIWindow(hObject);
            return;
        end;
        vdisplay = vDisplaySet(vdisplay, 'NumberOfPixelsPerBlockY', nValue);
        
    case 'ViewingDistance'
        if isnan(nValue) || nValue<=0
            ctdpRefreshGUIWindow(hObject);
            return;
        end;
        vdisplay = vDisplaySet(vdisplay,'ViewingDistance', nValue);
end;

displayGD=displaySet(displayGD,'m_bIsMainImageDirty', 1);
displayGD=displaySet(displayGD,'vdisplay', vdisplay);
ctSetObject('display', displayGD);

ctdpRefreshGUIWindow(hObject);

return;
