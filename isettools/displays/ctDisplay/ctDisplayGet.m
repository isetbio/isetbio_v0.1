function val = ctDisplayGet(displayGD,param,varargin)
% displayGet - Interface to data and parameters from display window
%
% This is for managing only the window parameters. To manage virtual
% display properties, use vDisplaySet/Get/Create 
%
% Current functionality is wrong - we are working on it.  MB/BW 1.9.2012
%
%   val = ctDisplayGet(displayGD,param,varargin)
%
% The Display Window Parameters from the Matlab window are in the displayGD
% structure.  
%
% In addition, ctDisplayGet reterieves GUI values from the virtual display
% and even from the dixel attached to the virtual display.
% Specifically,using this routine, as in
%
%     ctDisplayGet(displayGD,vdParam);
%
%  is equivalent to
%
%     vd = ctDisplayGet(displayGD,'vdisplay'); % Gets the virtual display
%     val = vDisplayGet(vd,vdParam);         % Reads the vDisplay parameter
% 
% Similarly, if dxParam is a dixel parameter, then,
% ctDisplayGet(displayGD,dxParam)is equivalent to
%
%     vd = ctDisplayGet(displayGD,'vdisplay');  % Get the display
%     dx = vDisplayGet(vd,'dixel);            % Get the dixel
%     val = dixelGet(dx,dxParam)              % Get the parameter
%
% For coding practice, please
%
%   (1) Get parameters from the vDisplayGet version because the displayGD
%   has lots of links to window menus and buttons that are annoying to look
%   at, and the vDisplay is a more compact structure.   
%   (2) Get dixel properties from vDisplayGet, and you do not use dixelGet
%   directly. 
%
% The current organization got this way as I amended the old XD
% architecture.
%
% Examples
%
%    handleToMainWindow = ctDisplayGet(displayGD,'m_hMainWindow');
%    axes = ctDisplayGet(displayGD,'m_n2ndMonitorSizeX','mm');
%
% Parameters - 
%  This is a list of the parameters in this routine; it is not a complete
%  list of all the vDisplay and dixel parameters you can retrieve.
%
%  This routine passes requests along to vDisplayGet and dixelGet, which
%  can return virtual display and dixel parameters. As we write above, you
%  should be using vDisplayGet for those parameters, which are summarized
%  in the vDisplayGet header (or should be).
%
% ctDisplayGet parameters - 
%
%     'mainwindow'
%     'refreshonthefly'
%     'm_bismainimagedirty'
%     'm_bmainimageneedsupdate'
%     'mainaxis'
%     'smallaxis'
%     'txtsummary'
%     'menualwaysrefreshonthefly'
%     'menuExistingModels'
%     'popupmenudisplaymodels'
%
%     'modelList'        - Cell array list of display models and names
%     'currentdisplay'   - Current display model (CDisplay)
%     'ncurrentdisplay'  - Integer indicating the currently selected
%                          display within the list
%     'nmodels'          - Number of display models
%     'modelnames'       - Cell array of the display model names
%     'allmodels'        - Cell array of all the display models
%     'newmodelname'     - Default name for new model
%
%     'defaultNumberofGraylevels'
%     'defaultnumberofsamples'
%     'm_bdefaultworkingmonitor'
%     'm_n2ndmonitorsizex'
%     'm_n2ndmonitorsizey'
%
%     'defaultcommport'
%     'm_npausetimeinseconds'
%
%     'virtualdisplay'
%
% Wandell, 2006

if ieNotDefined('displayGD'), error('Display window handles required.'); end
if ieNotDefined('param'), error('Parameter name required'); end

val = [];

param = ieParamFormat(param);
switch param
    % Display window management related
    case {'mainwindow','m_hmainwindow'}
        val = displayGD.m_hMainWindow;
    case {'alwaysrefresh','m_bisalwaysrefreshonthefly','refreshonthefly'}
        val = displayGD.m_bIsAlwaysRefreshOnTheFly;
    case {'m_bismainimagedirty'}
        val = displayGD.m_bIsMainImageDirty;
    case {'updatemain','m_bmainimageneedsupdate'}
        val = displayGD.m_bMainImageNeedsUpdate;
    case {'whiteboardaxis','axes1','mainaxis'}
        val = displayGD.axes1;
    case {'iconaxes','axes4','smallaxis'}
        val = displayGD.axes4;
        % Display model
    case {'txtsummary'}
        val = displayGD.txtSummary;
    case {'menualwaysrefreshonthefly'}
        val = displayGD.menuAlwaysRefreshOnTheFly;
    case {'menuexistingmodels'}
        val = displayGD.menuExistingModels;
    case {'popupmenudisplaymodels'}
        val = displayGD.popupmenuDisplayModels;
        
    % Display model management
    % In some cases, this routine calls vDisplayGet to retrieve virtual
    % display parameters.
    case {'modellist','m_cellselecteddisplaymodels','displaymodels'}
        % Cell array of model names and  CDisplay structures,
        %     ctDisplayGet(dispGD,'displayModels');
        % For a specific CDisplay (without the name), use
        %     ctDisplayGet(dispGD,'modelList',2);
        % For the current display, use
        %     ctDisplayGet(dispGD,'vDisplay');
        if isempty(varargin), 
            if checkfields(displayGD,'m_cellSelectedDisplayModels')
                val = displayGD.m_cellSelectedDisplayModels;
            else val = {};
            end
        else
            n = varargin{1};
            val = displayGD.m_cellSelectedDisplayModels{n};
        end
    case {'virtualdisplay','currentdisplay','vdisplay','vd','m_objvirtualdisplay',}
        % We should eliminate the m_objVirtualDisplay field altogether
        % ctDisplayGet(displayGD,'currentDisplay');
        n = ctDisplayGet(displayGD,'nCurrentmodel');
        val = ctDisplayGet(displayGD,'modelList',n);
    case {'m_ncurrentselectedmodel','ncurrentmodel','ncurrentdisplay', 'nselected'}
        if checkfields(displayGD,'m_nCurrentSelectedModel');
            val = displayGD.m_nCurrentSelectedModel;
        else val = 1;   % Maybe this should be empty on return ... not sure.
        end
    case {'newmodelname','m_ndefaultnewmodelname'}
        val =sprintf('display-%.0f',ctDisplayGet(displayGD,'nmodels')+1);
    case {'nmodels','ndisplaymodels'}
        val = length(ctDisplayGet(displayGD,'displayModels'));
    case {'currentmodelname','currentname'}
        n = ctDisplayGet(displayGD,'nCurrentmodel');
        models = ctDisplayGet(displayGD,'displayModels');
        val = vDisplayGet(models{n}, 'DisplayName');
    case {'modelnames'}
        % ctDisplayGet(displayGD,'modelNames')
        n = ctDisplayGet(displayGD,'nmodels');
        models = ctDisplayGet(displayGD,'displayModels');
        for ii=1:n, val{ii} = vDisplayGet(models{ii}, 'DisplayName'); end
    case {'allmodels'}
        % Cell array containing all the models
        % ctDisplayGet(displayGD,'allModels')
        n = ctDisplayGet(displayGD,'nmodels');
        models = ctDisplayGet(displayGD,'displayModels');
        for ii=1:n, val{ii} = models{ii}; end
        
    % Data collection related    
    case {'m_ndefaultcommport','defaultcommport'}
        val = displayGD.m_nDefaultCommPort;
            case {'pausetimesec','m_npausetimeinseconds'}
        val = displayGD.m_nPauseTimeInSeconds;

    % Not sure whether these are necessary    
    case {'m_ndefaultnumberofgraylevels','defaultnumberofgraylevels'}
        val = displayGD.m_nDefaultNumberOfGrayLevels;
    case {'m_ndefaultnumberofsamples','defaultnumberofsamples'}
        val = displayGD.m_nDefaultNumberOfSamples;
    case {'m_bdefaultworkingmonitor'}
        val = displayGD.m_bDefaultWorkingMonitor;
    case {'m_n2ndmonitorsizex'}
        val = displayGD.m_n2ndMonitorSizeX;
    case {'m_n2ndmonitorsizey'}
        val = displayGD.m_n2ndMonitorSizeY;
   
    % Virtual display parameters.  Possibly we should check earlier to see
    % whether these are valid.
    % If vDisplayGet fails to find the parameter in its own case statement,
    % it tries to look up the parameter using dixelGet.  Thus, dixel
    % parameters can also be returned by this call.
    otherwise
        % This is where we try to see if it is a vDisplay parameter.
        warning('ctDisplayGet called for %s, should be vDisplayGet',param);
        vd = ctDisplayGet(displayGD,'vdisplay');
        if ~isempty(varargin)
            v   = varargin{1};
            val = vDisplayGet(vd,param,v);
        else
            val = vDisplayGet(vd,param);
        end
end;

return

