function uiget_snr(hObject,handles)

% get SNR range for analysis

% Copyright 2016 M.Reiss and G.Rümpker

global sel_data

sel_data.snr  = str2double(get(hObject,'String'));

end