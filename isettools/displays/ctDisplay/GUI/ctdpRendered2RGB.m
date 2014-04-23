function imgRendered = ctdpRendered2RGB(vd,imgRendered, cbType)
% Transform the primary rendered image to an RGB image for display
%
%    imgRendered = ctdpRendered2RGB(vd,imgRendered)
%
% The rendered image is coded in terms of the display primaries.  When
% there are only three primaries, the rendered image is the same as the one
% we display.  But when there are four or more primaries then we need to
% transform the data to RGB format.  
%
% Further, this routine scales the RGB output so that a white pixel plots
% with the maximum R,G,B values on the user's display.  Without this color
% balancing, the white pixel can appear colored because, say, the color
% balance of the simulated display is shaded to green or blue or something.
% Possibly, we should be able to turn off this color balancing (which was
% only implemented in May, 2008).
%
% Example:
%   displayGD = ctGetObject('displayGD');
%   imgRendered = ctdpRendered2RGB(displayGet(displayGD,'currentDisplay'));
%   imtool(imgRendered)
%
% Wandell, 2006

if ieNotDefined('vd'), error('Must define virtual display'); end
if ieNotDefined('imgRendered'), 
    imgRendered = vDisplayGet(vd,'outputimage'); 
end
% Do we need to draw this on-screen with simulated colorblindness?
if ieNotDefined('cbType'), cbType = 0; end

% Build the spectral power distribution at each pixel so we can
% render it the right color.
% spd   = vDisplayGet(vd,'spd');
spd   = vDisplayGet(vd,'spectrumofprimaries');       % Get the SPDs back in an order based on the primary order
wList = vDisplayGet(vd,'wave');
primaries= vDisplayGet(vd, 'spps primarylist');

t = spd(primaries,:);

imSPD = imageLinearTransform(imgRendered,t);

% Create an RGB image that is roughly colored like the SPD suggests
% We should check if there is a gam or displayFlag option we should send
% in. This used to be imageSPDRGB, but that was deprecated in ISET.
imgRendered     = imageSPD(imSPD,wList,[],[],[],-1);

% Color balance the RGB pixel so that white appears white on the user's
% display.
wht = sum(spd);
wht = XW2RGBFormat(wht,1,1);
whitePixel = imageSPD(wht,wList,[],[],[],-1);  % Used to be imageSPDRGB
for ii=1:3
    imgRendered(:,:,ii) =  imgRendered(:,:,ii)/whitePixel(1,1,ii);
end

% Older code before change from imageSPDRGB to imageSPD
% imgRendered = imgRendered * diag(1 ./ whitePixel); 
% imgRendered     = XW2RGBFormat(imgRendered,r,c);

% We have the image rendered as RGB for a color normal.  We want to
% convert the RGB to a version as it appears to a dichromat.  This
% might be a routine, say rgb2rgb(rgb,cbType);
if(cbType ~= 0)     % Color dichromacy
    whiteXYZ = vDisplayGet(vd,'white xyz');
    imgRendered = lms2srgb(xyz2lms(srgb2xyz(imgRendered),cbType,whiteXYZ));
end

return;