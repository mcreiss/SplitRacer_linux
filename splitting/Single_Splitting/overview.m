function overview(sel_data)

% displays all splitting results per station
% necessary inputs are made in GUI and stored in sel_data

% Copyright 2016 M.Reiss and G.Rümpker, altered May 2019

clear globals

% get station(s)
[selected_stations,stations] = read_stationfile(sel_data);

for i=1:length(selected_stations)
    
    st_ind = strcmp(char(selected_stations(i)),stations.name);
    
    dir_get = [sel_data.work_dir,'/graphics_output/Splitting/',...
        'Filter_',num2str(sel_data.p1),'-',num2str(sel_data.p2),'s_SNR_',...
        num2str(sel_data.snr),'_tw_',num2str(sel_data.NL),...
        '/',char(selected_stations(i)),...
        '/Single_Splitting/'];

    % check if splitting results file exists
    st_read = [dir_get,'/splitting_results.txt'];
    if exist(st_read,'file')
    else
        w = warndlg('No file with splitting results for this station exists',...
            ['Warning for',char(selected_stations(i)),'!']);
        drawnow
        waitfor(w);
        continue
    end
    
    % show results
    show_results(char(selected_stations(i)),char(stations.nc(st_ind)),...
        sel_data,dir_get)
    
end

end

function show_results(station,nc,sel_data,dir_get)

% read text file with splitting resuöts
fileID1 = fopen([dir_get,'/splitting_results.txt']);
final_data = textscan(fileID1,'%s %s %f %f %f %f %f %f %f %s %f %f %f %f %f %f %f %f %f %f %s',...
    'headerLines',1);
fclose(fileID1);

% write in struct
results.phase = final_data{1,10};
results.baz = final_data{1,8};
results.phi = final_data{1,11};
results.dt = final_data{1,12};
results.cat = final_data{1,21};

results.lower_phi = abs(results.phi - final_data{1,13});
results.upper_phi = abs(results.phi - final_data{1,14});

results.lower_dt = abs(results.dt - final_data{1,15});
results.upper_dt = abs(results.dt - final_data{1,16});

results.si = final_data{1,18};
results.lower_si = final_data{1,19};
results.upper_si = final_data{1,20};

%% change phi to best display

if sel_data.fa_area == 0
    find_phi = find(results.phi<0);
    results.phi(find_phi)=results.phi(find_phi)+180;
elseif sel_data.fa_area == 90
    find_phi = find(results.phi>90);
    results.phi(find_phi)=results.phi(find_phi)-180;
end

%% seperate categories

fplot.nulls = strcmp(results.cat,'null-measurement');
fplot.nulls_phi = results.phi(fplot.nulls);
fplot.nulls_dt = results.dt(fplot.nulls);
fplot.nulls_si = results.si(fplot.nulls);
fplot.nulls_si_err_min = abs(results.si(fplot.nulls)- ...
    results.lower_si(fplot.nulls));
fplot.nulls_si_err_max = abs(results.si(fplot.nulls)- ...
    results.upper_si(fplot.nulls));

fplot.splits_good = strcmp(results.cat,'good');
fplot.splits_av = strcmp(results.cat,'average');

fplot.splits = bsxfun(@or,fplot.splits_good,fplot.splits_av);

fplot.splits_phi = results.phi(fplot.splits);
fplot.splits_dt = results.dt(fplot.splits);
fplot.splits_baz = results.baz(fplot.splits);
fplot.splits_si = results.si(fplot.splits);
fplot.splits_si_err_min = abs(results.si(fplot.splits)-...
    results.lower_si(fplot.splits));
fplot.splits_si_err_max = abs(results.si(fplot.splits)-...
    results.upper_si(fplot.splits));

%% calculate phi & dt from splitting intensity values
if length(fplot.splits_si) + length(fplot.nulls_si) >= 2
[si_phi,si_dt,err_phi,err_dt,f] = calc_split_si(fplot.splits_si,fplot.splits_si_err_min,...
    fplot.splits_si_err_max,fplot.splits_baz,fplot.nulls_si,...
    fplot.nulls_si_err_min,fplot.nulls_si_err_max,fplot.nulls_phi,station); 

% save results
si_name = '/SI_results.txt';
si_results = strcat(dir_get,si_name);
fileID23 = fopen(si_results, 'w');
% format phi dt phi_err dt_err
fprintf(fileID23, '%f %f %f %f\n', si_phi, si_dt, err_phi, err_dt);
fclose(fileID23);

print(f,[dir_get,'/SI_results.png'],'-dpng','-r0')
else
    w = warndlg('Not enough measurements to calculate the splitting vector',...
        ['Warning for station ', station]);
    drawnow
    waitfor(w);
end

%% write file to plot results in GMT

sta_file = [sel_data.work_dir,'/station.lst'];
fileID2 = fopen(sta_file);
sta_read = textscan(fileID2,'%s %s %f %f %f');
fclose(fileID2);

sta_find = strcmp(sta_read{1,1},station);
lon = sta_read{1,4}(sta_find);
lat = sta_read{1,3}(sta_find);

%splitting results
splitting = '/splits_gmt.tab';
splitting_results = strcat(dir_get,splitting);
fileID3 = fopen(splitting_results, 'w');
% format lon lat phi dt
for i = 1:length(fplot.splits_phi)
    fprintf(fileID3, '%f %f %f %f\n', lon, lat, fplot.splits_phi(i),...
        fplot.splits_dt(i));
end
fclose(fileID3);

%nulls results
null_measurements = '/nulls_gmt.tab';
nulls_results = strcat(dir_get,null_measurements);
fileID4 = fopen(nulls_results, 'w');

% format lon lat phi(baz) dt(0.8 resp. 0.4 to plot cross)
for j = 1:length(fplot.nulls_phi)
    fprintf(fileID4, '%f %f %f %f\n', lon, lat, fplot.nulls_phi(j),0.8);
    fprintf(fileID4, '%f %f %f %f\n', lon, lat, fplot.nulls_phi(j)+90,0.4);
end
fclose(fileID4);

%% plot splitting parameters 
figure('Name','Single Splitting Overview - SplitRacer 2.0',...
    'NumberTitle','off','units','normalized','position',[.3 .1 .7 .7])
title_string = ['Distribution of splitting parameters for station ',...
    station];
annotation('textbox', [0.05,0.95,0.9,0.035],'String',title_string, ...
    'fontunits','normalized','fontsize',0.025, 'BackgroundColor', 'w');

%% define axes for BAZ plots
ax1 = axes('Position',[0.05,0.1,0.4,0.33]); %lower left

hold all
subplot
ax2 = axes('Position',[0.55,0.1,0.4,0.33]); %lower right

hold all
subplot
ax0_1 = axes('Position',[0.2,0.5,0.2,0.35]); %upper left, for models 
set(gca,'visible','off');

hold all
subplot
ax0_2 = axes('Position',[0.45,0.5,0.2,0.35]); %upper right, for models
set(gca,'visible','off');

%% splitting overview

hold all
subplot
ax = axes('Position',[0.23,0.55,0.4,0.35]); % results overview

hold all

plot(ax,fplot.splits_dt,fplot.splits_phi,'d','MarkerFaceColor','r',...
    'MarkerEdgeColor','r','Color','r','MarkerSize',6)
plot(ax,fplot.nulls_dt,fplot.nulls_phi,'o','MarkerFaceColor','b',...
    'MarkerEdgeColor','b','MarkerSize',6);
legend(ax,'good/average','nulls','Location','best')
title(ax,'splitting parameter distribution')
xlabel(ax,'delay time (s)')
ylabel(ax,'phi (\circ)')
if sel_data.fa_area == 0
    axis(ax,[0 4 0 180])
elseif sel_data.fa_area == 90
    axis(ax,[0 4 -90 90])
end


%% pie wedges for statistics

ax3 = axes('Position',[0.62,0.65,0.25,0.26]);

[C,~,ic] = unique(results.phase);
B = accumarray(ic, 1, [], @sum);
for ii=1:length(B)
    label(ii) = strcat(C(ii), ' (', num2str(B(ii)), ')');
end
explode = ones(size(B));
pie(B,explode,label)

ax4 = axes('Position',[0.75,0.5,0.25,0.26]);

[Ca,~,ica]=  unique(results.cat);
Ba = accumarray(ica, 1, [], @sum);
for iii=1:length(Ba)
    label2(iii) = strcat(Ca(iii), ' (', num2str(Ba(iii)), ')');
end
if cell2mat(strfind(label2,'null-measurement') ) 
   label2 = strrep(label2,'null-measurement','nulls') ;
end
explode = ones(size(Ba));
pie(Ba,explode,label2)

hold all

flag=0;
ui_plot(fplot,results,dir_get,station,nc,sel_data.fa_area,...
    ax1,ax2,ax,ax0_1,ax0_2,flag);
end

function ui_plot(fplot,results,dir,station,nw_code,fa_area,ax1,ax2,...
    ax,ax0_1,ax0_2,flag)
% plot results

%% first phi

errorbar(ax1,fplot.splits_baz,fplot.splits_phi,...
    results.lower_phi(fplot.splits), ...
    results.upper_phi(fplot.splits),'d',...
    'MarkerEdgeColor','r','Color','r','MarkerSize',8);
plot(ax1,results.baz(fplot.nulls),fplot.nulls_phi,'o',...
    'MarkerEdgeColor','b','MarkerSize',8);

if isstruct(flag)
    for ii=1:9
          set(get(get(flag.phi(ii),'Annotation'),'LegendInformation'),...
              'IconDisplayStyle','off');  
    end
    legend(ax1,'app. split. para.','good/average','nulls',...
        'Location','best')
elseif flag == 0
    legend(ax1,'good/average','nulls','Location','best')
elseif flag == 1
    legend(ax1,'mean 1-layer value','good/average','nulls',...
        'Location','best') 
end
title(ax1,'polarisation')
xlabel(ax1,'backazimuth (\circ)')
ylabel(ax1,'phi (\circ)')
if fa_area == 0
    axis(ax1,[0 360 0 180])
elseif fa_area == 90
    axis(ax1,[0 360 -90 90])
end

%% now dt

errorbar(ax2,fplot.splits_baz,fplot.splits_dt,...
    results.lower_dt(fplot.splits), ...
    results.upper_dt(fplot.splits),'d',...
    'MarkerEdgeColor','r','Color','r','MarkerSize',8);
plot(ax2,results.baz(fplot.nulls),results.dt(fplot.nulls),'o',...
    'MarkerEdgeColor','b','MarkerSize',8);

if isstruct(flag)
    for ii=1:9
          set(get(get(flag.dt(ii),'Annotation'),'LegendInformation'),...
              'IconDisplayStyle','off');  
    end
    legend(ax2,'app. split. para.','good/average','nulls',...
        'Location','best')
elseif flag == 0
    legend(ax2,'good/average','nulls','Location','best')
elseif flag == 1
    legend(ax2,'mean 1-layer value','good/average','nulls',...
        'Location','best') 
end
title(ax2,'delay time')
xlabel(ax2,'backazimuth (\circ)')
ylabel(ax2,'delay time (s)')
axis(ax2,[0 360 0 4])

ui_layer_fitting(fplot,results,dir, station,nw_code,fa_area,ax1,ax2,...
    ax,ax0_1,ax0_2)
end

function ui_layer_fitting(fplot,results,dir, station,nw_code,fa_area,...
    ax1,ax2,ax,ax0_1,ax0_2)
%% button group to fit 1, 2 layers

bg = uibuttongroup('Visible', 'on','Position', [0.05 .5 .1 .4],...
    'BackgroundColor','w');

btn1 = uicontrol(bg,'Style','pushbutton','Units', 'normalized',...
    'position',[.05 .81 .9 .14],...
    'String','change phi range','Callback',{@replot,fplot,results,dir, ...
    station,nw_code,fa_area, ax1,ax2,ax,ax0_1,ax0_2});
btn2 = uicontrol(bg,'Style','pushbutton','Units', 'normalized',...
    'position',[.05 .62 .9 .14],...
    'String','fit one layer','Callback',{@ui_one,fplot,results,dir,...
    station,nw_code,fa_area,ax1,ax2,ax,ax0_1,ax0_2});
btn3 = uicontrol(bg,'Style','pushbutton','Units', 'normalized',...
    'position',[.05 .43 .9 .14],...
    'String','fit two layers','Callback',{@ui_two_layer,fplot,...
    results,dir,station,nw_code,fa_area,ax1,ax2,ax,ax0_1,ax0_2,4});
btn4 = uicontrol(bg,'Style','pushbutton','Units', 'normalized',...
    'position',[.05 .24 .9 .14],...
    'String','<html>fit continuous<br>model','Callback',{@ui_two_layer,fplot,...
    results,dir,station,nw_code,fa_area,ax1,ax2,ax,ax0_1,ax0_2,3});
btn5 = uicontrol(bg,'Style','pushbutton','Units', 'normalized',...
    'position',[.05 .05 .9 .14],...
    'String','<html>save figure <br>& exit','Callback',{@ui_exit,dir});
uiwait(gcf);

end

function ui_exit(hObject,handles,dir)

%save figure

fig = gcf;
fig.PaperPositionMode = 'auto';
print([dir,'/results.png'],'-dpng','-r0')
close(fig)
end

function ui_one(hObject,handles,fplot,results,dir,station,nw_code,...
    fa_area,ax1,ax2,ax,ax0_1,ax0_2)

flag = 1;
% remove previous plots
if ishandle(ax0_1)
    
    axes(ax0_1)
    delete(ax0_1.Children)
    set(gca,'visible','off');
    
    axes(ax0_2)
    delete(ax0_2.Children)
    set(gca,'visible','off');
    
end
if ~strcmp(get(ax,'visible'),'on')
axes(ax)
set(gca,'visible','on');
ylim(ax,[0-fa_area 180-fa_area])
plot(ax,fplot.splits_dt,fplot.splits_phi,'d','MarkerFaceColor','r',...
    'MarkerEdgeColor','r','Color','r')
plot(ax,fplot.nulls_dt,fplot.nulls_phi,'o','MarkerFaceColor','b',...
    'MarkerEdgeColor','b');
legend(ax,'good/average','nulls','Location','best')
title(ax,'splitting parameter distribution')
xlabel(ax,'delay time (s)')
ylabel(ax,'phi (\circ)')
if fa_area == 0
    axis(ax,[0 4 0 180])
elseif fa_area == 90
    axis(ax,[0 4 -90 90])
end
end
% fit one layer
phi_mean(1) = mean_circ(fplot.splits_phi,fa_area);
phi_mean(2) = phi_mean(1);

dt_mean(1) = mean(fplot.splits_dt);
dt_mean(2) = mean(fplot.splits_dt);
pol(1)=0;
pol(2)=360;

delete(ax1.Children)
delete(ax2.Children)

plot(ax1,pol,phi_mean,'k-');
plot(ax2,pol,dt_mean,'k-');

one_layer = ['one layer: ', num2str(phi_mean(1),2),'\circ, ',...
    num2str(dt_mean(1),2),'s'];

text(0.01,0.97,one_layer,'Units','normalized','Parent',ax1);
text(0.01,0.97,one_layer,'Units','normalized','Parent',ax2);

hold all
ui_plot(fplot,results,dir,station,nw_code,fa_area,ax1,ax2,ax,ax0_1,ax0_2,flag)

end

function ui_two_layer(hObject,handles,fplot,results,dir,station,...
    nw_code,fa_area,ax1,ax2,ax,ax0_1,ax0_2,np)

% fit 2 layer splitting parameters

std_phi = 20;
std_dt = 1;
freq = 0.1;

% search for best two layer model using splitting results
[vals] = search_layer_para(fplot.splits_baz,fplot.splits_phi,...
    fplot.splits_dt,std_phi,std_dt,freq,np);

% calculate theoretical splitting parameters from best fitting 2-layer
% model

Npol = 181;
pol_min = 0.001;
pol_max = 360;
pol = linspace(pol_min,pol_max,Npol);
phi0 = zeros(1,Npol);
dt0 = zeros(1,Npol);
for j=1:length(vals.phi1)
    for k=1:Npol
        if np == 4
            [phi0(j,k),dt0(j,k)] = layer2_app_split(pol(k),vals.phi1(j)...
                +0.2,vals.dt1(j),vals.phi2(j)+0.1,vals.dt2(j),freq);
        elseif np == 3
            [phi0(j,k),dt0(j,k)] = layer2_n3_app_split(pol(k),...
                vals.phi1(j)+0.2,vals.phi2(j)+0.1,vals.dt1(j),freq);
        end
    end
end
%% change phi according to fa_area

if fa_area == 90
    find_phi = find(phi0>90);
    phi0(find_phi) = phi0(find_phi)-180;
    if sum( vals.phi1 > 90)
        find_phi1 = find(vals.phi1>90);
        vals.phi1(find_phi1) = vals.phi1(find_phi1)-180;
    end
    if sum(vals.phi2 > 90)
        find_phi2 = find(vals.phi2>90);
        vals.phi2(find_phi2) = vals.phi2(find_phi2)-180;
    end
    if vals.phi1min > 90
        vals.phi1min = vals.phi1min-180;
    end
    if vals.phi2min > 90
        vals.phi2min = vals.phi2min-180;
    end
end

%% plot splitting parameter curve into previous plots

if np == 4
    lo_la = ['lower layer: ',num2str(vals.phi1min),'\circ, ', ...
        num2str(vals.dt1min),'s'];
    up_la = ['upper layer: ',num2str(vals.phi2min),'\circ, ', ...
        num2str(vals.dt2min),'s'];
    color = '.g';
    
elseif np == 3
    lo_la = ['lowest layer: ',num2str(vals.phi1min),'\circ, integrated ',...
        num2str(vals.dt1min),'s'];
    up_la = ['uppermost layer: ',num2str(vals.phi2min),'\circ per layer'];
    color = '.c';
end

delete(ax1.Children)
delete(ax2.Children)

text(0.01,0.91,lo_la,'Units','normalized','Parent',ax1);
text(0.01,0.97,up_la,'Units','normalized','Parent',ax1);

flag.phi = plot(ax1,pol,phi0,color,'MarkerSize',4);
flag.dt = plot(ax2,pol,dt0,color,'MarkerSize',4);
text(0.01,0.91,lo_la,'Units','normalized','Parent',ax2);
text(0.01,0.97,up_la,'Units','normalized','Parent',ax2);

plot_2layer_sp(vals,ax,ax0_1,ax0_2,fa_area,np)

hold all
ui_plot(fplot,results,dir,station,nw_code,fa_area,ax1,ax2,ax,ax0_1,ax0_2,flag)

end

function plot_2layer_sp(vals,ax,ax0_1,ax0_2,fa_area,flag)

% plot distribution of model parameters

axes(ax)
delete(ax.Children)
delete(legend)
set(gca,'visible','off');

if isempty(ax0_1.Children) == 0
    delete(ax0_1.Children)
    delete(ax0_2.Children)
end

if flag == 3
    vals.dt2 = vals.dt1;
end

set(ax0_1,'visible','on')
set(ax0_2,'visible','on')

signs = {'-r+';'-go';'-b*';'-cx';'-ms';'-yd';'-rh';'-gp';'-b<';'-c>'};

%% plot results of two layer search 

% first layer
for cc = 1: length(signs)
    plot(ax0_1,vals.dt1(cc),vals.phi1(cc),signs{cc},'MarkerSize',10)
    plot(ax0_1,vals.dt1(cc),vals.phi1(cc),signs{cc},'MarkerSize',14)
hold all
end
title(ax0_1,{'Distribution of model parameters:', 'lower layer'})
if fa_area == 0
    axis(ax0_1,[0 3 0 180])
elseif fa_area == 90
    axis(ax0_1,[0 3 -90 90])
end

% second layer
for cc = 1: length(signs)
plot(ax0_2,vals.dt2(cc),vals.phi2(cc),signs{cc},'MarkerSize',10)
plot(ax0_2,vals.dt2(cc),vals.phi2(cc),signs{cc},'MarkerSize',14)
hold all
title(ax0_2,{'Distribution of model parameters:', 'upper layer'})
end

if fa_area == 0
    axis(ax0_2,[0 3 0 180])
elseif fa_area == 90
    axis(ax0_2,[0 3 -90 90])
end


end

function replot(handles,hObject,fplot,results,dir_get, ...
    station,nc,fa_area, ax1,ax2,ax,ax0_1,ax0_2)

if fa_area == 0
    fa_area = 90;
    % change to -90-+90 deg
    
    fplot.nulls_phi(fplot.nulls_phi>90) = ...
        fplot.nulls_phi(fplot.nulls_phi>90)-180;
    fplot.splits_phi(fplot.splits_phi>90) = ...
        fplot.splits_phi(fplot.splits_phi>90)-180;
    
else
    fa_area = 0;
    % change to 0-180 deg 
    fplot.nulls_phi(fplot.nulls_phi<0) = ...
        fplot.nulls_phi(fplot.nulls_phi<0)+180;
    fplot.splits_phi(fplot.splits_phi<0) = ...
        fplot.splits_phi(fplot.splits_phi<0)+180;
    
end

% remove previous plots
if ishandle(ax0_1)
    
    axes(ax0_1)
    delete(ax0_1.Children)
    set(gca,'visible','off');
    
    axes(ax0_2)
    delete(ax0_2.Children)
    set(gca,'visible','off');
    
end

if ishandle(ax1)
    
    axes(ax1)
    delete(ax1.Children)

    axes(ax2)
    delete(ax2.Children)

end

axes(ax)
set(gca,'visible','on');
ylim(ax,[0-fa_area 180-fa_area])
plot(ax,fplot.splits_dt,fplot.splits_phi,'d','MarkerFaceColor','r',...
    'MarkerEdgeColor','r','Color','r')
plot(ax,fplot.nulls_dt,fplot.nulls_phi,'o','MarkerFaceColor','b',...
    'MarkerEdgeColor','b');
legend(ax,'good/average','nulls','Location','best')
title(ax,'splitting parameter distribution')
xlabel(ax,'delay time (s)')
ylabel(ax,'phi (\circ)')
if fa_area == 0
    axis(ax,[0 4 0 180])
elseif fa_area == 90
    axis(ax,[0 4 -90 90])
end

hold all
ui_plot(fplot,results,dir_get,station,nc,fa_area,...
    ax1,ax2,ax,ax0_1,ax0_2,0);
end
