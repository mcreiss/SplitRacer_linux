function [ ]  =  draw_bars_2L(ic_phi1, ic_delta1, ic_phi2, ic_delta2,...
    fa_area,hsp)

% plot routine for histogram

% usage: 
% ic_phi1: bins with fast polariation values first layer
% ic_delta1 : bin with delay time values first layer
% ic_phi2: bins with fast polariation values second layer
% ic_delta2 : bin with delay time values second layer
% fa_area : search interval for fast polarization
% tab: tab number

% Copyright 2016 M.Reiss and G.Rümpker, altered May 2019

phi_range = linspace(5-fa_area,175-fa_area,18);
delta_range = linspace(0.1,3.9,20);

ax1 = axes('Position',[0.5,0.58,0.2,0.32],'Parent',hsp);
bar(phi_range,ic_phi1,'y')
hold on
bar(phi_range,ic_phi2,'b')
hold off
ylabel('number of measurements')
xlabel('fast axis (\circ)')
title('Histogram')

ax2 = axes('Position',[0.78,0.58,0.2,0.32],'Parent',hsp);
bar(delta_range,ic_delta1,'y')
hold on
bar(delta_range,ic_delta2,'b')
hold off
ylabel('number of measurements')
xlabel('delay time (s)')

end
