function displayGD = ctDisplaySet(displayGD, param, val, varargin)
% Interface to data and parameters in display window.
%
%   ctDisplaySet(displayGD, param, val, varargin);
%
% This is for managing only the window parameters. To manage virtual
% display properties, use vDisplaySet/Get/Create 
%
% Current functionality is wrong - we are working on it.  MB/BW 1.9.2012
%
% FIX THIS.
%
% In addition to setting parameters display graphical interface parameters,
% this routine can also be used to set parameters of the display object
% attached to the interface.  Specifically, for a parameter that can be set
% in the CDisplay structure,
%
% Settable window gui parameters are
%   Objects in window 
%      mainAxes
%      iconAxes
%      txtSummary
%      mainWindow                 -  handle to the main ctToolBox window
%      m_bIsAlwaysRefreshOnTheFly - 
%      'redrawMainImage'        -
%      'mainNeedsUpdate'    -
%
%
%      'virtualdisplay'           - Virtual display model (CDisplay)
%      'modellist'                - List of all models stored in window
%      'nSelectedDisplay'         - Currently selected display model
%      m_nDefaultNewModelName
%
% Calibration data for PR-650
%      m_nDefaultCommPort
%      pauseTimeSec
%      m_nDefaultNumberOfGrayLevels
%      m_nDefaultNumberOfSamples
%      m_bDefaultWorkingMonitor
%      m_n2ndMonitorSizeX
%      m_n2ndMonitorSizeY
%      calibrationData
%
%      menuAlwaysRefreshOnTheFly
%      menuExistingModels
%      popupmenuDisplayModels
%
% It is also possible (though not preferred) to use ctDisplaySet to adjust
% virutal display parameters.  The call
%
%   ctDisplaySet(displayGD,CDParam,val) 
%
%      is equivalent to
%
%   vdisplay  = displayGet(displayGD,'vdisplay');
%   vdisplay  = vDisplaySet(vdisplay,CDParam,val);
%   displayGD = ctDisplaySet(displayGD,'vdisplay',vdisplay);
%

if ieNotDefined('displayGD'), error('Display window handles required.'); end
if ieNotDefined('param'), error('Parameter name required.'); end
if nargin<=2 , error('Insufficient number of parameters.');  end;

switch lower(param)
    % Window parameters
    case {'mainwindow','m_hmainwindow'}
        displayGD.m_hMainWindow=val;
    case {'alwaysrefresh','m_bisalwaysrefreshonthefly'}
        displayGD.m_bIsAlwaysRefreshOnTheFly=val;
    case {'redrawmainimage','m_bismainimagedirty'}
        displayGD.m_bIsMainImageDirty=val;
    case {'updatemain','mainneedsupdate','m_bmainimageneedsupdate'}
        displayGD.m_bMainImageNeedsUpdate=val;
    case {'mainaxes','axes1'}
        displayGD.axes1=val;
    case {'iconaxes','axes4'}
        displayGD.axes4=val;
    case {'txtsummary'}
        displayGD.txtSummary=val;
    case {'menualwaysrefreshonthefly'}
        displayGD.menuAlwaysRefreshOnTheFly=val;
    case {'menuexistingmodels'}
        displayGD.menuExistingModels=val;
    case {'popupmenudisplaymodels'}
        displayGD.popupmenuDisplayModels=val;
    case {'pausetimesec','m_npausetimeinseconds'}
        displayGD.m_nPauseTimeInSeconds=val;
        
        %Display parameters
    case {'displaylist','m_cellselecteddisplaymodels','modellist'}
        % This cell array is a set of structures that are
        % model.Name (String)
        % model.DispModel (CDisplay)
        displayGD.m_cellSelectedDisplayModels=val;
    case {'currentdisplay','m_objvirtualdisplay','vdisplay','virtualdisplay','vd'}
        n = ctDisplayGet(displayGD,'nCurrentModel');
        displayGD.m_cellSelectedDisplayModels{n} = val;
    case {'ncurrentdisplay','nselecteddisplay','m_ncurrentselectedmodel'}
        displayGD.m_nCurrentSelectedModel=val;
    case {'displayname'}
        % With no arguments, the current display name is changed.  
        %   ctDisplaySet(dispGD,'displayName','newName');
        % To change the nth in the list, use
        %   ctDisplaySet(dispGD,'displayName',n);
        %
        if isempty(varargin), n = ctDisplayGet(displayGD,'currentDisplay');
        else n = varargin{1}; end
        % We should probably check that n is within range.  
        displayGD.m_cellSelectedDisplayModels{n}=set(displayGD.m_cellSelectedDisplayModels{n}, 'DisplayName', val);

    case {'newdisplayname','m_ndefaultnewmodelname'}
        % Should be deleted.
        displayGD.m_nDefaultNewModelName=val;
      
    % Information for display calibration ... not quite right
    case {'defaultcommport','m_ndefaultcommport','commport'}
        displayGD.m_nDefaultCommPort=val;
    case {'m_ndefaultnumberofgraylevels'}
        displayGD.m_nDefaultNumberOfGrayLevels=val;
    case {'m_ndefaultnumberofsamples'}
        displayGD.m_nDefaultNumberOfSamples=val;
    case {'m_bdefaultworkingmonitor'}
        displayGD.m_bDefaultWorkingMonitor=val;
    case {'calibrationdata'}
        % This is a structure of the form
        %   val.wave
        %   val.spd
        %   val.gam
        displayGD.calibrationData = val;
    case {'calibrationwave'}
        displayGD.calibrationData.wave = val;
    case {'calibrationspd'}
        displayGD.calibrationData.spd = val;
    case {'calibrationgamma','calibrationgam'}
        displayGD.calibrationData.gam = val;
    case {'m_n2ndmonitorsizex'}
        displayGD.m_n2ndMonitorSizeX=val;
    case {'m_n2ndmonitorsizey'}
        displayGD.m_n2ndMonitorSizeY=val;
        
    otherwise
        % Assume this is a CDisplay parameter.  Probably we should check
        % rather than just assume.
        % We should also set the 'Dirty' flag in some cases.  And why is
        % there needs update, is dirty, all these various different cases?
        warning('ctDisplaySet called for %s, should be vDisplaySet',param);
        
        vd = ctDisplayGet(displayGD,'vDisplay');
        vd = vDisplaySet(vd,param,val);
        displayGD = ctDisplaySet(displayGD,'vDisplay',vd);
        
end;

return