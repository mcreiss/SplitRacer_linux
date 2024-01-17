function ui_si_split(results,info,tab,fileID1,dir_save)

% GUI for chosing single splitting categories
% usage:
% results: results from single splitting analysis per phase
% info: settings fro GUI
% tab: tab number
% fileID1: file ID to write results and category in text file
% dir_save: destination folder
% split_fig: figure handle

% Copyright 2016 M.Reiss and G.Rümpker, altered May 2019

%% automatic change of display in case that phi is close to grid border
if abs(abs(results.phi)-info.fa_area)<30
    if info.fa_area == 0
        info.fa_area = 90;
    elseif info.fa_area == 90
        info.fa_area = 0;
    end
    results = re_scale(results,info);
    delete(tab.Children);
    
    % re plot results
    plot_si_sp(results,info,tab);
end

%% initalize gui

bg2 = uibuttongroup('Visible', 'on','Position', [0.03 .05 .2 .19],...
    'Parent',tab);

txt8 = uicontrol(bg2,'Style','text','Visible','on','Units','normalized',...
    'Position',[.0 .85 1 .12],'String','Categorize measurement: ',...
    'Fontunits','normalized','FontSize',0.82 ,'FontWeight','bold',...
    'BackgroundColor','w');
txt88= uicontrol(bg2,'Style','text','Visible','on','Units','normalized',...
    'Position',[0.0,0.36,1,0.24],'String',...
    ['If you click "good", "average" or "null",',...
    ' phase is saved for joint splitting analysis'],...
     'Fontunits','normalized','FontSize',0.38);

% radio buttons
r1 = uicontrol(bg2,'Style','radiobutton', 'String','good','units',...
    'normalized', 'Position',[0.04 .67 .2 .1],...
    'HandleVisibility','on','Tag','Button1');
r2 = uicontrol(bg2,'Style','radiobutton','String','average','units',...
    'normalized','Position',[0.29 .67 .2 .1],...
    'HandleVisibility','on','Tag','Button2');
r3 = uicontrol(bg2,'Style','radiobutton','String','poor','units',...
    'normalized','Position',[.54 .67 .2 .1],...
    'HandleVisibility','on','Tag','Button3');
r4 = uicontrol(bg2,'Style','radiobutton','String','null','units',...
    'normalized', 'Position',[.79 .67 .2 .1],...
    'HandleVisibility','on','Tag','Button4');

% usually, one would need an additional button to continue looking at more
% data, as one radio button must always be selected
% and can therefore not be combined with uiwait/uiresume. Button 5 is set
%invisible, so that clicking one of four
% options automatically leads to the next phase

r5 = uicontrol(bg2,'Style','radiobutton', 'units','normalized',...
    'Position',[.9 .1 .2 .1],...
    'Visible','off','Tag','Button5','enable','off');

bgcolor = [1 1 1];
set(findobj(bg2,'-property', 'BackgroundColor'),'BackgroundColor',bgcolor);
set(bg2,'SelectionChangeFcn',{@categ_out,bg2,results,tab,fileID1,dir_save});
set(bg2,'SelectedObject',r5)


%% second button group for changing phi interval or time window

bg3 = uibuttongroup('Visible', 'on','Position', [0.03 .05 .2 .06],...
    'Parent',tab);

btn1 = uicontrol(bg3,'Style','pushbutton','Units', 'normalized',...
    'position',[.05 .05 .4 .9],'String',...
    '<html>re-scale<br>phi interval',...
    'Callback',{@uiresplit,results,info,tab,fileID1,dir_save,1});
btn2 = uicontrol(bg3,'Style','pushbutton','Units', 'normalized',...
    'position',[.55 .05 .4 .9],'String',...
    '<html>re-evaluate<br>time window',...
    'Callback',{@uiresplit,results,info,tab,fileID1,dir_save,2});
bgcolor = [1 1 1];
set(findobj(bg3,'-property','BackgroundColor'),'BackgroundColor',bgcolor);        


uiwait

end

function categ_out(hObject,handles,bg2,results,tab,fileID1,dir_save)

% function for radio buttons/ categorization

switch get(get(bg2,'SelectedObject'),'Tag')
    case 'Button1'
        cat1 = 'good';
    case 'Button2'
        cat1 = 'average';
    case 'Button3'
        cat1 = 'poor';
    case 'Button4'
        cat1 = 'null-measurement';
        results.phi = results.baz;
        if results.phi > 180
            results.phi = results.phi - 180;
        end
        results.err_phi = [0 0];
        results.delta = 0;
        results.err_dt = [0 0];
end

% write textfile, SI and source paramters added

fprintf(fileID1, '%s %f %f %f %f %f %f %f %s %f %f %f %f %f %f %f %f %f %f %s\n', ...
    datestr(results.origin_time), results.lat, results.lon, results.depth,...
    results.mag, results.dist, results.baz, results.cordeg, ...
    results.phases(results.i_phase).name, results.phi,results.delta,...
    results.err_phi,results.err_dt,results.level,results.split_int,...
    results.split_err,cat1);

if strcmp(cat1,'good') || strcmp(cat1,'average') || ...
        strcmp(cat1,'null-measurement')

    save_phase_for_js(results,cat1,dir_save)

end

% display saved category

bg4 = uibuttongroup('Visible', 'on','Position', [0.03 .05 .2 .19],...
    'Parent',tab);
txt8 = uicontrol(bg4,'Style','text','Visible','on','Units','normalized',...
    'Position',[.0 .85 1 .1],'String','Categorize measurement: ',...
    'Fontunits','normalized','FontSize',0.82 ,'FontWeight','bold');
txt88= uicontrol(bg4,'Style','text','Visible','on','Units','normalized',...
    'Position',[0.0,0.36,1,0.24],'String',...
    ['result saved as "',cat1, '"'], ...
    'Fontunits','normalized','FontSize',0.38);
bgcolor = [1 1 1];
set(findobj(bg4,'-property', 'BackgroundColor'), ...
    'BackgroundColor', bgcolor);

uiresume(gcbf)
end

function uiresplit(hObject,handles,results,info,tab,fileID1,dir_save,flag)

% callback for re-calculating splitting

% for flag = 1 ; search range for fast polarization is altered
% for flagf = 2; new time window per mouse clicks is allowed

% change cursor while waiting
oldcursor = get(gcf,'Pointer');
set(gcf,'Pointer','watch');

% apply changes
if flag == 1
    
    if info.fa_area == 0
        info.fa_area = 90;
    elseif info.fa_area == 90
        info.fa_area = 0;
    end
    
    results = re_scale(results,info);
    
elseif flag == 2
    
    info.tw_inp = [];
    results = si_sp_analysis(results,results.i_phase,info);
    
end

delete(tab.Children);
set(gcf,'Pointer',oldcursor);

% re plot results
plot_si_sp(results,info,tab);

ui_si_split(results,info,tab,fileID1,dir_save)
end

