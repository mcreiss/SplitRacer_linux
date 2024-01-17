function [north, east] = north_east (rad, tra, bazdeg)

% tranformation of radial-transversal to north east 

% Copyright 2016 M.Reiss and G.Rümpker

baz = bazdeg*pi/180;

east = cos(baz)*tra+sin(baz)*rad;
north = -sin(baz)*tra+cos(baz)*rad;

end