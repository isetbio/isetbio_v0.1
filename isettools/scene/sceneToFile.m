function varExplained = sceneToFile(fname,scene,bType,mType)
% Write scene data in the hyperspectral and multispectralfile format
%
%    varExplained = sceneToFile(fname,scene,cFlag,mFlag)
%
% If the cFlag is empty, it saves a file containing photons, wave,
% illuminant structure and a comment.
%
% If the cFlag is a value (double), the function builds a linear model
% basis to represent (and compress) the photon data. It saves the linear
% model, model coefficients, illuminant structure, and a comment. The
% linear model format removes the mean of the photons, builds a linear
% model, and stores the mean, linear model, and coefficients for each
% pixel.
%
%Inputs
% fname:  The full name of the output file
% scene:  ISET scene structure
% mType:  Mean computation
%         Remove the mean ('meansvd') or not ('canonical', default) before
%         calculating svd 
% bType:  Basis calculation type
%         Empty  - No compression, just save photons, wave, comment,
%            illuminant
%         A value between 0 and 1 specifying the fraction of variance
%            explained by the linear model compression (default, 0.99)
%         An integer >= 1 specifies the number of basis functions
%
%Return
% varExplained - Fraction of variance explained by the linear model
%
% Examples:
%   scene = sceneCreate;
%   vcAddAndSelectObject(scene); sceneWindow;
%   sceneToFile('deleteMe',scene,0.999);
%   scene2 = sceneFromFile('deleteMe','multispectral');
%   vcAddAndSelectObject(scene2); sceneWindow;
%
%   sceneToFile('deleteMe',scene,[]);
%
% (c) Imageval Consulting, LLC 2013

if ieNotDefined('fname'), error('Need output file name for now'); end
if ieNotDefined('scene'), error('scene structure required'); end
if ieNotDefined('bType'), bType = [];  end  % See hcBasis
if ieNotDefined('mType'), mType = [];  end  % See hcBasis

% We need to save the key variables
photons    = sceneGet(scene,'photons');
wave       = sceneGet(scene,'wave');
illuminant = sceneGet(scene,'illuminant');
comment = sprintf('Scene: %s',sceneGet(scene,'name'));

if isempty(bType)
    % No compression.
    save(fname,'photons','wave','comment','illuminant');
    varExplained = 1;
else
    % Figure out the basis functions on a subsampled photon image
    photons = photons(1:3:end,1:3:end,:);
    [imgMean, basisData, coef ,varExplained] = hcBasis(photons,bType,mType);
    clear photons;
    
    % Check the basis functions
    %   wList = sceneGet(scene,'wave');
    %   vcNewGraphWin;
    %   for ii = 1:size(basisData,2)
    %       plot(wList,basisData(:,ii)); hold on
    %   end   
    
    %  We have the basis functions.  Determine the coefficients
    %     photons = sceneGet(scene,'photons');
    %     [photons,row,col] = RGB2XWFormat(photons);
    %
    % Remove the mean
    %     imgMean = mean(photons,1);   % vcNewGraphWin; plot(imgMean)
    %     photons = photons - repmat(imgMean,row*col,1);
    %     coef = photons*basisData;
    %     % To get back to the original hc data
    %     %  d = coef*basisData'+ repmat(imgMean,row*col,1);
    %     % Have a look:   hcimage(XW2RGBFormat(d,row,col))
    %
    %     % Reshape the coefficients
    %     coef = XW2RGBFormat(coef,row,col);
    % Could check this way.
    %  d = RGB2XWFormat(coef)*basisData'+ repmat(imgMean,row*col,1);
    %  hcimage(XW2RGBFormat(d,row,col))
    
    % Save the data
    basis.basis = basisData;
    basis.wave  = wave;
    ieSaveMultiSpectralImage(fname,coef,basis,comment,imgMean,illuminant);
    
end

end  % End function
