function psf=psfSet(psf, param, val, varargin)
%psfSet - Interface to set psf structure parameters
%
%    psf=psfSet(psf, param, val, varargin)
%
% The point spread function parameters include mechanisms for handling
% purely theoretical point spreads or those based upon calibration of a
% specific display.
%
% Examples
%
%
% Parameters
%     'name'  - Sub-pixel name, e.g., red-Dell-LCD
%     'cols'  - Number of columns in the sampled psf used for calculations
%     'rows'  - Number of rows in the sampled psf used for calculations
%     'xsupport' - Obsolete. Spatial extent of the x (horizontal,cols) of the sampled psf
%     'ysupport' - Obsolete. Spatial extent of the y (vertical, rows) of the sampled psf
%
%     'xsigma' - Only used for Gaussian modeling, standard deviation in millimeters
%               Stored as a string ?
%     'ysigma'
%
%     'psffunction'- String used for analytical psf function
%                    f = psfGet(psf,'PSFfunction'); eval(f)
%     'customdata' - Structure containing the calibration data
%       'cdimage'  - image representing the psf of the sub-pixel
%       'samplepositions'
%       'cdColSpacing'   - Obsolete. col spacing between samples (mm)
%       'cdRowSpacing'   - Obsolete. row spacing between samples (mm)


if ieNotDefined('psf'),   error('PSF structure required.'); end
if ieNotDefined('param'), error('Parameter required.'); end
if nargin < 3,            error('Parameter value required.'); end

param = ieParamFormat(param);
switch param

    case {'name','psftype'}
        psf.name = val;

        % The sampling rate sets how we interpolate either the theoretical
        % function or the measured data.  Notice that the parameter is confused
        % about whether this is the  number of samples per pixel or the samples per
        % unit space.  Must get clearer.
    case {'cols','nx','xsamples','fsamplingratex','xsamplespermm'}
        psf.fSamplingRateX = val;
    case {'rows','ny','ysamples','fsamplingratey','ysamplespermm'}
        psf.fSamplingRateY = val;

        % This represents the total support of the psf representation.  The
        % support can extend beyond a single pixel because the psf can extend
        % beyond a single pixel.
        %     case {'strfinitesupportx','xsupport'}
        %         % This is a string.  It defines the spatial support of the PSF.  It
        %         % is defined in units of millimeters.
        %         psf.strFiniteSupportX = val;
        %     case {'ysupport','strfinitesupporty',}
        %         % This is a string.  It defines the spatial support of the PSF.  It
        %         % is defined in units of millimeters.
        %         % psfGet(psf,'
        %         psf.strFiniteSupportY = val;
    case {'sampledpsfdata','sampledata','sampleddata'}
        % This is a little dangerous
        psf.aSampledPSFData = val;

        % Gaussian modeling parameters.  Special case.
    case {'xsigma','strsigmax'}
        % Only used for Gaussian modeling.  This represents the standard
        % deviation in millimeters.  Stored as a string.
        % psfGet(psf,'xsigma','mm') will return a sigma in units of
        % millimeters.  Here, it is stored as a string.
        if   ischar(val), psf.strSigmaX = val;
        else psf.strSigmaX = ieNumber2RationalString(val);
        end
    case {'ysigma','strsigmay'}
        % Only used for Gaussian modeling.  This represents the standard
        % deviation in millimeters.  Stored as a string.
        if ischar(val), psf.strSigmaY = val;
        else psf.strSigmaY = ieNumber2RationalString(val);
        end

        % If we want to use a function to define the psf, the function is
        % stored in a string here so that we can eval this string and get the
        % function returned.  Used in Gaussian modeling.  Not sure this is a
        % good idea.  A better idea might be to build a dummy custom data with
        % the function and never have these special case parameters.
    case {'psffunction','strpsffunction','evalpsffunction'}
        % f = psfGet(psf,'evalPSFfunction');
        % eval(f)
        % to get analytically defined PSF data
        if ~ischar(val), error('This must be a string that can be evaluated'); end
        psf.strPSFFunction = val;

        % Calibration data should be stored here.  These can be at higher
        % spatial resolution than the sub-pixel psf that we use in the actual
        % calculation.  Additional information is likely to be added here over
        % time, such as the position of the sub-pixel center with respect to
        % the whole pixel.
    case {'scustomdata','customdata'}
        % This is one channel (sub-pixel).
        % The custom data field is a structure that contains the raw data and potentially
        % other measurement parameters
        psf.sCustomData = val;
    case {'rawdata','psfimage','cdimage'}
        % These are the image data from the custom calibration data
        psf.sCustomData.aRawData = val;
    case {'cdrowspacing'}
        % Units of microns
        % Obsolete
        evalin('caller','mfilename')
        psf.sCustomData.deltaY = val;
    case {'cdcolspacing'}
        % Units of microns
        % Obsolete
        evalin('caller','mfilename')
        psf.sCustomData.deltaX = val;
        
        % Why is there a row and col, and the default is row.  And if there
        % is no sampCol, shouldn't we return the row?  What's going on?
    case {'psfsamplesrow','samplepositions','psfsamples'}
        % psf image (aRawData) sample spacing in microns
        % Should this be sampRow?
        psf.sCustomData.samp = val;
    case {'psfsamplescol'}
        % psf image (aRawData) sample spacing in microns
        psf.sCustomData.sampCol = val;

    otherwise
        error('Unknown psf parameter %s',param);
end

return;

