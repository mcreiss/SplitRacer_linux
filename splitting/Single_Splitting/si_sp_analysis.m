function [event] = si_sp_analysis(event,i_phase,add_info)

% single splitting analysis per phase

% usage:
% event: struct with all event data
% i_phase: chosen phase
% add_info: struct with analysis settings 

% Copyright 2016 M.Reiss and G.Rümpker, altered May 2019

% check whether individual or mean misalignment correction should be used
if isempty(add_info.cordeg)
    add_info.cordeg = event.phases(i_phase).cordeg;
end

% norm relative to cut window
for it = 1:length(event.phases)
    event.ttxks(it) = event.phases(it).tt-event.phases(i_phase).tt +(50);
end

% save phase
event.i_phase = i_phase;
event.cordeg = add_info.cordeg;

%% start analysis ...
t_xks = event.phases(i_phase).tt_abs;

cut = datenum((t_xks-seconds(50)));

[~, index] = min(abs(event.time-cut));

index_end = index+(100/event.sr);

% cut selected time windows 100 s length
north_cut = event.n_amp(index:index_end);
east_cut = event.e_amp(index:index_end);
time_cut = 0:event.sr:100;

% azimuth correction
[north, east] =  rot_az(north_cut, east_cut, add_info.cordeg);

% get time window
if isempty(add_info.tw_inp)
    %determine approximate time window of SKS phase from mouse clicks
    [tw,~] = ginput(2);
    %save timewindow for joint splitting analysis
    event.tw1 = tw(1);
    event.tw2 = tw(2); 
    set(gcf,'Pointer','watch');
else
  event.tw1 = etime(datevec(event.phases(i_phase).tw(1)),datevec(cut));
  event.tw2  = etime(datevec(event.phases(i_phase).tw(2)),datevec(cut));
end

%% save unfiltered traces for long period particle motion

% use SKS time window
[~,inds] = min(abs(time_cut-event.tw1));
[~,inde] = min(abs(time_cut-event.tw2));

% filter first
north1 = buttern_filter(north,2,1/add_info.p2,1/add_info.p1,event.sr);
east1 = buttern_filter(east,2,1/add_info.p2,1/add_info.p1,event.sr);

% cut
northcut = north1(inds:inde);
eastcut = east1(inds:inde);

%norm
eastcut = coswin(eastcut);
northcut = coswin(northcut);

maxn = max(abs(northcut));
maxe = max(abs(eastcut));
maxne = max(maxe,maxn);
event.northcut = northcut/maxne;
event.eastcut = eastcut/maxne;

% also calculate medium long-period motion to check BAZ
north_mp = buttern_filter(north,2,1/50,1/10,event.sr);
east_mp = buttern_filter(east,2,1/50,1/10,event.sr);

% cut
northcuta = north_mp(inds:inde);
eastcuta = east_mp(inds:inde);

% norm
maxn = max(abs(northcuta));
maxe = max(abs(eastcuta));
maxne = max(maxe,maxn);
event.northcuta = northcuta/maxne;
event.eastcuta = eastcuta/maxne;

% also calculate long-period motion to check BAZ
north_lp = buttern_filter(north,2,1/50,1/15,event.sr);
east_lp = buttern_filter(east,2,1/50,1/15,event.sr);

% cut
northcutb = north_lp(inds:inde);
eastcutb = east_lp(inds:inde);

%norm
maxn = max(abs(northcutb));
maxe = max(abs(eastcutb));
maxne = max(maxe,maxn);
event.northcutb = northcutb/maxne;
event.eastcutb = eastcutb/maxne;

%% continue with entire filtered trace

% normalization
maxe = max(abs(east1));
maxn = max(abs(north1));
maxen = max(maxn,maxe);
north2 = north1/maxen;
east2 = east1/maxen;

% resampling of data points (after bandpass filtering)
M = 2048;
[event.east3,~] = reduce(M,east2);
[event.north3,dtfac] = reduce(M,north2);
dtn = event.sr*dtfac;
event.times = linspace(0,dtn*(M-1),M);

% radial-transverse components
% calculate radial-transverse components
[radc, trac] =  rad_tra (event.north3, event.east3, event.baz);

% normalize radial and transverse components
maxr = max(abs(radc));
maxt = max(abs(trac));
maxrt = max(maxr,maxt);
event.radc = radc/maxrt;
event.trac = trac/maxrt;

%% calculate splitting parameters

% initialize vectors
phimin = zeros(add_info.NL,1);
deltamin = zeros(add_info.NL,1);
tmin = zeros(add_info.NL,1);
Level = zeros(add_info.NL,1);
tra_energy = zeros(40,181,add_info.NL);
tra_energy_ges = zeros(40,181);
sp_low = zeros(add_info.NL,1);
sp_est = zeros(add_info.NL,1);
sp_high = zeros(add_info.NL,1);

%loop for time windows
for k = 1:add_info.NL
    
    % determine subwindows
    if add_info.NL ==  1
        t1 = event.tw1;
        t2 = event.tw2;
    else
        [t1,t2] = rand_wind(event.tw1,event.tw2,event.times);
    end
    
    event.t1vec(k) = t1;
    event.t2vec(k) = t2;
end

% loop over time windows, parallel computing if possible    
parfor kk = 1:add_info.NL
    
    % apply subwindows
    [times4,north4]  =  frame(event.t1vec(kk),event.t2vec(kk),...
        event.times,event.north3,M);
    [~,east4] = frame(event.t1vec(kk),event.t2vec(kk),...
        event.times,event.east3,M);
    dtnn = times4(2)-times4(1);
    
    % remove mean
    north4 = north4-mean(north4);
    east4 = east4-mean(east4);
       
    % apply taper
    north5 = coswin(north4);
    east5 = coswin(east4);

    % perform splitting analysis
    [tra_energy(:,:,kk),phimin(kk),deltamin(kk),tmin(kk)] = inversion(...
        north5, east5, dtnn, event.baz, add_info.fa_area);

    tra_energy_ges = tra_energy_ges+tra_energy(:,:,kk);
       
    % calculate error bars and 95% confidence level
    T = event.trac(int32(event.t1vec(kk)/dtn):int32(event.t2vec(kk)/dtn));
    
    [~, ~, Level(kk)] = errorbars(T,tra_energy(:,:,kk)',...
        min(min(tra_energy(:,:,kk))),add_info.fa_area);
    
    % calculate splitting intensity
    % tranformation of north east to radial-transversal
    [rad, tra]= rad_tra (north5, east5, event.baz);
    [sp_low(kk), sp_est(kk), sp_high(kk)] = SplitIntFunction(tra,rad ,dtnn);
    
end

%% for bar plot

[event.ic_phi,event.ic_delta] = make_bars(phimin,deltamin,...
    add_info.fa_area);

% mean energy over all time windows
event.mean_energy = tra_energy_ges ./add_info.NL;

%% plot T-energy surface for mean_energy

event.delta_range = 0.1:0.1:4;
event.phi_range = 0-add_info.fa_area:1:180-add_info.fa_area;
event.level = mean(Level);

[event.phi, event.delta, event.err_phi, event.err_dt] = ...
    c95Conf(event.delta_range(length(event.delta_range)),...
    event.mean_energy', event.level,add_info.fa_area);

%% apply inverse splitting operator

% apply initial time window
[~,north4] = frame(event.tw1,event.tw2,event.times,event.north3,M);
[times4,east4] = frame(event.tw1,event.tw2,event.times,event.east3,M);
dtval = times4(2)-times4(1);
east5 = coswin(east4);
north5 = coswin(north4);

% calculate radial-transverse components
[rad, tra] =  rad_tra (north5, east5, event.baz);

% norm radial-transverse components
maxr = max(abs(rad));
maxt = max(abs(tra));
maxrt = max(maxr,maxt);
event.rad = rad/maxrt;
event.tra = tra/maxrt;

% apply inverse splitting using mean splitting parameters
[ invrad, invtra ] = inv_split( north5, east5, dtval, event.delta, ...
    event.phi, event.baz);

% draw corrected radial-transverse components
maxr = max(abs(invrad));
maxt = max(abs(invtra));
maxrt = max(maxr,maxt);
event.invrad = invrad/maxrt;
event.invtra = invtra/maxrt;

% calculate energy on original and inverse transverse components

% to frequency domain and overwrite
tra_or = gft(event.tra);
tra_inv = gft(event.invtra);

% calculate energy on transverse component
tra_energy_or = sum(dot(tra_or,tra_or));
tra_energy_inv = sum(dot(tra_inv,tra_inv));

energy_decr = tra_energy_or - tra_energy_inv;
event.energy_red = energy_decr/tra_energy_or*100;

event.split_int = mean(sp_est);
event.split_err = [mean(sp_low), mean(sp_high)];

end


