function val = psfGet(psf,param,varargin)
%psfGet - Get parameters from a psf structure
%
%   val = psfGet(psf,param,varargin)
%
% A color pixel contains several sub-pixels, and each of these has a point
% spread function.  Usually we have a pixelPSF cell array that contains
% several sub-pixel structures, like this.
%
%  pixelPSF{1} = psfCreate('name','red-Dell-LCD');
%  pixelPSF{2} = psfCreate('name','green-Dell-LCD');
%  pixelPSF{3} = psfCreate('name','blue-Dell-LCD');
%
% We need to specify the rawData intensity distribution.  Someone must look
% up how we created these point spread variables from the camera data.
% Then we should try to specify the meaning of the numbers in the psf raw
% data field and have units for it.  This is probably implicit in the code
% somewhere - look it up and put it here!
%
% Example:
%    dsp = ctGetObject('display');  psf = displayGet(dsp,'psf');
%    subP = 1;
%    data = psfGet(psf{subP},'rawData');
%    support = psfGet(psf{subP},'support');   % Sample position in um
%    figure; mesh(support{2},support{1},data);
%    xlabel('um'), ylabel('um'); zlabel('Relative intensity'); title('PSF mesh')
%
%    data    = psfGet(psf{2},'sampledPSFData', 50);
%    support = psfGet(psf{2},'resampledGrid',50);
%    figure; mesh(support{2},support{1},data);
%    xlabel('um'), ylabel('um'); zlabel('Relative intensity');
%    title('Re-sampled PSF mesh');
%
%    psfGet(psf{2},'psfSize')
%    psfGet(psf{2},'psfSize','mm')
%
% See also:  psfCreate, psfSet, s_CustomPixelData
%
% PSF parameters (more editing
%     'type'   - Self-description of the structure as a psf structure
%     'name'   - Describes the type of psf, such as Gaussian, Custom,
%     'sampledpsfdata'
%     'resampledgrid' - Custom data from measurements of display contained here
%     'customdata'    - Whole custom data structure.
%     'psfimage'      - A matrix image of relative intensities as a function of position.
%                     - The spatial sampling units are coded in the cdColSpacing/RowSpacing variables.
%         The units of the image are the DV from the camera.  We
%         should probably change this field to be either a peak of one or a
%         unit area.
%     'rows'        % Number of samples
%     'cols'        % Number of samples
%     'size'        % Number of sample points
%     'rowspacing'  % Units are um
%     'colspacing'  % Units are microns
%     'spacing'     % Units are microns
%     'support'     % Support (in um) with 0 at the center of the sub-pixel psf
%     'samplepositions'  % Units are um.
%     'psfsize'       % Units are um
%
% The many parameters cdrows, cdcols, and so forth below, refer to the old
% 'customdata' ideas in the past.  Those are legacy.  Everything is now
% treated as custom data.
%
% Wandell, 2006

if ieNotDefined('psf'), error('PSF structure required.'); end
if ieNotDefined('param'), error('Parameter required.'); end

val = [];

param = ieParamFormat(param);
switch param

    case {'type'}
        % This is a self-description of the structure as a psf structure
        val = psf.type;

    case {'name','psftype'}
        % This describes the type of psf, such as Gaussian, Custom, and
        % others in the future.
        val = psf.name;

    case {'sampledpsfdata','sampledpsf'}
        % psfGet(psf,'sampledPsf','um')
        %
        % Return PSF data interpolated to a sample spacing specified in the
        % third argument.
        %         if checkfields(psf,'aSampledPSFData')
        %             I don't understand this condition.  Should it exist?  It
        %             appears that if these data are filled, we just return the
        %             existing entry.  I don't think we should allow this.
        %             error('This condition should not be here');
        %             This is the old code.  Eliminate it.
        %                         if ~isempty(psf.aSampledPSFData)
        %                             val = psf.aSampledPSFData;
        %                         end
        if length(varargin) > 1, units = varargin{2};
        else units = 'um';
        end
        if length(varargin) < 1 || isempty(varargin{1})
            % No resampling, values returned are in 'um'
            val = psfGet(psf,'psfImage');
        else
            % Typically, varargin{1} will be the output spacing (oSpacing)
            % from the virtual display.  So the size of the interpolated
            % psf image will be 
            %
            %   sampPerPix = vDisplayGet(vd,'pixel size','mm')/oSpacing
            %
            % PSF sampled at the sample spacing determined by varargin{1}.
            % All units should be microns.
            % We should find a way to return the sample grid, nX,nY, also.
            % At present, there is the call below to 'resampledGrid'
            newSpace = varargin{1};    % Sample spacing 
            psfImage = psfGet(psf,'psfImage');
            oldSamps = psfGet(psf,'psfSamples', units);
 
            % Create new sample values.
            newSamps = min(oldSamps):newSpace:max(oldSamps);
            [oX,oY] = meshgrid(oldSamps,oldSamps);
            [nX,nY] = meshgrid(newSamps,newSamps);
            val = interp2(oX,oY,psfImage,nX,nY,'linear*');

            % Have a look for debugging.

            % figure(1); mesh(oX,oY,psfImage); figure(2); mesh(nX,nY,val)
        end
        
    case {'resampledgrid'}
        % val = psfGet(psf,'resampledGrid',50)
        % This is the grid used for
        newSpace = varargin{1};
        oldSamps = psfGet(psf,'psfsamples');
        newSamps = min(oldSamps):newSpace:max(oldSamps);
        [nX,nY] = meshgrid(newSamps,newSamps);
        val{1} = nX; val{2} = nY;

        % Custom data from measurements of display contained here
    case {'customdata'}
        % Whole custom data structure.
        if checkfields(psf,'sCustomData'), val = psf.sCustomData;
        else error('No custom data');
        end
    case {'psfimage','cdimage','rawdata','data'}
        % An image of relative intensities.
        % The spatial position units are spaced 0.25 microns (um).
        % Should we guarantee this field has either a peak of one or a unit
        % area?  This is probably required for calibration consistency.
        % Shalomi?
        if checkfields(psf,'sCustomData','aRawData')
            val = psf.sCustomData.aRawData; 
        end
        % figure; mesh(psf.sCustomData.aRawData);
    case {'rows','cdrows'}
        val = size(psfGet(psf,'rawdata'),1);
    case {'cols','cdcols'}
        val = size(psfGet(psf,'rawdata'),2);
    case {'size','cdsize'}
        val = size(psfGet(psf,'rawdata'));
    case {'rowspacing','cdrowspacing'} % Units are um
        samp = psfGet(psf,'psfSamples');
        val = samp(2) - samp(1);
        if isempty(varargin), return;
        else units = varargin{1};
        end
        val = (val/(10^6))*ieUnitScaleFactor(units);
    case {'cdcolspacing','colspacing'}  % Units are microns
        samp = psfGet(psf,'psfSamples');
        val = samp(2) - samp(1);
        if isempty(varargin), return;
        else units = varargin{1};
        end
        val = (val/(10^6))*ieUnitScaleFactor(units);
    case {'spacing','cdspacing'}     % Default units are microns
        val = [psfGet(psf,'cdRowSpacing'),psfGet(psf,'cdColSpacing')];
        if isempty(varargin), return;
        else units = varargin{1};
        end
        val = (val/(10^6))*ieUnitScaleFactor(units);
    case {'support','cdsupport'}     
        % Support (in um) with 0 at the center of the sub-pixel psf
        % Comes back as a spatial sampling grid
        s = psfGet(psf,'psfSamples');
        [x,y] = meshgrid(s,s);
        val{1} = x; val{2} = y;
        if isempty(varargin), return;
        else units = varargin{1};
        end
        val = (val/(10^6))*ieUnitScaleFactor(units);

    case {'psfsamplesrow','psfsamples','samplepositions'}   
        % psfGet(psf,'psfSamples,'mm')
        % The default sample units are mm
        % But you can have them returned in other units
        % 
        val = psf.sCustomData.samp;
        if isempty(varargin), return;
        else units = varargin{1};
        end
        % Correct for microns to meters and then scale.
        val = (val/(10^3))*ieUnitScaleFactor(units);
    case {'psfsamplescol'}
        % psf image (aRawData) sample spacing in microns
        val = psf.sCustomData.sampCol;
        if isempty(varargin), return;
        else units = varargin{1};
        end
        val = (val/(10^6))*ieUnitScaleFactor(units);

    case {'psfsize'}                        % Units are um
        s = psfGet(psf,'psfSamples');
        val = s(end) - s(1);
        if isempty(varargin), return;
        else units = varargin{1};
        end
        val = (val/(10^6))*ieUnitScaleFactor(units);

    otherwise
        error('Unknown psf parameter %s',param);

end

return;
