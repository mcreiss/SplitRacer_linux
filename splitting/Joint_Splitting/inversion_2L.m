function [tra_energy_ges,phimin1,deltamin1,phimin2,deltamin2,tmin] =  ...
    inversion_2L(north_ges, east_ges, dt_ges, Baz, fa_area, res_t, res_d)

% inversion for two layer joint splitting

% usage: 
% north_ges & east_ges: time series in struct
% dt_ges: sample distance
% Baz: back azimuth (in deg)
% fa_area: search interval for phi range
% res_t: resolution in search interval for delay time
% res_d: resolution in search interval for fast polarization

% Copyright 2016 M.Reiss and G.Rümpker


tra_energy = zeros(res_t,res_d,res_t,res_d); 
tra_energy_ges = zeros(res_t,res_d,res_t,res_d); 
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


% search for fast angle and delay time

%grid interval for degree domain (fast axis direction),First Layer
parfor k1 = 1:res_d                         
    phideg1 = (k1*(180/(res_d-1))-(180/(res_d-1)))*1-fa_area;

     %grid interval for time domain
    for k2 = 1:res_t                      
        delta1 = k2*(2/res_t)
        % grid interval for degree domain second layer
        for l1 = 1:res_d                  
            phideg2 = (l1*(180/(res_d-1))-(180/(res_d-1)))*1-fa_area;
            %grid interval for time domain second layer
            for l2 = 1:res_t
                delta2 = l2*(2/res_t) 
                
                % inversion

                for i = 1:length(north_ges)
                    [~,invtra] = invopradtra_2L(rad(:,i),tra(:,i),...
                        dt_ges(i),delta1,phideg1,delta2,phideg2,Baz(i));

                    tra_energy(k2,k1,l2,l1) = sum(dot(invtra,invtra));
                    tra_energy_ges(k2,k1,l2,l1) = tra_energy_ges(...
                        k2,k1,l2,l1)+tra_energy(k2,k1,l2,l1);
                   
                end

            end
        
        end
       
    end

end

% find minimum energy and corresponding splitting parameters
[tmin, minidx] = min(tra_energy_ges(:));
[k2_min, k1_min, l2_min, l1_min] = ind2sub(size(tra_energy_ges), minidx);

phimin1 = (k1_min*(180/(res_d-1))-(180/(res_d-1)))*1-fa_area;
deltamin1 = k2_min*(2/res_t);
phimin2 = (l1_min*(180/(res_d-1))-(180/(res_d-1)))*1-fa_area;
deltamin2 = l2_min*(2/res_t);
tmin = tmin/tra_energy_org_ges;

end

