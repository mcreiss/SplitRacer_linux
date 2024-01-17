function plot_si_sp(event,add_info,tab)

% plot single splitting result per event/phase

% usage: 
% event: struct with all necessary data
% add_info: struct with analysis settings
% tab: tab number for plot

% Copyright 2016 M.Reiss and G.Rümpker, altered May 2019

% naming ...
title_string = ['Station: ', add_info.station, ', date: ', ...
    datestr(event.origin_time),', BAZ: ', num2str(event.baz), ...
    '\circ, distance: ', num2str(event.dist), '\circ'];

%% north & east components
annotation(tab,'textbox', [0.05,0.95,0.9,0.04],'String',title_string,...
    'fontunits','normalized','fontsize',0.025,'BackgroundColor', 'w');

ax1 = axes('Position',[0.05,0.82,0.35,0.09],'Parent',tab);

% plot filtered data and backazimuth
aa(1) = -1;
aa(2) = 1;
tt(1) = 50; tt(2) = 50;

plot(ax1,event.times,event.north3)
hold all

% only plot phases inside time window
time_min = min(event.times);
time_max = max(event.times);
for it=1:length(event.phases)
    tt1(1)=event.ttxks(it); tt1(2)=event.ttxks(it);
    if tt1(1)>time_min && tt1(1)<time_max
        plot(ax1,tt1,aa,'-k')
        text(event.ttxks(it),((-1)^it)*1*(1-0.2),...
            char(event.phases(it).name))
    end
end
plot(ax1,tt,aa,'-g')
hold off
xlim([time_min time_max])
ylim([-1 1])
%axis([event.times(1) event.times(end) -1 1])
set(gca,'xticklabel',{[]})
title('trace')
ylabel('North')

ax2 = axes('Position',[0.05, 0.73,0.35,0.09],'Parent',tab);
plot(ax2,event.times,event.east3)
hold on
plot(ax2,tt,aa,'-g')
text(50,((-1))*1*(1-0.2),char(event.phases(event.i_phase).name))
hold off
axis([event.times(1) event.times(end) -1 1])
ylabel('East')

%% plot radial and transverse
ax3 = axes('Position',[0.05,0.61,0.35,0.09],'Parent',tab);
plot(ax3,event.times,event.radc)
hold on
plot(ax3,tt,aa,'-g')
text(50,((-1))*1*(1-0.2),char(event.phases(event.i_phase).name))
%hold off
axis([event.times(1) event.times(end) -1 1])
ylabel('radial')
set(gca,'Xticklabel',{[]})

% finds time derivative of the Radial component
for put = 1:length(event.trac)-1
    rd(put)= (event.radc(put+1)-event.radc(put))/event.sr;
end
norm_rd = max(abs(rd));
rd = rd/norm_rd;

ax4 = axes('Position',[0.05,0.52,0.35,0.09],'Parent',tab);
plot(ax4,event.times,event.trac)
hold on
plot(ax4,event.times(2:end),rd, 'r--')
plot(ax4,tt,aa,'-g')
text(50,((-1))*1*(1-0.2),char(event.phases(event.i_phase).name))
%hold off
axis([event.times(1) event.times(end) -1 1])
xlabel('time (s)')
ylabel('transverse')

%% plot particle motion

% use original time window
ax5 = axes('Position',[0.41,0.74,0.17,0.17],'Parent',tab);
plot(ax5,event.east3,event.north3)
axis([-1 1 -1 1])
xlabel('East')
ylabel('North')
text(-0.9,0.9,'complete');
set(gca,'PlotBoxAspectRatio',[1 1 1])
hold on
xr(1) = 0;
yr(1) = 0;
xr(2) = sin(event.baz*pi/180);
yr(2) = cos(event.baz*pi/180);
plot(xr,yr,'-r','LineWidth',2.5)
hold off
title('particle motion')


ax6 = axes('Position',[0.55,0.74,0.17,0.17],'Parent',tab);
plot(ax6,event.eastcut,event.northcut)
axis([-1 1 -1 1])
xlabel('East')
ylabel('North')
text(-0.9,0.9,'SKS');
set(gca,'PlotBoxAspectRatio',[1 1 1])
hold on
xr(1) = 0;
yr(1) = 0;
xr(2) = sin(event.baz*pi/180);
yr(2) = cos(event.baz*pi/180);
plot(xr,yr,'-r','LineWidth',2.5)
hold off

ax7 = axes('Position',[0.41,0.52,0.17,0.17],'Parent',tab);
plot(ax7,event.eastcuta,event.northcuta)
axis([-1 1 -1 1])
xlabel('East')
ylabel('North')
text(-0.9,0.9,'SKS, T > 10 s');
set(gca,'PlotBoxAspectRatio',[1 1 1])
hold on
xr(1) = 0;
yr(1) = 0;
xr(2) = sin(event.baz*pi/180);
yr(2) = cos(event.baz*pi/180);
plot(xr,yr,'-r','LineWidth',2.5)
hold off

ax8 = axes('Position', [0.55,0.52,0.17,0.17],'Parent',tab);
plot(ax8, event.eastcutb,event.northcutb);
axis([-1 1 -1 1])
xlabel('East')
ylabel('North')
text(-0.9,0.9,'SKS, T > 15 s');
set(gca,'PlotBoxAspectRatio',[1 1 1])
hold on
xr(1) = 0;
yr(1) = 0;
xr(2) = sin(event.baz*pi/180);
yr(2) = cos(event.baz*pi/180);
plot(xr,yr,'-r','LineWidth',2.5)
hold off

%% draw histogram

draw_bars(event.ic_phi, event.ic_delta, add_info.fa_area,tab);

%% draw energy grid

ax9 = axes('Position',[0.28,0.05,0.25,0.38],'Parent',tab);
[X,Y] = meshgrid(event.phi_range,event.delta_range);
contourf(ax9,Y,X,event.mean_energy,50)
colormap('hot')
xlabel('delay time (s)')
ylabel('fast axis (\circ)')
title('Energy grid')
hold on
plot(event.delta,event.phi,'ow','MarkerFaceColor','w','MarkerSize',10)
hold off


%% draw confidence level

ax12 = axes('Position',[0.73,0.05,0.25,0.38],'Parent',tab);

Plot95Conf(event.delta_range(length(event.delta_range)),...
    event.mean_energy',mean(event.level),event.phi,event.delta,...
    add_info.fa_area,ax12);

%% plot particle motion

ax10 = axes('Position',[0.55,0.26,0.17,0.17],'Parent',tab);
plot(ax10,event.tra,event.rad)
ylabel('radial')
text(-0.9,0.9,'original')
set(gca,'DataAspectRatio',[1 1 1])
hold on
xr(1)=0;
yr(1)=0;
xr(2)=0;
yr(2)=1;
plot(xr,yr,'-r','LineWidth',2.5)
axis([-1 1 -1 1])
hold off
title('particle motion')

% corrected particle motion

ax11 = axes('Position',[0.55,0.05,0.17,0.17],'Parent',tab);
plot(ax11,event.invtra,event.invrad)
xlabel('transverse')
ylabel('radial')
text(-0.9,0.9,'corrected')
set(gca,'DataAspectRatio',[1 1 1])
hold on
xr(1)=0;
yr(1)=0;
xr(2)=0;
yr(2)=1;
plot(ax11,xr,yr,'-r','LineWidth',2.5)
axis([-1 1 -1 1])
hold off

%% plot time windows 

axes(ax3)
hold on
for k=1:add_info.NL
    xr(1)=event.t1vec(k);
    yr(1)=-1;
    xr(2)=event.t1vec(k);
    yr(2)=1;
    plot(ax3,xr,yr,'-r','LineWidth',1.5);
    xr(1)=event.t2vec(k);
    yr(1)=-1;
    xr(2)=event.t2vec(k);
    yr(2)=1;
    plot(ax3,xr,yr,'-r','LineWidth',1.5)
end
hold off

axes(ax4)

hold on
for k=1:add_info.NL
    xr(1)=event.t1vec(k);
    yr(1)=-1;
    xr(2)=event.t1vec(k);
    yr(2)=1;
    plot(ax4,xr,yr,'-r','LineWidth',1.5)
    xr(1)=event.t2vec(k);
    yr(1)=-1;
    xr(2)=event.t2vec(k);
    yr(2)=1;
    plot(ax4,xr,yr,'-r','LineWidth',1.5)
end
hold off

%% print results in plot window
bg = uibuttongroup('Visible', 'on','Position', [0.03 .05 .2 .38],...
    'Parent',tab);
txt1 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.0 .89 1 .08],'String','Results of splitting analysis ',...
    'Fontunits','normalized','FontSize',0.65,'FontWeight','bold');
txt2 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.01 .75 .2 .12],'String','phi (°): ',...
    'Fontunits','normalized','FontSize',0.38,...
    'HorizontalAlignment', 'left','FontWeight','bold');
txt22 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.21 .75 .2 .12],'String',num2str(event.phi,3),...
    'Fontunits','normalized','FontSize',0.38,...
    'HorizontalAlignment', 'left');
txt3 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.01 .65 .2 .12],'String','dt (s): ',...
    'Fontunits','normalized','FontSize',0.38,...
    'HorizontalAlignment', 'left','FontWeight','bold');
txt33 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.21 .65 .15 .12],'String',num2str(event.delta,3),...
    'Fontunits','normalized','FontSize',0.38,...
    'HorizontalAlignment', 'left');
txt4 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.4 .75 .25 .12],'String', 'error (°): ',...
    'Fontunits','normalized','FontSize',0.38,...
    'HorizontalAlignment', 'left','FontWeight','bold');

err_phi = strcat(num2str(event.err_phi(1),3),' / ',num2str(event.err_phi(2),3));
txt44 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.7 .75 .3 .12],'String',err_phi ,'Fontunits','normalized','FontSize',0.38,...
    'HorizontalAlignment', 'left');

txt5 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.4 .65 .45 .12],'String',...
    'error (s): ',...
    'Fontunits','normalized','FontSize',0.38,...
    'HorizontalAlignment', 'left','FontWeight','bold');

err_dt = strcat(num2str(event.err_dt(1),2),' / ', num2str(event.err_dt(2),2));
txt55 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.7 .65 .3 .12],'String',err_dt, ...
    'Fontunits','normalized','FontSize',0.38,...
    'HorizontalAlignment', 'left');

txt6 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.01 .55 .6 .12],'String','energy reduction (%):',...
    'Fontunits','normalized','FontSize',0.38,...
    'HorizontalAlignment', 'left','FontWeight','bold');
txt66 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.7 .55 .25 .12],'String',num2str(event.energy_red,2),...
    'Fontunits','normalized','FontSize',0.38,...
    'HorizontalAlignment', 'left');
txt7 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.01 .45 .6 .12],'String','split. intensity:',...
    'Fontunits','normalized','FontSize',0.38,...
    'HorizontalAlignment', 'left','FontWeight','bold');
split_int = strcat(num2str(event.split_int,3), '  (', ...
    num2str(event.split_err(1),3),' / ', num2str(event.split_err(2),3),...
    ')');

txt77 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.4 .45 .6 .12],'String',split_int,...
    'Fontunits','normalized','FontSize',0.38,...
    'HorizontalAlignment', 'left');

bgcolor = [1 1 1];

set(findobj(bg,'-property', 'BackgroundColor'), 'BackgroundColor', bgcolor);
end