function spPos = subPixPositions(sz,dType,varargin)
%Identify sub-pixel positions for different display models
%
%   spPos = subPixPositions(row,col,dType,varargin)
%
% Each sub-pixel is in some pixels, but it may not be in every pixel.  This
% routine contains the various rules that define the pixels containing a
% sub-pixel for various types of display models.
%
% Valid types so far are
%
%   crt - Defines a hexagonally packed CRT structure
%   X - All ones, for all other displays, lcd, l6w, etc
%
% Example
%   spPos = subPixPositions([4,4,3],'crt',2);
%   spPos = subPixPositions([4,4,3],'crt',5);
%   spPos = subPixPositions([4,4,3],'crt');
%   spPos = subPixPositions([4,4,3],'lcd');
%   spPos = subPixPositions([4,4,8],'l6w');
%
% Note
%   crt has a different layout to all display types, so it has to be
%   treated as a special case. Other display may need a special layout
%   in the future.
%
if ieNotDefined('sz'), error('Image size (row,col) must be defined'); end
if ieNotDefined('dType'), dType = 'lcd'; end

row = sz(1); col = sz(2); sp = sz(3);

switch lower(dType)
    case 'crt'
        r = 1:row;

        % Return just one bed of nails function
        if length(varargin) > 0, subPix = varargin{1};
            spPos = zeros(row,col);
            if subPix < 4, spPos(r,1:2:col) = 1;
            else           spPos(r,2:2:col) = 1;
            end
        else
            % Return all six bed of nails functions
            spPos = zeros(row,col,6);
            
            tmp = zeros(row,col); tmp(r,1:2:col) = 1;
            for ii=1:3, spPos(:,:,ii) = tmp; end
            
            tmp = zeros(row,col); tmp(r,2:2:col) = 1;
            for ii=4:6, spPos(:,:,ii) = tmp; end
        end

    otherwise
        spPos = ones(row,col,sp);

end

return;