function ui_export_js(hObject,handles,flag)

% export waveforms, energy grid etc.

% Copyright 2016 M.Reiss and G.Rümpker

global sel_data

format short

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
    
    % check which results should be exported
    sel_data.cat_phases = warning_2buttons(...
        ['Would you like to do the analysis for all saved phases',...
        'or only for phases previously categrozied as "good" or "null" '],...
        'all phases','<html>good and<br>nulls',char(selected_stations(i)));
    if sel_data.cat_phases == 1
        cat = 'all';
    else
        cat = 'nog';
    end
    %% open files/ save output of analysis
    
    dir_get = [sel_data.results_folder,...
        char(selected_stations(i)),'_',char(stations.nc(st_ind)),'/'];
    
    %check if joint splitting results exist
    
    if flag == 1
        %for one layer
        st_load = char(strcat(dir_get,'/results_js_', cat, '.mat'));
        folder_name = ['JointSplit_1Layer/',cat,'/'];
    else
        % for two layers
        st_load = char(strcat(dir_get,'/results_js_2L_', cat, '.mat'));
        folder_name = ['JointSplit_2Layer/',cat,'/'];
    end
    
    if ~exist(char(st_load),'file')
        w = warndlg('No pre-processed data file for this station exists',...
            ['Warning for station ', char(selected_stations(i))]);
        drawnow
        waitfor(w);
        delete(h)
        continue
    end
    
    
    % directory for exporting waveforms, time windows etc.
    dir_save = [sel_data.work_dir,'/graphics_output/Splitting/',...
        'Filter_',num2str(sel_data.p1),'-',num2str(sel_data.p2),'s_SNR_',...
        num2str(sel_data.snr),'_tw_',num2str(sel_data.NL),...
        '/',char(selected_stations(i)),'/',folder_name] ;
    
    dir_save_output = [dir_save,'/waveform_data/'];
    
    if exist(dir_save_output,'dir')
        outf = warning_2buttons(...
            ['A folder with waveform data', ...
            ' for this station already exists.'],...
            'overwrite','cancel',char(selected_stations(i)));
        if outf == 2
            continue
        end
    else
        mkdir(dir_save_output)
    end
    
    % load results from previous run
    load(st_load)
    load([dir_get,'/add_info.mat'])
    
    fn = fieldnames(results);
    find_events = strfind(fn,'event');
    fe_log = ~cellfun(@isempty,find_events);
    events = fn(fe_log);
    no_events = length(events);  
    
    for event = 1:no_events
        
        if getappdata(h,'canceling')
            break
        end
        
        waitbar(event /no_events)
        
        cur_ev = events{event};
        
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
        f6 = [dir_save_output,cur_ev,'_RT_orig_pm.txt'];
        
        RT_corr_pm(:,1) = results.(cur_ev).invtra;
        RT_corr_pm(:,2) = results.(cur_ev).invrad;
        
        dlmwrite(f6,RT_corr_pm,'delimiter','\t','precision',4)
        
        %% used timewindows
        f7 = [dir_save_output,cur_ev,'_TW.txt'];
        
        TW(:,1) = results.(cur_ev).t1vec';
        TW(:,2) = results.(cur_ev).t2vec';
        
        dlmwrite(f7,TW,'delimiter','\t','precision',4)
        
        
        clear f1 f2 f3 f4 f5 f6 f7 f8
        clear TNE TRT NE_pm NE_lp_pm RT_orig_pm RT_corr_pm TW
        
    end
    
    %% export used confidence matrix
    
    if flag == 1
        f8 = [dir_save_output,'energy_grid.txt'];
        
        size_em = size (results.Ematrix);
        
        dr = linspace(0,results.maxtime,size_em(2));
        delta_range = repmat(dr,size_em(1),1);
        pr = linspace(0-add_info.fa_area,180-add_info.fa_area,size_em(1));
        phi_range = repmat(pr,size_em(2),1);
        
        EG(:,1) = reshape(delta_range,[1, (...
            (length(dr))*...
            (length(pr)) )]);
        
        EG(:,2) = reshape(phi_range,[1, (...
            (length(dr))*...
            (length(pr)) )]);
        
        EG(:,3) = reshape(results.Ematrix,[1,(...
            (length(dr))*...
            (length(pr)) )]);
        
        dlmwrite(f8,EG,'delimiter','\t','precision',4)
        
        % write results to textfile
        
        txt = {'phi','dt','min err_phi','max err_phi', 'min err_dt',...
            'max err_dt', 'number of phases used',...
            'total energy reduction', 'confidence level' };
        
        ch_txt = cellstr(char(txt));
        
        vals = [results.phi results.delta results.err_phi results.err_dt ...
            event results.mean_energy_red results.level ];
        
        ch_vals = cellstr(num2str(vals(:)));
        
        output = [ch_txt ch_vals]';
        
        
        fileID = fopen([dir_save,'/results.txt'],'w');
        fprintf(fileID,'%s\t%s\n', output{:});
        fclose(fileID);
        
        % write file for GMT
        js_gmt(sel_data,dir_save,char(selected_stations(i)),results.phi,...
            results.delta, results.err_phi, results.err_dt)
        
    else
        f8 = [dir_save_output,'energy_grid_lower_layer.txt'];
        
        size_em = size (results.Ematrix_low);
        
        dr = linspace(0,results.maxtime,size_em(2));
        delta_range = repmat(dr,size_em(1),1);
        pr = linspace(0-add_info.fa_area,180-add_info.fa_area,size_em(1));
        phi_range = repmat(pr,size_em(2),1);
        
        EG(:,1) = reshape(delta_range,[1, (...
            (length(dr))*...
            (length(pr)) )]);
        
        EG(:,2) = reshape(phi_range,[1, (...
            (length(dr))*...
            (length(pr)) )]);
        
        EG(:,3) = reshape(results.Ematrix_low,[1,(...
            (length(dr))*...
            (length(pr)) )]);
        
        dlmwrite(f8,EG,'delimiter','\t','precision',4)
        
        f9 = [dir_save_output,'energy_grid_upper_layer.txt'];
        
        size_em = size (results.Ematrix_upp);
        
        dr = linspace(0,results.maxtime,size_em(2));
        delta_range = repmat(dr,size_em(1),1);
        pr = linspace(0-add_info.fa_area,180-add_info.fa_area,size_em(1));
        phi_range = repmat(pr,size_em(2),1);
        
        EG(:,1) = reshape(delta_range,[1, (...
            (length(dr))*...
            (length(pr)) )]);
        
        EG(:,2) = reshape(phi_range,[1, (...
            (length(dr))*...
            (length(pr)) )]);
        
        EG(:,3) = reshape(results.Ematrix_upp,[1,(...
            (length(dr))*...
            (length(pr)) )]);
        
        dlmwrite(f9,EG,'delimiter','\t','precision',4)
        
        % write results to textfile
        
        txt = {'phi','dt','min err_phi','max err_phi', 'min err_dt',...
            'max err_dt', 'number of phases used',...
            'total energy reduction', 'confidence level' };
        
        ch_txt = cellstr(char(txt));
        
        vals1 = [results.phiminval_low results.deltaminval_low ...
            results.err_phi_low results.err_dt_low ...
            event results.mean_energy_red results.level_low ];
        
        vals2 = [results.phiminval_upp results.deltaminval_upp ...
            results.err_phi_upp results.err_dt_upp ...
            event results.mean_energy_red results.level_upp ];
        
        ch_vals1 = cellstr(num2str(vals1(:)));
        ch_vals2 = cellstr(num2str(vals2(:)));
        
        output1 = [ch_txt ch_vals1]';
        output2 = [ch_txt ch_vals2]';
        
        
        fileID = fopen([dir_save,'/results.txt'],'w');
        fprintf(fileID,'%s\n', 'lower layer');
        fprintf(fileID,'%s\t%s\n', output1{:});
        fprintf(fileID,'%s\n', 'upper layer');
        fprintf(fileID,'%s\t%s\n', output2{:});
        fclose(fileID);
        
        
        % write file for GMT
        js_gmt(sel_data,dir_save,char(selected_stations(i)),...
            results.phiminval_low, results.deltaminval_low, ...
            results.err_phi_low, results.err_dt_low, ...
            results.phiminval_upp,results.deltaminval_upp, ...
            results.err_phi_upp, results.err_dt_upp)
    end
    
delete(h)    
end


end