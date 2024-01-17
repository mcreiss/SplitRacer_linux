function js_gmt(sel_data,dir_save,station,phi,delta,err_phi,err_dt,...
    phi2,delta2,err_phi2,err_dt2)

% write file to plot results in GMT

% usage:
% sel_data: struct with settings from GUI
% dir_save: target folder
% station: station name
% phi: fast polarization
% delta: delay time
% err_phi: errors in fast polarization
% err_dt: errors in delay time
% phi2: fast polarization
% delta2: delay time
% err_phi2: errors in fast polarization
% err_dt2: errors in delay time

% Copyright 2016 M.Reiss and G.Rümpker

% first read stations.lst with geo. coordinates
sta_file = [sel_data.work_dir,'/station.lst'];
fileID1 = fopen(sta_file);
sta_read = textscan(fileID1,'%s %s %f %f %f');
fclose(fileID1);

% find stations and get coordinates
sta_find = strcmp(sta_read{1,1},station);
lon = sta_read{1,4}(sta_find);
lat = sta_read{1,3}(sta_find);

if nargin == 7
    % for one layer joint splitting
    
    %joint splitting results
    splitting = ['/js_gmt.tab'];
    splitting_results = strcat(dir_save,splitting);
    fileID2 = fopen(splitting_results, 'w');
    
    % format lon lat phi dt
    fprintf(fileID2, '%f %f %f %f\n', lon, lat,phi,delta);
    fclose(fileID2);
    
    % error bars
    err_bar1 = ['/js_errbar1.tab'];
    err_bar1_results = strcat(dir_save,err_bar1);
    fileID3 = fopen(err_bar1_results,'w');
    % format lon lat dt_err_max phi_err_min phi_err_max
    fprintf(fileID3, '%f %f %f %f %f\n', lon, lat, err_dt(2), ...
        err_phi(1), err_phi(2));
    fprintf(fileID3, '%f %f %f %f %f\n', lon, lat, err_dt(2), ...
        err_phi(1)+180, err_phi(2)+180);
    fclose(fileID3);
    
    % error bars
    err_bar2 = ['/js_errbar2.tab'];
    err_bar2_results = strcat(dir_save,err_bar2);
    fileID4 = fopen(err_bar2_results,'w');
    % format lon lat dt_err_max phi_err_min phi_err_max
    fprintf(fileID4, '%f %f %f %f %f\n', lon, lat, err_dt(1), ...
        err_phi(1), err_phi(2));
    fprintf(fileID4, '%f %f %f %f %f\n', lon, lat, err_dt(1), ...
        (err_phi(1)+180), (err_phi(2)+180));
    fclose(fileID4);
    
else
    % for joint splitting 2 layer
    
    %joint splitting results
    splitting = ['/js_2L_gmt.tab'];
    splitting_results = strcat(dir_save,splitting);
    fileID2 = fopen(splitting_results, 'w');
    
    % format lon lat phi dt
    fprintf(fileID2, '%f %f %f %f\n', lon, lat,phi,delta);
    fprintf(fileID2, '%f %f %f %f\n', lon, lat,phi2,delta2);
    fclose(fileID2);
    
    % error bars
    err_bar1 = ['/js_2L_errbar1.tab'];
    err_bar1_results = strcat(dir_save,err_bar1);
    fileID3 = fopen(err_bar1_results,'w');
    % format lon lat dt_err_max phi_err_min phi_err_max
    fprintf(fileID3, '%f %f %f %f %f\n', lon, lat, err_dt(2), ...
        err_phi(1), err_phi(2));
    fprintf(fileID3, '%f %f %f %f %f\n', lon, lat, err_dt(2), ...
        err_phi(1)+180, err_phi(2)+180);
    fprintf(fileID3, '%f %f %f %f %f\n', lon, lat, err_dt2(2), ...
        err_phi2(1), err_phi2(2));
    fprintf(fileID3, '%f %f %f %f %f\n', lon, lat, err_dt2(2), ...
        err_phi2(1)+180, err_phi2(2)+180);
    fclose(fileID3);
    
    % error bars
    err_bar2 = ['/js_2L_errbar2.tab'];
    err_bar2_results = strcat(dir_save,err_bar2);
    fileID4 = fopen(err_bar2_results,'w');
    % format lon lat dt_err_max phi_err_min phi_err_max
    fprintf(fileID4, '%f %f %f %f %f\n', lon, lat, err_dt(1), ...
        err_phi(1), err_phi(2));
    fprintf(fileID4, '%f %f %f %f %f\n', lon, lat, err_dt(1), ...
        (err_phi(1)+180), (err_phi(2)+180));
    fprintf(fileID4, '%f %f %f %f %f\n', lon, lat, err_dt2(1), ...
        err_phi2(1), err_phi2(2));
    fprintf(fileID4, '%f %f %f %f %f\n', lon, lat, err_dt2(1), ...
        (err_phi2(1)+180), (err_phi2(2)+180));
    fclose(fileID4);
    
end

end