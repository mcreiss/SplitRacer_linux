function uicreate(hObject,handles)

% create new directory

% Copyright 2016 M.Reiss and G.Rümpker

global sel_data

new_work_dir = [sel_data.work_dir,'/',get(hObject,'String')];

sel_data.work_dir = new_work_dir;

mkdir(new_work_dir)

end