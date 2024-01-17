function Plot95Conf_js_2L(maxtime,Ematrix,Level1,phi,dt,fa_area,ax,flag)

% display the results minimum energy

% Inputs are expected in the following order:
% maxtime = maxtime for splitting (sks = 4 seconds)
% Ematrix = Energy Grid
% Level1  = confidence level for Silver&Chan Energy map
% fa_area = search interval for fast polarization
% ax =  axes handle
% flag = defines upper or lower layer

% Andreas Wüstefeld, 12.03.06

% altered my M.Reiss and G. Rümpker 08.08.2016, altered May 2019

Maptitle = {'Energy Map of T with 95% confidence level',flag};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Energy Map
hold on
f  = size(Ematrix);
ts = linspace(0,maxtime,f(2));
ps = linspace(0-fa_area,180-fa_area,f(1));

maxi = max(abs(Ematrix(:)));
mini = min(abs(Ematrix(:)));
nb_contours = floor((1 - mini/maxi)*10);

contour(ax,ts, ps, Ematrix, nb_contours);
contourf(ax,ts,ps,-Ematrix,-[Level1 Level1]);
colormap(ax,gray)
line([0 maxtime], [phi phi],'Color',[0 0 1])
line([dt dt],[0-fa_area 180-fa_area],'Color',[0 0 1])

hold off
axis([0 maxtime 0-fa_area 180-fa_area])
set(gca, 'Xtick',[0:0.5:maxtime], 'Ytick',...
    [0-fa_area:20:180-fa_area],'xMinorTick','on','yminorTick','on')

xlabel('dt (s)');
ylabel('fast axis (\circ)');
title(Maptitle);

end
