function [tra_energy_ges, phimin, deltamin, tmin]  =  ...
    inversion_js(north_ges, east_ges, dt_ges, Baz, fa_area)

% inversion for one layer joint splitting

% usage:
% north_ges & east_ges: time series in struct
% dt_ges: sample distance
% Baz: back azimuth (in deg)
% fa_area: search interval for fast polarization

% Copyright 2016 M.Reiss and G.Rümpker

tra_energy = zeros(40,181); 
tra_energy_ges = zeros(40,181); 
tra_energy_org_ges = 0;

% tranformation of north east to radial-transversal

for i = 1:length(north_ges)
    [rad_s, tra_s] =  rad_tra (north_ges{i}, east_ges{i}, Baz(i));
    %to frequency domain and overwrite
    rad(:,i) = gft(rad_s);
    tra(:,i) = gft(tra_s);
    % calculate energy on transverse component
    tra_energy_org = sum(dot(tra(:,i),tra(:,i)));
    tra_energy_org_ges = tra_energy_org_ges+tra_energy_org;
end


%% search for fast angle and delay time

%grid interval for degree domain (fast axis direction)
for k1 = 1:181
    
    phideg = (k1-1)*1-fa_area;
    
    %grid interval for time domain
    for k2 = 1:40
        delta = k2*0.1;
        % loop over events
        for i = 1:length(north_ges)
            
            
            [~,invtra]   =  invopradtra(rad(:,i),tra(:,i),dt_ges(i),...
                delta, phideg, Baz(i));
            
            % calculate energy on transverse component and normalize
            tra_energy(k2,k1) = sum(dot(invtra,invtra));
            tra_energy_ges(k2,k1) = tra_energy_ges(k2,k1)+tra_energy(k2,k1);
            
        end
    end
end

tmin = min(tra_energy_ges(:));
[row,col] = find(tra_energy_ges == tmin);

phimin  =  (col-1)*1-fa_area;
deltamin  =  row*0.05;
tmin = tmin/tra_energy_org_ges;

end


