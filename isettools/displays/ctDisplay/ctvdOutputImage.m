function ctvdOutputImage(vd, img, rendered, units)
% Display a VD rendered image with the spatial units
%
%   ctvdOutputImage(vd, [img], [rendered], [units])
%
%   vd - virtual display.
%   img - input image (in case input image is not passed, routine will use
%              display's existing 'input image').
%   rendered - a flag to determine whether input image is already rendered
%              on this vd, or it is needed to be rendered (default).
%   units - spacial units for image display (default = 'mm').
%
% Example:
%
%   This routine can be operated from the "Create Display" window menu
%   (Analyze | Output image (by mm))
%
% Copyright Stanford 2010


if ieNotDefined('units'), units = 'mm'; end
if ieNotDefined('rendered'), rendered = 0; end

if ~rendered
    if ieNotDefined('img')
        img = vdisplayCompute(vd);
    else
        vd = vDisplaySet(vd,'inputimage',img);
        img = vdisplayCompute(vd,'inputimage');
    end
end
img = ctdpRendered2RGB(vd,img);
sampleSpacing = vDisplayGet(vd,'sampleSpacing',units);

imSize = size(img);
x = [0:imSize(1)]*sampleSpacing;
y = [0:imSize(2)]*sampleSpacing;

% Show normalised version of img (image seems to have values above 1.0?)
figure, imagesc(x,y,img / max(max(max(img))));
axis image;
title('Output Image');
xlabel(['Position (' units ')']);
grid on;

return




