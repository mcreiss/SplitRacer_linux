function Plot95Conf( maxtime, Ematrix, Level1, phi, dt, fa_area, ax)

% display the results of a minimum Energy
% splitting procedure in a single plot

% Inputs are expected in the following order:
% maxtime = maxtime for splitting (sks = 4 seconds)
% Ematrix = Energy Grid
% Level  = confidence level for Silver&Chan Energy map
% fa_area = search interval for fast polarization
% ax: axes handle

% Andreas Wüstefeld, 12.03.06
% changed M.Reiss, 08.08.2016, , altered May 2019

Maptitle = 'Energy Map of T with 95% confidence level';


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
ylabel('fast axis (\circ)')
title(Maptitle);


end
