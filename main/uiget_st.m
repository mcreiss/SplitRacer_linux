function uiget_st(hObject,handles)

% get selected station(s)

% Copyright 2016 M.Reiss and G.Rümpker

global sel_data

stations = get(hObject,'String');
sel_station = get(hObject,'Value');
sel_data.station = stations(sel_station);

end