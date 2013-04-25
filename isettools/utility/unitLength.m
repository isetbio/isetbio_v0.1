function u = unitLength(v)
% Convert vectors in the rows of v to unit length in rows of u
%
%  u = unitLength(v)
%
% Assuming v is a matrix, we set the length of each row of v to be unit
% length.
%
% Example:
%   v = randn(8,8);
%   u = unitLength(v);
%   diag(u*u')
%
% (c) Imageval Consulting, LLC 2012

% Programming TODO:  Optimize this function for speed.
% Look at Kendrick's unitlength function for ideas.

% In the future we will add a parameter, dim = 1 through n to define which
% dimension we want to be unit length. For now,

% Make sure vectors are returned with same shape.
reshapeFlag = 0;

% Make sure a vector is a row vector.
[r,c] = size(v); 
if c==1, v = v(:)'; reshapeFlag = 1; end

u = diag(1./sqrt(diag(v*v')))*v;

if reshapeFlag, u = reshape(u,r,c); end

end

