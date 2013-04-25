function [u,v] = XYZ2uv(xyz)
% Convert CIE XYZ to uv chromaticity coordinates
%
%   [u,v] = XYZ2uv(xyz)
%
% Convert XYZ to u,v chromaticity coordinates (uniform chromaticity space).
% 
% References See (e.g.) Wyszecki and Stiles, 2cd, page 165.
%  
%   X+Y+Z=0 is returned as u=v=0.
%
% Example:
%  XYZ = [3 4 5]'; 
%  [u,v] = XYZ2uv(XYZ')
%
% Copyright ImagEval Consultants, LLC, 2003.

if ieNotDefined('xyz'), error('XYZ values required'); end
if size(xyz,2) ~= 3, error('XYZ should be n x 3'); end

% Now compute uprime and vprime.  These are the pre-cursors to ustar and
% vstar.  The columns of xyz are X,Y and Z respectively.
B = (xyz(:,1) + 15*xyz(:,2) + 3*xyz(:,3));

u = zeros(size(xyz,1),1);
v = zeros(size(u));

% Whenever B is valid, we set the u,v values to something legitimate. I am
% not sure what they should be when X+Y+Z is zero, as above.  For now, we
% are leaving them as zero.
nz = (B>0);
u(nz) = 4*xyz(nz,1) ./ B(nz); 
v(nz) = 9*xyz(nz,2) ./ B(nz); 

return;