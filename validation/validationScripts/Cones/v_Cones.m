function varargout = v_Cones(varargin)
%
% Test cone, lens and macular function calls.
%
% Issues:
%
% 1)Setting the macular pigment to zero density (unity transmittance) seems
% to have no effect.
%
% 2) Need to store some validation for future comparison, once issue 1 is
% fixed.
%
% 3) Need more comments in the code to say what each piece is and perhaps
% how the whole cone thing works.
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

function ValidationScript(runTimeParams)

%% Create appropriate structures
sensor = sensorCreate('human');
wave   = sensorGet(sensor,'wave');
human  = sensorGet(sensor,'human');

%% Plot scone spectral absorrptance
coneSpectralAbsorptance = coneGet(human.cone,'cone spectral absorptance');
if (runTimeParams.generatePlots)
    vcNewGraphWin([],'tall');
    subplot(5,1,1)
    plot(wave,coneSpectralAbsorptance);
    ylim([0 1]);
    title('Cone spectral absorptance')
end

%% Lens transmittance
lensTransmittance = lensGet(human.lens,'transmittance');
if (runTimeParams.generatePlots)
    subplot(5,1,2)
    plot(wave,lensTransmittance);
    ylim([0 1]);
    title('Lens transmittance');
end

%% Macular transmittance
macularTransmittance = macularGet(human.macular,'transmittance');
if (runTimeParams.generatePlots)
    subplot(5,1,3)
    plot(wave,macularTransmittance);
    ylim([0 1]);
    title('Macular transmittance');
end

%% Absorbance
coneAbsorbance = coneGet(human.cone,'absorbance');
if (runTimeParams.generatePlots)
    subplot(5,1,4)
    plot(wave,coneAbsorbance);
    ylim([0 1]);
    title('Cone-ocular absorbance');
end

%% Quantal efficiency of cones
coneQE = sensorGet(sensor,'spectral qe');
if (runTimeParams.generatePlots)
    subplot(5,1,5)
    plot(wave,coneQE);
    ylim([0 0.5]);
    title('Cone quantal efficiency');
end

%% Do the whole thing plot again, but with the macular pigment set to zero
human.macular = macularSet(human.macular,'density',0);

%% Plot scone spectral absorrptance
coneSpectralAbsorptance = coneGet(human.cone,'cone spectral absorptance');
if (runTimeParams.generatePlots)
    vcNewGraphWin([],'tall');
    subplot(5,1,1)
    plot(wave,coneSpectralAbsorptance);
    ylim([0 1]);
    title('Cone spectral absorptance - no macular')
end

%% Lens transmittance
lensTransmittance = lensGet(human.lens,'transmittance');
if (runTimeParams.generatePlots)
    subplot(5,1,2)
    plot(wave,lensTransmittance);
    ylim([0 1]);
    title('Lens transmittance - no macular');
end

%% Macular transmittance
macularTransmittance = macularGet(human.macular,'transmittance');
if (runTimeParams.generatePlots)
    subplot(5,1,3)
    plot(wave,macularTransmittance);
    ylim([0 1]);
    title('Macular transmittance - no macular');
end

%% Absorbance
coneAbsorbance = coneGet(human.cone,'absorbance');
if (runTimeParams.generatePlots)
    subplot(5,1,4)
    plot(wave,coneAbsorbance);
    ylim([0 1]);
    title('Cone-ocular absorbance - no macular');
end

%% Quantal efficiency of cones
coneQE = sensorGet(sensor,'spectral qe');
if (runTimeParams.generatePlots)
    subplot(5,1,5)
    plot(wave,coneQE);
    ylim([0 0.5]);
    title('Cone quantal efficiency - no macular');
end

%% End
end

