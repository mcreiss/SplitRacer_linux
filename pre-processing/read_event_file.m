function [event] = read_event_file(C2,n)

% extract event data from textfile

% Copyright 2016 M.Reiss and G.Rümpker

event.year = C2{1,1}(n);
event.month = C2{1,2}(n);
event.day = C2{1,3}(n);
event.hour = C2{1,4}(n);
event.min = C2{1,5}(n);
event.sec = C2{1,6}(n);
event.lat = C2{1,7}(n);
event.lon = C2{1,8}(n);
event.dist = C2{1,9}(n);
event.baz = C2{1,10}(n);
event.depth = C2{1,11}(n);
event.mag = C2{1,12}(n);
                
end