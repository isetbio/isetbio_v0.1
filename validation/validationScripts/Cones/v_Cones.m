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

%% Validation - Call validation script
ValidationScript(runTimeParams);

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
function ValidationScript(runTimeParams)

%% Create appropriate structures
sensor = sensorCreate('human');
wave   = sensorGet(sensor,'wave');
human  = sensorGet(sensor,'human');

%% Absorbance.
% These are normalized to unity.
coneAbsorbance = coneGet(human.cone,'absorbance');
UnitTest.validationData('coneAbsorbance', coneAbsorbance);
if (runTimeParams.generatePlots)
    vcNewGraphWin([],'tall');
    subplot(5,1,1)
    plot(wave,coneAbsorbance);
    ylim([0 1]);
    title('Photopigment spectral absorbance');
end

%% Plot scone spectral absorptance.
% These take optical density into account, but not anything about pre-retinal absorption.
coneSpectralAbsorptance = coneGet(human.cone,'cone spectral absorptance');
UnitTest.validationData('coneSpectralAbsorptance', coneSpectralAbsorptance);
if (runTimeParams.generatePlots)
    subplot(5,1,2)
    plot(wave,coneSpectralAbsorptance);
    ylim([0 1]);
    title('Cone photopigment spectral absorptance')
end

%% Lens transmittance
lensTransmittance = lensGet(human.lens,'transmittance');
UnitTest.validationData('lensTransmittance', lensTransmittance);
if (runTimeParams.generatePlots)
    subplot(5,1,3)
    plot(wave,lensTransmittance);
    ylim([0 1]);
    title('Lens transmittance');
end

%% Macular transmittance
macularTransmittance = macularGet(human.macular,'transmittance');
UnitTest.validationData('macularTransmittance', macularTransmittance);
if (runTimeParams.generatePlots)
    subplot(5,1,4)
    plot(wave,macularTransmittance);
    ylim([0 1]);
    title('Macular transmittance');
end

%% Quantal efficiency of cones
coneQE = sensorGet(sensor,'spectral qe');
UnitTest.validationData('coneQE', coneQE);
if (runTimeParams.generatePlots)
    subplot(5,1,5)
    plot(wave,coneQE);
    ylim([0 0.5]);
    title('Cone quantal efficiency');
end

%% Do the whole thing plot again, but with the macular pigment set to zero
human.macular = macularSet(human.macular,'density',0);
sensor = sensorSet(sensor,'human',human);
human  = sensorGet(sensor,'human');

%% Absorbance
coneAbsorbanceNoMac = coneGet(human.cone,'absorbance');
UnitTest.validationData('coneAbsorbanceNoMac', coneAbsorbanceNoMac);
if (runTimeParams.generatePlots)
    vcNewGraphWin([],'tall');
    subplot(5,1,1)
    plot(wave,coneAbsorbanceNoMac);
    ylim([0 1]);
    title('Photopigment spectral absorbance');
end

%% Plot cone spectral absorrptance
coneSpectralAbsorptanceNoMac = coneGet(human.cone,'cone spectral absorptance');
UnitTest.validationData('coneSpectralAbsorptanceNoMac', coneSpectralAbsorptanceNoMac);
if (runTimeParams.generatePlots)
    subplot(5,1,2)
    plot(wave,coneSpectralAbsorptanceNoMac);
    ylim([0 1]);
    title('Cone photopigment spectral absorptance')
end

%% Lens transmittance
lensTransmittanceNoMac = lensGet(human.lens,'transmittance');
UnitTest.validationData('lensTransmittanceNoMac', lensTransmittanceNoMac);
if (runTimeParams.generatePlots)
    subplot(5,1,3)
    plot(wave,lensTransmittanceNoMac);
    ylim([0 1]);
    title('Lens transmittance');
end

%% Macular transmittance
macularTransmittanceNoMac = macularGet(human.macular,'transmittance');
UnitTest.validationData('macularTransmittanceNoMac', macularTransmittanceNoMac);
if (runTimeParams.generatePlots)
    subplot(5,1,4)
    plot(wave,macularTransmittanceNoMac);
    ylim([0 1]);
    title('Macular transmittance - no macular');
end

%% Quantal efficiency of cones
coneQENoMac = sensorGet(sensor,'spectral qe');
UnitTest.validationData('coneQENoMac', coneQENoMac);
if (runTimeParams.generatePlots)
    subplot(5,1,5)
    plot(wave,coneQENoMac);
    ylim([0 0.5]);
    title('Cone quantal efficiency - no macular');
end

%% End
end

