function ISA = sensorCompute_OLD(ISA,OPTICALIMAGE,showWaitBar)
%Compute sensor response using ISA parameters and optical image data
%
%   ISA = sensorCompute([sensor],[opticalImage],[showWaitBar = 1])
%
%  This  top-level function  combines the parameters of an image sensor
%  array (ISA) and an optical image (OI) to produce the sensor volts
%  (electrons).
%
%  The computation checks a variety of parameters and flags in the ISA
%  structure to perform the calculation.  These parameters and flags can be
%  set either through the graphical user interface (sensorImageWindow) or
%  by scripts.
%
% COMPUTATIONAL OUTLINE:
%
%   This routine provides an overview of the algorithms.  The specific
%   algorithms are described in the routines themselves.
%
%   If the Custom button is set, then a routine provided by the user is
%   called instead of this routine.
%
%   Otherwise,
%   1.  The autoExposure flag is checked and the autoExposure routine is
%   called (or not).
%
%   2.  The sensorComputeImage() routine is called.  This is the key
%   computational routine for the mean image data; it contains many parts.
%
%   3.  Analog gain and offset are applied volts = (volts + offset)/gain.
%       With this formula, the offset set is relative to the voltage swing
%
%   4.  Correlated double sampling flag is checked and applied (or not).
%
%   5.  The Vignetting flag is checked and pixel vignetting is applied (or
%   not).
%
%   6.  The quantization flag is checked and the data are appropriately
%   quantized.
%
%   The main computations of the sensor image are done in the
%   sensorComputeImage routine.
%
%  The value of showWaitBar determines whether the waitbar is displayed to
%  indicate progress during the computation.
%
% See also:  sensorComputeMean and sensorComputeSamples
%
% Examples:
%  ISA = sensorCompute;   % Use selected ISA and OI
%  tmp = sensorCompute(vcGetObject('isa'),vcGetObject('oi'),0);
%
% Copyright ImagEval Consultants, LLC, 2005

%% Define and initialize parameters
if ieNotDefined('ISA'), ISA = vcGetObject('ISA'); end
if ieNotDefined('OPTICALIMAGE'), OPTICALIMAGE = vcGetObject('OPTICALIMAGE'); end
if ieNotDefined('showWaitBar'), showWaitBar = 1; end

wBar = [];
handles = ieSessionGet('sensorWindowHandles');

%% Switch to custom routine or stay here
% Use either the custom sensorCompute or the default.
% This appears broken now - BW
if ~isempty(handles) && get(handles.btnCustomCompute,'Value')
    % Custom sensor compute method is read
    customSC = sensorGet(ISA,'sensorComputeMethod');
    if exist(customSC,'file') ~= 2
        errordlg(sprintf('Cannot find custom method %s.',customSC));
        % scMethod = 'sensorCompute';
    end
    ISA = feval(customSC,ISA,OPTICALIMAGE);
    return;
end

%% Standard compute path
if showWaitBar, wBar = waitbar(0,'Sensor image:  '); end

integrationTime = sensorGet(ISA,'integrationTime');
pattern = sensorGet(ISA,'pattern');

if numel(integrationTime) == 1 && ...
        ( (integrationTime == 0) || sensorGet(ISA,'autoexposure') )
    % The autoexposure will need to work for the cases of 1 value for the
    % whole array and it will need to work for the case in which the
    % exposure times have the same shape as the pattern.  If neither holds
    % then we have to use the vector of numbers that are sent in.
    % We could decide that if autoexposure is on and there is a vector of
    % values we replace them with a single value.
    if showWaitBar, wBar = waitbar(0,wBar,'Sensor image: Auto Exposure'); end
    ISA.integrationTime  = autoExposure(OPTICALIMAGE,ISA);
    
elseif isvector(integrationTime)
    % We are in bracketing mode, do nothing.
    
elseif isequal( size(integrationTime),size(pattern) )
    % Find best exposure for each color filter separately   
    if sensorGet(ISA,'autoexposure')
        ISA.integrationTime  = autoExposure(OPTICALIMAGE,ISA,[],'cfa');
    end
end

%% Sensor fixed noise patterns
if isempty(sensorGet(ISA,'dsnuImage')) || isempty(sensorGet(ISA,'prnuImage'))
    % Compute voltage image and the dsnu and prnu images
    if showWaitBar, waitbar(0.3,wBar,'Sensor image: Voltage image (new dsnu/prnu)'); end
    [volts, offset, gain] = sensorComputeImage(OPTICALIMAGE,ISA,wBar);
    ISA = sensorSet(ISA,'volts',volts);
    ISA = sensorSet(ISA,'dsnuImage',offset);
    ISA = sensorSet(ISA,'prnuImage',gain);
else
    % dsnu and prnu are image are already present, so we just compute the
    % voltage image
    if showWaitBar, waitbar(0.3,wBar,'Sensor image: Voltage image (existing dsnu/prnu)'); end
    volts = sensorComputeImage(OPTICALIMAGE,ISA,wBar);
    ISA   = sensorSet(ISA,'volts',volts);
end

if isempty(sensorGet(ISA,'volts')),
    % Something went wrong.  Clean up the mess and return control to the main
    % processes.
    delete(wBar); return;
end

%% Correlated double sampling
if  sensorGet(ISA,'cds')
    % Read a zero integration time image that we will subtract from the
    % simulated image.  This removes much of the effect of dsnu.
    integrationTime = sensorGet(ISA,'integrationtime');
    ISA = sensorSet(ISA,'integrationtime',0);
    
    if showWaitBar, waitbar(0.6,wBar,'Sensor image: CDS'); end
    cdsVolts = sensorComputeImage(OPTICALIMAGE,ISA);
    ISA = sensorSet(ISA,'integrationtime',integrationTime);
    ISA = sensorSet(ISA,'volts',ieClip(ISA.data.volts - cdsVolts,0,[]));
end

if showWaitBar, waitbar(0.95,wBar,'Sensor image: A/D'); end

% Compute the digital values (DV).   The results are written into
% ISA.data.dv.  If the quantization method is Analog, then the data.dv
% field is cleared and the data are stored only in data.volts.

%% Clipping and quanzation
% We clip the voltage because we assume that everything must fall between 0 and voltage swing.
% We could broaden our horizons.
pixel = sensorGet(ISA,'pixel');
vSwing = pixelGet(pixel,'voltageswing');
ISA = sensorSet(ISA,'volts',ieClip(sensorGet(ISA,'volts'),0,vSwing));

switch lower(sensorGet(ISA,'quantizationmethod'))
    case 'analog'
        dv = [];
        ISA = sensorSet(ISA,'volts',analog2digital(ISA,'analog'));
    case 'linear'
        ISA = sensorSet(ISA,'digitalvalues',analog2digital(ISA,'linear'));
    case 'sqrt'
        ISA = sensorSet(ISA,'digitalvalues',analog2digital(ISA,'sqrt'));
    case 'lut'
        warning('LUT quantization not yet implemented.')
    case 'gamma'
        warning('Gamma quantization not yet implemented.')
    otherwise
        ISA = sensorSet(ISA,'digitalvalues',analog2digital(ISA,'linear'));
end

%% Macbeth chart management
% Possible overlay showing center of Macbeth chart
ISA = sensorSet(ISA,'mccRectHandles',[]);

% Indicate oi it is derived from - maybe not.
% ISA = sensorSet(ISA,'name',oiGet(oi,'name'));

if showWaitBar, close(wBar); end

return;