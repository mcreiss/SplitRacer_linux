function results = re_scale(results,info)

% changes display interval for fast polarization

% usage:
% results: results from single splitting analysis
% i_phase: number of phase used
% info: struct with settings

% Copyright 2016 M.Reiss and G.Rümpker

sp = results.phi_range(2)-results.phi_range(1);
new_energy = zeros(size(results.mean_energy));
new_ic_phi = zeros(18,1);

if info.fa_area == 90
    
    % re arrange energy grid
    results.phi_range = -90:sp:90;
    new_energy(:,1:90) = results.mean_energy(:,92:end);
    new_energy(:,91:end) = results.mean_energy(:,1:91);
    results.mean_energy = new_energy;
    
    % re arrange bin values for histogram
    new_ic_phi(1:9) = results.ic_phi(10:end);
    new_ic_phi(10:end) = results.ic_phi(1:9);
    results.ic_phi = new_ic_phi;
    
elseif info.fa_area == 0
    
    % re arrange energy grid
    results.phi_range = 0:sp:180;
    new_energy(:,1:91) = results.mean_energy(:,91:end);
    new_energy(:,92:end) = results.mean_energy(:,1:90);
    results.mean_energy = new_energy;
    
     % re arrange bin values for histogram
    new_ic_phi(1:9) = results.ic_phi(10:end);
    new_ic_phi(10:end) = results.ic_phi(1:9);
    results.ic_phi = new_ic_phi;
    
    
end

% recalculate splitting values and error bars

[results.phi, results.delta, results.err_phi, results.err_dt] = ...
    c95Conf(results.delta_range(length(results.delta_range)), ...
    results.mean_energy', results.level, info.fa_area);

end