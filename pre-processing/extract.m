function [trace]= extract(file)

% this function reads a miniseed file, checks for gaps, double entries
% a low pass of 1 s is administered to avoid aliasing effects

% usage:
% file: mseed file

% Copyright 2016 M.Reiss and G.Rümpker

% read miniseed file
try
    [X,I] = rdmseed(file);
catch
    disp('could not read mseed')
    trace = 0;
    return
end

rep_ind = 0;

for i_comp=1:length(I)
    
    clear comp_name
    clear comp
    clear trace0
    clear dtfigure
    clear t
    clear DupIndex
    
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
    if strfind(comp_name,'HE')
        trace(1).comp = 'East';
        trace(1).amp = trace0;
        trace(1).time = t;
        trace(1).dt = dt;
        rep_ind = rep_ind +1;
    end
    if strfind(comp_name,'H2')
        trace(1).comp = 'East';
        trace(1).amp = trace0;
        trace(1).time = t;
        trace(1).dt = dt;
        rep_ind = rep_ind +1;
    end
    if  strfind(comp_name,'HN')
        trace(2).comp = 'North';
        trace(2).amp = trace0;
        trace(2).time = t;
        trace(2).dt = dt;
        rep_ind = rep_ind +1;
    end
    if  strfind(comp_name,'H1')
        trace(2).comp = 'North';
        trace(2).amp = trace0;
        trace(2).time = t;
        trace(2).dt = dt;
        rep_ind = rep_ind +1;
    end
    if strfind(comp_name,'HZ')
        trace(3).comp = 'Z';
        trace(3).amp = trace0;
        trace(3).time = t;
        trace(3).dt = dt;
        rep_ind = rep_ind +1;
    end
    
    % stop after allocating three components
    if rep_ind == 3
        return
    end
    
end


end