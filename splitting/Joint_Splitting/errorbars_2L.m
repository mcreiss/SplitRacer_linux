function [errbar_phi,errbar_t,Ecrit] = errorbars_2L(Tcomp, Ematrix, ...
    Eresult,fa_area)

% estimate Degrees-of-Freedom and calculate 95% confidence interval

% usage:
% Tcomp: entire t component
% Ematrix : matrix containing energy values
% Eresult : minimum of transverse component energy
% fa_area : search interval for fast polarization

% taken from Wüstefeld et al. 2007
% altered by M.Reiss and G. Rümpker 2016 after Walsh et al. 2013

ndf = getndf(Tcomp,length(Tcomp),length(Tcomp));

K = 4;%Number of model parameters
if ndf <=K
    disp(['  NDF <= K... There is no resolution of the 95%',...
        'confidence region; Continuing'])
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
%(4 independent parameters, for each layer: phi, dt. 
%The second degree of fredom was estimated from transverse component

if nu2>100, nu2 = 100; end %using last value in table, no big change

%table created with MATLAB statistics Toolbox Command:
% fdata = finv(0.95,4,1:100)';
data=[...
   224.5832
   19.2468
    9.1172
    6.3882
    5.1922
    4.5337
    4.1203
    3.8379
    3.6331
    3.4780
    3.3567
    3.2592
    3.1791
    3.1122
    3.0556
    3.0069
    2.9647
    2.9277
    2.8951
    2.8661
    2.8401
    2.8167
    2.7955
    2.7763
    2.7587
    2.7426
    2.7278
    2.7141
    2.7014
    2.6896
    2.6787
    2.6684
    2.6589
    2.6499
    2.6415
    2.6335
    2.6261
    2.6190
    2.6123
    2.6060
    2.6000
    2.5943
    2.5888
    2.5837
    2.5787
    2.5740
    2.5695
    2.5652
    2.5611
    2.5572
    2.5534
    2.5498
    2.5463
    2.5429
    2.5397
    2.5366
    2.5336
    2.5307
    2.5279
    2.5252
    2.5226
    2.5201
    2.5177
    2.5153
    2.5130
    2.5108
    2.5087
    2.5066
    2.5046
    2.5027
    2.5008
    2.4989
    2.4971
    2.4954
    2.4937
    2.4920
    2.4904
    2.4889
    2.4874
    2.4859
    2.4844
    2.4830
    2.4817
    2.4803
    2.4790
    2.4777
    2.4765
    2.4753
    2.4741
    2.4729
    2.4718
    2.4707
    2.4696
    2.4685
    2.4675
    2.4665
    2.4655
    2.4645
    2.4636
    2.4626];

data=data(nu2);

end
