function [photons, mcCOEF, basis, comment, illuminant ] = vcReadImage(fullname,imageType,varargin)
% Read image monochrome, rgb, or multispectral data, return multispectral
% photons
%
%   [photons,mcCOEF,basis,comment,illuminant] = vcReadImage(fullname,imageType,varargin)
%
% The image data in fullname are converted into photons.  The other
% parameters can be returned if needed.  This routine is called pretty much
% only by sceneFromFile.
%
% There are several different image file types. This program tries to
% determine the type from the file name.  If that fails, the user is
% queried.
%
%  'rgb','unispectral','monochrome': In this case, varargin{1} can be a
%     file name to a display (displayCreate) structure.  In that case, the
%     data in the RGB or other format are returned as photons estimated by
%     putting the data into the display framebuffer.
%
%     If there is no display calibration file, we arrange the values so
%     that the display code returns the same RGB values as in the original
%     file.
%
%  'multispectral','hyperspectral': In this case the data are stored as
%     coefficients and basis functions. We build the spectral
%     representation here. These, along with a comment and measurement of
%     the scene illuminant (usually measured using a PhotoResearch PR-650
%     spectral radiometer) can be returned.
%
%  An empty input filename produces a return, with no error message, to
%  work smoothly with canceling vcSelectImage.
%
% Examples:
%  photons = vcReadImage;
%  photons = vcReadImage(vcSelectImage,'monochrome');
%  photons = vcReadImage(imageNameFullPath,'rgb');
%  photons = vcReadImage(imageNameFullPath,'hyperspectral');
%  photons = vcReadImage(imageNameFullPath,'multispectral');
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('imageType'), imageType = 'rgb'; end
if ieNotDefined('fullname'), [fullname,imageType] = vcSelectImage(imageType); end
if isempty(fullname), photons = []; return; end

% These are loaded for a file, when they are returned.
mcCOEF = []; comment = '';

imageType = ieParamFormat(imageType);

switch lower(imageType)
    
    case {'rgb','unispectral','monochrome'}
        if isempty(varargin) || isempty(varargin{1}), dispCal = []; 
        else dispCal = varargin{1};
        end
        
        % Read the image data and convert them to double
        inImg = imread(fullname);
        inImg = double(inImg);
        
        % If the data are 2 or 3 dimensions, then we have a unispectral or
        % an RGB image.
        if ndims(inImg) == 2 || ndims(inImg) == 3
            if ndims(inImg) == 2
                % A unispectral image.  We convert it to an RGB image and
                % then process it the same we we process an RGB image.
                rgbImg =zeros(size(inImg,1),size(inImg,2),3);
                for ii=1:3
                    rgbImg(:,:,ii) = inImg;
                end
                inImg = rgbImg;
                clear rgbImg;
            end
            
            % An rgb image.
            if isempty(dispCal)
                % If there is no display calibration file, we arrange the
                % photon values so that the scene window shows the same RGB
                % values as in the original file.
                %
                fprintf('[%s]: Assuming RGB data are 8 bits.\n', mfilename);
                [xwImg,r,c,w] = RGB2XWFormat(inImg/255);
                
                % Prevent DR > 10,000.  See ieCompressData.
                xwImg = ieClip(xwImg,1e-3,1);
                
                % When we render the RGB data in xwImg, they are multipled
                % by the colorBlockMatrix.  By storing the photons this
                % way, the displayed image in the scene window will be the
                % same as the original RGB image.
                photons = xwImg*pinv(colorBlockMatrix(31));
                
            else
                % The user sent a display calibration file. Go get it and
                % interpret the data with respect to that display.
                
                % Create a display structure using the file the user
                % specified
                d      = displayCreate(dispCal);
                wave   = displayGet(d,'wave');  % Primary wavelengths
                spd    = displayGet(d,'spd');   % Primary SPD in energy
                
                % Gamma issues
                %
                % The display gamma might assume a 10 bit image.  But the
                % image we read, might just be an 8-bit image.  We need to
                % scale the image we read into 0/1.  How can we be sure
                % that the image we read is 8 bit, when the display could
                % be 10-bit?  We just check that the max level is less than
                % 255.  If it is, we assume it is 8 bit.  If it is > 255
                % and < 1024, we assume 10 bit.
                %
                % gTable = displayGet(d,'gamma'); % Gamma table
                mx = max(inImg(:));
                if mx < 256,      [xwImg,r,c,w] = RGB2XWFormat(inImg/255);
                elseif mx < 1024, [xwImg,r,c,w] = RGB2XWFormat(inImg/1023);
                else error('Image mx is uninterprettable %f',mx);
                end
                
                % Prevent absurd DR > 100,000. Helps with ieCompressData.
                xwImg = ieClip(xwImg,1e-5,1);
                
                % The gamma table part here won't work if we scale first.
                % The values need to be DAC values (integers) not scaled
                % between 0 and 1.  At some point, get back to this and
                % make the DAC value stuff work right.  For now, make the
                % call and use a power function of 2.2
                %
                % Now, we need to convert to linear values using dac2rgb
                % xwImg = dac2rgb(xwImg,gTable);
                xwImg = dac2rgb(xwImg);
                
                % Yes, this has a lot of transposes.  Sorry.  Try not to
                % think about it.
                photons = Energy2Quanta(wave,(xwImg*spd')')';
            end
            photons = XW2RGBFormat(photons,r,c);
        else
            error('Bad number of dimensions (%.0f) for image data',ndims(img));
        end
        
    case {'multispectral','hyperspectral'}
        
        % These are always there.  Illuminant should be there, too.  But
        % sometimes it isn't, so we check below, separately.
        
        % See if the representation is a linear model with basis functions
        variables = whos('-file',fullname);
        if ieVarInFile(variables,'mcCOEF')
            disp('Reading multispectral data with mcCOEF.')

            % Make this a function.
            % [photons,basis] = ieReadMultispectralCoef(fullname);
            

            % The data are stored using a linear model
            load(fullname,'mcCOEF','basis','comment');
            
            % Resample basis functions to the user specified wavelength
            % list.  vcReadImage(fullname,'multispectral',[400:20:800]);
            if ~isempty(varargin) && ~isempty(varargin{1})
                oldWave    = basis.wave;
                newWave    = varargin{1};
                nBases     = size(basis.basis,2);
                extrapVal  = 0;
                newBases   = zeros(length(newWave),nBases);
                for ii=1:nBases
                    newBases(:,ii) = interp1(oldWave(:), basis.basis(:,ii), newWave(:),'linear',extrapVal);
                end
                basis.basis = newBases;
                basis.wave = newWave;
            end
            
            % The image data should be in units of photons
            photons = imageLinearTransform(mcCOEF,basis.basis');
            
            % These lines are left in because there must be different file
            % types out there somewhere.  Sometimes we stored the mean, and
            % sometimes we didn't.
            if ieVarInFile(variables,'imgMean')
                disp('Saved using principal component method');
                load(fullname,'imgMean')
                
                % Resample the image mean to the specified wavelength list
                if ~isempty(varargin)&& ~isempty(varargin{1})
                    extrapVal  = 0;
                    imgMean = interp1(oldWave(:), imgMean(:), newWave(:),'linear',extrapVal);
                end
                
                % Sometimes we run out of memory here.  So we should have a
                % try/catch sequence.
                %
                % The saved function was calculated using principal components,
                % not just the SVD.  Hence, the mean is stored and we must add
                % it into the computed image.
                [photons,r,c] = RGB2XWFormat(photons);
                try
                    photons = repmat(imgMean(:),1,r*c) + photons';
                catch ME
                    % Probably a memory error. Try with single precision.
                    if strcmp(ME.identifier,'MATLAB:nomem')
                        photons = repmat(single(imgMean(:)),1,r*c) + single(photons');
                    else
                        ME.identifier
                    end
                end
                
                photons = double(XW2RGBFormat(photons',r,c));
                % figure(1); imagesc(sum(img,3)); axis image; colormap(gray)
                
            else
                disp('Saved using svd method');
            end
            
            % Deal with the illuminant
            if ieVarInFile(variables,'illuminant'), load(fullname,'illuminant')
            else
                illuminant = [];
                warndlg('No illuminant information in %s\n',fullname);
            end
            
            photons = max(photons,0);
            
        else
            % The variable photons should be stored, there is no linear
            % model. We fill the basis slots.  Also, we allow the photons
            % to be stored in 'photons' or 'data'.  We allow the wavelength
            % to be stored in 'wave' or 'wavelength'.  Ask Joyce why.
            disp('Reading multispectral data with raw data.')

            % Make this function.
            % [photons,basis] = ieReadMultispectralRaw(fullname);
            
            if ieVarInFile(variables,'photons'), load(fullname,'photons');
            elseif ieVarInFile(variables,'data')
                load(fullname,'data'); photons = data; clear data;
            else error('No photon data in file'); 
            end  
            if ieVarInFile(variables,'comment'),  load(fullname,'comment'); end            
            if ieVarInFile(variables,'wave'), load(fullname,'wave');
            elseif ieVarInFile(variables,'wavelength')
                load(fullname,'wavelength');
                wave = wavelength; clear wavelength; %#ok<NODEF>
            end

            % Pull out the photons
            if ~isempty(varargin) && ~isempty(varargin{1})
                newWave = varargin{1};
                perfect = 0;
                idx = ieFindWaveIndex(wave,varargin{1},perfect);
                photons = photons(:,:,idx);
                wave = newWave;
                % oldWave = wave;
                % wave = newWave;
            end
            basis.basis = []; basis.wave = round(wave);
        end
        
        % For linear model or no linear model, either way, we try to find
        % illuminant and resample.
        illuminant = [];
        if ieVarInFile(variables,'illuminant'), load(fullname,'illuminant')
        else        warndlg('No illuminant information in %s\n',fullname);
        end
        illuminant = illuminantModernize(illuminant);
        
        % Resample the illuminant to the specified wavelength list
        if ~isempty(varargin)&& ~isempty(varargin{1})
            % Resample the illuminant wavelength to the new wave in the
            % call to this function.  This interpolates the illuminant
            % data, as well.
            illuminant = illuminantSet(illuminant,'wave',newWave(:));
        end
        
    otherwise
        fprintf('%s',imageType);
        error('Unknown image type.');
end

return;



