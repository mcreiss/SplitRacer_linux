function [xi,yi] = frame (x1,x2,x,y,m)

% interpolate function y(x) between x1 and x2 at m points

% Copyright 2016 M.Reiss and G.Rümpker

xi=linspace(x1,x2,m);
yi=interp1(x,y,xi);
end
