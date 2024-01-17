function d = wait_icon(station,flag)

% wait icon which is shown during calculation
if flag ==1
    d = dialog('units','normalized','position',[.4 .5 .2 .1],'Name',...
        'Joint splitting single layer');
else
    d = dialog('units','normalized','position',[.4 .5 .2 .1],'Name',...
        'Joint Splitting two layers');
end
                    
iconsClassName = 'com.mathworks.widgets.BusyAffordance$AffordanceSize';
iconsSizeEnums = javaMethod('values',iconsClassName);
SIZE_32x32 = iconsSizeEnums(3);  
jObj = com.mathworks.widgets.BusyAffordance(SIZE_32x32);  % icon, label

jObj.setPaintsWhenStopped(true);  
jObj.useWhiteDots(false);         

test = jObj.getComponent;
[jh,hcon] = javacomponent(test, [10 10 80 80], gcf);

set(hcon,'Units','norm','position',[0.2 0.1 .6 .4])
bgcolor = get(gcf, 'Color');

test.setBackground(java.awt.Color(bgcolor(1),bgcolor(2),bgcolor(3)));

jObj.start;
    
txt = uicontrol('Parent',d,...
               'Style','text',...
               'units','normalized','position',[.1 .7 .8 .2],...
               'String',...
               ['calculating results for station ',char(station)],...
               'fontunits', 'normalized','fontsize',0.6,'fontweight','bold');
end