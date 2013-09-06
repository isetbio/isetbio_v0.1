%% s_sceneSVDCompressHyperspectral
%
% Read in hyperspectral scene data and compress the data using linear model
% (svd to get spectral bases)
%
% See also:  s_Scene2SampledScene, s_renderScene
%
% Copyright ImagEval Consultants, LLC, 2012

%%
s_initISET

%%
baseDir = 'F:\ISET Data';

%objList = {'Faces1m','Faces30m','FruitAndMCC','Outdoor'}
objList = {'FruitAndMCC'};

%% We will do it again for VNIR
% wListVNIR = (420:4:950);
% wListSWIR = (967:6:2502);   % Last value is 2501

%%

for dd = 1:length(objList)  % For each of the top level directors
    % dd = 1
    
    % First, find the SWIR files
    thisDir = fullfile(baseDir,objList{dd},'SWIR');
    fileList = dir([thisDir,filesep,'*.mat']);
    
    % For each of the files, do the processing
    for ff = 1:length(fileList)
        
        %% Read in a hyperspectral scene file
        fname = fullfile(thisDir,fileList(ff).name);
        scene = sceneFromFile( fname ,'multispectral',[],[]);
        
        % Have a look at the image
        %         vcAddAndSelectObject(scene);
        %         hdl = ieSessionGet('scene window handle')
        %         % Makes it gray for SWIR
        %         set(hdl.popupDisplay,'Value',2);
        %         sceneWindow;  % This refreshes and brings it up
        %
        %         % Plot the illuminant
        %         plotScene(scene,'illuminant photons roi');
        
        %% Compress the hypercube using a smaller set of spectral basis functions
        % [imgMean, basis, coef] = hcBasis(hc,cType,pExplained)
        
        % Figure out the basis functions on a subsampled photon image
        photons = sceneGet(scene,'photons');
        photons = photons(1:3:end,1:3:end,:);
        [~, basisData] = hcBasis(photons,'meansvd',0.999);
        clear photons;
        
        % Check the basis functions
        %         wList = sceneGet(scene,'wave');
        %         tmp = size(basisData);
        %         vcNewGraphWin;
        %         NumBasis = tmp(2);
        %         for ii = 1:NumBasis
        %             plot(wList,basisData(:,ii)); hold on
        %         end
        
        %%  We have the basis functions.  Determine the coefficients
        hc = sceneGet(scene,'photons');
        [hc,row,col] = RGB2XWFormat(hc);
        
        % Remove the mean
        imgMean = mean(hc,1);   % vcNewGraphWin; plot(imgMean)
        hc = hc - repmat(imgMean,row*col,1);
        coef = hc*basisData;
        % To get back to the original hc data
        %  d = coef*basisData'+ repmat(imgMean,row*col,1);
        % Have a look:   hcimage(XW2RGBFormat(d,row,col))
        
        % Make the coefficients an RGB image so we can use
        % imageLinearTransform in vcReadImage
        coef = XW2RGBFormat(coef,row,col);
        
        %  d = RGB2XWFormat(coef)*basisData'+ repmat(imgMean,row*col,1);
        %  hcimage(XW2RGBFormat(d,row,col))
        
        %% Save the data
        % Input arguments
        %   mcCOEF  - coefficients (RGB format)
        %   basis   - basis functions functions
        %   comment
        %   imgMean - in some cases we remove the mean before creating the coeffs
        %   illuminant structure
        %     .wave  are wavelengths in nanometers
        %     .data  are illuminant as a function of wavelength in energy units
        % cd 'C:\Users\joyce\Documents\Matlab\SVN\scenedata\HyperspectralCompressed'
        [~,n] = fileparts(fileList(ff).name);
        comment = sprintf('%s: Compressed using SVD with imgMean separated out',n);
        basis.basis = basisData;
        basis.wave = wList;
        illuminant = illuminantCreate;
        illuminant = illuminantSet(illuminant,'wave',sceneGet(scene,'wave'));
        illuminant = illuminantSet(illuminant,'photons',sceneGet(scene,'illuminant photons'));
        illuminant = illuminantSet(illuminant,'name','Aris studio lamp');
        
        % Put the result in the Compressed subdirectory
        if isdir(fullfile(thisDir,'Compressed'))
        else mkdir(fullfile(thisDir,'Compressed'))
        end
        
        oName = fullfile(thisDir,'Compressed',[n,'_Cx']);
        
        ieSaveMultiSpectralImage(oName,coef,basis,comment,imgMean,illuminant);
        clear coef
        
        %% Test: Reading in the saved data
        % wList = [420:4:950];
        %         scene = sceneFromFile(oName ,'multispectral',[],[]);
        %         vcAddAndSelectObject(scene); sceneWindow;
        %         % Plot the illuminant
        %         plotScene(scene,'illuminant photons roi')
        
        %% Problem
        % ieSaveMultiSpectralImage assumes illuminant is stored in units of energy
        % by sceneFromFile ...
        % Starting to convert from old illuminant format to the modern one
        % on August 4, 2012.  New illuminant has photon representation and
        % a more standard Create/Get/Set group of functions.
        
        
    end
end




%% End
