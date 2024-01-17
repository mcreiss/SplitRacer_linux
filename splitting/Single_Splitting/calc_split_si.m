function [phi,dt,err_phi,err_dt,f] = calc_split_si(splits_si,splits_err_min,...
    splits_err_max,splits_baz,nulls_si,nulls_err_min,nulls_err_max,...
    nulls_baz,station)

%% routine to calculate phi and dt from splitting intensity measurements

% input:
% splits_si, splitting intensity from good / average measurements
% splits_baz, backazimuth to aforementioned measurements
% nulls_si, splitting intensity from null measurements
% nulls_baz, backazimuth to aforementioned measurements

% C. M.C. Reiss 2019

% calc complete error
splits_err = splits_err_min + splits_err_max;
nulls_err = nulls_err_min + nulls_err_max;

% merge values
si_vals = [splits_si;nulls_si];
si_err = [splits_err;nulls_err]; 
si_err_min = [splits_err_min; nulls_err_min];
si_err_max = [splits_err_max; nulls_err_max];
baz_vals = [splits_baz;nulls_baz];

% sort baz values and replace negative values
baz_vals(baz_vals<0)=baz_vals(baz_vals<0)+360;
[baz_sort, ind] = sort(baz_vals);
si_sort = si_vals(ind);
si_err_min = si_err_min(ind);
si_err_max = si_err_max(ind);

%% SVD method

X3 = cosd(2*baz_vals)./si_err;
X4 = sind(2*baz_vals)./si_err;

b = si_vals./si_err;

Aij = [X3,X4];

[U, S, V]= svd(Aij);

x = [0 0];

for j=1:2
    xi(j,:) = (U(:,j).'*b)/S(j,j)*V(:,j).';
    x = x + xi(j,:);
end

sigma_x = inv(Aij'*Aij);

dt = sqrt(x(1)^2+x(2)^2);
phi = 0.5*atan2d(-x(1),x(2));
sigma_dt = sigma_x(1,1)*(x(1)/dt).^2 + sigma_x(2,2)*(x(2)/dt).^2; 
sigma_phi = 1/4 * (sigma_x(1,1)*(x(2)/dt^2).^2 + sigma_x(2,2)*(x(1)/dt^2).^2 ); 
err_dt = sqrt(sigma_dt);
err_phi = rad2deg(sqrt(sigma_phi));

%% figure 

% calculate complete si curve
baz_vec = 0:1:360;
fi_si_curve = dt*sind(2*baz_vec-2*phi);

f = figure('Name','Splitting Vector');
errorbar(baz_sort,si_sort,si_err_min,si_err_max,'ro')
hold on
plot(baz_vec,fi_si_curve,'-g')
axis([0 360 -(dt+0.3) (dt+0.3)])
legend('data','SVD','location','northeast')
title({'splitting vector',['for station ',station]})
text(5, (-dt-0.17),['SVD: phi: ', num2str(phi,3), '\circ \pm ', ...
    num2str(err_phi,3), ' dt: ', num2str(dt,2), 's \pm', num2str(err_dt,2)]) 
xlabel('backazimuth \circ')
ylabel('splitting intensity')

end