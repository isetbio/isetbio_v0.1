function val = fontGet(font,parm,varargin)
%Get font parameters and derived properties 
%
%     val = fontGet(font,parm,varargin)
%
%
% (HJ/BW)  PDCSoft Team, 2014.

if ~exist('parm','var') || isempty(parm), error('Parameter must be defined.'); end

% Default is empty when the parameter is not yet defined.
val = [];

parm = ieParamFormat(parm);

switch parm
    
    % Book keeping
    case 'type'
        val = font.type;
    case 'name'
        val = font.name;

    case 'character'
        val = font.character;
    case 'size'
        val = font.size;
    case 'family'
        val = font.family;
    case 'style'
        val = font.style;
    case 'dpi'
        val = font.dpi;
    case 'bitmap'
        val = font.bitmap;
        
    % Derived
    case 'paddedbitmap'
        % fontGet(font,'padded bitmap',padval);
        % vcNewGraphWin; imagesc(fontGet(font,'padded bitmap'));axis equal
        padsize = [7 7]; padval = 1;
        if ~isempty(varargin), padsize = varargin{1}; end
        if length(varargin) > 1, padval = varargin{2}; end
        
        % RGB bitmap
        bitmap = fontGet(font,'bitmap');
        
        % Pad and return
        newSize = size(bitmap); 
        newSize(1:2) = newSize(1:2) + 2*padsize;
        val = zeros(newSize);        
        for ii=1:size(bitmap,3);
            val(:,:,ii) = padarray(bitmap(:,:,ii),padsize,padval);
        end
        
        
    otherwise
        disp(['Unknown parameter: ',parm]);
        
 end

return;
