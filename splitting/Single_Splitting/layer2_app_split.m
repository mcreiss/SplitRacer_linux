function [phi0,dt0] = layer2_app_split(pol,phi1,dt1,phi2,dt2,freq)
%
% this subroutine computes the apparent delay time and fast polarization
% direction for two layers.  The inputs are the two delay times and two
% fast polarization directions and the reference frequency.  The output
% is the apparent fast polarization, delay time the  apparent rotation
% and change in size of the initial polarization vector.
% phi1 and dt1 correspond to the first layer the wave passes though
% with phi2 and dt2 the second.  The solved for parameters are
% phi0 and dt0, the apparent fast pol dir and delay time, as well as
% amp, and phase, the amplitude and phase of the complex scalar multiplying
% the phat vector. Written by Paul Silver 7/25/91

rad= 180.0/pi;
zero = 1.0e-10;

% changed by Georg Rümpker

zero=1.e-25;
t1=pi*freq*dt1;
t2=pi*freq*dt2;

% right away, if one of numbers is zero, put out appropriate outputs
if (dt1 < 0.00001)
    phi0 = phi2;
    dt0 = dt2;
    return
end
if (dt2 < 0.0001)
    phi0 = phi1;
    dt0 = dt1;
    return
end

phat=pol;

al1=2.0*(phi1-phat)/rad;
al2=2.0*(phi2-phat)/rad;

cc  = cos(t1)*sin(t2)*cos(al2) + cos(t2)*sin(t1)*cos(al1);
cs  = cos(t1)*sin(t2)*sin(al2) + cos(t2)*sin(t1)*sin(al1);
ap  = cos(t1)*cos(t2) - sin(t1)*sin(t2)*cos(al2-al1);
app=                 - sin(t1)*sin(t2)*sin(al2-al1);


divisor = app*ap + cs*cc;
xnumerator = app^2 + cs^2;
xt=xnumerator/divisor;

% prevent dividing by zero
if ((divisor < zero) && (divisor >= 0.0))
    a10 = pi/2;
    
elseif ((divisor > -zero) && (divisor <= 0.0))
    a10 = -pi/2;
    
else
    
    a10=atan(xnumerator/divisor);
end

t0= atan(app/(cs*cos(a10) - cc*sin(a10)));

% this and the next two lines give amplitude and phase of K
ak=complex(ap,cc)/complex(cos(t0),sin(t0)*cos(a10));
amp=abs(ak);
phase=atan2(imag(ak),real(ak));
phi0 = 0.5*a10*rad+phat;
dt0=t0/(pi*freq);
phase=phase*rad;

% if dt0 is negative, make pos and add 90 to phi0
if (dt0 < 0.0)
    dt0 = -dt0;
    phi0=phi0+90;
    if (phi0 > 90.0 )
        phi0=phi0-180;
    end
end
% write phi0 as positive in output
if (phi0 < 0.0)
    phi0 = phi0 + 180;
end
% added by Georg
while (phi0 > 180.0)
    phi0=phi0-180;
end
return
end
