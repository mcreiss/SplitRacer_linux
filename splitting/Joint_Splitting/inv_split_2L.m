function [ invrad, invtra ]  =  inv_split_2L( north, east, dt, ...
    delta1, phideg1, delta2, phideg2, bazdeg)

% application of inverse splitting operator

% usage: 
% north & east: time series
% dt: sample distance
% delta1: delay time first layer
% phideg1: fast polarization first layer
% delta2: delay time second layer
% phideg2: fast polarization second layer
% bazdeg: back azimuth (in deg)

% Copyright 2016 M.Reiss and G.Rümpker

% tranformation of north east to radial-transversal
[rad, tra] =  rad_tra (north, east, bazdeg);

% to frequency domain and overwrite
rad = gft(rad);
tra = gft(tra);

[invrad, invtra]   =  invopradtra_2L(rad, tra, dt, ...
    delta1, phideg1, delta2, phideg2, bazdeg);

% to time domain and overwrite
invrad = real(igft(invrad));
invtra = real(igft(invtra));

end

