function gS = gammaCreate(tbl)
%Default gamma structure
%
%  gS = gammaCreate
%
% Example:
%   tbl = [1:256]/256;
%   g = gammaCreate(tbl);
%   nSamples = gammaGet(g,'tableSize');
%   plot(1:nSamples,gammaGet(g,'table'))
%
%   g = gammaCreate;
%   nSamples = gammaGet(g,'tableSize');
%   plot(1:nSamples,gammaGet(g,'table'))
%

if ieNotDefined('tbl'), 
    gS.vGammaRampLUT = ((1:256)/256).^2.2; 
else
    gS.vGammaRampLUT = tbl;
end
        
return;
