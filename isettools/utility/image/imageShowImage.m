function imageShowImage(vci,gam,trueSizeFlag,figNum)
% Display the image in the processor window.
%
%  imageShowImage(vci, [gam],[trueSizeFlag],[figNum])
%
% Examples:
%   imageShowImage(vci,1/2.2)
%
% Copyright ImagEval Consultants, LLC, 2003.

% TODO
% I am concerned about the ordering of the ^gam and the scale
% operations.  Perhaps scaling should be first, and then the gamma.  As
% things stand, we apply gamma and then scale.

if ieNotDefined('vci'), cla; return;  end
if ieNotDefined('gam'),  gam = 1; end
if ieNotDefined('trueSizeFlag'), trueSizeFlag = 0; end
if ieNotDefined('figNum'),  figNum = ieSessionGet('vcimageFigure'); end

figure(figNum);

img = imageGet(vci,'result');  
img = double(img); 


dMax = imageGet(vci,'dataMax');
if isempty(img)
    cla; sprintf('There is no result image in vci.');
    return;
elseif max(img(:)) > imageGet(vci,'dataMax')
    error('Image max %.2f exceeds data max: %.2f\n',max(img(:)),dMax);
end

if ndims(img) == 2,     vciType = 'monochrome';
elseif ndims(img) == 3, vciType = 'rgb';
else                    vciType = 'multisensor';
end

if isempty(gam) || gam == 1
    switch vciType
        case 'monochrome'
            colormap(gray(256)); 
            imagesc(img);
        case 'rgb'
            % The data have gone through the processing pipeline and are in
            % RGB space.
            % The absolute scale is set so that the image maximum is in the
            % same ratio to the peak display output as the sensor data were
            % to the sensor maximum.
            %
            img = img/dMax;  % imtool(img)
            if imageGet(vci,'scaledisplay'), imagescRGB(img);
            else
                img = ieClip(img,0,1);
                image(img);
            end
            
        case 'multisensor'
            error('No display method for multisensor.');
    end
else
    switch vciType 
        case 'monochrome'
            colormap(gray(256));imagesc(img.^gam);
        case 'rgb'           
            if imageGet(vci,'scaleDisplay')
                % Use imagescRGB to render the RGB image.  
                %  Prior to display negative values imagescRGB clips
                %  negative value and scales the result to a maximum of 1.
                imagescRGB(img.^gam);
            else
                % No scaling. There may be some negative numbers or numbers
                % > 1 because of processing noise and saturation + noise.
                img = ieClip(img,0,1);
                image(img.^gam);
            end
        case 'multisensor'
            error('No display method for multisensor.');
    end
end

axis image; axis off
if trueSizeFlag, truesize; end

return;
