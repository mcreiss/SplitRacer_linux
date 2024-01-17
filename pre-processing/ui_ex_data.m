function ui_ex_data(hObject,handles,sel_data)

% GUI for 'check data' - view/check data before analysis

% Copyright 2016 M.Reiss and G.Rümpker, altered May 2019

global test_data pd2

% define figure
mainfig=figure('Name','SplitRacer 2.0 - View waveforms','NumberTitle','off',...
    'units','normalized','position',[.3 .1 .7 .7]);
hp = uipanel('units','normalized','position',[.0 .0 1 1]);
movegui(mainfig,'center')

% define panels
hsp = uipanel('units','normalized','position',[.0 .0 .15 1],'parent',hp);
hsp2 = uipanel('units','normalized','position',[.15 .0 .85 1],'parent',hp);

%% main button group to the left
menu_bg = uibuttongroup('Parent',hsp,'Visible', 'on','Position', ...
    [.0 .0 1 1]);

[disp_stations] = disp_st_lst;
disp_stations{1} = ' ';

txt = uicontrol(menu_bg,'Style','text','Visible','on','Units',...
    'normalized','position',[0.1,0.93,0.8,0.05],'String','Menu',...
    'fontunits','normalized','fontsize',0.6);

txt1 = uicontrol(menu_bg,'Style','text','Visible','on','Units',...
    'normalized','position',[0.1,0.85,0.8,0.05],'String',...
    'Choose station', 'fontunits','normalized','fontsize',0.4);

pd1 = uicontrol(menu_bg,'Style','popupmenu', 'String',disp_stations,...
    'Units', 'normalized','position',[0.1,0.76,0.8,0.1],...
    'BackgroundColor','w', 'fontunits','normalized','fontsize', 0.2,...
    'Callback', {@uisel_st,menu_bg,sel_data});

txt2 = uicontrol(menu_bg,'Style','text','Units', 'normalized',...
    'position',[0.1,0.74,0.8,0.05],'String','Choose event','fontunits',...
    'normalized','fontsize',0.4);

pd2 = uicontrol(menu_bg,'Style','popupmenu', 'String',' ','Units',...
    'normalized','position',[0.1,0.65,0.8,0.1],...
    'fontunits','normalized','fontsize', 0.2);

pb1 = uicontrol(menu_bg,'Style','pushbutton','Units', 'normalized',...
    'position',[0.1,0.62,0.8,0.05],'String', 'show event','fontunits',...
    'normalized','fontsize',0.4,'Callback',...
    {@ui_get_ex_data,hsp2,pd1});

pb2 = uicontrol(menu_bg,'Style','pushbutton','Units', 'normalized',...
    'position',[0.1,0.52,0.8,0.05],'String', 'next event','fontunits',...
    'normalized','fontsize',0.4,'Callback',...
    {@ui_get_next,hsp2,pd1});

pb3 = uicontrol(menu_bg,'Style','pushbutton','Units', 'normalized',...
    'position',[0.1,0.12,0.8,0.05],'String', ...
    'exit','fontunits',...
    'normalized','fontsize',0.4,'Callback','delete(gcf)');

flag = 0;
end

function uisel_st(hObject,handles,menu_bg,sel_data)

% get station & network code

global test_data pd2

% get input from GUI
station_strings = get(hObject,'String');
station_vals = get(hObject,'Value');
test_data.station = station_strings(station_vals);
sel_data.station = station_strings(station_vals);

[selected_station,stations]=read_stationfile(sel_data);
find_station = strcmp(char(selected_station),stations.name);
test_data.nc = char(stations.nc(find_station));

test_data.work_dir = sel_data.work_dir;

%read log file containing successfully downloaded data
fileID = fopen([sel_data.work_dir,'/data_request_',...
    char(selected_station),'_',char(stations.nc(find_station))]);

C = textscan(fileID,'%s %s %s %s %s %s %f %f %f %f %f %f %s %s',...
    'CollectOutput',1);

fclose(fileID);

% get events
data = C{1,1};

for n = 1: length(data(:,1))
    
    events(n+1,:) = strjoin(data(n,:));
    
end

% put data in pull down menu
pd2 = uicontrol(menu_bg,'Style','popupmenu', 'String',events,'Units',...
    'normalized','position',[0.1,0.65,0.8,0.1],...
    'fontunits','normalized','fontsize', 0.2);

end

function ui_get_ex_data(hObject,handles,hsp2,pd1)

% get input from GUI to plot event

global test_data pd2

delete(hsp2.Children)

uiget_event(pd2)

plot_ex_data(test_data,hsp2)

end

function ui_get_next(hObject,handles,hsp2,pd1)

% get input from GUI to plot event

global test_data pd2

val = get(pd2,'value');

pd2.Value = val+1;

ui_get_ex_data(hObject,handles,hsp2,pd1)

end