function [vDisp,fullName] = ctDisplayLoad(fullName)
% Load a virtual display structure from a file
%
%  [vDisp,fullName] = ctDisplayLoad([fullName])
%
% This loads a virtual display.  It also checks that certain fields have
% been updated in the file.   These are:
%
% oSample:  Oversample factor for display
% psf:      We converted from micron units to millimeters at some point,
%           but not every file was converted.  We check and warn here.
%
% See also: ctDisplaySave
%
%Examples:
%  [vDisplay,fullName] = ctDisplayLoad;
%  vDisplay = ctDisplayLoad(fullName);
%
% (c) PDCSOFT Team 2006

if ieNotDefined('fullName'), fullName = vcSelectDataFile('stayput','r'); end
displayFile = load(fullName,'-mat');

if    isfield(displayFile,'vDisp'),  vDisp = displayFile.vDisp; 
else  error('File does not contain vDisp variable.');
end

% The calibrated data was created for earlier versions of ctToolBox. So
% here we do a bunch of conversion, where we ensure needed fields are
% present for the newer version of ctToolBox

% The oSample field
if ~checkfields(vDisp,'sStimulus','oSample')
    warning('Please update oSample field in %s', fullName);
    vDisp.sStimulus.oSample = 19;
end

% The spatial units in the psf spatial samples (mm rather than microns)
psf = vDisplayGet(vDisp, 'psf');
if max(psf{1}.sCustomData.samp) > 1
    warning('Please adjust spatial sample units from microns to mm in %s\n',fullName);
    for i = 1:length(psf)
        % ctToolBox now uses mm units internally.
        % What did it used to use?  It seems it used to use microns.  So we
        % divide by 1000 to get to millimeters.
        % Here, we convert the psf sCustomData to correct physical units
        psf{i}.sCustomData.samp = ((psf{i}.sCustomData.samp * (1e-3)));
    end
end
vDisp = vDisplaySet(vDisp,'psf',psf);

return;