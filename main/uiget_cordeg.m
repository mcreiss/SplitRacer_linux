function uiget_cordeg(hObject,handles,ch1,ch2,ch3)

% check if mean, single or other misalignment value should be used
%  whichever checkbox was checked, this is ch1, check the tag for which
%  case

% Copyright 2019 M.Reiss and G.Rümpker, altered May 2019

global e5

% set other checkboxes to 'unchecked'
set(ch2,'value',0)
set(ch3,'value',0)

% get tag
get_tag = get(ch1,'Tag');
if strcmp(get_tag, 'cb3')
    set(e5,'enable','on') % turn on editable field
else
    set(e5,'enable','off','String',0) % turn it off
end

end