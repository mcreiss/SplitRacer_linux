function outf = warning_2buttons(quest,b1,b2,station)

% this function prompts are warning box with two buttons
% usage: 
% quest: question to ask
% b1: string for first button
% b2: string for second button
% station: station name

% Copyright 2016 M.Reiss and G.Rümpker


global outf

d = dialog('units','normalized','Position',[.35 .5 .3 .15],...
    'Name',['Warning for station ',station]);

txt = uicontrol('Parent',d,'Style','text','units','normalized',...
    'Position',[.1 .5 .8 .4],'String',quest,'fontunits',...
    'normalized','fontsize',0.22);

btn1 = uicontrol('Parent',d,'units','normalized','Position',...
    [.2 .2 .2 .2], 'String',b1,'Callback',{@uiout,1});
btn2 = uicontrol('Parent',d,'units','normalized','Position',...
    [.6 .2 .2 .2], 'String',b2,'Callback',{@uiout,2});

uiwait(gcf)
end

function uiout(hObject,handles,answer)

global outf

outf=answer;
delete(gcf);

end
