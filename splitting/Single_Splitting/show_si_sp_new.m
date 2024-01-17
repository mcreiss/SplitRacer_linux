function show_si_sp_new(sel_data)

% re-categorize results
% necessary inputs are selected in GUI and stored in sel_data

% Copyright 2016 M.Reiss and G.Rümpker, altered May 2019

% get station(s)
[selected_stations,stations] = read_stationfile(sel_data);

% loop around stations
for i=1:length(selected_stations)
    
    st_ind = strcmp(char(selected_stations(i)),stations.name);
    
    %% open files/ save output of analysis
    
    dir_save = [sel_data.results_folder,...
        char(selected_stations(i)),'_',char(stations.nc(st_ind)),'/'];
    
    dir_save_output = [sel_data.work_dir,'/graphics_output/Splitting/',...
        'Filter_',num2str(sel_data.p1),'-',num2str(sel_data.p2),'s_SNR_',...
        num2str(sel_data.snr),'_tw_',num2str(sel_data.NL),...
        '/',char(selected_stations(i)),...
        '/Single_Splitting/'];
    
    if ~exist(dir_save_output,'dir')
        mkdir(dir_save_output)
    else
        outf = warning_2buttons({'A folder with single splitting results',...
            'for this station already exists.'},'overwrite','cancel',...
            char(selected_stations(i)));
        if outf == 2
            continue
        end
    end
    
    %check if single splitting results exist
    st_load = char(strcat(dir_save,'/results_si_split.mat'));
    if ~exist(char(st_load),'file')
        w = warndlg('No pre-processed data file for this station exists',...
            ['Warning for station ', char(selected_stations(i))]);
        drawnow
        waitfor(w);
        continue
    end
    
    % check if single splitting categorization exists
    st_save = char(strcat(dir_save_output,'splitting_results.txt'));
    
    if exist(char(st_save),'file')
        outf = warning_2buttons(...
            {'A text file with single splitting results & categorization',...
            'for this station already exists.'},'overwrite','cancel',...
            char(selected_stations(i)));
        if outf == 1
            fileID1 = fopen(char(st_save), 'w');
        else
            continue
        end
    else
        fileID1 = fopen(char(st_save), 'w');
    end
    
    % write header, Splitting intensity added
    
    fprintf(fileID1, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s\n', ...
    'date', 'time', 'lat', 'lon', 'depth', 'mag', 'dist', 'baz', 'cordeg',...
    'phase','phi', 'delta', 'err_phi_min', 'err_phi_max', 'err_dt_min', ...
    'err_dt_max', 'confidence_level', 'SplitInt', 'SplitInt_err_min',...
    'SplitInt_err_max', 'category');

    % check if event list for joint splitting analysis exist
    el_st_save = char(strcat(dir_save,'phases_js.mat'));
    
    if exist(char(el_st_save),'file')
        flag = warning_2buttons(...
            ['A file with saved phases for joint splitting analysis', ...
            ' for this station already exists.'],...
            'overwrite','cancel',char(selected_stations(i)));
        if flag == 1
            delete(el_st_save)
        else
            continue
        end
        
    end
    
    % open figure
    split_fig = figure('Name','SplitRacer 2.0 - Single Splitting Analysis',...
        'NumberTitle','off',...
        'units','normalized','position',[.1 .1 .9 .8],...
        'KeyPressFcn',{@keypress});
    tgroup = uitabgroup('Parent',split_fig);
    movegui(split_fig,'center')
    
    % load results from previous run
    load([dir_save,'/results_si_split.mat'])
    load([dir_save,'/add_info.mat'])
       
    ana_phases = fieldnames(results);
    
    % plot results per event
    for ii = 1:length(ana_phases)
        
        name_event = ['event' int2str(ii)];
        tab = uitab(tgroup,'Title',['Event ', num2str(ii),'/',...
            num2str(length(ana_phases))]);
        tgroup.SelectedTab = tab;
        plot_si_sp(results.(name_event),add_info,tab);
        
        % categorization
        ui_si_split(results.(name_event),add_info,tab,fileID1,dir_save)
        
        % save graphic
        split_fig.PaperPositionMode = 'auto';
        set(gcf,'renderer','opengl')
        print(split_fig,[dir_save_output,'/event_', num2str(ii),'.png'],...
            '-dpng','-r0')
        
        delete(tab)
    end
    
           
    fclose(fileID1);
    close(split_fig)
    
end

end