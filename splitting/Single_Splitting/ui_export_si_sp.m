function ui_export_si_sp(hObject,handles)

% export waveforms, energy grid etc
% Copyright 2016 M.Reiss and G.Rümpker

global sel_data

% loop for single splitting analysis around selected stations

% get station(s)
[selected_stations,stations] = read_stationfile(sel_data);

% loop around stations
for i=1:length(selected_stations)
    
    wait_string = sprintf(...
        'Exporting data for station %s ...',...
        char(selected_stations(i)));
    
    h = waitbar(0,wait_string,'CreateCancelBtn',...
        'setappdata(gcbf,''canceling'',1)');
    
    setappdata(h,'canceling',0);
    
    st_ind = strcmp(char(selected_stations(i)),stations.name);
    
    
    %% open files/ save output of analysis
    
    dir_get = [sel_data.results_folder,...
        char(selected_stations(i)),'_',char(stations.nc(st_ind)),'/'];
    
    %check if single splitting results exist
    st_load = char(strcat(dir_get,'/results_si_split.mat'));
    
    if ~exist(char(st_load),'file')
        w = warndlg('No pre-processed data file for this station exists',...
            ['Warning for station ', char(selected_stations(i))]);
        drawnow
        waitfor(w);
        continue
    end
    
    % directory for exporting waveforms, time windows etc.
    dir_save_output = [sel_data.work_dir,'/graphics_output/Splitting/',...
        'Filter_',num2str(sel_data.p1),'-',num2str(sel_data.p2),'s_SNR_',...
        num2str(sel_data.snr),'_tw_',num2str(sel_data.NL),...
        '/',char(selected_stations(i)),...
        '/Single_Splitting/waveform_data/'];
    
    if exist(dir_save_output,'dir')
        flag = warning_2buttons(...
            ['A folder with waveform data', ...
            ' for this station already exists.'],...
            'overwrite','cancel',char(selected_stations(i)));
        if flag == 2
            continue
        end
    else
        mkdir(dir_save_output)
    end
    
    % load results from previous run
    load([dir_get,'/results_si_split.mat'])
    load([dir_get,'/add_info.mat'])
    
    events = fieldnames(results);
    
    for no_events = 1:length(events)
        
        if getappdata(h,'canceling')
            break
        end
        
        waitbar(no_events /length(events)) 
        
        cur_ev = ['event' int2str(no_events)];
        disp(cur_ev)
        % rewrite waveforms to store as ascii
        
        %% 100s N/E
        f1 = [dir_save_output,cur_ev,'_tiNE.txt'];
        
        TNE(:,1) = results.(cur_ev).times;
        TNE(:,2) = results.(cur_ev).north3;
        TNE(:,3) = results.(cur_ev).east3;
        
        dlmwrite(f1,TNE,'delimiter','\t','precision',4)
        
        %% 100s R/T
        f2 = [dir_save_output,cur_ev,'_tiRT.txt'];
        
        TRT(:,1) = results.(cur_ev).times;
        TRT(:,2) = results.(cur_ev).radc;
        TRT(:,3) = results.(cur_ev).trac;
        
        dlmwrite(f2,TRT,'delimiter','\t','precision',4)
        
        %% N/E original particle motion        
        f3 = [dir_save_output,cur_ev,'_NE_orig_pm.txt'];
        
        NE_pm(:,1) = results.(cur_ev).northcut;
        NE_pm(:,2) = results.(cur_ev).eastcut;
        
        dlmwrite(f3,NE_pm,'delimiter','\t','precision',4)
        
        %% N/E long-period particle motion
        f4 = [dir_save_output,cur_ev,'_NE_lp_pm.txt'];
        
        NE_lp_pm(:,1) = results.(cur_ev).northcutb;
        NE_lp_pm(:,2) = results.(cur_ev).eastcutb;
        
        dlmwrite(f4,NE_lp_pm,'delimiter','\t','precision',4)
        
        %% R/T original particle motion
        f5 = [dir_save_output,cur_ev,'_RT_orig_pm.txt'];
        
        RT_orig_pm(:,1) = results.(cur_ev).tra;
        RT_orig_pm(:,2) = results.(cur_ev).rad;
        
        dlmwrite(f5,RT_orig_pm,'delimiter','\t','precision',10)
        
        %% R/T corrected particle motion
        f6 = [dir_save_output,cur_ev,'_RT_corr_pm.txt'];
        
        RT_corr_pm(:,1) = results.(cur_ev).invtra;
        RT_corr_pm(:,2) = results.(cur_ev).invrad;
        
        dlmwrite(f6,RT_corr_pm,'delimiter','\t','precision',4)
        
        %% used timewindows
        f7 = [dir_save_output,cur_ev,'_TW.txt'];
        
        TW(:,1) = results.(cur_ev).t1vec';
        TW(:,2) = results.(cur_ev).t2vec';
        
        dlmwrite(f7,TW,'delimiter','\t','precision',4)
        
        %% used confidence matrix
        f8 = [dir_save_output,cur_ev,'_energy_grid.txt'];
        
        delta_range = repmat((results.(cur_ev).delta_range'),181,1);
        EG(:,1) = reshape(delta_range,[1, (...
            (length(results.(cur_ev).delta_range))*...
            (length(results.(cur_ev).phi_range)) )]);
        
        phi_range = repmat(results.(cur_ev).phi_range,40,1);
        EG(:,2) = reshape(phi_range,[1, (...
            (length(results.(cur_ev).delta_range))*...
            (length(results.(cur_ev).phi_range)) )]);
        
        EG(:,3) = reshape(results.(cur_ev).mean_energy,[1,(...
            (length(results.(cur_ev).delta_range))*...
            (length(results.(cur_ev).phi_range)) )]);

        dlmwrite(f8,EG,'delimiter','\t','precision',4)
        
        clear f1 f2 f3 f4 f5 f6 f7 f8
        clear TNE TRT NE_pm NE_lp_pm RT_orig_pm RT_corr_pm TW EG
        
    end
delete(h)   
end


end