function [ temp ] = spd2cct( wave, spds )
% Convert a spectral power distribution to a correlated color temperature 
%
% [ CCT ] = spd2cct( WAVE, SPD )
%
% Calculates the correlated color temperature of an illuminant from its
% spectral power distribution.
%
% CCT : Correlated color temperature.
%
% WAVE: Wavelengths of SPD.
% SPD : Spectral power disbution of the illuminant.
%
% Copyright ImagEval Consultants, LLC, 2003.


error('Not yet implemented.  Missing UVW data conversion routine')

UVW = CIEUVW( wave );
uvw = UVW'*spds;

u = uvw(1,:) ./ sum(uvw,1);
v = uvw(2,:) ./ sum(uvw,1);

temp = cct( [u;v] );

return;
