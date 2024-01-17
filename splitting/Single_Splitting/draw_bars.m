function [ ] = draw_bars(ic_phi, ic_delta, fa_area,tab)

% plot routine for histogram

% usage: 
% ic_phi: bins with fast polariation values
% ic_delta : bin with delay time values
% fa_area : search interval for fast polarization
% tab: tab number

% Copyright 2016 M.Reiss and G.Rümpker, altered May 2019

phi_range = linspace(0-fa_area,180-fa_area,18);
delta_range = linspace(0,4,20);

ax1 = axes('Position',[0.73,0.51,0.1,0.4],'Parent',tab);
bar(ax1,phi_range,ic_phi,'b')
xlim([phi_range(1) phi_range(end)])
ylabel('number of measurements')
xlabel('fast axis (\circ)')
title('Histogram')

ax2 = axes('Position',[0.88,0.51,0.1,0.4],'Parent',tab);
bar(ax2,delta_range,ic_delta,'b')
xlim([0 4])
ylabel('number of measurements')
xlabel('delay time (s)')
end
