function adaptedData = riekeAdapt(sensor,params)
%Convert photon absorption rates at the sensor into cone photocurrent
%
%  adaptedData = riekeAdapt(sensor,params)
%
% The returned adapted data are in units of current (pico amps).  The size
% of adapted data is equal to the size of the time series of input photons.
% These are stored as a (x,y,t) array in the sensor.
% 
% In this case, the physiological differential equations for cones
% are implemented. The differential equations are (from Rieke's PPT)
%
%    1) d opsin(t) / dt = -sigma * opsin(t) + R*(t)
%    2) d PDE(t) / dt   = opsin(t) - phi * PDE(t) + eta
%    3) d cGMP(t) / dt  = S(t) - PDE(t) * cGMP(t)
%    4) d Ca(t) / dt    = q * I(t) - beta * Ca(t)
%    5) d Ca_slow(t) / dt = - beta_slow * (Ca_slow(t) - Ca(t))
%    6) S(t) = smax / (1 + (Ca(t)/kGc)^n)
%    7) I(t) = k * cGMP(t)^h / (1 + Ca_slow/Ca_dark)
%
% This model gives a cone-by-cone time series for the current. To calculate
% the response requires a time-series of photon absorptions in the sensor
% structure.
%
% 
%
% Comments:
%
% This is a very nonlinear set of equations that cannot be reduced to an
% auto-regressive (AR) formulation.  The difference between the
% steady-state responses with this adaptation model and the simpler ones
% (e.g., from Dunn et al.) is modest.  Though we should really check how
% much of an effect there is by running specific calculations that include
% noise.
%
% The advantage of this calculation is that it does a better job at
% capturing the rapid temporal fluctuations (ms timescale) than simpler
% models.  So, perhaps this should be used for cases where the rapid
% onset/offset voltage swings matter.  It may be less useful and not worth
% the extra computation for steady-state judgments.
%
% Problem ... the different equations always solve to a positive value.
% But the measured current reports are sometimes negative (HJ).
%
% Example:
%    
% HJ ISETBIO Team, 2013

%% Initialize parameters

% Number of isomerizations in a single integration time.
% We make sure these are double, not single.
photons = double(sensorGet(sensor, 'photons'));
if isempty(photons), error('Non-adapted cone absorptions (photons) should be pre-computed'); end

% Initialize the parameters for the adaptation model
p = riekeInit;
if isempty(p.bgPhotons), p.bgPhotons = median(photons(:)); end

% Now copy fields that are sent in
if notDefined('params')
    % Do nothing
else
    fields = fieldnames(params);
    for ii=1:length(fields)
        switch fields{ii}
            case 'sigma'
            case 'phi'
            case 'eta'
            case 'gdark'
            case 'k'
            case 'cdark'
            case 'beta'
            case 'betaSlow'
            case 'n'
            case 'kGc'
            case 'h'
            case 'bgPhotons'
                % Over ride the assumed mean
                p.bgPhotons = params.bgPhotons;
            otherwise
                error('Unknown field name %s\n',fields{ii));
        end
    end
end

%% Start calculation

% Convert to the rate of isomerizations per second
photons   = photons   / sensorGet(sensor, 'exposure time');
bgPhotons = bgPhotons / sensorGet(sensor, 'exposure time');

% This is stored in the eye movement structure.
dt = sensorGet(sensor, 'sample time interval');
if isempty(dt), dt = 1e-3; end

% Prior to the onset of the stimulus, there is some adaptation of the
% system.  This function estimates the background current, bgCur, at the
% initial time point by finding the current from the mean response.
bgCur = riekeAdaptSteadyState(bgPhotons,p);

% Compute initial values for the differential equations
opsin   = ones(sensorGet(sensor, 'size')) * bgPhotons / sigma;
PDE     = (opsin + eta) / phi;
Ca      = ones(sensorGet(sensor, 'size')) * bgCur * q / beta;
Ca_slow = Ca;
st      = smax ./ (1 + (Ca / kGc).^n);
cGMP    = st * phi ./ (opsin + eta);

% The units are some kind of current (pico ampere, 10^-12 amps)
% These are time course of the current at each of the photoreceptor sample
% points. 
% The time, dt, is the sample period.
adaptedData = zeros([size(opsin) size(volts, 3)]);

% Simulate differential equations from Fred's PowerPoint slides.
% The adapted data are in units of current (pico amps)
for ii = 1 : size(volts, 3)
    opsin = opsin + dt * (photons(:,:,ii) - sigma * opsin);
    PDE   = PDE   + dt * (opsin + eta - phi * PDE);
    Ca    = Ca    + dt * (q*k * cGMP.^h./(1+Ca_slow/cdark)-beta*Ca);
    st    = smax ./ (1 + (Ca / kGc).^n);
    cGMP  = cGMP  + dt * (st - PDE .* cGMP);
    Ca_slow = Ca_slow - dt * betaSlow * (Ca_slow - Ca);
    adaptedData(:,:,ii) = - k * cGMP.^h ./ (1 + Ca_slow / cdark);
end


end


    