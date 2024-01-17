function uiget_event(hObject,handles)

% get event for check phases window

% Copyright 2016 M.Reiss and G.Rümpker

global test_data

strings = get(hObject,'String');
test_data.plot_vals = get(hObject,'Value');

test_data.plot_event  = strings(test_data.plot_vals,:);

end