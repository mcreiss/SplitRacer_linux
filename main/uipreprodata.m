function uipreprodata(hObject,handles)

% GUI menu to select data for download

% Copyright 2016 M.Reiss and G.Rümpker

global sel_data e1 e2 e3 pd1

% main panel for processing
hsp_prep = uipanel('units','normalized','position',[.2 .0 .8 1]);

% main button group 
prep_bg = uibuttongroup('Parent',hsp_prep,'Visible', 'on','Position', ...
    [.0 .0 1 1]);

% title string
title_str = uicontrol(prep_bg,'Style','text','Visible','on','Units',...
    'normalized','position',[0.2,0.92,0.6,0.05],'String',...
    'Select pre-processing parameters',...
    'fontunits','normalized','fontsize',0.8);

% button group for setting processing parameters
prep_bg1 = uibuttongroup('Parent',hsp_prep,'Title',...
    'Explore data & set parameters', 'Visible', 'on','Position',...
    [.0 .0 .5 .85],'fontunits','normalized','fontsize',0.05);

pb1 = uicontrol(prep_bg1,'Style','pushbutton','Units', 'normalized',...
    'position',[0.05,0.8,0.4,0.1],'String',...
    'view waveforms','fontunits',...
    'normalized','fontsize',0.33,'Callback',{@ui_ex_data,sel_data});

txt = uicontrol(prep_bg1,'Style','text','Visible','on','Units',...
    'normalized','position',[0.0,0.62,1,0.1],'String',...
    'Choose basic analysis parameters','fontweight','bold',...
    'fontunits','normalized','fontsize',0.33);

r1 = uicontrol(prep_bg1,'Style','radiobutton', 'String','manual input',...
    'units','normalized', 'Position',[0.05 .55 .5 .1],'fontunits',...
    'normalized','fontsize',0.33,...
    'HandleVisibility','on','Tag','Button1');

r2 = uicontrol(prep_bg1,'Style','radiobutton', 'String',...
    'load saved settings','units','normalized', 'Position',...
    [0.5 .55 .5 .1],'fontunits', 'normalized','fontsize',0.33,...
    'HandleVisibility','on','Tag','Button2');

[disp_stations] = disp_st_lst;

txt1 = uicontrol(prep_bg1,'Style','text','Visible','on','Units',...
    'normalized','position',[0.05,0.43,0.4,0.1],'String',...
    'Choose station', 'fontunits','normalized','fontsize',0.33);

pd1 = uicontrol(prep_bg1,'Style','popupmenu', 'String',disp_stations,...
    'Units','normalized','position',[0.5,0.43,0.4,0.1],'fontunits',...
    'normalized', 'fontsize', 0.31,'Callback',@uiget_st);

txt2 = uicontrol(prep_bg1,'Style','text','Units', 'normalized',...
    'position',[0.05,0.32,0.4,0.1],'String','Filter [s]','fontunits',...
    'normalized','fontsize',0.33);

txt3 = uicontrol(prep_bg1,'Style','text','Units', 'normalized',...
    'position',[0.5,0.32,0.4,0.1],'String','-','fontunits',...
    'normalized','fontsize',0.33);

e1 = uicontrol(prep_bg1, 'Style', 'edit','String','4',...
    'Units', 'normalized', 'position',[0.5,0.38,0.15,0.05],...
    'Callback',@uiget_p1);

e2 = uicontrol(prep_bg1, 'Style', 'edit','String','50',...
    'Units', 'normalized', 'position',[0.75,0.38,0.15,0.05],...
    'Callback',@uiget_p2);

txt4 = uicontrol(prep_bg1,'Style','text','Units', 'normalized',...
    'position',[0.05,0.23,0.4,0.1],'String','Choose SNR cut-off',...
    'fontunits', 'normalized','fontsize',0.33);

e3 = uicontrol(prep_bg1, 'Style', 'edit','String','2.5',...
    'Units', 'normalized', 'position',[0.5,0.27,0.15,0.05],...
    'Callback',@uiget_snr);


%% button group for selecting a processing step

prep_bg2 = uibuttongroup('Parent',hsp_prep,'Title', ...
    'Prepare data','Visible', 'on','Position', [.5 .0 .5 .85],...
    'fontunits','normalized','fontsize', 0.05);

txt11 = uicontrol(prep_bg2,'Style','text','Units', 'normalized',...
    'position',[0.05,0.77,0.4,0.1],'String',...
    'Step 1:','fontunits','normalized','fontsize',0.33);

pb11 = uicontrol(prep_bg2,'Style','pushbutton','Units', 'normalized',...
    'position',[0.5,0.8,0.4,0.1],'String', ...
    '<html>Initial<br>Pre-processing','enable',...
    'off','fontunits',...
    'normalized','fontsize',0.33,'Callback',{@uigetinput,1});

txt22 = uicontrol(prep_bg2,'Style','text','Units', 'normalized',...
    'position',[0.05,0.62,0.4,0.1],'String',...
    'Step 2:','fontunits',...
    'normalized','fontsize',0.33);

pb22 = uicontrol(prep_bg2,'Style','pushbutton','Units', 'normalized',...
    'position',[0.5,0.65,0.4,0.1],'String',...
    '<html>Visual<br>Quality check','enable',...
    'off','fontunits',...
    'normalized','fontsize',0.33,'Callback',{@uigetinput,2});

txt33 = uicontrol(prep_bg2,'Style','text','Units', 'normalized',...
    'position',[0.05,0.47,0.4,0.1],'String',...
    'Step 3:','fontunits',...
    'normalized','fontsize',0.33);

pb33 = uicontrol(prep_bg2,'Style','pushbutton','Units', 'normalized',...
    'position',[0.5,0.5,0.4,0.1],'String',...
    '<html>Check station<br>misalignment','enable', 'off','fontunits',...
    'normalized','fontsize',0.33,'Callback',{@uigetinput,3});

pb44 = uicontrol(prep_bg2,'Style','pushbutton','Units', 'normalized',...
    'position',[0.5,0.25,0.4,0.1],'String',...
    '<html>save<br>statistics','enable', 'off','fontunits',...
    'normalized','fontsize',0.33,'Callback',@uistat);

%% OK - enable button

pb2 = uicontrol(prep_bg1,'Style','pushbutton','Units', 'normalized',...
    'position',[0.05,0.1,0.4,0.1],'String', 'OK','fontunits',...
    'normalized','fontsize',0.33,'Callback',{@ui_ok,...
    prep_bg1,r1,r2,prep_bg2,pb11,pb22,pb33,pb44});

set(prep_bg1,'SelectionChangeFcn', {@ui_choose_pre_para,prep_bg1});
set(prep_bg1,'SelectedObject',r1)

end


function ui_choose_pre_para(hObject,handles,prep_bg1)

% load settings from previous processing/ check data 

global e1 e2 e3 pd1 sel_data

switch get(get(prep_bg1,'SelectedObject'),'Tag')
                
    case 'Button2'
        
        % read file
        [sel_data.set_file, sel_data.set_folder] = ...
            uigetfile('*.txt','please select file with saved settings',...
            [sel_data.work_dir,'/processed_data/']);
        
        fileID = fopen([sel_data.set_folder,sel_data.set_file]);
        C = textscan(fileID,'%f %f %3.1f');
        fclose(fileID);
        
        % write in editable fields
        e1 = uicontrol(prep_bg1,'Style','edit','String',num2str(C{1}),...
            'Units', 'normalized', 'position',[0.5,0.38,0.15,0.05],...
            'Callback',@uiget_p1);
        
        e2 = uicontrol(prep_bg1,'Style','edit','String',num2str(C{2}),...
            'Units', 'normalized', 'position',[0.75,0.38,0.15,0.05],...
            'Callback',@uiget_p2);
        
        e3 = uicontrol(prep_bg1,'Style','edit','String',num2str(C{3},3),...
            'Units', 'normalized', 'position',[0.5,0.27,0.15,0.05],...
            'Callback',@uiget_snr);
        
        % get parameters
        uiget_p1(e1)
        uiget_p2(e2)
        uiget_snr(e3)
        uiget_st(pd1)
end


end


function ui_ok(hObject,handles,prep_bg1,r1,r2,prep_bg2,pb11,pb22,pb33,pb44)

% get chosen paramters

global sel_data e1 e2 e3 pd1

switch get(get(prep_bg1,'SelectedObject'),'Tag')
    
    case 'Button1' % if manual inout was chosen, a new folder is created
        
        % get path
        sel_data.set_folder = [sel_data.work_dir,'/processed_data/'];
        
        % get settings for name
        p1 = get(e1,'String');
        p2 = get(e2,'String');
        snr = get(e3,'String');
        
        % folder name
        save_str = ['Filter_',p1,'-',p2,'s_SNR_',snr];
        
        mk_new_dir = [sel_data.set_folder,'/',save_str];
        
        if exist(mk_new_dir,'dir')
             w = warndlg(['The specified settings were already used. ',...
            'Please click "load saved settings" instead!'],...
            'Warning!');
            drawnow
            waitfor(w);
            return
            
        end
        
        % get input
        uiget_p1(e1)
        uiget_p2(e2)
        uiget_snr(e3)
        uiget_st(pd1)
        
        sel_data.set_folder = mk_new_dir;
        mkdir(mk_new_dir)
               
        fileID = fopen([mk_new_dir,'/saved_settings.txt'], 'w');
        fprintf(fileID, '%s %s %s\n',p1,p2,snr);
        fclose(fileID);
                       
end

% enable processing steps

set(pb11,'Enable','on')
set(pb22,'Enable','on')
set(pb33,'Enable','on')
set(pb44,'Enable','on')

% disable other buttons

set(pd1,'enable','off')
set(e1,'enable','off')
set(e2,'enable','off')
set(e3,'enable','off')
set(r1,'enable','off')
set(r2,'enable','off')
set(hObject,'enable','off')

end
