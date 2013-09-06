function imageShowImage(vci,gam,trueSizeFlag,figNum)
% Display the image in the processor window.
%
%  imageShowImage(vci, [gam],[trueSizeFlag],[figNum])
%
% The processor data are converted to sRGB for display, using the display
% model in the vci.
%
% The images look a little better when they are rendered with gamma of 0.6.
% Not sure why.
%
% Examples:
%   imageShowImage(vci{3},1/2.2)
%   imageShowImage(vci{3})
%
% Copyright ImagEval Consultants, LLC, 2003.

% TODO
% I am concerned about the ordering of the ^gam and the scale
% operations.  Perhaps scaling should be first, and then the gamma.  As
% things stand, we apply gamma and then scale. 
% I am also unsured why the sRGB doesn't look better.  It looks good in the
% other windows. (BW).

if ieNotDefined('vci'), cla; return;  end
if ieNotDefined('gam'),  gam = 1; end
if ieNotDefined('trueSizeFlag'), trueSizeFlag = 0; end
if ieNotDefined('figNum'),  figNum = ieSessionGet('vcimageFigure'); end

% Bring up the figure
figure(figNum);

% Test and then convert the linear RGB values stored in result to XYZ
img = imageGet(vci,'result');
if isempty(img)
    cla; sprintf('There is no result image in vci.');
    return;
elseif max(img(:)) > imageGet(vci,'dataMax')
    error('Image max %.2f exceeds data max: %.2f\n',max(img(:)),dMax);
end

% Get the xyz data from the image
img = xyz2srgb(imageDataXYZ(vci));

if ndims(img) == 2,       vciType = 'monochrome';
elseif ndims(img) == 3, vciType = 'rgb';
else                    vciType = 'multisensor';
end

switch vciType
    case 'monochrome'
        colormap(gray(256));
        if gam ~= 1, imagesc(img.^(gam));
        else imagesc(img);
        end
    case 'rgb'
        % I am puzzled why we need a gamma when we convert to srgb.
        % But the images do look better with a gamma of 0.6, which is
        % how I set the default rendering.
        if imageGet(vci,'scaleDisplay')
            % Use imagescRGB to render the RGB image.
            %  Prior to display negative values imagescRGB clips
            %  negative value and scales the result to a maximum of 1.
            if gam ~= 1, imagescRGB(img.^(gam));
            else         imagescRGB(img);
            end
            
        else
            % No scaling. There may be some negative numbers or numbers
            % > 1 because of processing noise and saturation + noise.
            img = ieClip(img,0,1);
            if gam ~= 1, image(img.^gam);
            else image(img);
            end
        end
    case 'multisensor'
        error('No display method for multisensor.');
end

axis image; axis off
if trueSizeFlag, truesize; end

return;
