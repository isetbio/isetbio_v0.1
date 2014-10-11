function validateSceneManipulations(runParams)
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
    
    
    % Generate Macbeth scene with D65 illuminant
    fluorescentScene    = sceneCreate('macbethfluorescent');
    illuminantPhotons   = sceneGet(fluorescentScene, 'illuminantPhotons');
    peakRadiance        = sceneGet(fluorescentScene, 'peakRadiance');
    photonRadianceMap   = sceneGet(fluorescentScene,'photons');
    wavelengthSampling  = sceneGet(fluorescentScene, 'wave');
    
    rgbImage1 = sceneGet(fluorescentScene,'rgb image');
    
    figure(11); clf;
    subplot(3,3,1); hold on;
    plot(wavelengthSampling, illuminantPhotons, 'r-');
    plot(wavelengthSampling, peakRadiance, 'k-');
    legend('illuminant photons', 'peak radiance');
    set(gca, 'FontSize', 12);
    title('fluorescent macbeth');
    
    wavelengthSubSamplingInterval = 2;
    subplot(3,3, [2 3]);
    plotRadianceMap(photonRadianceMap, wavelengthSampling, wavelengthSubSamplingInterval, 'Radiance')
    set(gca, 'FontSize', 12);
    
    % Generate Macbeth scene with D65 illuminant
    d65Scene            = sceneCreate('macbethd65');
    illuminantPhotons2  = sceneGet(d65Scene, 'illuminantPhotons');
    peakRadiance2       = sceneGet(d65Scene, 'peakRadiance');
    photonRadianceMap2  = sceneGet(d65Scene,'photons');
    wavelengthSampling2 = sceneGet(d65Scene, 'wave');
    rgbImage2 = sceneGet(d65Scene,'rgb image');
    
    subplot(3,3,4); hold on;
    plot(wavelengthSampling2, illuminantPhotons2, 'r-');
    plot(wavelengthSampling2, peakRadiance2, 'k-');
    legend('illuminant photons', 'peak radiance');
    set(gca, 'FontSize', 12);
    title('D65 macbeth');
    
    subplot(3,3, [5 6]);
    plotRadianceMap(photonRadianceMap2, wavelengthSampling2, wavelengthSubSamplingInterval, 'Radiance')
    set(gca, 'FontSize', 12);
    
    % Change illuminant in macbeth d65 scene
    fluorescentIllum    = sceneGet(fluorescentScene, 'illuminant');
    d65Scene            = sceneSet(d65Scene, 'illuminant', fluorescentIllum);
    illuminantPhotons3  = sceneGet(d65Scene, 'illuminantPhotons');
    peakRadiance3       = sceneGet(d65Scene, 'peakRadiance');
    photonRadianceMap3 = sceneGet(d65Scene,'photons');
    wavelengthSampling3 = sceneGet(d65Scene, 'wave');
    
    subplot(3,3,7); hold on;
    plot(wavelengthSampling3, illuminantPhotons3, 'r-');
    plot(wavelengthSampling3, peakRadiance3, 'k-');
    legend('illuminant photons', 'peak radiance');
    title(sprintf('D65 macbeth re-illuminated \nwith fluorescent illuminant'));
    set(gca, 'FontSize', 12);
    
    subplot(3,3, [8 9]);
    plotRadianceMap(photonRadianceMap3, wavelengthSampling3, wavelengthSubSamplingInterval, 'Radiance')
    set(gca, 'FontSize', 12);
    
    rgbImage3 = sceneGet(d65Scene,'rgb image');
    
    drawnow

     
    figure(10); clf;
    subplot(1,3,1);
    imshow(rgbImage1);
    
    subplot(1,3,2);
    imshow(rgbImage2);
    
    subplot(1,3,3);
    imshow(rgbImage3);
    
    pause;
    
    
    %% Get radiance data
    % the spectal sampling
    wavelengthSampling = sceneGet(testScene, 'wave');
    
    newIlluminant = illuminantCreate('fluorescent', wavelengthSampling);
    testScene = sceneSet(testScene, 'illuminant', newIlluminant);
    
    %% Get optical and resolution parameters of the scene 
    % Scene distance to the lens
    distance = sceneGet(testScene, 'objectdistance');
    
    % Scene angular size in degrees of visual angle
    horizontalFieldOfView = sceneGet(testScene, 'wangular');
    verticalFieldOfView = sceneGet(testScene, 'hangular');
    
    % Scene size in meters (height, width)
    sizeInMeters = sceneGet(testScene, 'heightandwidth');
    
    % Scene sampling (rows, cols)
    sizeInSamples = sceneGet(testScene,'size');
    
    
    
    
    %% Get radiance data
    % the spectal sampling
    wavelengthSampling = sceneGet(testScene, 'wave');
    
    
    
    
    % the illuminant SPD
    illuminantPhotons = sceneGet(testScene, 'illuminantPhotons');
    
    % peak radiance at each wavelength (units: emitted photons per sec per wavelength per steradian per meter from the scene)
    peakRadiance = sceneGet(testScene, 'peakRadiance');
    

    % Get RGB map
    rgbImage = sceneGet(testScene,'rgb image');
    
    % radiance map: distribution of emitted photons across space units: photons per sec per wavelength per steradian per meter from the scene
    photonRadianceMap = sceneGet(testScene,'photons');
    
    % Compute reflectance map
    reflectanceMap = photonRadianceMap./permute(repmat(illuminantPhotons, [1 size(rgbImage,2) size(rgbImage,1)]), [3 2 1]);
    
    
    
    figure(3);
    clf;
    subplot(4,4,1);
    bar(wavelengthSampling, peakRadiance, 'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9], 'LineWidth',1.0);
    hold on;
    plot(wavelengthSampling, illuminantPhotons, '-', 'Color', [1 0.5 0.1], 'LineWidth', 2);
    set(gca, 'XLim', [wavelengthSampling(1)-5 wavelengthSampling(end)+5]);
    legend({'radiance photons', 'illuminant photons'});
    
    subplot(4,4,5);
    hold on;
    for row = 1:sizeInSamples(1)
        for col = 1:sizeInSamples(2)
            plot(wavelengthSampling, squeeze(reflectanceMap(row,col,:)), 'k-');
        end
    end
    plot(wavelengthSampling, peakRadiance./illuminantPhotons, 'r-');
    plot(wavelengthSampling, squeeze(max(max(reflectanceMap,[],1),[],2)), 'b--');
    
    
    subplot(4,4,9);
    image(1:size(rgbImage,2), 1:size(rgbImage,2), rgbImage);
        axis 'image'
        xlabel('x');
        ylabel('y');
        title('RGB image');
        set(gca, 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold');
        
    
    subplot(4,4, [2 3 4 6 7 8]);
    wavelengthSubSamplingInterval = 2;
    reflectanceMap = photonRadianceMap./permute(repmat(illuminantPhotons, [1 size(rgbImage,2) size(rgbImage,1)]), [3 2 1]);
    plotRadianceMap(reflectanceMap, wavelengthSampling, wavelengthSubSamplingInterval, 'Reflectance')
    

    subplot(4,4,[10 11 12 14 15 16]);
    plotRadianceMap(photonRadianceMap, wavelengthSampling, wavelengthSubSamplingInterval, 'Radiance');
        
    % Get mean luminance
    meanLuminance = sceneGet(testScene,'meanLuminance');
    
    % Get luminance map
    luminanceMap = sceneGet(testScene,'luminance');
    
    % Get scene radiance in emitted photons per sec per wavelength per steradian per meter from the scene
    % This is a 3D image (rowsxcolsxwavelength sampling)
    photonRadianceMap = sceneGet(testScene,'photons');
    
    
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


function plotRadianceMap(radianceMap, wavelengthSampling, wavelengthSubSamplingInterval, titleText)
    [X,Y,Z] = meshgrid(1:size(radianceMap,2), wavelengthSampling, 1:size(radianceMap,1));
    radianceMap = permute(radianceMap, [3 2 1]);
    minRadiance = min(radianceMap(:));
    maxRadiance = max(radianceMap(:));
    radianceMap = radianceMap/maxRadiance;
    h = slice(X,Y,Z, radianceMap, Inf, wavelengthSampling(1):wavelengthSubSamplingInterval:wavelengthSampling(end), Inf, 'nearest');
    
    for n = 1:numel(h)
        a = get(h(n), 'cdata');
        set(h(n), 'alphadata', 0.1*ones(size(a)), 'facealpha', 'flat');
    end
    
    shading flat
    
    axis 'image'
    set(gca, 'ZDir', 'reverse', 'Color', [1 1 0.6]);
    set(gca, 'FontName', 'Helvetica', 'FontSize', 14, 'FontWeight', 'bold');
    xlabel('x'); ylabel('wavelength'); zlabel('y');
    title(titleText);
    colormap(hot(256));
    colorbar('vert', 'Ticks', [min(radianceMap(:)) max(radianceMap(:))], 'TickLabels', [0 1.0]*(maxRadiance-minRadiance) + minRadiance);
    
    box off;
    grid off;
end