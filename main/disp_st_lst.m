function [disp_stations] = disp_st_lst

% read station.lst for displaying stations in pulldown menu
% get input from sel_data

% Copyright 2016 M.Reiss and G.Rümpker

global sel_data

station_path = [sel_data.work_dir,'/station.lst'];

fileID = fopen(station_path);
C = textscan(fileID,'%s %s %f %f');
fclose(fileID);

stations.name = C{1,1};
stations.nc = C{1,2};
stations.lat = C{1,3};
stations.lon = C{1,4};

disp_station(2:length(stations.name)+1) = stations.name;
disp_station{1} = 'all';
disp_stations = disp_station';

end