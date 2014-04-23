function [psfs, spps, subPixelHalfWidth, subPixelHalfHeight] = psfGroupCreate(groupName, varargin)
%Create group of pointspread functions that define a display dixel
%
%   [psfs,spps] = psfGroupCreate(groupName,varargin);
%
%% Parameters
% groupName: The type of display dixel
% Additional arguments specify the dixel properties, These differ for every
% dixel type. Possibilities are:
%  sub-dixel centers
%  sub-dixel widths (or total dixel?)
%  orientation of the sub-dixel arrangements (e.g., horizontal or vertical)
%
% Each sub-dixel has its own point spread function (psf). 
% psfs{ii}.samp - Represents the spatial sampling of (each sub-dixel?) is
% represented in units of ??? microns.
% I am concerned that there is .samp and .sampCol  I think .samp is
% .sampRow, but I am not sure.
% The primary intensity is specified is returned in psfs{ii}.aRawData
%
% Spatial information about the sub-dixel structures are stored in the
% structure spps. 
%
%% Spatial coordinate frame:
%
% The dixel centers are defined in relative coordinates, where [0,0] is the
% center and the range of each dimension runs from [-.5 .5].  The true
% physical spacing (in units) are calculated from the relative units that
% define all the sub-dixels and the dixel-to-dixel spacing in dots per inch
% (dpi) . The centers of the sub-dixels are stored in the rows of
% spps.rCenters in the (x,y) i.e., col,row, format.
%
%% Color information
%
% The primary  associated with each sub-dixel is specified spps.primaries.
% The shape of the matrix spps.primaries indicates the relative position of
% the sub-pixels. For example, an LCD with an RGB stripes would be [1 2 3].
% An LCD with BGR stripes might be [3 2 1]. The 4-color layout of an L6W
% pixel would be
%
%      [ 1 2 3 4; 3 4 1 2]
%
% which is an array:
%
%          R G B W
%          B W R G
%
% The center of each primary w.r.t. the normalized pixel is spps.centers.
%
%% Display types
%
%   'gaussian' - Gaussian crt
%   'lcd' -  3 rectangular subpixels (some order of RGB)
%   'rgbw','wbgr' = 4 rectangular subpixels (some order of RGBW)
%   'l6w' - 2x4 arrangement
%           odd columns have an RG/BW subpixel array
%           even columns have a BW/RG subpixel array
%
% To see examples of the parameters used to create these, read the
% examples below.
%
% See also: psfCreate, vDisplayCreate.
%
%% Examples and descriptions:
%
% Gaussian (rgb):
%    [psfs,spps] = psfGroupCreate('Gaussian CRT');
%    subP = 2;
%    data = psfGet(psfs{subP},'rawData');
%    support = psfGet(psfs{subP},'support');   % Sample position in um
%    figure; mesh(support{2},support{1},data);
%
% Rectangular rgb (lcd):
%   dpi = 72;        % Dots per inch
%   sampSpacing = 5; % Sample spacing in um
%   direction = 'v'; rgbOrder = 'rgb';
%   [psfs,spps] = psfGroupCreate('lcd',dpi,sampSpacing,direction,rgbOrder);
%   figure; plot(spps.rCenters(:,1),spps.rCenters(:,2),'o');
%   set(gca,'xlim',[-.5 .5],'ylim',[-.5 .5])
%
%
% RGBW
%   subPixelHalfWidth = 1/10;  % As a fraction of the normalized pixel
%   [psfS,spps] = psfGroupCreate('rgbw',72,10,'v','rgbw',subPixelHalfWidth);
% 
%  case {'2x2'}
%  case {'2x2rgbg'}
%  case {'3x3rgbdiag'}
%  case {'3x2rgbdeltatriad'}
%  case {'l6w'}
%
% (c) Stanford, PDCSOFT, Wandell, 2010
%%
if ieNotDefined('groupName'), error('Must specify psf/spp type'); end

param = ieParamFormat(groupName);
switch param
    case {'gaussian','gaussiancrt'}
        
        if ~isempty(varargin), dpi = varargin{1}; else dpi = 72; end
        
        % dSpacing is sample spacing in mm
        if length(varargin) > 1, dSpacing = varargin{2};
        else dSpacing = 0.010; end

        % Convert from dpi to microns per dot.  The CRT dixel in this case
        % has 6 sub-pixel positions.  More discussion here.
        dixelWidth = dpi2mperdot(dpi,'mm');
        dixelHeight = dixelWidth;

        % These are col,row (x,y) relative centers with respect to the
        % block of subpixels.  For these hexagonal packed CRTs, we need 6
        % sub-dixels to form a full repeating block. There are only 3
        % primaries, however.
        % THESE LOOK LIKE THEY ARE WRONG AND CHANGED.  NOT THE CRT LOOK.
        % Adjust them later - FIX
        centers = [-1/3, -1/4; 
                      0,  1/4;
                    1/3, -1/4;
                   -1/3,  1/4;
                      0, -1/4;
                    1/3, 1/4];
        % figure; plot(centers(:,1),centers(:,2),'o'); 
        % set(gca,'xlim',[-.5 .5],'ylim',[-.5 .5])
        spps.rCenters = centers;

        % Now we make the actual center position in units of mm
        % This doesn't happen in other cases ... why is that?
        centers = centers*dixelWidth;   % Real unit positions
        sigma   = 0.2*dixelWidth;       % Gaussian spread

        % Create the six sub-dixel psf images and associate each one with a
        % particular primary.
        psfs = cell(1,6);
        for ii=1:6
            psfs{ii} = psfCreate('Gaussian',dixelWidth,dixelHeight,dSpacing,centers(ii,1),centers(ii,2),sigma);            
        end
        % figure; img = psfGet(psfs{1},'psf image','mm'); mesh(img)
        
        % Position of the RGB primaries in the six sub-dixel block. 
        spps.primaries = [1, 2, 3, 1, 2, 3];

    case 'lcd'
        % A three primary LCD display
        % dpi is the dots per inch of the pixels
        % We only have RGB and BGR ordering at the moment.
        % dSpacing is sample spacing for the psf in millimeters.
        % Units for dixel sizes are millimeters
        if ~isempty(varargin), dpi = varargin{1}; else dpi = 96; end
        if length(varargin) > 1, dSpacing = varargin{2}; else dSpacing = 0.010; end
        if length(varargin) > 2, dir = varargin{3}; else dir = 'v'; end
        if length(varargin) > 3, rgbOrder = varargin{4}; else rgbOrder = 'rgb'; end
        if length(varargin) > 4, dixelWidth = varargin{5}; else dixelWidth = dpi2mperdot(dpi,'mm'); end

        % I am not sure why we have height and width everywhere ...
        % although I guess there are situations in which the block is wider
        % than tall ...
        dixelHeight = dixelWidth;
        
        % Specification of the sub-pixel centers is in relative units.
        % The pixel spatial coordinates are [-0.5 0.5], and they get turned
        % into real units inside of the psfCreate() routine.
        if strcmp(dir,'h')
            % Three sub-dixels, bottom to top 
            % Each one-third. Half of this is 1/6th.
            subPixelHalfWidth  = 1/2;   
            subPixelHalfHeight = 1/6;
            centers = [0,-2/3; 0, 0; 0, 2/3];  % Center positions of sub-pixels
        elseif strcmp(dir,'v')
            % Three sub-dixels, left to right
            % Each one-third. Half of this is 1/6th.
            subPixelHalfWidth  = 1/6;
            subPixelHalfHeight = 1/2;
            centers = [-2/3,0; 0,0; 2/3,0];
        else
            error('Unknown direction');
        end

        % MNOTES: PSF contains implicit positional information about the
        % location of the PSF within a dixel
        psfs = cell(1,3);
        for ii=1:3
            psfs{ii} = psfCreate('rectangular',dixelWidth,dixelHeight,dSpacing,...
                centers(ii,1),centers(ii,2),dir,subPixelHalfWidth,subPixelHalfHeight);
        end

        % Adjust ordering for rgb and bgr modes
        if isnumeric(rgbOrder)
            spps.primaries = rgbOrder;
        elseif strcmp(rgbOrder,'rgb')
             spps.primaries = 1:3;
        elseif strcmp(rgbOrder,'bgr')
            spps.primaries = 3:-1:1;
        else
            error('Unknown rgb arrangement');
        end

        spps.rCenters = centers;

    case {'rgbw','wbgr','rgby', 'rgbwstripe','wbgrstripe'}
        % Four color LCD type display, with a white pixel on one side or the other
        % We only take RGBW or WBGR ordering at the moment.
        % [psfS,spps] = psfGroupCreate('rgbw',dpi,dSpacing,dir,rgbOrder,subPixelHalfWidth);
        if ~isempty(varargin), dpi = varargin{1}; else dpi = 72; end
        if length(varargin) > 1, dSpacing = varargin{2}; else dSpacing = 0.010; end  % Microns
        if length(varargin) > 2, dir = varargin{3}; else dir = 'h'; end
        if length(varargin) > 3, rgbOrder = varargin{4}; else rgbOrder = 'rgbw'; end
        if length(varargin) > 4, dixelWidth = varargin{5}; else dixelWidth = dpi2mperdot(dpi,'mm'); end
        if length(varargin) > 5, dixelHeight = varargin{6}; else dixelHeight = dpi2mperdot(dpi,'mm'); end

        if strcmp(dir,'h')
            subPixelHalfWidth = 1/2;
            subPixelHalfHeight = 1/8;
            centers = [0,-3/4; 0,-1/4; 0,1/4; 0,3/4];
        elseif strcmp(dir,'v')
            subPixelHalfWidth = 1/8;
            subPixelHalfHeight = 1/2;
            centers = [-3/4,0; -1/4,0; 1/4,0; 3/4,0];
        else
            error('Unknown direction');
        end

        spps.rCenters = centers;

        psfs = cell(1,4);
        % spps = cell(1,4);

        for ii=1:4
            psfs{ii} = psfCreate('rectangular',dixelWidth, dixelHeight, dSpacing,...
                centers(ii,1),centers(ii,2),dir,subPixelHalfWidth,subPixelHalfHeight);
        end
        % figure(1); mesh(psfs{2}.sCustomData.aRawData) 
         if isnumeric(rgbOrder)
            spps.primaries = rgbOrder;
         elseif strcmp(rgbOrder,'rgbw')
             spps.primaries = 1:4;
         elseif strcmp(rgbOrder,'wbgr')
             spps.primaries = 4:-1:1;
         else
             error('Unknown rgbw arrangement');
         end

    case {'2x2'}
        % Four colors in a 2x2 arrangement
        %
        if ~isempty(varargin), dpi = varargin{1}; else dpi = 72; end
        if length(varargin) > 1, dSpacing = varargin{2}; else dSpacing = 0.010; end  % Microns
        if length(varargin) > 2, dir = varargin{3}; else dir = 'h'; end
        if length(varargin) > 3, rgbOrder = varargin{4}; else rgbOrder = 'rgbw2x2'; end
        if length(varargin) > 4, dixelWidth = varargin{5}; else dixelWidth = dpi2mperdot(dpi,'mm'); end
        if length(varargin) > 5, dixelHeight = varargin{6}; else dixelHeight = dpi2mperdot(dpi,'mm'); end

        subPixelHalfWidth = 1/4;
        subPixelHalfHeight = 1/4;

        centers = [-1/2, -1/2; 1/2, -1/2; -1/2, 1/2; 1/2, 1/2];
        spps.rCenters = centers;

        psfs = cell(1,4);

        for ii=1:4
            psfs{ii} = psfCreate('rectangular',dixelWidth,dixelHeight,dSpacing,...
                centers(ii,1),centers(ii,2),dir,subPixelHalfWidth, subPixelHalfHeight);
        end
 
        % figure(1); mesh(psfs{2}.sCustomData.aRawData)
        if isnumeric(rgbOrder)
            spps.primaries = rgbOrder;
        elseif strcmp(rgbOrder,'rgbw') 
            spps.primaries = [1, 2, 3, 4];
        elseif strcmp(rgbOrder,'wbgr')
            spps.primaries = [4, 3, 1, 2];
        else error('Unknown rgbw arrangement');
        end

    case {'2x2rgbg'}
        % Four colors in a 2x2 arrangement
        %
        if ~isempty(varargin), dpi = varargin{1}; else dpi = 72; end
        if length(varargin) > 1, dSpacing = varargin{2}; else dSpacing = 0.010; end  % Microns
        if length(varargin) > 2, dir = varargin{3}; else dir = 'h'; end
        if length(varargin) > 3, rgbOrder = varargin{4}; else rgbOrder = 'rgbw2x2'; end
        if length(varargin) > 4, dixelWidth = varargin{5}; else dixelWidth = dpi2mperdot(dpi,'mm'); end
        if length(varargin) > 5, dixelHeight = varargin{6}; else dixelHeight = dpi2mperdot(dpi,'mm'); end

        subPixelHalfWidth = 1/4;
        subPixelHalfHeight = 1/4;

        centers = [-1/2, -1/2; 1/2, -1/2; -1/2, 1/2; 1/2, 1/2];
        spps.rCenters = centers;

        psfs = cell(1,4);

        for ii=1:4
            psfs{ii} = psfCreate('rectangular',dixelWidth,dixelHeight,dSpacing,...
                centers(ii,1),centers(ii,2),dir,subPixelHalfWidth, subPixelHalfHeight);
        end
        % figure(1); mesh(psfs{2}.sCustomData.aRawData)
        if isnumeric(rgbOrder)
            spps.primaries = rgbOrder;
        elseif strcmp(rgbOrder,'rgbg') 
            spps.primaries = [1, 2, 2, 3];
        else error('Unknown rgbw arrangement');
        end
  
    case {'3x3rgbdiag'}
        % Three colors in a 3x3 arrangement
        %
        if ~isempty(varargin), dpi = varargin{1}; else dpi = 72; end
        if length(varargin) > 1, dSpacing = varargin{2}; else dSpacing = 0.010; end  % Microns
        if length(varargin) > 2, dir = varargin{3}; else dir = 'h'; end
        if length(varargin) > 3, rgbOrder = varargin{4}; else rgbOrder = 'rgbbrggbr'; end
        if length(varargin) > 4, dixelWidth = varargin{5}; else dixelWidth = dpi2mperdot(dpi,'mm'); end
        if length(varargin) > 5, dixelHeight = varargin{6}; else dixelHeight = dpi2mperdot(dpi,'mm'); end

        subPixelHalfWidth = 1/6;
        subPixelHalfHeight = 1/6;

        centers = [-2/3, -2/3; 0, -2/3; 2/3, -2/3; -2/3, 0; 0, 0; 2/3, 0; -2/3, 2/3; 0, 2/3; 2/3, 2/3];
        spps.rCenters = centers;

        psfs = cell(1,9);
        
        for ii=1:9
            psfs{ii} = psfCreate('rectangular',dixelWidth,dixelHeight,dSpacing,...
                centers(ii,1),centers(ii,2),dir,subPixelHalfWidth, subPixelHalfHeight);
        end

        % figure(1); mesh(psfs{2}.sCustomData.aRawData)
        if isnumeric(rgbOrder)
            spps.primaries = rgbOrder;
        elseif strcmp(rgbOrder,'rgbbrggbr')
            spps.primaries = [1, 2, 3, 3, 1, 2, 2, 3, 1];
        else error('Unknown rgb arrangement');
        end

    case {'3x2rgbdeltatriad'}
        % Three colors in a 3x3 arrangement
        %
        if ~isempty(varargin), dpi = varargin{1}; else dpi = 72; end
        if length(varargin) > 1, dSpacing = varargin{2}; else dSpacing = 0.010; end  % Microns
        if length(varargin) > 2, dir = varargin{3}; else dir = 'h'; end
        if length(varargin) > 3, rgbOrder = varargin{4}; else rgbOrder = 'rgbbrg'; end
        if length(varargin) > 4, dixelWidth = varargin{5}; else dixelWidth = dpi2mperdot(dpi,'mm'); end
        if length(varargin) > 5, dixelHeight = varargin{6}; else dixelHeight = dpi2mperdot(dpi,'mm'); end

        subPixelHalfWidth = (1/7) / 2;
        subPixelHalfHeight = (1/4.5) / 2;

        centers = [ -1, -1/2; -1/3, -1/2; 1/3, -1/2; -2/3, 1/2; 0, 1/2; 2/3, 1/2] / 2;
        spps.rCenters = centers;

        % MNOTE: THIS BREAKS THIS DISPLAY (FIXME) - dixelWidth and
        % dixelHeight not the same
        dixelWidth = dixelWidth * 2;
        psfs = cell(1,6);

        for ii=1:6
            psfs{ii} = psfCreate('rectangular',dixelWidth,dixelHeight,dSpacing,...
                centers(ii,1),centers(ii,2),dir,subPixelHalfWidth, subPixelHalfHeight);
        end

        % figure(1); mesh(psfs{2}.sCustomData.aRawData)
        if isnumeric(rgbOrder)
            spps.primaries = rgbOrder;
        elseif strcmp(rgbOrder,'rgbbrg')
            spps.primaries = [1, 2, 3, 3, 1, 2];
        else error('Unknown rgb arrangement');
        end

    case {'l6w'}
        % Four colors in a 4x2 arrangement
        %
        if ~isempty(varargin), dpi = varargin{1}; else dpi = 72; end
        if length(varargin) > 1, dSpacing = varargin{2}; else dSpacing = 10; end  % Microns
        if length(varargin) > 2, dir = varargin{3}; else dir = 'h'; end
        if length(varargin) > 3, rgbOrder = varargin{4}; else rgbOrder = 'rgbw'; end
        if length(varargin) > 4, dixelWidth = varargin{5}; else dixelWidth = dpi2mperdot(dpi,'um'); end
        if length(varargin) > 5, dixelHeight = varargin{6}; else dixelHeight = dpi2mperdot(dpi,'um'); end

        subPixelHalfWidth = 1/8;
        subPixelHalfHeight = 1/4;

        centers = [-3/4, -1/2; -1/4, -1/2; 1/4, -1/2; 3/4, -1/2; -3/4, 1/2; -1/4, 1/2; 1/4, 1/2; 3/4, 1/2];
        spps.rCenters = centers;

        psfs = cell(1,8);
        
        for ii=1:8
            psfs{ii} = psfCreate('rectangular',dixelWidth,dixelHeight,dSpacing,...
                centers(ii,1),centers(ii,2),dir,subPixelHalfWidth, subPixelHalfHeight);
        end

        if isnumeric(rgbOrder)
            spps.primaries = rgbOrder;
        else
            spps.primaries = [1 2 3 4 3 4 2 1];
        end
 
    otherwise
        error('Unknown display type.')
end

% See what you have on the way out
%
% figure; plot(spps.rCenters(:,1),spps.rCenters(:,2),'o');
% subP = 2; data = psfGet(psfs{subP},'rawData');
% support = psfGet(psfs{subP},'support');   % Sample position in um
% figure; mesh(support{2},support{1},data);

return;