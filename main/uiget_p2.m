function uiget_p2(hObject,handles)

% get upper filter range ( in s )

% Copyright 2016 M.Reiss and G.Rümpker

global sel_data

sel_data.p2  = str2double(get(hObject,'String'));

end
