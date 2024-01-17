function [ invrad, invtra ]  =  inv_split( north, east, dt, delta, ...
    phideg, bazdeg)

% application of inverse splitting operator

% usage: 
% north & east: time series
% dt: sample distance
% delta: delay time
% phideg: fast polarization
% bazdeg: back azimuth (in deg)

% Copyright 2016 M.Reiss and G.Rümpker

% tranformation of north east to radial-transversal
[rad, tra] =  rad_tra (north, east, bazdeg);

% to frequency domain and overwrite
rad = gft(rad);
tra = gft(tra);

[invrad, invtra]   =  invopradtra(rad, tra, dt, delta, phideg, bazdeg);

% to time domain and overwrite
invrad = real(igft(invrad));
invtra = real(igft(invtra));

end

