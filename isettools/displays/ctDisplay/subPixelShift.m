function simg = subPixelShift(img, shift);
% Shift subpixel image
%
%   shiftImage = subPixelShift( img, shift );
% 
% A pixel image is the input image specified for one of the sub-pixel
% primaries.  For example, if we have the sub-pixel positions and an input
% image, we can compute
%  
%    img = spPos(:,:,ii) .* inputImage(:,:,primary);
%
% Both spPos and inputImage can be obtained via a get() on the virtual
% display.
%
% The shift is (row,col,2) for each pixel in img.  
% So, shift(i,j,1) defines the size of the yShift (row) for pixel i,j.
%

if ieNotDefined('img'), error('img must be defined'); end
if ieNotDefined('shift'), simg = img; return; end

sizeI = size(img);
simg = zeros(sizeI);

% Get the positions of all non-zero pixel in img
[y x] = getIdx( find(img), sizeI );

% Shift each pixel according to the given 'shift' matrix
shft_int = floor( shift );      % The entire sample shift
shft_sub = shift - shft_int;    % The sub sample shift
for k = 1:length(y)
    intensity = img(y(k), x(k) );
    % Reshape the target shift value to a 1x2 array
    s_int = reshape( shft_int( y(k), x(k), : ), 1,2);
    s_sub = reshape( shft_sub( y(k), x(k), : ), 1,2);
    
    % Compute the ... I don't know how to name them.
    s_sub_b = 1 - abs(s_sub);
    U = sign(s_sub) .* ceil( abs(s_sub));
    
    % The interger part of the center of the pixel
    pc = [ y(k), x(k) ] + s_int;
    
    % Compute the weighting of the 4 sample to represent the sub sample shift
    weighting = abs( [ s_sub_b(1) * s_sub_b(2), 
                  s_sub_b(1) * s_sub(2),
                  s_sub(1)   * s_sub(2),
                  s_sub(1)   * s_sub_b(2) ] );
    weighting = intensity * weighting;
	% Assign 4 samples of simg to represent the shifted sample of img
    simg( pc(1)     ,pc(2)      ) = weighting(1) + simg( pc(1)     ,pc(2)      );
    simg( pc(1)     ,pc(2)+U(2) ) = weighting(2) + simg( pc(1)     ,pc(2)+U(2) );
    simg( pc(1)+U(1),pc(2)+U(2) ) = weighting(3) + simg( pc(1)+U(1),pc(2)+U(2) );
    simg( pc(1)+U(1),pc(2)      ) = weighting(4) + simg( pc(1)+U(1),pc(2)      );
end


return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sub Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [y x p] = getIdx(idx, sizeI);
    layer = sizeI(1)*sizeI(2);
    p = ceil( idx / layer );
    x = ceil( mod(idx,layer) / sizeI(1) );
    y = mod(idx, sizeI(1) );

    % Replace any x = 0 and y = 0 by sizeI(2) and sizeI(1)
    y = y + (y==0)*sizeI(1);
    x = x + (x==0)*sizeI(2);
return;