function font = fontCreate(letter,sz,family,dpi)
% Create a font structure
%
% Inputs
%   letter: (Default 'g')
%   sz:     Font size (default = 18)
%   family: Font family (default 'Georgia')
%   dpi:    Dot per inch (default 96)
%
% Example
%   font = fontCreate;
%   font = fontCreate('A',24,'Georgia',96); 
%   vcNewGraphWin; imagesc(font.bitMap);
%
% (BW) Vistasoft group, 2014

%
if ieNotDefined('letter'), letter = 'g'; end
if ieNotDefined('sz'), sz = 18; end
if ieNotDefined('family'), family = 'Georgia'; end
if ieNotDefined('dpi'), dpi = 96; end

font.type       = 'font';
font.character  = letter;
font.size       = sz;
font.family     = family;
font.style      = 'NORMAL';
font.dpi        = dpi;

% Need to make a way to read the cached fonts rather than the method here.
% The dpi will be added and we will read the overscaled (x) fonts.  Then we
% will put them in the display structure, and maybe filter if we decide to.
font.bitMap     = fontBitmapGet(family, sz, letter);
    
return