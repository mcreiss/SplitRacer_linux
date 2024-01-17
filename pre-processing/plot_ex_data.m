function plot_ex_data(test_data,hsp2)

% plot data defined by ui_ex_data
% usage: all input values are in struct 'test_data', except hsp2, which is
% a sub panel to the main figure

% Copyright 2016 M.Reiss and G.Rümpker, altered May 2019

%% read selected file

[event] = get_event_data(test_data);

if isempty(event)
    return
end

%% plot header

title_str = ['Station: ', char(test_data.station), ', date: ', ...
    datestr(event.origin_time), ', BAZ: ', num2str(event.baz), '\circ', ....
    ', distance: ', num2str(event.dist), '\circ'];

annotation(hsp2,'textbox', [0.05,0.95,0.9,0.04],'String',title_str,...
    'fontunits','normalized','fontsize',0.025,'BackgroundColor', 'w');

%% button group for filter and SNR options

ap_bg = uibuttongroup('Parent',hsp2,'Visible', 'on','Position', ...
    [.0 .45 1 0.06]);

txt1 = uicontrol(ap_bg,'Style','text','Visible','on','Units',...
    'normalized','position',[0.01,0.2,0.1,0.6],'String','Filter (s)',...
    'fontunits','normalized','fontsize',0.7);

e1 = uicontrol(ap_bg,'Style', 'edit','String','4','Units',...
    'normalized','position',[0.11,0.2,0.05,0.6],...
    'fontunits','normalized','fontsize',0.7);

txt2 = uicontrol(ap_bg,'Style','text','Visible','on','Units',...
    'normalized','position',[0.16,0.2,0.03,0.6],'String','-',...
    'fontunits','normalized','fontsize',0.7);

e2 = uicontrol(ap_bg,'Style', 'edit','String','50','Units',...
    'normalized','position',[0.19,0.2,0.05,0.6],...
    'fontunits','normalized','fontsize',0.7);

txt3 = uicontrol(ap_bg,'Style','text','Visible','on','Units',...
    'normalized','position',[0.27,0.2,0.13,0.6],'String','SNR cut-off',...
    'fontunits','normalized','fontsize',0.7);

e3 = uicontrol(ap_bg,'Style', 'edit','String','2.5','Units',...
    'normalized','position',[0.4,0.2,0.05,0.6],...
    'fontunits','normalized','fontsize',0.7);

pb1 = uicontrol(ap_bg,'Style', 'pushbutton','String','apply','Units',...
    'normalized','position',[0.51,0.1,0.1,0.8],...
    'fontunits','normalized','fontsize',0.5,'Callback',...
    {@ui_apl,e1,e2,e3,event,hsp2});

pb2 = uicontrol(ap_bg,'Style', 'pushbutton','String','save settings',...
    'Units','normalized','position',[0.89,0.1,0.1,0.8],...
    'fontunits','normalized','fontsize',0.4,'Callback',...
    {@ui_save_apl,e1,e2,e3,test_data});

%% plot hour trace

plot_hour(event,hsp2)

%% plot spectrum

[event] = calc_spec(event);

plot_spec(event,hsp2)

%% plot zoom in to XKS phase

plot_xks(event,hsp2)

end


function [event] = get_event_data(test_data)

% find event

%read log file containing successfully downloaded data
fileID2 = fopen([test_data.work_dir,'/data_request_',...
    char(test_data.station),'_',char(test_data.nc)]);
C2 = textscan(...
    fileID2,'%f %f %f %f %f %f %f %f %f %f %f %f %s %s');

files = C2{1,14};

sel_event1 = files(test_data.plot_vals-1,:);
sel_event = strcat(char(test_data.work_dir),'/',char(sel_event1));
file_mseed = extract(char(sel_event));

% check if more than 2 components exist
if length(file_mseed)<3
    
    w = warndlg(['The chosen event does not have three components. ',...
        'Please chose a different event to continue. '],...
        'Warning!');
    drawnow
    waitfor(w);
    event = [];
    return
end

% check if components consist of more than 10 minutes
test_no_samples = 600 / file_mseed(1).dt;

if ~length(file_mseed(1).amp)>test_no_samples && ...
        length(file_mseed(2).amp)>test_no_samples && ...
        length(file_mseed(3).amp)>test_no_samples 
    
    w = warndlg(['The chosen event is too short. ',...
        'Please chose a different event to continue. '],...
        'Warning!');
    drawnow; 
    waitfor(w);
    event = [];
    return
end
 
% read event from text file
[event] = read_event_file(C2,test_data.plot_vals-1);

% resample data
[event] = re_sample(event,file_mseed,0.05);

%% norm

max_amp(1) = max(event.z_amp);
max_amp(2) = max(event.n_amp);
max_amp(3) = max(event.e_amp);
max_val = max(max_amp);

event.z_amp = event.z_amp/max_val;
event.n_amp = event.n_amp/max_val;
event.e_amp = event.e_amp/max_val;

%% get travel times
[event.phases] = get_tt(event.dist,event.depth);
% calculate absolute travel times

for iF = 1:length(event.phases)
    event.phases(iF).tt_abs = ...
        seconds(event.phases(iF).tt) + event.origin_time;
end


end

function plot_hour(event,hsp2)

% plot Z component
ax1 = axes('Position',[0.05,0.77,0.45,0.1],'Parent',hsp2);
plot(ax1,event.time,event.z_amp)
datetick('x')
hold on
% plot phases
for n=1:length(event.phases)
    plot(ax1,[datenum(event.phases(n).tt_abs) datenum(event.phases(n).tt_abs)],...
        [-1 1],'k')
    text(( datenum(event.phases(n).tt_abs) ), ...
        ( ((-1)^n)*(1*0.8) ), event.phases(n).name,...
        'fontunits','normalized','FontSize',0.18);
end
axis([min(event.time) max(event.time) -1 1])
set(gca,'XTickLabel','')
ylabel('Z')
set(get(gca,'YLabel'),'Rotation',0)
title('Entire trace')
hold off

%plot N component
ax2 = axes('Position',[0.05,0.67,0.45,0.1],'Parent',hsp2);
plot(ax2,event.time,event.n_amp)
datetick('x')
hold on
% plot phases
for n=1:length(event.phases)
    plot(ax2,[datenum(event.phases(n).tt_abs) datenum(event.phases(n).tt_abs)],...
        [-1 1],'k')
    text( ( datenum(event.phases(n).tt_abs) ), ...
        ( ((-1)^n)*(1*0.8) ), event.phases(n).name,...
        'fontunits','normalized','FontSize',0.18);
end
axis([min(event.time) max(event.time) -1 1])
set(gca,'XTickLabel','')
ylabel('N')
set(get(gca,'YLabel'),'Rotation',0)
hold off

%plot e component
ax3 = axes('Position',[0.05,0.57,0.45,0.1],'Parent',hsp2);
plot(ax3,event.time,event.e_amp)
datetick('x')
hold on
%plot phases
for n=1:length(event.phases)
    plot(ax3,[datenum(event.phases(n).tt_abs) datenum(event.phases(n).tt_abs)],...
        [-1 1],'k')
    text( ( datenum(event.phases(n).tt_abs) ), ...
        ( ((-1)^n)*(1*0.8) ), event.phases(n).name,...
        'fontunits','normalized','FontSize',0.18)
end
axis([min(event.time) max(event.time) -1 1])
ylabel('E')
set(get(gca,'YLabel'),'Rotation',0)
hold off

end

function [event] = calc_spec(event)

% calculate spectrum
z_fft = fft(event.z_amp);
n_fft = fft(event.n_amp);
e_fft = fft(event.e_amp);

% norm spectrum

max_spec(1) = max(abs(z_fft));
max_spec(2) = max(abs(n_fft));
max_spec(3) = max(abs(e_fft));

max_val = max(max_spec);

z_fft = z_fft/max_val;
n_fft = n_fft/max_val;
e_fft = e_fft/max_val;

% save spectrum

M = length(z_fft);

event.z_spec = abs(z_fft(1:round(M/2)));
event.n_spec = abs(n_fft(1:round(M/2)));
event.e_spec = abs(e_fft(1:round(M/2)));

% frequency vector
event.spec = (0:M/2)/ (M/(1/event.sr));

end


function plot_spec(event,hsp2)

% plot Z component sepctrum
ax4 = axes('Position',[0.6,0.77,0.35,0.1],'Parent',hsp2);
semilogx(ax4,1./event.spec,event.z_spec)
%axis([0 1 0 1])
set(gca,'XTickLabel','')
title('Normalized Spectrum')
ylabel('Z')
set(get(gca,'YLabel'),'Rotation',0);

%plot N component spectrum
ax5 = axes('Position',[0.6,0.67,0.35,0.1],'Parent',hsp2);
semilogx(ax5,1./event.spec,event.n_spec)
%axis([0 1 0 1])
set(gca,'XTickLabel','')
ylabel('N')
set(get(gca,'YLabel'),'Rotation',0);

%plot E component spectrum
ax6 = axes('Position',[0.6,0.57,0.35,0.1],'Parent',hsp2);
semilogx(ax6,1./event.spec,event.e_spec)
%axis([0 1 0 1])
ylabel('E')
xlabel('period (s)')
set(get(gca,'YLabel'),'Rotation',0);

end

function ui_apl(hObject,handles,e1,e2,e3,event,hsp2)

% get input from editable fields
apl.p1 = str2double(get(e1,'String'));
apl.p2 = str2double(get(e2,'String'));
apl.cut_snr = str2double(get(e3,'String'));

% re plot
plot_xks(event,hsp2,apl)

end

function plot_xks(event,hsp2,apl)

% get data/ parameters
if nargin > 2
    event = calc_xks(event,apl);
    to_apl = 1;
else
    event = calc_xks(event);
    to_apl = 0;
end

%% plot

tgroup = uitabgroup('Parent',hsp2,'units','normalized','Position',...
    [0 0 1 .45]);

no_tab = 0;

for i_phase = 1:length(event.phases) % plot all XKS phases
    
    if event.phases(i_phase).time_cut > 1
        
        % one tab per phase
        no_tab = no_tab +1; 
        
        t_xks=event.phases(i_phase).tt_abs;
        
        tab(no_tab)=uitab(tgroup,'Title',event.phases(i_phase).name);
        
        min_time = event.phases(i_phase).time_cut(1);
        max_time = event.phases(i_phase).time_cut(end);
        
        ax1 = axes('Position',[0.05,0.6,0.45,0.2],'Parent',tab(no_tab));
        
        % plot noise and signal windows
        n1 = datenum(t_xks)-datenum(seconds(20));
        s1 = datenum(t_xks)+datenum(seconds(25));
        
        hold(ax1,'on')
        ha = area(ax1,[n1 datenum(t_xks)],[ -.95 -.95],'FaceColor',...
            [0.75 0.93 1],'EdgeColor',[0.75 0.93 1]);
        ha = area(ax1,[n1 datenum(t_xks)],[.98 .98],'FaceColor',...
            [0.75 0.93 1],'EdgeColor',[0.75 0.93 1]);
        ha = area(ax1,[datenum(t_xks) s1],[ -.95 -.95],'FaceColor',...
            [0.68 1 .18],'EdgeColor',[0.68 1 .18]);
        ha = area(ax1,[datenum(t_xks) s1],[.98 .98],'FaceColor',...
            [0.68 1 .18],'EdgeColor',[0.68 1 .18],'ShowBaseLine','off');
        
        plot(ax1,event.phases(i_phase).time_cut,...
            event.phases(i_phase).z_cut)
        datetick('x')
        
        % plot phases
        for n = 1:length(event.phases)
            if ge(datenum(event.phases(n).tt_abs),min_time) && ...
                    le(datenum(event.phases(n).tt_abs),max_time)
                plot(ax1,...
                    [datenum(event.phases(n).tt_abs) datenum(event.phases(n).tt_abs)],...
                    [-1 1],'k')
                text(( datenum(event.phases(n).tt_abs) ), ...
                    ( ((-1)^n)*(1*0.8) ), event.phases(n).name,...
                    'fontunits','normalized','FontSize',0.18);
            end
        end
        title('Zoom in to phase')
        set(gca,'XTickLabel','')
        ylabel('Z')
        set(get(gca,'YLabel'),'Rotation',0)
        axis([min_time max_time -1 1])
        hold(ax1,'off')
        
        ax2 = axes('Position',[0.05,0.4,0.45,0.2],'Parent',tab(no_tab));
        
        % plot signal/noise window
        hold(ax2,'on')
        ha = area(ax2,[n1 datenum(t_xks)],[ -.95 -.95],'FaceColor',...
            [0.75 0.93 1],'EdgeColor',[0.75 0.93 1]);
        ha = area(ax2,[n1 datenum(t_xks)],[.98 .98],'FaceColor',...
            [0.75 0.93 1],'EdgeColor',[0.75 0.93 1]);
        ha = area(ax2,[datenum(t_xks) s1],[ -.95 -.95],'FaceColor',...
            [0.68 1 .18],'EdgeColor',[0.68 1 .18]);
        ha = area(ax2,[datenum(t_xks) s1],[.98 .98],'FaceColor',...
            [0.68 1 .18],'EdgeColor',[0.68 1 .18],'ShowBaseLine','off');
        
        % plot trace
        plot(ax2,event.phases(i_phase).time_cut,...
            event.phases(i_phase).north_cut)
        
        % plot phases
        for n = 1:length(event.phases)
            if ge(datenum(event.phases(n).tt_abs),min_time) && ...
                    le(datenum(event.phases(n).tt_abs),max_time)
                plot(ax2,...
                    [datenum(event.phases(n).tt_abs) datenum(event.phases(n).tt_abs)],...
                    [-1 1],'k')
                text(( datenum(event.phases(n).tt_abs) ), ...
                    ( ((-1)^n)*(1*0.8) ), event.phases(n).name,...
                    'fontunits','normalized','FontSize',0.18);
            end
        end
        set(gca,'XTickLabel','')
        ylabel('N')
        set(get(gca,'YLabel'),'Rotation',0)
        axis([min_time max_time -1 1])
        hold(ax2,'off')
        
        ax3 = axes('Position',[0.05,0.2,0.45,0.2],'Parent',tab(no_tab));
        
        % plot signal/noise window
        hold(ax3,'on')
        ha = area(ax3,[n1 datenum(t_xks)],[ -.95 -.95],'FaceColor',...
            [0.75 0.93 1],'EdgeColor',[0.75 0.93 1]);
        ha = area(ax3,[n1 datenum(t_xks)],[.98 .98],'FaceColor',...
            [0.75 0.93 1],'EdgeColor',[0.75 0.93 1]);
        ha = area(ax3,[datenum(t_xks) s1],[ -.95 -.95],'FaceColor',...
            [0.68 1 .18],'EdgeColor',[0.68 1 .18]);
        ha = area(ax3,[datenum(t_xks) s1],[.98 .98],'FaceColor',...
            [0.68 1 .18],'EdgeColor',[0.68 1 .18],'ShowBaseLine','off');
        plot(ax3,event.phases(i_phase).time_cut,...
            event.phases(i_phase).east_cut)
        datetick('x')
        
        % plot phases
        for n = 1:length(event.phases)
            if ge(datenum(event.phases(n).tt_abs),min_time) && ...
                    le(datenum(event.phases(n).tt_abs),max_time)
                plot(ax3,...
                    [datenum(event.phases(n).tt_abs) datenum(event.phases(n).tt_abs)],...
                    [-1 1],'k')
                text(( datenum(event.phases(n).tt_abs) ), ...
                    ( ((-1)^n)*(1*0.8) ), event.phases(n).name,...
                    'fontunits','normalized','FontSize',0.18);
            end
        end
        ylabel('E')
        set(get(gca,'YLabel'),'Rotation',0)
        axis([min_time max_time -1 1])
        hold(ax3,'off')
        
        %% plot particle motion
        
        positionVector1 = [0.6,0.6,0.1,0.3];
        subplot('Position',positionVector1)
        
        [~]=pm(event.phases(i_phase).north_cut2,...
            event.phases(i_phase).east_cut2,event.sr,event.baz,...
            char(event.phases(i_phase).name));
        
        % at long periods
        
        % take unfiltered traces if filtering was done before
        positionVector2 = [0.6,0.13,0.1,0.3];
        subplot('Position',positionVector2)
        

        [~]=pm(event.phases(i_phase).north_cut2_lp,...
            event.phases(i_phase).east_cut2_lp,event.sr,event.baz,...
            [event.phases(i_phase).name ',15 -50s']);
        
        %% plot annotation box
        
        anno_bg = uibuttongroup('Visible', 'on','Position', [0.75 .05 .2 .9],...
            'Parent',tab(no_tab));
        
        txt1 = uicontrol(anno_bg,'Style','text','Visible','on','Units',...
            'normalized','Position',[.0 .89 1 .08],'String','Results ',...
            'fontunits','normalized','fontsize',0.75,'FontWeight','bold');
        
        txt2 = uicontrol(anno_bg,'Style','text','Visible','on','Units',...
            'normalized','Position',[.0 .62 0.3 .08],'String','SNR:',...
            'fontunits','normalized','fontsize',0.7);
        
        txt3 = uicontrol(anno_bg,'Style','text','Visible','on','Units',...
            'normalized', 'Position',[.5 .62 0.5 .08],'String',...
            num2str(event.phases(i_phase).snr_h,3),...
            'fontunits','normalized','fontsize',0.7);       
        
        % check if filter was used
        if to_apl == 1
            
            txt4 = uicontrol(anno_bg,'Style','text','Visible','on',...
                'Units','normalized', 'Position',[.0 .73 0.5 .08],...
                'String','filtered (s): ',...
                'fontunits','normalized','fontsize',0.7);
            
            txt5 = uicontrol(anno_bg,'Style','text','Visible','on',...
                'Units','normalized','Position',[.5 .73 0.5 .08],...
                'String', [num2str(apl.p1), '-', num2str(apl.p2)],...
                'fontunits','normalized','fontsize',0.7);
            
            
            % check if phase fulfills criteria
            if event.phases(i_phase).snr_h > apl.cut_snr
                
                txt6 = uicontrol(anno_bg,'Style','text','Visible','on',...
                    'Units','normalized', 'Position',[.0 .51 1 .08],...
                    'String','SNR is above cut-off value','fontunits',...
                    'normalized','fontsize',0.7,'ForegroundColor','g');
            else
                txt6 = uicontrol(anno_bg,'Style','text','Visible','on',...
                    'Units','normalized', 'Position',[.0 .51 1 .08],...
                    'String','SNR is below cut-off value','fontunits',...
                    'normalized','fontsize',0.7,'ForegroundColor','r');   
            end
            
            % check if phases overlap
            if event.phases(i_phase).i_overlap
                
                txt7 = uicontrol(anno_bg,'Style','text','Visible','on',...
                    'Units', 'normalized', 'Position',[.0 .32 1 .16],...
                    'String', 'phases overlap by less than 10 s',...
                    'fontunits','normalized','fontsize',0.35,...
                    'ForegroundColor','r');
                
            else
                
                txt7 = uicontrol(anno_bg,'Style','text','Visible','on',...
                    'Units','normalized', 'Position',[.0 .4 1 .08],...
                    'String', 'phases do not overlap','fontunits',...
                    'normalized','fontsize',0.7,'ForegroundColor','g');
            end
            
            % check of all criteria are fulfilled
            if event.phases(i_phase).snr_h > apl.cut_snr && ...
                    event.phases(i_phase).i_overlap == 0
                
                txt8 = uicontrol(anno_bg,'Style','text','Visible','on',...
                    'Units', 'normalized', 'Position',[.0 .1 1 .08],...
                    'String','phase fulfills criteria',...
                    'ForegroundColor','g',...
                    'fontunits','normalized','fontsize',0.7);
            else
                txt8 = uicontrol(anno_bg,'Style','text','Visible','on',...
                    'Units','normalized', 'Position',[.0 .05 1 .16],...
                    'String','phase does not fulfill criteria',...
                    'ForegroundColor','r',...
                    'fontunits','normalized','fontsize',0.35);
            end
            
        else
            
            txt4 = uicontrol(anno_bg,'Style','text','Visible','on',...
                'Units','normalized',...
                'Position',[.0 .73 1 .08],'String','unfiltered',...
                'fontunits','normalized','fontsize',0.7);
                        
            txt5 = uicontrol(anno_bg,'Style','text','Visible','on',...
                'Units','normalized', 'Position',[.0 .62 1 .08],...
                'String', 'noise window: blue', 'fontunits',...
                'normalized','fontsize',0.7,'Fontweight','bold',...
                'ForegroundColor',[0.75 0.93 1]);
                
            txt6 = uicontrol(anno_bg,'Style','text','Visible','on',...
                'Units', 'normalized', 'Position',[.0 .51 1 .08],...
                'String', 'signal window: green','fontunits',...
                'normalized','fontsize',0.7,'Fontweight','bold',...
                'ForegroundColor',[0.68 1 .18]);
            
            
            txt8 = uicontrol(anno_bg,'Style','text','Visible','on',...
                'Units','normalized', 'Position',[.0 .05 1 .08],...
                'String','no criteria applied','FontWeight','bold',...
                'fontunits','normalized','fontsize',0.7);
            
        end
        
        bgcolor = [1 1 1];
        
        set(findobj(anno_bg,'-property', 'BackgroundColor'), ...
            'BackgroundColor', bgcolor);
    end
end
end



function event = calc_xks(event,apl)

if nargin > 1
    apl_settings = 1;
else
    apl_settings = 0;
end

% no phase yet
event.i_xks = 0;

% check all phases;
for i_phase = 1:length(event.phases)
    
    % select ..KS phases only
    p_str = char(event.phases(i_phase).name);
    find_xks = strfind(p_str, 'KS');
    
    if find_xks > 1
        event.i_xks = event.i_xks+1;
        
        % get arrival time of phase
        t_xks = event.phases(i_phase).tt_abs;
        if (event.i_xks == 1)
            t_xks_previous=t_xks;
        end
        
        %% check if window contains phase & ...
        %cutting an appropriate time window is possible
        
        cut = datenum((t_xks-seconds(50)));
        
        [~, index] = min(abs(event.time-cut));
        
        index_end = index+(100/event.sr);
        find_cut = event.time(index:index_end);
        
        if length(find_cut) > 99/event.sr
            
            % check for overlapping phases
            event.phases(i_phase).i_overlap = 0;
            if ((event.i_xks > 1) && ...
                    (seconds(t_xks-t_xks_previous) < 10.0))
                event.phases(i_phase).i_overlap = 1;
                % for next check
                t_xks_previous=t_xks;
            end
            
            
            % cut selected time windows 100 s length
            event.phases(i_phase).time_cut = event.time(index:index_end);
            
            event.phases(i_phase).z_cut = event.z_amp(index:index_end);
            event.phases(i_phase).north_cut = event.n_amp(index:index_end);
            event.phases(i_phase).east_cut = event.e_amp(index:index_end);
            
            % remove mean
            event.phases(i_phase).z_cut = event.phases(i_phase).z_cut ...
                - mean(event.phases(i_phase).z_cut);
            
            event.phases(i_phase).north_cut = ...
                event.phases(i_phase).north_cut ...
                - mean(event.phases(i_phase).north_cut);
            
            event.phases(i_phase).east_cut = ...
                event.phases(i_phase).east_cut ...
                - mean(event.phases(i_phase).east_cut);
            
            % filter traces long period for lp pm
            event.phases(i_phase).north_cut_lp = buttern_filter(...
                event.phases(i_phase).north_cut,2,...
                1/50,1/15,event.sr);
            event.phases(i_phase).east_cut_lp = buttern_filter(...
                event.phases(i_phase).east_cut,2,...
                1/50,1/15,event.sr);
           
            %% apply filter
            
            if apl_settings == 1
                
                
                % bandpass filter (in sec periods)
                event.phases(i_phase).z_cut = buttern_filter(...
                    event.phases(i_phase).z_cut,2,...
                    1/apl.p2,1/apl.p1,event.sr);
                event.phases(i_phase).north_cut = buttern_filter(...
                    event.phases(i_phase).north_cut,2,...
                    1/apl.p2,1/apl.p1,event.sr);
                event.phases(i_phase).east_cut = buttern_filter(...
                    event.phases(i_phase).east_cut,2,...
                    1/apl.p2,1/apl.p1,event.sr);
                
            end
            
            %norm traces
            maxt(1) = max(abs(event.phases(i_phase).z_cut));
            maxt(2) = max(abs(event.phases(i_phase).north_cut));
            maxt(3) = max(abs(event.phases(i_phase).east_cut));
            maxtt = max(maxt);
            
            event.phases(i_phase).z_cut = ...
                event.phases(i_phase).z_cut/maxtt;
            event.phases(i_phase).north_cut = ...
                event.phases(i_phase).north_cut/maxtt;
            event.phases(i_phase).east_cut = ...
                event.phases(i_phase).east_cut/maxtt;
            
            % calculate signal to noise ratio of XKS phase
            % on effective horizontal component
            
            h_trace = sqrt((event.phases(i_phase).north_cut).^2 ...
                +(event.phases(i_phase).east_cut).^2);
            event.phases(i_phase).snr_h = snr(h_trace,event.sr,20,25);
            
            % cut window for particle motion short period
            cut2 = datenum(t_xks - seconds(5));
            [~, index2] = min(abs(event.phases(i_phase).time_cut-cut2));
            
            index_end2 = index2+(30/event.sr);
            event.phases(i_phase).time_cut2 = ...
                event.phases(i_phase).time_cut(index2:index_end2);
            event.phases(i_phase).east_cut2 = ...
                event.phases(i_phase).east_cut(index2:index_end2);
            event.phases(i_phase).north_cut2 = ...
                event.phases(i_phase).north_cut(index2:index_end2);
            
            % cut window for particle motion long period
            event.phases(i_phase).east_cut2_lp = ...
                event.phases(i_phase).east_cut_lp(index2:index_end2);
            event.phases(i_phase).north_cut2_lp = ...
                event.phases(i_phase).north_cut_lp(index2:index_end2);
            
                       
            % calculate long to short axis
            [~,event.phases(i_phase).xlam1,event.phases(i_phase).xlam2]= ...
                covar(event.phases(i_phase).north_cut2, ...
                event.phases(i_phase).east_cut2);
            
            
        end
    end
end



end

function ui_save_apl(hObject,handles,e1,e2,e3,test_data)

% save settings
% input : e1,e2,e3 : editabel fields
% test_data: struct with directory

% get folder
test_data.set_folder = [test_data.work_dir,'/processed_data/'];

% get input from editable fields
p1 = get(e1,'String');
p2 = get(e2,'String');
snr = get(e3,'String');

save_str = ['Filter_',p1,'-',p2,'s_SNR_',snr];

mk_new_dir = [test_data.set_folder,'/',save_str];

% test if settings already exist
if exist(mk_new_dir,'dir')
    w = warndlg('The specified settings were already used. ',...
        'Warning!');
    drawnow; waitfor(w);
    return
    
end

% save settings as textfile
mkdir(mk_new_dir)

fileID = fopen([mk_new_dir,'/saved_settings.txt'], 'w');
fprintf(fileID, '%s %s %s\n',p1,p2,snr);
fclose(fileID);


end
