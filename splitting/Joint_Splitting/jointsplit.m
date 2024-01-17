function [data] = jointsplit(station,nw_code,sel_data)

% joint splitting routine for one layer

% usage:
% station: station name as specified in GUI
% nw_code: network code for station
% sel_data: stores all necessary input from GUI

% Copyright 2016 M.Reiss and G.Rümpker, altered May 2019

%set data directories
dir_get = strcat(sel_data.results_folder,station, '_',...
    nw_code,'/');

%% import data

load(strcat(dir_get,'phases_js.mat'));

%% define variables to increase speed

M = 2048;

%% select events

phases = fieldnames(data);
no_phases = length(phases);

if sel_data.cat_phases == 2
    
    for n = 1: no_phases
        sel_phase = phases{n};
        
        if  strcmp(data.(sel_phase).cat,'average')
            data = rmfield(data,sel_phase);
        end
        
    end
    
    clear phases no_phases
    phases = fieldnames(data);
    no_phases = length(phases);
    
end


%% define cell arrays for inversion
north5_ges{no_phases,sel_data.NL} = [];
east5_ges{no_phases,sel_data.NL} = [];
smooth{no_phases,sel_data.NL} = [];
Tges{1,sel_data.NL} = [];
dtnn_ges = zeros(no_phases,sel_data.NL);
baz = zeros(no_phases,sel_data.NL);

% initialize vectors
dtnn = zeros(sel_data.NL,1);
phimin = zeros(sel_data.NL,1);
deltamin = zeros(sel_data.NL,1);
tmin = zeros(sel_data.NL,1);

Level = zeros(sel_data.NL,1);
tra_energy_ges = zeros(40,181); 
tra_energy = zeros(40,181,sel_data.NL);

%% start analysis

%loop over time windows
for k=1:sel_data.NL
        
   
    for i=1:no_phases
        
        sel_phase = phases{i};
        
        dtn(i,k) = data.(sel_phase).times(2)-data.(sel_phase).times(1);
        
        if sel_data.NL == 1
            data.(sel_phase).t1vec(k) = data.(sel_phase).tw1;
            data.(sel_phase).t2vec(k) = data.(sel_phase).tw2;
        else
            [data.(sel_phase).t1vec(k),data.(sel_phase).t2vec(k)]=...
                rand_wind(data.(sel_phase).tw1,data.(sel_phase).tw2,...
                data.(sel_phase).times);
        end
               
        % apply subwindows
        [~,north4]     = frame(data.(sel_phase).t1vec(k), ...
            data.(sel_phase).t2vec(k),data.(sel_phase).times,...
            data.(sel_phase).north3,M);
        [times4,east4] = frame(data.(sel_phase).t1vec(k),...
            data.(sel_phase).t2vec(k),data.(sel_phase).times,...
            data.(sel_phase).east3,M);
        
        dtnn(i,k) = times4(2)-times4(1);
        
        % remove mean
        north4 = north4 - mean(north4);
        east4 = east4 - mean(east4);
        
        % apply taper
        east5 = coswin(east4);
        north5 = coswin(north4);
        
        % Add all north5- and east5-Components to cell array
        north5_ges(i,k) = {north5};
        east5_ges(i,k) = {east5};
        dtnn_ges(i,k) = dtnn(i,k);
        baz(i,k) = data.(sel_phase).baz;
        
        % merge smoothed transversal components from timewindow
        
        % time cannot exceed 100 s
        data.(sel_phase).t2vec(data.(sel_phase).t2vec > 100) = 100;
        % time cannot be smaller than 0 s
        data.(sel_phase).t1vec(data.(sel_phase).t1vec < dtn(i,k)) = dtn(i,k);   
        
        timewindow(i,k) = int32((data.(sel_phase).t2vec(k)/dtn(i,k)) - ...
            int32(data.(sel_phase).t1vec(k)/dtn(i,k)))+1;
        
        smooth(i,k) = {tukeywindow(timewindow(i,k),0.5)};
        
        if i==1
            Tges_ind = data.(sel_phase).trac(...
                int32(data.(sel_phase).t1vec(k)/dtn(i,k)):...
                int32(data.(sel_phase).t2vec(k)/dtn(i,k))) .* ...
                cell2mat(smooth(i,k));
        else
            trac_sm = data.(sel_phase).trac(...
                int32(data.(sel_phase).t1vec(k)/dtn(i,k)):...
                int32(data.(sel_phase).t2vec(k)/dtn(i,k))) .* ...
                cell2mat(smooth(i,k));
            Tges_ind =  [Tges_ind ; trac_sm];
        end
    end
    Tges(k) = {Tges_ind}; 
    clear Tges_ind;

end

parfor k=1:sel_data.NL
    
    %% perform splitting analysis
    [tra_energy(:,:,k),phimin(k),deltamin(k),tmin(k)] = inversion_js(...
        north5_ges(:,k),east5_ges(:,k),dtnn_ges(:,k),baz(:,k),...
        sel_data.fa_area);
    
    tra_energy_ges = tra_energy_ges+tra_energy(:,:,k);
    
    %% calculate 95% confidence level
    [~, ~, Level(k)] =...
        errorbars(cell2mat(Tges(k)),tra_energy(:,:,k)',...
        min(min(tra_energy(:,:,k))), sel_data.fa_area);
    
end

%% calculate parameter distribution

[ data.ic_phi, data.ic_delta,] = ...
    make_bars (phimin, deltamin, sel_data.fa_area);

delta_range = 0.05:0.05:4;

mean_energy = tra_energy_ges ./sel_data.NL;

%% get splitting results from averaged 95%-confidence levels
[data.phi, data.delta, data.err_phi, data.err_dt] = ...
    c95Conf(delta_range(length(delta_range)),mean_energy', ...
    mean(Level),sel_data.fa_area);

%% apply initial time window and use found splitting parameters to 
% calculate new radial and transverse components

for i=1:no_phases
    
    sel_phase = phases{i};
    
    [~,north4] = frame(data.(sel_phase).tw1,data.(sel_phase).tw2,...
        data.(sel_phase).times,data.(sel_phase).north3,M);
    [times4,east4] = frame(data.(sel_phase).tw1,data.(sel_phase).tw2,...
        data.(sel_phase).times,data.(sel_phase).east3,M);
    
    dtval = times4(2)-times4(1);
    
    east5  = coswin(east4);
    north5 = coswin(north4);
       
    % apply inverse splitting using mean splitting parameters
    [invrad,invtra ] = ...
        inv_split(north5, east5, dtval, data.delta, data.phi, baz(i));
    
    maxr = max(abs(invrad));
    maxt = max(abs(invtra));
    maxrt = max(maxr,maxt);
    data.(sel_phase).invrad = invrad/maxrt;
    data.(sel_phase).invtra = invtra/maxrt;
    
    % to frequency domain and overwrite
    tra_or = gft(data.(sel_phase).tra);
    tra_inv = gft(data.(sel_phase).invtra);
    
    % calculate energy on transverse component
    tra_energy_or = sum(dot(tra_or,tra_or));
    tra_energy_inv = sum(dot(tra_inv,tra_inv));
    
    % calculate energy reduction
    energy_decr = tra_energy_or - tra_energy_inv;
    data.(sel_phase).energy_red = energy_decr/tra_energy_or*100;
    energy_red(i) = energy_decr/tra_energy_or*100;
end


%% save variables in struct for plotting
data.mean_energy_red = mean(energy_red);
data.maxtime = delta_range(length(delta_range));
data.Ematrix = mean_energy';
data.level = mean(Level);
data.fa_area = sel_data.fa_area;

end
