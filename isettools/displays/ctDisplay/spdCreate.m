function spd = spdCreate(wave,energy)
% Create a spectral power distribution (spd) structure
%
%  spd = spdCreate(wave,energy)
%
%

if ieNotDefined('wave'), wave = []; end
if ieNotDefined('energy'), energy = []; end

spd.wave = wave;
spd.energy = energy;

return;
