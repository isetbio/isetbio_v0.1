function sensor = riekeAdapt(sensor,params)
%
%  sensor = riekeAdapt(sensor,params)
%
% Functionalizing HJ's code for the adaptation model
% We will change the name and improve and test over the next few weeks
%
% In this case, the physiological differential equations for cones
% are implemented. The differential equations are:
%    1) d opsin(t) / dt = -sigma * opsin(t) + R*(t)
%    2) d PDE(t) / dt = opsin(t) - phi * PDE(t) + eta
%    3) d cGMP(t) / dt = S(t) - PDE(t) * cGMP(t)
%    4) d Ca(t) / dt = q * I(t) - beta * Ca(t)
%    5) d Ca_slow(t) / dt = - beta_slow * (Ca_slow(t) - Ca(t))
%    6) S(t) = smax / (1 + (Ca(t)/kGc)^n)
%    7) I(t) = k * cGMP(t)^h / (1 + Ca_slow/Ca_dark)
%
% This model gives a cone-by-cone adaptation and it requires a
% time-series data in sensor structure
%
% HJ ISETBIO Team, 2013

%% Initialize parameters

% Default parameter values
sigma = 100;  % rhodopsin activity decay rate (1/sec)
phi = 50;     % phosphodiesterase activity decay rate (1/sec)
eta = 100;	  % phosphodiesterase activation rate constant (1/sec)
gdark = 35;	  % concentration of cGMP in darkness
k = 0.02;     % constant relating cGMP to current
cdark = 0.5;  % dark calcium concentration
beta = 50;	  % rate constant for calcium removal in 1/sec
betaSlow = 2;
n = 4;  	  % cooperativity, hill coef
kGc = 0.35;   % hill affinity
h = 3;
bgVolts = 0;  % Default background voltage

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
            case 'bgVolts'
            otherwise
                error('Unknown field name %s\n',fields{ii));
        end
    end
end

%% Start calculation
volts  = double(sensorGet(sensor, 'volts'));

if isempty(volts), error('cone absorptions should be pre-computed'); end

if isfield(params, 'vSwing'), vSwing = params.vSwing;
else                          vSwing = sensorGet(sensor,'pixel voltageSwing');
end

if isfield(params, 'bgVolts'), bgVolts = params.bgVolts; 
else                           bgVolts = median(volts(:));
end

q    = 2 * beta * cdark / (k * gdark^h);
smax = eta/phi * gdark * (1 + (cdark / kGc)^n);

photons = volts / sensorGet(sensor, 'conversion gain');
photons = photons / sensorGet(sensor, 'exposure time');
dt = sensorGet(sensor, 'timeInterval');

% Compute background adaptation parameters
bgR = bgVolts / sensorGet(sensor, 'conversion gain');
bgCur = fminbnd(@(x) abs(x - k*beta*cdark*smax^h * phi^h / ...
    (bgR/sigma + eta)^h / (beta*cdark + q*x) / ...
    (1 + (q*x/beta/kGc)^n)^h), 0, 1000);

% Compute starting values
opsin   = ones(sensorGet(sensor, 'size')) * bgR / sigma;
PDE     = (opsin + eta) / phi;
Ca      = ones(sensorGet(sensor, 'size')) * bgCur * q / beta;
Ca_slow = Ca;
st      = smax ./ (1 + (Ca / kGc).^n);
cGMP    = st * phi ./ (opsin + eta);

% simulate differential equtions
adaptedData = zeros([size(opsin) size(volts, 3)]);
for ii = 1 : size(volts, 3)
    opsin = opsin + dt * (photons(:,:,ii) - sigma * opsin);
    PDE   = PDE   + dt * (opsin + eta - phi * PDE);
    Ca    = Ca    + dt * (q*k * cGMP.^h./(1+Ca_slow/cdark)-beta*Ca);
    st    = smax ./ (1 + (Ca / kGc).^n);
    cGMP  = cGMP  + dt * (st - PDE .* cGMP);
    Ca_slow = Ca_slow - dt * betaSlow * (Ca_slow - Ca);
    adaptedData(:,:,ii) = - k * cGMP.^h ./ (1 + Ca_slow / cdark);
end

% Set back
% Currently, there's no space for temporally varying adaptation
% data. Thus, we just return back the adapted data
gainMap = [];
bgVolts = [];

end
