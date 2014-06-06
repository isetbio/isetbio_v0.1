function [uData, g] = displayPlot(d,param,varargin)
% Gateway routine for plotting display structure
%
%   [uData, g] = displayPlot(d,param,varargin)
%
% Example:
%  d = displayCreate('CRT-Dell');
%  displayPlot(d,'gamut');
%  
%  displayPlot(d,'spd')
%
%  d = displayCreate('crt');
%  displayPlot(d,'gamma table')
%
% (c) Imageval Consulting, 2013

if notDefined('d'), error('Display required'); end

param = ieParamFormat(param);

switch param
    case 'spd'
        spd = displayGet(d,'spd primaries');
        wave = displayGet(d,'wave');
        g = vcNewGraphWin;
        cOrder = {'r','g','b','k','y'};
        hold on
        for ii=1:size(spd,2)
            plot(wave,spd(:,ii),cOrder{ii});
        end
        
        xlabel('Wavelength (nm)');ylabel('Energy (watts/sr/m2/nm)');
        grid on; uData.wave = wave; uData.spd = spd;
        set(g,'userdata',uData);
        
    case {'gammatable','gamma'}
        gTable = displayGet(d,'gamma table');
        g = vcNewGraphWin; plot(gTable);
        xlabel('DAC'); ylabel('Linear');
        grid on
        
        uData = gTable;
        set(g,'userdata',uData);
        
        
    case 'gamut'
        spd = displayGet(d,'spd primaries');
        wave = displayGet(d,'wave');
        XYZ = ieXYZFromEnergy(spd',wave);
        xy = chromaticity(XYZ);
        
        g = chromaticityPlot(xy,'gray',256);
        xy = [xy; xy(1,:)];
        l = line(xy(:,1),xy(:,2));
        set(l,'color',[.6 .6 .6]);
        
        % Store data in figure
        uData.xy = xy;
        set(g,'userdata',uData);
        
    otherwise
        error('Unknown parameter %s\n',param);
end

end

    