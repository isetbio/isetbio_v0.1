function ctSaveVirtualDisplayImageAsScene(displayGD);
% Convert the virtual display image to an ISET scene
% 
%    ctSaveVirtualDisplayImageAsScene(displayGD)
%   
% To measure display images, we transform the data into an ISET scene and
% use the ISET Scene Window.
%
%
% Wandell, 2006

if ieNotDefined('displayGD'), displayGD = ctGetObject('display'); end
aImageRendered= displayGet(displayGD, 'ImageRendered');
if isempty(aImageRendered), return; end;

[strFileName, strPathName] = uiputfile({'*.mat','MAT-files (*.mat)'}, 'Save as ISET scene file', 'Untitled.mat');
if isequal(strFileName,0) | isequal(strPathName,0)
   return;
else
   nNumberOfPrimaries=displayGet(displayGD, 'NumberOfPrimaries');
   cellWaveSamples=displayGet(displayGD, 'WaveLengthSamples');
   cellPrimarySpectrum=displayGet(displayGD, 'SpectrumOfPrimaries');

   for ii=1:nNumberOfPrimaries
      sBasis.basis(:, ii)=cellPrimarySpectrum{ii}.';
      sBasis.wave=cellWaveSamples{ii};
%TODO: here the mcSaveCoefAndBasis functiond does not consider wavelength samples with different length      
   end;

   %try
       mcSaveCoefAndBasis(strPathName, strFileName, aImageRendered, sBasis,[], ['Generated from vDisplay 1.0 --' sprintf('Date: %s\n',date)]);
   %catch
   %    errordlg('Error in saving files...');
   %    return;
   %end;
end
