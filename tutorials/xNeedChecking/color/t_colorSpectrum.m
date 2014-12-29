%% t_colorSpectrum
%
% Apply color methods to render an approximation to the visible spectrum
% 
% PURPOSE: This tutorial uses the color-matching tools we have developed to
% create an image approaching the appearance the rainbow (the spectral
% colors) on your display.
%
% Class:     Psych 221/EE 362 Tutorial:  Spectrum Author:    Wandell
% Purpose:   An example calculation: making a desaturated rainbow. Date:
% 01.12.98 Duration:  20 minutes
%
% 12/29/14  dhb  WORKING ON UPDATING THIS.  NOT QUITE DONE.

%% Initialize
clear; close all;
s_initISET;

%% Get display primaries
%
% Let's suppose that we know the spectral power distributions of your
% monitor's phosphors.  For this example, we will use the SPDs for a sample
% display description provided with isetbio.
displayCalFile = 'LCD-Apple.mat';
d = displayCreate(displayCalFile);
wave = displayGet(d,'wave');
primaries = displayGet(d,'spd primaries');

% Here is a plot of the primaries.
figure;
plot(wave,primaries(:,1),'r', ...
    wave,primaries(:,2),'g', ...
    wave,primaries(:,3),'b');

%% Get color matching functions
%
% We use the CIE XYZ color matching functions for creating calibrated
% signals.  So, we load them first.  The ieReadSpectra function splines
% these to match the passed wavelength sampling.
XYZ = ieReadSpectra('XYZ',wave);

%% Compute color transfomration matrix
%
% We compute the matrix that converts between XYZ values linear intensities
% of the monitor RGB values.  We do this in two steps.  First, we find the
% XYZ values for each of the individual primaries.  The columns of this
% matrix represent the XYZ values of the red, green and blue primaries,
% respectively.  These values should be relatively easy to interpret.
rgb2xyz = XYZ'*primaries

% Invert the rgb2xyz matrix so that we can compute from XYZ back to linear
% RGB values.
%
% Notice that the values of the xyz2rgb matrix contain negative values and
% are difficult to interpret directly. Such is life.
xyz2rgb = inv(rgb2xyz)

%% Get RGB values for the spectrum locus
%
% In principle, we could compute the RGB values of spectral lights now.
% Remember that the XYZ values of each spectral light are contained in the
% rows of the XYZ matrix.  So, we need only to multiply the two matrices as
% in:
rgbSpectrum = xyz2rgb*XYZ';

% This calculation would produce the rgbSpectrum for monochrome lights of
% equal energy.  But, equal energy monochrome lights do not appear equally
% bright.  The brightest part of the spectrum is near 550nm, and the blue
% and red ends are much dimmer (per unit watt).
%
% So, there is one adjustment I would like to make to the spectral colors.
% I would like to display spectral colors that are similar in their
% brightness.  To adjust the overall luminance of the spectral values, I
% will scale the XYZ values of each spectral light by a function that is
% inversely related to its Y value.  Remember that the Y value represents
% luminance is roughly correlated with brightness.  So, if we scale by the
% Y value, we can compensate a bit for brightness differences.
%
% Here is what I propose to use as a scale factor. Adding the 0.4
% stabilizes the scale factor for small values of Y.
Yvalues = XYZ(:,2);
scaleFactors = 1 ./ (Yvalues + 0.4);

% Now, let's scale the rgb values. Pay attention to the fact that I am
% doing this scaling in the linear RGB space.  This calculation would be
% wrong if I did it on the frame buffer values, rather than the linear RGB
% intensities.
rgbSpectrum = rgbSpectrum*diag(scaleFactors);
rgbSpectrum = rgbSpectrum';

% Here is a plot of the scale factors used to make the brightness of the
% wavelengths more nearly equal.
figure;
plot(wave,scaleFactors,'k')
set(gca,'ylim',[0 2]), grid on

% And here is a graph of the R,G and B values we need for each of the
% individual wavelengths when they are presented at equal energy levels.
% The horizontal axis shows wavelength and the three colored curves show
% the linear intensity values needed for the phoshors.
figure;
plot(wave,rgbSpectrum(:,1),'r', ...
    wave,rgbSpectrum(:,2),'g', ...
    wave,rgbSpectrum(:,3),'b')
grid on

%% Those pesky negative values
% As you can see in the figure, some of the RGB values are negative.  These
% are called "out of gamut" and cannot be displayed precisely.  There is no
% getting around this problem either for this example or in many real world
% applications. Some physical colors in the world simply cannot be
% displayed on conventional monitors, with three primaries.  This
% corresponds to the observation that in the color-matching experiment
% sometimes we must move one of the primaries to the other side of the
% field.
%
% There are many different suggestions (hacks) that people use to overcome
% the basic physical limitation of displays.  For our purposes, we can use
% a fairly simple compromise -- some of you may like it, others may not.
% That is the nature of this business.
%
% We can display these rgb values superimposed on a constant gray
% background.  By superimposing the spectrum on a constant background, we
% can both add and subtract RGB values.
%
% We will use a gray background that is only as bright as the
% most negative rgbSpectrum value.
grayLevel = abs(min(rgbSpectrum(:)));
rgbSpectrum = (rgbSpectrum + grayLevel);

% And, we will scale the RGB values in rgbSpectrum so they are as large as
% possible, but the sum of the background and these values will still be
% less than the maximum display value (1).
rgbSpectrum = rgbSpectrum/max(rgbSpectrum(:));

% Here is a plot of the RGB values scaled to be in range
figure 
plot(rgbSpectrum), grid on

%% Display the RGB values.
% Now, we correct for the display nonlinearities by presuming that we know
% something (which we don't) about your display. Here is the display gamma
% function relating a standard monitor frame buffer entries to the display
% intensities.
%
% Here is the function we use to convert the linear values in rgb to the
% frame buffer (DAC) values. The call to displayGet returns a table of the
% non-linearity, and the function ieLUTLinear inverts it to provide the
% desired DAC values.
gTable = displayGet(d,'gamma table');
DAC = ieLUTLinear(rgbSpectrum, ieLUTInvert(gTable));

%% GOT TO HERE.  NEED TO FIGURE OUT HOW ISETBIO INVERTS A DISPLAY LUT AND GET THE SCALE RIGHT.  -DHB

%% Create image for display
waveSamp = 1:2:361;
mp = DAC(waveSamp,:);
wavelengths = 360 + waveSamp;

% Create a linear ramp to show the color map values.
im = 1:size(DAC,1);
mp = DAC/max(DAC(:));
figure;
colormap(mp);
image(im);
image(DAC)

% and show 'em
% 


% Notice that the color start to fade towards the end.  Why do you think
% that is?  Try varying some of the choices I made, such as the scaleFactor
% and the intensity of the gray background.

% Here is a plot of the DAC values we ended up with.
figure;
plot(wavelengths, DAC(waveSamp,1),'-r',...
    wavelengths, DAC(waveSamp,2),'-g',...
    wavelengths,DAC(waveSamp,3),'-b')

% Notice that the overall saturation is quite limited by one part of the
% spectrum.  Perhaps if we didn't try to reproduce just that part of the
% image, or we adjusted just that part, we could obtain a more saturated
% overall appearance. Again, a design decision.

% END TUTORIAL
