function varargout = v_Cones(varargin)
%
% Test cone, lens and macular function calls.
%
% Issues:
%
% 1) It would be clever to compare each piece to what PTB returns.
%
% ISETBIO Team Copyright 2013-14

%% Initialization
% Initialize validation run and return params
runTimeParams = UnitTest.initializeValidationRun(varargin{:});
if (nargout > 0) varargout = {'', false, []}; end
close all;

%% Call the validation function
ValidationFunction(runTimeParams);

%% Reporting and return params
if (nargout > 0)
    [validationReport, validationFailedFlag, validationFundametalFailureFlag] = ...
        UnitTest.validationRecord('command', 'return');
    validationData  = UnitTest.validationData('command', 'return');
    extraData       = UnitTest.extraData('command', 'return');
    varargout       = {validationReport, validationFailedFlag, validationFundametalFailureFlag, validationData, extraData};
else
    if (runTimeParams.printValidationReport)
        [validationReport, ~] = UnitTest.validationRecord('command', 'return');
        UnitTest.printValidationReport(validationReport);
    end
end
end

%% Actual script
function ValidationFunction(runTimeParams)

%% Create appropriate structures
sensor = sensorCreate('human');
wave   = sensorGet(sensor,'wave');
human  = sensorGet(sensor,'human');

%% Absorbance.
% These are normalized to unity.
coneAbsorbance = coneGet(human.cone,'absorbance');
UnitTest.validationData('coneAbsorbance', coneAbsorbance);

%% Plot scone spectral absorptance.
% These take optical density into account, but not anything about pre-retinal absorption.
coneSpectralAbsorptance = coneGet(human.cone,'cone spectral absorptance');
UnitTest.validationData('coneSpectralAbsorptance', coneSpectralAbsorptance);

%% Lens transmittance
lensTransmittance = lensGet(human.lens,'transmittance');
UnitTest.validationData('lensTransmittance', lensTransmittance);

%% Macular transmittance
macularTransmittance = macularGet(human.macular,'transmittance');
UnitTest.validationData('macularTransmittance', macularTransmittance);

%% Quantal efficiency of cones
coneQE = sensorGet(sensor,'spectral qe');
UnitTest.validationData('coneQE', coneQE);

%% Plot
if (runTimeParams.generatePlots)
    vcNewGraphWin([],'tall');
    subplot(5,1,1)
    plot(wave,coneAbsorbance);
    ylim([0 1]);
    title('Photopigment spectral absorbance');
    
    subplot(5,1,2)
    plot(wave,coneSpectralAbsorptance);
    ylim([0 1]);
    title('Cone photopigment spectral absorptance')
    
    subplot(5,1,3)
    plot(wave,lensTransmittance);
    ylim([0 1]);
    title('Lens transmittance');
    
    subplot(5,1,4)
    plot(wave,macularTransmittance);
    ylim([0 1]);
    title('Macular transmittance');
    
    subplot(5,1,5)
    plot(wave,coneQE);
    ylim([0 0.5]);
    title('Cone quantal efficiency');
end

%% Do the whole thing again, but with the macular pigment set to zero
% The cone absorbance, cone absorptance, and lens transmittance don't
% change, but macular transmittance and the cone quantal efficiences do.
%
% Note that we need to be sure to write the changed human structure back
% into the sensor.
human.macular = macularSet(human.macular,'density',0);
sensor = sensorSet(sensor,'human',human);
human  = sensorGet(sensor,'human');

%% Absorbance
coneAbsorbanceNoMac = coneGet(human.cone,'absorbance');
UnitTest.validationData('coneAbsorbanceNoMac', coneAbsorbanceNoMac);

%% Plot cone spectral absorrptance
coneSpectralAbsorptanceNoMac = coneGet(human.cone,'cone spectral absorptance');
UnitTest.validationData('coneSpectralAbsorptanceNoMac', coneSpectralAbsorptanceNoMac);

%% Lens transmittance
lensTransmittanceNoMac = lensGet(human.lens,'transmittance');
UnitTest.validationData('lensTransmittanceNoMac', lensTransmittanceNoMac);

%% Macular transmittance
macularTransmittanceNoMac = macularGet(human.macular,'transmittance');
UnitTest.validationData('macularTransmittanceNoMac', macularTransmittanceNoMac);

%% Quantal efficiency of cones
coneQENoMac = sensorGet(sensor,'spectral qe');
UnitTest.validationData('coneQENoMac', coneQENoMac);

%% Plot
if (runTimeParams.generatePlots)
    vcNewGraphWin([],'tall');
    subplot(5,1,1)
    plot(wave,coneAbsorbanceNoMac);
    ylim([0 1]);
    title('Photopigment spectral absorbance');
    
    subplot(5,1,2)
    plot(wave,coneSpectralAbsorptanceNoMac);
    ylim([0 1]);
    title('Cone photopigment spectral absorptance')
    
    subplot(5,1,3)
    plot(wave,lensTransmittanceNoMac);
    ylim([0 1]);
    title('Lens transmittance');
    subplot(5,1,4)
    plot(wave,macularTransmittanceNoMac);
    ylim([0 1]);
    title('Macular transmittance - no macular');
    subplot(5,1,5)
    plot(wave,coneQENoMac);
    ylim([0 0.5]);
    title('Cone quantal efficiency - no macular');
end

%% End
end

