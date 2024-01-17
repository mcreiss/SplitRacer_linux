function quality_check(sel_data)

% quality check for phases after inital preparation - loop for all stations

% Copyright 2016 M.Reiss and G.Rümpker

% get selected stations from GUI
[selected_stations,~] = read_stationfile(sel_data);

% get/set directories
dir_get = [sel_data.set_folder,'/pre-processing/']; 
dir_save = [sel_data.set_folder,'/quality_check/'];
mkdir(dir_save)

% loop for all selected stations
for i = 1:length(selected_stations)
        
    % check if same pre-processing was done before
    st_to_save = char(strcat(dir_save,selected_stations(i),'.mat'));
    
    if exist(st_to_save,'file')
        outf = warning_3buttons(...
            'A quality check .mat-file for this station already exists',...
            'append','overwrite',char(selected_stations(i)));
        if outf == 1
            load(char(strcat(dir_save,selected_stations(i),...
                '_last_event.mat')));
            start_index = n+1;
            load(st_to_save)
            prev_events = final_events;
        elseif outf == 2
            start_index = 1;
            prev_events = 0;
        else
            continue
        end
    else
        start_index = 1;
        prev_events = 0;
    end
    
    % check if pre-requisite for quality check exists
    st_to_read = char(strcat(dir_get,selected_stations(i),'.mat'));
    if ~exist(st_to_read,'file')
        w = warndlg('No pre-processed data file exists for this station',...
            ['Warning for ',char(selected_stations(i)) ,' !']);
        drawnow
        waitfor(w);
        continue
    end
    
    % load *.mat file for station
    load(st_to_read)
    
    % call subroutine for quality check
    final_events = qc_phases(data,char(selected_stations(i)),...
        prev_events,start_index,sel_data);
    
    % save output of quality check
    save(st_to_save,'final_events');
    
    % save number of events for if data is added later
    n = length(fieldnames(data));
    save(char(strcat(dir_save,selected_stations(i),'_last_event.mat')),'n');
    
    
end
end