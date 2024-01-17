function uiget_ntw(hObject,handles)

% get number of time windows for analysis

% Copyright 2016 M.Reiss and G.Rümpker

global sel_data

sel_data.NL  = str2double(get(hObject,'String'));

end