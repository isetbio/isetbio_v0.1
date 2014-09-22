function PTB_vs_ISETBIO_Colorimetry(runParams)
%
%  Validate ISETBIO-based colorimetric computations by comparing to PTB-based colorimetric computations.
%

    % Call the validation script
    [validationReport, validationFailedFlag, validationDataToSave] = validationScript(runParams);

    % Update the parent @UnitTest object
    UnitTest.updateParentUnitTestObject(validationReport, validationFailedFlag, validationDataToSave, runParams);
end

%% Skeleton validation script
function [validationReport, validationFailedFlag, validationDataToSave] = validationScript(runParams)

    %% Initialize return params
    validationReport = ''; 
    validationFailedFlag = false; 
    validationDataToSave = struct();
    
    %% SETUP
    isetbioPath = fileparts(which('colorTransformMatrix'));
    curDir = pwd; 
    tolerance = 1e-10;
    
    %% XYZ-related colorimetry
    %
    message = sprintf('\n\t\t***** Basic XYZ *****');
    validationReport = sprintf('%s %s', validationReport, message);
    
    testXYZs = [[1 2 1]' [2 1 0.5]' [1 1 1]' [0.6 2.3 4]'];
    ptbxyYs = XYZToxyY(testXYZs);
    ptbxys  = ptbxyYs(1:2,:);
    isetxys = chromaticity(testXYZs')';
    
    if (any(abs(ptbxys-isetxys) > tolerance))
        message = sprintf('\n\t\tPTB-ISET DIFFERENCE for XYZ to xy (tolerance: %g)', tolerance);
        validationFailedFlag = true;
    else
        message = sprintf('\n\t\tPTB-ISET AGREE for XYZ to xy (tolerance: %g)', tolerance);
    end
    
    % update validation report and validationDataToSave struct
    validationReport = sprintf('%s %s', validationReport, message);
    validationDataToSave.testXYZs = testXYZs;
    validationDataToSave.ptbxys = ptbxys;
    validationDataToSave.isetxys = isetxys;
    
    %% xyY
    ptbXYZs = xyYToXYZ(ptbxyYs);
    if (any(abs(testXYZs-ptbXYZs) > tolerance))
        message = sprintf('\n\t\tPTB FAILS XYZ to xyY to XYZ (tolerance: %g)', tolerance);
        validationFailedFlag = true;
    else
        message = sprintf('\n\t\tPTB PASSES XYZ to xyY to XYZ (tolerance: %g)', tolerance);
    end
    
    % update validation report and validationDataToSave struct
    validationReport = sprintf('%s %s', validationReport, message);
    validationDataToSave.ptbXYZs = ptbXYZs;
    
    isetXYZs = xyy2xyz(ptbxyYs')';
    if (any(abs(testXYZs-isetXYZs) > tolerance))
        message = sprintf('\n\t\tPTB-ISET DIFFERENCE for xyY to XYZ (tolerance: %g)', tolerance);
        validationFailedFlag = true;
    else
        message = sprintf('\n\t\tPTB-ISET AGREE for xyY to XYZ (tolerance: %g)', tolerance);
    end 
    
    % update validation report and validationDataToSave struct
    validationReport = sprintf('%s %s', validationReport, message);
    validationDataToSave.isetXYZs = isetXYZs;

    
    %% CIE uv chromaticity
    ptbuvYs = XYZTouvY(testXYZs);
    ptbuvs = ptbuvYs(1:2,:);
    [isetus,isetvs] = xyz2uv(testXYZs');
    isetuvs = [isetus' ; isetvs'];
    if (any(abs(ptbuvs-isetuvs) > tolerance))
        message = sprintf('\n\t\tPTB-ISET DIFFERENCE for XYZ to uv (tolerance: %g)', tolerance);
        message = sprintf('%s\n\t\t\tI think this is because ISET implements an obsolete version of the standard', message);
        validationFailedFlag = true;
    else
        message = sprintf('\n\t\tPTB-ISET AGREE for XYZ to uv (tolerance: %g)', tolerance);
    end
    
    % update validation report and validationDataToSave struct
    validationReport = sprintf('%s %s', validationReport, message);
    validationDataToSave.ptbuvs = ptbuvs;
    validationDataToSave.isetuvs = isetuvs;
    
    %% CIELUV
    whiteXYZ = [3,4,3]';
    ptbLuvs = XYZToLuv(testXYZs,whiteXYZ);
    isetLuvs = xyz2luv(testXYZs',whiteXYZ')';
    if (any(abs(ptbLuvs-isetLuvs) > tolerance))
        message = sprintf('\n\t\tPTB-ISET DIFFERENCE for XYZ to Luv (tolerance: %g)', tolerance);
        message = sprintf('%s\n\t\t\tPresumably because the uv transformation differs.', message);
        validationFailedFlag = true;
    else
        message = sprintf('\n\t\tPTB-ISET AGREE for XYZ to Luv (tolerance: %g)', tolerance);
    end
    
    % update validation report and validationDataToSave struct
    validationReport = sprintf('%s %s', validationReport, message);
    validationDataToSave.whiteXYZ = whiteXYZ;
    validationDataToSave.ptbLuvs = ptbLuvs;
    validationDataToSave.isetLuvs = isetLuvs;
    
    %% CIELAB
    whiteXYZ = [3,4,3]';
    ptbLabs = XYZToLab(testXYZs,whiteXYZ);
    cd(isetbioPath);
    isetLabs = xyz2lab(testXYZs',whiteXYZ')';
    cd(curDir);
    if (any(abs(ptbLabs-isetLabs) > tolerance))
        message = sprintf('\n\t\tPTB-ISET DIFFERENCE for XYZ to Lab (tolerance: %g)', tolerance);
        validationFailedFlag = true;
    else
        message = sprintf('\n\t\tPTB-ISET AGREE for XYZ to Lab (tolerance: %g)', tolerance);
    end
    % update validation report and validationDataToSave struct
    validationReport = sprintf('%s %s', validationReport, message);
    validationDataToSave.ptbLabs  = ptbLabs;
    validationDataToSave.isetLabs = isetLabs;
    
    ptbXYZCheck = LabToXYZ(ptbLabs,whiteXYZ);
    isetXYZCheck = lab2xyz(isetLabs',whiteXYZ')';
    if (any(abs(testXYZs-ptbXYZCheck) > tolerance ))
        message = sprintf('\n\t\tPTB FAILS XYZ to Lab to XYZ (tolerance: %g)', tolerance);
        validationFailedFlag = true;
    else
        message = sprintf('\n\t\tPTB PASSES XYZ to Lab to XYZ (tolerance: %g)', tolerance);
    end
    % update validation report and validationDataToSave struct
    validationReport = sprintf('%s %s', validationReport, message);
    validationDataToSave.ptbXYZCheck  = ptbXYZCheck;
    
    if (any(abs(testXYZs-isetXYZCheck) > tolerance))
        message = sprintf('\n\t\tISET FAILS XYZ to Lab to XYZ (tolerance: %g)', tolerance);
        validationFailedFlag = true;
    else
        message = sprintf('\n\t\tISET PASSES XYZ to Lab to XYZ (tolerance: %g)', tolerance);
    end
    % update validation report and validationDataToSave struct
    validationReport = sprintf('%s %s', validationReport, message);
    validationDataToSave.isetXYZCheck  = isetXYZCheck;

    
    %% sRGB
    %
    % The iset routines seem to use a matrix that is 1/100 of the standard
    % definition.  Or, at least, 1/100 of what the PTB routines use.  To
    % account for this, I multiply XYZ values by 100 before passing them
    % to the iset routines.
    %
    % The iset routines take an exponent argument for the sRGB gamma transform.
    % At http://www.w3.org/Graphics/Color/sRGB this is specified as 2.4.  The
    % iset routine xyz2srgb uses 2.2, with a comment that an update at
    % www.srgb.com changed this from 2.4 to 2.2.  I think this is wrong,
    % though.  The text I can find on the web says that the 2.4 exponent, plus
    % the linear initial region, is designed to approximate a gamma of 2.2.
    % That is, you want 2.4 in the formulae to approximate the 2.2 industry
    % standard gamma.  Site www.srgb.com now appears gone, by the way, but all
    % the other sites I find seem to be the same in this regard.
    % 
    % Also note that if you change the exponent in the iset sRGB formulae, you
    % also should probably change the cutoff used at the low-end, where the
    % sRGB standard special cases the functional form of the gamma curve.  Here
    % the test is set for 2.4.
    %
    % Finally,the default gamma used by iset lrgb2srgb and by xzy2srgb
    % currently differ, so you really want to be careful using these.  The
    % inverse routine srgb2lrgb doesn't allow passing of the exponent, and it
    % is hard coded as 2.4.  This causes a failure of the iset sRGB gamma
    % routines to self-invert for gamma other than 2.4, and with their
    % defaults.
    %
    % One other convention difference is that the PTB routine rounds to
    % integers for the settings, while the iset routine leaves the rounding up
    % to the caller.
    message = sprintf('\n\n\t\t***** sRGB*****');
    validationReport = sprintf('%s %s', validationReport, message);

    % Create some test sRGB values and convert them in the PTB framework
    ptbSRGBs = [[188 188 188]' [124 218 89]' [255 149 203]' [255 3 203]'];
    ptbSRGBPrimary = SRGBGammaUncorrect(ptbSRGBs);
    ptbXYZs = SRGBPrimaryToXYZ(ptbSRGBPrimary);

    % The ISET form takes the frame buffer values in the [0,1] regime
    isetSRGBs = ptbSRGBs/255;
    isetSRGBs = XW2RGBFormat(isetSRGBs',4,1);
    isetXYZ   = srgb2xyz(isetSRGBs);
    isetXYZs  = RGB2XWFormat(isetXYZ)';

    if (any(abs(isetXYZs-ptbXYZs) > tolerance))
        d = isetXYZs - ptbXYZs;
        message = sprintf('\n\t\tPTB-ISET DIFFERENCE for XYZ to sRGB: %f (tolerance: %g)',max(abs(d(:))), tolerance);
        d = d ./ptbXYZs;
        message = sprintf('%s\n\t\tPTB-ISET Percent XYZ DIFFERENCE: %f\n', message, max(abs(d(:))));
        validationFailedFlag = true;
    else
        message = sprintf('\n\t\tPTB-ISET AGREE for XYZ to sRGB (tolerance: %g)', tolerance);
    end

    % update validation report and validationDataToSave struct
    validationReport = sprintf('%s %s', validationReport, message);
    validationDataToSave.isetXYZs = isetXYZs;
    validationDataToSave.ptbXYZs = ptbXYZs;
    
    % PTB testing of inversion
    if (any(abs(XYZToSRGBPrimary(ptbXYZs)-ptbSRGBPrimary) > tolerance))
        message = sprintf('\n\t\tPTB FAILS linear sRGB to XYZ to linear sRGB (tolerance: %g)', tolerance);
        validationFailedFlag = true;
    else
        message = sprintf('\n\t\tPTB PASSES linear sRGB to XYZ to linear sRGB (tolerance: %g)', tolerance);
    end
    % update validation report and validationDataToSave struct
    validationReport = sprintf('%s %s', validationReport, message);
    validationDataToSave.ptbSRGBPrimary = ptbSRGBPrimary;
    
    
    if (any(abs(SRGBGammaCorrect(ptbSRGBPrimary)-ptbSRGBs) > tolerance))
        message = sprintf('\n\t\tPTB FAILS sRGB to linear sRGB to sRGB (tolerance: %g)', tolerance);
        validationFailedFlag = true;
    else
        message = sprintf('\n\t\tPTB PASSES sRGB to linear sRGB to sRGB (tolerance: %g)', tolerance);
    end
    % update validation report and validationDataToSave struct
    validationReport = sprintf('%s %s', validationReport, message);
    validationDataToSave.ptbSRGBs = ptbSRGBs;
    
    
    % Compare sRGB matrices
    [nil,ptbSRGBMatrix] = XYZToSRGBPrimary([]);
    isetSRGBMatrix = colorTransformMatrix('xyz2srgb')';

    if (any(abs(ptbSRGBMatrix-isetSRGBMatrix) > tolerance))
        message = sprintf('\n\t\tPTB-ISET DIFFERENCE for sRGB transform matrix (tolerance: %g)', tolerance);
        validationFailedFlag = true;
    else
        message = sprintf('\n\t\tPTB-ISET AGREE for sRGB transform matrix (tolerance: %g)', tolerance);
    end
    % update validation report and validationDataToSave struct
    validationReport = sprintf('%s %s', validationReport, message);
    validationDataToSave.ptbSRGBMatrix = ptbSRGBMatrix;
    validationDataToSave.isetSRGBMatrix = isetSRGBMatrix;
    
    % XYZ -> lRGB 
    % Reformat shape
    ptbXYZsImage = CalFormatToImage(ptbXYZs,1,size(ptbXYZs,2));

    % ISET convert 
    [isetSRGBImage,isetSRGBPrimaryImage] = xyz2srgb(ptbXYZsImage);

    % Reformat shape
    isetSRGBs = ImageToCalFormat(isetSRGBImage); 
    isetSRGBPrimary = ImageToCalFormat(isetSRGBPrimaryImage);

    if (any(abs(ptbSRGBPrimary-isetSRGBPrimary) > tolerance))
        d = ptbSRGBPrimary - isetSRGBPrimary;
        message = sprintf('\n\t\tPTB-ISET DIFFERENCE for XYZ to sRGB: %f (tolerance: %g)',max(abs(d(:))), tolerance);
        d = d ./isetSRGBPrimary;
        message = sprintf('%s\n\t\tPTB-ISET Percent RGB DIFFERENCE: %f', message, max(abs(d(:))));
        validationFailedFlag = true;
    else
        message = sprintf('\n\t\tPTB-ISET AGREE for XYZ to linear sRGB (tolerance: %g)', tolerance);
    end
    % update validation report and validationDataToSave struct
    validationReport = sprintf('%s %s', validationReport, message);
    validationDataToSave.ptbSRGBPrimary = ptbSRGBPrimary;
    validationDataToSave.isetSRGBPrimary = isetSRGBPrimary;
    
    
    % ISET/PTB sRGB comparison in integer gamma corrected space
    if (any(abs(round(isetSRGBs*255)-ptbSRGBs) > tolerance))
        message = sprintf('\n\t\tPTB-ISET DIFFERENCE for XYZ to sRGB (tolerance: %g)', tolerance);
        validationFailedFlag = true;
    else
        message = sprintf('\n\t\tPTB-ISET AGREE for XYZ to sRGB (tolerance: %g)', tolerance);
    end
    % update validation report and validationDataToSave struct
    validationReport = sprintf('%s %s', validationReport, message);
    validationDataToSave.isetSRGBs = isetSRGBs*255;
    validationDataToSave.ptbSRGBs = ptbSRGBs;
    
    
    % lrgb -> srgb -> lrgb in ISET
    isetSRGBPrimaryCheckImage = srgb2lrgb(isetSRGBImage);
    isetSRGBPrimaryCheck = ImageToCalFormat(isetSRGBPrimaryCheckImage);
    if (any(abs(isetSRGBPrimaryCheck-isetSRGBPrimary) > 1e-10))
        message = sprintf('\n\t\tISET FAILS linear sRGB to sRGB to linear sRGB (tolerance: %g)', tolerance);
        validationFailedFlag = true;
    else
        message = sprintf('\n\t\tISET PASSES linear sRGB to sRGB to linear sRGB (tolerance: %g)', tolerance);
    end
    % update validation report and validationDataToSave struct
    validationReport = sprintf('%s %s', validationReport, message);
    validationDataToSave.isetSRGBPrimaryCheck = isetSRGBPrimaryCheck;
    validationDataToSave.isetSRGBPrimary = isetSRGBPrimary;
    

    %% Quanta/Energy
    %
    % The ISET routines define c and h to more places than the PTB, so the
    % agreement is only good to about 5 significant places.  Seems OK to me.
    message = sprintf('\n\n\t\t***** Energy/Quanta *****');
    validationReport = sprintf('%s %s', validationReport, message);
 
    load spd_D65
    spdEnergyTest = spd_D65;
    wlsTest = SToWls(S_D65);
    testPlaces = 5;
    ptbQuanta = EnergyToQuanta(wlsTest,spdEnergyTest);
    isetQuanta = Energy2Quanta(wlsTest,spdEnergyTest);
    toleranceQuanta = (10^-testPlaces)*min(ptbQuanta);
    if (any(abs(ptbQuanta-isetQuanta) > toleranceQuanta))
        message = sprintf('\n\t\tPTB-ISET DIFFERENCE for energy to quanta conversion at %d significant places (tolerance: %g)',testPlaces, toleranceQuanta);
        validationFailedFlag = true;
    else
        message = sprintf('\n\t\tPTB-ISET AGREE for energy to quanta conversion to %d significant places (tolerance: %g)',testPlaces,  toleranceQuanta);
    end
    
    % update validation report and validationDataToSave struct
    validationReport = sprintf('%s %s', validationReport, message);
    validationDataToSave.ptbQuanta = ptbQuanta;
    validationDataToSave.isetQuanta = isetQuanta;
    
    
    if (any(abs(QuantaToEnergy(wlsTest,ptbQuanta)-spdEnergyTest) > tolerance))
        message = sprintf('\n\t\tPTB FAILS energy to quanta to energy (tolerance: %g)', tolerance);
        validationFailedFlag = true;
    else
        message = sprintf('\n\t\tPTB PASSES energy to quanta to energy (tolerance: %g)', tolerance);
    end
    % update validation report and validationDataToSave struct
    validationReport = sprintf('%s %s', validationReport, message);
    validationDataToSave.ptbEnergyFromQuanta = QuantaToEnergy(wlsTest,ptbQuanta);
    validationDataToSave.spdEnergyTest = spdEnergyTest;
    
    if (any(abs(Quanta2Energy(wlsTest,isetQuanta')'- spdEnergyTest) > tolerance))
        message = sprintf('\n\t\tISET FAILS energy to quanta to energy (tolerance: %g)', tolerance);
        validationFailedFlag = true;
    else
        message = sprintf('\n\t\tISET PASSES energy to quanta to energy (tolerance: %g)', tolerance);
    end
    % update validation report and validationDataToSave struct
    validationReport = sprintf('%s %s', validationReport, message);
    validationDataToSave.isetEnergyFromQuanta = Quanta2Energy(wlsTest,isetQuanta')';
    

    %% CIE daylights
    % 
    % These routines are now running in ISET and everything agrees.
    message = sprintf('\n\n\t\t***** Energy/Quanta *****');
    validationReport = sprintf('%s %s', validationReport, message);
    
    load B_cieday
    testWls = SToWls(S_cieday);
    testTemp = 4987;
    ptbDaySpd = GenerateCIEDay(testTemp,B_cieday);
    ptbDaySpd = ptbDaySpd/max(ptbDaySpd(:));

    % Iset version of normalized daylight
    isetDaySpd = daylight(testWls,testTemp);
    isetDaySpd = isetDaySpd/max(isetDaySpd(:));
    if (any(abs(isetDaySpd-ptbDaySpd) > tolerance))
        message = sprintf('\n\t\tPTB-ISET DIFFERENCE for daylight (tolerance: %g)', tolerance);
        validationFailedFlag = true;
    else
        message = sprintf('\n\t\tPTB-ISET AGREE for for daylight (tolerance: %g)', tolerance);
    end
    % update validation report and validationDataToSave struct
    validationReport = sprintf('%s %s', validationReport, message);
    validationDataToSave.isetDaySpd = isetDaySpd;
    validationDataToSave.ptbDaySpd  = ptbDaySpd;
    

    % Generate plots, if so specified
    if (nargin >= 1) && (isfield(runParams, 'generatePlots')) && (runParams.generatePlots == true)
        % Your plotting code goes here.
    end
    
end
