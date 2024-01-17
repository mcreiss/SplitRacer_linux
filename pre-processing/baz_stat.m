function [clean_mean_miss_baz, bazfig] = baz_stat(data,station)

% calculates mean misorientation value from previously selected events

% input
% data: struct with events
% station: string with station name

% Copyright 2016 M.Reiss and G.Rümpker

events = fieldnames(data);
ts = strfind(events,'event');
tsd = sum(cell2mat(ts));
no_up = 0;

% read only information of phases fulfilling previous quality criteria

for iEvents = 1: tsd
    fn = ['event',num2str(iEvents)];
    for i_phase = 1:length(data.(fn).phases)
        if data.(fn).phases(i_phase).tw > 1
            no_up = no_up+1;
            cordeg(no_up) = data.(fn).phases(i_phase).cordeg;
            baz(no_up) = data.(fn).baz;
            time_vec(no_up) = data.(fn).origin_time;
        end
    end
end

% initialize figure
bazfig = figure('Name','Misalignment Check - SplitRacer 2.0',...
    'NumberTitle','off', 'units','normalized','position',[.3 .1 .7 .7]);
hp = uipanel('position',[.0 .0 1 1]);
movegui(bazfig,'center')

% title
title_str = ['Station: ', station, ', Distribution of misalignment' ];
annotation(hp,'textbox', [0.05,0.94,0.9,0.04],'String',title_str,...
    'fontunits','normalized','fontsize',0.025, 'BackgroundColor', 'w');

% plot distribution of misalignment
positionVector1 = [0.08,0.5,0.4,0.4];
axes('Parent',hp);
subplot('Position',positionVector1)

binrange = -90:10:90;
[bincounts,~] = histc(cordeg,binrange);
bar(binrange,bincounts)
ylabel('number of measurements')
xlabel('missorientation (\circ)')

% plot distribution of misalignment over baz
positionVector2 = [0.55,0.5,0.4,0.4];
axes('Parent',hp);
subplot('Position',positionVector2)
plot(baz,cordeg, 'd','MarkerFaceColor','b')
xlim([0 360]);
ylabel('misalignment (\circ)')
xlabel('BAZ (\circ)')
title('Missorientation to BAZ');

% plot distribution of misalignment over time
positionVector3 = [0.08,0.1,0.7,0.3];
axes('Parent',hp);
subplot('Position',positionVector3)
plot(time_vec,cordeg, 'o','MarkerFaceColor','w','MarkerEdgeColor','r',...
    'MarkerSize',8)

% calculate mean miss aligment
if length(cordeg)>1
    
    % calc mean
    mean_miss_baz = mean(cordeg);
    % calc standard deviation
    std_miss_baz = std(cordeg);
    % find values within one standard deviation
    abs_val = abs(cordeg-mean_miss_baz);
    miss_baz_find=find(abs_val<std_miss_baz);
    clean_miss_baz=cordeg(miss_baz_find);
    %calc new standard deviation without outliers
    clean_mean_miss_baz = mean(clean_miss_baz);
    clean_std = std(clean_miss_baz);
    new_time_vec = time_vec(miss_baz_find);
    
    % plot results
    hold all
    plot(new_time_vec,clean_miss_baz, 'd','MarkerFaceColor','r',...
        'MarkerEdgeColor','r','MarkerSize',8)
    plot([min(time_vec) max(time_vec)],...
        [clean_mean_miss_baz clean_mean_miss_baz],'k-');
    hold off
    l = legend({'values outside one SD  ','values used for mean'},...
    'position',[.81 .32 .12 .08]);
    ylabel('misalignment (\circ)');
    title('Misalignment over time');  
   
    %% info box
    hsp = uipanel('Parent',hp, 'Position',[0.8,0.1,0.15,0.2],...
        'BackgroundColor','w');
    txt = uicontrol(hsp,'Style','text','Visible','on','Units',...
        'normalized',...
        'Position',[.01 .8 .99 .15],'String','Results: ','fontunits',...
        'normalized','fontsize',0.8,'HorizontalAlignment', 'center',...
        'FontWeight','bold','BackgroundColor','w');

    txt1 = uicontrol(hsp,'Style','text','Visible','on','Units',...
        'normalized',...
        'Position',[.01 .4 .99 .3],'String',{'mean', ...
        ['misalignment: ' num2str(clean_mean_miss_baz,2) '°']},...
        'fontunits',...
        'normalized','fontsize',0.32,'HorizontalAlignment', 'left',...
        'BackgroundColor','w','FontWeight','bold');
    
    txt2 = uicontrol(hsp,'Style','text','Visible','on','Units',...
        'normalized',...
        'Position',[.01 .05 .99 .3],'String',{'sigma of', ...
        ['miss-orientation: ' num2str(clean_std,2) '°']},'fontunits',...
        'normalized','fontsize',0.32,'HorizontalAlignment', 'left',...
        'FontWeight','bold','BackgroundColor','w');
       
elseif length(cordeg) == 1
     
    hsp = uipanel('Parent',hp, 'Position',[0.8,0.1,0.15,0.2],...
        'BackgroundColor','w');
    txt = uicontrol(hsp,'Style','text','Visible','on','Units',...
        'normalized',...
        'Position',[.01 .8 .99 .15],'String','Results: ','fontunits',...
        'normalized','fontsize',0.8,'HorizontalAlignment', 'center',...
        'FontWeight','bold','BackgroundColor','w');
    
    
    txt1 = uicontrol(hsp,'Style','text','Visible','on','Units',...
        'normalized','Position',[.01 .4 .99 .3],'String',...
        {'only one event:', ...
        ['misalignment: ' num2str(cordeg,2) '°']},'fontunits',...
        'normalized','fontsize',0.32,'HorizontalAlignment', 'left',...
        'BackgroundColor','w','FontWeight','bold');
    
    clean_mean_miss_baz = cordeg;
    
end


end