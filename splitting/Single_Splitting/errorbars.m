function [errbar_phi,errbar_t,Ecrit] = errorbars(Tcomp, Ematrix, ...
    Eresult,fa_area)

% estimate Degrees-of-Freedom and calculate 95% confidence interval

% usage:
% Tcomp: entire t component
% Ematrix : matrix containing energy values
% Eresult : minimum of transverse component energy
% fa_area : search interval for fast polarization

% taken from Wüstefeld et al. 2007
% altered by M.Reiss and G. Rümpker 2016, altered May 2019

% get number of degrees of freedom
ndf = getndf(Tcomp,length(Tcomp),length(Tcomp));

%Number of model parameters
K = 2;
if ndf <=K
    disp('  NDF <= K... There is no resolution of the 95% confidence region; Continuing')
    errbar_phi = [nan nan];
    errbar_t   = [nan nan];
    Ecrit = Eresult;

else
    
    Ecrit    = Eresult*(1+K*sign(Eresult) / (ndf-K)*inv_f(K,ndf-K));

    %% reconstruct grid
    f     = size(Ematrix);

    dphi  = 180/(f(1)-1); %grid size in phi direction
    dt    = 4/(f(2)-1);   %grid size in dt direction 

    [cols, rows] = incontour(Ematrix,Ecrit);

    errbar_phi = (rows-1) * dphi-fa_area;
    errbar_t   = (cols-1) * dt;
end

end


%%
function data = inv_f(nu1,  nu2)

%using tablelook up for finding the Inverse of the F cumulative
%distribution function. First Degree of Freedom in our case is always 2
%(2 independant parameter: phi, dt. The second degree of fredom was estimated
% from transverse component

if nu2>100, nu2 = 100; end %using last value in table, no big change

%table created with MATLAB statistics Toolbox Command:
% fdata = finv(0.95,2,1:100)';
data = [...
    199.5000
    19.0000
    9.5521
    6.9443
    5.7861
    5.1433
    4.7374
    4.4590
    4.2565
    4.1028
    3.9823
    3.8853
    3.8056
    3.7389
    3.6823
    3.6337
    3.5915
    3.5546
    3.5219
    3.4928
    3.4668
    3.4434
    3.4221
    3.4028
    3.3852
    3.3690
    3.3541
    3.3404
    3.3277
    3.3158
    3.3048
    3.2945
    3.2849
    3.2759
    3.2674
    3.2594
    3.2519
    3.2448
    3.2381
    3.2317
    3.2257
    3.2199
    3.2145
    3.2093
    3.2043
    3.1996
    3.1951
    3.1907
    3.1866
    3.1826
    3.1788
    3.1751
    3.1716
    3.1682
    3.1650
    3.1619
    3.1588
    3.1559
    3.1531
    3.1504
    3.1478
    3.1453
    3.1428
    3.1404
    3.1381
    3.1359
    3.1338
    3.1317
    3.1296
    3.1277
    3.1258
    3.1239
    3.1221
    3.1203
    3.1186
    3.1170
    3.1154
    3.1138
    3.1123
    3.1108
    3.1093
    3.1079
    3.1065
    3.1052
    3.1038
    3.1026
    3.1013
    3.1001
    3.0989
    3.0977
    3.0966
    3.0954
    3.0943
    3.0933
    3.0922
    3.0912
    3.0902
    3.0892
    3.0882
    3.0873];

data = data(nu2);

end

