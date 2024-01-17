function uigetinput(hObject,handles,flag)

% this function distributs the input parameters to the desired processing
% step
% flag must be set accordingly

% Copyright 2016 M.Reiss and G.Rümpker

global sel_data

    if flag == 1
        prep_data(sel_data)
    elseif flag == 2
        quality_check(sel_data)
    elseif flag == 3
        misalignment_check(sel_data)
    elseif flag == 4
        single_splitting(sel_data)
    elseif flag == 5
        outff = warning_2buttons(['Would you like to view all events',...
            'at the same time seperated by tabs or consecutively? ',...
            'If you expect 30+ events, the tab view mode will be slower ...'], ...
            'tabs','one at a time','!');
        if outff == 1
            show_si_sp(sel_data)
        else
            show_si_sp_new(sel_data)
        end
    elseif flag == 6
        overview(sel_data)
    elseif flag == 7
        js(sel_data)
    elseif flag == 8
        js_2L(sel_data)
    elseif flag == 9
        show_js(sel_data)
    elseif flag == 10
        show_js_2L(sel_data)
    end
    
    
end

