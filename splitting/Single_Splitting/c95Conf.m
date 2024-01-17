function [phi, dt, errbar_phi, errbar_dt] = c95Conf(maxtime, Ematrix, ...
    Level1, fa_area)

% calculate splitting results and errors from 95% confidence level

% usage:
% maxtime = maxtime for splitting (sks = 4 seconds)
% Ematrix = Energy Grid
% Level  = confidence level for Silver&Chan Energy map
% fa_area = search interval for fast polarization

% Andreas W�stefeld, 12.03.06

% altered M. Reiss and G. Rümpker 08.07.2016

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Energy Map

f  = size(Ematrix);
ts = linspace(0,maxtime,f(2));
ps = linspace(0-fa_area,180-fa_area,f(1));

%% find errors in summed confidence levels

dphi  = 180/(f(1)-1); %grid size in phi direction
ddt    = maxtime/(f(2)-1);   %grid size in dt direction

[cols, rows] = incontour(Ematrix,Level1);

errbar_phi = (rows-1) * dphi-fa_area;
errbar_dt   = (cols-1) * ddt;

[~, min_ind]= min(Ematrix(:));
[phi_ind, dt_ind] = ind2sub( size(Ematrix), min_ind);

phi = ps(phi_ind);
dt = ts(dt_ind);

end
