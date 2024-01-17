function misalignment_check(sel_data)

% misaligment per station from previous quality check -
% loop around all selected stations

% Copyright 2016 M.Reiss and G.Rümpker

[selected_stations,~] = read_stationfile(sel_data);

% get directory
dir_get = [sel_data.set_folder,'/quality_check/'];

% create folder to save output
dir_save = [sel_data.work_dir,'/graphics_output/pre-processing/Filter_',...
    num2str(sel_data.p1),'-',num2str(sel_data.p2),'s_SNR_',...
    num2str(sel_data.snr),'/'];

for i=1:length(selected_stations)
       
    % check if pre-processed data exists
    station_file = char(strcat(dir_get,selected_stations(i),'.mat'));
    
    if exist(station_file,'file')

    else
        w = warndlg('No pre-processed data file exists for this station',...
            ['Warning for station ', char(selected_stations(i)),'!']);
        drawnow;
        waitfor(w);
        continue
    end
    
    % load file from quality check
    load(station_file);
    
    if ~isempty(final_events)
    
    % call function to calculate misaligment
    [baz_cor, baz_fig] = baz_stat(final_events,char(selected_stations(i)));
    
    % save as figure
    mkdir(dir_save)
    baz_fig.PaperPositionMode = 'auto';
    print(baz_fig,[dir_save,char(selected_stations(i)),'_baz_stat.png'],'-dpng','-r0')
    
    % write value in *.mat-file from quality check
    if isfield(final_events, 'cor_deg')
                
        outf = warning_2buttons(...
            'A misalignment corrections for this station already exists.',...
            'overwrite','cancel',char(selected_stations(i)));
        if outf == 1
           final_events.cor_deg = baz_cor;
        else   
            continue
        end
    else
        final_events.cor_deg = baz_cor;
    end
    
    save(char(strcat(dir_get,selected_stations(i),'.mat')),'final_events');
    else
        w = warndlg('Sorry, there is no data for this station!',...
            ['Warning for station ', char(selected_stations(i)),'!']);
        drawnow;
        waitfor(w);
    end

end

end