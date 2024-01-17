function uistat(hObject,handles)

% export statistics of pre-processing

% Copyright 2016 M.Reiss and G.Rümpker

global sel_data

% calculation of misaligment per station from previous quality check

[selected_stations,stations] = read_stationfile(sel_data);

for i=1:length(selected_stations)
    
    st_ind = strcmp(char(selected_stations(i)),stations.name);
    
    % check if pre-processed data exists
    
    % get directory
    dir_qc = [sel_data.set_folder,'/quality_check/'];
    qc_station_file = char(strcat(dir_qc,selected_stations(i),'.mat'));
    
    if ~exist(qc_station_file,'file')
        f = warndlg('No pre-processed data file exists for this station',...
            ['Warning for station ', char(selected_stations(i)),'!']);
        drawnow
        waitfor(f);
        continue
    end
    
    %% check original number of events
    
    %read log file containing successfully downloaded data
    fileID1 = fopen([sel_data.work_dir,'/data_request_',...
        char(selected_stations(i)),'_',char(stations.nc(st_ind))]);
    C2 = textscan(...
        fileID1,'%f %f %f %f %f %f %f %f %f %f %f %f %s');
    fclose(fileID1);
    orig_no_events = length(C2{1,1});
    
    %% check number of events after initial pre-processing
    
    % get directory
    dir_ipp = [sel_data.set_folder,'/pre-processing/'];
    ipp = char(strcat(dir_ipp,selected_stations(i),'.mat'));
    % load *.mat file for station
    load(ipp)

    % get number of events & phases to analyze
    ipp_no_phases = 0;
    ipp_no_events = fieldnames(data);
    
    for ii = 1:length(ipp_no_events)
        
        fn = ipp_no_events{ii};
        phases = length(data.(fn).phases_to_analyze);
        ipp_no_phases = ipp_no_phases + phases;     
    
    end
    
    %% check number of events after visual quality check
    
    % load file from quality check
    load(qc_station_file);
    
    if ~isempty(final_events)

    qc_no_events = fieldnames(final_events);
    qc_no_phases = 0;

    ts = strfind(qc_no_events,'event');
    tsd = sum(cell2mat(ts));
    
    % loop over all events per station
    for ife = 1: tsd
        
        fn = ['event',num2str(ife)];
        
        % loop over phases per event
        for an_phases = 1:length(final_events.(fn).phases_to_analyze)

            i_phase = final_events.(fn).phases_to_analyze(an_phases);
            
            if final_events.(fn).phases(i_phase).tw > 1
                qc_no_phases = qc_no_phases +1;
                
            end
        end
    end
    
    %% write statistics in textfile
    
    text = {'no. of events total', 'no. of events above SNR cut-off',...
        'no. of phases above SNR cut-off', ['no. of events after visual',...
        'quality check'], 'no. of phases after visual quality check',...
        'mean misalignment'};
    vals = [orig_no_events length(ipp_no_events) ipp_no_phases ...
        length(qc_no_events) qc_no_phases final_events.cor_deg];
    
    % folder to save output
    dir_save = [sel_data.work_dir,'/graphics_output/pre-processing/Filter_',...
        num2str(sel_data.p1),'-',num2str(sel_data.p2),'s_SNR_',...
        num2str(sel_data.snr),'/'];
    
    file_name = [dir_save,char(selected_stations(i)),...
        '_pre_processing_stats.txt'];
    
    if exist(file_name,'file')
        
        % check if file already exists
        outf = warning_2buttons(...
            'Statistics already exist for this station',...
            'overwrite','cancel', char(selected_stations(i)));
        
        if outf == 1
            
            fileID2 = fopen(char(file_name), 'w');
            for j = 1:length(vals)
                fprintf(fileID2, '%s %f\n', char(text(j)),vals(j));
            end
            fclose(fileID2);
            
        end
        
    else
        
        fileID2 = fopen(char(file_name), 'w');
        for j = 1:length(vals)
            fprintf(fileID2, '%s %f\n', char(text(j)),vals(j));
        end
        fclose(fileID2);
        
        
    end
    end
end
    
end