function varargout = displayWindow(varargin)
% display main window
%
% This is the main GUI window for interfacing with the Display Simulator
% design functions.  From this window you can visualize the sub-pixels,
% load simple images, and perform various analytical calculations using the
% display.  
%
% The display radiance data can also be converted into an ISET Scene format
% and thus transferred into the ISET analysis tools.
%
% This function brings up the window to edit display properties
%
%      displayWindow, by itself, creates a new display or raises the
%      existing singleton.
%
%      H = displayWindow returns the handle to a new or the the existing
%      singleton.
%
%      displayWindow('Property','Value',...) creates a new CTDISPLAY using
%      the given property value pairs. Unrecognized properties are passed
%      via varargin to ctDisplay_OpeningFcn.  This calling syntax produces
%      a warning when there is an existing singleton*.
%
%      CTDISPLAY('CALLBACK') and CTDISPLAY('CALLBACK',hObject,...) call the
%      local function named CALLBACK in CTDISPLAY with the given input
%      arguments.
%
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% (c) Stanford, PDCSOFT, Wandell, 2010

% Edit the above text to modify the response to help ctDisplay

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ctDisplay_OpeningFcn, ...
                   'gui_OutputFcn',  @ctDisplay_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
return;

% --- Executes just before ctDisplay is made visible.
function ctDisplay_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% Refresh handles structure
guidata(hObject, handles);

if isempty(ctGetObject('displayW'))
    ctSetObject('displayFigure', hObject);
    ctdpInitializeSession;
else
    menuRefresh_Callback(hObject, eventdata, handles);
end

return;

% --- Outputs from this function are returned to the command line.
function varargout = ctDisplay_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

return;

% --------------------------------------------------------------------
function menuLCD_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuProductHelp_Callback(hObject, eventdata, handles)
disp('Will bring up PDF Manual')
return;

% --------------------------------------------------------------------
function menuAbout_Callback(hObject, eventdata, handles)
disp('Will go to ImagEval website')
return;

% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuFileLoadImage_Callback(hObject, eventdata, handles)
% File | Load Image
%
dW = ctGetObject('displayW'); 
[img, comment, displayGD] = ctdpLoadImage(dW);
if isempty(img), return; end

vd = ctDisplayGet(displayGD,'vd'); 
vd = vDisplaySet(vd,'inputImage',img);
displayGD = ctDisplaySet(displayGD,'vd',vd);
ctSetObject('display', displayGD); 

% The refresh call causes vdisplayCompute to be called and the image is
% rendered.
ctdpProcessRefreshEvent(hObject);

return;

% --------------------------------------------------------------------
function menuEdit_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuEditNew_Callback(hObject, eventdata, handles)
% Edit | New Model
displayGD = ctDisplayNew; 
ctSetObject('display',displayGD);
ctdpProcessRefreshEvent(hObject);
return;

% --------------------------------------------------------------------
function menuEditDeleteSome_Callback(hObject, eventdata, handles)
% Edit | Delete some
ctDisplayDelete(hObject);
ctdpProcessRefreshEvent(hObject);
return;

function menuDeleteCurrent_Callback(hObject, eventdata, handles)
% Edit | Delete
ctDisplayDelete(hObject,ctDisplayGet(ctGetObject('display'),'nCurrentModel'));
ctdpProcessRefreshEvent(hObject);
return;

% --------------------------------------------------------------------
function menuPlot_Callback(hObject, eventdata, handles)
return;

function subpixelMesh_Callback(hObject, eventdata, handles)
% Plot | Sub pixel mesh
% Makes a subplot with meshes showing the various sub-pixels
%
displayPlot(ctGetObject('displayGD'),'mesh');
return;

function subpixeImage_Callback(hObject, eventdata, handles)
% Plot | Sub pixel image
displayPlot(ctGetObject('displayGD'),'image');
return;

% --------------------------------------------------------------------
function menuDisplay_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menu4Color_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuDisplayVerticalStripesRGBW_Callback(hObject, eventdata, handles)
% Display | Theoretical | RGBW 
%
disGD  = ctGetObject('displayGD');
%vd     = vDisplayCreate('rgbw',72,1,'v','rgbw');
%vd     = vDisplayCreate('rgbw',[],1,'v','rgbw', .48, .32);
vd     = vDisplayCreate('rgbw',72,0.001,'v','rgbw');

disGD  = ctDisplaySet(disGD,'vDisplay',vd);

ctSetObject('displayGD',disGD);
ctdpRefreshGUIWindow(handles.figure1);
%
return;

% --------------------------------------------------------------------
function menuDisplayVerticalStripesWGBR_Callback(hObject, eventdata, handles)
% Display | Theoretical | 4 Color | WRGB

disGD  = ctGetObject('displayGD');
vd     = vDisplayCreate('wbgr',72,0.001,'v','wbgr');
%img    = ones(4,4,4);  
%vd     = vDisplaySet(vd,'ImageRawData',img);

disGD  = ctDisplaySet(disGD,'vDisplay',vd);

ctSetObject('displayGD',disGD);
ctdpRefreshGUIWindow(handles.figure1);
return;


% --------------------------------------------------------------------
function menuDisplayHorizontalStripesRGBW_Callback(hObject, eventdata, handles)
% Display | Theoretical | RGBW 
%
disGD  = ctGetObject('displayGD');
vd     = vDisplayCreate('rgbw',72,0.001,'h','rgbw');

disGD  = ctDisplaySet(disGD,'vDisplay',vd);

ctSetObject('displayGD',disGD);
ctdpRefreshGUIWindow(handles.figure1);
%
return;

% --------------------------------------------------------------------
function menuDisplayHorizontalStripesWGBR_Callback(hObject, eventdata, handles)
% Display | Theoretical | 4 Color | WRGB

disGD  = ctGetObject('displayGD');
vd     = vDisplayCreate('wbgr',72,0.001,'h','wbgr');
%img    = ones(4,4,4);  
%vd     = vDisplaySet(vd,'ImageRawData',img);

disGD  = ctDisplaySet(disGD,'vDisplay',vd);

ctSetObject('displayGD',disGD);
ctdpRefreshGUIWindow(handles.figure1);
return;

% --------------------------------------------------------------------
function menuDisplayRGBY_Callback(hObject, eventdata, handles)
% Display | Theoretical | 4 Color | RGBY
disGD  = ctGetObject('displayGD');
vd     = vDisplayCreate('rgby');

disGD  = ctDisplaySet(disGD,'vDisplay',vd);

ctSetObject('displayGD',disGD);
ctdpRefreshGUIWindow(handles.figure1);
return;


% --------------------------------------------------------------------
function menuDisplayRGBW2x2_Callback(hObject, eventdata, handles)
% Display | Theoretical | 4 Color | RGBW 2x2
disGD  = ctGetObject('displayGD');
vd     = vDisplayCreate('rgbw2x2',72,0.001,'v','rgbw');

disGD  = ctDisplaySet(disGD,'vDisplay',vd);

ctSetObject('displayGD',disGD);
ctdpRefreshGUIWindow(handles.figure1);

return;


% --------------------------------------------------------------------
function menuDisplayWBGR2x2_Callback(hObject, eventdata, handles)
% Display | Theoretical | 4 Color | WBGR 2x2
disGD  = ctGetObject('displayGD');
vd     = vDisplayCreate('wbgr2x2',72,0.001,'v','wbgr');

disGD  = ctDisplaySet(disGD,'vDisplay',vd);

ctSetObject('displayGD',disGD);
ctdpRefreshGUIWindow(handles.figure1);

return;


% --------------------------------------------------------------------
function menu4ColorL6W_Callback(hObject, eventdata, handles)
% Display | Theoretical | 4 color | L6W (CV)
% 
% Clairvoyant style four color, 2x4 pixel arrangement
% RGBW/BWRG
disGD  = ctGetObject('displayGD');
vd     = vDisplayCreate('L6W',72, 0.001);

% Should the input image describe the eight sub-pixels, or just the four
% primaries in each 2x2 pixel?  You would think I know given that I wrote
% the code.  Sigh.  See vDisplayCreate to fix this.

disGD  = ctDisplaySet(disGD,'vDisplay',vd);

ctSetObject('displayGD',disGD);
ctdpRefreshGUIWindow(handles.figure1);
return;

% --------------------------------------------------------------------
function menuDisplayTheoretical_Callback(hObject, eventdata, handles)
% Display | Theoretical (Lists various theoretical options)
return;

function menuDisplayPixScale_Callback(hObject, eventdata, handles)
% Display | Scale Pixel/PSF
disGD = ctGetObject('display'); vd = ctDisplayGet(disGD,'vDisplay');

% Routine scales by the right factor
curPix = vDisplayGet(vd,'pixelSize','um');
newPix = ieReadNumber('Enter new pixel size (um)',curPix(1),' %.0f');
if isempty(newPix), return; end

vd = vDisplayScale(vd,newPix/curPix);

disGD = ctDisplaySet(disGD,'vDisplay',vd);
ctSetObject('display',disGD);
ctdpRefreshGUIWindow(hObject);
return;

% --------------------------------------------------------------------
function menuAnalyze_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuAnalyzeLuminanceImage_Callback(hObject, eventdata, handles)
% Analyze | Luminance Image
%
displayGD = ctGetObject('display');
vd = ctDisplayGet(displayGD,'vd');
wave     = vDisplayGet(vd,'wave');

% It would be better to have the spatial coordinates right.  This is
% roughly how to approach it; but it is not done right here.  We need a way
% to query the vdisplay for the sample positions of the current image.
% psf      = vDisplayGet(vd,'psf');
% supp     = psfGet(psf{1},'cdSupport');

radiance = vDisplayGet(vd,'imageRadiance');
[radXW,r,c] = RGB2XWFormat(radiance);

lum = ieLuminanceFromEnergy(radXW,wave);
lum = reshape(lum,r,c);

vcNewGraphWin;
mesh(lum); 
zlabel('cd/m^2'); xlabel('Sample positions'); ylabel('Sample positions')
return;

% --------------------------------------------------------------------
function menuAnalyzeRender_Callback(hObject, eventdata, handles)
% Analyze | Render
%
% Ask the user for a sample resolution and render the image at that
% resolution
% What image?  This is weird .... probably some XD holdover.  Figure it out
% ... clean it  up.  Maybe eliminate it and replace it with must File |
% Load Image?

warndlg('Render pulldown is not really functional now.  Fix it.')
return;

displayGD = ctGetObject('display');

% displayGD = ctDisplaySet(displayGD, 'm_bIsAlwaysRefreshOnTheFly',0);
% displayGD = ctDisplaySet(displayGD, 'm_bMainImageNeedsUpdate',0);
vd = ctDisplayGet(displayGD,'vd');

sampPerPix = ieReadNumber('Samples per Pixel',10,'%.0f');
data = vdisplayCompute(vd, 'inputImage', 0, sampPerPix);
vd = vDisplaySet(vd, 'ImageRawData',data);
displayGD = ctDisplaySet(displayGD,'vd',vd);

ctSetObject('displayGD',displayGD);
ctdpProcessRefreshEvent(handles.figure1);
return;

% --------------------------------------------------------------------
function menuAnalyzeOutputImage_Callback(hObject, eventdata, handles)
% Analyze | Output image (by units)
displayGD = ctGetObject('display');
vd = ctDisplayGet(displayGD,'vd');
ctvdOutputImage(vd);
return;


% --------------------------------------------------------------------
function menuAnVD2Scene_Callback(hObject, eventdata, handles)
% Analyze | vd->Scene
% Opens up a Scene Window from ISET-2.0
ctvdImage2Scene([],1);
return;

% --------------------------------------------------------------------
function menuHelp_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuDisplayWhiteBackground_Callback(hObject, eventdata, handles)
% Display | White Background
% User is queried about the number of pixels.
ctdpLoadWhiteboard(handles.figure1);
ctdpProcessRefreshEvent(handles.figure1);
return;

% --------------------------------------------------------------------
function menuSaveVirtualDisplayImage_Callback(hObject, eventdata, handles)
% File | Save Display Image
ctdpSaveVirtualDisplayImage(handles.figure1);
return;

% --------------------------------------------------------------------
function menuSaveVirtualDisplayImageAsScene_Callback(hObject, eventdata, handles)
% File | Save Display As Scene
ctdpSaveVirtualDisplayImageAsScene(handles.figure1);
return;

% --------------------------------------------------------------------
function menuClose_Callback(hObject, eventdata, handles)
% File | Close
hFig = ctGetObject('displayW');
delete(hFig);
return;

% --------------------------------------------------------------------
function menuSaveDisplayModel_Callback(hObject, eventdata, handles)
% File | Save Current Model
dispGD = guidata(handles.figure1);
vd = ctDisplayGet(dispGD,'vDisplay');
ctDisplaySave(vd);
return;

% --------------------------------------------------------------------
function menuLoadFont_Callback(hObject, eventdata, handles)
ctdpLoadFont(handles.figure1);
return;

% --------------------------------------------------------------------
function menuRefresh_Callback(hObject, eventdata, handles)
ctdpProcessRefreshEvent(hObject);
return;

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
ctdpSaveAndClose(handles.figure1);
return;

% --------------------------------------------------------------------
function menuCRT_Callback(hObject, eventdata, handles)
% Display | CRT
displayGD  = ctGetObject('display');
dpi = 72;
dSpacing = 0.001; % sample spacing in mm
displayCRT = vDisplayCreate('crt', dpi, dSpacing);
displayGD  = ctDisplaySet(displayGD,'vDisplay',displayCRT);
ctSetObject('display', displayGD);
ctdpRefreshGUIWindow(hObject);
return;

% --------------------------------------------------------------------
function menuShowInNewWindow_Callback(hObject, eventdata, handles)
% Edit | Show in Zoomed View
ctdpImageZoomView(handles.figure1);
return;

% --------------------------------------------------------------------
function menuScalingFactor_Callback(hObject, eventdata, handles)
ctdpProcessScalingFactorEvents(handles.figure1, '?', '?');
return;

% --------------------------------------------------------------------
function menuLoadDisplayModel_Callback(hObject, eventdata, handles)
% File | Load Display
%
ctdpLoadDisplayModel(handles.figure1);
ctdpProcessRefreshEvent(handles.figure1);

return;

% --------------------------------------------------------------------
function menuPlotDisplaySPD_Callback(hObject, eventdata, handles)
iePlotDisplaySPD(handles.figure1);
return;

% --------------------------------------------------------------------
function menuPlotGamut_Callback(hObject, eventdata, handles)
iePlotDisplayGamut(handles.figure1);
return;

% --------------------------------------------------------------------
function menuPlotGamma_Callback(hObject, eventdata, handles)
iePlotDisplayGamma(handles.figure1);
return;

% --------------------------------------------------------------------
function menuLCDHorizontalStripesRGB_Callback(hObject, eventdata, handles)
displayGD   = ctGetObject('display');
dpi = 72;
dSpacing = 0.001; % sample spacing in mm
vDisplayLCD = vDisplayCreate('lcd',dpi,dSpacing,'h','rgb');

displayGD   = ctDisplaySet(displayGD,'vDisplay',vDisplayLCD);  % Add?  Replace?
ctSetObject('display', displayGD);
ctdpRefreshGUIWindow(hObject);
return;

% --------------------------------------------------------------------
function menuLCDVerticalStripesRGB_Callback(hObject, eventdata, handles)
displayGD  = ctGetObject('display');

dpi = 72;
dSpacing = 0.001; % sample spacing in mm
vDisplayLCD = vDisplayCreate('lcd',dpi,dSpacing,'v','rgb');

displayGD  = ctDisplaySet(displayGD,'vDisplay',vDisplayLCD);  % Add?  Replace?
ctSetObject('display', displayGD);
ctdpRefreshGUIWindow(hObject);
return;

% --------------------------------------------------------------------
function menuLCDVerticalStripesBGR_Callback(hObject, eventdata, handles)
% Display | LCD | Vertical BGR
displayGD  = ctGetObject('display');

dpi = 72;
dSpacing = 0.001; % sample spacing in mm
vDisplayLCD = vDisplayCreate('lcd',dpi,dSpacing,'v','bgr');

displayGD  = ctDisplaySet(displayGD,'vDisplay',vDisplayLCD);  % Add?  Replace?
ctSetObject('display', displayGD);
ctdpRefreshGUIWindow(hObject);
return;

% --------------------------------------------------------------------
function menuLCDHorizontalStripesBGR_Callback(hObject, eventdata, handles)
% Display | LCD | Vertical BGR
displayGD   = ctGetObject('display');

dpi = 72;
dSpacing = 0.001; % sample spacing in mm
vDisplayLCD = vDisplayCreate('lcd',dpi,dSpacing,'h','bgr');

displayGD   = ctDisplaySet(displayGD,'vDisplay',vDisplayLCD);  % Add?  Replace?
ctSetObject('display', displayGD);
ctdpRefreshGUIWindow(hObject);
return;


% --------------------------------------------------------------------
function menuDisplayRGBDeltaTriad_Callback(hObject, eventdata, handles)
% Display | Theoretical | SPD | RGB Delta Triad
%
disGD  = ctGetObject('displayGD');

dpi = 72;
dSpacing = 0.01; % sample spacing in mm ??? Changed by BW. To check.
vd     = vDisplayCreate('rgbdeltatriad',dpi,dSpacing,'v','rgbbrg');

disGD  = ctDisplaySet(disGD,'vDisplay',vd);

ctSetObject('displayGD',disGD);
ctdpRefreshGUIWindow(handles.figure1);
%
return;


% --------------------------------------------------------------------
function menuDisplayRGBDiagonal_Callback(hObject, eventdata, handles)
% Display | Theoretical | SPD | RGB Delta Triad
%
disGD  = ctGetObject('displayGD');

dpi = 72;
dSpacing = 0.001; % sample spacing in mm ??? Changed by BW. To check.
vd     = vDisplayCreate('rgbdiag',dpi,dSpacing,'v','rgbbrggbr');

disGD  = ctDisplaySet(disGD,'vDisplay',vd);

ctSetObject('displayGD',disGD);
ctdpRefreshGUIWindow(handles.figure1);
%
return;

% --------------------------------------------------------------------
function menuDisplayRGBGQuad_Callback(hObject, eventdata, handles)
% Display | Theoretical | SPD | RGB Delta Triad
%
disGD  = ctGetObject('displayGD');
dpi = 108;
dSpacing = 0.001; % sample spacing in mm ??? Changed by BW. To check. 
vd     = vDisplayCreate('rgbgquad',dpi,dSpacing,'v','rgbg');

disGD  = ctDisplaySet(disGD,'vDisplay',vd);

ctSetObject('displayGD',disGD);
ctdpRefreshGUIWindow(handles.figure1);
%
return;

% --------------------------------------------------------------------
function menuCaptureFont_Callback(hObject, eventdata, handles)
ctdpCaptureFont(handles.figure1);
return;

% --------------------------------------------------------------------
function menuLoadRedboard_Callback(hObject, eventdata, handles)
ctdpLoadRedboard(handles.figure1);
return;

% --------------------------------------------------------------------
function menuEditScaleImage_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuEditChangeFontSize_Callback(hObject, eventdata, handles)
ctFontChangeSize(handles.figure1);
return;

% --------------------------------------------------------------------
function menuConfigurePSFs_Callback(hObject, eventdata, handles)
ctdpConfigurePSF(handles.figure1);
return;

% --------------------------------------------------------------------
function menuExistingModels_Callback(hObject, eventdata, handles)
% Display | Calibrated
ctdpProcessExistingDisplayModels(handles.figure1);
ctdpRefreshGUIWindow(handles.figure1);
return;

% --- Executes on selection change in popupmenuDisplayModels.

function popupmenuDisplayModels_Callback(hObject, eventdata, handles)
% When the 'Selected Display' popup is chosen, this routine is called
ctdpProcessSelectDisplayModel(hObject);
ctdpRefreshGUIWindow(hObject);
return;

% --- Executes during object creation, after setting all properties.
function popupmenuDisplayModels_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

function editPixelSizeInUmX_Callback(hObject, eventdata, handles)
ctdpProcessEditEvents(handles.figure1, 'PixelSizeInUmX');
return;

% --- Executes during object creation, after setting all properties.
function editPixelSizeInUmX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

function editPixelSizeInUmY_Callback(hObject, eventdata, handles)
ctdpProcessEditEvents(handles.figure1, 'PixelSizeInUmY');
return;

% --- Executes during object creation, after setting all properties.
function editPixelSizeInUmY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

function editNumberOfPrimaries_Callback(hObject, eventdata, handles)
ctdpProcessEditEvents(handles.figure1, 'NumberOfPrimaries');
return;

% --- Executes during object creation, after setting all properties.
function editNumberOfPrimaries_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

function editNumberOfSubPixelsPerBlock_Callback(hObject, eventdata, handles)
ctdpProcessEditEvents(handles.figure1, 'NumberOfSubPixelsPerBlock');
return;

% --- Executes during object creation, after setting all properties.
function editNumberOfSubPixelsPerBlock_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

function editViewingDistance_Callback(hObject, eventdata, handles)
ctdpProcessEditEvents(handles.figure1, 'ViewingDistance');
return;

% --- Executes during object creation, after setting all properties.
function editViewingDistance_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

function editNumberOfVirtualPixelsPerBlockX_Callback(hObject, eventdata, handles)
ctdpProcessEditEvents(handles.figure1, 'NumberOfVirtualPixelsPerBlockX');
return;

% --- Executes during object creation, after setting all properties.
function editNumberOfVirtualPixelsPerBlockX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

function editNumberOfVirtualPixelsPerBlockY_Callback(hObject, eventdata, handles)
ctdpProcessEditEvents(handles.figure1, 'NumberOfVirtualPixelsPerBlockY');
return;

% --- Executes during object creation, after setting all properties.
function editNumberOfVirtualPixelsPerBlockY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% --------------------------------------------------------------------
function menuDisplayConfigure_Callback(hObject, eventdata, handles)
% Probably obsolete
return;

% --------------------------------------------------------------------
function menuOption_Callback(hObject, eventdata, handles)
ctdpAdjustOptions(handles.figure1);
return;


% --------------------------------------------------------------------
function menuFileSaveAllAndClose_Callback(hObject, eventdata, handles)
ctdpSaveAndClose(handles.figure1);
return;

% --------------------------------------------------------------------
function menuFileSaveAll_Callback(hObject, eventdata, handles)
ctdpSaveAllDisplayModels(handles.figure1);
return;


% --------------------------------------------------------------------
function menuEditDisplayProperties_Callback(hObject, eventdata, handles)
return;

% --------------------------------------------------------------------
function menuDisplayPropPSizeOnly_Callback(hObject, eventdata, handles)
% Edit | Display | Pixel size 
%
% This does not scale the psf, only the separation (black space) between
% the dixels.  There is a separate callback that scales the dixel and psf
% together. 
%
% This callback is interactive - you are shown the new look before it is
% modified.

dispGD = ctGetObject('display');
vd = ctDisplayGet(dispGD,'vDisplay');

vd = ctdpDixelSeparation(vd);
if isempty(vd), return; end  % User canceled

dispGD = ctDisplaySet(dispGD,'virtualDisplay',vd);
ctSetObject('displaygd',dispGD);
ctdpProcessRefreshEvent(hObject);

return;

% --------------------------------------------------------------------
function menuDisplayVD_Callback(hObject, eventdata, handles)
% Display | Viewing Distance (m)
%
dispGD = ctGetObject('display');
vd = ctDisplayGet(dispGD,'vDisplay');
dist = vDisplayGet(vd,'viewingDistance');

newDist = ieReadNumber('Enter new viewing distance (m)',dist,' %.02f ');
if isempty(newDist), return; end

vd = vDisplaySet(vd,'viewingDistance',newDist);
dispGD = ctDisplaySet(dispGD,'virtualDisplay',vd);
ctSetObject('displaygd',dispGD);

return;
% --------------------------------------------------------------------
function menuEditScalePixel_Callback(hObject, eventdata, handles)
disp('Not yet implemented')
return;

% --------------------------------------------------------------------
function menuEditRenameDisplay_Callback(hObject, eventdata, handles)
ctdpRenameDisplayModel(handles.figure1);
return;


%-----------------------------------------------------
function editMaxLum_Callback(hObject, eventdata, handles)
% Edit box for max luminance
% Possibly we should only scale the SPDs in response to changing this
% number, and we should figure out how to scale the SPDs and derive the max
% luminance from the SPDs, which could be stored in real units for goodness
% sake.

displayGD = ctGetObject('display');
vdisp = ctDisplayGet(displayGD,'vDisplay');

maxLum = str2num(get(hObject,'string'));
vDisplaySet(vdisp,'maxLuminance',maxLum);

displayGD = ctDisplaySet(displayGD,'vDisplay',vdisp);
ctSetObject('display',displayGD);

return;

%-----------------------------------------------------
function editMaxLum_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

function editVar_Callback(hObject, eventdata, handles)
% Edit the variance - Mura?
disp('Not yet implemented')
return;

function editVar_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

function editAmp_Callback(hObject, eventdata, handles)
return;

function editAmp_CreateFcn(hObject, eventdata, handles)
return;

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;
