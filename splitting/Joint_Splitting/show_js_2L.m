function show_js_2L(sel_data)

% callback for button show joint splitting for two layers

% all necessary variales are taken from GUI input and stored in sel_data

% Copyright 2016 M.Reiss and G.Rümpker

% get station(s)
[selected_stations,stations]=read_stationfile(sel_data);

% check which results should be shown
sel_data.cat = warning_2buttons(...
    ['Would you like to show the analysis for all saved phases',...
    'or only for phases previously categrozied as "good" or "null" '],...
    'all phases','<html>good and<br>nulls','network');
if sel_data.cat == 1
    sel_data.cat = 'all';
else
    sel_data.cat = 'nog';
end

% loop around stations
for i=1:length(selected_stations)
    
    st_ind = strcmp(char(selected_stations(i)),stations.name);
    
    % define directories
    dir_get = sel_data.results_folder;
    dir_save =  char(strcat(dir_get,...
        char(selected_stations(i)),'_',...
        char(stations.nc(st_ind)),'/'));
       
    fname = ['/results_js_2L_',sel_data.cat, '.mat'];
    
    % load data
    if exist([dir_save,fname])
        load([dir_save,fname])
    else
        w = warndlg('No joint splitting results for this station exist',...
            ['Warning for station ',char(selected_stations(i)) ]);
        drawnow
        waitfor(w);
        continue
    end
    
    % plot results
    plot_js_2L(results,char(selected_stations(i)),...
        char(stations.nc(st_ind)),sel_data);
    
end

end