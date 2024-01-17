function [x] = tukeywindow(tl,w)

% tukey window to smooth time series

% usage:
% tl is number of points in trace
% w is width of cosine divided by two

% Copyright 2016 M.Reiss and G.Rümpker

tl = double(tl);
flanks = round(tl * w/2);
center = tl-2*flanks;

x = (1:1:tl)';

x(1 : flanks) = 0.5*(1-cos(pi*(x(1:flanks)-1)/flanks));
x(flanks+1 : center+flanks) = 1;
x(center+flanks+1 : tl) = 0.5*(1-cos(pi*(tl - ...
    x(center+flanks+1 : tl))/flanks));

end