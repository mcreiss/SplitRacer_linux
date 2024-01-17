function [ invrad, invtra ]  =  invopradtra_2L(rad, tra, dt, ...
    delta1, phideg1, delta2, phideg2, bazdeg)

% apply fixed inverse splitting operator to radial and transverse component
% in frequency domain

% usage:
% rad & tra: time series in radial and transversal
% dt: sample distance
% delta1: delay time first layer
% phideg1: fast polarization first layer
% delta2: delay time second layer
% phideg2: fast polarization second layer
% bazdeg: back azimuth (in deg)

% Copyright 2016 M.Reiss and G.Rümpker

if isrow(rad)   % is different than invopradtra.m 
                % because ai11,12 etc habe different dimensions
    rad = rad.';
    tra = tra.';
end

N = length(rad);
invrad = zeros(N,1);
invtra = zeros(N,1);

komega = 1:1:(N/2+1);

omega = 2*pi.*(komega-1)/(N*dt);
theta = omega.*delta1/2;
alpha = 2.*(phideg1-bazdeg)*pi/180;

ar = cos(theta);
ai = -sin(theta).*cos(alpha);
bi = -sin(theta).*sin(alpha);

a = ar+1i*ai;
b = 1i*bi;
as = ar-1i*ai;
bs = 1i*bi;

acm(1,1,:) = a;
acm(1,2,:) = b;
acm(2,1,:) = bs;
acm(2,2,:) = as;

theta2 = omega.*delta2/2;
alpha2 = 2.*(phideg2-bazdeg)*pi/180;

ar2 = cos(theta2);
ai2 = -sin(theta2).*cos(alpha2);
bi2 = -sin(theta2).*sin(alpha2);

a2 = ar2+1i*ai2;
b2 = 1i*bi2;
as2 = ar2-1i*ai2;
bs2 = 1i*bi2;

bcm(1,1,:) = a2;
bcm(1,2,:) = b2;
bcm(2,1,:) = bs2;
bcm(2,2,:) = as2;

ccm = zeros(size(bcm));

for ii=1:length(komega)
ccm(:,:,ii) = bcm(:,:,ii)*acm(:,:,ii);
end

[ ai11, ai12, ai21, ai22 ] = imat22(ccm);

% the sign in the following expression depends on the definition of the
% transverse component!

invrad(1:N/2+1) = ai11 .* rad(1:N/2+1) + ai12 .*tra(1:N/2+1);
invtra(1:N/2+1) = ai21 .* rad(1:N/2+1) +ai22 .* tra(1:N/2+1);

invradtmp = conj(flipud(invrad(2:N/2)));
invtratmp = conj(flipud(invtra(2:N/2)));

invrad(N/2+2:end) = invradtmp;
invtra(N/2+2:end) = invtratmp;


end

function [ ai11, ai12, ai21, ai22 ] = imat22(a)

det = a(1,1,:).*a(2,2,:)-a(1,2,:).*a(2,1,:);

ai11 = squeeze(a(2,2,:)./det);
ai22 = squeeze(a(1,1,:)./det);
ai12 = squeeze(-a(1,2,:)./det);
ai21 = squeeze(-a(2,1,:)./det);

end
