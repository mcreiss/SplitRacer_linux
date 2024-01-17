function uiget_fa_area(hObject,handles,split_bg1)

% get phi range for analysis

% Copyright 2016 M.Reiss and G.Rümpker

global sel_data

switch get(get(hObject,'SelectedObject'),'Tag')
    
    case 'Button1'
        sel_data.fa_area  = 90;
    case 'Button2'
        sel_data.fa_area  = 0;
        
end

end