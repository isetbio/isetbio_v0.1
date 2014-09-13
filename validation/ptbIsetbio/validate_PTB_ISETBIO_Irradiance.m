function validate_PTB_ISETBIO_Irradiance()

    % Initialize a @UnitTest object to handle the results
    unitTestOBJ = UnitTest(mfilename('fullpath'));

    unitTestOBJ.addProbe('name', 'PTB vs. ISETBIO irradiance compute', ...
                         'functionHandle', @PTB_ISETBIO_Irradiance, ...
                         'functionParams', struct(...
                                                'fov', 20, ...
                                                'roiSize', 5, ...
                                                'generatePlots', false...
                                           ) ...
                         );
    
end


function validationData = PTB_ISETBIO_Irradiance(params)

    disp('here')
    fov     = params.fov;
    roiSize = params.roiSize;
    generatePlots = params.generatePlots;
    
    % Initialize ISETBIO
    s_initISET

    % Create a radiance image in isetbio
    scene = sceneCreate('uniform ee');    % Equal energy
    scene = sceneSet(scene,'name','Equal energy uniform field');
    scene = sceneSet(scene,'fov', fov);     % Big field required

    % Plot of the spectral radiance function averaged within an roi
    sz = sceneGet(scene,'size');
    
    % Define a rectangular ROI starting at the scene's center with size
    % roiSize x roiSize
    rect = [sz(2)/2,sz(1)/2,roiSize,roiSize];
    % Get the (x,y) coords of pixels within the rect
    roiLocs = ieRoi2Locs(rect);
    
    radianceDataA = sceneGet(scene,'radiance energy roi', roiLocs);
    radianceDataB = sceneGet(scene,'roi photons spd', roiLocs);
    
    radianceData2.energy = vcGetROIData(scene,roiLocs,'energy');
    radianceData2.wave   = sceneGet(scene,'wave');
    radianceData2.energy = mean(radianceData2.energy,1);
    radianceData2.roiLocs = roiLocs;
        
        
    radianceData3 = plotScene(scene,'radiance energy roi',roiLocs);
    title(sprintf(sceneGet(scene,'name')));

    %for k = 1:numel(radianceData2.energy)
    %    fprintf('%g %g; diff: %g\n', radianceData2.energy(k), radianceData3.energy(k), radianceData2.energy(k)-radianceData3.energy(k))
    %end
    
    
    validationData.scene = scene;
end


