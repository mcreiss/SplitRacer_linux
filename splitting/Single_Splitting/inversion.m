function [ tra_energy, phimin, deltamin, tmin] = inversion( ...
    north, east, dt, bazdeg, fa_area)

% transverse component energy after application of inverse splitting
% operator

% usage:
% north & east: time series
% dt: sample distance
% bazdeg: back azimuth (in deg)
% fa_area: search interval for fast polarization

% Copyright 2016 M.Reiss and G.Rümpker

tra_energy=zeros(40,181);

% tranformation of north east to radial-transversal
[rad, tra]= rad_tra(north, east, bazdeg);

% to frequency domain and overwrite
rad=gft(rad);
tra=gft(tra);

% calculate energy on transverse component
tra_energy_org = sum(dot(tra,tra));

tmin=1.e30;
% search for fast angle and delay time

for k1=1:181
    phideg=(k1-1)*1-fa_area;
    
    for k2=1:40
        delta = k2*0.1;

        [~,invtra]  = invopradtra(rad, tra, dt, delta, phideg, bazdeg);

        % calculate energy on transverse component and normalize
        tra_energy(k2,k1) = sum(dot(invtra,invtra));
        
    end
end

tmin2 = min(tra_energy(:));
[row,col] = find(tra_energy == tmin2,1,'first');

phimin  =  (col-1)*1-fa_area;
deltamin  =  row*0.1;
tmin = tmin2/tra_energy_org;


end
