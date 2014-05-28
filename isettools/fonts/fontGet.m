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
        
    otherwise
        disp(['Unknown parameter: ',parm]);
        
 end

return;
