function [phi0,dt0] = layer2_n3_app_split(pol,phia,phib,dtmax,freq)

% assume continuous variation: 3-parameter model, with fixed number of
% layers

% this subroutine computes the apparent delay time and fast polarization
% direction for mutiple layers.  The inputs are the total delay times and two
% fast polarization directions and the reference frequency.  The output
% is the apparent fast polarization and delay time. For details see
% Ruempker & Silver (1998, GJI)

% set fixed number of layers
nlay = 10;
phi = zeros(1,nlay);
delta = zeros(1,nlay);

% define continuous range of phi and delta values
dphi = (phib-phia)/(nlay-1);
ddelta = (dtmax-0)/(nlay);
for ii = 1:nlay
    phi(ii) = phia+(ii-1)*dphi;
    delta(ii) = ddelta;
end

% redefine input values
omega = 2*pi*freq;
theta = omega/2*delta;
alpha = 2*(phi-pol)*pi/180;

% get apparent splitting parameters for n-layer model
[ap,cc,app,cs] = xiter(nlay,theta,alpha);

% code below was originally written by Paul Silver to calculate 2-layer apparent
% splitting parameters
rad = 180/pi;
zero = 1e-25;
divisor = app*ap + cs*cc;
xnumerator = app^2 + cs^2;
xt = xnumerator/divisor;

%  prevent dividing by zero
if ((divisor < zero) && (divisor >= 0.0))
    a10 = pi/2;
elseif ((divisor > -zero) && (divisor <= 0.0))
    a10 = -pi/2;
else
    a10 = atan(xnumerator/divisor);
end

t0 = atan(app/(cs*cos(a10) - cc*sin(a10)));

% this and the next two lines give amplitude and phaseof K

ak = complex(ap,cc)/complex(cos(t0),sin(t0)*cos(a10));
amp = abs(ak);
phase = atan2(imag(ak),real(ak));
phi0 = 0.5*a10*rad+pol;
dt0 = t0/(pi*freq);
phase = phase*rad;

% if dt0 is negative, make pos and add 90 to phi0
if (dt0 < 0.0)
    dt0 = -dt0;
    phi0 = phi0+90;
    if (phi0 > 90.0 )
        phi0 = phi0-180;
    end
end
%  write phi0 as positive in output
if (phi0 < 0.0)
    phi0 = phi0 + 180;
end
% added by Georg
while (phi0 > 180.0)
    phi0 = phi0-180;
end

end



function [ap,cc,app,cs] = xiter(nlay,theta,alpha)
% code below is taken from Georg's Fortran subroutines

if nlay<1
    
    [a30,a3,a3s,b3,b3s] = xlay(theta(1),alpha(1));
    
else
    % note: nlay should be ge 2
    % starting at the lowermost layer and working upwards
    
    [a10,a1,a1s,b1,b1s] = xlay(theta(1),alpha(1));
    [a20,a2,a2s,b2,b2s] = xlay(theta(2),alpha(2));
    
    for ii=2:nlay
        
        [a30,a3,a3s,b3,b3s] = xlayop(a10,a1,a1s,b1,b1s,a20,a2,a2s,b2,b2s);
        
        if ii<nlay
            a10 = a30;
            a1 = a3;
            a1s = a3s;
            b1 = b3;
            b1s = b3s;
            [a20,a2,a2s,b2,b2s] = xlay(theta(ii+1),alpha(ii+1));
        end
    end
    
end
ap = real(a30+a3);
cc = - imag(a30+a3);
app = real(b3s);
cs = - imag(b3s);
end

function [a0,a,as,b,bs] = xlay(theta,alpha)

% note: recursion scheme in terms of tan(theta) is not!
% stable

a0 = cos(theta);
a = -1i*sin(theta)*cos(alpha);
as = -a;
b = -1i*sin(theta)*sin(alpha);
bs = b;

end

function [a30,a3,a3s,b3,b3s] = xlayop(a10,a1,a1s,b1,b1s,a20,a2,a2s,b2,b2s)

a30 = a20*a10;
a3 = a2*a10+a20*a1+a2*a1+b2*b1s;
a3s = a2s*a10+a20*a1s+a2s*a1s+b2s*b1;
b3 = b2*a10+b1*a20+a2*b1+b2*a1s;
b3s = b2s*a10+a20*b1s+a2s*b1s+b2s*a1;

end
