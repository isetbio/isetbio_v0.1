function [validationReport, validationFailedFlag, validationData] = PTB_vs_ISETBIO_Irradiance(varargin)
%
%   Validate ISETBIO-based irradiance/isomerization computations by comparing to PTB-based irradiance/isomerization computations.
% 
    %% Initialization   
    % Initialize return variables
    validationReport = ''; validationFailedFlag = false; validationData = [];
    % Initialize validation run
    runTimeParams = UnitTest.initializeValidationRun(varargin{:});
    
    %% Validation code
    
    %% Initialize ISETBIO
    s_initISET;
       
    %% Set computation params
    fov     = 20;  % need large field
    roiSize = 5;
        
    %% Create a radiance image in ISETBIO
    scene = sceneCreate('uniform ee');    % Equal energy
    scene = sceneSet(scene,'name','Equal energy uniform field');
    scene = sceneSet(scene,'fov', fov);
    
    %% Compute the irradiance in ISETBIO
    %
    % To make comparison to PTB work, we turn off
    % off axis correction as well as optical blurring
    % in the optics.
    oi     = oiCreate('human');
    optics = oiGet(oi,'optics');
    optics = opticsSet(optics,'off axis method','skip');
    optics = opticsSet(optics,'otf method','skip otf');
    oi     = oiSet(oi,'optics',optics);
    oi     = oiCompute(oi,scene);

    % Define a region of interest starting at the scene's center with size
    % roiSize x roiSize
    sz = sceneGet(scene,'size');
    rect = [sz(2)/2,sz(1)/2,roiSize,roiSize];
    sceneRoiLocs = ieRoi2Locs(rect);
    
    %% Get wavelength and spectral radiance spd data (averaged within the scene ROI) 
    wave  = sceneGet(scene,'wave');
    radiancePhotons = sceneGet(scene,'roi mean photons', sceneRoiLocs);
    radianceEnergy  = sceneGet(scene,'roi mean energy',  sceneRoiLocs); 
    
    % Need to recenter roi because the optical image is
    % padded to deal with optical blurring at its edge.
    sz         = oiGet(oi,'size');
    rect       = [sz(2)/2,sz(1)/2,roiSize,roiSize];
    oiRoiLocs  = ieRoi2Locs(rect);

    %% Get wavelength and spectral irradiance spd data (averaged within the scene ROI)
    wave                    = oiGet(scene,'wave');
    isetbioIrradianceEnergy = oiGet(oi, 'roi mean energy', oiRoiLocs);

    %% Get the underlying parameters that are needed from the ISETBIO structures.
    optics = oiGet(oi,'optics');
    pupilDiameterMm  = opticsGet(optics,'pupil diameter','mm');
    focalLengthMm    = opticsGet(optics,'focal length','mm');
    
    %% Compute the irradiance in PTB
    % The PTB calculation is encapsulated in ptb.ConeIsomerizationsFromRadiance.
    % This routine also returns cone isomerizations, which we are not validating here.
    % The macular pigment and integration time parameters affect the isomerizations,
    % but don't affect the irradiance returned by the PTB routine.
    % The integration time doesn't affect the irradiance, but we
    % need to pass it 
    macularPigmentOffset = 0;
    integrationTimeSec   = 0.05;
    [isoPerCone, ~, ptbPhotoreceptors, ptbIrradiance] = ...
        ptb.ConeIsomerizationsFromRadiance(radianceEnergy(:), wave(:),...
        pupilDiameterMm, focalLengthMm, integrationTimeSec,macularPigmentOffset);
    
    % Compare irradiances computed by ISETBIO vs. PTB
    % accounting for the magnification difference.
    % The magnification difference results from how Peter Catrysse implemented the radiance to irradiance
    % calculation in isetbio versus the simple trig formula used in PTB. Correcting for this reduces the difference
    % to about 1%.
    m = opticsGet(optics,'magnification',sceneGet(scene,'distance'));
    ptbMagCorrectIrradiance = ptbIrradiance(:)/(1+abs(m))^2;
    
     
    %% Numerical check to decide whether we passed.
    % We are checking against a 1% error.
    tolerance = 0.01;
    ptbMagCorrectIrradiance = ptbMagCorrectIrradiance(:);
    isetbioIrradianceEnergy = isetbioIrradianceEnergy(:);
    difference = ptbMagCorrectIrradiance-isetbioIrradianceEnergy;
    if (max(abs(difference./isetbioIrradianceEnergy)) > tolerance)
        message = sprintf('Validation FAILED. Difference between PTB and isetbio irradiance exceeds tolerance of %0.1f%% !!!', 100*tolerance);
        validationFailedFlag = true;
    else
        message = sprintf('Validation PASSED. PTB and isetbio agree about irradiance to %0.1f%%',100*tolerance);
        validationFailedFlag = false;
    end
    
    % update validationReport and validationData struct
    UnitTest.validationRecord('appendMessage', message);
    UnitTest.validationData('fov', fov);
    UnitTest.validationData('roiSize', roiSize);
    UnitTest.validationData('tolerance', tolerance);
    UnitTest.validationData('scene', scene);
    UnitTest.validationData('oi', oi);
    UnitTest.validationData('ptbMagCorrectIrradiance', ptbMagCorrectIrradiance);
    UnitTest.validationData('isetbioIrradianceEnergy',isetbioIrradianceEnergy);
    
    %% Compare spectral sensitivities used by ISETBIO and PTB.
    %
    % THe PTB routine above uses the CIE 2-deg standard, which is the
    % Stockman-Sharpe 2-degree fundamentals.  Apparently, so does ISETBIO.
    coneTolerance = 1e-3;
    ptbCones = ptbPhotoreceptors.isomerizationAbsorptance';
    sensor    = sensorCreate('human');
    isetCones = sensorGet(sensor,'spectral qe');
    isetCones = isetCones(:,2:4);
    coneDifference = ptbCones-isetCones;
    if (max(abs(coneDifference)) > coneTolerance)
        message = sprintf('Validation FAILED. Difference between PTB and isetbio cone quantal efficiencies %0.1g !!!', coneTolerance);
        validationFailedFlag = true;
    else
        message = sprintf('Validation PASSED. PTB and isetbio agree about cone quantal efficiencies to %0.1g',coneTolerance);
        validationFailedFlag = false;
    end
    % update validationReport and validationData struct
    UnitTest.validationRecord('appendMessage', message);
    UnitTest.validationData('isetCones',  isetCones);
    UnitTest.validationData('ptbCones',  ptbCones);
    UnitTest.validationData('coneTolerance', coneTolerance);
    UnitTest.validationData('sensor', sensor);
   
    %% Compute quantal absorptions
    %
    % Put this in as a placeholder.
    % Need to:
    %  Get our L, M, S absorptions from the RO1 where we get the spectrum
    %  Do PTB computation
    %  Compare
    %  Work through parameters that might lead to differences
    %    e.g., cone aperture, integration time, ...
    sensor = coneAbsorptions(sensor, oi);
    volts  = sensorGet(sensor,'volts');

    
    %% Gather data on record
    validationReport = UnitTest.validationRecord('command', 'return');
    validationData   = UnitTest.validationData('command', 'return');
    
    %% Generate plots, if so specified
    if (runTimeParams.generatePlots)

        h = figure(500);
        clf;
        set(h, 'Position', [100 100 800 600]);
        subplot(2,1,1);
        plot(wave, ptbIrradiance, 'ro', 'MarkerFaceColor', [1.0 0.8 0.8], 'MarkerSize', 10);
        hold on;
        plot(wave, isetbioIrradianceEnergy, 'bo', 'MarkerFaceColor', [0.8 0.8 1.0], 'MarkerSize', 10);
        hold off
        set(gca,'ylim',[0 1.2*max([max(ptbIrradiance(:)) max(isetbioIrradianceEnergy(:))])]);
        set(gca, 'FontName', 'Helvetica', 'FontSize', 14,  'FontWeight', 'bold');
        legend({'PTB','ISETBIO'}, 'Location','SouthEast','FontSize',12);
        xlabel('Wave (nm)', 'FontName', 'Helvetica', 'FontSize', 16); ylabel('Irradiance (q/s/nm/m^2)', 'FontName', 'Helvetica', 'FontSize', 16)
        title('Without magnification correction', 'FontName', 'Helvetica', 'FontSize', 18, 'FontWeight', 'bold');
    
        subplot(2,1,2);
        plot(wave,ptbMagCorrectIrradiance,'ro', 'MarkerFaceColor', [1.0 0.8 0.8], 'MarkerSize', 10);
        hold on;
        plot(wave,isetbioIrradianceEnergy,'bo', 'MarkerFaceColor', [0.8 0.8 1.0], 'MarkerSize', 10);
        hold off
        set(gca,'ylim',[0 1.2*max([max(ptbIrradiance(:)) max(isetbioIrradianceEnergy(:))])]);
        set(gca, 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold');
        xlabel('Wave (nm)', 'FontName', 'Helvetica', 'FontSize', 14); ylabel('Irradiance (q/s/nm/m^2)', 'FontName', 'Helvetica', 'FontSize', 14)
        legend({'PTB','ISETBIO'}, 'Location','SouthEast','FontSize',12)
        title('Magnification-corrected comparison', 'FontName', 'Helvetica', 'FontSize', 18, 'FontWeight', 'bold');
        
        % Compare PTB sensor spectral responses with ISETBIO
        vcNewGraphWin; hold on; 
        set(gca, 'FontName', 'Helvetica', 'FontSize', 14,  'FontWeight', 'bold');
        plot(wave, isetCones(:,1),'ro', 'MarkerFaceColor', [1.0 0.8 0.8], 'MarkerSize', 10);
        plot(wave, ptbCones(:,1), 'r-');
        plot(wave, isetCones(:,2),'go', 'MarkerFaceColor', [0.8 1.0 0.8], 'MarkerSize', 10);
        plot(wave, ptbCones(:,2), 'g-');
        plot(wave, isetCones(:,3),'bo', 'MarkerFaceColor', [0.8 0.8 1.0], 'MarkerSize', 10);
        plot(wave, ptbCones(:,3), 'b-');
        legend({'ISETBIO','PTB'},'Location','NorthWest','FontSize',12);
        xlabel('Wavelength');
        ylabel('Quantal Efficiency')

        vcNewGraphWin; hold on
        set(gca, 'FontName', 'Helvetica', 'FontSize', 14,  'FontWeight', 'bold');
        plot(ptbCones(:),isetCones(:),'o','MarkerSize', 10);
        plot([0 0.5],[0 0.5], '--');
        xlabel('PTB cones');
        ylabel('ISET cones');
        axis('square');
    end 
    
   
    %% Validation report printing
    if (runTimeParams.printValidationReport)
        disp(validationReport);
        fprintf('\n');
    end
    
end