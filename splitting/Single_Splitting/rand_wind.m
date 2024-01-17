function [t1,t2]  =  rand_wind(ta,tb,times)

% generate random time windows

% usage: 
% ta: original time window start
% tb: original time window end
% times: time vector of trace

% Copyright 2016 M.Reiss and G.Rümpker

var = 1/5;

N = length(times);

tmin = times(1);
tmax = times(N);

t1 = ta+(tb-ta)*var*(rand-0.5)*2;
t2 = tb+(tb-ta)*var*(rand-0.5)*2;

while ((t1 < tmin) || (t2 > tmax))
    t1 = ta+(tb-ta)*var*(rand-0.5)*2;
    t2 = tb+(tb-ta)*var*(rand-0.5)*2;
end

end   