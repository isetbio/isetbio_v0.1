function validateMacbethColorCheckerScene(runParams)
%
% Validate a scene depicting a Macbeth Color Checker illuminanted with D65
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
    
    % Create Macbeth scene with D65 illuminant
    testScene = sceneCreate('macbethd65');
    
    % Query scene
    
    % Get RGB image
    rgbImage = sceneGet(testScene,'rgb image');
     
    % Get mean luminance
    meanLuminance = sceneGet(testScene,'meanLuminance');
    
    % Get luminance map
    luminanceMap = sceneGet(testScene,'luminance');
    
    % Get scene radiance in emitted photons per sec per wavelength per steradian per meter from the scene
    % This is a 3D image (rowsxcolsxwavelength sampling)
    photonRadianceMap = sceneGet(testScene,'photons');
    
    % Get the wavelength sample values in nanometers
    wavelengthSampling = sceneGet(testScene,'wave');
    
    validationFailedFlag = false;
    validationReport = sprintf('Scene get/set operations perform as expected');
    validationDataToSave.scene = testScene;
    
    if (nargin >= 1) && (isfield(runParams, 'generatePlots')) && (runParams.generatePlots == true)
        h = figure(500);
        clf;
    
        subplot(2,4,1);
        image(1:size(rgbImage,2), 1:size(rgbImage,2), rgbImage);
        axis 'image'
        xlabel('x');
        ylabel('y');
        title('RGB image');
        set(gca, 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold');

        subplot(2,4,5);
        imagesc(1:size(luminanceMap,2), 1:size(luminanceMap,2), luminanceMap);
        axis 'image'
        pos = get(gca,'position');
        colorbar('location','manual','position',[pos(1)+pos(3)+.01 pos(2) .03 pos(4)]);
        xlabel('x');
        ylabel('y');
        title('Luminance map');
        set(gca, 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold');

    
        subplot(2,4,[3 4 7 8]);
        wavelengthSubSamplingInterval = 3;
        plotRadianceMap(photonRadianceMap, wavelengthSampling, wavelengthSubSamplingInterval);
        drawnow;
    end
    
    % Do not forget to update the following params:
    % - validationReport (string),
    % - validationFailedFlag (boolean) true if the results are not what we expect 
    % - validationDataToSave (struct with fields containing validation data that you want to save for comparison to ground truth data)
    
    % Generate plots, if so specified
    if (nargin >= 1) && (isfield(runParams, 'generatePlots')) && (runParams.generatePlots == true)
        % Your plotting code goes here.
    end
    
end


function plotRadianceMap(radianceMap, wavelengthSampling, wavelengthSubSamplingInterval)
    [X,Y,Z] = meshgrid(1:size(radianceMap,2), wavelengthSampling, 1:size(radianceMap,1));
    radianceMap = permute(radianceMap, [3 2 1]);
    minRadiance = min(radianceMap(:))
    maxRadiance = max(radianceMap(:))
    radianceMap = radianceMap/maxRadiance;
    h = slice(X,Y,Z, radianceMap, Inf, wavelengthSampling(1):wavelengthSubSamplingInterval:wavelengthSampling(end), Inf);
    
    for n = 1:numel(h)
        a = get(h(n), 'cdata');
        set(h(n), 'alphadata', 0.1*ones(size(a)), 'facealpha', 'flat');
    end
    
    shading flat
    xlabel('x');
    ylabel('wavelength');
    zlabel('y');
    axis 'image'
    set(gca, 'ZDir', 'reverse', 'Color', [1 1 0.6]);
    set(gca, 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold');
    title('Radiance (photons) map');
    colormap(hot(256));
    colorbar('horiz', 'Ticks', [min(radianceMap(:)) max(radianceMap(:))], 'TickLabels', [0 1.0]*(maxRadiance-minRadiance) + minRadiance);
    
    box off;
    grid off;
end