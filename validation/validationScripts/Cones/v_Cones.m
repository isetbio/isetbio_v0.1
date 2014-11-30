function varargout = v_Cones(varargin)
%
% Test cone, lens and macular function calls.
%
% Issues:
%
% 1) This crashes on the call to coneGet(cone,'lens'), which is the
% state it was in when I found it.
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
        [validationReport, validationFailedFlag] = UnitTest.validationRecord('command', 'return');
        validationData = UnitTest.validationData('command', 'return');
        varargout = {validationReport, validationFailedFlag, validationData};
    else
        if (runTimeParams.printValidationReport)
            [validationReport, ~] = UnitTest.validationRecord('command', 'return');
            UnitTest.printValidationReport(validationReport);
        end 
    end
end

function ValidationScript(runTimeParams)%% v_Cones

%% Create a cone structure
cone = coneCreate;
wave = coneGet(cone,'wave');

%% Get and plot the spectral absorptance
vcNewGraphWin([],'tall');
subplot(4,1,1)
plot(wave,coneGet(cone,'cone spectral absorptance'));
title('Cone spectral absorptance')

subplot(4,1,2)
lens = coneGet(cone,'lens');
plot(wave,lensGet(lens,'transmittance'))
title('Lens transmittance')

subplot(4,1,3)
macular = coneGet(cone,'macular');
plot(wave,macularGet(macular,'transmittance'))
title('Macular transmittance')

subplot(4,1,4)
plot(wave,coneGet(cone,'effective spectral absorptance'))
title('Cone-ocular absorptance')

%% Plot again, but change the macular pigment density to 0

m = coneGet(cone,'macular');
m = macularSet(m,'density',0);
cone = coneSet(cone,'macular',m);

%%
vcNewGraphWin([],'tall');
subplot(4,1,1)
plot(wave,coneGet(cone,'cone spectral absorptance'));
title('Cone spectral absorptance')

subplot(4,1,2)
lens = coneGet(cone,'lens');
plot(wave,lensGet(lens,'transmittance'))
title('Lens transmittance')

subplot(4,1,3)
macular = coneGet(cone,'macular');
plot(wave,macularGet(macular,'transmittance'))
title('Macular transmittance')

subplot(4,1,4)
plot(wave,coneGet(cone,'effective spectral absorptance'))
title('Cone-ocular absorptance')

%% End
end