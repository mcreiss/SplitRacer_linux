function [saved_events] = qc_phases(data,station,prev_events,...
    start_index,sel_data)

% quality check for phases after inital preparation
% usage:
% data: saved events/phases from previous preparation step
% station: station name
% snr_cutoff: previously defined snr cut off

% Copyright 2016 M.Reiss and G.Rümpker

global final_events to_keep sel_event outcancel

outcancel = [];
final_events = [];
sel_event = [];

% create figure
qcfig = figure('Name','Quality Check - SplitRacer 2.0','NumberTitle',...
    'off','units','normalized','position',[.3 .1 .7 .7]);
hp = uipanel('position',[.0 .0 1 1]);
movegui(qcfig,'center')

%% analyse data

% check with which event to start if data was added later & previous
% analysis exists 

to_keep = 0;

if isstruct(prev_events)
    final_events = prev_events;
     to_keep = sum(cell2mat(strfind(fieldnames(prev_events),'event')));
end

events = fieldnames(data);

pause(0.01);

% loop over all events in data
for iEvents = start_index : length(events)
    
    fn = events{iEvents};
    
    % create title string
    title_str = ['Station: ', station, ', Event No. ', ...
        num2str(iEvents),  '/', num2str(length(events)), ', date: ', ...
        datestr(data.(fn).origin_time), ', BAZ: ', ...
        num2str(data.(fn).baz), '\circ, distance: ', ...
        num2str(data.(fn).dist), '\circ'];
    
    ip_count = 0;
    
    % use only phases above previously specified SNR cut off
    % loop over phases
    
    for an_phases = 1:length(data.(fn).phases_to_analyze)
        
        if isempty(outcancel)
            
            i_phase = data.(fn).phases_to_analyze(an_phases);
            
            an = annotation(hp,'textbox', [0.05,0.94,0.9,0.04],'String',...
                title_str, 'fontunits','normalized','fontsize',0.025,...
                'Tag','annobox','BackgroundColor', 'w');
            
            if ip_count == 0
                [sel_event,cut] = analyse_data(data.(fn),i_phase,sel_data);
            else
                [sel_event,cut] = analyse_data(sel_event,i_phase,sel_data);
            end
            
            %% buttons and info box
            
            bg = uibuttongroup('Parent',hp,'Visible', 'on','Position', ...
                [0.53 .08 .42 .13],'BackgroundColor','w');
            txt1 = uicontrol(bg,'Style','text','Visible','on','Units',...
                'normalized', 'Position',[.01 .75 .25 .15],'String',...
                'SNR: ','fontunits',...
                'normalized','fontsize',0.9,'HorizontalAlignment', ...
                'left', 'FontWeight','bold');
            txt2 = uicontrol(bg,'Style','text','Visible','on','Units',...
                'normalized','Position',[.01 .55 .25 .15],'String',...
                'short/long axis: ','fontunits',...
                'normalized','fontsize',0.9,'HorizontalAlignment', ...
                'left','FontWeight','bold');
            txt3 = uicontrol(bg,'Style','text','Visible','on','Units',...
                'normalized', 'Position',[.01 .35 .25 .15],'String',...
                'BAZ diff. (°):','fontunits', 'normalized',...
                'fontsize',0.9,'FontWeight','bold',...
                'HorizontalAlignment', 'left');
            txt4 = uicontrol(bg,'Style','text','Visible','on','Units',...
                'normalized', 'Position',[.5 .55 .48 .35],'String',...
                'Would you like to keep this event for further analysis?',...
                'fontunits', 'normalized',...
                'fontsize',0.4,'FontWeight','bold',...
                'HorizontalAlignment', 'left','BackgroundColor','w');
            btn1 = uicontrol(bg,'Style','pushbutton','Units', ...
                'normalized', 'position',[.5 .1 .125 .35],...
                'String','Yes','Callback',{@uiyes});
            btn2 = uicontrol(bg,'Style','pushbutton','Units', ...
                'normalized',  'position',[.645 .1 .125 .35],...
                'String','No','Callback',{@uino});
            btn3 = uicontrol(bg,'Style','pushbutton','Units',...
                'normalized', 'position',[.79 .1 .2 .35],...
                'String','<html>re-evaluate<br>time window','Callback',...
                {@uitimewindow,hp,bg,cut,i_phase,sel_data});
            
            % enable keyboard short cuts
            set(qcfig, 'KeyPressFcn',...
                {@keyPress,hp,bg,cut,i_phase,station,qcfig,sel_data})
            
            % plot data
            plot_data(hp,bg,sel_event,cut,i_phase,sel_data);
            
            uiwait(gcf);
            delete(findall(gcf,'Tag','annobox'))
            clear cut
            ip_count = ip_count +1;
            
        end
        
    end
    
end

saved_events = final_events;

if ishandle(qcfig)
    close(qcfig)
end

end

function [event,cut] = analyse_data(event,i_phase,sel_data)

% prepare time series section specified by phase before plotting/ analyzing

% cut selected time windows 100 s length
t_xks = event.phases(i_phase).tt_abs;

cutc = datenum((t_xks-seconds(50)));
[~, index] = min(abs(event.time-cutc));

index_end = index+(100/event.sr);
cut.time = event.time(index:index_end);

cut.z_unfilt = event.z_amp(index:index_end);
cut.north_unfilt = event.n_amp(index:index_end);
cut.east_unfilt = event.e_amp(index:index_end);


%% filter other traces

% bandpass filter (in sec periods)

event.z_amp_filt = buttern_filter(event.z_amp,2,...
    1/sel_data.p2,1/sel_data.p1,event.sr);
event.n_amp_filt = buttern_filter(event.n_amp,2,...
    1/sel_data.p2,1/sel_data.p1,event.sr);
event.e_amp_filt = buttern_filter(event.e_amp,2,...
    1/sel_data.p2,1/sel_data.p1,event.sr);

cut.z = buttern_filter(cut.z_unfilt,2,...
    1/sel_data.p2,1/sel_data.p1,event.sr);
cut.north = buttern_filter(cut.north_unfilt,2,...
    1/sel_data.p2,1/sel_data.p1,event.sr);
cut.east = buttern_filter(cut.east_unfilt,2,...
    1/sel_data.p2,1/sel_data.p1,event.sr);

cut.north_lp = buttern_filter(cut.north_unfilt,2,...
    1/50,1/15,event.sr);
cut.east_lp = buttern_filter(cut.east_unfilt,2,...
    1/50,1/15,event.sr);

%% cut window for particle motion
cut2 = datenum(t_xks - seconds(5));
[~, index2] = min(abs(cut.time-cut2));
index_end2 = index2+(30/event.sr);

event.phases(i_phase).tw(1) = datenum(t_xks - seconds(5));
event.phases(i_phase).tw(2) = datenum(t_xks + seconds(25));

cut.pm_east_sp = cut.east(index2:index_end2);
cut.pm_north_sp = cut.north(index2:index_end2);

cut.pm_east_lp = cut.east_lp(index2:index_end2);
cut.pm_north_lp = cut.north_lp(index2:index_end2);

% rotation into r-t-coordinates, with theoretical baz
[cut.radc, cut.trac] = rad_tra(cut.north, cut.east,event.baz);

end

function plot_data(hp,bg,event,cut,i_phase,sel_data)

% plot data
t_xks = event.phases(i_phase).tt_abs;

%% plot all in one figure
sub_window_new(1,'Z','N','E',event.time,event.z_amp_filt,event.n_amp_filt, ...
    event.e_amp_filt,event.phases,t_xks,hp);
title('Z N E components for entire Event')
sub_window_new(2,'Z','N','E',event.time,event.z_amp_filt,event.n_amp_filt, ...
    event.e_amp_filt,event.phases,t_xks,hp);
sub_window_new(3,'Z','N','E',event.time,event.z_amp_filt,event.n_amp_filt, ...
    event.e_amp_filt,event.phases,t_xks,hp);

% show sub-window: ZNE
sub_window_new(4,'Z','N','E',cut.time,cut.z,cut.north,cut.east,...
    event.phases,t_xks,hp);
title(['Z N E components for phase: ', char(event.phases(i_phase).name)])
sub_window_new(5,'Z','N','E',cut.time,cut.z,cut.north,cut.east,...
    event.phases,t_xks,hp);
sub_window_new(6,'Z','N','E',cut.time,cut.z,cut.north,cut.east,...
    event.phases,t_xks,hp);

% show sub-window: ZRT
sub_window_new(7,'Z','R','T',cut.time,cut.z,cut.radc,cut.trac,...
    event.phases,t_xks,hp);
title(['Z R T components for phase: ', char(event.phases(i_phase).name)])
sub_window_new(8,'Z','R','T',cut.time,cut.z,cut.radc,cut.trac,...
    event.phases,t_xks,hp);
sub_window_new(9,'Z','R','T',cut.time,cut.z,cut.radc,cut.trac,...
    event.phases,t_xks,hp);

% particle motion at regular and long periods
positionVector1 = [0.52,0.29,0.15,0.15];
subplot('Position',positionVector1)
[~] = pm(cut.north,cut.east,event.sr,event.baz,'trace');
positionVector2 = [0.67,0.29,0.15,0.15];
subplot('Position',positionVector2)
[~] = pm(cut.pm_north_sp,cut.pm_east_sp,event.sr,event.baz,...
    char(event.phases(i_phase).name));
title('particle motion')
positionVector3 = [0.82,0.29,0.15,0.15];
subplot('Position',positionVector3)
[~]=pm(cut.pm_north_lp,cut.pm_east_lp,event.sr,event.baz,...
    [char(event.phases(i_phase).name), ', T > 15 s']);

% info box
txt11 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.27 .75 .2 .15],'String',...
    num2str(event.phases(i_phase).snr,3),...
    'fontunits','normalized','fontsize',0.9,'HorizontalAlignment', 'left',...
    'FontWeight','bold');
txt22 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.27 .55 .2 .15],'String',...
    num2str(num2str(event.phases(i_phase).xlam_ratio,3)),...
    'fontunits','normalized','fontsize',0.9,'HorizontalAlignment', 'left',...
    'FontWeight','bold');
txt33 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.27 .35 .2 .15],'String',...
    num2str(event.phases(i_phase).cordeg,2),...
    'fontunits','normalized','fontsize',0.9,'HorizontalAlignment', 'left',...
    'FontWeight','bold');

end


function uiyes(hObject,handles)

% callback for yes button
% save displayed phase for further analysis

global final_events to_keep sel_event

% delete unnecessary structs
sel_event = rmfield(sel_event,'z_amp_filt');
sel_event = rmfield(sel_event,'e_amp_filt');
sel_event = rmfield(sel_event,'n_amp_filt');

if to_keep == 0
    to_keep = to_keep +1;
    new_name = ['event' int2str(to_keep)];
    final_events.(new_name)=sel_event;
else
    fn = ['event' int2str(to_keep)];
    if final_events.(fn).origin_time == sel_event.origin_time
        final_events.(fn) = sel_event;
    else
        to_keep = to_keep +1;
        new_name = ['event' int2str(to_keep)];
        final_events.(new_name) = sel_event;
    end
end

uiresume(gcbf)

end

function uino(hObject,handles)

% callback for no button

uiresume(gcbf)

end

function uitimewindow(hObject,handles,hp,bg,cut,i_phase,sel_data)

% callback for re-evaluate time window button

global sel_event

set(gca,'Parent',hp)
% get new time window from graphical input
[cutc,~] = ginput(2);

new_phase_time(1) = datenum(sel_event.phases(i_phase).tt_abs);
new_phase_time(2) = cutc(1);
new_phase_time(3) = cutc(2);

% save new time window in struct
sel_event.phases(i_phase).tw(1) = cutc(1);
sel_event.phases(i_phase).tw(2) = cutc(2);

sub_window_new(9,'Z','R','T',cut.time,cut.z,cut.radc,cut.trac,...
    sel_event.phases,new_phase_time,hp);

find_n = find(cut.time >= cutc(1) & cut.time <= cutc(2));
find_e = find(cut.time >= cutc(1) & cut.time <= cutc(2));

new_pm_north_sp = cut.north(find_n);
new_pm_east_sp = cut.east(find_e);

new_pm_north_lp = cut.north_lp(find_n);
new_pm_east_lp = cut.east_lp(find_e);

[~,xlam1,xlam2] = covar(new_pm_north_sp,new_pm_east_sp);

% plot particle motion for new time window
positionVector1 = [0.52,0.29,0.15,0.15];
subplot('Position',positionVector1)
[~] = pm(cut.north,cut.east,sel_event.sr,sel_event.baz,'trace');
positionVector2 = [0.67,0.29,0.15,0.15];
subplot('Position',positionVector2)
[~] = pm(new_pm_north_sp,new_pm_east_sp,sel_event.sr,sel_event.baz,...
    char(sel_event.phases(i_phase).name));
title('particle motion')
positionVector3 = [0.82,0.29,0.15,0.15];
subplot('Position',positionVector3)
[baz_long]=pm(new_pm_north_lp,new_pm_east_lp,sel_event.sr,sel_event.baz,...
    [char(sel_event.phases(i_phase).name), ' T > 15 s']);


% calculate new difference to backazimuth
if sel_event.baz > baz_long
    sel_event.phases(i_phase).cordeg = mod(sel_event.baz - baz_long,180);
elseif sel_event.baz < baz_long
    sel_event.phases(i_phase).cordeg = mod(sel_event.baz - baz_long,-180);
end

if sel_event.phases(i_phase).cordeg > 90
    sel_event.phases(i_phase).cordeg = ...
        sel_event.phases(i_phase).cordeg-180;
end

if sel_event.phases(i_phase).cordeg < -90
    sel_event.phases(i_phase).cordeg = ...
        sel_event.phases(i_phase).cordeg +180;
end

% calculate new short/long axis ratio
sel_event.phases(i_phase).xlam_ratio = xlam2/xlam1;

%% write new values in info box

txt22 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.27 .55 .2 .15],'String',...
    num2str(num2str(sel_event.phases(i_phase).xlam_ratio,3)),...
    'fontunits','normalized','fontsize',0.9,'HorizontalAlignment', 'left',...
    'FontWeight','bold');

txt4 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.01 .15 .25 .15],'String','new BAZ diff. (°):' ,...
    'FontWeight','bold','fontunits','normalized','fontsize',0.9, ...
    'HorizontalAlignment', 'left');
txt44 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.27 .15 .2 .15],'String',...
    num2str(sel_event.phases(i_phase).cordeg,2),...
    'fontunits','normalized','fontsize',0.9, 'FontWeight','bold',...
    'HorizontalAlignment', 'left');
end

function keyPress(hObject,handles,hp,bg,cut,i_phase,station,qcfig,sel_data)

global outcancel

switch handles.Key
    case 'y'
        uiyes
    case 'n'
        uino
    case 't'
        uitimewindow(hObject,handles,hp,bg,cut,i_phase,sel_data)
    case 'q'
        outcancel = warning_2buttons(['Do you really wanto to exit',...
            ' this quality check?'],'yes','no',station);
        if outcancel == 1
            close(qcfig)
        else
            return
        end
        
end


end