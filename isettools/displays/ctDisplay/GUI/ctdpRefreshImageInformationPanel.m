disp('**Obsolete**'); evalin('caller','mfilename'); return;
function ctRefreshImageInformationPanel(hObject);
disp('**Obsolete**'); evalin('caller','mfilename'); return;
% Helper function to refresh the Information panel in vDisplay GUI
disp('**Obsolete**'); evalin('caller','mfilename'); return;
% window.

s=guidata(hObject);

fPixelSizeX=s.m_objVirtualDisplay.ImagePixelSizeX*1000; %now in um
fPixelSizeY=s.m_objVirtualDisplay.ImagePixelSizeY*1000;
nNumberOfPrimaries=s.m_objVirtualDisplay.NumberOfPrimaries;
fDynamicRange=s.m_objVirtualDisplay.ImageDynamicRange;
fMeanIntensity=s.m_objVirtualDisplay.ImageMeanIntensity;
[fImageSizeY, fImageSizeX, nTemp]=size(s.m_objVirtualDisplay.ImageRawData);
fImageSizeX=round(fImageSizeX*s.m_objVirtualDisplay.ScalingFactorX);
fImageSizeY=round(fImageSizeY*s.m_objVirtualDisplay.ScalingFactorY);

%vdRecalculateVisualAngle;
%Here the visual angles of vDisplay are determined by the stimulus size and
%the viewing distance. Hence if there is any change of in image size or
%viewing distance, we need to recalculate it. I decided to put it here
%since this is a single point of contact.

handles=guihandles(hObject);
textImagePixelSizeX=handles.textImagePixelSizeX;
textImagePixelSizeY=handles.textImagePixelSizeY;
textNumberOfPrimaries=handles.textImageNumberOfPrimaries;
textDynamicRange=handles.textImageDynamicRange;
textMeanIntensity=handles.textImageMeanIntensity;
textImageSizeX=handles.textImageSizeX;
textImageSizeY=handles.textImageSizeY;

set(textImagePixelSizeX, 'String', sprintf('%4.2f', fPixelSizeX));
set(textImagePixelSizeY, 'String', sprintf('%4.2f', fPixelSizeY));
set(textNumberOfPrimaries, 'String', sprintf('%d', nNumberOfPrimaries));
set(textDynamicRange, 'String', sprintf('%4.2f', fDynamicRange));
set(textMeanIntensity, 'String', sprintf('%4.2f', fMeanIntensity));
set(textImageSizeX, 'String', sprintf('%d', fImageSizeX));
set(textImageSizeY, 'String', sprintf('%d', fImageSizeY));
