function uiget_p1(hObject,handles)

% get lower filter range ( in s )

% Copyright 2016 M.Reiss and G.Rümpker

global sel_data

sel_data.p1  = str2double(get(hObject,'String'));


end