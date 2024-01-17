function [ ] = draw_bars_js(ic_phi, ic_delta, fa_area,hsp)

% plot routine for histogram

% usage: 
% ic_phi: bins with fast polariation values first layer
% ic_delta : bin with delay time values first layer
% fa_area : search interval for fast polarization
% hsp: parent panel

% Copyright 2016 M.Reiss and G.Rümpker, altered May 2019

phi_range = linspace(5-fa_area,175-fa_area,18);
delta_range =linspace(0.1,3.9,20);


ax1 = axes('Position',[0.45,0.55,0.2,0.32],'Parent',hsp);
bar(phi_range,ic_phi)
ylabel('number of measurements')
xlabel('fast axis (\circ)')
title('Histogram')


ax2 = axes('Position',[0.75,0.55,0.2,0.32],'Parent',hsp);
bar(delta_range,ic_delta)
ylabel('number of measurements')
xlabel('delay time (s)')


end
