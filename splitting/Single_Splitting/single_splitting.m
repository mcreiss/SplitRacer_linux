function single_splitting(sel_data)

% loop for single splitting analysis around selected stations
% Copyright 2016 M.Reiss and G.Rümpker, altered May 2019

% get station(s)
[selected_stations,stations] = read_stationfile(sel_data);

dir_get = [sel_data.set_folder,'/quality_check/'];

% loop around stations
for i=1:length(selected_stations)
    
    st_ind = strcmp(char(selected_stations(i)),stations.name);
    
    % check if pre-processed/quality checked data exists
    st_read = char(strcat(dir_get,selected_stations(i),'.mat'));
    
    if ~exist(st_read,'file')
        w = warndlg('No pre-processed data file for this station exists',...
            ['Warning for station ', char(selected_stations(i))]);
        drawnow
        waitfor(w);
        continue
    end
    
    % read saved phases for this station
    load(st_read);
    
    % check if misalignment correction exists and should be used
    if isfield(final_events, 'cor_deg')
        
        if strcmp(sel_data.cordeg,'mean')
            add_info.cordeg = final_events.cor_deg; %use mean value
        elseif strcmp(sel_data.cordeg,'single')
            add_info.cordeg = []; % use single value per event
        else
            add_info.cordeg = sel_data.cordeg; % use value chosen by user
        end

    else
        if strcmp(sel_data.cordeg,'mean')
            outf = warning_2buttons({...
                'No mean value to correct misalignment exists. ',...
                'You can continue using the  individual misalignment values ?'},...
                'yes','no',char(selected_stations(i)));
            if outf == 1
                add_info.cordeg = [];
            else
                continue
            end
        else
            add_info.cordeg = [];
        end
    end
    
    %% creater folder and open textfile to save output of analysis
    
    dir_save = [sel_data.results_folder,...
        char(selected_stations(i)),'_',char(stations.nc(st_ind)),'/'];
    mkdir(dir_save)
    
    % check if single splitting results exist
    st_save = char(strcat(dir_save,'/results_si_split.mat'));
    
    if exist(char(st_save),'file')
        outf = warning_2buttons(...
            {'A file with single splitting results',...
            'for this station already exists.'},'overwrite','cancel',...
            char(selected_stations(i)));
        if outf == 1
            delete(st_save)
        elseif outf == 2
            continue
        end
    end
    
    % check if file for joint splitting analysis exist
    el_st_save = char(strcat(dir_save,'phases_js.mat'));
    
    if exist(char(el_st_save),'file')
        flag = warning_2buttons(...
            ['A file with saved phases for joint splitting analysis',...
            ' for this station already exists.'],...
            'overwrite','cancel',char(selected_stations(i)));
        if flag == 2
            continue
        elseif flag == 1
            delete(el_st_save)
        end
    end
    
    % only use information of phases fulfilling previous quality criteria
    events = fieldnames(final_events);
    ts = strfind(events,'event');
    tsd = sum(cell2mat(ts));
    events = events(1:tsd);
    no_up = 0;
    
    % gather additional needed information in one struct
    add_info.tw_inp = 1;
    add_info.p1 = sel_data.p1;
    add_info.p2 = sel_data.p2;
    add_info.station = char(selected_stations(i));
    
    % set fast axis interval & number time windows
    add_info.NL = sel_data.NL;
    add_info.fa_area = sel_data.fa_area;
    
    % set up waitbar
    wait_string = sprintf(...
        'Single splitting analysis for station %s ...',...
        char(selected_stations(i)));
    
    h = waitbar(0,wait_string,'CreateCancelBtn',...
        'setappdata(gcbf,''canceling'',1)');
    
    setappdata(h,'canceling',0);
    
    %% analyze phases
    
    % loop over all events per station
    for ife = 1: length(events)

        if getappdata(h,'canceling')
            break
        end
        
        waitbar(ife /length(events))
        
        fn = events{ife};
        
        % loop over phases per event
        for an_phases = 1:length(final_events.(fn).phases_to_analyze)
        
        i_phase = final_events.(fn).phases_to_analyze(an_phases);
            
            if final_events.(fn).phases(i_phase).tw > 1
                
                no_up = no_up+1;
                name_event = ['event' int2str(no_up)];
                results.(name_event) = ...
                    si_sp_analysis(final_events.(fn),i_phase,add_info);
            end
        end
    end
    
    delete(h)
       
    save([dir_save,'/results_si_split.mat'],'results')
    save([dir_save,'/add_info.mat'],'add_info')

    
    clear results ana_phases events tab
    
end

end
