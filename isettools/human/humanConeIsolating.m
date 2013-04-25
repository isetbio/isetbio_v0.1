function [coneIsolating,monitor2cones,wave] = humanConeIsolating(monitorFile,wave,cones)
%Determine the monitor color directions (R,G,B) to isolate a cone signal
%
%   [coneIsolating,monitor2cones,wave] = humanConeIsolating(monitorFile,wave,cones)
%
%  This routine calculates the monitor color directions TGB that produce a
%  cone isolating signal for the Stockman L,M and S-cones and a display
%  monitor described in monitorFile. These RGB values are returned as the
%  columns of the 3x3 matrix, coneIsolating. The inverse matrix, mapping
%  from monitor values into LMS space, is given in monitor2cones.
%
%  The units used in these calculations are designed around the normalized
%  RGB values from the monitor space.  Hence, the LMS values are not in
%  physical coordinates (e.g., absorptions).  More information is needed to
%  calculate absorption rate, and this is done using the rest of the
%  simulation code.  The display spectral power distribution of the monitor
%  should be in units of watts/sr/... 
%
% Example:
%   signalDirs = humanConeIsolating('newsomeLabMonitor')
%
%   [monitor,wave] = ieReadSpectra('newsomeLabMonitor');
%   cones = humanCones('stockmanAbs',wave,0.35,0.35);
%   [signalDirs, monitor2cones] = humanConeIsolating('newsomeLabMonitor',wave,cones);
%
% Copyright ImagEval Consultants, LLC, 2005.

if ieNotDefined('monitorFile'), monitorFile = vcSelectDataFile('displays');  end

if ieNotDefined('wave'),        [monitor,wave] = ieReadSpectra(monitorFile); 
else                            monitor = ieReadSpectra(monitorFile,wave); 
end

if ieNotDefined('cones'), cones = ieReadSpectra('stockmanAbs',wave); end

monitor2cones = cones'*monitor;
cones2monitor = inv(monitor2cones);

coneIsolatingSPD = monitor*cones2monitor;
coneIsolating = cones2monitor;

return;





