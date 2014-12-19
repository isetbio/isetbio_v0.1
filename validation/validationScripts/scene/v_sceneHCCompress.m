function varargout = v_sceneCompress(varargin)
%
% Validate hyperspectral scene data and compression
%
% Uses linear model compression.
%
% Copyright ImagEval Consultants, LLC, 2012

    %% Initialization
    % Initialize validation run
    runTimeParams = UnitTest.initializeValidationRun(varargin{:});
    % Initialize return params
    if (nargout > 0) varargout = {'', false, []}; end
    
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


%% Here is the actual code
function ValidationFunction(runTimeParams)

%% Initialize
s_initISET;

%% Read in the scene
fName = fullfile(isetRootPath,'data','images','multispectral','StuffedAnimals_tungsten-hdrs');
scene = sceneFromFile(fName,'multispectral');
UnitTest.validationData('sceneA', scene);
    
% Have a look at the image
if (runTimeParams.generatePlots)
    % Show scene in window
    vcAddAndSelectObject(scene); sceneWindow;
    
    % Plot the illuminant
    plotScene(scene,'illuminant photons');
end

%% Compress the hypercube requiring only 95% of the var explained
vExplained = 0.95;
[imgMean, imgBasis, coef] = hcBasis(sceneGet(scene,'photons'),vExplained);

%% Save the data 
wave        = sceneGet(scene,'wave');
basis.basis = imgBasis;
basis.wave  = wave;

comment = 'Compressed using hcBasis with imgMean)';

illuminant = sceneGet(scene,'illuminant');
% illuminant.wavelength = scene.spectrum.wave;
% illuminant.data = scene.illuminant.data;
oFile = fullfile(isetRootPath,'deleteMe.mat');
ieSaveMultiSpectralImage(oFile,coef,basis,comment,imgMean,illuminant);

%% read in the data
wList = 400:5:700;
scene2 = sceneFromFile(oFile ,'multispectral',[],[],wList);

% It is very desaturated
if (runTimeParams.generatePlots)
    vcAddAndSelectObject(scene2); sceneWindow;
end

%% Now require that most of the variance be plained
vExplained = 0.99;
[imgMean, imgBasis, coef] = hcBasis(sceneGet(scene,'photons'),vExplained);
fprintf('Number of basis functions %.0f\n',size(imgBasis,2));

%% Save the data 
wave        = sceneGet(scene,'wave');
basis.basis = imgBasis;
basis.wave  = wave;

comment = 'Compressed using hcBasis with imgMean)';

illuminant = sceneGet(scene,'illuminant');
% illuminant.wavelength = scene.spectrum.wave;
% illuminant.data = scene.illuminant.data;
ieSaveMultiSpectralImage(oFile,coef,basis,comment,imgMean,illuminant);

%% read in the data
wList = 400:5:700;
scene2 = sceneFromFile(oFile ,'multispectral',[],[],wList);
vcAddAndSelectObject(scene2); sceneWindow;

%% Clean up the temporary file.
delete(oFile);

%% End
end
