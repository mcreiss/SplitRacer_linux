function [baz_pm]  =  pm(north,east,dt,baz_geo,ano_text,p_min,p_max)

% show paricle motion to check BAZ
% usage: 
% north: north component
% east: east component
% dt: sample rate
% baz_geo: theoretical BAZ
% ano_text: annotation as string
% p_min: filter in s 
% p_max: filter in s

% Copyright 2016 M.Reiss and G.Rümpker

if nargin > 5
    % use filter
    northa = buttern_filter(north,2,1/p_max,1/p_min,dt);
    easta = buttern_filter(east,2,1/p_max,1/p_min,dt);
    easta = coswin(easta);
    northa = coswin(northa);
else
    northa = north;
    easta = east;
end

% norm traces
maxn = max(abs(northa));
maxe = max(abs(easta));
maxne = max(maxe,maxn);
northa = northa/maxne;
easta = easta/maxne;

% covariance analysis
[baz_pm,~,~] = covar(northa,easta);

% plot
plot(easta,northa)
axis([-1 1 -1 1])
xlabel('East')
ylabel('North')
text(-0.9,0.88,ano_text);
set(gca,'PlotBoxAspectRatio',[1 1 1])
hold on
xr(1) = 0;
yr(1) = 0;
xr(2) = sin(baz_geo*pi/180);
yr(2) = cos(baz_geo*pi/180);
plot(xr,yr,'-r','LineWidth',2.5)
hold off
end

