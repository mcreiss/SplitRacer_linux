function plot_js_2L(results,station,nc,sel_data)

% plot joinst splitting results for two layers

% usage:
% results: struct with results from joint splitting analysis
% station: station name
% sel_data: struct with settings from GUI

% Copyright 2016 M.Reiss and G.Rümpker, altered May 2019

joint_split_fig = figure('Name',...
    'Joint Splitting Two Layers - SplitRacer 2.0','NumberTitle','off',...
    'units','normalized','position',[.1 .1 .9 .8]);
hp = uipanel('units','normalized','position',[.0 .0 1 1]);
movegui(joint_split_fig,'center')

%% info box
% write joint splitting results in sidebar for overview

hsp = uipanel('Visible', 'on','Position', [.0 .0 .5 1],...
    'Parent',hp);

if strcmp(sel_data.cat,'all')
    cat = 'all measurements';
else
    cat = 'only good and nulls';
end

annotation(hsp,'textbox', [0.05,0.95,0.9,0.04],'String',[...
    'Joint splitting results for station ',station, ', ', cat],...
    'fontunits','normalized','fontsize',0.025,'BackgroundColor', 'w');

bg = uibuttongroup('Visible', 'on','Position', [.02 .54 .4 .36],...
    'Parent',hsp);

txt1 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.0 .84 1 .15],'String','Results of splitting analysis ',...
    'fontunits','normalized','fontsize',0.42,'FontWeight','bold');

%% lower layer
txtl2 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.01 .7 .5 .11],'String','lower layer: ','fontunits',...
    'normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

txtl3 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.01 .61 .5 .11],'String','phi (°): ','fontunits',...
    'normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

txtl33 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.25 .61 .5 .11],'String',num2str(results.phiminval_low,3),...
    'fontunits','normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

txtl4 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.45 .61 .5 .11],'String','error (°): ','fontunits',...
    'normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

txtl44 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.7 .61 .5 .11],'String',[...
    num2str(results.err_phi_low(1),3),' - ',...
    num2str(results.err_phi_low(2),3)],...
    'fontunits','normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

txtl5 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.01 .53 .5 .11],'String','dt (s): ',...
    'fontunits','normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

txtl55 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.25 .53 .5 .11],'String',num2str(results.deltaminval_low,2),...
    'fontunits','normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

txtl6 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.45 .53 .5 .11],'String','error (s):',...
    'fontunits','normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

txtl66 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.7 .53 .5 .11],'String',[...
    num2str(results.err_dt_low(1),2),' - ',...
    num2str(results.err_dt_low(2),2)],...
    'fontunits','normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

%% upper layer
txt2 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.01 .43 .5 .11],'String','upper layer: ','fontunits',...
    'normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

txt3 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.01 .34 .5 .11],'String','phi (°): ','fontunits',...
    'normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

txt33 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.25 .34 .5 .11],'String',num2str(results.phiminval_upp,3),...
    'fontunits','normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

txt4 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.45 .34 .5 .11],'String','error (°): ','fontunits',...
    'normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

txt44 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.7 .34 .5 .11],'String',[...
    num2str(results.err_phi_upp(1),3),' - ',...
    num2str(results.err_phi_upp(2),3)],...
    'fontunits','normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

txt5 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.01 .24 .5 .11],'String','dt (s): ',...
    'fontunits','normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

txt55 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.25 .24 .5 .11],'String',num2str(results.deltaminval_upp,2),...
    'fontunits','normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

txt6 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.45 .24 .5 .11],'String','error (s):',...
    'fontunits','normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

txt66 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.7 .24 .5 .11],'String',[...
    num2str(results.err_dt_upp(1),2),' - ',...
    num2str(results.err_dt_upp(2),2)],...
    'fontunits','normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

txt7 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.01 .12 .5 .11],'String','filter (s):',...
    'fontunits','normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

txt77 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.25 .12 .5 .11],'String',[...
    num2str(sel_data.p1,3),' - ',num2str(sel_data.p2,3)],...
    'fontunits','normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

txt8 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.01 .02 .7 .11],'String','mean energy reduction (%):',...
    'fontunits','normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

txt88 = uicontrol(bg,'Style','text','Visible','on','Units','normalized',...
    'Position',[.7 .02 .3 .11],'String',...
    num2str(results.mean_energy_red,3),...
    'fontunits','normalized','fontsize',0.42,...
    'HorizontalAlignment', 'left','FontWeight','bold');

bgcolor = [1 1 1];

set(findobj(bg,'-property','BackgroundColor'),'BackgroundColor',bgcolor);

%% plot histogram
pause(0.1)
draw_bars_2L(results.ic_phi_low, results.ic_delta_low, ...
    results.ic_phi_upp,results.ic_delta_upp,results.fa_area,hsp);

%% plot confidence level
pause(0.1)
ax2 = axes('Position',[0.08,0.05,0.4,0.4],'Parent',hsp);

Plot95Conf_js_2L(results.maxtime, results.Ematrix_low, ...
    results.level_low, results.phiminval_low,results.deltaminval_low,...
    results.fa_area,ax2,'lower layer');

ax3 = axes('Position',[0.57,0.05,0.4,0.4],'Parent',hsp);

Plot95Conf_js_2L(results.maxtime, results.Ematrix_upp, ...
    results.level_upp, results.phiminval_upp,results.deltaminval_upp,...
    results.fa_area,ax3,'upper layer');

%% plot single events in pairs per tab
pause(0.1)
hsp2 = uipanel('Visible', 'on','Position', [.5 .0 .5 1],'Parent',hp);
tgroup= uitabgroup('Parent',hsp2);

fn = fieldnames(results);
find_events = strfind(fn,'event');
fe_log = ~cellfun(@isempty,find_events);
events = fn(fe_log);
no_events = length(events);

no_tab = 0;
p_vec = 0;

for i = 1 : no_events
    
    event = events{i};
    if mod(i,2) > 0
        no_tab = no_tab +1;
        if i< no_events
            tab(no_tab)=uitab(tgroup,'Title',['Event ', num2str(i),...
                '&',num2str(i+1)]);
        else
            tab(no_tab)=uitab(tgroup,'Title',['Event ', num2str(i)]);
        end
        if p_vec == 0.45
            p_vec = 0;
        end;
    else
        p_vec = 0.45;
    end
    
    % define axes
    positionVector1 = [0.1,0.82-p_vec,0.5,0.09];
    positionVector2 = [0.1,0.73-p_vec,0.5,0.09];
    positionVector3 = [0.1,0.61-p_vec,0.5,0.09];
    positionVector4 = [0.1,0.52-p_vec,0.5,0.09];
    positionVector5 = [0.68,0.73-p_vec,0.17,0.17];
    positionVector6 = [0.68,0.53-p_vec,0.17,0.17];
    pv_text = [0.87,0.68-p_vec,0.12,0.12];
    
    %plot north and east component
    M= length(results.(event).north3);
    axes('Parent',tab(no_tab));
    subplot('Position',positionVector1)
    plot(results.(event).times,results.(event).north3)
    axis([results.(event).times(1) results.(event).times(M) -1 1])
    set(gca,'xticklabel',{[]})
    title([datestr(results.(event).origin_time),', ',...
        results.(event).phases(results.(event).i_phase).name,', BAZ: ',...
        num2str(results.(event).baz),'\circ'])
    ylabel('North')
    subplot('Position',positionVector2)
    plot(results.(event).times,results.(event).east3)
    axis([results.(event).times(1) results.(event).times(M) -1 1])
    ylabel('East')
    
    % plot R and T components
    axes('Parent',tab(no_tab));
    subplot('Position',positionVector3)
    plot(results.(event).times,results.(event).radc)
    axis([results.(event).times(1) results.(event).times(M) -1 1])
    set(gca,'xticklabel',{[]})
    ylabel('R')
    subplot('Position',positionVector4)
    plot(results.(event).times,results.(event).trac)
    
    % plot used time windows
    hold on
    for k=1:length(results.(event).t1vec)
        xr(1)=results.(event).t1vec(k);
        yr(1)=-1;
        xr(2)=results.(event).t1vec(k);
        yr(2)=1;
        plot(xr,yr,'-r','LineWidth',1.5)
        xr(1)=results.(event).t2vec(k);
        yr(1)=-1;
        xr(2)=results.(event).t2vec(k);
        yr(2)=1;
        plot(xr,yr,'-r','LineWidth',1.5)
    end
    hold off
    axis([results.(event).times(1) results.(event).times(M) -1 1])
    ylabel('T')
    
    % plot original and corrected particle motion
    axes('Parent',tab(no_tab));
    subplot('Position',positionVector5)
    plot(results.(event).tra,results.(event).rad)
    ylabel('radial')
    title('particle motion')
    text(-0.9,0.9,'original')
    set(gca,'DataAspectRatio',[1 1 1])
    hold on
    xr(1)=0;
    yr(1)=0;
    xr(2)=0;
    yr(2)=1;
    plot(xr,yr,'-r','LineWidth',2.5)
    axis([-1.2 1.2 -1.2 1.2])
    hold off
    
    axes('Parent',tab(no_tab));
    subplot('Position',positionVector6)
    plot(results.(event).invtra,results.(event).invrad)
    xlabel('transverse')
    ylabel('radial')
    text(-0.9,0.9,'corrected')
    set(gca,'DataAspectRatio',[1 1 1])
    hold on
    xr(1)=0;
    yr(1)=0;
    xr(2)=0;
    yr(2)=1;
    plot(xr,yr,'-r','LineWidth',2.5)
    axis([-1.2 1.2 -1.2 1.2])
    hold off
    
    %% print energy reduction onto window
    en_str = {[num2str(results.(event).energy_red,2) '%'], ...
        'energy reduction'};
    
    txt = uicontrol(hsp2,'Style','text','Visible','on','Units',...
    'normalized','position',pv_text,'String',en_str,...
    'fontunits','normalized',...
    'fontsize',0.17,'Parent',tab(no_tab));

    tgroup.SelectedTab=tab(no_tab);
    
end

% create last tab to delete unuasable events

no_tab = no_tab+1;

tab(no_tab) = uitab(tgroup,'Title','delete phases','Foregroundcolor','r');

hsp_tab = uipanel('Visible', 'on','Position', [.1 .1 .8 .8],...
    'Parent',tab(no_tab));

bg_tab = uibuttongroup('Visible', 'on','Position', [.0 .0 1 1],...
    'Parent',hsp_tab);

txt1 = uicontrol(bg_tab,'Style','text','Visible','on','Units','normalized',...
    'Position',[.0 .8 1 .15],'String',['Below, you can delete phases',...
    ' which you found unsuitable for the analysis. You can then re-run', ...
    ' the calculation. Please be aware that if you delete phases here',...
    ' they will be unavailable for any future joint splitting analysis.'],...
    'fontunits','normalized','fontsize',0.16,'FontWeight','bold');

txta = uicontrol(bg_tab,'Style','text','Visible','on','Units','normalized',...
    'Position',[.15 .7 .2 .05],'String','event no: ',...
    'fontunits','normalized','fontsize',0.4);

txtb = uicontrol(bg_tab,'Style','text','Visible','on','Units','normalized',...
    'Position',[.15 .63 .2 .05],'String','event no: ',...
    'fontunits','normalized','fontsize',0.4);

txtc = uicontrol(bg_tab,'Style','text','Visible','on','Units','normalized',...
    'Position',[.15 .56 .2 .05],'String','event no: ',...
    'fontunits','normalized','fontsize',0.4);

txtd = uicontrol(bg_tab,'Style','text','Visible','on','Units','normalized',...
    'Position',[.15 .49 .2 .05],'String','event no: ',...
    'fontunits','normalized','fontsize',0.4);

txte = uicontrol(bg_tab,'Style','text','Visible','on','Units','normalized',...
    'Position',[.15 .42 .2 .05],'String','event no: ',...
    'fontunits','normalized','fontsize',0.4);

e1 = uicontrol(bg_tab, 'Style', 'edit','String','','enable', 'on',...
    'Units', 'normalized', 'position',[0.35,0.71,0.1,0.05]);
e2 = uicontrol(bg_tab, 'Style', 'edit','String','','enable', 'on',...
    'Units', 'normalized', 'position',[0.35,0.64,0.1,0.05]);
e3 = uicontrol(bg_tab, 'Style', 'edit','String','','enable', 'on',...
    'Units', 'normalized', 'position',[0.35,0.57,0.1,0.05]);
e4 = uicontrol(bg_tab, 'Style', 'edit','String','','enable', 'on',...
    'Units', 'normalized', 'position',[0.35,0.50,0.1,0.05]);
e5 = uicontrol(bg_tab, 'Style', 'edit','String','','enable', 'on',...
    'Units', 'normalized', 'position',[0.35,0.43,0.1,0.05]);


pb1 = uicontrol(bg_tab,'Style','pushbutton','Units', 'normalized',...
    'position',[0.60,0.55,0.2,0.1],'String',...
    'delete events','enable', 'on','fontunits',...
    'normalized','fontsize',0.2,'Callback',...
    {@uiget_delev,e1,e2,e3,e4,e5,events,results,station,nc,sel_data});

txt2 = uicontrol(bg_tab,'Style','text','Visible','on','Units','normalized',...
    'Position',[.48 .40 .1 .4],'String','}',...
    'fontunits','normalized','fontsize',0.8);

txt3 = uicontrol(bg_tab,'Style','text','Visible','on','Units','normalized',...
    'Position',[.1 .2 .8 .10],'String',['If you have deleted any events, ',...
    'remember to change their category to "poor" in the', ...
    ' single splitting results file.'],...
    'fontunits','normalized','fontsize',0.22,'ForegroundColor','r');

pb2 = uicontrol(bg_tab,'Style','pushbutton','Units', 'normalized',...
    'position',[0.10,0.11,0.25,0.1],'String',...
    '<html> re-categorize<br> single splitting results','enable',...
    'on','fontunits','normalized','fontsize',0.2,'callback',...
    {@open_si_sp_rtxt,sel_data,station});

pb3 = uicontrol(bg_tab,'Style','pushbutton','Units', 'normalized',...
    'position',[0.40,0.11,0.25,0.1],'String',...
    '<html>show (new) overview<br>off used events','enable', 'on','fontunits',...
    'normalized','fontsize',0.2,'callback',...
    {@sel_overview,sel_data,station});

pb4 = uicontrol(bg_tab,'Style','pushbutton','Units', 'normalized',...
    'position',[0.70,0.11,0.2,0.1],'String',...
    'exit','enable', 'on','fontunits',...
    'normalized','fontsize',0.2,'callback','close(gcbf)');

tgroup.SelectedTab = tab(1);

uiwait

end


function uiget_delev(hObject,handles,e1,e2,e3,e4,e5,events,results,...
    station,nc,sel_data)

outf = warning_2buttons(...
    'Do you really wanto to delete these events?',...
    'yes','no',station);
if outf == 2
    return
end


% get input from editable fields
del_events(1)  = str2double(get(e1,'String'));
del_events(2)  = str2double(get(e2,'String'));
del_events(3)  = str2double(get(e3,'String'));
del_events(4)  = str2double(get(e4,'String'));
del_events(5)  = str2double(get(e5,'String'));

del_events(isnan(del_events)) = [];

if isempty(del_events)
    w = warndlg('You did not select any events!',...
        ['Warning for station ', station]);
    drawnow
    waitfor(w);
    return
end

% load phases_js.mat

load([sel_data.results_folder, station, '_',nc, '/phases_js.mat'])


for i = 1:length(del_events)
    
    del_fieldname = events{del_events(i)};
    
    if isfield(data,del_fieldname)
        
    data = rmfield(data,del_fieldname);
    
    else 
        w = warndlg(['Event ', num2str(del_events(i)), ' was already deleted!'],...
            '!! Warning !!');
        drawnow
        waitfor(w)
    end
    
end

% save new phases_js.mat variable

save([sel_data.results_folder, station, '_',nc,'/phases_js.mat'],'data')

end


function open_si_sp_rtxt(hObject,handles,sel_data,station)

dirget_old = sel_data.results_folder;
dirget_new = strrep(dirget_old,'results','graphics_output/Splitting');
dirget = [dirget_new,station,'/Single_Splitting/'];

open([dirget,'splitting_results.txt']);

commandwindow
end

function sel_overview(hObject,handles,sel_data,station)

% save old info
old_station = sel_data.station;
sel_data.station = {station};
% call overview routine
overview(sel_data);
sel_data.station = old_station;

end    