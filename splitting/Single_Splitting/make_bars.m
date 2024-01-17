function [ic_phi,ic_delta] = make_bars(phimin,deltamin,fa_area)

% plot histogram

% Copyright 2016 M.Reiss and G.Rümpker

edges_phi = [0-fa_area : 10 :  180-fa_area];
edges_delta = [0 : 0.2 : 4];

h = histcounts(phimin,edges_phi);
ic_phi = h';
h = histcounts(deltamin,edges_delta);
ic_delta = h';

end