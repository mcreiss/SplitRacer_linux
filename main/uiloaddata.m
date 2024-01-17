function uiloaddata(hObject,handles)

% GUI menu to select data for download

% Copyright 2016 M.Reiss and G.Rümpker, altered May 2019

global sel_data pd2 pd4 pb2

% define main panel
hsp_load = uipanel('units','normalized','position',[.2 .0 .8 1]);

% define station parameters panel
load_bg = uibuttongroup('Parent',hsp_load,'Visible', 'on','Position', ...
    [.0 .0 1 1]);

% define title string
title_str = uicontrol(load_bg,'Style','text','Visible','on','Units',...
    'normalized','position',[0.2,0.92,0.6,0.05],'String',...
    'Select download parameters',...
    'fontunits','normalized','fontsize',0.8);


%% data center & station parameters

% define button group
load_bg1 = uibuttongroup('Parent',hsp_load,'Title','Station parameters',...
    'fontunits','normalized','fontsize',0.05,...
    'Visible', 'on','Position', [.0 .0 .5 .85]);

% get data centers
fileID = fopen('data_centers.dat');
C2 = textscan(fileID,'%s %s');
fclose(fileID);

data_centers = C2{1,1};
urls = C2{1,2};
dist_centers(2:length(data_centers)+1)=data_centers;

% all buttons for station/network parameters

txt1 = uicontrol(load_bg1, 'Style', 'text', 'String', ...
    {'Choose', 'data center'},'Units', 'normalized','position',...
    [0.05,0.8,0.4,0.1],'fontunits','normalized','fontsize',0.33);

pd1 = uicontrol(load_bg1, 'Style', 'popupmenu','String',dist_centers,...
    'Units', 'normalized', 'position',[0.5,0.79,0.4,0.1],'fontunits',...
    'normalized','fontsize',0.33, 'Callback',{@uisel_dc,C2,load_bg1});

txt2 = uicontrol(load_bg1,'Style','text','Visible','on','Units',...
    'normalized','position',[0.05,0.68,0.4,0.1],'String',{'Choose',...
    'network code'},...
    'fontunits','normalized','fontsize',0.33);
    
pd2 = uicontrol(load_bg1,'Style','popupmenu', 'String','no network',...
    'Units','normalized','position',[0.5,0.67,0.4,0.1],'fontunits',...
    'normalized', 'fontsize', 0.31);

txt3 = uicontrol(load_bg1, 'Style', 'text', 'String', ...
    {'Choose', 'channel name'},'Units', 'normalized','position',...
    [0.05,0.56,0.4,0.1],'fontunits','normalized','fontsize',0.33);

channels = {'','BH','HH'};

pd3 = uicontrol(load_bg1, 'Style', 'popupmenu','String',channels,...
    'Units', 'normalized', 'position',[0.5,0.55,0.4,0.1],'fontunits',...
    'normalized','fontsize',0.33,...
    'Callback',{@uiget_channel,C2,load_bg1});

txt4 = uicontrol(load_bg1,'Style','text','Visible','on','Units',...
    'normalized','position',[0.05,0.44,0.4,0.1],'String',...
    {'Select station', '& location'},'fontunits','normalized','fontsize',0.33);
    
pd4 = uicontrol(load_bg1,'Style','popupmenu','Units', 'normalized',...
    'position',[0.5,0.43,0.4,0.1],'String','no stations','fontunits',...
    'normalized','fontsize',0.33,'Callback',@uisel_st);  


pb11 = uicontrol(load_bg1,'Style','pushbutton','Units', 'normalized',...
    'position',[0.05,0.3,0.4,0.1],'String','Create event list',...
    'fontunits', 'normalized','fontsize',0.33,'Callback',@uicreatelist);

pb22 = uicontrol(load_bg1,'Style','pushbutton','Units', 'normalized',...
    'position',[0.5,0.3,0.4,0.1],'String','Set event list','fontunits',...
    'normalized','fontsize',0.33,'Callback',@uieventlist);


%% request parameters

load_bg2 = uibuttongroup('Parent',hsp_load,'Title','Event parameters',...
    'fontunits','normalized','fontsize',0.05,'Visible', 'on',...
    'Position', [.5 .0 .5 .85]);

% all buttons / editable fields for event parameters

txt11 = uicontrol(load_bg2, 'Style', 'text', 'String', ...
    {'Enter start date'},'Units', 'normalized','position', ...
    [0.05,0.8,0.4,0.1],'fontunits','normalized','fontsize',0.33);

e11 = uicontrol(load_bg2, 'Style', 'Edit','String','2012-01',...
    'Units', 'normalized', 'position',[0.5,0.855,0.4,0.05],...
    'Callback',@uisel_sd);    

txt22 = uicontrol(load_bg2, 'Style', 'text', 'String', ...
    {'Enter end date'},'Units', 'normalized','position',...
    [0.05,0.68,0.4,0.1],'fontunits','normalized','fontsize',0.33);

e22 = uicontrol(load_bg2, 'Style', 'Edit','String','2012-12',...
    'Units', 'normalized',...
    'position',[0.5,0.735,0.4,0.05],'Callback',@uisel_ed);  

txt33 = uicontrol(load_bg2, 'Style', 'text', 'String', ...
    {'Enter min.', 'distance [in °]'},'Units', 'normalized','position',...
    [0.05,0.58,0.4,0.1],'fontunits','normalized','fontsize',0.33);

e33 = uicontrol(load_bg2, 'Style', 'Edit','String','85',...
    'Units', 'normalized', 'position',[0.5,0.615,0.4,0.05],...
    'Callback',@uisel_mindis);    

txt44 = uicontrol(load_bg2, 'Style', 'text', 'String', ...
    {'Enter max.', 'distance [in °]'},'Units', 'normalized','position',...
    [0.05,0.46,0.4,0.1],'fontunits','normalized','fontsize',0.33);

e44 = uicontrol(load_bg2, 'Style', 'Edit','String','140',...
    'Units', 'normalized',...
    'position',[0.5,0.495,0.4,0.05],'Callback',@uisel_maxdis); 

txt55 = uicontrol(load_bg2, 'Style', 'text', 'String', ...
    {'Enter magnitude'},'Units', 'normalized','position',...
    [0.05,0.32,0.4,0.1],'fontunits','normalized','fontsize',0.33);

e55 = uicontrol(load_bg2, 'Style', 'Edit','String','6',...
    'Units', 'normalized',...
    'position',[0.5,0.375,0.4,0.05],'Callback',@uisel_mag);

% download button
pb2 = uicontrol(load_bg2,'Style','pushbutton','Units', 'normalized',...
    'position',[0.3,0.05,0.4,0.1],'String','Download','fontunits',...
    'normalized','fontsize',0.4,'Enable', 'off','Callback', ...
    {@uigetdownloadinput,e11,e22,e33,e44,e55});
end


function uisel_dc(hObject,handles,C2,load_bg1)

% once a data center is selected, a fdsn request is sent for all available
% networks, which then appear in pop up menu

global sel_data pd2

data_centers = get(hObject,'String');
sel_data_center = get(hObject,'Value');
sel_data.data_center  = data_centers(sel_data_center); 

index_dc = find(strcmp(C2{1,1}, sel_data.data_center)==1);
dc_url = C2{1,2}(index_dc);

find_ind = strfind(char(dc_url), '/dataselect/1/');
new_url = strcat('curl -L --digest "', dc_url{1,1}(1:find_ind),...
    'station/1/query?network=*&format=text&level=network" -o ');
output = strcat(sel_data.work_dir,'/available_networks.txt');
req_line = sprintf('%s %s',char(new_url),char(output));
system(req_line);
fileID2 = fopen([sel_data.work_dir,'/available_networks.txt']);
C3 = textscan(fileID2,'%s %*[^\n]','Delimiter','|');
fclose(fileID2);

disp_networks = C3{1,1}; disp_networks{1,1}=[];
pd2 = uicontrol(load_bg1,'Style','popupmenu', 'String',disp_networks,...
    'Units','normalized','position',[0.5,0.67,0.4,0.1],'fontunits',...
    'normalized', 'fontsize', 0.33,'Callback',{@uiget_nc});

end

function uiget_nc(hObject,handles)

% get network code
global sel_data

nc = get(hObject,'String');
sel_nc = get(hObject,'Value');
sel_data.nc  = nc(sel_nc); 

end

function uiget_channel(hObject,handles,C2,load_bg1)

% if channel is set, a fdsn request is sent for all available stations,
% which then appear in pop up menu

global sel_data pd4

streams = get(hObject,'String');
sel_stream = get(hObject,'Value');

sel_data.stream  = streams(sel_stream); 

index_dc = find(strcmp(C2{1,1}, sel_data.data_center)==1);
dc_url = C2{1,2}(index_dc);

find_ind = strfind(char(dc_url), '/dataselect/1/');
new_url = strcat('curl -L --digest "', dc_url{1,1}(1:find_ind),...
    'station/1/query?network=',sel_data.nc,'&channel=',sel_data.stream,...
    'Z&format=text&level=channel" -o ');
output = strcat(sel_data.work_dir,'/available_stations.txt');
req_line = sprintf('%s %s',char(new_url),char(output));
system(req_line);
fileID2 = fopen([sel_data.work_dir,'/available_stations.txt']);
C3 = textscan(fileID2,'%s %s %s %*[^\n]','Delimiter','|','HeaderLines',1);
fclose(fileID2);

tmp_stations = strcat(C3{1,2},{' '},C3{1,3});
[tmp_stations,~,~] = unique(tmp_stations);
disp_stations = cat(1,{'all'},tmp_stations);
pd4 = uicontrol(load_bg1,'Style','popupmenu','Units', 'normalized',...
    'position',[0.5,0.43,0.4,0.1],'String',disp_stations,'fontunits',...
    'normalized','fontsize',0.33,'Callback',@uiget_st);  

end

function uigetdownloadinput(hObject,handles, e11,e22,e33,e44,e55)

% this function assembles all necessary inputs for download

global sel_data pd4

uiget_st(pd4)
uisel_sd(e11)
uisel_ed(e22)
uisel_mindis(e33)
uisel_maxdis(e44)
uisel_mag(e55)


download(sel_data)

end


function uisel_sd(hObject,handles)

% get start date 
global sel_data

sel_data.start_date = get(hObject,'String');

end

function uisel_ed(hObject,handles)

% get end date
global sel_data

sel_data.end_date = get(hObject,'String');

end

function uisel_mindis(hObject,handles)

%get minimum distance
global sel_data

sel_data.min_dist  = str2double(get(hObject,'String'));

end

function uisel_maxdis(hObject,handles)

% get maximum distance
global sel_data

sel_data.max_dist  = str2double(get(hObject,'String'));

end

function uisel_mag(hObject,handles)

% get cutt off magnitude
global sel_data

sel_data.mag  = str2double(get(hObject,'String'));

end

function uieventlist(hObject,handles)

% get path/ name of event list 
global sel_data pb2

[sel_data.Eventlist,sel_data.Eventlist_path] =...
    uigetfile({ '*.*',  'All Files (*.*)'},'please select eventlist');

set(pb2,'Enable','on');

end

function uicreatelist(hObject,handels)

% path to USGS earthquake archive
web('http://earthquake.usgs.gov/earthquakes/search/','-browser')

end
