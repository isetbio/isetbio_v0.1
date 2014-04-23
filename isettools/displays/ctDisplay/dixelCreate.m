function s = dixelCreate(varargin)
% dixelCreate (display pixel) constructor
%
%    s = dixelCreate(varargin)
%
% When called in various ways, this constructor returns a display
% pixel (dixel) structure.
%
% There is a notion of a block as well as a dixel.  I don't understand that
% yet, and there aren't enough comments about that.  So let's fix it here.
% BW
%
%
%    No Parameters - Default dixel, a Gaussian in a CRT mode, 4mm pixel.
%                   (Should change default.)
%    Dixel object -  Copy constructor
%    'parameter',value pair:  Default with that parameter set to value
%
% Dixel parameters that can be adjusted by set(dixelCreate) can be
% used in the (parameter,value) pairs.
%
% Examples:
%  dixel = dixelCreate;        %Default (Gaussian)
%  dixel = dixelCreate(d);     %Copy
%  dixel = dixelCreate('PixelSizeInMmX',0.2978,'PixelSizeInMmY',0.2978);
%  get(dixel,'PixelSizeInMmX')
%
% Parameters - Created by default
%         s.m_fPixelSizeInMmX
%         s.m_fPixelSizeInMmY
%
%         s.m_fSubPixelFillFactorX
%         s.m_fSubPixelFillFactorY
%
%         s.m_cellNameOfPrimaries
%
%         nPrimaries
%         s.m_aSpectrumOfPrimaries
%         s.m_aWaveLengthSamples
%         s.m_aColorOfPrimaries
%
%         s.m_cellPSFStructure
%
%         s.m_cellSPPatternStructure = spps;
%         s.m_nNumberOfSubPixelsPerBlock=6;
%         s.m_nNumberOfPixelsPerBlockX=2;
%         s.m_nNumberOfPixelsPerBlockY=1;
%         s.m_cellGammaStructure - cell array
%
%
% (c) Stanford, PDCSOFT, Wandell, 2006

% TODO:
%  Re-write the constructor to call the set() instead of repeating the
%  functions here.  Also, we should have a unique set of dixel values that
%  we set.  We should not have to use the refreshStructure method.  Try to
%  do this when we have time.
%
%  Fix the load crtSPD.mat call below


% Normally we have a lower() call on the varagin
% There isn't one here.  We should edit it in so that the calls are not
% case-sensitive

switch nargin
    case 1
        % Just returns the argument, checking that it is a struct
        if isstruct(varargin{1}), s = varargin{1};
        else                      error('Wrong argument type');
        end;

    otherwise
        % Create the default dixel. Should really be a sub-function and
        % then we prepare for other types.  Maybe dixelCreateDefault();
        %

        % Should be deleted in the end. ??? Hunh ???
        s.m_fPixelSizeInMmX = 0.4;  %0.4mm
        s.m_fPixelSizeInMmY = 0.4;  %0.4mm

        s.m_fSubPixelFillFactorX = 100; %100%
        s.m_fSubPixelFillFactorY = 100; %100%

        %Let's use 'lower' to avoid case issues.
        s.m_cellNameOfPrimaries = {'Red', 'Green', 'Blue'};

        % I guess the default PSF is currently a CRT.
        % Maybe it should be the NEC LCD, though.
        % This should be a more specific call.  FIX THIS (BW).
%        tmp = load('crt-Dell.mat');       % OLD - Up to ISET revision 624
%        data = tmp.data';               % OLD
%        wavelength = tmp.wavelength;    % OLD
%        s.m_aSpectrumOfPrimaries= data; % OLD
        
        %
        %Should be m x n array, where m is the
        %number of primaries, and n should be number of wavelength samples

        tmp = load('crt.mat');                     % NEW - For ISET revision 625+
        wavelength = tmp.d.wave;                   % NEW
        s.m_aSpectrumOfPrimaries = tmp.d.spd';     % NEW

        s.m_aWaveLengthSamples  = wavelength;

        s.m_aColorOfPrimaries = [1 0 0;
            0 1 0;
            0 0 1];

        % Default dixel has a Gaussian.  But when we open the window the
        % default is the NEC LCD. Ugh.
        [psfs,spps] = psfGroupCreate('gaussianCRT');
        s.m_cellPSFStructure = psfs;

        % To accomodate the general case of handling arbitrary
        %subpixel block patterns, we distinguish 'Primaries' and
        %'Sub-Pixels'. There might be more 'Sub-Pixels' than the
        %'Primaries', each subpixel associated with a primary.
        s.m_cellSPPatternStructure = spps;

        s.m_nNumberOfSubPixelsPerBlock=6;

        %In order to be able to allow a pattern block to contain multiple
        %pixels, we have to specify the number of pixels per block in
        %horizontal and vertical directions.
        s.m_nNumberOfPixelsPerBlockX = 2;
        s.m_nNumberOfPixelsPerBlockY = 1;
        
        % By default dixel are to laid out side by side, not overlaid (0) -
        % overlaid = 1
        s.m_boundeddixel = 0;

        nPrimaries = length(s.m_cellNameOfPrimaries);
        for ii=1:nPrimaries, s.m_cellGammaStructure{ii}=gammaCreate; end
        
        % With arbitrary values we want the overscaling infor for each
        % subpixel group (unit in subblock)
        s.m_nSubpixelOverscaleX = 3;
        s.m_nSubpixelOverscaleY = 1;
        
end

%% Fill in fields specified in varargin, over-riding the default.
if nargin >0
    if rem(nargin,2) == 0
        for i=1:2:nargin
            switch ieParamFormat(varargin{i})
                case 'numberofprimaries'
                    N = round(varargin{i+1});
                    if ~isscalar(varargin{i+1}) || ~isa(varargin{i+1}, 'double') || N<1
                        error('Wrong ''NumberOfPrimaries'' property value, should be a double scalar >= 1');
                    end;
                    %s=RefreshStructure(s, N);
                case 'pixelsizeinmmx'
                    if ~isscalar(varargin{i+1}) || ~isa(varargin{i+1}, 'double') || varargin{i+1}<=0
                        error('Wrong ''PixelSizeInMmX'' property value, should be a double scalar > 0');
                    end;
                    s.m_fPixelSizeInMmX = varargin{i+1};
                case 'pixelsizeinmmy'
                    if ~isscalar(varargin{i+1}) || ~isa(varargin{i+1}, 'double') || varargin{i+1}<=0
                        error('Wrong ''PixelSizeInMmY'' property value, should be a double scalar > 0');
                    end;
                    s.m_fPixelSizeInMmY = varargin{i+1};
                case {'nameofprimaries','primarynames'}
                    N= length(varargin{i+1});
                    cellTemp=varargin{i+1};
                    if ~iscell(cellTemp) || numel(cellTemp)~=N || ~iscellstr(cellTemp)
                        error('Wrong ''NameOfPrimaries'' property value, should be a cell vector of strings');
                    end;
                    %s=RefreshStructure(s, N);
                    for ii=1:N
                        strTemp=cellTemp{ii};
                        strTemp=[upper(strTemp(1)) lower(strTemp(2:end))];
                        s.m_cellNameOfPrimaries{ii} = strTemp;
                    end;
                case {'wavelengthsamples','wave','wavelength'}
                    aTemp=varargin{i+1};
                    s.m_aWaveLengthSamples=aTemp;
                case {'spectrumofprimaries','primaryspd'}
                    aTemp=varargin{i+1};
                    s.m_aSpectrumOfPrimaries = aTemp;
                case {'colorofprimaries','primarycolors','primarycolornames'}
                    %These are just nominal colors used for drawing
                    %markers/colored lines in plots; they are not accurate
                    %colors. Here we check if they are between [0, 1].
                    %Should be 2D matrix, the row represents primaries...
                    %
                    if numel(varargin{i+1})~=size(varargin{i+1}, 1)*size(varargin{i+1}, 2) ...
                            || ~isa(varargin{i+1}, 'double') ...
                            || ~isempty(find(varargin{i+1}>1, 1)) ...
                            || ~isempty(find(varargin{i+1}<0, 1))
                        error('Wrong ''ColorOfPrimaries'' property value, should be a 2D array of double in [0, 1]');
                    end;
                    s.m_aColorOfPrimaries = varargin{i+1};

                case {'gammastructure','gamstruct'}
                    %Should be an m x 1 cell array, where m
                    %is the number of primaries. Each element is a
                    %structure
                    %Maybe we should do more thorough error check?
                    cellTemp = varargin{i+1};
                    if numel(cellTemp)~=size(cellTemp, 1)*size(cellTemp, 2) ...
                            || ~iscell(cellTemp)
                        error('Wrong ''GammaStructure'' property value, should be a m x 1 cell array of structures representing gamma');
                    end;
                    s.m_cellGammaStructure=cellTemp;

                case {'psfstructure','psfstruct'}
                    %Should be an m x 1 cell array, where m
                    %is the number of primaries. Each element is a
                    %structure
                    %Maybe I should do more robust error check?
                    cellTemp=varargin{i+1};
                    if numel(cellTemp)~=size(cellTemp, 1)*size(cellTemp, 2) ...
                            || ~iscell(cellTemp)
                        error('Wrong ''PSFStructure'' property value, should be a m x 1 cell array of structures representing PSF');
                    end;
                    s.m_cellPSFStructure=cellTemp;

                case {'numberofsubpixelsperblock','nsubpixperblock'}

                    N = round(varargin{i+1});
                    if ~isscalar(varargin{i+1}) || ~isa(varargin{i+1}, 'double') || N<1
                        error('Wrong ''NumberOfSubPixelsPerBlock'' property value, should be a double scalar >= 1');
                    end;
                    %s=RefreshStructure1(s, N);

                case {'sppatternstructure','spps'}
                    %Should be an m x 1 cell array, where m
                    %is the number of primaries. Each element is a
                    %structure
                    %Maybe I should do more robust error check?
                    cellTemp=varargin{i+1};
                    if numel(cellTemp)~=size(cellTemp, 1)*size(cellTemp, 2) ...
                            || ~iscell(cellTemp)
                        error('Wrong ''PSFStructure'' property value, should be a m x 1 cell array of structures representing PSF');
                    end
                    s.m_cellSPPatternStructure=cellTemp;

                case {'numberofpixelsperblockx','npixperblockx'}
                    N = round(varargin{i+1});
                    if ~isscalar(varargin{i+1}) || ~isa(varargin{i+1}, 'double') || N<1
                        error('Wrong ''NumberOfPixelsPerBlockX'' property value, should be a double scalar >= 1');
                    end;
                    s.m_nNumberOfPixelsPerBlockX=N;

                case {'numberofpixelsperblocky','npixperblocky'}
                    N = round(varargin{i+1});
                    if ~isscalar(varargin{i+1}) || ~isa(varargin{i+1}, 'double') || N<1
                        error('Wrong ''NumberOfPixelsPerBlockY'' property value, should be a double scalar >= 1');
                    end;
                    s.m_nNumberOfPixelsPerBlockY=N;


                otherwise
                    error('Wrong properties');
            end;
        end;
    else
        error('Wrong number of arguments');
    end;
end;

return




