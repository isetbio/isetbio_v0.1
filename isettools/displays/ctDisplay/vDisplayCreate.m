function vd = vDisplayCreate(dspType,varargin)
%Create a virtual display structure
%
%   vDisplay = vDisplayCreate(dspType,varargin)
%
% Several types of display structures can be created.  More types of
% virtual displays will be added over time.
%
% MNOTE: Dixel width and heigth (specific in mm, e.g. .56 = 560 microns)
%   Rather than using DPI, you can now pass in args which specific the
%   width and height of the dixels (dixels are tiling units used to create
%   the display, the tile is repeated to create a display subpixel layout)
%
% MNOTE: Be wary of DPI
%   Be very careful when using the concept of DPI, as in much of the code
%   a dot is equvialent to a dixel NOT a pixel. Dixels can "contain" multiple
%   pixels. This is dangerous, as the font raster takes in a DPI param. How
%   does that relate to dixel tile "dpi"?
%
%        **** The logic of the virtual Display structure ****
%
% A virtual display will generally have P different primaries.  The
% position of a primary within a pixel may vary depending on the row and
% column location of that pixel.  We define a sub-pixel as primaries at a
% particular pixel location.
%
% For example, CRTs often have hexagonal packing array. Pixel (1,1) might
% have a triangle with R G on top and B on the bottom, while the adjacent
% pixel (1,2) might have blue on top and red green on the bottom. In this
% case, the display has three primaries but six sub-pixels.  The sub-pixel
% pattern repeats every two pixels.
%
% LCDs typically have one type of repeating pixel so that each primary
% appears once in the same position within each pixel.  This is true for
% the RGB or RGBW LCD. (But not for the Clairvoyant L6W).
%
% The  primaries and sub-pixel properties are stored in the sub-pixel
% pattern structure, the psf and the spd fields within the display.  In
% fact, these are grouped inside of the dixel structure, but can be
% accessed directly from the vDisplayGet/Set properties.
%
%      vd   = displayGet(ctGetObject('displayGD'),'currentDisplay');
%      spps = vDisplayGet(vd,'spps');
%      spd  = vDisplayGet(vd,'spd');
%
% Many other properties of the display, such as its spatial sample
% positions and many others can also be retrieved.
%
% The input image to the display represents the intensities of the
% primaries. A display that is row x col x nPrimaries has an input image
% that is of the same size.
%
% The high resolution rendering of these data, that accounts for the
% primary SPDs, the sub-pixel positions, and the pixel point spread
% function is stored in the imageRendered field of the display.  The
% vdisplayCompute() routine accounts for all of these factors and creates
% the rendered image from the input image.
%
% Examples:
%  dispGD = ctGetObject('display');
%  displayCRT  = vDisplayCreate('crt');
%  displayLCD  = vDisplayCreate('lcd');
%  displayRGBW = vDisplayCreate('rgbw');
%  displayWBGR = vDisplayCreate('wbgr');
%  displayRGBW2x2 = vDisplayCreate('rgbw2x2');
%  displayL6W  = vDisplayCreate('l6w');
%
%  dispGD = displaySet(dispGD,'vDisplay',displayRGBW2x2); 
%  ctSetObject('display',dispGD);
%  ctDisplay;
%
% (c) Stanford, PDCSOFT, Wandell, 2010
        
if ieNotDefined('dspType'), dspType = 'default'; end

% Initialize a virtual display structure
vd = vDisplayCreateStruct;

% Lets keep track of what vDisplay type this is (may be useful for
% bypassing hardcoding of RGB parameter passing)
vd = vDisplaySet(vd,'name', upper(dspType));

% Modify the default display to a specific type
dspType = lower(dspType);

switch lower(dspType)
    case {'gaussian','crt','gaussiancrt'}
        % Three primaries and six sub-pixels
        if ~isempty(varargin), dpi = varargin{1}; else dpi = 72; end
        if length(varargin) > 1, dSpacing = varargin{2}; else dSpacing = 0.010; end
        
        vd    = displayGaussianCRT(vd, dpi, dSpacing);
        dixel = vDisplayGet(vd, 'dixel');
        dixel = dixelSet(dixel, 'pixelsizeinmmonly', dpi2mperdot(dpi,'mm'));

        % names = cell(1,3);
        names = {'r', 'g', 'b'};
        
        dixel = dixelSet(dixel, 'Power Consumption Per Subpixel', [9 9 24 9 9 24]);

        spd   = dixelGet(dixel,'spd');
        gam   = dixelGet(dixel,'gam');

        % Adjust the dixel default properties
        dixel = dixelSet(dixel, 'NameOfPrimaries', names);
        dixel = dixelSet(dixel, 'gam', gam);
        dixel = dixelSet(dixel, 'spd', spd);
        dixel = dixelSet(dixel, 'boundeddixel', 1);     % Indicate that this dixel had overlay tiling

        % Lets keeps info on pixel and sub-pixel numbers correct
        dixel = dixelSet(dixel, 'NumberOfPixelsPerBlockX', 2);
        dixel = dixelSet(dixel, 'NumberOfPixelsPerBlockY', 1);

        % Overscaling is orientation independent
        dixel = dixelSet(dixel, 'SubpixelOverscaleX', 3);
        dixel = dixelSet(dixel, 'SubpixelOverscaleY', 2);

        vd    = vDisplaySet(vd,'name', upper(dspType));
        vd    = vDisplaySet(vd, 'dixel', dixel);
        
        % Set input image raw data to the right size
        img    = ones(4,4,6);
        vd     = vDisplaySet(vd, 'InputImage', img);


    case {'default','lcd'}
        % vDisplayCreate('lcd',dpi,dSpacing,dir,rgbOrder);
        
        % Three primaries and three sub-pixels.
        if ~isempty(varargin), dpi = varargin{1}; else dpi = 72; end

        % dSpacing is sample spacing of the psf representation.
        % This and other sizes are in mm
        if length(varargin) > 1, dSpacing = varargin{2}; else dSpacing = 0.010; end
        if length(varargin) > 2, dir = varargin{3}; else dir = 'v'; end
        if length(varargin) > 3, rgbOrder = varargin{4}; else rgbOrder = 'rgb'; end

        % We use DPI to calculate dixel width and height in mm.
        if length(varargin) > 5
            dixelWidth  = varargin{5};
            dixelHeight = varargin{6};
        else
            dixelWidth  = dpi2mperdot(dpi,'mm');
            dixelHeight = dixelWidth;
        end
        
        vd = createDisplay(vd, 'lcd', dpi, dSpacing, dir, rgbOrder, dixelWidth, dixelHeight);

        % What overscaling should we use on this display?
        dixel = vDisplayGet(vd,'dixel');
 
        % Overscaling for ClearType rendering depends on sub-pixel orientation
        if dir == 'v'
            dixel = dixelSet(dixel, 'SubpixelOverscaleX', 3);
            dixel = dixelSet(dixel, 'SubpixelOverscaleY', 1);
        else
            dixel = dixelSet(dixel, 'SubpixelOverscaleX', 1);
            dixel = dixelSet(dixel, 'SubpixelOverscaleY', 3);
        end

        % Set power consumption of each subpixel in microWatts, [9 9 24]
        % means R uses 9 microWatts, G uses 10 microWatts, and B uses 24
        % microWatts
        if strcmp(rgbOrder, 'rgb') == 1
            powerPerSubpixel = [9 9 24];    % RGB
        else
            powerPerSubpixel = [24 9 9];    % BGR
        end

        dixel = dixelSet(dixel, 'Power Consumption Per Subpixel', powerPerSubpixel);
        
        vd    = vDisplaySet(vd,'name', dspType);        
        vd    = vDisplaySet(vd,'dixel',dixel);

        % This is the little white patch that is displayed by default.
        img    = ones(4,4,3);
        vd     = vDisplaySet(vd,'InputImage',img);

    case {'rgbw','wbgr','rgbwstripes','wbgrstripes'}
        % Four sub-pixels and four primaries.
        % Four color display with a white pixel.
        % The ordering is specified in the rgbOrder (4th parameter) or in
        % the dspType argument itself
        if ~isempty(varargin), dpi = varargin{1}; else dpi = 72; end
        if length(varargin) > 1, dSpacing = varargin{2}; else dSpacing = 0.010; end
        if length(varargin) > 2, dir = varargin{3}; else dir = 'v'; end
        if length(varargin) > 3, rgbOrder = varargin{4};
        else rgbOrder = lower(dspType); end

        % Do we use DPI to calc dixel width and height, or do have
        % explicit values for width and height?
        if length(varargin) > 5
            dixelWidth = varargin{5};
            dixelHeight = varargin{6};
        else
            dixelWidth = dpi2mperdot(dpi,'mm');
            dixelHeight = dpi2mperdot(dpi,'mm');
        end

        vd = createDisplay(vd, 'rgbw', [], dSpacing, dir, rgbOrder, dixelWidth, dixelHeight);

        dixel = vDisplayGet(vd,'dixel');

        spd   = dixelGet(dixel,'spd');
        sFactor = 2.5*sum(spd(2,:))/size(spd,2);
        spd   = [spd; ones(1,size(spd,2))*sFactor];
         
        names = cell(1,4);
        for ii=1:4, names{ii} = rgbOrder(ii); end

        gam   = dixelGet(dixel,'gam'); gam{4} = gam{3};

        % Adjust the dixel default properties
        dixel = dixelSet(dixel,'NameOfPrimaries',names);
        dixel = dixelSet(dixel,'gam',gam);
        dixel = dixelSet(dixel,'spd',spd);

        % Lets keeps info on pixel and sub-pixel numbers correct
        dixel = dixelSet(dixel, 'NumberOfPixelsPerBlockX', 1);
        dixel = dixelSet(dixel, 'NumberOfPixelsPerBlockY', 1);

        % Overscaling depends on pixel orientation
        if dir == 'v'
            dixel = dixelSet(dixel, 'SubpixelOverscaleX', 4);
            dixel = dixelSet(dixel, 'SubpixelOverscaleY', 1);
        else
            dixel = dixelSet(dixel, 'SubpixelOverscaleX', 1);
            dixel = dixelSet(dixel, 'SubpixelOverscaleY', 4);
        end

        % Set power consumption of each subpixel in microWatts, see LCD
        % display above for more details
        if strcmp(rgbOrder, 'rgbw') == 1
            powerPerSubpixel = [9 9 24 15]; % RGBW
        else
            powerPerSubpixel = [15 24 9 9];    % WBGR
        end

        dixel = dixelSet(dixel, 'Power Consumption Per Subpixel', powerPerSubpixel); 

        vd    = vDisplaySet(vd,'name', upper(dspType));
        vd    = vDisplaySet(vd,'dixel',dixel);
        
        % Set input image raw data to the right size
        img    = ones(4,4,4);
        vd     = vDisplaySet(vd,'InputImage',img);


    case {'rgby'}       % NOT WORKING
        % Four sub-pixels and four primaries.
        % Four color display with a white pixel.
        % The ordering is specified in the rgbOrder (4th parameter) or in
        % the dspType argument itself
        if ~isempty(varargin), dpi = varargin{1}; else dpi = 72; end
        if length(varargin) > 1, dSpacing = varargin{2}; else dSpacing = 10; end
        if length(varargin) > 2, dir = varargin{3}; else dir = 'v'; end
        if length(varargin) > 3, rgbOrder = varargin{4};
        else rgbOrder = lower(dspType); end
        vd    = displayRGBW(vd,dpi,dSpacing,dir,rgbOrder);
        dixel = vDisplayGet(vd,'dixel');
        dixel = dixelSet(dixel, 'pixelsizeinmmonly', dpi2mperdot(dpi,'mm'));

        spd   = dixelGet(dixel,'spd'); sFactor = 2.5*sum(spd(2,:))/size(spd,2);
        spd   = [spd; ones(1,size(spd,2))*sFactor];
        spd(4, 1:10) = 0;

        names = cell(1,4);
        for ii=1:4, names{ii} = rgbOrder(ii); end

        gam   = dixelGet(dixel,'gam'); gam{4} = gam{3};

        % Adjust the dixel default properties
        dixel = dixelSet(dixel,'NameOfPrimaries', names);
        dixel = dixelSet(dixel,'gam', gam);
        dixel = dixelSet(dixel,'spd', spd);

        % Lets keeps info on pixel and sub-pixel numbers correct
        dixel = dixelSet(dixel, 'NumberOfPixelsPerBlockX', 1);
        dixel = dixelSet(dixel, 'NumberOfPixelsPerBlockY', 1);

        % MIKE: Extend to list overscaling values for other display types
        dixel = dixelSet(dixel, 'SubpixelOverscaleX', 4);
        dixel = dixelSet(dixel, 'SubpixelOverscaleY', 1);

        dixel = dixelSet(dixel, 'Power Consumption Per Subpixel', [9 9 24 8]);  % RGBY

        vd    = vDisplaySet(vd,'name', dspType);
        vd    = vDisplaySet(vd,'dixel', dixel);
        
        % Set input image raw data to the right size
        img    = ones(4,4,4);
        vd     = vDisplaySet(vd,'InputImage',img);


    case {'rgbw2x2','wbgr2x2'}
        % Four sub-pixels and four primaries in a 2x2 arrangement.
        % Four color display with a white pixel.
        % The ordering is specified in the rgbOrder (4th parameter) or in
        % the dspType argument itself
        if ~isempty(varargin), dpi = varargin{1}; else dpi = 72; end
        if length(varargin) > 1, dSpacing = varargin{2}; else dSpacing = 0.010; end
        if length(varargin) > 2, dir = varargin{3}; else dir = 'v'; end
        if length(varargin) > 3, rgbOrder = varargin{4};
        else rgbOrder = lower(dspType); end
        
        % Do we use DPI to calc dixel width and height, or do have
        % explicit values for width and height?
        if length(varargin) > 5
            dixelWidth = varargin{5};
            dixelHeight = varargin{6};
        else
            dixelWidth = dpi2mperdot(dpi,'mm');
            dixelHeight = dpi2mperdot(dpi,'mm');
        end

        vd = createDisplay(vd, '2x2', [], dSpacing, dir, rgbOrder, dixelWidth, dixelHeight);
        
        dixel = vDisplayGet(vd, 'dixel');

        spd   = dixelGet(dixel,'spd');
        sFactor = 2.5*sum(spd(2,:))/size(spd,2);
        spd   = [spd; ones(1,size(spd,2))*sFactor];
  
        names = cell(1,4);
        for ii=1:4, names{ii} = rgbOrder(ii); end

        gam   = dixelGet(dixel,'gam'); gam{4} = gam{3};

        % Adjust the dixel default properties
        dixel = dixelSet(dixel, 'NameOfPrimaries', names);
        dixel = dixelSet(dixel, 'gam', gam);
        dixel = dixelSet(dixel, 'spd', spd);

        % Lets keeps info on pixel and sub-pixel numbers correct
        dixel = dixelSet(dixel, 'NumberOfPixelsPerBlockX', 1);
        dixel = dixelSet(dixel, 'NumberOfPixelsPerBlockY', 1);

        % Overscaling is orientation independent
        dixel = dixelSet(dixel, 'SubpixelOverscaleX', 2);
        dixel = dixelSet(dixel, 'SubpixelOverscaleY', 2);

        % Set power consumption of each subpixel in microWatts, see LCD
        % display above for more details
        if strcmp(rgbOrder, 'rgbw2x2') == 1
            powerPerSubpixel = [9 9 24 15]; % RGBW
        else
            powerPerSubpixel = [15 24 9 9];    % WBGR
        end

        dixel = dixelSet(dixel, 'Power Consumption Per Subpixel', powerPerSubpixel); 

        vd    = vDisplaySet(vd,'name', upper(dspType));
        vd    = vDisplaySet(vd, 'dixel', dixel);
        
        % Set input image raw data to the right size
        img    = ones(4,4,4);
        vd     = vDisplaySet(vd, 'InputImage', img);

        
    case {'l6w'}
        % Eight sub-pixels, four primaries.
        % We think of the pattern as pixel types [A,B,A,B] on every row A
        % is 2x2 RG/BW and the second is BW/RG. In the future, we will
        % allow the ordering to be specified by the rgbOrder parameter.
        %
        % dSpacing is sample spacing of the psf representation.
        % This and other sizes are in mm
        if ~isempty(varargin), dpi = varargin{1}; else dpi = 72; end
        if length(varargin) > 1, dSpacing = varargin{2}; else dSpacing = 0.010; end
        if length(varargin) > 2, dir = varargin{3}; else dir = 'v'; end
        if length(varargin) > 3, rgbOrder = varargin{4};
        else rgbOrder = lower(dspType); end
        
        % Do we use DPI to calc dixel width and height, or do have
        % explicit values for width and height?
        if length(varargin) > 5
            dixelWidth = varargin{5};
            dixelHeight = varargin{6};
        else
            dixelWidth = dpi2mperdot(dpi,'mm');
            dixelHeight = dpi2mperdot(dpi,'mm');
        end

        vd = createDisplay(vd, 'l6w', [], dSpacing, dir, rgbOrder, dixelWidth, dixelHeight);

        dixel = vDisplayGet(vd, 'dixel');

        spd   = dixelGet(dixel,'spd');
        sFactor = 2.5*sum(spd(2,:))/size(spd,2);
        spd   = [spd; ones(1,size(spd,2))*sFactor];
  
        names = {'r', 'g', 'b', 'w'};

        gam   = dixelGet(dixel,'gam'); gam{4} = gam{3};

        % Adjust the dixel default properties
        dixel = dixelSet(dixel, 'NameOfPrimaries', names);
        dixel = dixelSet(dixel, 'gam', gam);
        dixel = dixelSet(dixel, 'spd', spd);
        
        % Lets keeps info on pixel and sub-pixel numbers correct
        dixel = dixelSet(dixel, 'NumberOfPixelsPerBlockX', 1);
        dixel = dixelSet(dixel, 'NumberOfPixelsPerBlockY', 1);

        % Overscaling is orientation independent
        dixel = dixelSet(dixel, 'SubpixelOverscaleX', 4);
        dixel = dixelSet(dixel, 'SubpixelOverscaleY', 2);

        % Set power consumption of each subpixel in microWatts, see LCD
        % display above for more details
        powerPerSubpixel = [9 9 24 15 24 15 9 9]; % RGBW, BWRG (TODO: Check order matches subpixel order)
        dixel = dixelSet(dixel, 'Power Consumption Per Subpixel', powerPerSubpixel); 

        vd    = vDisplaySet(vd,'name', upper(dspType));
        vd    = vDisplaySet(vd, 'dixel', dixel);
        
        % Set input image raw data to the right size
        img    = ones(4,4,8);
        vd     = vDisplaySet(vd, 'InputImage', img);
 
        
    case {'rgbgquad'}
        % 4 sub-pixels and 3 primaries in a 2x2 arrangement.
        if ~isempty(varargin), dpi = varargin{1}; else dpi = 72; end
        if length(varargin) > 1, dSpacing = varargin{2}; else dSpacing = 10; end
        if length(varargin) > 2, dir = varargin{3}; else dir = 'v'; end
        if length(varargin) > 3, rgbOrder = varargin{4};
        else rgbOrder = lower(dspType); end

        % Do we use DPI to calc dixel width and height, or do have have
        % explicit values for width and height?
        if length(varargin) > 5
            dixelWidth = varargin{5};
            dixelHeight = varargin{6};
        else
            dixelWidth = dpi2mperdot(dpi,'mm');
            dixelHeight = dpi2mperdot(dpi,'mm');
        end

        vd = createDisplay(vd, '2x2RGBG', [], dSpacing, dir, rgbOrder, dixelWidth, dixelHeight);
        
        dixel = vDisplayGet(vd, 'dixel');

        spd   = dixelGet(dixel,'spd');
        spd(2, :)   = spd(2, :) / 2;
  
        names = cell(1,4);
        for ii=1:4, names{ii} = rgbOrder(ii); end

        gam   = dixelGet(dixel,'gam'); gam{4} = gam{2};

        % Adjust the dixel default properties
        dixel = dixelSet(dixel, 'NameOfPrimaries', names);
        dixel = dixelSet(dixel, 'gam', gam);
        dixel = dixelSet(dixel, 'spd', spd);

        % Lets keeps info on pixel and sub-pixel numbers correct
        dixel = dixelSet(dixel, 'NumberOfPixelsPerBlockX', 1);
        dixel = dixelSet(dixel, 'NumberOfPixelsPerBlockY', 1);

        % Overscaling is orientation independent
        dixel = dixelSet(dixel, 'SubpixelOverscaleX', 2);
        dixel = dixelSet(dixel, 'SubpixelOverscaleY', 2);

        % Set power consumption of each subpixel in microWatts, see LCD
        % display above for more details
        powerPerSubpixel = [9 9 9 24]; % RGGBW (TODO: Check order matches subpixel order)
        dixel = dixelSet(dixel, 'Power Consumption Per Subpixel', powerPerSubpixel); 

        vd    = vDisplaySet(vd, 'name', upper(dspType));
        vd    = vDisplaySet(vd, 'dixel', dixel);
        
        % Set input image raw data to the right size
        img    = ones(4,4,4);
        vd     = vDisplaySet(vd, 'InputImage', img);
 
 
     case {'rgbdiag'}
        % 9 sub-pixels and 3 primaries in a 3x3 arrangement.
        if ~isempty(varargin), dpi = varargin{1}; else dpi = 72; end
        if length(varargin) > 1, dSpacing = varargin{2}; else dSpacing = 0.010; end
        if length(varargin) > 2, dir = varargin{3}; else dir = 'v'; end
        if length(varargin) > 3, rgbOrder = varargin{4};
        else rgbOrder = lower(dspType); end
        
        % Do we use DPI to calc dixel width and height, or do have have
        % explicit values for width and height?
        if length(varargin) > 5
            dixelWidth = varargin{5};
            dixelHeight = varargin{6};
        else
            dixelWidth = dpi2mperdot(dpi,'mm');
            dixelHeight = dpi2mperdot(dpi,'mm');
        end

        vd = createDisplay(vd, '3x3RGBDiag', dpi, dSpacing, dir, rgbOrder, dixelWidth, dixelHeight);

        dixel = vDisplayGet(vd, 'dixel');

        names = cell(1,9);
        for ii=1:9, names{ii} = rgbOrder(ii); end

        % Adjust the dixel default properties
        dixel = dixelSet(dixel, 'NameOfPrimaries', names);

        % Lets keeps info on pixel and sub-pixel numbers correct
        dixel = dixelSet(dixel, 'NumberOfPixelsPerBlockX', 1);
        dixel = dixelSet(dixel, 'NumberOfPixelsPerBlockY', 1);

        % Overscaling is orientation independent
        dixel = dixelSet(dixel, 'SubpixelOverscaleX', 3);
        dixel = dixelSet(dixel, 'SubpixelOverscaleY', 3);

        % Set power consumption of each subpixel in microWatts, see LCD
        % display above for more details
        powerPerSubpixel = [9 9 24 24 9 9 9 24 9]; % RGB, BRG, GBR (TODO: Check order matches subpixel order)
        dixel = dixelSet(dixel, 'Power Consumption Per Subpixel', powerPerSubpixel); 

        vd    = vDisplaySet(vd, 'name', upper(dspType));
        vd    = vDisplaySet(vd, 'dixel', dixel);
        
        % Set input image raw data to the right size
        img    = ones(4,4,9);
        vd     = vDisplaySet(vd, 'InputImage', img);


     case {'rgbdeltatriad'}
        % 6 sub-pixels and 3 primaries in a 3x2 arrangement.
        if ~isempty(varargin), dpi = varargin{1}; else dpi = 72; end
        if length(varargin) > 1, dSpacing = varargin{2}; else dSpacing = 0.010; end
        if length(varargin) > 2, dir = varargin{3}; else dir = 'v'; end
        if length(varargin) > 3, rgbOrder = varargin{4};
        else rgbOrder = lower(dspType); end
        
        % Do we use DPI to calc dixel width and height, or do have have
        % explicit values for width and height?
        if length(varargin) > 5
            dixelWidth = varargin{5};
            dixelHeight = varargin{6};
        else
            dixelWidth = dpi2mperdot(dpi,'mm');
            dixelHeight = dpi2mperdot(dpi,'mm');
        end

        vd = createDisplay(vd, '3x2RGBDeltaTriad', [], dSpacing, dir, rgbOrder, dixelWidth, dixelHeight);

        dixel = vDisplayGet(vd, 'dixel');

        names = cell(1,6);
        for ii=1:6, names{ii} = rgbOrder(ii); end

        % Adjust the dixel default properties
        dixel = dixelSet(dixel, 'NameOfPrimaries', names);

        % Lets keeps info on pixel and sub-pixel numbers correct
        dixel = dixelSet(dixel, 'NumberOfPixelsPerBlockX', 1);
        dixel = dixelSet(dixel, 'NumberOfPixelsPerBlockY', 1);

        % Overscaling is orientation independent
        dixel = dixelSet(dixel, 'SubpixelOverscaleX', 3);
        dixel = dixelSet(dixel, 'SubpixelOverscaleY', 2);

        vd    = vDisplaySet(vd, 'name', upper(dspType));
        vd    = vDisplaySet(vd, 'dixel', dixel);

        % Set input image raw data to the right size
        img    = ones(4,4,6);
        vd     = vDisplaySet(vd, 'InputImage', img);

    otherwise
        error('Unknown display type %s\n',dspType);

end

return;

%------------------------------
function vd = displayGaussianCRT(vd,dpi,dSpacing)
%
% Create a display with Gaussian sub-pixel point spreads and a hexagonal
% crt arrangement.

[psfs,spps] = psfGroupCreate('gaussianCRT',dpi,dSpacing);
vd = vDisplaySet(vd, 'PSFStructure', psfs);
vd = vDisplaySet(vd, 'SPPatternStructure', spps);

% Specific dixel width and height in mm
dixelWidth = dpi2mperdot(dpi,'mm');
dixelHeight = dixelWidth;
dixel = vDisplayGet(vd,'dixel');
dixel = dixelSet(dixel, 'pixel size in mm', [dixelWidth,dixelHeight]);
vd = vDisplaySet(vd, 'dixel', dixel);

return;


%-------------------------------
% Create a display with the right resolution, psf, spps, dixeltype
function vd = createDisplay(vd, ditype, dpi, dSpacing, dir, rgbOrder, dixelWidth, dixelHeight)

% Width and height in mm at this point
[psfs,spps,dixelHalfWidth,dixelHalfHeight] = ...
    psfGroupCreate(ditype, dpi, dSpacing, dir, rgbOrder, dixelWidth, dixelHeight);

vd = vDisplaySet(vd, 'Dixel Type', ditype);
vd = vDisplaySet(vd, 'Dixel SubPixelHalfWidth', dixelHalfWidth);
vd = vDisplaySet(vd, 'Dixel SubPixelHalfHeight', dixelHalfHeight);
vd = vDisplaySet(vd, 'Dixel Orientation', dir);
vd = vDisplaySet(vd, 'PSF Structure', psfs);
vd = vDisplaySet(vd, 'SP Pattern Structure', spps);

% Specific dixel width and height in mm
dixel = vDisplayGet(vd,'dixel');
dixel = dixelSet(dixel, 'pixelsizeinmmonly', [dixelWidth]);

vd = vDisplaySet(vd, 'dixel', dixel);

return;


%-----------------------------------
function vd = vDisplayCreateStruct
% Build the basic display structure and fill the slots with default
% variables.
% Some day, we should get the variable names to be something reasonable.
% These names are left over from XD days.

vd.m_strDisplayName='Default';
vd.m_strDisplayType='VirtualDisplay';

%Structure PhysicalDisplay
vd.sPhysicalDisplay.m_objCDixelStructure = dixelCreate;
vd.sPhysicalDisplay.m_fPhysicalViewableDiagonalSize = 20.1; %inch
vd.sPhysicalDisplay.m_fPhysicalViewableAspectRatio = 4/3; %unitless

vd.sPhysicalDisplay.m_fVerticalRefreshRate = 75; %Hz

%Structure ViewingContext
vd.sViewingContext.m_fViewingDistance = 0.6; %meters
vd.sViewingContext.m_fViewingAngleX = 40; %degree
vd.sViewingContext.m_fViewingAngleY = 40; %degree
vd.sViewingContext.m_fRoomAmbientLighting = 0;

%Structure Stimulus
vd.sStimulus.m_aImageRawData = [];  %original dry image data
vd.sStimulus.m_aImageRendered= [];
vd.sStimulus.m_fScalingFactorX=1;
vd.sStimulus.m_fScalingFactorY=1;
vd.sStimulus.m_fVisualAngleX = 1; %degree
vd.sStimulus.m_fVisualAngleY = 1; %degree
vd.sStimulus.m_fImageMeanIntensity = 100; %Luminance: cd/m^2
vd.sStimulus.m_fImageDynamicRange = 25;  % dB
vd.sStimulus.m_fImagePixelSizeX = 0.255; %in mm per pixel
vd.sStimulus.m_fImagePixelSizeY = 0.255; %in mm per pixel

% Use vDisplaySet(vd,'osample',40) for higher resolution.
% This number is OK for faster run speeds.
vd.sStimulus.oSample = 19;      % Number of samples per

return;


