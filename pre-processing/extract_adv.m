function [trace]= extract_adv(file,chan_info)

% this function reads a miniseed file, checks for gaps, double entries
% a low pass of 1 s is administered to avoid aliasing effects

% usage:
% file: mseed file, chan_info (consist information of misalignment)

% Copyright 2016 M.Reiss and G.Rümpker
% Modified May 2019 Frederik Link & M. Reiss

% read miniseed file
try
[X,I] = rdmseed(file);
catch 
    disp('could not read mseed')
    trace = 0;
    return
end

for i_comp=1:length(I)
    
    clear comp_name
    clear comp
    clear trace0
    clear t
    
    comp_name = I(i_comp).ChannelFullName;
    comp = I(i_comp).XBlockIndex;
    
    trace0 = cat(1,X(comp).d);
    trace0 = trace0-mean(trace0);
    dt = 1/X(i_comp).SampleRate;
    t = cat(1,X(comp).t);
    
    %% check if gaps exist
    if isempty(I(i_comp).GapBlockIndex)
        
         %% sort time and amp values, delete multiples
        
        [new_t, ind_sort] = sort(t);
        new_trace = trace0(ind_sort);
              
        [~,Index] = unique(new_t,'rows','first');
        t = (new_t(Index))';
        trace0 = (new_trace(Index))';
               
        % low pass butterworth filter
        trace0 = buttern_low(trace0,6,1,dt);
        
        % check if file contains appropriate amount of data points
        time_diff = datevec(t(end)-t(1));
        expec_no_samples = (time_diff(4)*3600 + time_diff(5)*60 + time_diff(6))/dt;
        
        if length(t) > expec_no_samples + 200
            disp('file corrupted')
            trace0 = 0;
            t = 0;
            dt = 0;
        end
        
    else
        disp('data points are missing')
        trace0 = 0;
        t = 0;
        dt = 0;
    end
    % use appropriate channel name
    comp_name = char(comp_name);
    chan_info.channel_Z=char(chan_info.channel_Z);
    chan_info.channel_N=char(chan_info.channel_N);
    chan_info.channel_E=char(chan_info.channel_E);
    if contains(comp_name,chan_info.channel_Z)
        trace(3).comp = 'Z';
        trace(3).amp = trace0;
        trace(3).time = t;
        trace(3).dt = dt;
    elseif contains(comp_name,chan_info.channel_E)
        trace(1).comp = 'East';
        trace(1).amp = trace0;
        trace(1).time = t;
        trace(1).dt = dt;
    elseif contains(comp_name,chan_info.channel_N)
        trace(2).comp = 'North';
        trace(2).amp = trace0;
        trace(2).time = t;
        trace(2).dt = dt;
    end


end

if ~exist('trace','var')
    trace(1).comp = 'NotReadable';
    trace(1).amp = 0;
    trace(1).time = 0;
    trace(1).dt = 0;
    return
end


end