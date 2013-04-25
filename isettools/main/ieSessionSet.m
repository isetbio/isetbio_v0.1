function ieSessionSet(param,val,varargin)
% Set vcSESSION parameters.
%
%     ieSessionSet(param,val,varargin);
%
% While vcSESSION parameters are generally set by this routine. There remain
% some places, however, where vcSESSION is touched directly. This will
% change over time.  At some point in time, vcSESSION is likely to be
% hidden in the main window, and not be global.
%
%   {'version'}
%   {'sessionname'}
%   {'sessiondir'}
%   {'inithelp'}
% setpref variables
%   {'detlafontsize'} -- This value determines whether we change the
%     font size in every window by this increment, calling
%     ieFontChangeSize when the window is opened. 
%   {'whitePoint'} - sets
%     which SPD maps to (1,1,1) in scene/optics windows.
%   {'waitbar'}  - Show compute waitbars or not. 
%
%  Example:  ieSessionSet('mainwindow',hObject,eventdata,handles);
%
%      {'mainwindow'}    - Store handles for main window
%      {'scenewindow'}   - Store handles for scene window
%      {'oiwindow'}      - Store handles of optical image window
%      {'sensorwindow'}  - Store handles for sensor window
%      {'vcimagewindow'} - Store handles for processor 
%                (virtual camera image) window
%      {'metricswindow'} - Store handles for metrics window
%
%      {'graphwinval'}    - Number for graphics window
%      {'graphwinhandle'} - Not currently used, in future will be as named
%      {'graphwinfigure'} - hObject for graphics window.  Why is this not
%          handle?
%     
%   These custom parameters are cell arrays of user defined routines for
%   these various operations. 
%   {'custom'}
%      {'customdemosaiclist','demosaiclist','setdemosaiclist'}
%      {'adddemosaic','adddemosaicmethod'}
%      {'deletedemosaic','deletedemosaicmethod'}
%         
%      {'customcolorbalancelist','colorbalancelist','setcolorbalancelist'}
%      {'addcolorbalance','addcolorbalancemethod'}
%      {'deletecolorbalance','deletecolorbalancemethod'}
%         
%      {'customcolorconversionlist','colorconversionlist','setcolorconversionlist'}
%      {'addcolorconversion','addconversion','addcolorconversionmethod'}
%      {'deletecolorconversion','deletecolorconversionmethod'}
%         
%      {'renderlist','setrenderlist'}
%         % ieSessionSet('setrenderlist',algListCellArray);
%      {'addrender','addrendermethod'}
%         % ieSessionSet('addrender',newAlg);
%      {'deleterender','deleterendermethod'}
%         % ieSessionSet('deleterender',[5 8]);
%         
%      {'setoicomputelist','oicomputelist'}
%         % ieSessionSet('setOIComputeList',algListCellArray);
%      {'addoicompute','addoicomputemethod'}
%         % ieSessionSet('addOIComputeMethod',newAlg);
%      {'deleteoicompute','deleteOIComputemethod'}
%         % ieSessionSet('deleteOIcomputeMethod',newAlg);
%         
%      {'setsensorcomputelist','sensorcomputelist'}
%         % ieSessionSet('setSensorComputeList',algListCellArray);
%      {'addsensorcompute','addsensorcomputemethod'}
%         % ieSessionSet('addSensorComputeMethod',newAlg);
%      {'deletesensorcompute','deletesensorcomputemethod'}
%         % ieSessionSet('deleteSensorComputeMethod',newAlg);
%         
%      {'setedgealgorithmlist','edgealgorithmlist'}
%         % ieSessionSet('edgeAlgorithmList',algListCellArray);
%      {'addedgealgorithm','addedgealgorithmmethod'}
%         % ieSessionSet('addSensorComputeMethod',newAlg);
%      {'deleteedgealgorithm','deleteedgealgorithmmethod'}
%         % ieSessionSet('deleteSensorComputeMethod',newAlg);
%
% Example:
%    ieSessionSet('addrender',newAlg);
%
% See also ieSessionGet
%
% Copyright ImagEval Consultants, LLC, 2005.

% TODO
%    It seems that not all session sets are handled through this call yet.
%    Must find more.  Look at the routine vcSetFigureHandles for some
%    clues.
%
%    Here's a clue:  vcReplaceObject.  Maybe vcAddandSelectObject ...
%
%    Rather than vcGetObject, we should be using ieSessionGet('scene') or
%    ieSessionGet('scene',3);  Sigh. For historical reasons, the vcSESSION
%    was not properly protected. Hence, there are still way too many
%    vcSESSION. calls in the sub-routines.

global vcSESSION

if ieNotDefined('param'), error('You must specify a parameter.'); end
if ~exist('val','var'),   error('You must specify a value.');     end

switch lower(param)
    case {'version'}
        vcSESSION.VERSION = val;
    case {'name','sessionname'}
        vcSESSION.NAME = val;
    case {'dir','sessiondir'}
        vcSESSION.DIR = val;
    case {'help','inithelp'}
        % Default for help is true, if the initHelp has not been set.
        if checkfields(vcSESSION,'initHelp'), vcSESSION.initHelp = val; 
        else vcSESSION.initHelp = 1; val = 1; 
        end
    case {'detlafontsize','fontincrement','increasefontsize','fontdelta','deltafont'}
        % This value determines whether we change the font size in every
        % window by this increment, calling ieFontChangeSize when the
        % window is opened.
        setpref('ISET','fontDelta',val);
    case {'whitepoint'}
        % This white point can be used in rendering the spectral images. It
        % sets the properties of the color block matrix so that one of a
        % series of spd options is mapped to (1,1,1).
        % The default is unset, in which case equal photon count across the
        % spectrum maps to 1,1,1
        % It is also possible to choose 'ee' (equal energy), or 'd65'.  If
        % the value is unrecognized, the default is used.
        setpref('ISET','whitePoint',val);
    case {'custom'}
        vcSESSION.CUSTOM = val;
        
        % These parameters are cell arrays of user defined routines for these various
        % operations.
    case {'customdemosaiclist','demosaiclist','setdemosaiclist'}
        vcSESSION.CUSTOM.demosaic = val;
    case {'adddemosaic','adddemosaicmethod'}
        l = ieSessionGet('demosaicList');
        vcSESSION.CUSTOM.demosaic = cellMerge(l,val);
    case {'deletedemosaic','deletedemosaicmethod'}
        vcSESSION.CUSTOM.demosaic = cellDelete(vcSESSION.CUSTOM.demosaic,val);
        
    case {'customcolorbalancelist','colorbalancelist','setcolorbalancelist'}
        vcSESSION.CUSTOM.colorBalance = val;
    case {'addcolorbalance','addcolorbalancemethod'}
        l = ieSessionGet('colorbalancelist');
        vcSESSION.CUSTOM.colorBalance = cellMerge(l,val);
    case {'deletecolorbalance','deletecolorbalancemethod'}
        vcSESSION.CUSTOM.colorBalance = cellDelete(vcSESSION.CUSTOM.colorBalance,val);
        
    case {'customcolorconversionlist','colorconversionlist','setcolorconversionlist'}
        vcSESSION.CUSTOM.colorConversion = val;
    case {'addcolorconversion','addconversion','addcolorconversionmethod'}
        l = ieSessionGet('colorconversionlist');
        vcSESSION.CUSTOM.colorConversion = cellMerge(l,val);
    case {'deletecolorconversion','deletecolorconversionmethod'}
        vcSESSION.CUSTOM.colorConversion = cellDelete(vcSESSION.CUSTOM.colorConversion,val);
        
    case {'renderlist','setrenderlist'}
        % ieSessionSet('setrenderlist',algListCellArray);
        vcSESSION.CUSTOM.render = val;
    case {'addrender','addrendermethod'}
        % ieSessionSet('addrender',newAlg);
        l = ieSessionGet('renderlist');
        vcSESSION.CUSTOM.render = cellMerge(l,val);
    case {'deleterender','deleterendermethod'}
        % ieSessionSet('deleterender',[5 8]);
        vcSESSION.CUSTOM.render = cellDelete(vcSESSION.CUSTOM.render,val);
        
    case {'setoicomputelist','oicomputelist'}
        % ieSessionSet('setOIComputeList',algListCellArray);
        vcSESSION.CUSTOM.oicompute = val;
    case {'addoicompute','addoicomputemethod'}
        % ieSessionSet('addOIComputeMethod',newAlg);
        l = ieSessionGet('OIComputelist');
        vcSESSION.CUSTOM.oicompute = cellMerge(l,val);
    case {'deleteoicompute','deleteOIComputemethod'}
        % ieSessionSet('deleteOIcomputeMethod',newAlg);
        vcSESSION.CUSTOM.oicompute = cellDelete(vcSESSION.CUSTOM.oicompute,val);
        
    case {'setsensorcomputelist','sensorcomputelist'}
        % ieSessionSet('setSensorComputeList',algListCellArray);
        vcSESSION.CUSTOM.sensorcompute = val;
    case {'addsensorcompute','addsensorcomputemethod'}
        % ieSessionSet('addSensorComputeMethod',newAlg);
        l = ieSessionGet('sensorcomputelist');
        vcSESSION.CUSTOM.sensorcompute = cellMerge(l,val);
    case {'deletesensorcompute','deletesensorcomputemethod'}
        % ieSessionSet('deleteSensorComputeMethod',newAlg);
        vcSESSION.CUSTOM.sensorcompute = cellDelete(vcSESSION.CUSTOM.sensorcompute,val);
        
    case {'setedgealgorithmlist','edgealgorithmlist'}
        % ieSessionSet('edgeAlgorithmList',algListCellArray);
        vcSESSION.CUSTOM.edgeAlgorithm = val;
    case {'addedgealgorithm','addedgealgorithmmethod'}
        % ieSessionSet('addSensorComputeMethod',newAlg);
        l = ieSessionGet('edgealgorithmlist');
        vcSESSION.CUSTOM.edgeAlgorithm = cellMerge(l,val);
    case {'deleteedgealgorithm','deleteedgealgorithmmethod'}
        % ieSessionSet('deleteSensorComputeMethod',newAlg);
        vcSESSION.CUSTOM.edgeAlgorithm = cellDelete(vcSESSION.CUSTOM.sensorcompute,val);
        
    % Set window information at startup
    case {'mainwindow'}
        if length(varargin) < 2, error('main window requires hObject,eventdata,handles'); end
        vcSESSION.GUI.vcMainWindow.hObject = val;
        vcSESSION.GUI.vcMainWindow.eventdata = varargin{1};
        vcSESSION.GUI.vcMainWindow.handles = varargin{2};
    case {'scenewindow'}
        if length(varargin) < 2, error('scene window requires hObject,eventdata,handles'); end
        vcSESSION.GUI.vcSceneWindow.hObject = val;
        vcSESSION.GUI.vcSceneWindow.eventdata = varargin{1};
        vcSESSION.GUI.vcSceneWindow.handles = varargin{2};
    case {'oiwindow'}
        if length(varargin) < 2, error('optical image window requires hObject,eventdata,handles'); end
        vcSESSION.GUI.vcOptImgWindow.hObject = val;
        vcSESSION.GUI.vcOptImgWindow.eventdata = varargin{1};
        vcSESSION.GUI.vcOptImgWindow.handles = varargin{2};
    case {'sensorwindow'}
        if length(varargin) < 2, error('sensor window requires hObject,eventdata,handles'); end
        vcSESSION.GUI.vcSensImgWindow.hObject = val;
        vcSESSION.GUI.vcSensImgWindow.eventdata = varargin{1};
        vcSESSION.GUI.vcSensImgWindow.handles = varargin{2};
    case {'vcimagewindow'}
        if length(varargin) < 2, error('vcimage window requires hObject,eventdata,handles'); end
        vcSESSION.GUI.vcImageWindow.hObject = val;
        vcSESSION.GUI.vcImageWindow.eventdata = varargin{1};
        vcSESSION.GUI.vcImageWindow.handles = varargin{2};
    case {'metricswindow'}
        if length(varargin) < 2, error('metrics window requires hObject,eventdata,handles'); end
        vcSESSION.GUI.metricsWindow.hObject = val;
        vcSESSION.GUI.metricsWindow.eventdata = varargin{1};
        vcSESSION.GUI.metricsWindow.handles = varargin{2};
        
        % This graphics window stuff is a mess
    case {'graphwinstructure','graphwinval'}
        vcSESSION.GRAPHWIN = val;
    case {'graphwinhandle'}
        % At present we don't add any objects with handles.  So this is
        % empty. But we might some day.
        vcSESSION.GRAPHWIN.handle = val;
    case {'graphwinfigure'}
        % This is just the figure number, usually.
        vcSESSION.GRAPHWIN.hObject = val;
    case {'waitbar'}
        % 0 means off, 1 means on
        if ischar(val)
            switch val
                case 'on',  val = 1;
                case 'off', val = 0;
            end
        end
        setpref('ISET','waitbar',val);
        vcSESSION.GUI.waitbar = val;
        
    otherwise
        error('Unknown parameter')
end
