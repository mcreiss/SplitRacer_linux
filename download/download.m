function download(sel_data)

%% select events within specified range

% Copyright 2016 M.Reiss und G. Rümpker, altered May 2019

%read eventlist
fileID = fopen([sel_data.Eventlist_path,sel_data.Eventlist]);
formatSpec = '%s';
N = 6;
C_header = textscan(fileID,formatSpec,N,'Delimiter','|');
C = textscan(fileID,'%s %f %f %f %f %*[^\n]');
fclose(fileID);

date = C{1,1};
events.lat = C{1,2};
events.lon = C{1,3};
events.depth = C{1,4};
events.mag = C{1,5};

%read data center and stations
fileID2 = fopen([sel_data.Eventlist_path,'data_centers.dat']);
C2 = textscan(fileID2,'%s %s');
fclose(fileID2);

fileID3 = fopen([sel_data.work_dir,'/available_stations.txt']);
formatSpec = '%s';
N = 17;
C3_header = textscan(fileID3,formatSpec,N,'Delimiter','|');
C3 = textscan(fileID3,'%s %s %s %s %f %f %f %*[^\n]','Delimiter','|');
fclose(fileID3);

stations.nc = C3{1,1};
stations.name = C3{1,2};
stations.loc = C3{1,3};
stations.lat = C3{1,5};
stations.lon = C3{1,6};
stations.elevation = C3{1,7};

% delete double entries in available_stations.lst
test_stations = strcat(C3{1,2},{' '},C3{1,3});
[~,ia,~]=unique(test_stations);

stations.nc = stations.nc(ia);
stations.name = stations.name(ia);
stations.loc = stations.loc(ia);
stations.lat = stations.lat(ia);
stations.lon = stations.lon(ia);
stations.elevation = stations.elevation(ia);

find_stations = strcmp('all',char(sel_data.station));

if find_stations == 0
    str_cut=strsplit(char(sel_data.station));
    selected_stations = str_cut(1);
    selected_locs = str_cut(2);
elseif find_stations == 1
    selected_stations = stations.name;
    selected_locs = stations.loc;
end

station_list = strcat(sel_data.work_dir,'/station.lst');

% check if previous station list exists
if exist(char(station_list),'file')
    list_saved =  warning_3buttons('A station list already exists.',...
        'overwrite','append',' ');
    if list_saved == 1
        fileID6 = fopen(char(station_list), 'w');
    elseif list_saved == 2
        fileID6 = fopen(char(station_list), 'a');
    else
        return
    end
else
    fileID6 = fopen(char(station_list), 'w');
end

% check which events lie within specified range, loop over all stations
% possible
for i=1:length(selected_stations)
    
    st_ind_tmp = strcmp(char(selected_stations(i)),stations.name);
    st_ind = find(st_ind_tmp, 1, 'first');
    
    %write log file for successfully downloaded data
    req_data_file = strcat(sel_data.work_dir,'/data_request_',...
        selected_stations(i),'_',sel_data.nc);
    
    if exist(char(req_data_file),'file')
        st_saved = warning_3buttons({
            'A log file with successfully requested data',...
            'for this station already exists.'},'overwrite','append',...
            char(selected_stations(i)));
        if st_saved == 1
            fileID4 = fopen(char(req_data_file), 'w');
        elseif st_saved == 2
            fileID4 = fopen(char(req_data_file), 'a');
        else
            continue
        end
    else
        fileID4 = fopen(char(req_data_file), 'w');
    end
    
    % write log file for unavailable data
    failed_req = strcat(sel_data.work_dir,'/failed_data_request_',...
        selected_stations(i),'_',sel_data.nc);
    
    if exist(char(failed_req),'file')
        outf = warning_2buttons({
            'A log file with failed requested data', ...
            'for this station already exists.'},'overwrite','append',...
            char(selected_stations(i)));
        if outf == 1
            fileID5 = fopen(char(failed_req), 'w');
        else
            fileID5 = fopen(char(failed_req), 'a');
        end
    else
        fileID5 = fopen(char(failed_req), 'w');
    end
    
    % write station.lst
    % only if station has not been saved before
    if ~exist('st_saved') || exist('list_saved') && list_saved == 1
        fprintf(fileID6, '%s %s %f %f \n', char(stations.name(st_ind)),...
            char(stations.nc(st_ind)),stations.lat(st_ind),...
            stations.lon(st_ind));
    end
    
    failed_request = 0;
    
    dir_save = char(strcat(sel_data.work_dir,'/mseed_files/',...
        selected_stations(i),'_',sel_data.nc,'/'));
    mkdir(dir_save);
    
    % get information on station
    index_dc = find(strcmp(C2{1,1}, sel_data.data_center)==1);
    dc_url = C2{1,2}(index_dc);
    find_ind = strfind(char(dc_url), '/dataselect/1/');
    
    % check whether location code was used
    if ~isempty(char(selected_locs(i)))  % if yes
        request_url = strcat('curl -L --digest "',dc_url{1,1}(1:find_ind),...
            'station/1/query?network=',sel_data.nc, '&station=',...
            char(selected_stations(i)), ...
            '&loc=', char(selected_locs(i)), '&channel=',sel_data.stream,...
            '*&format=text&level=channel" -o ');
    else
        request_url = strcat('curl -L --digest "',dc_url{1,1}(1:find_ind),...
            'station/1/query?network=',sel_data.nc, '&station=',...
            char(selected_stations(i)), '&loc=--', ...
            '&channel=',sel_data.stream,...
            '*&format=text&level=channel" -o ');
    end
    
    output = strcat(dir_save,'/channel_info.txt');
    req_line =  sprintf('%s %s', char(request_url),char(output));
    system(req_line);
    
    % find start and end rows according to specified dates
    sd_find = strfind(date,char(sel_data.start_date));
    ed_find = strfind(date,char(sel_data.end_date));
    
    start_row = find(~cellfun(@isempty,sd_find),1,'first');
    end_row = find(~cellfun(@isempty,ed_find),1,'last');
    
    if isempty(start_row)
        w = warndlg(['The specified start date does not exist in the event',...
            ' list. Please choose an appropriate date!'],...
            ['Warning for station ', char(selected_stations(i))]);
        drawnow
        waitfor(w);
        return
    end
    
    if isempty(end_row)
        w = warndlg(['The specified end date does not exist in the event',...
            ' list. Please choose an appropriate date!'],...
            ['Warning for station ', char(selected_stations(i))]);
        drawnow
        waitfor(w);
        return
    end
    
    e_count = 0;
    
    wait_string = sprintf('downloading data for station %s ...',...
        char(selected_stations(i)));
    
    h = waitbar(0,wait_string,'CreateCancelBtn',...
        'setappdata(gcbf,''canceling'',1)');
    setappdata(h,'canceling',0);
    
    % loop for all events
    for n = start_row:end_row
        
        e_count = e_count +1;
        if getappdata(h,'canceling')
            break
        end
        waitbar(e_count/(end_row-start_row))
        events.year(n,:) = str2double(date{n,1}(1:4));
        events.month(n,:) = str2double(date{n,1}(6:7));
        events.day(n,:) = str2double(date{n,1}(9:10));
        events.hour(n,:) = str2double(date{n,1}(12:13));
        events.min(n,:) = str2double(date{n,1}(15:16));
        events.sec(n,:) = str2double(date{n,1}(18:23));
        
        %check if event above specified magnitude
        if ge((events.mag(n)),sel_data.mag)
            
            %calculate distance between event and station
            [distance,~,baz]=delaz(events.lat(n),events.lon(n),...
                stations.lat(st_ind),stations.lon(st_ind),0);
            
            if ge(distance,sel_data.min_dist) && ...
                    le(distance,sel_data.max_dist)
                
                %calculate one hour after event time
                max_julday = jul_day(events.year(n),12,31);
                julday_event = jul_day(events.year(n),events.month(n),...
                    events.day(n));
                next_hour = events.hour(n)+1;
                next_julday = julday_event;
                next_year= events.year(n);
                
                if next_hour>23
                    next_hour= 0;
                    next_julday= julday_event+1;
                    if next_julday> max_julday
                        next_julday = 1;
                        next_year=events.year(n)+1;
                    end
                end
                
                [~,next_month,next_day]=cal_day(next_year,next_julday);
                
                index_dc = find(strcmp(C2{1,1}, sel_data.data_center)==1);
                dc_url = C2{1,2}(index_dc);
                
                % built string for fdsn request
                
                %start time
                st_time = strcat(num2str(events.year(n)),'-',...
                    sprintf('%02d',events.month(n)),'-',...
                    sprintf('%02d',events.day(n)),'T',...
                    sprintf('%02d',events.hour(n)),':',...
                    sprintf('%02d',events.min(n)),':',...
                    sprintf('%05.2f',events.sec(n)),'Z');
                
                %end time
                e_time = strcat(num2str(next_year),'-',...
                    sprintf('%02d',next_month),'-',...
                    sprintf('%02d',next_day),'T',...
                    sprintf('%02d',next_hour),':',...
                    sprintf('%02d',...
                    events.min(n)),':',...
                    sprintf('%05.2f',events.sec(n)),'Z');
                
                name_mseed1 = strcat(selected_stations(i),...
                    '_',sel_data.nc,'_', num2str(events.year(n)),'-',...
                    sprintf('%02d', events.month(n)),'-', ...
                    sprintf('%02d', events.day(n)),'-', ...
                    sprintf('%02d', events.hour(n)),'-', ...
                    sprintf('%02d', events.min(n)),'-',...
                    sprintf('%05.2f',events.sec(n)), '.mseed');
                
                name_mseed = strcat(dir_save,name_mseed1);
                
                %check whether location code was chosen
                    if ~isempty(char(selected_locs(i)))
                        disp(['Location code is used for station',...
                            char(selected_stations(i))])
                        req_line1 = strcat('curl -L --digest "',...
                            dc_url','query?net=',...
                            sel_data.nc, '&sta=',selected_stations(i), ...
                            '&loc=',char(selected_locs(i)),...
                            '&cha=',sel_data.stream, '*&starttime=',st_time,...
                            '&endtime=',e_time,'" -o ');
                        sel_loc = selected_locs(i);
                    else % default, empty location code
                        req_line1 = strcat('curl -L --digest "',dc_url',...
                            'query?net=',...
                            sel_data.nc, '&sta=',selected_stations(i), ...
                            '&loc=--','&cha=',sel_data.stream, ...
                            '*&starttime=',st_time,...
                            '&endtime=',e_time,'" -o ');
                        sel_loc = {'-'};
                    end
                
%% in case you wanted to use a password                
%                 req_line1 = strcat('curl -L --digest --user username:password "',dc_url','queryauth?net=',...
%                     sel_data.nc, '&sta=',selected_stations(i), ...
%                     '&cha=',sel_data.stream, '*&starttime=',st_time,...
%                     '&endtime=',e_time,'" -o ');
%%               
                req_line = ...
                    sprintf('%s %s',char(req_line1),char(name_mseed));
                
                % sent fdsn request
                [~, cmdout] = system(req_line);
                disp(cmdout);
                
                %check if data is downloaded
                MyFileInfo = dir(char(name_mseed));
                
                if isempty(MyFileInfo) || isstruct(MyFileInfo) && MyFileInfo.bytes == 0
                    disp('request returned no data')
                    fprintf(fileID5, '%s %s \n', st_time, ...
                        'request returned no data');
                    delete(char(name_mseed));
                    failed_request = failed_request +1;
                else
                    fprintf(fileID4, ...
                        ['%4d %02d %02d %02d %02d %05.2f %7.2f %7.2f',...
                        '%7.2f %5.1f% 4.1f %3.1f %s %s\n'], ...
                        events.year(n) ,events.month(n),events.day(n),...
                        events.hour(n),events.min(n),events.sec(n),...
                        events.lat(n),events.lon(n),distance,baz,...
                        events.depth(n),  events.mag(n), ...
                        char(sel_loc), char(strcat(...
                        '/mseed_files/', selected_stations(i),'_',...
                        sel_data.nc,'/',name_mseed1)));
                end
                
            end
        end
        
        
    end
    
    delete(h);
    fclose(fileID4);
    fclose(fileID5);
    
    if failed_request == 0
        delete(char(failed_req));
    end
    
end

fclose(fileID6);

end