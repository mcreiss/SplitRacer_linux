function [vals] = search_layer_para(pol,phi,dt,phisd,dtsd,freq,np)

% find 2-layer splitting parameters for given values of phi and dt
% simplified version of Fortran program search2 written 
% by Martha Kane Savage, 9/19/92

% Input:
% frequency
% freq=0.1;
% pol, phi, dt: arrays with splitting parameters
% phisd: average standard deviation / scaling factor for phi values
% dtsd: average standard deviation /scaling factor for dt values
% phisd: 20 degrees
% dtsd: 1 second
% the larger the values, the less weight is but on either phi or dt
% Output: best fitting 2-layer parameters (based on given scaling factors)

% altered by M. Reiss, 13.09.2016 to include a continuously changing model

% initilize
errorphi = 0.0;
errordt = 0.0;
errortotmin = 99999;

nvals = length(phi);

% determine resolution
nphi = 18;
ndt = 12;

% introduce small deviations to stabilize calculation

for iphi1 = 1:nphi
    phi1 = iphi1*180.0/nphi + 0.15;
    for iphi2 = 1:nphi
        phi2 = iphi2 * 180.0/nphi + 0.1 ;
        for idt1 = 1:ndt
            dt1 = idt1 * 2.4/ndt;
            for idt2 = 1:ndt
                dt2 = idt2 * 2.4/ndt;
                
                for i = 1:nvals
                    % get apparent splitting parameters
                    if np == 4
                        [phiapp,dtapp] = layer2_app_split(pol(i),...
                            phi1,dt1,phi2,dt2,freq);
                    elseif np == 3
                        [phiapp,dtapp] = layer2_n3_app_split(pol(i),...
                            phi1,phi2,dt1,freq);
                    end
                    
                    diff = phiapp-phi(i);
                    diff = mod(diff,180);
                    
                    if (diff > 90.0)
                        diff = 180.0-diff;
                    end
                    
                    errorphi = errorphi + abs(diff);
                    errordt = errordt + abs(dtapp-dt(i));
                end
                
                if np == 4
                    errortot(iphi1,idt1,iphi2,idt2) = ...
                        (errorphi/phisd) + (errordt/dtsd);
                elseif np == 3
                    errortot(iphi1,idt1,iphi2) = ...
                        (errorphi/phisd) + (errordt/dtsd);
                end
                
                
                errorphi = 0.0;
                errordt = 0.0;
            end
        end
    end
end

%find minimal error
[error_min, minidx] = min(errortot(:));
[err_sort sort_ind] = sort(errortot(:));
error_find = sort_ind(1:10);

if np == 4
    
    [ind_phi1,ind_dt1,ind_phi2,ind_dt2] = ...
        ind2sub( size(errortot), error_find);
    [ind_phi1min,ind_dt1min,ind_phi2min,ind_dt2min] = ...
        ind2sub( size(errortot), minidx);
    vals.dt2 = ind_dt2 * 2.4/ndt;
    vals.dt2min = ind_dt2min * 2.4/ndt;
    
elseif np == 3
    
    [ind_phi1,ind_dt1,ind_phi2] = ...
        ind2sub( size(errortot), error_find);
    [ind_phi1min,ind_dt1min,ind_phi2min] = ...
        ind2sub( size(errortot), minidx);
    
end

vals.phi1 = ind_phi1*180.0/nphi + 0.15;
vals.dt1 = ind_dt1 * 2.4/ndt;
vals.phi2 = ind_phi2 * 180.0/nphi + 0.1 ;

vals.phi1min = ind_phi1min*180.0/nphi + 0.15;
vals.dt1min = ind_dt1min * 2.4/ndt;
vals.phi2min = ind_phi2min * 180.0/nphi + 0.1 ;

end


