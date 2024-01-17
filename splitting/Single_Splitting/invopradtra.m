function [ invrad, invtra ]  =  invopradtra(...
    rad, tra, dt, delta, phideg, bazdeg)

% apply fixed inverse splitting operator to radial and transverse
% component in frequency domain

% usage:
% rad: radial component as row vector
% tra: transversal component as row vector
% dt: sampling rate
% delta: delay time
% phideg: fast polarization
% bazdeg: back azimuth (in deg)

% Copyright 2016 M.Reiss and G.Rümpker

if ~isrow(rad)
    rad = rad.';
    tra = tra.';
end

N = length(rad);
invrad = zeros(N,1);
invtra = zeros(N,1);

komega = 1:1:(N/2+1);

omega = 2*pi.*(komega-1)/(N*dt);

theta = omega.*delta/2;
alpha = 2.*(phideg-bazdeg)*pi/180;

ar = cos(theta);
ai = -sin(theta).*cos(alpha);
bi = -sin(theta).*sin(alpha);

a = ar+1i *ai ;
b = 1i *bi;
as = ar-1i *ai;
bs = 1i *bi;

c11 = a;
c12 = b;
c21 = bs;
c22 = as;

[ ai11, ai12, ai21, ai22 ] = imat22(c11,c12,c21,c22);

% the sign in the following expression depends on the definition of the
% transverse component!

invrad(1:N/2+1) = ai11 .* rad(1:N/2+1) + ai12.*tra(1:N/2+1);
invtra(1:N/2+1) = ai21 .* rad(1:N/2+1) +ai22 .* tra(1:N/2+1);

invradtmp = conj(flipud(invrad(2:N/2)));
invtratmp = conj(flipud(invtra(2:N/2)));

invrad(N/2+2:end) = invradtmp;
invtra(N/2+2:end) = invtratmp;

end

function [ ai11, ai12, ai21, ai22 ] = imat22(c11,c12,c21,c22)

det = c11.*c22-c12.*c21;

ai11 = c22./det;
ai22 = c11./det;
ai12 = -c12./det;
ai21 = -c21./det;

end

