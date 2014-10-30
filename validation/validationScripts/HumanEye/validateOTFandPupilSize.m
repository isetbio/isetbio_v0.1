function validateOTFandPupilSize(runParams)
%
% Validate the OTF as a function of pupil size by comparing it to the OTFs
% derived by Watson in  Watson JOV (2013) "A formula for the mean human
% optical modulation transfer function as a function of pupil size".
% http://www.journalofvision.org/content/13/6/18.short?related-urls=yes&legid=jov;13/6/18)
%

    % Call the validation script
    [validationReport, validationFailedFlag, validationDataToSave] = validationScript(runParams);
        
    % Update the parent @UnitTest object
    UnitTest.updateParentUnitTestObject(validationReport, validationFailedFlag, validationDataToSave, runParams);
end

%% Skeleton validation script
function [validationReport, validationFailedFlag, validationDataToSave] = validationScript(runParams)

    %% Initialize return params
    validationReport = 'Nothing to report.'; 
    validationFailedFlag = false; 
    validationDataToSave = struct();
    
    %% Initialize ISETBIO
    s_initISET;
    

    % Pupil diameters to test
    examinedPupilDiametersInMillimeters = (2:0.5:6.5);
    
    for pupilSizeIndex = 1:numel(examinedPupilDiametersInMillimeters)
        
        %% Retrieve examined pupil radius 
        pupilDiameterInMillimeters = examinedPupilDiametersInMillimeters(pupilSizeIndex);
        pupilRadiusInMeters = pupilDiameterInMillimeters/2.0/1000.0;
        
        %% Create human optics with given pupil radius
        optics = opticsCreate('human', pupilRadiusInMeters);
        
        %% Initialize optical image with above optics
        oi = oiCreate('human');
        oi = oiSet(oi, 'optics', optics);
        
        %% Compute optical image for given scene
        scene = sceneCreate('line d65');
        %% Make the scene angular size = 1 deg and place it at a distance = 1.0 m
        sceneAngularSizeInDeg = 2.0;
        sceneDistanceInMeters = 1.0;
        scene = sceneSet(scene,'wangular', sceneAngularSizeInDeg);
        scene = sceneSet(scene,'distance', sceneDistanceInMeters);
        
        %% Compute optical image
        oi = oiCompute(scene,oi); 
        
        %% Compute RGB rendition of optical image
        opticalRGBImage = oiGet(oi, 'rgb image');
        sceneRGBImage   = sceneGet(scene, 'rgb image');
        compositeRGBimage = generateCompositeImage(sceneRGBImage, opticalRGBImage);
        
        %% Retrieve the full OTF
        optics = oiGet(oi, 'optics');
        OTF    = abs(opticsGet(optics,'otf data'));
        
        %% Retrieve the wavelength axis
        OTFwavelengths = opticsGet(optics,'otf wave');
        
        %% Retrieve the spatial frequency support. This is in cycles/micron
        OTFsupport = opticsGet(optics,'otf support', 'um');
        
        otf_sfXInCyclesPerMicron = OTFsupport{1};
        otf_sfYInCyclesPerMicron = OTFsupport{2};
        
        %% Convert to cycles/deg.
        % In human retina, 1 deg of visual angle is about 288 microns
        micronsPerDegee = 288;
        otf_sfX = otf_sfXInCyclesPerMicron * micronsPerDegee;
        otf_sfY = otf_sfYInCyclesPerMicron * micronsPerDegee;
        
        %% Get the 2D slice at 550 nm
        [~,waveIndex]   = min(abs(OTFwavelengths - 550));
        examinedWaveLength = OTFwavelengths(waveIndex);
        
        %% Shift (0,0) to origin
        OTF550 = fftshift(squeeze(OTF(:,:,waveIndex)));
        
        %% Get a 2D slice through origin
        [~, sfIndex] = min(abs(otf_sfY - 0));
        OTFslice = squeeze(OTF550(sfIndex,:));
        
        
        %% Generate plots, if so specified
        if (nargin >= 1) && (isfield(runParams, 'generatePlots')) && (runParams.generatePlots == true)
        
            plotWidth = 0.3;
            plotHeight = 0.85/(numel(examinedPupilDiametersInMillimeters)/2);
            margin     = 0.021;
            if (pupilSizeIndex <= numel(examinedPupilDiametersInMillimeters)/2)
                if (pupilSizeIndex == 1)
                    % start figure 1
                    h1 = figure(1);
                    set(h1, 'Position', [100 100 650 760]);
                    clf;
                end
                figure(h1);
                subplotRow = pupilSizeIndex;
            else
                if (pupilSizeIndex == numel(examinedPupilDiametersInMillimeters)/2+1)
                    % Start figure 2
                    h2 = figure(2);
                    set(h2, 'Position', [200 200 650 760]);
                    clf;
                end
                figure(h2);
                subplotRow = pupilSizeIndex-numel(examinedPupilDiametersInMillimeters)/2;
            end

            %% Plot the 2D OTF
            subplot('Position', [0.03 1+margin/2-subplotRow*(plotHeight+margin) plotWidth plotHeight]);
            imagesc(otf_sfX, otf_sfY, OTF550);
            axis 'image'
            axis 'xy'
            if (pupilSizeIndex == numel(examinedPupilDiametersInMillimeters))
               xlabel('cycles/deg');
            else
               xlabel(''); 
            end
            set(gca, 'XLim', [-60 60], 'YLim', [-60 60], 'XTick', [-60:60:60], 'YTick', [-60:60:60]);
            colormap(gray(256));
        
            %% Plot the 1D OTF slice
            subplot('Position', [0.06+plotWidth 1+margin/2-subplotRow*(plotHeight+margin) plotWidth plotHeight]);
            indices = find(otf_sfX >= 0);
            OTFsfX = otf_sfX(indices)+0.001;
            plot(OTFsfX, OTFslice(indices), 'rs-', 'MarkerSize', 8, 'MarkerFaceColor', [1 0.8 0.8]);
            hold on;
            % plot the modelOTF from Watson's model
            modelOTF = WatsonOTFmodel(pupilDiameterInMillimeters, examinedWaveLength, OTFsfX);

            plot(OTFsfX, modelOTF, 'ko-', 'MarkerSize', 6, 'MarkerFaceColor', [0.5 0.5 0.5]);
            hold off;
            
            if (pupilSizeIndex == numel(examinedPupilDiametersInMillimeters)) || ...
               (pupilSizeIndex == numel(examinedPupilDiametersInMillimeters)/2)
               xlabel('cycles/deg');
            else
               xlabel(''); 
            end
            text(0.12, 0.005, sprintf('Pupil:%2.1f mm', examinedPupilDiametersInMillimeters(pupilSizeIndex)), 'FontSize', 12, 'FontWeight', 'bold');
            set(gca, 'XLim', [0.1 60], 'YLim', [0.001 1]);
            set(gca, 'XScale', 'log', 'YScale', 'log', 'XTick', [0.1 1 2 5 10 20 50 100], 'YTick', [0.001 0.002 0.005 0.01 0.02 0.05 0.10 0.20 0.50 1.0]);
            set(gca, 'XTickLabel', [0.1 1 2 5 10 20 50 100], 'YTickLabel',  [0.001 0.002 0.005 0.01 0.02 0.05 0.10 0.20 0.50 1.0]);
            box on;
            grid on;
            colormap(gray(256));

            %% Plot the RGB rendered optical image
            subplot('Position', [0.09+2*plotWidth 1+margin/2-subplotRow*(plotHeight+margin) plotWidth plotHeight]);
            halfRange = size(compositeRGBimage,1)/2-10;
            rowRange = size(compositeRGBimage,1)/2 + [-halfRange:halfRange];
            colRange = size(compositeRGBimage,2)/2 + [-halfRange:halfRange];
            imshow(compositeRGBimage(rowRange, colRange, :));
            axis 'image'

            drawnow; 
        end 
    end
    
    if (nargin >= 1) && (isfield(runParams, 'generatePlots')) && (runParams.generatePlots == true)
        clear 'modelOTF'
        h = figure(3);
        set(h, 'Position', [100 100 940 300]);
        clf;
        sf = 0:0.01:120;
        examinedPupilDiametersInMillimeters = 2:0.5:6;
        for index = 1:numel(examinedPupilDiametersInMillimeters)
            index
            modelOTF(index,:) = WatsonOTFmodel(examinedPupilDiametersInMillimeters(index), examinedWaveLength, sf);
        end

        colors = jet(size(modelOTF,1));
        colors = colors(end:-1:1,:);
        
        subplot('Position', [0.03 0.1 0.48 0.90]); 
        hold on
        for index = 1:size(modelOTF,1)
            plot(sf, modelOTF(index,:), 'k-', 'Color', squeeze(colors(index,:)), 'LineWidth', 2);
        end
        hold off;
        legend({'PD = 2.0mm', 'PD = 2.5mm', 'PD = 3.0mm', 'PD = 3.5mm', 'PD = 4.0mm', 'PD = 4.5mm', 'PD = 5.0mm', 'PD = 5.5mm', 'PD = 6.0mm'});
        set(gca, 'XLim', [0 120], 'YLim', [0 1]);
        set(gca, 'XScale', 'linear', 'YScale', 'linear', 'XTick', [0:10:100], 'YTick', [0:0.1:1.0]);
        set(gca, 'XTickLabel', [0:10:100], 'YTickLabel',  [0:0.1:1.0]);
        set(gca, 'FontName', 'Helvetica', 'FontSize', 10);
        xlabel('spatial frequency (c/deg)', 'FontName', 'Helvetica', 'FontSize', 12, 'FontWeight', 'bold');
        ylabel('Gain', 'FontName', 'Helvetica', 'FontSize', 12, 'FontWeight', 'bold');
        axis 'square'
        box on;
        grid on;
        
        subplot('Position', [0.51 0.1 0.48 0.90]); 
        hold on
        for index = 1:size(modelOTF,1)
            plot(sf, modelOTF(index,:), 'k-', 'Color', squeeze(colors(index,:)),  'LineWidth', 2);
        end
        hold off;
        legend({'PD = 2.0mm', 'PD = 2.5mm', 'PD = 3.0mm', 'PD = 3.5mm', 'PD = 4.0mm', 'PD = 4.5mm', 'PD = 5.0mm', 'PD = 5.5mm', 'PD = 6.0mm'}, 'Location', 'SouthWest');
        set(gca, 'XLim', [0.1 120], 'YLim', [0.001 1]);
        set(gca, 'XScale', 'log', 'YScale', 'log', 'XTick', [0.1 1 2 5 10 20 50 100], 'YTick', [0.001 0.002 0.005 0.01 0.02 0.05 0.10 0.20 0.50 1.0]);
        set(gca, 'XTickLabel', [0.1 1 2 5 10 20 50 100], 'YTickLabel',  [0.001 0.002 0.005 0.01 0.02 0.05 0.10 0.20 0.50 1.0]);
        set(gca, 'FontName', 'Helvetica', 'FontSize', 10);
        xlabel('spatial frequency (c/deg)', 'FontName', 'Helvetica', 'FontSize', 12, 'FontWeight', 'bold');
        ylabel('Gain', 'FontName', 'Helvetica', 'FontSize', 12, 'FontWeight', 'bold');
        axis 'square'
        box on;
        grid on;
        drawnow;
    end
    
end

% Method to compute Watson's OTF model as a function of pupil diameter (d, in mm)
% wavelength (lambda), for a range of spatial frequencies (u, in cycles/deg)
function modelOTF = WatsonOTFmodel(d, lambda, u)
    u1       = 21.95 - 5.512*d + 0.3922 * d^2;                                  % [Equation (4)]
    D        = DiffractionLimitedMTF(u,d, lambda);   
    modelOTF = ((1 + (u/u1).^2).^(-0.62)) .* sqrt(D);                           % [Equation (5)]
   
    function D = DiffractionLimitedMTF(u,d,lambda)  
        u0    = IncoherentCutoffFrequency(d,lambda);
        u_hat = u / u0;                                                         % [Equation (2)]
        
        D           = u * 0;
        indices     = find(u_hat < 1.0);
        u_hat       = u_hat(indices);
        D(indices)  = (2/pi)*(acos(u_hat) - u_hat.*sqrt(1-u_hat.^2));    % [Equation (1)]
   
        function u0 = IncoherentCutoffFrequency(d,lambda)
            % units of u0 is cycles/deg
            u0 = (d * pi * 10^6)/(lambda*180);                                  % [Equation (3)]
        end
    end
end


function compositeRGBimage = generateCompositeImage(sceneRGBImage, opticalRGBImage)
    compositeRGBimage = opticalRGBImage;
    dstRows = size(opticalRGBImage,1);
    dstCols = size(opticalRGBImage,2);
    srcRows = size(sceneRGBImage, 1);
    srcCols = size(sceneRGBImage, 2);
    rowMargin = (dstRows-srcRows)/2;
    colMargin = (dstCols-srcCols)/2;
    compositeRGBimage(1:dstRows/2,:,:) = 0;
    compositeRGBimage(rowMargin+(1:srcRows/2), colMargin+(1:srcCols/2),:) = sceneRGBImage(1:srcRows/2,1:srcCols/2,:);
end