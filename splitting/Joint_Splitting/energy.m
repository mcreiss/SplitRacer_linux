function [tra_energy_ges, tmin, phimin, deltamin]  =  ...
    energy(north_ges, east_ges, dt_ges, Baz, phi, delta, ...
    layer, fa_area, res_t, res_d)

% energy calculation if one layer is fixed

% usage:
% north & east: time series
% dt_ges: sample distance
% Baz: back azimuth (in deg)
% phi: fast polarization
% delta: delay time
% layer: 1 or 2 depending on which layer is fixed
% fa_area: search interval for phi range
% res_t: resolution in search interval for delay time
% res_d: resolution in search interval for fast polarization

% Copyright 2016 M.Reiss and G.Rümpker

tra_energy = zeros(res_t,res_d);
tra_energy_ges = zeros(res_t,res_d);
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

tmin = 1.e30;

%% search for fast angle and delay time

% if upper layer is fixed

if layer  ==  1
    
    %grid interval for degree domain (fast axis direction),lower Layer
    for k1 = 1:res_d
        phideg1 = (k1*(180/(res_d-1))-(180/(res_d-1)))*1-fa_area;
        
        %grid interval for time domain, lower Layer
        for k2 = 1:res_t
            delta1 = k2*(2/res_t);
            
            %upper layer is fixed
            phideg2  =  phi;
            delta2 = delta;
            
            % inversion
            for i = 1:length(north_ges)
                
                [~,invtra] = invopradtra_2L(rad(:,i),tra(:,i), ...
                    dt_ges(i), delta1, phideg1, delta2, phideg2, Baz(i));
                tra_energy(k2,k1) = sum(dot(invtra,invtra));
                tra_energy_ges(k2,k1) = tra_energy_ges(k2,k1) + ...
                    tra_energy(k2,k1);
            end
            
            if tra_energy_ges(k2,k1) < tmin
                tmin = tra_energy_ges(k2,k1);
                phimin = phideg1;
                deltamin = delta1;
                
            end
        end
    end
    tmin  =  tmin/tra_energy_org_ges;
    
% if lower layer is fixed    
elseif layer  ==  2
    
    phideg1 = phi;                        %first layer fixed
    delta1 = delta;
    
    % grid interval for degree domain upper layer
    for l1 = 1:res_d
        phideg2 = (l1*(180/(res_d-1))-(180/(res_d-1)))*1-fa_area;
        
        %time interval for time domain upper layer
        for l2 = 1:res_t             
            delta2 = l2*(2/res_t);
            
            % inversion
            for i = 1:length(north_ges)
                [~,invtra] = invopradtra_2L(rad(:,i),tra(:,i),...
                    dt_ges(i), delta1, phideg1, delta2, phideg2, Baz(i));
                tra_energy(l2,l1) = sum(dot(invtra,invtra));
                tra_energy_ges(l2,l1) = tra_energy_ges(l2,l1) + ...
                    tra_energy(l2,l1);
            end
            
            if tra_energy_ges(l2,l1) < tmin
                tmin = tra_energy_ges(l2,l1);
                phimin = phideg2;
                deltamin = delta2;
                
            end
        end
    end
    tmin = tmin/tra_energy_org_ges;
end
