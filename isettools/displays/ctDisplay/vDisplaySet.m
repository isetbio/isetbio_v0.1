function vd = vDisplaySet(vd, varargin)
% Set function for virtual display
%
%    vd = vDisplaySet(vd, varargin)
%    vd = vDisplaySet(vd,param,val,...)
%
% The input, vd, is a virtual display structure, say created by
%   vd = vDisplayCreate.
%
% The input arguments should be in the form of (parameter, value).
%
% When a parameter is not in the vDisplay, we check to see if it is in the
% dixel and try to set it there. This routine should be used to set dixel
% properties, rather than dixelSet.
%
% See also: vDisplayGet
%
% Example:
%   vd = vDisplayCreate;
%   vd = vDisplaySet(vd,'VerticalRefreshRate',60);
%   vDisplaySet(vd)
%
% There are many parameters in the dixel not shown here. We need to update
% the code comments here.
%
% Parameters -
%  'DisplayType'
%
% Display properties
%  'DixelStructure'
%  'PhysicalViewableDiagonalSize'
%  'PhysicalViewableAspectRatio'
%  'VerticalRefreshRate'
%  'DisplayMeanIntensity'
%  'DisplayDynamicRange'
%
% Viewing Context
%  'ViewingDistance'
%  'ViewingAngleX'
%  'ViewingAngleY'
%  'RoomAmbientLighting'
%
% Image data
%  'inputImage'
%  'outputImage'
%  'scaleX'
%  'scaleY'
%  'renderoversampling'
%
% ???
%  'ImagePixelSizeX'
%  'ImagePixelSizeY'
%
% Original comments.  These should be incorporated above when understood.
% -- BW
%
%  'Display Type'
%    1. Physical Display:
%      - CDixelStructure (including SPDs and number of primaries)
%      - Physical Diagonal Viewable Size (inch)
%      - Physical Viewable Aspect Ratio (4:3 or 16:9)
%      - Physical Pixel Aspect Ratio (the aspect ratio of a
%        pixel, this can be derived from the above parameters, mostly 1:1)
%      - Physical Horizontal Viewable Size (inch)
%     - Physical Vertical Viewable Size (inch) (these
%     two parameters can be derived from the Diagonal
%     Size and Physical Aspect Ratio...)
%      - Horizontal Display Size in Pixels
%      - Vertical Display Size in pixels (these two
%       parameters can be derived from the PPI resolution
%       and the physical viewable screen size ...)
%        - Gamma Structure y=g(x), where x is the DAC value, y
%        is the output luminance. See
%        vdCreateDefautGammaRampStructure for details
%         - Frame Flicker Rate: (Hz)
%         - Display Dynamic Range: (Max Luminance/Min Luminance, dB)
%         - Mean Display Intensity: (Luminance: cd/m^2)
%           (these two parameters can be derived from Gamma LUT ... )
%
%   2. Viewing Context:
%     - Viewing Distance (meter)
%     - Horizontal Viewing Angle (degree)
%     - Vertical Viewing Angle (degree)
%     - Room Ambient Lighting: (Radiance: quanta/s/sr^2/m^2)
%
%   3. Stimulus:
%     - Image Data (photons)
%     - Horizontal Visual Angle (degree)
%     - Vertical Visual Angle (degree)
%     - Mean Intensity: (Luminance, cd/m^2)
%     - Dynamic Range: (Max Luminance/Min Luminance, dB)
%
% Outputs:  Return values of the updated/new object;
%
% (c) Stanford, PDCSOFT, Wandell, 2006

% Arguments must be set(s) or set(s,param,val)
if ~isodd(nargin),      error('Wrong number of arguments'); end

% Hmmm, I think this is guaranteed because otherwise why would we be here?
if ~isstruct(vd), error('First argument must be a Display Model structure'); end

if nargin ~= 1
    % The format is vDisplaySet(vd,param,val,param,val ...)
    % So we start with varargin{1}, varargin{2} and loop through them all.
    for ii=1:2:(nargin-1)
        
        param = ieParamFormat(varargin{ii});
        val = varargin{ii + 1};
        
        switch param
            case 'displaytype'
                % VirtualDisplay and ActualDisplay may be options.
                vd.m_strDisplayType = val;
            case {'displayname','name'}
                % VirtualDisplay and ActualDisplay may be options.
                vd.m_strDisplayName = val;

            case 'physicalviewablediagonalsize'
                vd.sPhysicalDisplay.m_fPhysicalViewableDiagonalSize = val;
            case 'physicalviewableaspectratio'
                vd.sPhysicalDisplay.m_fPhysicalViewerAspectRatio = val;
            case 'verticalrefreshrate'
                vd.sPhysicalDisplay.m_fVerticalRefreshRate = val;
            case {'maxluminance','maximumluminance'} % cd/m2
                % This should not be part of stimulus.  And it should be
                % named luminance, not intensity.  Sigh.
                vd.sStimulus.m_fImageMeanIntensity = val;

                % Viewing context
            case 'viewingdistance'  % Meters
                vd.sViewingContext.m_fViewingDistance = val;

            case 'roomambientlighting'
                vd.sViewingContext.m_fRoomAmbientLighting = val;

            case {'inputimage'} %,'imagerawdata'}
                % Raw data is the image before its been converted to RGB
                % space, where each primary still exists as separate layer
                % in matrix
                vd.sStimulus.m_aImageRawData = val;
            case {'outputimage','imagerendered','renderedimage','imagerawdata'}
                vd.sStimulus.m_aImageRenderedOut = val;
            case {'scalex','scalingfactorx'}
                vd.sStimulus.m_fScalingFactorX = val;
            case {'scaley','scalingfactory'}
                vd.sStimulus.m_fScalingFactorY = val;

            case {'renderoversampling', 'osample', 'osampling'}
                % MNOTE: In vDisplayGet osample is now dynamically
                % calculate, this set should be removed or rewritten to
                % account for dynamic calc
                % BW:  Undid. Enforced the val to be a multiple of the
                % number of sub-dixels. The get routine reads this value.
                % vd = vDisplaySet(vd, 'oSample', 21)
                % Note: val is the sampling per sub-pixel
                nSubDixels = vDisplayGet(vd,'nSubDixels');
                val = nSubDixels*ceil(val/nSubDixels);
                vd.sStimulus.oSample = val;

                % Why is there an image pixel size and a dixel pixel size?
                % Dixel properties
            case {'dixel','dixelstructure'}
                vd.sPhysicalDisplay.m_objCDixelStructure = val;

                % I don't understand why these are here.  If we have an
                % image, I think we can compute this, right?
                %             case 'visualanglex'
                %                 vd.sStimuluvd.m_fVisualAngleX = val;
                %             case 'visualangley'
                %                 vd.sStimulus.m_fVisualAngleY = val;

                % Both of these can be computed, shouldn't be here
            case 'imagemeanintensity'
                vd.sStimulus.m_fImageMeanIntensity = val;
            case 'imagedynamicrange'
                vd.sStimulus.m_fImageDynamicRange = val;


            otherwise
                % See if the variable is a dixel property.  If it comes
                % back without an error, you can reattach and return.
                dxl = vDisplayGet(vd,'dixel');
                try
                    dxl = dixelSet(dxl,param,val);
                catch
                    error('Unknown property')
                end
                vd = vDisplaySet(vd,'dixel',dxl);
        end;
    end;

else
    % If only one input, just dump the object
    display(s);
end


return;
