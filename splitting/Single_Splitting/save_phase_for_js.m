function save_phase_for_js(results,cat,dir_save)

% write .mat file for joint splitting analysis
% usage:
% results: results from single splitting analysis
% dir_save: directory

% Copyright 2016 M.Reiss and G.Rümpker

% remove unneccesary fields

results = rmfield(results,'z_amp');
results = rmfield(results,'n_amp');
results = rmfield(results,'e_amp');
results = rmfield(results,'time');
results = rmfield(results,'t1vec');
results = rmfield(results,'t2vec');
results = rmfield(results,'ic_phi');
results = rmfield(results,'ic_delta');
results = rmfield(results,'mean_energy');
results = rmfield(results,'delta_range');
results = rmfield(results,'phi_range');  
results = rmfield(results,'level');
results = rmfield(results,'phi');
results = rmfield(results,'delta');
results = rmfield(results,'err_phi');
results = rmfield(results,'err_dt');
results = rmfield(results,'invrad');
results = rmfield(results,'invtra');
results = rmfield(results,'energy_red');

% save category

results.cat = cat;

% check if .mat file already exists

if exist([dir_save,'phases_js.mat'])
    
    load([dir_save,'phases_js.mat'])
    old_events = fieldnames(data);
    no_events = length(old_events);
    new_event = no_events +1;
    new_fieldname = ['event',num2str(new_event)];
    data.(new_fieldname) = results;
    save([dir_save,'/phases_js.mat'],'data')
    
% otherwise just add new phases to .mat file    
else
    data.event1 = results;
    save([dir_save,'/phases_js.mat'],'data')     
end

end