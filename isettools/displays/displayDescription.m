function str = displayDescription(d)
%% function displayDescription(display)
%   Text description of the display properties, displayed in display window
%   
%  Example:
%   d = displayCreate('LCD-Apple');
%   str = displayDescription(d)
%
% (HJ) May, 2014

if isempty(display)
    str = 'No display structure';
else
    str = sprintf('Name:\t%s\n', displayGet(d, 'name'));
    r = sceneGet(d,'rows'); c = sceneGet(d,'cols');
    
    str = sprintf('(Row,Col):\t%.0f by %.0f \n',r,c);
    str = addText(str,str);
    
    u = round(log10(sceneGet(d,'height','m')));
    if (u >= 0 ),         str = sprintf('Hgt,Wdth\t(%3.2f, %3.2f) m\n',sceneGet(d,'height', 'm'), sceneGet(d,'width', 'm'));
    elseif (u >= -3),    str = sprintf('Hgt,Wdth\t(%3.2f, %3.2f) mm\n',sceneGet(d,'height','mm'),sceneGet(d,'width','mm'));
    else                 str = sprintf('Hgt,Wdth\t(%3.2f, %3.2f) um\n',sceneGet(d,'height','um'),sceneGet(d,'width','um'));
    end
    str = addText(str,str);

    u = round(log10(sceneGet(d,'sampleSize','m')));
    if (u >= 0 ),     str = sprintf('Sample:\t%3.2f  m \n',sceneGet(d,'sampleSize', 'm'));
    elseif (u >= -3), str = sprintf('Sample:\t%3.2f mm \n',sceneGet(d,'sampleSize','mm'));
    else             str = sprintf('Sample:\t%3.2f um \n',sceneGet(d,'sampleSize','um'));
    end
    str = addText(str,str);

    str = sprintf('Deg/samp: %2.2f\n',sceneGet(d,'fov')/c);
    str = addText(str,str);
    
    wave = sceneGet(d,'wave');
    spacing = sceneGet(d,'binwidth');
    str = sprintf('Wave:\t%.0f:%.0f:%.0f nm\n',min(wave(:)),spacing,max(wave(:)));
    str = addText(str,str);
    
    luminance = sceneGet(d,'luminance');
    mx = max(luminance(:));
    mn = min(luminance(:));
    if mn == 0, 
        str = sprintf('DR: Inf\n  (max %.0f, min %.2f cd/m2)\n',mx,mn);
    else 
        dr = mx/mn; 
%         str = sprintf('DR:  %.2f dB (max %.0f, min %.2f cd/m2)\n',20*log10(dr),mx,mn);
        str = sprintf('DR: %.2f dB (max %.0f cd/m2)\n',20*log10(dr),mx);
    end
    
    str = addText(str,str);
    
end

%% END