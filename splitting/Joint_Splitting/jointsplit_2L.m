function [data] = jointsplit_2L(station,nw_code,sel_data)

% joint splitting routine for two layers

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

%% grid parameters in time and degree domain

% search rate time domain
t_inc = 0.1;

% in time, time max is 2 seconds
max_time = 2;
res_t = length(0:t_inc:max_time);

%search rate degree domain
d_inc = 5;
res_d = length(0:d_inc:180);

%% define variables to increase speed

M=2048;

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
north5_ges{no_phases}=[];
east5_ges{no_phases}=[];
dtnn_ges=zeros(no_phases,sel_data.NL);

% initialize vectors

t1vec=zeros(sel_data.NL,1);
t2vec=zeros(sel_data.NL,1);
dtnn=zeros(sel_data.NL,1);

phimin1=zeros(sel_data.NL,1);
deltamin1=zeros(sel_data.NL,1);
phimin2=zeros(sel_data.NL,1);
deltamin2=zeros(sel_data.NL,1);
tmin=zeros(sel_data.NL,1);

phimin_low=zeros(sel_data.NL,1);
deltamin_low=zeros(sel_data.NL,1);
phimin_upp=zeros(sel_data.NL,1);
deltamin_upp=zeros(sel_data.NL,1);
tmin_low=zeros(sel_data.NL,1);
tmin_upp=zeros(sel_data.NL,1);

% neu für error via confidence level
Level_low=zeros(sel_data.NL,1);
Level_upp=zeros(sel_data.NL,1);
tra_energy_ges=zeros(res_t,res_d,res_t,res_d);
tra_energy_ges_low=zeros(res_t,res_d);
tra_energy_ges_upp=zeros(res_t,res_d);

%% start analysis

%loop over time windows
for k = 1:sel_data.NL

    for i=1:no_phases
        
        sel_phase = phases{i};
        
        dtn = data.(sel_phase).times(2)-data.(sel_phase).times(1);
        
        if (sel_data.NL==1)
            data.(sel_phase).t1vec(k) = data.(sel_phase).tw1;
            data.(sel_phase).t2vec(k)=data.(sel_phase).tw2;
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
        
        dtnn(i,k)=times4(2)-times4(1);
        
        % remove mean
        north4 = north4-mean(north4);
        east4 = east4-mean(east4);
               
        % apply taper
        east5 = coswin(east4);
        north5 = coswin(north4);
        
        % Add all north5- and east5-Components to cell array
        north5_ges(i) = {north5};
        east5_ges(i) = {east5};
        dtnn_ges(i,k) = dtnn(i,k);
        baz(i) = data.(sel_phase).baz;
        
        % merge smoothed transversal components from timewindow
        % time cannot exceed 100 s
        data.(sel_phase).t2vec(data.(sel_phase).t2vec > 100) = 100;
        % time cannot be smaller than 0 s
        data.(sel_phase).t1vec(data.(sel_phase).t1vec < dtn) = dtn;
        
        timewindow = int32((data.(sel_phase).t2vec(k)/dtn) - ...
            int32(data.(sel_phase).t1vec(k)/dtn))+1;
        
        smooth=tukeywindow(timewindow,0.5);
        
        if i==1
            Tges = data.(sel_phase).trac(...
                int32(data.(sel_phase).t1vec(k)/dtn):...
                int32(data.(sel_phase).t2vec(k)/dtn)).*smooth;
        else
            trac_sm = data.(sel_phase).trac(...
                int32(data.(sel_phase).t1vec(k)/dtn):...
                int32(data.(sel_phase).t2vec(k)/dtn)).*smooth;
            Tges = [Tges ; trac_sm];
        end
    end
    tic
    %% perform splitting analysis
    [tra_energy,phimin1(k),deltamin1(k),phimin2(k),...
        deltamin2(k),tmin(k)] = inversion_2L(north5_ges,east5_ges,...
        dtnn_ges(:,k),baz,sel_data.fa_area,res_t,res_d);
    toc
    tra_energy_ges = tra_energy_ges+tra_energy;
    
    %% calculate energy level seperately from inversion
    
    % first: phi1&dt1 are constant while phi2 and dt2 are varied
    %then vice versa
    
    [tra_energy_low, tmin_low(k), phimin_low(k), ...
        deltamin_low(k)] = ...
        energy(north5_ges, east5_ges, dtnn_ges(:,k), baz, phimin2(k),...
        deltamin2(k),1,sel_data.fa_area,res_t,res_d);
    
    [tra_energy_upp, tmin_upp(k), phimin_upp(k), ...
        deltamin_upp(k)] = ...
        energy(north5_ges, east5_ges, dtnn_ges(:,k), baz, phimin1(k),...
        deltamin1(k),2,sel_data.fa_area,res_t,res_d);
    
    tra_energy_ges_low = tra_energy_ges_low+tra_energy_low;
    tra_energy_ges_upp = tra_energy_ges_upp+tra_energy_upp;
    
    %% calculate 95% confidence level
    [~, ~, Level_low(k)] = errorbars_2L(Tges,tra_energy_low',...
        min(min(tra_energy_low)),sel_data.fa_area);
    
    [~, ~, Level_upp(k)] = errorbars_2L(Tges,tra_energy_upp',...
        min(min(tra_energy_upp)),sel_data.fa_area);

end

%% calculate parameter distribution

[data.ic_phi_low,data.ic_delta_low] = make_bars(phimin_low, ...
    deltamin_low, sel_data.fa_area);
[data.ic_phi_upp,data.ic_delta_upp] = make_bars(phimin_upp, ...
    deltamin_upp, sel_data.fa_area);

% calculate delta % phi range
delta_range = (2/res_t):(2/res_t):2 ;

%% get splitting results from averaged 95%-confidence levels

% lower layer

[data.phiminval_low, data.deltaminval_low, ...
    data.err_phi_low, data.err_dt_low] = c95Conf(...
    delta_range(length(delta_range)),(tra_energy_ges_low/sel_data.NL)',...
    mean(Level_low),sel_data.fa_area);

%upper layer

[data.phiminval_upp, data.deltaminval_upp, ...
    data.err_phi_upp, data.err_dt_upp] = c95Conf(...
    delta_range(length(delta_range)),(tra_energy_ges_upp/sel_data.NL)',...
    mean(Level_upp),sel_data.fa_area);

%% apply initial time window and use found splitting parameters to

% calculate new radial and transverse components

for i=1:no_phases
    
    sel_phase = phases{i};
    
    [~,north4]     = frame(data.(sel_phase).tw1,data.(sel_phase).tw2,...
        data.(sel_phase).times,data.(sel_phase).north3,M);
    [times4,east4] = frame(data.(sel_phase).tw1,data.(sel_phase).tw2,...
        data.(sel_phase).times,data.(sel_phase).east3,M);
    
    dtval=times4(2)-times4(1);
    
    east5  = coswin(east4);
    north5 = coswin(north4);
    
    % apply inverse splitting using mean splitting parameters
    [ invrad, invtra ] = inv_split_2L( north5, east5, dtval, ...
        data.deltaminval_low, data.phiminval_low, ...
        data.deltaminval_upp, data.phiminval_upp, baz(i));
    
    maxr=max(abs(invrad));
    maxt=max(abs(invtra));
    maxrt=max(maxr,maxt);
    data.(sel_phase).invrad = invrad/maxrt;
    data.(sel_phase).invtra = invtra/maxrt;
    
    % to frequency domain and overwrite
    tra_or = gft(data.(sel_phase).tra);
    tra_inv = gft(data.(sel_phase).invtra);
    
    % calculate energy on transverse component
    tra_energy_or=sum(dot(tra_or,tra_or));
    tra_energy_inv=sum(dot(tra_inv,tra_inv));
    
    % calculate energy reduction
    energy_decr = tra_energy_or - tra_energy_inv;
    data.(sel_phase).energy_red = energy_decr/tra_energy_or*100;
    energy_red(i) = energy_decr/tra_energy_or*100;
end

%% save variables in strcut for plotting

data.mean_energy_red = mean(energy_red);
data.maxtime = delta_range(length(delta_range));
data.Ematrix_low = (tra_energy_ges_low/sel_data.NL)';
data.Ematrix_upp = (tra_energy_ges_upp/sel_data.NL)';
data.level_low = mean(Level_low);
data.level_upp = mean(Level_upp);
data.fa_area = sel_data.fa_area;


end
